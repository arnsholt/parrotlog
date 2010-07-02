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
    # TODO: Make it actually do anything. For starters I think making it
    # invoke a goal main/0 will be a good place to start.
    my $past := PAST::Block.new(:hll<parrotlog>, :blocktype<immediate>);

    for $ast -> $predicate {
        my $block := PAST::Block.new(:name($predicate));
        # TODO: Replace with a single parameter variable for each argument to
        # the predicate.
        # Arguments can be named simply arg1..argn, because Prolog variables
        # can't start with a lowercase letter so all those names are free for
        # us to use internally.
        my $args := PAST::Var.new(:name<args>, :scope<parameter>, :slurpy);

        $block.push: $args;
        $past.push: $block;

        pir::say($predicate);
    }

    return $past;
}
