=begin overview

This is the grammar for parrotlog in Perl 6 rules.

=end overview

grammar Parrotlog::Grammar is HLL::Grammar;

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
    # XXX: Prolog has lower priority = binds tighter, while I think NQP has
    # higher precedence = binds tighter. That'll have to be fixed.
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
}

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
# An exp is an EXPR with a priority limit of 99. That means a precedence limit
# of 202.
proto token exp { <...> }
token exp:sym<EXPR> { <EXPR('0202')> }
#token exp { <infix> | <prefix> | <postfix> }
token exp:sym<infix> { <infix> }
token exp:sym<prefix> { <prefix> }
token exp:sym<postfix> { <postfix> }

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
token term:<list> { <.open_list> <items> <.close_list> }
token items { $<head>=[<.EXPR> ** <.comma>] [<.ht_sep> $<tail>=<.EXPR>]? }

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

# Layout text, section 6.4.1
# Layout text separates stuff, so we set <ws> to that
token ws { <.layout_text>* }
token layout_text { [ <.layout_char> | <.comment>  ]+ }
proto token comment { <...> }
token comment:sym<line> { <.line_comment_char> \N* \n  }
token comment:sym<bracketed> {
    '/*'
    [ <-[/]> | <!after '*' > '/' ] *
    '*/'
}

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
token head_tail_separator_token { <head_tail_separator_char> }
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
