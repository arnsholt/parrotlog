# Variables and terms. The variable code is largely inspired by the Perl code
# in this PerlMonks post:  http://www.perlmonks.org/?node_id=193649
=begin Ref

Ref is a quick and dirty reference class that lets us emulate the references
used in the Perl code.

=end Ref
class Ref {
    has $!value;

    method bind($x) {
        $!value := $x;
    }

    method unbind() {
        $!value := undef;
    }

    method value() { return $!value; }
}

=begin Variable

=end Variable
class Variable {
    has $!value;

    # Create a new free variable.
    method free() {
        my $var := new;
        $var.container(Ref.new);
    }

    method bound() {
        # XXX: Probably wrong...
        return $!value // $!value.value.value;
    }

    method value() {
        # XXX: Possibly wrong...
        return $!value.value.value;
    }

    method container($c?) {
        if $c {
            $!value := $c;
        }

        return $!value;
    }

    method equal($other) {
        $!value =:= $other.container || value().equal($other.value);
    }

    method bind($other) {
        fail() if bound;

        if $other ~~ Var {
            $!value := $other.container;
        }
        else {
            # TODO
        }
        return 1;
    }

    method unbind() {
        $!value := Ref.new;
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

    # XXX: No objects have a defined() method.
    method functor($ctor?) {
        if $ctor.defined {
            $!functor := $ctor;
        }

        return $!functor;
    }

    method arity($arity?) {
        if $arity.defined {
            $!arity := $arity;
        }

        return $!arity;
    }

    method args(*@args) {
        if @args.defined {
            @!args := @args;
        }

        return @!args;
    }
}

sub unify($paths, $x, $y) {
    if $x ~~ Term && $y ~~ Term {
        if $x.functor ne $y.functor
        || $x.arity   != $y.arity {
            fail($paths);
        }

        # TODO: Make sure argument lists unify.
    }
    elsif $x ~~ Var && $y ~~ Term
    ||    $x ~~ Term && $y ~~ Var {
        # simplify control flow.
        if $x ~~ Term {
            my $tmp := $x;
            $x := $y;
            $y := $tmp;
        }

        $x.bind($y);
    }
    else {
    }
=begin sketch

- If both vars are unbound, bind one to the other.
- If only one is unbound, bind it to the bound one.
- If both are bound: check functor and arity equal, then unify each element of
  the arglist.

=end sketch
}

# XXX: Temporary code to test guts.
our $tests;

sub say($str) {
    pir::say($str);
}

sub ok($msg?) {
    $tests++;
    if $msg {
        say("ok $tests - $msg");
    }
    else {
        say("ok $tests");
    }
}

sub not_ok($msg?) {
    $tests++;
    if $msg {
        say("not ok $tests - $msg");
    }
    else {
        say("not ok $tests");
    }
}

sub plan($count?) {
    if !$count {
        $count := $tests;
    }

    say("1..$count");
}

sub MAIN() {
    my $x := Variable.new;
    $tests := 0;
    ok("creating empty Variable");

    my $paths := paths();
    if $paths {
        ok("creating paths");
        fail($paths);
    }
    else {
        ok("backtracking");
    }

    plan();
}
