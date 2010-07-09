=begin description

Code for testing the correct workings of Parrolog's internals.

=end description
module Coretest;

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

sub coretest() {
    unification();
    runtime_classes();

    plan();
}

sub unification() {
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
    my $other_atom := Term.from_data("atom");
    my $different := Term.from_data("different");
    my $complex := Term.from_data("term", $atom);
    ok(1, "creating complex terms");
    my $other_complex := Term.from_data("term", $other_atom);
    my $different_complex := Term.from_data("different", $atom);

    unifies($atom, $atom, "unification of atom to itself");
    unifies($atom, $other_atom, "unification of atom to identical atom");
    not_unifies($atom, $different, "non-unification of unequal atoms");
    unifies($complex, $complex, "unification of complex term to itself");
    unifies($complex, $other_complex, "unification of complex term to identical complex term");
    not_unifies($complex, $different_complex, "non-unification of different complex terms");

    # Test unification of variables.
    my $free := Variable.new;
    ok(1, "creating free variable");
    ok(!$free.value, "value of free variable");
    ok(!$free.bound, "bound state of free variable");

    unifies($free, $atom, "unification of free variable to atom");
    ok($free.bound, "bound state of unified variable");
    ok($free.value.functor eq $atom.functor, "value after unification");
    unifies($free, $other_atom, "unification after binding");

    $paths := paths();
    if $paths {
        my $x := Variable.new;
        my $y := Variable.new;
        my $z := Variable.new;

        unify($paths, $x, $y);
        unify($paths, $y, $z);
        unify($paths, $z, $atom);

        ok($x.value.functor eq $y.value.functor, "transitive unification (1) - X equals Y");
        ok($y.value.functor eq $z.value.functor, "transitive unification (1) - Y equals Z");
        ok($x.value.functor eq $z.value.functor, "transitive unification (1) - X equals Z");
    }
    else {
        ok(0, "transitive unification (1) - backtracked too far");
    }

    $paths := paths();
    if $paths {
        my $x := Variable.new;
        my $y := Variable.new;
        my $z := Variable.new;

        unify($paths, $x, $y);
        unify($paths, $y, $z);
        unify($paths, $y, $atom);

        ok($x.value.functor eq $y.value.functor, "transitive unification (2) - X equals Y");
        ok($y.value.functor eq $z.value.functor, "transitive unification (2) - Y equals Z");
        ok($x.value.functor eq $z.value.functor, "transitive unification (2) - X equals Z");
    }
    else {
        ok(0, "transitive unification (2) - backtracked too far");
    }

    $paths := paths();
    if $paths {
        my $x := Variable.new;
        my $y := Variable.new;
        my $z := Variable.new;

        unify($paths, $x, $y);
        unify($paths, $y, $z);
        unify($paths, $x, $atom);

        ok($x.value.functor eq $y.value.functor, "transitive unification (3) - X equals Y");
        ok($y.value.functor eq $z.value.functor, "transitive unification (3) - Y equals Z");
        ok($x.value.functor eq $z.value.functor, "transitive unification (3) - X equals Z");
    }
    else {
        ok(0, "transitive unification (3) - backtracked too far");
    }

    $paths := paths();
    if $paths {
        my $x := Variable.new;
        my $y := choose($paths, $atom, $different);
        unify($paths, $x, $y);
        fail($paths) if $x.value.functor eq "atom";

        ok($x.value.functor eq "different", "backtracking over unification");
    }
    else {
        ok(0, "backtracking over unification - backtracked too far");
    }

    $paths := paths();
    if $paths {
        my $x := Variable.new;
        my $y := Variable.new;
        my $z := Variable.new;

        unify($paths, $x, $y);
        unify($paths, $y, $z);
        unify($paths, $z, $x);
        unify($paths, $z, $atom);

        ok($x.value.functor eq $y.value.functor, "circular unification (1) - X equals Y");
        ok($y.value.functor eq $z.value.functor, "circular unification (1) - Y equals Z");
        ok($x.value.functor eq $z.value.functor, "circular unification (1) - X equals Z");
    }
    else {
        ok(0, "circular unification - backtracked too far");
    }

    # Check for regression. Backtracking over the mark should live.
    $paths := paths();
    if $paths {
        mark($paths);
        fail($paths);
    }
    else {
        ok(1, "Survived backtracking over mark.");
    }
}

# Chocoblob example from Graham's book. Exhaustive version. (page 300)
sub exhaustive_blob() {
    my @results := ();
    my $pings := 0;
    my $paths := paths();

    if !$paths {
        # Done processing.
        ok(@results[0][0] eq "la" &&  @results[0][1] == 1 && @results[0][2] == 2, "exhaustive-blob(), @results[0]");
        ok(@results[1][0] eq "ny" &&  @results[1][1] == 1 && @results[1][2] == 1, "exhaustive-blob(), @results[1]");
        ok(@results[2][0] eq "bos" && @results[2][1] == 2 && @results[2][2] == 2, "exhaustive-blob(), @results[2]");
        ok($pings == 12, "exhaustive-blob(), number of values checked");

        return 1;
    }

    my $city := choose($paths, "la", "ny", "bos");
    my $store := choose($paths, 1, 2);
    my $box := choose($paths, 1, 2);

    $pings++;

    if coin($city, $store, $box) {
        @results.push: [$city, $store, $box];
    }

    fail($paths);
}

# Chocoblob example from Graham's book. Pruned version (with cut). (page 301)
sub cut_blob() {
    my @results := ();
    my $pings := 0;
    my $paths := paths();

    if !$paths {
        # Done processing.
        ok(@results[0][0] eq "la" &&  @results[0][1] == 1 && @results[0][2] == 2, "cut-blob(), @results[0]");
        ok(@results[1][0] eq "ny" &&  @results[1][1] == 1 && @results[1][2] == 1, "cut-blob(), @results[1]");
        ok(@results[2][0] eq "bos" && @results[2][1] == 2 && @results[2][2] == 2, "cut-blob(), @results[2]");
        ok($pings == 7, "cut-blob(), number of values checked");

        return 1;
    }

    my $city := choose($paths, "la", "ny", "bos");
    mark($paths);
    my $store := choose($paths, 1, 2);
    my $box := choose($paths, 1, 2);

    $pings++;

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

sub runtime_classes() {
    my $set := Set.new;
    ok(1, "creating new Set");

    $set.add: 'a', 'b', 'c';
    ok(+$set.contents == 3, 'set has 3 elements after adding <a b c>');
    ok($set.contains('a'), 'contains a');
    ok($set.contains('b'), 'contains b');
    ok($set.contains('c'), 'contains c');

    my $other := Set.new;
    $other.add: 'b', 'c', 'd';

    $set.union: $other;
    ok(+$set.contents == 4, '<a b c> U <b c d> has length 4');
    ok($set.contains('a'), 'contains a');
    ok($set.contains('b'), 'contains b');
    ok($set.contains('c'), 'contains c');
    ok($set.contains('d'), 'contains d');

    $set.diff: $other;
    ok(+$set.contents == 1, '<a b c d> - <b c d> has length 1');
    ok($set.contains('a'), 'contains a');

    $set := Set.new;
    $set.add: 'a', 'b', 'c';
    $set.diff: $other;
    ok(+$set.contents == 1, '<a b c> - <b c d> has length 1');
    ok($set.contains('a'), 'contains a');
}
