.HLL 'parrotlog'

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
    .param pmc options :slurpy
    .local pmc cc
    .local pmc chosen
    .local pmc paths

    # If we have no options to choose from a previous search has failed.
    if options goto got_options
    'fail'()
  got_options:
    chosen = shift options

    # Create a continuation for our current state and save it on the stack of
    # active choice points.
    cc = new 'Continuation'
    set_addr cc, recurse
    paths = get_global '!paths'
    push paths, cc

    say chosen
    .return (chosen)

  recurse:
    .tailcall 'choose'(options :flat)
.end

# Signal that choose() has picked an invalid element, and invoke the saved
# continuation.
.sub 'fail'
    .local pmc cc
    .local pmc paths

    paths = get_global '!paths'

    if paths goto got_paths
    cc = get_global '!topcc'
    goto call_cc
  got_paths:
    cc = shift paths

  call_cc:
    cc()
.end

# TODO: Implement mark() and cut().

.include 'src/gen/parrotlog-grammar.pir'
.include 'src/gen/parrotlog-actions.pir'
.include 'src/gen/parrotlog-compiler.pir'
.include 'src/gen/parrotlog-runtime.pir'

.namespace []
.sub 'main' :main
    .param pmc args

    $P0 = compreg 'parrotlog'
    # Cannot tailcall here. (TT #1029)
    $P1 = $P0.'command_line'(args)
    .return ($P1)
.end
