=begin overview

This is the grammar for parrotlog in Perl 6 rules.

=end overview

grammar Parrotlog::Grammar is HLL::Grammar;

# XXX: nqp-rx doesn't like grammar items with -, so we use _ instead.
token TOP {
    <prolog_text>*
    [ $ || <.panic: "Syntax error"> ]
}

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
    my $i := 0;
    while $i <= 1201 {
        my $precstr :=
            $i < 10   ?? "000$i" !!
            $i < 100  ?? "00$i" !!
            $i < 1000 ?? "0$i" !!
                         "$i";
        Parrotlog::Grammar.O(":prec<$precstr>", $i);
        $i++;
    }
}

# Prolog text: section 6.2.1
token prolog_text { [ <directive> | <clause> ]* }

# Directives: section 6.2.1.1
token directive { <directive_term> <.end> }
# TODO: The term in directive term has priority 1201.
token directive_term { <term> }

# Clauses: section 6.2.1.2
token clause { <clause_term> <.end> }
# TODO: The term in clause term has priority 1201.
# TODO: The principal functor of term cannot be :-
token clause_term { <term> }

# Data: section 6.2.2
# TODO: The term in read term has priority 1201.
token read_term { <.layout_text>? <term> <.end> }

# Terms: section 6.3
#proto token term { <...> } # Already defined in HLL::Grammar
# Constants: section 6.3.1
# Numbers: section 6.3.1.1
# TODO: Priority should be 0.
token term:sym<integer> { '-'? <integer> }
token term:sym<float> { '-'? <float_number> }

# Negative numbers: section 6.3.1.2
# Handled inline in the integer/float terms.

# Atoms: section 6.3.1.3
# TODO: Priority is 0.
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
token arg_list { <EXPR>**<comma> }

# Expressions: section 6.3.3.1

# Operators: section 6.3.4.3
# TODO: I have to figure out how to interface with the NQP operator precedence
# parser.
# TODO: Precedence levels.
token infix:sym<:->           { <sym> <O('xfx')> }
token infix:sym<< --> >>      { <sym> <O('xfx')> }
token prefix:sym<:->          { <sym> <O('fx')> }
token prefix:sym<?->          { <sym> <O('fx')> }
token infix:sym<;>            { <sym> <O('xfy')> }
token infix:sym<< -> >>       { <sym> <O('xfy')> }
token infix:sym<,>            { <sym> <O('xfy')> }
token infix:sym<=>            { <sym> <O('xfx')> }
token infix:sym<\\=>          { <sym> <O('xfx')> }
token infix:sym<==>           { <sym> <O('xfx')> }
token infix:sym<\\==>         { <sym> <O('xfx')> }
token infix:sym<<@<>>         { <sym> <O('xfx')> }
token infix:sym<<@=<>>        { <sym> <O('xfx')> }
token infix:sym<< @> >>       { <sym> <O('xfx')> }
token infix:sym<< @>= >>      { <sym> <O('xfx')> }
token infix:sym<=..>          { <sym> <O('xfx')> }
token infix:sym<is>           { <sym> <O('xfx')> }
token infix:sym<=:=>          { <sym> <O('xfx')> }
token infix:sym<=\\=>         { <sym> <O('xfx')> }
token infix:sym<< < >>        { <sym> <O('xfx')> }
token infix:sym<=<>           { <sym> <O('xfx')> }
token infix:sym<< > >>        { <sym> <O('xfx')> }
token infix:sym<< >= >>       { <sym> <O('xfx')> }
token infix:sym<+>            { <sym> <O('yfx')> }
token infix:sym<->            { <sym> <!integer> <O('yfx')> }
token infix:sym</\\>          { <sym> <O('yfx')> }
token infix:sym<\\/>          { <sym> <O('yfx')> }
token infix:sym<*>            { <sym> <O('yfx')> }
token infix:sym</>            { <sym> <O('yfx')> }
token infix:sym<//>           { <sym> <O('yfx')> }
token infix:sym<rem>          { <sym> <O('yfx')> }
token infix:sym<mod>          { <sym> <O('yfx')> }
token infix:sym<<< << >>>     { <sym> <O('yfx')> }
token infix:sym<<< >> >>>     { <sym> <O('yfx')> }
token infix:sym<**>           { <sym> <O('xfx')> }
token infix:sym<^>            { <sym> <O('xfy')> }
token prefix:sym<->           { <sym> <O('fy')> }
token prefix:sym<\\>          { <sym> <O('fy')> }
token infix:sym<@>            { <sym> <O('xfx')> }
token infix:sym<:>            { <sym> <O('xfx')> }

