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

    method from_data($functor, *@args) {
        my $term := Term.new;
        $term.functor($functor);
        $term.arity(@args);
        $term.args(|@args);

        return $term;
    }

    # XXX: No objects have a defined() method.
    method functor($ctor?) {
        if $ctor {
            $!functor := $ctor;
        }

        return $!functor;
    }

    method arity($arity?) {
        if $arity {
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
    elsif $x ~~ Var && $y ~~ Term
    ||    $x ~~ Term && $y ~~ Var {
        # To simplify control flow.
        if $x ~~ Term {
            my $tmp := $x;
            $x := $y;
            $y := $tmp;
        }

        # TODO
        $x.bind($y);
    }
    else {
        # TODO
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

sub diag($str) {
    say("# $str");
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

sub succeeds(&block, $msg?) {
    my $*paths := paths();
    if $*paths {
        &block();
        ok($msg);
    }
    else {
        not_ok($msg);
    }
}

sub fails(&block, $msg?) {
    my $*paths := paths();
    if $*paths {
        &block();
        not_ok($msg);
    }
    else {
        ok($msg);
    }
}

sub unifies($x, $y, $msg?) {
    succeeds( { unify($*paths, $x, $y); }, $msg);
}

# XXX: Needs a better name...
sub not_unifies($x, $y, $msg?) {
    fails( { unify($*paths, $x, $y); }, $msg);
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

    # Test unification of terms.
    my $atom := Term.from_data("atom");
    ok("creating atoms");
    unifies($atom, $atom, "unification of atom to itself");

    my $other_atom := Term.from_data("atom");
    unifies($atom, $other_atom, "unification of atom to identical atom");

    my $different := Term.from_data("different");
    not_unifies($atom, $different, "non-unification of unequal atoms");

    my $complex := Term.from_data("term", $atom);
    unifies($complex, $complex, "unification of complex term to itself");

    my $other_complex := Term.from_data("term", $other_atom);
    unifies($complex, $other_complex, "unification of complex term to identical complex term");

    my $different_complex := Term.from_data("different", $atom);
    not_unifies($complex, $different_complex, "non-unification of different complex terms");

    # Test unification of variables.
    # TODO

    plan();
}
