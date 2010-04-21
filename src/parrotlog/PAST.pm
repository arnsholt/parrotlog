sub make_past($ast) {
    if $ast ~~ Variable {
        pir::say("Can't make AST for a Variable!");
    }
    elsif $ast ~~ Term {
=begin workflow

This'll have to be dispatched on the basis of the top-level functor of the
term. For now, we're parsing queries (not actual programs) so I think the way
to do it is to work recursively. If the functor is =, set up the environment
with the necessary parameters, and then call unify. If it's , do make_ast() on
the lhs first, then on the rhs.

=end workflow
        if $ast.functor eq '=' {
            # Set up call to unify().
            pir::say("unification");
        }
        elsif $ast.functor eq ',' {
            # Create ast for lhs first, then for rhs (with lhs as outer
            # scope).
            pir::say("conjunction");
            my $lhs := make_past($ast.args[0]);
            my $rhs := make_past($ast.args[1]);
        }
        else {
            pir::die("Don't know how to handle functor {$ast.functor}");
        }
    }
    else {
        pir::die("Non-Term, non-Variable passed to make_ast()");
    }
}
