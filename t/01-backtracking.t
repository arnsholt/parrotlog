main :- write('1..2'), first, second.

first :- fail; write('ok 1 - backtracks on fail/0').

% Test that cut prunes the search tree all the way to the start of the current
% predicate and ignores any predicates called.
second :- other, !, fail ; write('ok - cut doesn''t backtrack into subordinate predicate').
other  :- true ; print('not ').
