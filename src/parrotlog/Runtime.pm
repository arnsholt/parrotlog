# Variables and terms. The variable code is largely inspired by the Perl code
# in this PerlMonks post:  http://www.perlmonks.org/?node_id=193649
=begin Variable

Variable is the internal data structure used for Prolog Variables.

=end Variable
class Variable {
    has $!value;
    has $!name;

    method value() {
        if $!value ~~ Variable || $!value ~~ Term {
            return $!value.value;
        }
        else {
            return $!value;
        }
    }

    method name($name?) {
        if pir::defined($name) {
            $!name := $name;
        }

        return $!name;
    }

    method references($other) {
        if self =:= $other        { return 1; }
        elsif $!value ~~ Variable { return $!value.references($other); }
        else                      { return 0; }
    }

    method bind($other) {
        if $!value ~~ Term {
            pir::die("Attempted to bind bound Variable");
        }
        elsif $!value ~~ Variable {
            $!value.bind($other);
        }
        else {
            #if $other ~~ Variable
            if $other ~~ Term {
                $!value := $other;
            }
            elsif $other ~~ Variable {
                # Make sure $other isn't bound to self.
                return 0 if $other.references(self);
                $!value := $other;
            }
            else {
                pir::die("Attempted to bind Variable to non-Variable, non-Term");
            }
        }
    }

    method bound() {
        if    $!value ~~ Term     { return 1;}
        elsif $!value ~~ Variable { return $!value.bound; }
        else                      { return 0; }
    }

    method unbind() {
        $!value := Undef;
    }

    method output($indent = '') {
        pir::say($indent ~ ($!name ?? $!name !! '_'));
    }
}

=begin Term

Term represents a Prolog term; both atoms and complex terms. An atom will have
$arity 0 and an ampty args array, while complex terms will have $arity > 0 and
the corresponding number of elements in @args.

=end Term
class Term {
    has $!functor;
    has $!arity;
    has @!args;

    method get_bool() { return 1; }

    method from_data($functor, *@args) {
        my $term := Term.new;
        $term.functor($functor);
        $term.arity(+@args);
        $term.args(|@args);

        return $term;
    }

    method functor($ctor?) {
        if $ctor {
            $!functor := $ctor;
        }

        return $!functor;
    }

    method arity($arity?) {
        if pir::defined($arity) {
            $!arity := $arity;
        }

        return $!arity;
    }

    method args(*@args) {
        if @args {
            @!args := @args;
        }

        return @!args;
    }

    method value() { return self; }

    # Pretty print.
    method output($indent = '') {
        pir::say("$indent$!functor/$!arity");

        for @!args -> $arg {
            if $arg ~~ Term { $arg.output($indent ~ '  '); }
            elsif $arg ~~ Variable { $arg.output($indent ~ '  '); }
            else { pir::say("$indent  $arg"); }
        }
    }
}

sub unify($paths, $x, $y) {
    if $x =:= $y {
        # XXX: ATM NQP ignores bare returns, so we return a value.
        return 1;
    }

    if $x ~~ Term && $y ~~ Term {
        # First, check that the functors and arities are the same.
        if $x.functor ne $y.functor
        || $x.arity   != $y.arity {
            fail($paths);
        }

        # Then, make sure the argument lists unify as well.
        my $i := 0;
        my @x := $x.args;
        my @y := $y.args;
        while $i < $x.args {
            unify($paths, @x[$i], @y[$i]);
            $i++;
        }

        return 1;
    }
    elsif ($x ~~ Variable && $y ~~ Term)
    ||    ($x ~~ Term && $y ~~ Variable) {
        # To simplify control flow.
        if $x ~~ Term {
            my $tmp := $x;
            $x := $y;
            $y := $tmp;
        }

        my $var := $x;
        my $term := $y;

        if $var.bound {
            unify($paths, $var.value, $term);
        }
        else {
            # The binding of a Variable has to be undone on backtracking.
            if choicepoint($paths) {
                $var.unbind;
                fail($paths);
            }
            else {
                $var.bind($term);
            }
        }
    }
    elsif $x ~~ Variable && $y ~~ Variable {
        if $x.bound && $y.bound {
            unify($paths, $x.value, $y.value);
        }
        # One or both unbound.
        else {
            if $x.bound {
                my $tmp := $x;
                $x := $y;
                $y := $tmp;
            }

            # The binding of a Variable has to be undone on backtracking.
            if choicepoint($paths) {
                $x.unbind;
                fail($paths);
            }
            else {
                $x.bind($y);
            }
        }
    }
    else {
        pir::die("Attempting to unify() something that isn't a Variable or a Term");
    }
}
