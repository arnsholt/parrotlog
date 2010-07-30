class Parrotlog::Compiler is HLL::Compiler;

INIT {
    Parrotlog::Compiler.language('Parrotlog');
    Parrotlog::Compiler.parsegrammar(Parrotlog::Grammar);
    Parrotlog::Compiler.parseactions(Parrotlog::Actions);
}

# TODO: Set an adverb somewhere, indicating whether we are compiling a query
# from the REPL, or a program text.
method past($source, *%adverbs) {
    my $ast := $source.ast;
    # The top-level driver.
    my $past := PAST::Block.new(:hll<parrotlog>, :blocktype<immediate>);

    # Set up the backtracking stack.
    $past.push: PAST::Var.new(:scope<register>, :name<paths>, :isdecl,
        :viviself(self.call_internal: 'paths'));
    my $paths := PAST::Var.new(:scope<register>, :name<paths>);

    # Call main/0 on the initial pass, jump to error condition on backtrack.
    # TODO: The error message could use some love. =)
    $past.push: PAST::Op.new(:pasttype<unless>,
        $paths,
        PAST::Op.new(:inline('    say "# OHNOES TEH MANATEE"')), # XXX: Final failure code goes here.
        PAST::Op.new(:name<main/0>, :pasttype<call>, $paths));

    # Compile all the clauses.
    for $ast -> $predicate {
        my $clauses := $ast{$predicate};
        my $block := PAST::Block.new(:name($predicate), :blocktype<declaration>);
        my @args;

        # Do some digging around to find out which predicate we're defining.
        my $a_clause := $clauses[0];
        $a_clause := $a_clause.args[0]
            if $a_clause.arity == 2 && $a_clause.functor eq ':-';
        my $functor := $a_clause.functor;
        my $arity   := $a_clause.arity;

        # Arguments can be named simply arg1..argn, because Prolog variables
        # can't start with a lowercase letter so all those names are free for
        # us to use internally.
        my $i := 0;
        $block.push: PAST::Var.new(:name<paths>, :scope<parameter>);
        @args.push: PAST::Var.new(:name<paths>, :scope<lexical>);
        while $i < $arity {
            $i++;
            my $name := "arg" ~ $i;
            $block.push: PAST::Var.new(:name($name), :scope<parameter>);
            @args.push: PAST::Var.new(:name($name), :scope<lexical>);
        }

        $past.push: $block;

        # Stitch together the different branches of the directive.
        my $target := $block;
        for $clauses {
            my $if := PAST::Op.new(:pasttype<unless>,
                self.call_internal('choicepoint', @args[0]));
            $if.push: self.compile_clause($_, @args);
            $target.push: $if;
            $target := $if;
        }
        # As the final option when backtracking, fail.
        $target.push: self.call_internal('fail', @args[0]);
    }

    return $past;
}

method compile_clause($clause, @args) {
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
    $past.push: self.call_internal('mark', @args[0]);

    my %vars;
    for $clause.variable_set.contents -> $var {
        $past.push: PAST::Var.new(:name($var), :isdecl, :scope<lexical>,
            :viviself(self.variable($var)));
        %vars{$var} := PAST::Var.new(:name($var), :scope<lexical>);
    }

    # Section 7.6.1, converting a term to the head of a clause.
    my $i := 0;
    for $head.args -> $arg {
        $past.push: self.procedure_call(
            '=/2',
            @args[0],
            @args[$i+1],
            $head.args[$i].past);
        $i++;
    }

    $past.push: self.compile_body($body, @args[0], %vars)
        if pir::defined($body);

    return $past;
}

# Section 7.6.2, converting a term to the body of a clause.
method compile_body($ast, $paths, %vars) {
    my $class := pir::class__PP($ast).name;

    if $class eq 'Variable' {
        pir::die("Can't handle variable goals yet.");
    }
    elsif $class eq 'Term' {
        my $functor := $ast.functor;
        my $arity := $ast.arity;

        # Table 7, Principal functors and control structures gives the terms
        # that get special handling.
        # Section 7.8.5, ','/2 - conjunction.
        if $arity == 2 && $functor eq ',' {
           return PAST::Stmts.new(
                self.compile_body($ast.args[0], $paths, %vars),
                self.compile_body($ast.args[1], $paths, %vars));
        }
        # Section 7.8.6, ';' - disjunction.
        # Section 7.8.8, ';'/2 - if-then-else.
        elsif $arity == 2 && $functor eq ';' {
            # TODO: ;/2 with ->/2 as first argument (7.8.8).
            return PAST::Op.new(:pasttype<unless>,
                self.call_internal('choicepoint', $paths),
                self.compile_body($ast.args[0], $paths, %vars),
                self.compile_body($ast.args[1], $paths, %vars));
        }
        # Section 7.8.7, '->'/2 - if-then.
        elsif $arity == 2 && $functor eq '->' {
            pir::die('->/2 not implemented yet');
        }
        # Section 7.8.4, !/0 - cut.
        elsif $arity == 0 && $functor eq '!' {
            # On a cut we have to create a new mark on the stack so that a
            # subsequent cut won't mess with the backtracking info of a
            # predicate farther up the call stack.
            # BUG: Previously executed predicates leave stuff on the stack
            # that interfere with cut. Must investigate.
            return PAST::Stmts.new(
                self.call_internal('cut', $paths),
                self.call_internal('mark', $paths));
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
            return self.call_internal('fail', $paths);
        }
        # Section 7.8.9 - catch/3.
        elsif $arity == 3 && $functor eq 'catch' {
            pir::die('catch/3 not implemented yet');
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
            return self.procedure_call($name, |@args);
        }
    }
    else {
        pir::die("Can't handle $class goals.");
    }
}

method procedure_call($name, *@args) {
    return PAST::Op.new(:pasttype<call>, :name($name), |@args);
}

method call_internal($function, *@args) {
    return PAST::Op.new(:pasttype<call>,
        # XXX: This has the potential for breakage if weird names are passed in.
        PAST::Op.new(:inline("    %r = get_root_global ['_parrotlog'], '$function'")),
        |@args);
}

method variable($name?) {
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
