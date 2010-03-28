class Parrotlog::Compiler is HLL::Compiler;

INIT {
    Parrotlog::Compiler.language('Parrotlog');
    Parrotlog::Compiler.parsegrammar(Parrotlog::Grammar);
    Parrotlog::Compiler.parseactions(Parrotlog::Actions);
}
