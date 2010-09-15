=begin overview

This is the grammar for parrotlog in Perl 6 rules.

=end overview

grammar Parrotlog::Grammar is HLL::Grammar;

our %prefix;
our %infix;
our %postfix;

INIT {
    # Operator precedence stuff for the associativity of operators.
    Parrotlog::Grammar.O(':assoc<unary> :uassoc<non>',    'fx');
    Parrotlog::Grammar.O(':assoc<unary> :uassoc<right>',  'fy');
    Parrotlog::Grammar.O(':assoc<non>',                  'xfx');
    Parrotlog::Grammar.O(':assoc<right>',                'xfy');
    Parrotlog::Grammar.O(':assoc<left>',                 'yfx');
    Parrotlog::Grammar.O(':assoc<unary> :uassoc<non>',   'xf');
    Parrotlog::Grammar.O(':assoc<unary> :uassoc<left>',  'yf');

    # Prolog has precedence levels from 0 to 1201. I'm not going to type them
    # all in by hand.
    # TODO: When we actually support defining custom operators, we should
    # probably generate only the precedence levels we need, to avoid bogging
    # down NQP with too many of them. For on-the-fly generation of rules, see
    # the Rakduo source.
    my $pri := 1;
    while $pri <= 1200 {
        my $i := 1201 - $pri;
        my $precstr :=
            $i < 10   ?? "000$i" !!
            $i < 100  ?? "00$i" !!
            $i < 1000 ?? "0$i" !!
                         "$i";
        Parrotlog::Grammar.O(":prec<$precstr>", $pri);
        $pri++;
    }

    %prefix<:->  := 'fx 1200';
    %prefix<?->  := 'fx 1200';
    # XXX: \+/1 isn't defined in the draft I have, only in the final standard,
    # so this is currently a bit sketchy.
    %prefix<\\+> := 'fy 900';
    # Prefix -/1 gets special treatment so that -3 is parsed correctly.
    #%prefix<->   := 'fy 200';
    %prefix<\\>  := 'fy 200';

    %infix<:->    := 'xfx 1200';
    %infix{'-->'} := 'xfx 1200';
    %infix<;>     := 'xfy 1100';
    %infix{'->'}  := 'xfy 1050';
    %infix<,>     := 'xfy 1000';
    %infix<=>     := 'xfx  700';
    %infix<\\=>   := 'xfx  700';
    %infix<==>    := 'xfx  700';
    %infix<\\==>  := 'xfx  700';
    %infix<<@<>>  := 'xfx  700';
    %infix<<@=<>> := 'xfx  700';
    %infix{'@>'}  := 'xfx  700';
    %infix{'@>='} := 'xfx  700';
    %infix<=..>   := 'xfx  700';
    %infix<is>    := 'xfx  700';
    %infix<=:=>   := 'xfx  700';
    %infix<=\\=>  := 'xfx  700';
    %infix<< < >> := 'xfx  700';
    %infix<=<>    := 'xfx  700';
    %infix{'>'}   := 'xfx  700';
    %infix{'>='}  := 'xfx  700';
    %infix<+>     := 'yfx  500';
    %infix<->     := 'yfx  500';
    %infix</\\>   := 'yfx  500';
    %infix<\\/>   := 'yfx  500';
    %infix<*>     := 'yfx  400';
    %infix</>     := 'yfx  400';
    %infix<//>    := 'yfx  400';
    %infix<rem>   := 'yfx  400';
    %infix<mod>   := 'yfx  400';
    %infix{'<<'}  := 'yfx  400';
    %infix{'>>'}  := 'yfx  400';
    %infix<**>    := 'xfx  200';
    %infix<^>     := 'xfy  200';
    %infix<@>     := 'xfx  100';
    %infix<:>     := 'xfx   50';
}

sub is_op($op) {
    return %prefix{$op} || %infix{$op} || %postfix{$op};
}

# Section 6.2.1, Prolog text and data
method TOP() {
    $*DIRECTIVES ?? self.with_directives !! self.no_directives;
}

token with_directives {
    #<?DEBUG>
    #[<term=.EXPR> <.end>]*

    # Serial alternation to make sure we check for directive before
    # interpreting as clause.
    [<directive> || <clause>]*
    [ <.ws> $ || <.panic: "Syntax error"> ]
}

token no_directives {
    <clause>*
    [ <.ws> $ || <.panic: "Syntax error"> ]
}

token read_term {
    <.ws> <term> <.end> <.ws>
}

token directive {
    <directive=.EXPR> <.end>
    <?{ $<directive>.ast ~~ Term
     && $<directive>.ast.functor eq ':-'
     && $<directive>.ast.arity == 1 }>
}

token clause { <clause=.EXPR> <.end> }

# Section 6.3, terms
# Section 6.3.1, constants
# Section 6.3.1.1, numbers; section 6.3.1.2, negative numbers
token term:sym<integer> { $<neg>=['-'?] <integer> }
token term:sym<float> { $<neg>=['-'?] <float> }

# Section 6.3.1.3, atoms
# XXX: Some kind of magic will be necessary here to rule out illegal
# combinations of operators as literals.
# Section 6.3.1.3: An atom which is an operator shall not be the immediate
# operand of an operator.
token term:sym<atom> { <.ws> <atom> <!{ is_op($<atom>.ast) }> }

