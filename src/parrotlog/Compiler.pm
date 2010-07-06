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
    my $paths := PAST::Var.new(:scope<register>, :name<paths>,
        self.call_internal('paths'));

    # Call main/0 on the initial pass, jump to error condition on backtrack.
    # TODO: The error message could use some love. =)
    $past.push: PAST::Op.new(:pasttype<unless>,
        $paths,
        PAST::Op.new(:inline('    die "OHNOES TEH MANATEE"')), # XXX: Final failure code goes here.
        PAST::Op.new(:name<main/0>, :pasttype<call>, $paths));
    $past.push: PAST::Op.new(:inline("say 'hello'"));

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

        #$block.push: compile_clause($_) for $clauses;
        for $clauses {
            $block.push: self.compile_clause($_, @args)
        }
    }

    return $past;
}

method compile_clause($clause, @args) {
    # For now, we just say something and fail. TODO: Actual compilation.
    return PAST::Stmts.new(
        self.call_internal('mark', @args[0]),
        PAST::Op.new(:inline("say 'hallo!'")),
        self.call_internal('fail', @args[0])
    );
}

method call_internal($function, *@args) {
    return PAST::Op.new(:pasttype<call>,
        # XXX: This has the potential for breakage if weird names are passed in.
        PAST::Op.new(:inline("    %r = get_root_global ['_parrotlog'], '$function'")),
        |@args);
}
