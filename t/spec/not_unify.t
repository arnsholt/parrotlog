main :- write('1..10'), nl,
    test1,
    test2,
    test3,
    test4,
    test5,
    test6,
    test7,
    test8,
    test9,
    test10.

% ['\\='(1,1), failure].
test1 :- '\\='(1,1), write('not ok 1'), nl.
test1 :- write('ok 1'), nl.

% ['\\='(X,1), failure].
test2 :- '\\='(X,1), write('not ok 2'), nl.
test2 :- write('ok 2'), nl.

% ['\\='(X,Y), failure].
test3 :- '\\='(X,Y), write('not ok 3'), nl.
test3 :- write('ok 3'), nl.

% [('\\='(X,Y),'\\='(X,abc)), failure].
test4 :- ('\\='(1,1),'\\='(X,abc)), write('not ok 4'), nl.
test4 :- write('ok 4'), nl.

% ['\\='(f(X,def),f(def,Y)), failure].
test5 :- '\\='(f(X,def),f(def,Y)), write('not ok 5'), nl.
test5 :- write('ok 5'), nl.

% ['\\='(1,2), success].
test6 :- '\\='(1,2), write('ok 6'), nl.
test6 :- write('not ok 6'), nl.

% ['\\='(1,1.0), success].
test7 :- '\\='(1,1.0), write('ok 7'), nl.
test7 :- write('not ok 7'), nl.

% ['\\='(g(X),f(f(X))), success].
test8 :- '\\='(g(X),f(f(X))), write('ok 8'), nl.
test8 :- write('not ok 8'), nl.

% ['\\='(f(X,1),f(a(X))), success].
test9 :- '\\='(f(X,1),f(a(X))), write('ok 9'), nl.
test9 :- write('not ok 9'), nl.

% ['\\='(f(X,Y,X),f(a(X),a(Y),Y,2)), success].
test10 :- '\\='(f(X,Y,X),f(a(X),a(Y),Y,2)), write('ok 10'), nl.
test10 :- write('not ok 10'), nl.
