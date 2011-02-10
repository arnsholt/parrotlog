main :- write('1..3'), nl,
    test1,
    (test2 ; write('ok 2'), nl),
    test3.

% [!, success].
test1 :- !, write('ok 1'), nl.

% [(!,fail;true), failure].
test2 :- (!, fail;true), write('not ok 2'), nl.

% [(call(!),fail;true), success].
test3 :- (call(!),fail;true), write('ok 3'), nl.
test3 :- write('not ok 3'), nl.

% vim:filetype=prolog
