main :- write('1..6'), nl,
    test1,
    test2,
    test3,
    test4,
    test5,
    test6.

% [atomic(atom), success].
test1 :- atomic(atom), write('ok 1'), nl.
test1 :- write('not ok 1'), nl.

% [atomic(a(b)), failure].
test2 :- atomic(a(b)), write('not ok 2'), nl.
test2 :- write('ok 2'), nl.

% [atomic(Var), failure].
test3 :- atomic(Var), write('not ok 3'), nl.
test3 :- write('ok 3'), nl.

% [atomic([]), success].
test4 :- atomic([]), write('ok 4'), nl.
test4 :- write('not ok 4'), nl.

% [atomic(6), success].
test5 :- atomic(6), write('ok 5'), nl.
test5 :- write('not ok 5'), nl.

% [atomic(3.3), success].
test6 :- atomic(3.3), write('ok 6'), nl.
test6 :- write('not ok 6'), nl.

% vim:filetype=prolog
