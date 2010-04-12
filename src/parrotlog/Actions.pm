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

method atom:sym<name>($/) { make Term.from_data($<name>); }

method term:sym<compound>($/) {
    make Term.from_data($<atom>, |$<arg_list><EXPR>);
}
