class Parrotlog::Actions is HLL::Actions;

sub say($msg) {
    pir::say($msg);
}

method TOP($/) {
    make $<prolog_text>.ast;

    $/.ast.output;
}

# XXX: A hack for the time being.
method prolog_text($/) { make $/[0][0]<directive>.ast; }

method directive($/) { make $<directive_term>.ast; }
method directive_term($/) { make $<EXPR>.ast; }

method clause($/) { make $<clause_term>.ast; }
method clause_term($/) { make $<EXPR>.ast; }

method EXPR($/, $tag?) {
    if !$tag {
    }
    # XXX: This may have to change when we support custom operators.
    elsif $tag eq 'INFIX' {
        make Term.from_data($<infix><sym>, $/[0].ast, $/[1].ast);
    }
    elsif $tag eq 'PREFIX' {
       make Term.from_data($<prefix><sym>, $/[0].ast);
    }
    elsif $tag eq 'POSTFIX' {
       make Term.from_data($<postfix><sym>, $/[0].ast);
    }
}

method term:sym<atom>($/) { make $<atom>.ast; }
method atom:sym<name>($/) { make Term.from_data($<name>); }
method atom:sym<empty_list>($/) { make Term.from_data('[]'); }
method atom:sym<curly_brackets>($/) { make Term.from_data('{}'); }

method term:sym<variable>($/) { make $<variable>.ast; }

method term:sym<compound>($/) {
    my @args := ();
    for $<arg_list><EXPR> -> $arg {
        @args.push: $arg.ast
    }

    make Term.from_data($<atom>, |@args);
}

method variable($/) { make $<variable_token>.ast; }

method variable_token:sym<anonymous>($/) { make Variable.new; }
method variable_token:sym<named>($/) {
    my $var := Variable.new;
    $var.name(~$<name>);

    make $var;
}
