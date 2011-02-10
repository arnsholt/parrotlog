main :- write('1..7'), nl,
    test1,
    test2,
    test3,
    test4,
    test5,
    test6,
    test7.

% [atom(atom), success].
test1 :- atom(atom), write('ok 1'), nl.
test1 :- write('not ok 1'), nl.

% [atom('string'), success].
test2 :- atom('string'), write('ok 2'), nl.
test2 :- write('not ok 2'), nl.

% [atom(a(b)), failure].
test3 :- atom(a(b)), write('not ok 3'), nl.
test3 :- write('ok 3'), nl.

% [atom(Var), failure].
test4 :- atom(Var), write('not ok 4'), nl.
test4 :- write('ok 4'), nl.

% [atom([]), success].
test5 :- atom([]), write('ok 5'), nl.
test5 :- write('not ok 5'), nl.

% [atom(6), failure].
test6 :- atom(6), write('not ok 6'), nl.
test6 :- write('ok 6'), nl.

% [atom(3.3), failure].
test7 :- atom(3.3), write('not ok 7'), nl.
test7 :- write('ok 7'), nl.

% vim:filetype=prolog
