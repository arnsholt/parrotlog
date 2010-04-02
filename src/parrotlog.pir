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

    # If we have no options to choose from a previous search has failed.
    if options goto got_options
    'fail'()
  got_options:
    chosen = shift options

    # Create a continuation for our current state and save it on the stack of
    # active choice points.
    cc = new 'Continuation'
    set_addr cc, recurse
    push paths, cc

    say chosen
    .return (chosen)

  recurse:
    .tailcall 'choose'(options :flat)
.end

# Signal that choose() has picked an invalid element, and invoke the saved
# continuation.
.sub 'fail'
    .param pmc paths
    .local pmc cc

    cc = shift paths

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
