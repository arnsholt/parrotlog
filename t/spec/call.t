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

% [call(!),success].
test1 :- call(!), write('ok 1'), nl.

% [call(fail), failure].
test2 :- call(fail), write('not ok 2'), nl.
test2 :- write('ok 2'), nl.

% [call((fail, X)), failure].
test3 :- call((fail, X)), write('not ok 3'), nl.
test3 :- write('ok 3'), nl.

% [call((fail, call(1))), failure].
test4 :- call((fail, call(1))), write('not ok 4'), nl.
test4 :- write('ok 4'), nl.

% [call((write(3), X)), instantiation_error].
test5 :- catch(call((write('# Writing...'), nl, _)), X, instantiation_error(X)).

% [call((write(3), call(1))), type_error(callable,1)].
test6 :- catch(call((write('# Writing...'), nl, call(1))), X, type_error(X, callable, 1)).

% [call(X), instantiation_error].
test7 :- catch(call(_), X, instantiation_error(X)).

% [call(1), type_error(callable,1)].
test8 :- catch(call(1), X, type_error(X, callable, 1)).

% [call((fail, 1)), type_error(callable,(fail,1))].
test9 :- catch(call((fail, 1)), X, type_error(X, callable, 1)).

% [call((write(3), 1)), type_error(callable,(write(3), 1))].
test10 :- catch(call((write('# Whut?'), nl, 1)), X, type_error(X, callable, 1)).

% [call((1; true)), type_error(callable,(1; true))].
test11 :- catch(call((1; true)), X, type_error(X, callable, 1)).

instantiation_error(error(instantiation_error, _)) :- write('ok'), nl.
instantiation_error(E) :-
    write('not ok # got '),
    write(E),
    write('; expected '),
    write(error(instantiation_error, _)),
    nl.

type_error(error(type_error(Type, Culprit), _), Type, Culprit) :- write('ok'), nl.
type_error(E, Type, Culprit) :-
    write('not ok # got '),
    write(E),
    write('; expected '),
    write(error(type_error(Type, Culprit), _)),
    nl.

% vim:filetype=prolog
