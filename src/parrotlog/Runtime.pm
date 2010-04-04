# Variables and terms. The variable code is largely inspired by the Perl code
# in this PerlMonks post:  http://www.perlmonks.org/?node_id=193649
=begin Ref

Ref is a quick and dirty reference class that lets us emulate the references
used in the Perl code.

=end Ref
class Ref {
    has $!value;

    method value($value?) {
        # XXX: This should really be ``if $value'', but that breaks on the
        # get_bool() VTABLE method not being implemented in Term, and I can't
        # figure out how to do that in NQP.
        if $value ~~ Term {
            $!value := $value;
        }

        return $!value;
    }
}

=begin Variable

Variable is the internal data structure used for Prolog Variables.

=end Variable
class Variable {
    has $!container;

    # Create a new free variable.
    method free() {
        my $var := self.new;
        $var.unbind();
        return $var;
    }

    method value() {
        return $!container.value;
    }

    my method container() {
        return $!container;
    }

    method bind($other) {
        pir::die("Attempted to bind bound Variable") if self.value;

        if $other ~~ Variable {
            if $other.bound {
                $!container.value($other.value);
            }
            else {
                $!container := $other.container;
            }
        }
        elsif $other ~~ Term {
            $!container.value($other);
        }
        else {
            pir::die("Attempted to bind Variable to non-Variable, non-Term");
        }
    }

    # Because ``if $variable.value'' is broken.
    method bound() {
        return self.value ~~ Term;
    }

    method unbind() {
        $!container := Ref.new;
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
        $term.arity(@args);
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
    # BUG: Binding a variable to a value represents a choice point, so we have
    # to save a continuation and undo the binding on failure.
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

        diag("var/term unification");
        if $var.bound {
            diag("var bound");
            unify($paths, $var.value, $term);
        }
        else {
            diag("var unbound");
            $var.bind($term);
        }
    }
    elsif $x ~~ Variable && $y ~~ Variable {
        diag("var/var unification");
        if $x.bound && $y.bound {
            diag("both bound");
            unify($paths, $x.value, $y.value);
        }
        # One or both unbound.
        else {
            diag("> 0 unbound");
            if $x.bound {
                my $tmp := $x;
                $x := $y;
                $y := $tmp;
            }

            $x.bind($y);
        }
    }
    else {
        pir::die("Attempting to unify() something that isn't a Variable or a Term");
    }
}

# XXX: Temporary code to test guts.
our $tests;

sub say($str) {
    pir::say($str);
}

sub diag($str) {
    say("# $str");
}

sub ok($val, $msg?) {
    $tests++;
    if $msg {
        say("{$val ?? "" !! "not "}ok $tests - $msg");
    }
    else {
        say("{$val ?? "" !! "not "}ok $tests");
    }
}

sub succeeds(&block, $msg?) {
    my $*paths := paths();
    if $*paths {
        &block();
        ok(1, $msg);
    }
    else {
        ok(0, $msg);
    }
}

sub fails(&block, $msg?) {
    my $*paths := paths();
    if $*paths {
        &block();
        ok(0, $msg);
    }
    else {
        ok(1, $msg);
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
    ok(1, "creating empty Variable");

    # Test backtracking.
    my $paths := paths();
    if $paths {
        # After initial call.
        ok(1, "creating paths");
        fail($paths);
    }
    else {
        # After call to fail().
        ok(1, "backtracking");
    }

    exhaustive_blob();
    cut_blob();

    # Test unification of terms.
    my $atom := Term.from_data("atom");
    ok(1, "creating atoms");
    unifies($atom, $atom, "unification of atom to itself");

    my $other_atom := Term.from_data("atom");
    unifies($atom, $other_atom, "unification of atom to identical atom");

    my $different := Term.from_data("different");
    not_unifies($atom, $different, "non-unification of unequal atoms");

    my $complex := Term.from_data("term", $atom);
    ok(1, "creating complex terms");
    unifies($complex, $complex, "unification of complex term to itself");

    my $other_complex := Term.from_data("term", $other_atom);
    unifies($complex, $other_complex, "unification of complex term to identical complex term");

    my $different_complex := Term.from_data("different", $atom);
    not_unifies($complex, $different_complex, "non-unification of different complex terms");

    # Test unification of variables.
    my $free := Variable.free;
    ok(1, "creating free variable");

    unifies($free, $atom, "unification of free variable to atom");
    ok($free.value.functor eq $atom.functor, "value after unification");
    unifies($free, $other_atom, "unification after binding");

    $paths := paths();
    if $paths {
        my $x := Variable.free;
        my $y := Variable.free;
        my $z := Variable.free;

        unify($paths, $x, $y);
        unify($paths, $y, $z);
        unify($paths, $z, $atom);
        # XXX: Doesn't work.
        #ok($x.value.functor eq $z.value.functor, "transitive unification");
    }
    else {
    }

    # TODO: Make sure failure undoes bindings.

    plan();
}

# Chocoblob example from Graham's book. Exhaustive version. (page 300)
sub exhaustive_blob() {
    my @results := ();
    my $paths := paths();

    if !$paths {
        # Done processing.
        ok(@results[0][0] eq "la" &&  @results[0][1] == 1 && @results[0][2] == 2, "exhaustive-blob(), @results[0]");
        ok(@results[1][0] eq "ny" &&  @results[1][1] == 1 && @results[1][2] == 1, "exhaustive-blob(), @results[1]");
        ok(@results[2][0] eq "bos" && @results[2][1] == 2 && @results[2][2] == 2, "exhaustive-blob(), @results[2]");

        return 1;
    }

    my $city := choose($paths, "la", "ny", "bos");
    my $store := choose($paths, 1, 2);
    my $box := choose($paths, 1, 2);

    if coin($city, $store, $box) {
        @results.push: [$city, $store, $box];
    }

    fail($paths);
}

# Chocoblob example from Graham's book. Pruned version (with cut). (page 301)
sub cut_blob() {
    my @results := ();
    my $paths := paths();

    if !$paths {
        # Done processing.
        ok(@results[0][0] eq "la" &&  @results[0][1] == 1 && @results[0][2] == 2, "cut-blob(), @results[0]");
        ok(@results[1][0] eq "ny" &&  @results[1][1] == 1 && @results[1][2] == 1, "cut-blob(), @results[1]");
        ok(@results[2][0] eq "bos" && @results[2][1] == 2 && @results[2][2] == 2, "cut-blob(), @results[2]");

        return 1;
    }

    my $city := choose($paths, "la", "ny", "bos");
    mark($paths);
    my $store := choose($paths, 1, 2);
    my $box := choose($paths, 1, 2);

    if coin($city, $store, $box) {
        @results.push: [$city, $store, $box];
        cut($paths);
    }

    fail($paths);
}

sub coin($city, $store, $box) {
    if ($city eq "la"  && $store == 1 && $box == 2)
    || ($city eq "ny"  && $store == 1 && $box == 1)
    || ($city eq "bos" && $store == 2 && $box == 2) {
        return 1;
    }
    else {
        return 0;
    }
}
