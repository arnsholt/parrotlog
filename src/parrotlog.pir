.HLL 'parrotlog'
.namespace []

.sub 'write/1'
    .param pmc paths
    .param pmc term

    $S0 = term.'output'()
    print $S0

    .return (paths)
.end

.sub 'nl/0'
    .param pmc paths

    print "\n"

    .return (paths)
.end

.sub '=/2'
    .param pmc paths
    .param pmc lhs
    .param pmc rhs

    $P0 = get_root_global ['_parrotlog'], 'unify'
    $P0(paths, lhs, rhs)

    .return (paths)
.end

.sub '\=/2'
    .param pmc paths
    .param pmc lhs
    .param pmc rhs

    $P0 = get_root_global ['_parrotlog'], 'choicepoint'
    $P0 = $P0(paths)
    $I0 = isnull $P0
    if $I0, failure

    $P1 = get_root_global ['_parrotlog'], 'unify'
    $P2 = get_root_global ['_parrotlog'], 'fail'
    $P1($P0, lhs, rhs)
    $P2(paths)

  failure:
    .return (paths)
.end

.include 'src/arithmetic.pir'
.include 'src/types.pir'

.HLL '_parrotlog'
.namespace []
.sub 'error'
    .param pmc term
    .param pmc impldef     :optional
    .param int has_impldef :opt_flag

    $P0 = get_global 'Term'
    if has_impldef goto have_impldef
    impldef = $P0.'from_data'('')
    # TODO: Set some reasonable value for impldef here.
  have_impldef:
    $P0 = $P0.'from_data'('error', term, impldef)
    $S0 = $P0.'output'()

    $P1 = new 'Exception'
    $P1['payload'] = $P0
    throw $P1

    .return ()
.end

.sub '' :anon :load :init
    load_bytecode 'HLL.pbc'

    .local pmc hllns, parrotns, imports
    hllns = get_hll_namespace
    parrotns = get_root_namespace ['parrot']
    imports = split ' ', 'PAST PCT HLL Regex Hash'
    parrotns.'export_to'(hllns, imports)

    $P0 = newclass 'Cons'
    addattribute $P0, 'car'
    addattribute $P0, 'cdr'
.end

.sub 'call'
    .param pmc origpaths
    .param pmc var

    $I0 = var.'bound'()
    if $I0, bound

    $P0 = get_root_global ['_parrotlog'], 'Term'
    $P1 = $P0.'from_data'('instantiation_error')
    $P1 = $P0.'from_data'('error', $P1, $P1)
    $P2 = new 'Exception'
    $P2['payload'] = $P1
    throw $P2

  bound:
    var = var.'value'()

    .local string functor
    .local string arity
    .local pmc args

    functor = var.'functor'()
    arity = var.'arity'()
    args = var.'args'()

    $S0 = functor . "/"
    $S0 = $S0 . arity
    $P0 = get_root_global ['parrotlog'], $S0
    $P0(origpaths, args :flat)
.end

# Non-deterministic search. Choose an element from a list of options, with the
# option to backtrack if it turns out it was an invalid value.
# XXX: This should be moved to Coretest, as it's only used there.
.sub 'choose'
    .param pmc paths
    .param pmc options :slurpy
    .local pmc cc
    .local pmc chosen

    # If we have no options to choose from a previous search has failed.
    if options goto got_options
    'fail'(paths)
  got_options:
    chosen = shift options

    $P0 = 'choicepoint'(paths)
    $I0 = isnull $P0
    if $I0 goto recurse

    .return (chosen, $P0)

  recurse:
    .tailcall 'choose'(paths, options :flat)
.end

# Signal that choose() has picked an invalid element, and invoke the saved
# continuation.
.sub 'fail'
    .param pmc paths
    .local pmc cc
    .local pmc rest

    cc = getattribute paths, 'car'
    rest = getattribute paths, 'cdr'

    # Parrot continuations don't take arguments, but fail (which serves as the
    # mark) -does-, so we have to supply the argument in order to not fail
    # when backtracking over the mark.
    .tailcall cc(rest)
.end

# Create a new stack to backtrack over. This makes which continuations belong
# to which group explicit when we nest things (e.g. for finall/3 and friends).
.sub 'paths'
    .local pmc cc
    .local pmc stack

    stack = 'choicepoint'(stack)
    $I0 = isnull stack
    if $I0 goto final_failure

    .return (stack)

  final_failure:
    null $P0
    .return ($P0)
.end

# Store a choicepoint on the stack. Returns 0 on initial call, 1 when
# backtracking.
.sub 'choicepoint'
    .param pmc paths
    .local pmc cc

    cc = new 'Continuation'
    set_addr cc, failure
    $P0 = new 'Cons'
    setattribute $P0, 'car', cc
    setattribute $P0, 'cdr', paths

    .return ($P0)
  failure:
    null $P0
    .return ($P0)
.end

# Set the mark up to which cut() should prune. We use the sub ref to fail() as
# the mark, so that fail doesn't have to be modified. Whenever fail() happens
# upon a mark, it will simply result in a recursive call to itself, which will
# call the next continuation on the stack.
# XXX: This should be moved to Coretest, as it's only used there.
.sub 'mark'
    .param pmc paths
    .local pmc fail_cc

    fail_cc = get_global 'fail'
    $P0 = new 'Cons'
    setattribute $P0, 'car', fail_cc
    setattribute $P0, 'cdr', paths

    .return ($P0)
.end

# Prune the search tree up to the mark.
# XXX: This should be moved to Coretest, as it's only used there.
.sub 'cut'
    .param pmc paths
    .local pmc cc
    .local pmc fail_cc

    fail_cc = get_global 'fail'

  # Pop elements off the stack until we find a mark.
  loop:
    cc = getattribute paths, 'car'
    paths = getattribute paths, 'cdr'
    $I0 = issame cc, fail_cc
    unless $I0 goto loop

    .return (paths)
.end

.include 'src/gen/parrotlog-grammar.pir'
.include 'src/gen/parrotlog-actions.pir'
.include 'src/gen/parrotlog-compiler.pir'
.include 'src/gen/parrotlog-runtime.pir'
.include 'src/gen/parrotlog-coretest.pir'
.include 'src/gen/parrotlog-term.pir'

.namespace []
.sub 'main' :main
    .param pmc args

    $P0 = compreg 'Parrotlog'
    # Cannot tailcall here. (TT #1029)
    $P1 = $P0.'command_line'(args)
    .return ($P1)

    .local pmc coretest

    coretest = get_hll_global ['Coretest'], 'coretest'
    coretest()

    .return ()
.end
