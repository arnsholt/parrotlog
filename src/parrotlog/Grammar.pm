=begin overview

This is the grammar for parrotlog in Perl 6 rules.

=end overview

grammar parrotlog::Grammar is HLL::Grammar;

# XXX: nqp-rx doesn't like grammar items with -, so we use _ instead.
token TOP {
    <prolog_text>*
    [ $ || <.panic: "Syntax error"> ]
}

proto token prolog_text { <...> }
rule prolog_text:type<directive> { <term> '.' }
rule prolog_text:type<clause> { }

proto token term { <...> }

rule atom:sym<[ ]> { <sym> }
rule atom:sym<{ }> { <sym> }

# Tokens: section 6.4

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
# TODO: This stuff should probably be implemented with quote_EXPR. I just have
# to figure out how quote_EXPR works...
#token name_token:sym<quoted> {
#    <single_quote_char> [ <single_quoted_char> | \\ \n ]* <single_quote_char>
#}
#token semicolon_token { <semicolon_char> }
#token cut_token { <cut_char> }
#proto token single_quoted_char { <...> }
#token single_quoted_char:sym<non-quote> { <+graphic_char
#                                           +alnum_char
#                                           +solo_char
#                                           +space> }
#token single_quoted_char:sym<meta-escape> { <backslash_char> <meta_char> }
#token single_quoted_char:sym<control-escape> { 

# Variables: section 6.4.3
proto token variable { <...> }
token variable:sym<anonymous> { <underscore> }
token variable:sym<named> { <underscore> <alnum-char>+ | <capital-char> <alnum-char>* }

# Characters: section 6.5
token char { <+graphic_char +alnum_char +solo_char +layout_char +meta_char> }

# Graphic characters: section 6.5.1
token graphic_char { <[#$&*+_./:<=>?@^~]> }

# Alphanumerics: section 6.5.2
token alnum_char { <+alpha +digit> }
token alpha_char { <+underscore letter> }
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
token quote:sym<'> { <?[']> <quote_EXPR: ':q'> } # For vi: '
token quote:sym<"> { <?["]> <quote_EXPR: ':qq'> }

# TODO: Operators. ISO Prolog allows for user defined operators. That should
# probably be implemented using nqp's extendable grammar features.