# Tokens: section 6.4
token name { <.ws> <name_token> }
token variable { <.ws> <variable_token> }

# Layout text, section 6.4.1.
token ws { <layout_text>+ } # Layout text separates stuff, so we set <ws> to that
token layout_text { [ <layout_char> | <comment> ]+ }
proto token comment { <...> }
token comment:sym<line> { <line_comment> \N \n }
token comment:sym<bracketed> {
    '/*'
    [ <-[/]> | <!after '*' > '/' ] *
    '*/'
}

# Name tokens: section 6.4.2
proto token name_token { <...> }
token name_token:sym<identifier> { <small_char> <alnum_char>* }
token name_token:sym<graphic> { <+graphic_char +backslash>+ }
token name_token:sym<quoted> { <?[']> <quote_EXPR> } # For vim: ' ]> }

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
token quote_escape:sym<continuation> { <backslash> \n }
token quote_escape:sym<stopper> { <stopper> <stopper> }
token quote_escape:sym<control> { <backslash> <[abfnrtv]> }
token quote_escape:sym<octal> { <backslash> <octdigit_char> <backslash> }
token quote_escape:sym<hex> { <backslash> x <hexdigit_char> <backslash>  }

# Variables: section 6.4.3
proto token variable_token { <...> }
token variable_token:sym<anonymous> { <underscore> }
token variable_token:sym<named> { <underscore> <alnum_char>+ | <capital_char> <alnum_char>* }

# Integers: section 6.4.4
token integer_token {
    | <integer_constant>
    | <character_code_constant>
    | <binary_constant>
    | <octal_constant>
    | <hex_constant>
}

token integer_constant { <decint_char>+ }
# XXX: Probably broken, due to <stopper> not being set correctly.
token character_code_constant { 0 <single_quote_char> <quote_atom> }
token binary_constant { 0b <bindigit_char>+ }
token octal_constant { 0o <octdigit_char>+ }
token hex_constant { 0x <hexdigit_char>+ }

# Floating point numbers: section 6.4.5
token float_token { <integer_constant> '.' <decdigit_char>+ <exponent>? }
token exponent { <[eE]> <[\-+]>? <integer_constant> }

# Characters: section 6.5
token char { <+graphic_char +alnum_char +solo_char +layout_char +meta_char> }

# Graphic characters: section 6.5.1
token graphic_char { <[#$&*+_./:<=>?@^~]> }

# Alphanumerics: section 6.5.2
token alnum_char { <+alpha_char +digit> }
token alpha_char { <+underscore +letter> }
token letter_char { <+capital +small> }
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
token cut_char { <[!]> }
token open_char { <[(]> }
token close_char { <[)]> }
token comma_char { <[,]> }
token semicolon_char { <[;]> }
token open_list_char { <[\[]> }
token close_list_char { <[\]]> }
token open_curly_char { <[{]> }
token close_curly_char { <[}]> }
token head_tail_char { <[|]> }
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

## Lexer items

## Statements

rule statementlist { [ <statement> | <?> ] ** ';' }

rule statement {
    | <statement_control>
    | <EXPR>
}

proto token statement_control { <...> }
rule statement_control:sym<say>   { <sym> [ <EXPR> ] ** ','  }
rule statement_control:sym<print> { <sym> [ <EXPR> ] ** ','  }

## Terms

token term:sym<integer> { <integer> }
token term:sym<quote> { <quote> }

proto token quote { <...> }
token quote:sym<'> { <?[']> <quote_EXPR: ':q'> } # For vi: ' ]> }
token quote:sym<"> { <?["]> <quote_EXPR: ':qq'> } # For vi: " ]> }

# TODO: Operators. ISO Prolog allows for user defined operators. That should
# probably be implemented using nqp's extendable grammar features.
