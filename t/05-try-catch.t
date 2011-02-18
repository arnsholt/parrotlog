main :- write('1..6'), nl,
    test1,
    test2,
    test3,
    test4,
    test5,
    test6.

test1 :- catch(throw(foo), foo, (write('ok 1'), nl)).
test2 :-
    catch(
        catch(throw(foo), bar, (write('not ok 2'), nl)),
    foo, (write('ok 2'), nl)).
test3 :-
    catch(
        (catch(throw(foo), _, fail); write('ok 3'), nl),
        foo,
        (write('not ok 3'), nl)).

test4 :- (true; write('ok 4'), nl), catch(true, _, true), fail.
test4.

test5 :- catch(
    (catch(throw(foo), _, true), fail; write('ok 5'), nl),
    foo,
    (write('not ok 5'), nl)).

% Check that the exception handler is reinstated on backtracking.
test6 :- catch(
    (catch((true; throw(foo)), foo, (write('ok 6 # TODO'), nl)), fail),
        foo,
        (write('not ok 6 # TODO: Backtracking/exceptions'), nl)).

% vim:filetype=prolog
