main :- write('1..1'), nl,
        test1.

test1 :- foo(bar), ok.
test1 :- ok.

foo(blech) :- write('not ').
ok :- write('ok 1 - bar \\= blech'), nl.
