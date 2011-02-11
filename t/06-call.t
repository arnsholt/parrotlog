main :- write('1..1'), nl,
    test1.

test1 :- X = 'ok 1', call(write(X)).
