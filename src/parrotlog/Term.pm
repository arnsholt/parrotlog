# vim:syntax=perl6

=begin Term

Term represents a Prolog term; both atoms and complex terms. An atom will have
$arity 0 and an ampty args array, while complex terms will have $arity > 0 and
the corresponding number of elements in @args.

=end Term

class Term is PrologTerm;

our $origpaths;
our $origdecl;
our $paths;

INIT {
    $origpaths := PAST::Var.new(:name<origpaths>, :scope<lexical>);
    $origdecl := PAST::Var.new(:name<origpaths>, :scope<parameter>);
    $paths := PAST::Var.new(:name<paths>, :scope<lexical>);
}

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

method predicate_spec() {
    return "$!functor/$!arity";
}

method value() { return self; }

method variable_set() {
    if $!arity < 1 {
        # Atoms have an empty variable set.
        return Set.new;
    }
    else {
        my $set := Set.new;
        for @!args -> $term {
            $set.union: $term.variable_set;
        }

        return $set;
    }
}

method existential_vars() {
    if $!arity == 2 && $!functor eq '^' {
        my $set := Set.new;
        $set.union: $!args[0].variable_set;
        $set.union: $!args[1].existential_vars;
        return $set;
    }
    else {
        return Set.new;
    }
}

method free_vars($v) {
    # FV(T, V) = VS(T) - BV, BV = VS(V) u EV(T)
    my $set := Set.new;
    $set.union: self.variable_set;

    my $bv := Set.new;
    $bv.union: $v.variable_set;
    $bv.union: self.existential_vars;

    $set.diff: $bv;
    return $set;
}

# Pretty print.
method output() {
    my $output := "$!functor";

    # XXX: To be improved
    if $!arity > 0 {
        #$output := $output ~ "/$!arity";
        $output := $output ~ '(';
        $output := $output ~ @!args[0].output;
        my $i := 1;
        while $i < $!arity {
            $output := $output ~ ', ' ~ @!args[$i++].output;
        }
        $output := $output ~ ')';
    }

    return $output;
}

method past() {
    my $class := PAST::Op.new(
        :inline("    %r = get_root_global ['_parrotlog'], 'Term'"));
    my $call := PAST::Op.new(:name<from_data>, :pasttype<callmethod>, $class);
    $call.push: PAST::Val.new(:value($!functor));
    for @!args -> $arg {
        $call.push: $arg.past;
    }

    return $call;
}

