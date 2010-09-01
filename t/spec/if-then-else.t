main :- write('1..10'), nl,
    test1,
    test2,
    test3,
    test4,
    test5,
    test6,
    test7,
    test8.

% [';'('->'(true, true), fail), success].
test1 :- ';'('->'(true, true), fail), write('ok 1'), nl.
test1 :- write('not ok 1'), nl.

% [';'('->'(fail, true), true), success].
test2 :- ';'('->'(fail, true), true), write('ok 2'), nl.
test2 :- write('not ok 2'), nl.

% [';'('->'(true, fail), fail), failure].
test3 :- ';'('->'(true, fail), fail), write('not ok 3'), nl.
test3 :- write('ok 3'), nl.

% [';'('->'(fail, true), fail), failure].
test4 :- ';'('->'(fail, true), fail), write('not ok 4'), nl.
test4 :- write('ok 4'), nl.

% [';'('->'(true, X=1), X=2), [[X <-- 1]]].
test5 :- ';'('->'(true, X=1), X=2), X = 1, write('ok 5'), nl.
test5 :- write('not ok 5'), nl.

% [';'('->'(fail, X=1), X=2), [[X <-- 2]]].
test6 :- ';'('->'(fail, X=1), X=2), X = 2, write('ok 6'), nl.
test6 :- write('not ok 6'), nl.

% [';'('->'(true, ';'(X=1, X=2)), true), [[X <-- 1], [X <-- 2]]].
test7 :- ';'('->'(true, ';'(X=1, X=2)), true), (X = 1, write('ok 7'), nl, fail; X = 2, write('ok 8'), nl).
test7 :- write('not ok 8'), nl.

% [';'('->'(';'(X=1, X=2), true), true), [[X <-- 1]]].
test8 :- ';'('->'(';'(X=1, X=2), true), true), (X = 1, write('ok 9'), nl, fail; X = 2, write('not ok 10'), nl).
test8 :- write('ok 10'), nl.
