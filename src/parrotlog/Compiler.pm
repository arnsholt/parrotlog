class Parrotlog::Compiler is HLL::Compiler;

our $origpaths;
our $paths;

INIT {
    Parrotlog::Compiler.language('Parrotlog');
    Parrotlog::Compiler.parsegrammar(Parrotlog::Grammar);
    Parrotlog::Compiler.parseactions(Parrotlog::Actions);

    $origpaths := PAST::Var.new(:name<origpaths>, :scope<lexical>);
    $paths := PAST::Var.new(:name<paths>, :scope<lexical>);
}

method past($source, *%adverbs) {
    my $ast := $source.ast;
    # Main driver code. On program start, set up backtracking stack and call
    # main/0.
    my $past := PAST::Block.new(:hll<parrotlog>, :blocktype<immediate>);

    $past.push: PAST::Var.new(:name<termclass>, :scope<lexical>, :isdecl,
        :viviself(PAST::Op.new(:inline("    %r = get_root_global ['_parrotlog'], 'Term'"))));
    our $termclass := PAST::Var.new(:name<termclass>, :scope<lexical>);

    $past.push: PAST::Var.new(:scope<lexical>, :name<paths>, :isdecl,
        :viviself(call_internal('paths')));

    # Call main/0 on the initial pass, jump to error condition on backtrack.
    $past.push: PAST::Op.new(:pasttype<unless>,
        PAST::Op.new(:pirop<isnull>, $paths),
        PAST::Op.new(:name<main/0>, :pasttype<call>, $paths),
        PAST::Op.new(:inline("    say '# OHNOES TEH MANATEE'"))); # XXX: Final failure code goes here.

    # Compile all the clauses.
    for $ast -> $predicate {
        $past.push: compile_predicate($predicate, $ast{$predicate});
    }

    return $past;
}

sub compile_predicate($predicate, $clauses) {
    my $block := PAST::Block.new(:name($predicate), :blocktype<declaration>);

    # Find the arity of the predicate.
    my $a_clause := $clauses[0];
    $a_clause := $a_clause.args[0]
        if $a_clause.arity == 2 && $a_clause.functor eq ':-';
    my $arity := $a_clause.arity;

    my @args;
    $block.push: PAST::Var.new(:name<origpaths>, :scope<parameter>);
    @args.push: PAST::Var.new(:name<origpaths>, :scope<lexical>);
    my $i := 0;
    while $i < $arity {
        $i++;
        my $name := "arg" ~ $i;
        $block.push: PAST::Var.new(:name($name), :scope<parameter>);
        @args.push: PAST::Var.new(:name($name), :scope<lexical>);
    }

    $block.push: PAST::Var.new(:name<paths>, :scope<lexical>, :isdecl,
        :viviself(@args[0]));

    $block.push: compile_clauses($clauses, @args);

    return $block;
}

sub compile_clauses(@clauses, @args) {
    if @clauses {
        my $clause := @clauses.shift;
        return choicepoint(
            compile_clause($clause, @args),
            compile_clauses(@clauses, @args));
    }
    else {
        return call_internal('fail', @args[0]);
    }
}

sub compile_clause($clause, @args) {
    my $head;
    my $body;
    if $clause.arity == 2 && $clause.functor eq ':-' {
        $head := $clause.args[0];
        $body := $clause.args[1];
    }
    else {
        $head := $clause;
    }

    my $past := PAST::Block.new(:blocktype<immediate>);

    my %vars;
    for $clause.variable_set.contents -> $var {
        $past.push: PAST::Var.new(:name($var), :isdecl, :scope<lexical>,
            :viviself(variable($var)));
        %vars{$var} := PAST::Var.new(:name($var), :scope<lexical>);
    }

    # Section 7.6.1, converting a term to the head of a clause.
    my $i := 0;
    for $head.args -> $arg {
        $past.push: procedure_call(
            '=/2',
            $paths,
            @args[$i+1],
            $head.args[$i].past);
        $i++;
    }

    $past.push: compile_body($body)
        if pir::defined($body);

    return $past;
}

