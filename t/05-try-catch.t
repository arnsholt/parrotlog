main :- write('1..2'), nl,
    test1,
    test2.

test1 :- catch(throw(foo), foo, (write('ok 1'), nl)).
test2 :-
    catch(
        catch(throw(foo), bar, (write('not ok 2'), nl)),
    foo, (write('ok 2'), nl)).

% vim:filetype=prolog
