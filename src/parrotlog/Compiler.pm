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
    #$past.push: PAST::Op(:pasttype<call>, :name<main/0>, );
    my $paths := self.call_internal('paths');
    $past.push: PAST::Op.new(:name<main/0>, :pasttype<call>, $paths);

    for $ast -> $predicate {
        my $clauses := $ast{$predicate};
        my $block := PAST::Block.new(:name($predicate));
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
        @args.push: PAST::Var.new(:name<paths>, :scope<parameter>);
        while $i < $arity {
            $i++;
            my $arg := PAST::Var.new(:name("arg" ~ $i), :scope<parameter>);
            @args.push: $arg;
            $block.push: $arg;
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
    # TODO: Create PAST for each clause and stitch them together to
    # make the whole predicate.
    my $past := PAST::Stmts.new();
    #my $choicepoint := PAST::Op.new(:pasttype<if>, self.choicepoint(@args[0]), $if);
}

method choicepoint($paths) {
    my $past;

    #return PAST::Op.new(:pasttype<call>, $function, $paths);
}

method call_internal($function, *@args) {
    return PAST::Op.new(:pasttype<call>, 
        # XXX: This has the potential for breakage if weird names are passed in.
        PAST::Op.new(:inline("    %r = get_root_global ['_parrotlog'], '$function'")),
        |@args);
}
