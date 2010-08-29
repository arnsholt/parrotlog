main :- write('1..7'), nl,
    test1,
    test2,
    test3,
    test4,
    test5,
    test6,
    test7.

% [compound(33.3), failure].
test1 :- compound(33.3), write('not ok 1'), nl.
test1 :- write('ok 1'), nl.

% [compound(-33.3), failure].
test2 :- compound(-33.3), write('not ok 2'), nl.
test2 :- write('ok 2'), nl.

% [compound(-a), success].
test3 :- compound(-a), write('ok 3'), nl.
test3 :- write('not ok 3'), nl.

% [compound(_), failure].
test4 :- compound(_), write('not ok 4'), nl.
test4 :- write('ok 4'), nl.

% [compound(a), failure].
test5 :- compound(a), write('not ok 5'), nl.
test5 :- write('ok 5'), nl.

% [compound(a(b)), success].
test6 :- compound(a(b)), write('ok 6'), nl.
test6 :- write('not ok 6'), nl.

% [compound([a]),success].
test7 :- compound([a]), write('ok 7'), nl.
test7 :- write('not ok 7'), nl.
