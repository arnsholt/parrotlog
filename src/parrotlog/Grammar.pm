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

    %prefix<:-> := 'fx 1200';
    %prefix<?-> := 'fx 1200';
    %prefix<->  := 'fy 200';
    %prefix<\\> := 'fy 200';

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
    %infix<->     := 'yfx  500'; # XXX: Needs to check that following term is not an integer
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

method is_op($op) {
    return %prefix{$op} || %infix{$op} || %postfix{$op};
}

# Section 6.2.1, Prolog text and data
token TOP {
    #<?DEBUG>
    #[<term=.EXPR> <.end>]*

    # Serial alternation to make sure we check for directive before
    # interpreting as clause.
    [<directive> || <clause>]*
    [ <.ws> $ || <.panic: "Syntax error"> ]
}

token read_term {
    <.ws> <term> <.end> <.ws>
}

token directive {
    <directive=.EXPR> <.end>
    <?{ $<directive>.ast.functor eq ':-' && $<directive>.ast.arity == 1 }>
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
token term:sym<atom> { <.ws> <atom> <!{ is_op{$<atom>.ast} }> }

# TODO: Parse graphical tokens as atoms as well, so that we are able to parse
# operators as well.
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
token term:sym<compound> { <atom> <.open> <exp>**<.comma> <.close> }
# XXX: In exp we should allow operators of lower precedence than '0202' to be
# operands, but I've no idea how to allow that...
token exp { <.ws> <EXPR('0203')> }

# Section 6.3.5, compound terms - list notation
token term:sym<list> { <.open_list> <items> <.close_list> }
proto token items { <...> }
token items:sym<more> { <exp> <.comma> <items> }
token items:sym<ht> { <car=.exp> <.ht> <cdr=.exp> }
# XXX: Don't really like how I have to use lookahead here. Try to fold ht and
# last into one rule?
token items:sym<last> { <exp> <!ht> }

# Section 6.3.6, compound terms - curly bracket notation
token term:sym<curly> { <.open_curly> <EXPR> <.close_curly> }

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
    [ <-[/]> | <!after '*' > '/' ] *
    '*/'
}

