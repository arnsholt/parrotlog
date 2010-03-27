class parrotlog::Compiler is HLL::Compiler;

INIT {
    parrotlog::Compiler.language('parrotlog');
    parrotlog::Compiler.parsegrammar(parrotlog::Grammar);
    parrotlog::Compiler.parseactions(parrotlog::Actions);
}
