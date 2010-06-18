class Parrotlog::Actions is HLL::Actions;

method TOP($/) {
    for $<EXPR> -> $ast {
        $ast := $ast.ast;
        if $ast.functor eq ':-' && $ast.arity == 1 {
            # Handle directive logic. See section 7.4.2.
        }
        else {
            # Handle clause. See section 7.4.3.
        }
        $ast.output();
    }
}

method term:sym<atom>($/) { make Term.from_data($<atom>.ast); }

method atom:sym<name>($/) { make $<name>.ast; }
method atom:sym<empty_list>($/) { make '[]'; }
method atom:sym<curlies>($/) { make '{}'; }

method term:sym<compound>($/) {
    pir::say("compound");
    my @args;
    for $<exp> -> $arg {
        @args.push: $arg.ast;
    }
    make Term.from_data($<atom>, |@args);
}

method exp($/) { make $<EXPR>.ast }

method term:sym<list>($/) { pir::say("list");make $<items>.ast }
method items:sym<more>($/) { make Term.from_data('.', $<exp>.ast, $<items>.ast) }
method items:sym<ht>($/) { make Term.from_data('.', $<car>.ast, $<cdr>.ast) }
method items:sym<last>($/) {
    make Term.from_data('.', $<exp>.ast, Term.from_data('[]'))
}

method term:sym<curly>($/) { make Term.from_data('{}', $<EXPR>.ast) }

method name($/) { make $<name_token>.ast }

method name_token:sym<ident>($/) { make ~$<name> }
method name_token:sym<graphic>($/) { make ~$<name> }
method name_token:sym<quoted>($/) { make $<str>.ast }

method quote_EXPR($/) { make $<quote_delimited>.ast; }
method quote_delimited($/) {
    my $str := '';
    for $<quote_atom> -> $part {
        $str := $str ~ $part.ast;
    }

    make $str;
}

method quote_escape:sym<nl>($/) { make "\n" }
method quote_escape:sym<stopper>($/) { make ~$<stopper> }
method quote_escape:sym<meta>($/) { make ~$<meta> }

method EXPR($/, $tag?) {
    # $tag is empty in the final reduction of EXPR. In that case we don't need
    # to do anything.
    return 0 if !$tag;

    # TODO: Handle different cases depending on $tag.
    if $tag eq 'INFIX' {
        make Term.from_data($<OPER><op>.ast, $/[0].ast, $/[1].ast);
    }
    elsif $tag eq 'PREFIX' {
        make Term.from_data($<OPER><op>.ast, $/[0].ast);
    }
    elsif $tag eq 'POSTFIX' {
        make Term.from_data($<OPER><op>.ast, $/[0].ast);
    }
}

=begin olded

method TOP($/) {
    make $<prolog_text>.ast;

    my $i := 1;
    for $/.ast -> $x {
        pir::say("Thing $i:");
        $i++;
        $x.output;
    }

    # A hack, for the moment being.
    make make_past($/.ast[0]);
}

# XXX: A hack for the time being.
method prolog_text($/) {
    my @ast := ();
    for $/[0] -> $x {
        if $x<clause> { @ast.push: $x<clause>.ast; }
        #else          { @ast.push: $x<directive>.ast; }
    }
    make @ast;
}

method directive($/) { handle_directive($<directive_term>.ast); }
method directive_term($/) { make $<EXPR>.ast; }

method clause($/) { make $<clause_term>.ast; }
method clause_term($/) { make $<EXPR>.ast; }

method term:sym<atom>($/) { make $<atom>.ast; }
method atom:sym<name>($/) { make Term.from_data($<name>.ast); }
method atom:sym<empty_list>($/) { make Term.from_data('[]'); }
method atom:sym<curly_brackets>($/) { make Term.from_data('{}'); }

method term:sym<variable>($/) { make $<variable>.ast; }

# Compound terms: section 6.3.3
method term:sym<compound>($/) {

    make Term.from_data($<atom>.ast.functor, |$<arg_list>.ast);
}

method arg_list($/) {
    my @ast := ();
    for $<exp> -> $arg {
        @ast.push: $arg.ast;
    }
    make @ast;
}

# Expressions: section 6.3.3.1
method exp:sym<EXPR>($/) { make $<EXPR>.ast; }
method exp:sym<infix>($/) { make Term.from_data($<infix><sym>); }
method exp:sym<prefix>($/) { make Term.from_data($<prefix><sym>); }
method exp:sym<postfix>($/) { make Term.from_data($<postfix><sym>); }

# Compound terms - list notation: section 6.3.5
method term:sym<list>($/) { make $<items>.ast; }
method items:sym<comma>($/) { make Term.from_data('.', $<exp>.ast, $<items>.ast); }
method items:sym<tail>($/) { make Term.from_data('.', $<head>.ast, $<tail>.ast); }
method items:sym<exp>($/) { make Term.from_data('.', $<exp>.ast, Term.from_data('[]')); }

# Tokens: section 6.4
method name($/) { make $<name_token>; }

method variable($/) { make $<variable_token>.ast; }

method variable_token:sym<anonymous>($/) { make Variable.new; }
method variable_token:sym<named>($/) {
    my $var := Variable.new;
    $var.name(~$<name>);

    make $var;
}

# Interaction with the operator precedence parser.
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

=end olded
