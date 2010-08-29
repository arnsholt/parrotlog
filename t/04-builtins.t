main :- write('1..1'), nl,
    test1.

% Test for bug in in atom/1.
test1 :- X = a, atom(X), write('ok 1'), nl.
test1 :- write('not ok 1'), nl.
