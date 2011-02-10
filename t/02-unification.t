main :- write('1..5'), nl,
        test1,
        test2(foo),
        test3,
        test4,
        test5.

test1 :- foo(bar), ok.
test1 :- ok.
foo(blech) :- write('not ').
ok :- write('ok 1 - bar \\= blech'), nl.

test2(bar) :- write('not ').
test2(_) :- write('ok 2 - bad arguments cause backtracking'), nl.

test3 :- bar(foo), write('ok 3 - unification inside procedure'), nl.
bar(X) :- X = foo.
bar(_) :- write('not ').

test4 :- (1 = '1', write('not '); true), write('ok 4 - difference of integers and atoms'), nl.
test5 :- (1.0 = '1.0', write('not '); true), write('ok 5 - difference of floats and atoms'), nl.

% vim:filetype=prolog
