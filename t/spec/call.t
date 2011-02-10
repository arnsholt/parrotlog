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
test5 :- write('not ok 5 # TODO: Error reporting'), nl.

% [call((write(3), call(1))), type_error(callable,1)].
test6 :- write('not ok 6 # TODO: Error reporting'), nl.

% [call(X), instantiation_error].
test7 :- write('not ok 7 # TODO: Error reporting'), nl.

% [call(1), type_error(callable,1)].
test8 :- write('not ok 8 # TODO: Error reporting'), nl.

% [call((fail, 1)), type_error(callable,(fail,1))].
test9 :- write('not ok 9 # TODO: Error reporting'), nl.

% [call((write(3), 1)), type_error(callable,(write(3), 1))].
test10 :- write('not ok 10 # TODO: Error reporting'), nl.

% [call((1; true)), type_error(callable,(1; true))].
test11 :- write('not ok 11 # TODO: Error reporting'), nl.
