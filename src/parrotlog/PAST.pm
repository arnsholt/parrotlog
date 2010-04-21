=begin workflow

First, we set up the outermost context of the query: we create named variables
for all of the named variables used in the query.

Then we recursively traverse the Term representing the query. It might make
sense to create custom PAST types for unification and certain other ops
(subroutine application, certainly) in order to make this code a bit more
legible, seeing how all of these will require additional function calls to set
up the backtracking infrastructure.

=end workflow

=begin selfnotes

- Function calls seem to be created with PAST::Op and pasttype `call'.
- New objects with pasttype `new'?

=end selfnotes

sub make_past($ast) {
    # TODO: First we set up the outer lexical scope by creating all the named
    # variables in the query. Finally we set the mark to stop the pruning in
    # case of a cut.
    my $block := PAST::Block.new(:blocktype<immediate>);
    # For variables in $ast: $block.push(make_variable($varname))

    # Then we process the query as typed in.
    make_conjunction($ast);
}

sub make_unification($ast) {
    # TODO: Set up call to unify().
    pir::say("unification");
}

sub make_conjunction($ast) {
    if $ast ~~ Term {
        if $ast.functor eq '=' && $ast.arity == 2 {
            make_unification($ast);
        }
        elsif $ast.functor eq ',' && $ast.arity == 2 {
            pir::say("conjunction");
            my $lhs := make_conjunction($ast.args[0]);
            my $rhs := make_conjunction($ast.args[1]);
        }
        elsif $ast.functor eq '!' && $ast.arity == 0 {
            make_cut();
        }
        else {
            pir::die("Don't know how to handle {$ast.functor}/{$ast.arity}");
        }
    }
    else {
        pir::die("Non-Term passed to make_ast()");
    }
}

sub make_cut() {
    pir::say("cut");
}

sub make_term($ast) {
}

sub make_variable($ast) {
}