# Section 7.6.2, converting a term to the body of a clause.
sub compile_body($ast) {
    my $class := pir::class__PP($ast).name;

    if $class eq 'Variable' {
        # A goal X is equivalent to call(X).
        return compile_body(Term.from_data('call', $ast));
    }
    elsif $class eq 'Term' {
        my $functor := $ast.functor;
        my $arity := $ast.arity;

        # Table 7, Principal functors and control structures gives the terms
        # that get special handling.
        # Section 7.8.5, ','/2 - conjunction.
        if $arity == 2 && $functor eq ',' {
           return PAST::Stmts.new(
                compile_body($ast.args[0]),
                compile_body($ast.args[1]));
        }
        # Section 7.8.6, ';' - disjunction.
        # Section 7.8.8, ';'/2 - if-then-else.
        elsif $arity == 2 && $functor eq ';' {
            # TODO: ;/2 with ->/2 as first argument (7.8.8).
            my $arg0 := $ast.args[0];
            if $arg0 ~~ Term && $arg0.arity == 2 && $arg0.functor eq '->' {
                pir::die("If-then-else not implemented yet");
            }
            else {
                # We wrap disjunctions in their own Block with its own
                # origpaths parameter so that we can reset paths to the
                # correct value when backtracking. We do not declare a new
                # paths lexical, however, since we want cuts to affect the
                # whole predicate, not just the disjunction.
                my $block := PAST::Block.new(:blocktype<declaration>);
                $block.push: PAST::Var.new(:name<origpaths>, :scope<parameter>);

                $block.push: choicepoint(
                    compile_body($ast.args[0]),
                    PAST::Stmts.new(
                        PAST::Op.new(:pasttype<bind>,
                            $paths, $origpaths),
                        compile_body($ast.args[1])));

                return PAST::Op.new(:pasttype<call>, $block, $paths);
            }
        }
        # Section 7.8.7, '->'/2 - if-then.
        elsif $arity == 2 && $functor eq '->' {
            # We wrap the antecedent of the implication in a Block with a new
            # paths lexical so that cuts don't affect the rest of the
            # predicate.
            my $block := PAST::Block.new(:blocktype<declaration>);
            $block.push: PAST::Var.new(:name<origpaths>, :scope<parameter>);
            $block.push: PAST::Var.new(:name<paths>, :scope<lexical>, :isdecl,
                :viviself($origpaths));
            $block.push: compile_body($ast.args[0]);

            return PAST::Stmts.new(
                PAST::Op.new(:pasttype<call>, $block, $paths),
                compile_body($ast.args[1]));
        }
        # Section 7.8.4, !/0 - cut.
        elsif $arity == 0 && $functor eq '!' {
            return PAST::Op.new(:pasttype<bind>,
                $paths,
                $origpaths);
        }
        # Section 7.8.3, call/1.
        elsif $arity == 1 && $functor eq 'call' {
            if $ast.args[0] ~~ Term {
                return PAST::Op.new(:pasttype<call>,
                    PAST::Block.new(:blocktype<declaration>,
                        PAST::Var.new(:name<origpaths>, :scope<parameter>),
                        PAST::Var.new(:name<paths>, :scope<lexical>, :isdecl,
                            :viviself($origpaths)),
                        compile_body($ast.args[0])),
                    $paths);
            }
            else {
                return call_internal('call', $origpaths, $ast.args[0].past);
            }
        }
        # Section 7.8.1, true/0.
        elsif $arity == 0 && $functor eq 'true' {
            return PAST::Stmts.new();
        }
        # Section 7.8.2, fail/0.
        elsif $arity == 0 && $functor eq 'fail' {
            return call_internal('fail', $paths);
        }
        # Section 7.8.9 - catch/3.
        elsif $arity == 3 && $functor eq 'catch' {
            # XXX: The Goal and Recovery might constitute their own cut
            # domains. If that's so, the Stmts nodes have to be changed to
            # Blocks with their own paths lexicals.
            # First, compile the arguments to catch/3 into the correct forms.
            my $goal := compile_body(
                Term.from_data('call', $ast.args[0]));
            my $catcher := $ast.args[1].past;
            my $recovery := compile_body(
                Term.from_data('call', $ast.args[2]));

            # Some bookkeeping variables we'll be needing.
            my $ex := PAST::Var.new(:name<ex>, :scope<lexical>);
            my $ex_obj := PAST::Var.new(:name<ex_obj>, :scope<lexical>);
            my $unified := PAST::Var.new(:name<unified>, :scope<register>);
            my $popeh := PAST::Var.new(:name<popeh>, :scope<register>);

            # If the payload of the Exception is a Prolog term, we do this:
            my $is_term := choicepoint(
                PAST::Stmts.new(
                    # Try to unify the Ball thrown with the Catcher...
                    procedure_call('=/2',
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
                        call_internal('fail', $origpaths),
                        # Unification failed: rethrow exception
                        PAST::Op.new(:pirop<rethrow__vP>,
                            $ex_obj))));

            # If the payload isn't a term, we just pop the exception handler
            # and rethrow.
            my $not_term := PAST::Stmts.new(
                PAST::Op.new(:pirop<pop_eh>),
                PAST::Op.new(:pirop<rethrow__vP>,
                    $ex_obj));

            our $termclass;
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
                PAST::Op.new(:pasttype<if>,
                    PAST::Op.new(:pasttype<callmethod>, :name<ACCEPTS>,
                        $termclass,
                        $ex),
                    $is_term,
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
                    $ast.args[0].past));
        }
        else {
            my $name := $ast.functor ~ '/' ~ $ast.arity;
            my @args;
            @args.push: $paths;
            for $ast.args -> $arg { @args.push: $arg.past; }
            return procedure_call($name, |@args);
        }
    }
    else {
        pir::die("Can't handle $class goals.");
    }
}

sub choicepoint($first, $second) {
    return PAST::Stmts.new(
        PAST::Op.new(:pasttype<bind>,
            $paths,
            call_internal('choicepoint',
                $paths)),
        PAST::Op.new(:pasttype<unless>,
            PAST::Op.new(:pirop<isnull>,
                $paths),
                $first,
                $second)
    );
}

sub call_internal($function, *@args) {
    return PAST::Op.new(:pasttype<call>,
        # XXX: This has the potential for breakage if weird names are passed in.
        PAST::Op.new(:inline("    %r = get_root_global ['_parrotlog'], '$function'")),
        |@args);
}

sub variable($name?) {
    my $obj :=  PAST::Op.new(
        :inline("    %r = root_new ['_parrotlog'; 'Variable']"));
    if pir::defined($name) {
        return PAST::Stmts.new(
            PAST::Op.new(:pasttype<callmethod>, :name<name>,
                $obj,
                PAST::Val.new(:value($name))),
            $obj);
    }
    else {
        return $obj;
    }
}

sub procedure_call($name, *@args) {
    return PAST::Op.new(:pasttype<call>, :name($name), |@args);
}