# Section 6.4.2, names
proto token name_token { <...> }
token name_token:sym<ident> { $<name>=[<.lower> <.alnum>*] }
token name_token:sym<graphic> { $<name>=[<+[\\]+graphic_char>+] }
token name_token:sym<quoted> { <?[\']> <str=.quote_EXPR> }

# Section 6.4.2.1, quoted characters
# Essentially quote_atom from HLL::Grammar, but we allow <stopper> inside the
# string.
token quote_atom { [ <quote_escape> | <-quote_escape-stopper> ] }

token quote_escape:sym<nl> { \\ \n }
token quote_escape:sym<stopper> { <stopper> <.stopper> }
token quote_escape:sym<meta> { \\ $<meta>=<[\\'"`]> }
# TODO: The remaining escape sequences.

# Section 6.4.4, integer numbers
proto token integer { <...> }
token integer:sym<dec> { <decint> }

# Section 6.4.5, floating point numbers
token float {
    $<radix>=[<[0..9]>+ '.' <[0..9]>+]
    [<[eE]> $<esign>=<[+\-]>? $<exponent>=[<[0..9]>+]]?
}

# Section 6.5.2, graphic characters
token graphic_char { <[#$&*+\-./:<=>?@^~]> }

# Section 6.5.3, solo characters
token open { '(' }
token close { ')' }

# Section 6.5.4, layout characters
token layout_char { <space> | \n }

# Operators:
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

token postfix:sym<prolog> {
    <.ws> <op=.name>
    <?{ %postfix{$<op>.ast} }>
    <O(%postfix{$<op>.ast})>
}

=begin olded

# Prolog text and data: section 6.2
# Prolog text: section: 6.2.1
# XXX: nqp-rx doesn't like grammar items with -, so we use _ instead.
token TOP {
    #<?DEBUG>
    <prolog_text>
    [ <.ws> $ || <.panic: "Syntax error"> ]
}

token termish {
    <.ws>
    <prefixish>*
    <term>
    <postfixish>*
}

# Prolog text: section 6.2.1
token prolog_text { ( <directive> | <clause> )* }

# Directives: section 6.2.1.1
token directive {
    <directive_term>
    <?{ my $ast := $<directive_term>.ast;
        $ast ~~ Term && $ast.functor eq ":-" && $ast.arity == 1 }>
    <.end>
}
# TODO: The principal functor of the term is :-/1
# TODO: The term in directive term has priority 1201.
token directive_term { <EXPR> }

# Clauses: section 6.2.1.2
token clause { <clause_term> <.end> }
# TODO: The term in clause term has priority 1201.
# TODO: The principal functor of the term is not :-/1
token clause_term { <EXPR> }

# Data: section 6.2.2
# TODO: The term in read term has priority 1201.
token read_term { <.ws> <term> <.end> }

# Terms: section 6.3
#proto token term { <...> } # Already defined in HLL::Grammar
# Constants: section 6.3.1
# Numbers: section 6.3.1.1
# TODO: Priority should be 0.
token term:sym<integer> { $<neg>=['-'?] <integer> }
token term:sym<float> { $<neg>=['-'?] <float> }

# Negative numbers: section 6.3.1.2
# Handled inline in the integer/float terms.

# Atoms: section 6.3.1.3
# TODO: Priority is 0.
token operator { <.infix> | <.prefix> | <.postfix> }
token term:sym<atom> { <!operator> <atom> }


proto token atom { <...> }
token atom:sym<name> { <name> }
token atom:sym<empty_list> { <.open_list> <.close_list> }
token atom:sym<curly_brackets> { <.open_curly> <.close_curly> }

# Variables: section 6.3.2
# TODO: Priority is 0.
token term:sym<variable> { <variable> }

# Compound terms: section 6.3.3
token term:sym<compound> { <atom> <.open_ct> <arg_list> <.close> }
token arg_list { <exp>**<.comma> }

# Expressions: section 6.3.3.1
# An exp is an EXPR with a priority limit of 999. That means a precedence limit
# of 202.
proto token exp { <...> }
token exp:sym<EXPR> { <EXPR('0202')> }
#token exp { <infix> | <prefix> | <postfix> }
token exp:sym<infix> { <.ws> <infix> }
token exp:sym<prefix> { <.ws> <prefix> }
token exp:sym<postfix> { <.ws> <postfix> }

# Operators: section 6.3.4.3
# TODO: I have to figure out how to interface with the NQP operator precedence
# parser.
token infix:sym<:->           { <sym> <O('xfx 1200')> }
token infix:sym<< --> >>      { <sym> <O('xfx 1200')> }
token prefix:sym<:->          { <sym> <O('fx  1200')> }
token prefix:sym<?->          { <sym> <O('fx  1200')> }
token infix:sym<;>            { <sym> <O('xfy 1100')> }
token infix:sym<< -> >>       { <sym> <O('xfy 1050')> }
token infix:sym<,>            { <sym> <O('xfy 1000')> }
token infix:sym<=>            { <sym> <O('xfx  700')> }
token infix:sym<\\=>          { <sym> <O('xfx  700')> }
token infix:sym<==>           { <sym> <O('xfx  700')> }
token infix:sym<\\==>         { <sym> <O('xfx  700')> }
token infix:sym<<@<>>         { <sym> <O('xfx  700')> }
token infix:sym<<@=<>>        { <sym> <O('xfx  700')> }
token infix:sym<< @> >>       { <sym> <O('xfx  700')> }
token infix:sym<< @>= >>      { <sym> <O('xfx  700')> }
token infix:sym<=..>          { <sym> <O('xfx  700')> }
token infix:sym<is>           { <sym> <O('xfx  700')> }
token infix:sym<=:=>          { <sym> <O('xfx  700')> }
token infix:sym<=\\=>         { <sym> <O('xfx  700')> }
token infix:sym<< < >>        { <sym> <O('xfx  700')> }
token infix:sym<=<>           { <sym> <O('xfx  700')> }
token infix:sym<< > >>        { <sym> <O('xfx  700')> }
token infix:sym<< >= >>       { <sym> <O('xfx  700')> }
token infix:sym<+>            { <sym> <O('yfx  500')> }
token infix:sym<->            { <sym> <!integer> <O('yfx 500')> }
token infix:sym</\\>          { <sym> <O('yfx  500')> }
token infix:sym<\\/>          { <sym> <O('yfx  500')> }
token infix:sym<*>            { <sym> <O('yfx  400')> }
token infix:sym</>            { <sym> <O('yfx  400')> }
token infix:sym<//>           { <sym> <O('yfx  400')> }
token infix:sym<rem>          { <sym> <O('yfx  400')> }
token infix:sym<mod>          { <sym> <O('yfx  400')> }
token infix:sym<<< << >>>     { <sym> <O('yfx  400')> }
token infix:sym<<< >> >>>     { <sym> <O('yfx  400')> }
token infix:sym<**>           { <sym> <O('xfx  200')> }
token infix:sym<^>            { <sym> <O('xfy  200')> }
token prefix:sym<->           { <sym> <O('fy   200')> }
token prefix:sym<\\>          { <sym> <O('fy   200')> }
token infix:sym<@>            { <sym> <O('xfx  100')> }
token infix:sym<:>            { <sym> <O('xfx   50')> }

# Compound terms - list notation: section 6.3.5
token term:sym<list> { <.open_list> <items> <.close_list> }
proto token items { <...> }
token items:sym<comma> { <exp> <.comma> <items> }
token items:sym<tail> { $<head>=<.exp> <.ht_sep> $<tail>=<.exp> }
token items:sym<exp> { <exp> }
#token items { $<head>=[<.EXPR> ** <.comma>] [<.ht_sep> $<tail>=<.EXPR>]? }

# Compound terms - curly bracket notation: section 6.3.6
token term:<curly> { <.open_curly> <term> <.close_curly> }

# Compound terms - character code list notation: section 6.3.7
# TODO

# Tokens: section 6.4
proto token token { <...> }
token token:sym<name> { <name_token> }
token token:sym<variable> { <variable_token> }
token token:sym<integer> { <integer_token> }
token token:sym<float> { <float_token> }
# TODO: Char code list.
token token:sym<open> { <open_token> }
token token:sym<close> { <close_token> }
token token:sym<open_list> { <open_list_token> }
token token:sym<close_list> { <close_list_token> }
token token:sym<open_curly> { <open_curly_token> }
token token:sym<close_curly> { <close_curly_token> }
token token:sym<head_tail_separator> { <head_tail_separator_token> }
token token:sym<comma> { <comma_token> }
token token:sym<end> { <end_token> }

token name        { <.ws> <name_token> }
token variable    { <.ws> <variable_token> }
token integer     { <.ws> <integer_token> }
token float       { <.ws> <float_token> }
# TODO: Char code list.
token open_ct     { <.ws> <.open_token> }
token close       { <.ws> <.close_token> }
token open_list   { <.ws> <.open_list_token> }
token close_list  { <.ws> <.close_list_token> }
token open_curly  { <.ws> <.open_curly_token> }
token close_curly { <.ws> <.close_curly_token> }
token ht_sep      { <.ws> <.head_tail_separator_token> }
token comma       { <.ws> <.comma_token> }
token end         { <.ws> <.end_token> }

# Name tokens: section 6.4.2
proto token name_token { <...> }
token name_token:sym<identifier> { <small_char> <alnum_char>* }
token name_token:sym<graphic> { <+graphic_char +backslash_char>+ }
token name_token:sym<quoted> { <?[']> <quote_EXPR> } # For vim: ' ]> }
token name_token:sym<semicolon> { <semicolon_char> }
token name_token:sym<cut> { <cut_char> }

# We might be able to get some of this for free using quote_EXPR's quotemod
# features, but I'm not quite sure if it'll work exactly as I want to.
# We override quote_atom, because the default rule wants the matche to be
# <!stopper>, which means that quote_escape:sym<stopper> will never match.
token quote_atom {
    [
    | <quote_escape>
    | [ <-quote_escape-stopper> ]+
    ]
}
token quote_escape:sym<continuation> { <backslash_char> \n }
token quote_escape:sym<stopper> { <stopper> <stopper> }
token quote_escape:sym<control> { <backslash_char> <[abfnrtv]> }
token quote_escape:sym<octal> { <backslash_char> <octdigit_char> <backslash_char> }
token quote_escape:sym<hex> { <backslash_char> x <hexdigit_char> <backslash_char>  }

# Variables: section 6.4.3
proto token variable_token { <...> }
token variable_token:sym<anonymous> { <.underscore_char> }
token variable_token:sym<named> {
    | $<name>=[<.underscore_char> <.alnum_char>+]
    | $<name>=[<.capital_char> <.alnum_char>*]
}

# Integers: section 6.4.4
token integer_token {
    | <integer_constant>
    | <character_code_constant>
    | <binary_constant>
    | <octal_constant>
    | <hex_constant>
}

token integer_constant { <decdigit_char>+ }
# XXX: Probably broken, due to <stopper> not being set correctly.
token character_code_constant { 0 <single_quote_char> <quote_atom> }
token binary_constant { 0b <bindigit_char>+ }
token octal_constant { 0o <octdigit_char>+ }
token hex_constant { 0x <hexdigit_char>+ }

# Floating point numbers: section 6.4.5
token float_token { <integer_constant> '.' <decdigit_char>+ <exponent>? }
token exponent { <[eE]> <[\-+]>? <integer_constant> }

# Character code lists: section 6.4.6
# TODO

# Back quoted strings: section 6.4.7
# TODO

# Other tokens: section 6.4.8
token open_token { <open_char> }
token close_token { <close_char> }
token open_list_token { <open_list_char> }
token close_list_token { <close_list_char> }
token open_curly_token { <open_curly_char> }
token close_curly_token { <close_curly_char> }
token head_tail_separator_token { <head_tail_char> }
token comma_token { <comma_char> }
token end_token { <end_char> }

token end_char { '.' }

# Characters: section 6.5
token char { <+graphic_char +alnum_char +solo_char +layout_char +meta_char> }

# Graphic characters: section 6.5.1
token graphic_char { <[#$&*+\-./:<=>?@^~]> }

# Alphanumerics: section 6.5.2
token alnum_char { <+alpha_char +digit> }
token alpha_char { <+underscore_char +letter_char> }
token letter_char { <+capital_char +small_char> }
token small_char { <lower> }
token capital_char { <upper> }
token decdigit_char { <[0..9]> }
token bindigit_char { <[01]> }
token octdigit_char { <[0..7]> }
token hexdigit_char { <xdigit> }
token underscore_char { <[_]> }

# Solo characters: section 6.5.3
token solo_char { <+cut_char
                   +open_char
                   +close_char
                   +comma_char
                   +semicolon_char
                   +open_list_char
                   +close_list_char
                   +open_curly_char
                   +close_curly_char
                   +head_tail_char
                   +line_comment_char> }
token cut_char          { <[!]> }
token open_char         { <[(]> }
token close_char        { <[)]> }
token comma_char        { <[,]> }
token semicolon_char    { <[;]> }
token open_list_char    { <[\[]> }
token close_list_char   { <[\]]> }
token open_curly_char   { <[{]> }
token close_curly_char  { <[}]> }
token head_tail_char    { <[|]> }
token line_comment_char { <[%]> }

# Layout characters: section 6.5.4
token layout_char { <space> | \n }

# Meta characters: section 6.5.5
token meta_char { <+backslash_char
                   +single_quote_char
                   +double_quote_char
                   +back_quote_char> }
token backslash_char { <[\\]> }
token single_quote_char { <[']> }
token double_quote_char { <["]> }
token back_quote_char { <[`]> }

=end olded
