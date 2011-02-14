main :- write('1..3'), nl,
    test1,
    test2.

test1 :- X = 'ok 1', call((write(X), nl)).
test2 :- call((write('ok 2'), nl; write('ok 3'), nl)), fail.
test2.
