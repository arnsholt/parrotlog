% Hand-converted from and in inriasuite
main :- write('1..5'), nl,
    test1,
    test2,
    test3,
    test4,
    test5.

%[','(X=1, var(X)), failure].
test1 :- ','(X=1, var(X)), write('not ok 1'), nl.
test1 :- write('ok 1'), nl.

%[','(var(X), X=1), [[X <-- 1]]].
test2 :- ','(var(X), X=1), X = 1, write('ok 2'), nl.
test2 :- write('not ok 2'), nl.

%[','(fail, call(3)), failure].
test3 :- ','(fail, call(3)), write('not ok 3'), nl.
test3 :- write('ok 3'), nl.

%[','(nofoo(X), call(X)), existence_error(procedure, nofoo/1)].
test4 :- write('ok 4 # SKIP exception'), nl.

%[','(X = true, call(X)), [[X <-- true]]].
test5 :- ','(X = true, call(X)), X = true, write('ok 5'), nl.
test5 :- write('not ok 5').

% vim:filetype=prolog
