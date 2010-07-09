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

        # TODO: Figure out a sensible way to stitch together the different
        # branches of the predicate.
        for $clauses {
            $block.push: self.compile_clause($_, @args)
        }
    }

    return $past;
}

method compile_clause($clause, @args) {
    my $head;
    my $body;

    if $clause.arity == 2 && $clause.functor eq ':-' {
        $head := $clause.args[0];
        $body := $clause.args[0];
    }
    else {
        $head := $clause;
    }

    my $past := PAST::Stmts.new;
    $past.push: self.call_internal('mark', @args[0]);

    my %vars;
    for $clause.variable_set.contents -> $var {
        $past.push: PAST::Var.new(:name($var), :isdecl, :scope<register>,
            :viviself(self.variable($var)));
        %vars{$var} := PAST::Var.new(:name($var), :scope<register>);
    }

    my $i := 0;
    for $head.args -> $arg {
        $past.push: self.call_internal('unify',
            @args[$i+1],
            $head.args[$i].past);
        $i++;
    }

    # TODO: Compile body.
    $past.push: self.call_internal('fail', @args[0]);

    return $past;
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
        return PAST::Op.new(:pasttype<callmethod>, :name<name>,
            $obj,
            PAST::Val.new(:value($name)));
    }
    else {
        return $obj;
    }
}
