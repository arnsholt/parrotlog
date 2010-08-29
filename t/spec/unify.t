main :- write('1..11'), nl,
    test1,
    test2,
    test3,
    test4,
    test5,
    test6,
    test7,
    test8,
    test9,
    test10,
    test11.

% ['='(1,1), success].
test1 :- '='(1,1), write('ok 1'), nl.
test1 :- write('not ok 1'), nl.

% ['='(X,1),[[X <-- 1]]].
test2 :- '='(X,1), X = 1, write('ok 2'), nl.
test2 :- write('not ok 2'), nl.

% ['='(X,Y),[[Y <-- X]]].
test3 :- '='(X,Y), X = Y, write('ok 3'), nl.
test3 :- write('not ok 3'), nl.

% [('='(X,Y),'='(X,abc)),[[X <-- abc, Y <-- abc]]].
test4 :- ('='(X,Y),'='(X,abc)), X = abc, Y = abc, write('ok 4'), nl.
test4 :- write('not ok 4'), nl.

% ['='(f(X,def),f(def,Y)), [[X <-- def, Y <-- def]]].
test5 :- '='(f(X,def),f(def,Y)), X = def, Y = def, write('ok 5'), nl.
test5 :- write('not ok 5'), nl.

% ['='(1,2), failure].
test6 :- '='(1,2), write('not ok 6'), nl.
test6 :- write('ok 6'), nl.

% ['='(1,1.0), failure].
test7 :- '='(1,1.0), write('not ok 7'), nl.
test7 :- write('ok 7'), nl.

% ['='(g(X),f(f(X))), failure].
test8 :- '='(g(X),f(f(X))), write('not ok 8'), nl.
test8 :- write('ok 8'), nl.

% ['='(f(X,1),f(a(X))), failure].
test9 :- '='(f(X,1),f(a(X))), write('not ok 9'), nl.
test9 :- write('ok 9'), nl.

% ['='(f(X,Y,X),f(a(X),a(Y),Y,2)), failure].
test10 :- '='(f(X,Y,X),f(a(X),a(Y),Y,2)), write('not ok 10'), nl.
test10 :- write('ok 10'), nl.

% ['='(f(A,B,C),f(g(B,B),g(C,C),g(D,D))),
%         [[A <-- g(g(g(D,D),g(D,D)),g(g(D,D),g(D,D))),
%           B <-- g(g(D,D),g(D,D)),
%           C <-- g(D,D)]]].
test11 :- '='(f(A,B,C),f(g(B,B),g(C,C),g(D,D))),
    A  = g(g(g(D,D),g(D,D)),g(g(D,D),g(D,D))),
    B  = g(g(D,D),g(D,D)),
    C  = g(D,D),
    write('ok 11'), nl.
test11 :- write('not ok 11'), nl.
