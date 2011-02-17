main :- write('1..4'), nl,
    test1,
    test2,
    test3,
    test4,
    test5.

test1 :- catch(throw(foo), foo, (write('ok 1'), nl)).
test2 :-
    catch(
        catch(throw(foo), bar, (write('not ok 2'), nl)),
    foo, (write('ok 2'), nl)).
test3 :-
    catch(
        (catch(throw(foo), _, fail); write('ok 3'), nl),
        foo,
        (write('not ok 3 # TODO backtracking bug'), nl)).
test4 :- write('ok 4 # SKIP: blows up'), nl.
%test4:- catch(
%    (catch(throw(foo), _, true), fail; write('ok 4'), nl),
%    foo,
%    (write('not ok 4'), nl)).

test5 :- write('ok 5 # SKIP: blows up'), nl.
%test5 :- catch((true; throw(foo)), foo, (write('ok 5'), nl)), fail.
%test5.

% vim:filetype=prolog
