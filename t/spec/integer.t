main :- write('1..5'), nl,
    test1,
    test2,
    test3,
    test4,
    test5.

% [integer(3), success].
test1 :- integer(3), write('ok 1'), nl.
test1 :- write('not ok 1'), nl.

% [integer(-3), success].
test2 :- integer(-3), write('ok 2'), nl.
test2 :- write('not ok 2'), nl.

% [integer(3.3), failure].
test3 :- integer(3.3), write('not ok 3'), nl.
test3 :- write('ok 3'), nl.

% [integer(X), failure].
test4 :- integer(X), write('not ok 4'), nl.
test4 :- write('ok 4'), nl.

% [integer(atom), failure].
test5 :- integer(atom), write('not ok 5'), nl.
test5 :- write('ok 5'), nl.
