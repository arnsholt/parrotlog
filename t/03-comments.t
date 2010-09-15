% And now, for something completely different. This file doesn't really test
% any code, it just makes sure certain syntactic construction parse.
% Line comment.
/* Block comment. */
/* Perverted /// block */
/* More * / block */ % With line
main :- write('1..1'), nl,
    write('ok 1'), nl.
foo :- X = f(:-, ;, [:-, :-|:-]).
