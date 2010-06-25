=begin spec

The spec gives five, mutually exclusive types for terms: variables, integers,
floating point numbers, atoms and compound terms (section 7.1).

Variables, atoms (as compound terms of arity 0) and compound terms we handle
properly already. Data types for ints and floats are still TODO.

=end spec

# PrologTerm: Base class for all Prolog types.
class PrologTerm {
    # Section 7.1.1.1, variable set of a term
    method variable_set() { pir::die("virtual method!"); }

    # Section 7.1.1.3, existential variables set of a term
    method existential_vars() { pir::die("virtual method!"); }

    # Section 7.1.1.4, free variables set of a term
    method free_vars($term) { pir::die("virtual method!"); }
}

# Variables and terms. The variable code is largely inspired by the Perl code
# in this PerlMonks post:  http://www.perlmonks.org/?node_id=193649
=begin Variable

Variable is the internal data structure used for Prolog Variables.

=end Variable
class Variable is PrologTerm {
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
class Term is PrologTerm {
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
            if $arg ~~ PrologTerm { $arg.output($indent ~ '  '); }
            else { pir::say("$indent  $arg (Non T/V)"); }
        }
    }
}

class Int is PrologTerm {
    has $!value;

    method create($value) {
        my $i := Int.new;
        $i.value($value);
        return $i;
    }

    method value($value?) {
        if pir::defined($value) {
            $!value := $value
        }

        return $!value;
    }

    method variable_set() { return pir::null__p; }
    method existential_vars() { return pir::null__p; }
    method free_vars($t) { return pir::null__p; }

    method output($indent = '') { pir::say("$indent$!value"); }
}

class Float is PrologTerm {
    has $!value;

    method create($value) {
        my $f := Float.new;
        $f.value($value);
        return $f;
    }

    method value($value?) {
        if pir::defined($value) {
            $!value := $value
        }

        return $!value;
    }

    method variable_set() { return pir::null__p; }
    method existential_vars() { return pir::null__p; }
    method free_vars($t) { return pir::null__p; }

    method output($indent = '') { pir::say("$indent$!value"); }
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

# Directives: section 7.4.2
our %directives;
# Because NQP doesn't support hash literals.
INIT {
    %directives<dynamic>         := dynamic;
    %directives<multifile>       := multifile;
    %directives<discontiguous>   := discontiguous;
    %directives<op>              := op;
    %directives<char_conversion> := char_conversion;
    %directives<initialization>  := initialization;
    %directives<include>         := include;
    %directives<ensure_loaded>   := ensure_loaded;
}

sub handle_directive($ast) {
    $ast := $ast.args[0];
    pir::die("Unknown directive {$ast.functor}") if !%directives{$ast.functor};
    %directives{$ast.functor}(|$ast.args);
}

sub dynamic($predicate) {}
sub multifile($predicate) {}
sub discontiguous($predicate) {}

sub op($priority, $spec, $operator) {
    pir::say("Defining operator {$priority.functor}, {$spec.functor}, {$operator.functor}");
    # TODO: Essentially, create a rule *fix:sym<$operator> { <sym> <O("$spec $priority")> }
}

sub char_conversion($in, $out) {}
sub initialization($predicate) {}
sub include($file) {}
sub ensure_loaded($file) {}
