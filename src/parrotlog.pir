.HLL 'Parrotlog'

.namespace []

.sub '' :anon :load :init
    load_bytecode 'HLL.pbc'

    .local pmc hllns, parrotns, imports
    hllns = get_hll_namespace
    parrotns = get_root_namespace ['parrot']
    imports = split ' ', 'PAST PCT HLL Regex Hash'
    parrotns.'export_to'(hllns, imports)
.end

# Non-deterministic search. Choose an element from a list of options, with the
# option to backtrack if it turns out it was an invalid value.
.sub 'choose'
    .param pmc paths
    .param pmc options :slurpy
    .local pmc cc
    .local pmc chosen

    #say paths

    # If we have no options to choose from a previous search has failed.
    if options goto got_options
    'fail'(paths)
  got_options:
    chosen = shift options

    # Create a continuation for our current state and save it on the stack of
    # active choice points.
    cc = new 'Continuation'
    set_addr cc, recurse
    push paths, cc

    .return (chosen)

  recurse:
    .tailcall 'choose'(paths, options :flat)
.end

# Signal that choose() has picked an invalid element, and invoke the saved
# continuation.
.sub 'fail'
    .param pmc paths
    .local pmc cc

    cc = pop paths

  call_cc:
    cc()
.end

# Create a new stack to backtrack over. This makes which continuations belong
# to which group explicit when we nest things (e.g. for finall/3 and friends).
.sub 'paths'
    .local pmc cc
    .local pmc stack

    cc = new 'Continuation'
    set_addr cc, final_failure

    stack = new 'ResizablePMCArray'
    push stack, cc

    .return (stack)

  final_failure:
    .return ()
.end

# Set the mark up to which cut() should prune. We use the sub ref to fail() as
# the mark, so that fail doesn't have to be modified. Whenever fail() happens
# upon a mark, it will simply result in a recursive call to itself, which will
# call the next continuation on the stack.
.sub 'mark'
    .param pmc paths
    .local pmc fail_cc

    fail_cc = get_global 'fail'
    push paths, fail_cc
.end

# Prune the search tree up to the mark.
.sub cut
    .param pmc paths
    .local pmc cc
    .local pmc fail_cc

    fail_cc = get_global 'fail'

  loop:
    cc = pop paths
    $I0 = issame cc, fail_cc
    if $I0 goto done
    goto loop
  done:
.end

# TODO: Implement mark() and cut().

.include 'src/gen/parrotlog-grammar.pir'
.include 'src/gen/parrotlog-actions.pir'
.include 'src/gen/parrotlog-compiler.pir'
.include 'src/gen/parrotlog-runtime.pir'

# To make it easy to test bits and pieces of the implementation, I cheat.
# MAIN() is defined in Runtime.pm does the various bits of testing.
.namespace []
.sub 'main' :main
    .param pmc args

    #$P0 = compreg 'Parrotlog'
    ## Cannot tailcall here. (TT #1029)
    #$P1 = $P0.'command_line'(args)
    #.return ($P1)

    'MAIN'()
    .return ()
.end
