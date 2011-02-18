main :- write('1..4'), nl,
    test1,
    test2,
    test3.

test1 :- X = 'ok 1', call((write(X), nl)).
test2 :- call((write('ok 2'), nl; write('ok 3'), nl)), fail.
test2.
test3 :- call(true), fail.
test3 :- write('ok 4'), nl.

% vim: filetype=prolog
