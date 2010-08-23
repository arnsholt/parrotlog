class Parrotlog::Compiler is HLL::Compiler;

INIT {
    Parrotlog::Compiler.language('Parrotlog');
    Parrotlog::Compiler.parsegrammar(Parrotlog::Grammar);
    Parrotlog::Compiler.parseactions(Parrotlog::Actions);
}

method past($source, *%adverbs) {
    my $ast := $source.ast;
    # Main driver code. On program start, set up backtracking stack and call
    # main/0.
    my $past := PAST::Block.new(:hll<parrotlog>, :blocktype<immediate>);
    $past.push: PAST::Var.new(:scope<register>, :name<paths>, :isdecl,
        :viviself(call_internal('paths')));
    my $paths := PAST::Var.new(:scope<register>, :name<paths>);

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

    $block.push: PAST::Var.new(:name<paths>, :scope<lexical>, :isdecl);
    my $paths := PAST::Var.new(:name<paths>, :scope<lexical>);
    $block.push: PAST::Op.new(:pasttype<bind>, $paths, @args[0]);

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

    my $past := PAST::Stmts.new;

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
            PAST::Var.new(:name<paths>, :scope<lexical>),
            @args[$i+1],
            $head.args[$i].past);
        $i++;
    }

    $past.push: compile_body($body, @args[0], %vars)
        if pir::defined($body);

    return $past;
}

# Section 7.6.2, converting a term to the body of a clause.
sub compile_body($ast, $origpaths, %vars) {
    my $class := pir::class__PP($ast).name;
    my $paths := PAST::Var.new(:name<paths>, :scope<lexical>);

    if $class eq 'Variable' {
        # A goal X is equivalent to call(X).
        return compile_body(Term.from_data('call', $ast), $origpaths, %vars);
    }
    elsif $class eq 'Term' {
        my $functor := $ast.functor;
        my $arity := $ast.arity;

        # Table 7, Principal functors and control structures gives the terms
        # that get special handling.
        # Section 7.8.5, ','/2 - conjunction.
        if $arity == 2 && $functor eq ',' {
           return PAST::Stmts.new(
                compile_body($ast.args[0], $origpaths, %vars),
                compile_body($ast.args[1], $origpaths, %vars));
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
                my $block := PAST::Block.new(:blocktype<declaration>);
                $block.push: PAST::Var.new(:name<origpaths>, :scope<parameter>);

                $block.push: choicepoint(
                    compile_body($ast.args[0], $origpaths, %vars),
                    PAST::Stmts.new(
                        PAST::Op.new(:pasttype<bind>,
                            $paths, $origpaths),
                        compile_body($ast.args[1], $origpaths, %vars)));

                return PAST::Op.new(:pasttype<call>, $block, $paths);
            }
        }
        # Section 7.8.7, '->'/2 - if-then.
        elsif $arity == 2 && $functor eq '->' {
            my $block := PAST::Block.new(:blocktype<declaration>);
            $block.push: PAST::Var.new(:name<origpaths>, :scope<parameter>);
            $block.push: PAST::Var.new(:name<paths>, :scope<lexical>, :isdecl,
                :viviself($origpaths));
            $block.push: compile_body($ast.args[0], $origpaths, %vars);

            return PAST::Stmts.new(
                PAST::Op.new(:pasttype<call>, $block, $origpaths),
                compile_body($ast.args[1], $origpaths, %vars));
        }
        # Section 7.8.4, !/0 - cut.
        elsif $arity == 0 && $functor eq '!' {
            return PAST::Op.new(:pasttype<bind>,
                $paths,
                $origpaths);
        }
        # Section 7.8.3, call/1.
        elsif $arity == 1 && $functor eq 'call' {
            pir::die('call/1 not implemented yet');
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
            pir::die('catch/3 not implemented yet');
            # Given catch(Goal, Catcher, Recovery):
            # 1) push_eh
            # 2) call(Goal)
            # 3a) If the call is successful, true
            # 3b) If an error is thrown unify payload of exception with
            # Catcher then execute Recovery.
        }
        # Section 7.8.10 - throw/1.
        elsif $arity == 1 && $functor eq 'throw' {
            pir::die('throw/1 not implemented yet');
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
            PAST::Var.new(:name<paths>, :scope<lexical>),
            call_internal('choicepoint',
                PAST::Var.new(:name<paths>, :scope<lexical>))),
        PAST::Op.new(:pasttype<unless>,
            PAST::Op.new(:pirop<isnull>,
                PAST::Var.new(:name<paths>, :scope<lexical>)),
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
