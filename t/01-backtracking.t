main :- write('1..2'), nl,
        first,
        (second ; true), write('ok 2 - cut eliminates whole call chain #TODO: BUG'), nl.

first :- fail; write('ok 1 - backtracks on fail/0'), nl.

% Test that cut prunes the search tree all the way to the start of the current
% predicate and ignores any predicates called.
second :- other, !, fail.
second :- write('not ').
other  :- true.
