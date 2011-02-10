% Hand-converted from if-then in inriasuite.
main :- write('1..8'), nl,
    test1,
    test2,
    test3,
    test4,
    test5,
    test6.

test1 :- '->'(true, true), write('ok 1'), nl.
test1 :- write('not ok 1'), nl.

test2 :- ->(true, fail), write('not ok 2'), nl.
test2 :- write('ok 2'), nl.

test3 :- ->(fail, true), write('not ok 3'), nl.
test3 :- write('ok 3'), nl.

test4 :- ->(true, X = 1), X = 1, write('ok 4'), nl.
test4 :- write('not ok 4'), nl.

test5 :- ->(;(X = 1, X = 2), true), (X = 1, write('ok 5'), nl, fail ; X = 2, write('not ok 6'), nl).
test5 :- write('ok 6'), nl.

test6 :- ->(true, ;(X = 1, X = 2)), (X = 1, write('ok 7'), nl, fail ; X = 2, write('ok 8'), nl).
test6 :- write('not ok 8'), nl.

% vim:filetype=prolog
