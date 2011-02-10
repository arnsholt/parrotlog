main :- write('1..2'), nl,
    test1,
    test2.

% Test for bug in in atom/1.
test1 :- X = a, atom(X), write('ok 1'), nl.
test1 :- write('not ok 1'), nl.

test2 :- X = a(b), compound(X), write('ok 2'), nl.
test2 :- write('not ok 2'), nl.

% vim:filetype=prolog
