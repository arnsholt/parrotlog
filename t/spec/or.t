main :- write('1..5'), nl,
    test1,
    test2,
    test3,
    test4,
    test5.

% [';'(true, fail), success].
test1 :- ';'(true, fail), write('ok 1'), nl.

% [';'((!, fail), true), failure].
test2 :- ';'((!, fail), true), write('not ok 2'), nl.
test2 :- write('ok 2'), nl.

% [';'(!, call(3)), success].
test3 :- ';'(!, call(3)), write('ok 3'), nl.

% [';'((X=1, !), X=2), [[X <-- 1]]].
test4 :- ';'((X=1, !), X=2), (X = 1, write('ok 4'), nl, fail ; X = 2, write('not ok 5'), nl).
test4 :- write('ok 5').

% [';'(X=1, X=2), [[X <-- 1], [X <-- 2]]].
test5 :- ';'(X=1, X=2), (X = 1).
test5 :- ';'(X=1, X=2), (X = 1, write('ok 6'), nl, fail ; X = 2, write('ok 7'), nl).
test5 :- write('not ok 7').
