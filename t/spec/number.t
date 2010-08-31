main :- write('1..5'), nl,
    test1,
    test2,
    test3,
    test4,
    test5.

% [number(3), success].
test1 :- number(3), write('ok 1'), nl.
test1 :- write('not ok 1'), nl.

% [number(3.3), success].
test2 :- number(3.3), write('ok 2'), nl.
test2 :- write('not ok 2'), nl.

% [number(-3), success].
test3 :- number(-3), write('ok 3'), nl.
test3 :- write('not ok 3'), nl.

% [number(a), failure].
test4 :- number(a), write('not ok 4'), nl.
test4 :- write('ok 4'), nl.

% [number(X), failure].
test5 :- number(X), write('not ok 5'), nl.
test5 :- write('ok 5'), nl.
