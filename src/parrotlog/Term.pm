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
method as_query() {
    my $functor := self.functor;
    my $arity := self.arity;

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
    # Section 7.8.3, call/1.
    elsif $arity == 1 && $functor eq 'call' {
        if self.args[0] ~~ Term {
            return PAST::Op.new(:pasttype<call>,
                PAST::Block.new(:blocktype<declaration>,
                    $origdecl,
                    PAST::Var.new(:name<paths>, :scope<lexical>, :isdecl,
                        :viviself($origpaths)),
                    self.args[0].as_query,
                    $paths),
                $paths);
        }
        else {
            return Parrotlog::Compiler::call_internal('call', $origpaths, self.args[0].past);
        }
    }
    # Section 7.8.1, true/0.
    elsif $arity == 0 && $functor eq 'true' {
        return PAST::Stmts.new();
    }
    # Section 7.8.2, fail/0.
    elsif $arity == 0 && $functor eq 'fail' {
        return Parrotlog::Compiler::call_internal('fail', $paths);
    }
    # Section 7.8.9 - catch/3.
    elsif $arity == 3 && $functor eq 'catch' {
        # XXX: The Goal and Recovery might constitute their own cut
        # domains. If that's so, the Stmts nodes have to be changed to
        # Blocks with their own paths lexicals.
        # First, compile the arguments to catch/3 into the correct forms.
        my $goal :=  Term.from_data('call', self.args[0]).as_query;
        my $catcher := self.args[1].past;
        my $recovery := Term.from_data('call', self.args[2]).as_query;

        # Some bookkeeping variables we'll be needing.
        my $ex := PAST::Var.new(:name<ex>, :scope<lexical>);
        my $ex_obj := PAST::Var.new(:name<ex_obj>, :scope<lexical>);
        my $unified := PAST::Var.new(:name<unified>, :scope<register>);
        my $popeh := PAST::Var.new(:name<popeh>, :scope<register>);

        # If the payload of the Exception is a Prolog term, we do this:
        my $is_term := Parrotlog::Compiler::choicepoint(
            PAST::Stmts.new(
                # Try to unify the Ball thrown with the Catcher...
                Parrotlog::Compiler::procedure_call('=/2',
                    $paths,
                    $catcher,
                    $ex),
                # If we come this far, the Ball is subsumed by Catcher,
                # and we want to fail/0 on backtracking, instead of
                # rethrowing the exception. Make sure we remember that.
                PAST::Op.new(:pasttype<bind>,
                    $unified,
                    PAST::Val.new(:value(1))),
                # Do the exception handling.
                $recovery,
                # If we come this far, we don't have to pop the exception
                # handler on backtracking, since that's the next thing
                # done. Make sure we remember that.
                PAST::Op.new(:pasttype<bind>,
                    $popeh,
                    PAST::Val.new(:value(1)))),
            PAST::Stmts.new(
                # Pop the exception handler, if needed.
                PAST::Op.new(:pasttype<if>,
                    PAST::Op.new(:pirop<isnull>,
                        $popeh),
                    PAST::Op.new(:pirop<pop_eh>)),
                PAST::Op.new(:pasttype<unless>,
                    PAST::Op.new(:pirop<isnull>,
                        $unified),
                    # Unification succeeded: backtrack
                    Parrotlog::Compiler::call_internal('fail', $origpaths),
                    # Unification failed: rethrow exception
                    PAST::Op.new(:pirop<rethrow__vP>,
                        $ex_obj))));

        # If the payload isn't a term, we just pop the exception handler
        # and rethrow.
        my $not_term := PAST::Stmts.new(
            PAST::Op.new(:pirop<pop_eh>),
            PAST::Op.new(:pirop<rethrow__vP>,
                $ex_obj));

        my $handler := PAST::Stmts.new(
            # Stuff the exception object and payload into the right
            # variables.
            PAST::Var.new(:name<ex_obj>, :scope<lexical>, :isdecl, :viviself(
                PAST::Op.new(:inline('    .get_results(%r)')))),
            PAST::Var.new(:name<ex>, :scope<lexical>, :isdecl, :viviself(
                PAST::Var.new(:scope<keyed>,
                    $ex_obj,
                    PAST::Val.new(:value<payload>)))),
            # Declare our bookkeeping variables.
            PAST::Var.new(:name<unified>, :scope<register>, :isdecl),
            PAST::Var.new(:name<popeh>, :scope<register>, :isdecl),
            # Do the right thing depending on the type of the payload.
            PAST::Op.new(:pasttype<unless>,
                PAST::Op.new(:pirop<isnull>, $ex),
                PAST::Op.new(:pasttype<if>,
                    PAST::Op.new(:pasttype<callmethod>, :name<ACCEPTS>,
                        PAST::Op.new(:inline("    %r = get_root_global ['_parrotlog'], 'Term'")),
                        $ex),
                    $is_term),
                $not_term));

        # Return the whole shebang wrapped in an exception handler.
        return PAST::Op.new(:pasttype<try>,
            $goal,
            $handler);
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