# Section 7.6.2, converting a term to the body of a clause.
method as_query($in_block = 0) {
    my $functor := self.functor;
    my $arity := self.arity;

    if $in_block {
        my $block := PAST::Block.new(:blocktype<declaration>, :hll<parrotlog>);
        $block.push: PAST::Var.new(:name<origpaths>, :scope<parameter>);
        $block.push: PAST::Var.new(:name<paths>, :scope<lexical>, :isdecl,
            :viviself(PAST::Var.new(:name<origpaths>, :scope<lexical>)));
        $block.push: self.as_query;
        return $block;
    }

    # Table 7, Principal functors and control structures gives the terms
    # that get special handling.
    # Section 7.8.5, ','/2 - conjunction.
    if $arity == 2 && $functor eq ',' {
        return PAST::Stmts.new(
            self.args[0].as_query,
            self.args[1].as_query);
    }
    # Section 7.8.6, ';' - disjunction.
    # Section 7.8.8, ';'/2 - if-then-else.
    elsif $arity == 2 && $functor eq ';' {
        my $arg0 := self.args[0];
        if $arg0 ~~ Term && $arg0.arity == 2 && $arg0.functor eq '->' {
            my $past := PAST::Block.new(:blocktype<declaration>,
                PAST::Var.new(:name<curpaths>, :scope<parameter>));

            my $if := PAST::Block.new(:blocktype<declaration>,
                $origdecl,
                PAST::Var.new(:name<paths>, :scope<lexical>, :isdecl,
                    :viviself($origpaths)),
                $arg0.args[0].as_query);
            $if := PAST::Op.new(:pasttype<call>, $if, $paths);

            $if := PAST::Stmts.new(
                $if,
                PAST::Op.new(:pasttype<bind>,
                    $paths,
                    PAST::Var.new(:name<curpaths>, :scope<lexical>)),
                $arg0.args[1].as_query);

            my $else := PAST::Stmts.new(
                PAST::Op.new(:pasttype<bind>,
                    $paths,
                    PAST::Var.new(:name<curpaths>, :scope<lexical>)),
                self.args[1].as_query);

            $past.push: Parrotlog::Compiler::choicepoint(
                $if,
                $else);

            return PAST::Op.new(:pasttype<call>, $past, $paths);
        }
        else {
            # We wrap disjunctions in their own Block with its own
            # origpaths parameter so that we can reset paths to the
            # correct value when backtracking. We do not declare a new
            # paths lexical, however, since we want cuts to affect the
            # whole predicate, not just the disjunction. This is also why
            # disjunction blocks don't have to return a paths value to the
            # outer block.
            my $block := PAST::Block.new(:blocktype<declaration>);
            $block.push: PAST::Var.new(:name<curpaths>, :scope<parameter>);

            $block.push: Parrotlog::Compiler::choicepoint(
                self.args[0].as_query,
                PAST::Stmts.new(
                    PAST::Op.new(:pasttype<bind>,
                        $paths,
                        PAST::Var.new(:name<curpaths>, :scope<lexical>)),
                    self.args[1].as_query));

            return PAST::Op.new(:pasttype<call>, $block, $paths);
        }
    }
    # Section 7.8.7, '->'/2 - if-then.
    elsif $arity == 2 && $functor eq '->' {
        # We wrap the antecedent of the implication in a Block with a new
        # paths lexical so that cuts don't affect the rest of the
        # predicate. Also, we discard choicepoints from inside the
        # antecedent by not returning the paths value at the end.
        my $block := PAST::Block.new(:blocktype<declaration>);
        $block.push: $origdecl;
        $block.push: PAST::Var.new(:name<paths>, :scope<lexical>, :isdecl,
            :viviself($origpaths));
        $block.push: self.args[0].as_query;

        return PAST::Stmts.new(
            PAST::Op.new(:pasttype<call>, $block, $paths),
            self.args[1].as_query);
    }
    # Section 7.8.4, !/0 - cut.
    elsif $arity == 0 && $functor eq '!' {
        return PAST::Op.new(:pasttype<bind>,
            $paths,
            $origpaths);
    }
    # Section 7.8.1, true/0.
    elsif $arity == 0 && $functor eq 'true' {
        return $paths;
    }
    # Section 7.8.2, fail/0.
    elsif $arity == 0 && $functor eq 'fail' {
        return Parrotlog::Compiler::call_internal('fail', $paths);
    }
    # Section 7.8.9 - catch/3.
    elsif $arity == 3 && $functor eq 'catch' {
        my $parrotex := PAST::Var.new(:name<parrotex>, :scope<register>);
        my $prologex := PAST::Var.new(:name<prologex>, :scope<register>);
        my $rethrow := PAST::Op.new(:pirop<rethrow__vP>, $parrotex);
        my $popeh := PAST::Op.new(:pirop<pop_eh>);
        my $haspopped := PAST::Var.new(:name<haspopped>, :scope<register>);

        my $goal := PAST::Stmts.new(
            PAST::Var.new(:name<haspopped>, :scope<register>, :isdecl,
                :viviself(PAST::Val.new(:value(0)))),
            Parrotlog::Compiler::procedure_call('call/1',
                $paths,
                self.args[0].past),
            PAST::Op.new(:pasttype<unless>,
                $haspopped,
                PAST::Stmts.new(
                    $popeh,
                    PAST::Op.new(:pasttype<bind>,
                        $haspopped,
                        PAST::Val.new(:value(1))))),
        );

        my $recovery := PAST::Stmts.new(
            PAST::Var.new(:name<parrotex>, :scope<register>, :isdecl,
                :viviself(PAST::Op.new(:inline('    .get_results(%r)')))),
            PAST::Var.new(:name<prologex>, :scope<register>, :isdecl,
                :viviself(PAST::Var.new(:scope<keyed>,
                    $parrotex,
                    PAST::Val.new(:value('payload'))))),

            # If the payload is NULL, it's not a Prolog exception, so rethrow.
            PAST::Op.new(:pasttype<if>,
                PAST::Op.new(:pirop<isnull>, $prologex),
                $rethrow),

            # If the payload isn't a PrologTerm, it's not a Prolog exception
            # either, so rethrow.
            PAST::Op.new(:pasttype<unless>,
                PAST::Op.new(:pasttype<callmethod>, :name<ACCEPTS>,
                    PAST::Op.new(:inline("    %r = get_root_global ['_parrotlog'], 'PrologTerm'")),
                    $prologex),
                $rethrow),

            # Set up a choicepoint, and unify Catcher and the thrown Ball.
            PAST::Var.new(:name<tmppaths>, :scope<register>, :isdecl,
                :viviself(Parrotlog::Compiler::call_internal('choicepoint', $paths))),
            PAST::Op.new(:pasttype<if>,
                PAST::Op.new(:pirop<isnull>,
                    PAST::Var.new(:name<tmppaths>, :scope<register>)),
                $rethrow),
            Parrotlog::Compiler::procedure_call('=/2',
                PAST::Var.new(:name<tmppaths>, :scope<register>),
                $prologex,
                self.args[1].past),
            # Can't tailcall here, because that messes with which lexical
            # scope is selected in call/1.
            Parrotlog::Compiler::procedure_call('call/1',
                $paths,
                self.args[2].past));

            return PAST::Block.new(:blocktype<immediate>,
                PAST::Op.new(:inline('    push_eh recovery')),
                $goal,
                PAST::Op.new(:inline('    goto done')),
                PAST::Op.new(:inline('  recovery:')),
                $recovery,
                PAST::Op.new(:inline('  done:')));
    }
    # Section 7.8.10 - throw/1.
    elsif $arity == 1 && $functor eq 'throw' {
        return PAST::Op.new(:inline('    throw %0'),
            PAST::Op.new(:inline("    %r = new 'Exception'\n    %r['payload'] = %0"),
                self.args[0].past));
    }
    else {
        my $name := self.functor ~ '/' ~ self.arity;
        my @args;
        @args.push: $paths;
        for self.args -> $arg { @args.push: $arg.past; }
        return Parrotlog::Compiler::procedure_call($name, |@args);
    }
}
