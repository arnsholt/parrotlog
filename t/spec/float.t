main :- write('1..5'), nl,
    test1,
    test2,
    test3,
    test4,
    test5.

% [float(3.3), success].
test1 :- float(3.3), write('ok 1'), nl.
test1 :- write('not ok 1'), nl.

% [float(-3.3), success].
test2 :- float(-3.3), write('ok 2'), nl.
test2 :- write('not ok 2'), nl.

% [float(3), failure].
test3 :- float(3), write('not ok 3'), nl.
test3 :- write('ok 3'), nl.

% [float(atom), failure].
test4 :- float(atom), write('not ok 4'), nl.
test4 :- write('ok 4'), nl.

% [float(X), failure].
test5 :- float(X), write('not ok 5'), nl.
test5 :- write('ok 5'), nl.

% vim:filetype=prolog
