class Parrotlog::Actions is HLL::Actions;

method TOP($/) {
    # We make the AST a hash of arrays, with a single hash entry for each
    # predicate.
    # XXX: How this will interact with queries typed on the REPL remains to be
    # seen.
    my %ast;
    for $<clause> -> $ast {
=begin spec

A clause whose functor is :-/2 defines a procedure foo/n where foo and n are
the functor and arity of the clause's first argument, respectively; any other
clause defines a procedure foo/n where foo and n are the clause's functor and
arity. foo cannot be a built-in or a control construct.

=end spec
        $ast := $ast.ast;

        my $spec := $ast.arity == 2 && $ast.functor eq ':-'??
                        $ast.args[0].predicate_spec !!
                        $ast.predicate_spec;
        %ast{$spec} := [] if !pir::defined(%ast{$spec});
        %ast{$spec}.push: $ast;
    }

    make %ast;
}

# XXX: Directive handling should probably be folded into the grammar, rather
# than the actions, seeing how their effects are mostly syntactic.
method directive($/) {
    my $directive := $<directive>.ast.args[0];
    if $directive.functor eq 'op' && $directive.arity == 3 {
        self.insert_op($/, |$directive.args);
    }
    elsif $directive.functor eq 'dynamic' && $directive.arity == 1 {
        # dynamic/1 can be safely ignored for now, I think.
    }
    elsif $directive.functor eq 'coretest' && $directive.arity == 0 {
        Coretest::coretest();
    }
    else {
        $/.CURSOR.panic("Unknown directive {$directive.functor}/{$directive.arity}");
    }
}

method clause($/) { make $<clause>.ast }

# Section 7.4.2.4, directive op/3
method insert_op($/, $priority, $specifier, $operator) {
    # XXX: Check constraints on input arguments!
    $specifier := $specifier.functor;
    $priority := $priority.value;
    $operator := $operator.functor; # XXX: Can also be a list.
    my $spec := "$specifier $priority";

=begin spec
Section 6.3.4.3:
There shall not be two operators with the same class and name.

There shall not be an infix and a prefix operator with the same name.
=end spec
    if $specifier eq 'fx' || $specifier eq 'fy' {
        $/.CURSOR.panic("Redefinition of prefix operator $operator")
            if %Parrotlog::Grammar::prefix{$operator};

        %Parrotlog::Grammar::prefix{$operator} := $spec;
    }
    elsif $specifier eq 'xfx' || $specifier eq 'xfy' || $specifier eq 'yfx' {
        $/.CURSOR.panic("Redefinition of infix operator $operator")
            if %Parrotlog::Grammar::infix{$operator};
        $/.CURSOR.panic("Cannot create infix $operator when postfix already exists")
            if %Parrotlog::Grammar::postfix{$operator};

        %Parrotlog::Grammar::infix{$operator} := $spec;
    }
    elsif $specifier eq 'xf' || $specifier eq 'yf' {
        $/.CURSOR.panic("Redefinition of postfix operator $operator")
            if %Parrotlog::Grammar::postfix{$operator};
        $/.CURSOR.panic("Cannot create postfix $operator when infix already exists")
            if %Parrotlog::Grammar::infix{$operator};

        %Parrotlog::Grammar::postfix{$operator} := $spec;
    }
    else {
        $/.CURSOR.panic("Bad operator specifier: $specifier");
    }
}

method term:sym<integer>($/) { make $<integer>.ast }
method term:sym<float>($/) { make $<float>.ast }

method term:sym<atom>($/) { make Term.from_data($<atom>.ast) }

method atom:sym<name>($/) { make $<name>.ast }
method atom:sym<empty_list>($/) { make '[]' }
method atom:sym<curlies>($/) { make '{}' }

method term:sym<variable>($/) { make $<variable>.ast }

method variable:sym<named>($/) { 
    my $var := Variable.new;
    $var.name: ~$<name>;
    make $var;
}
method variable:sym<anon>($/) { make Variable.new }

method term:sym<compound>($/) {
    my @args;
    for $<exp> -> $arg {
        @args.push: $arg.ast;
    }
    make Term.from_data($<atom>.ast, |@args);
}

method exp:sym<expr>($/) { make $<EXPR>.ast }
method exp:sym<op>($/) { make Term.from_data($<atom>.ast) }

method term:sym<list>($/) { make $<items>.ast }
method items:sym<more>($/) { make Term.from_data('.', $<exp>.ast, $<items>.ast) }
method items:sym<last>($/) {
    make Term.from_data('.', $<car>.ast,
        $<cdr>[0] ?? $<cdr>[0].ast !! Term.from_data('[]'));
}

method term:sym<curly>($/) { make Term.from_data('{}', $<EXPR>.ast) }

method name($/) { make $<name_token>.ast }
method comma($/) { make ',' } # To make the EXPR code happy

method name_token:sym<ident>($/) { make ~$<name> }
method name_token:sym<graphic>($/) { make ~$<name> }
method name_token:sym<quoted>($/) { make $<str>.ast }
method name_token:sym<;>($/) { make ~$<sym> }
method name_token:sym<!>($/) { make ~$<sym> }

method quote_EXPR($/) { make $<quote_delimited>.ast }
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
method quote_espace:sym<oct>($/) { make pir::chr($<octint>.ast) }
method quote_espace:sym<hex>($/) { make pir::chr($<hexint>.ast) }

method integer:sym<dec>($/) { make Int.create($<decint>.ast) }
method integer:sym<bin>($/) { make Int.create($<binint>.ast) }
method integer:sym<oct>($/) { make Int.create($<octint>.ast) }
method integer:sym<hex>($/) { make Int.create($<hexint>.ast) }
method integer:sym<chr>($/) { make Int.create(pir::ord(~$/[0])) }

method float($/) { make Float.create($<dec_number>.ast) }

method circumfix:sym<( )>($/) { make $<EXPR>.ast }
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
