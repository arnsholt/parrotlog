class Parrotlog::Actions is HLL::Actions;

sub say($msg) {
    pir::say($msg);
}

method TOP($/) {
    say('TOP: ' ~ $/);
    #make PAST::Block.new( $<statementlist>.ast , :hll<Parrotlog>, :node($/) );
}

method EXPR($/) {
    say('EXPR: ' ~ $/);
}