proto token atom { <...> }
token atom:sym<name> { <name> }
token atom:sym<empty_list> { <.open_list> <.close_list> }
token atom:sym<curlies> { <.open_curly> <.close_curly> }

# Section 6.3.2, variables
token term:sym<variable> { <.ws> <variable> }

proto token variable { <...> }
token variable:sym<named> { $<name>=['_' <.alnum>+ | <.upper> <.alnum>*] }
token variable:sym<anon> { '_' }

# Section 6.3.3, compound terms - functional notation
token term:sym<compound> { <atom> <.open> ~ <.close> <exp>**<.comma> }
proto token exp { <...> }
token exp:sym<expr> { <.ws> <EXPR('0203')> }
token exp:sym<op> { <.ws> <atom> <?{ is_op($<atom>.ast) && $<atom>.ast ne ',' }> }

# Section 6.3.5, compound terms - list notation
token term:sym<list> { <.open_list> ~ <.close_list> <items> }
token items { <exp>**<.comma> [<.ht> <cdr=.exp>]? }

# Section 6.3.6, compound terms - curly bracket notation
token term:sym<curly> { <.open_curly> ~ <.close_curly> <EXPR> }

# Section 6.4, tokens
token name { <.ws> <name_token> }
token open_list { <.ws> '[' }
token close_list { <.ws> ']' }
token open_curly { <.ws> '{' }
token close_curly { <.ws> '}' }
token ht { <.ws> '|' }
token comma { <.ws> ',' }
token end { <.ws> '.' }

# Section 6.4.1, layout text
# Layout text separates stuff, so we set <ws> to that
token ws { <.layout_text>* }
token layout_text { [ <.layout_char> | <.comment>  ]+ }
proto token comment { <...> }
token comment:sym<line> { '%' \N* \n  }
token comment:sym<bracketed> {
    '/*'
    [ <-[*]> | '*' <!before '/'> ] *
    '*/'
}

# Section 6.4.2, names
proto token name_token { <...> }
token name_token:sym<ident> { $<name>=[<.lower> <+alnum+[_]>*] }
token name_token:sym<graphic> { $<name>=[<+[\\]+graphic_char>+] }
token name_token:sym<quoted> { <?[\']> <str=.quote_EXPR> }
token name_token:sym<;> { <sym> }
token name_token:sym<!> { <sym> }

# Section 6.4.2.1, quoted characters
# Essentially quote_atom from HLL::Grammar, but we allow <stopper> inside the
# string.
token quote_atom { [ <quote_escape> | <-quote_escape-stopper> ] }

token quote_escape:sym<nl> { \\ \n }
token quote_escape:sym<stopper> { <stopper> <.stopper> }
token quote_escape:sym<meta> { \\ $<meta>=<[\\'"`]> }
# TODO: The remaining escape sequences.
token quote_escape:sym<oct> { \\ <octint> \\ }
token quote_escape:sym<hex> { \\ x <hexint> \\ }

token nonnumeric { <!before [<integer> | <float>]> }
# Section 6.4.4, integer numbers
proto token integer { <...> }
# A bit of a hack to prevent "1.3." from being read as two integers rather
# than a single float
token integer:sym<dec> { <decint> <!before '.' <decint>> }
token integer:sym<bin> { '0b' <binint> }
token integer:sym<oct> { '0o' <octint> }
token integer:sym<hex> { '0x' <hexint> }
token integer:sym<chr> { "0'" (.) } # XXX: This is not 100% right
# Override the *int tokens from HLL::Grammar to disallow _ between digits.
token decint { \d+ }
token binint { <[01]>+ }
token octint { <[0..7]>+ }
token hexint { <[0..9a..fA..F]>+ }

# Section 6.4.5, floating point numbers
token float { <dec_number> }
# Override dec_number to allow only standard Prolog floats.
token dec_number { $<coeff>=[<.decint> '.' <.decint>] <escale>? }

# Section 6.5.2, graphic characters
token graphic_char { <[#$&*+\-./:<=>?@^~]> }

# Section 6.5.3, solo characters
token open { '(' }
token close { ')' }

# Section 6.5.4, layout characters
token layout_char { <space> | \n }

# Operators:
token circumfix:sym<( )> { <.ws> <.open> <EXPR> <.ws> <.close> }
token infix:sym<prolog> {
    # The infix operators need a special case for comma, since it isn't a
    # <name>.
    <.ws> [<op=.name> | <op=.comma>]
    <?{ %infix{$<op>.ast} }>
    <O(%infix{$<op>.ast})>
}

token prefix:sym<prolog> {
    <.ws> <op=.name>
    <?{ %prefix{$<op>.ast} }>
    <O(%prefix{$<op>.ast})>
}

token prefix:sym<neg> {
    # For some absurd reason, this doesn't work:
    # <.ws> $<op>=['-']
    <.ws> <op=.name>
    <?{ $<op>.ast eq '-' }>
    <!before <integer> | <float>>
    <O('fy 200')>
}

token postfix:sym<prolog> {
    <.ws> <op=.name>
    <?{ %postfix{$<op>.ast} }>
    <O(%postfix{$<op>.ast})>
}
