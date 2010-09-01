main :- write('1..6'), nl,
        first,
        (second ; true), write('ok 2 - cut eliminates whole call chain'), nl,
        third,
        (fourth ; true), write('ok 6 - cut is effective inside ;/2'), nl.

%first :- fail; write('ok 1 - backtracks on fail/0'), nl.
first :- fail.
first :- write('ok 1 - backtracks on fail/0'), nl.

% Test that cut prunes the search tree all the way to the start of the current
% predicate and ignores any predicates called.
second :- other, !, fail.
second :- write('not ').
other  :- true.

% Check for bug where disjunctions are handled improperly.
third :- (write('ok 3 - disjuntion 1'), nl ; write('ok 4 - disjuntion 2'), nl), fail.
third :- write('ok 5 - fallback'), nl.

% Check for bug where cuts don't propagate outside disjunctions.
fourth :- (true; write('not ')), (! ; true), fail.
