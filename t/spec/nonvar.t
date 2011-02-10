main :- write('1..6'), nl,
    test1,
    test2,
    test3,
    test4,
    test5,
    test6.

% [nonvar(33.3), success].
test1 :- nonvar(33.3), write('ok 1'), nl.
test1 :- write('not ok 1'), nl.

% [nonvar(foo), success].
test2 :- nonvar(foo), write('ok 2'), nl.
test2 :- write('not ok 2'), nl.

% [nonvar(Foo), failure].
test3 :- nonvar(Foo), write('not ok 3'), nl.
test3 :- write('ok 3'), nl.

% [(foo=Foo,nonvar(Foo)),[[Foo <-- foo]]].
test4 :- (foo=Foo,nonvar(Foo)), Foo = foo, write('ok 4'), nl.
test4 :- write('not ok 4'), nl.

% [nonvar(_), failure].
test5 :- nonvar(_), write('not ok 5'), nl.
test5 :- write('ok 5'), nl.

% [nonvar(a(b)), success].
test6 :- nonvar(a(b)), write('ok 6'), nl.
test6 :- write('not ok 6'), nl.

% vim:filetype=prolog
