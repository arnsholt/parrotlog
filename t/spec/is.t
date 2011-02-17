main :- write('1..6'), nl,
    test1,
    test2,
    test3,
    test4,
    test5,
    test6.

%['is'(Result,3 + 11.0),[[Result <-- 14.0]]].
test1 :- 'is'(Result,3 + 11.0),
    (Result = 14.0, write('ok 1'), nl
    ; write('not ok 1 - expected 14.0, got '), write(Result), write('# TODO'), nl).

%[(X = 1 + 2, 'is'(Y, X * 3)),[[X <-- (1 + 2), Y <-- 9]]]. % error? 1+2
test2 :- (X = 1 + 2, 'is'(Y, X * 3)), X = (1+2), Y = 9, write('ok 2'), nl.
test2 :- write('not ok 2'), nl.

%['is'(foo,77), failure]. % error? foo
test3 :- 'is'(foo,77), write('not ok 3'), nl.
test3 :- write('ok 3'), nl.

%['is'(77, N), instantiation_error].
test4 :- catch('is'(77, N), X, instantiation_error(X)).

%['is'(77, foo), type_error(evaluable, foo/0)].
test5 :- catch('is'(77, foo), X, type_error(X, evaluable, _)).

%['is'(X,float(3)),[[X <-- 3.0]]].
%test6 :- 'is'(X,float(3)),
%    (X = 3.0, write('ok 6'), nl
%    ; write('not ok 6 - expected 3.0, got '), write(X), nl).
test6 :- write('ok 6 # SKIP: float/1 not implemented'), nl.

instantiation_error(error(instantiation_error, _)) :- write('ok'), nl.
instantiation_error(E) :- write('not ok - got '), write(E),
    write('; expected '), write(error(instantiation_error, _)), nl.

type_error(error(type_error(Type,Culprit), _), Type, Culprit) :- write('ok'), nl.
type_error(E, Type, Culprit) :- write('not ok - got '), write(E),
    write('; expected '), write(error(type_error(Type,Culprit), _)), nl.

% vim:filetype=prolog
