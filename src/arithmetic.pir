.HLL 'parrotlog'
.namespace []
.sub 'is/2'
    .param pmc paths
    .param pmc lhs
    .param pmc rhs

    $P0 = get_root_global ['_parrotlog'], 'eval_arith'
    rhs = $P0(rhs)

    $I0 = isa rhs, 'Float'
    if $I0, float
    $P0 = get_root_global ['_parrotlog'], 'Int'
    goto create
  float:
    $P0 = get_root_global ['_parrotlog'], 'Float'
  create:
    rhs = $P0.'create'(rhs)


    .tailcall '=/2'(paths, lhs, rhs)
.end

.HLL '_parrotlog'
.namespace []

.sub 'eval_arith'
    .param pmc term

    # Used to set arguments for type_error:
    .local pmc type
    .local pmc culprit

    $P0 = get_global 'Variable'
    $I0 = $P0.'ACCEPTS'(term)
    unless $I0, nonvar
    $I0 = term.'bound'()
    unless $I0, instantiation_error
    term = term.'value'()

  nonvar:
    $P0 = get_global 'Term'
    $I0 = $P0.'ACCEPTS'(term)
    unless $I0, nonterm
    $I0 = term.'arity'()
    $S0 = term.'functor'()
    # There are no evaluable functors with arity not equal to 1 or 2.
    if $I0 == 1 goto unary
    if $I0 == 2 goto binary
    goto not_evaluable

  # Section 9.1.1, Evaluable functors and operations
  # Section 9.3, Other arithmetic functors
  # Section 9.4, Logical functors
  unary:
    $P1 = term.'args'()
    $P1 = $P1[0]
    $P1 = 'eval_arith'($P1)

  neg:
    unless $S0 == '-' goto abs
    $P1 = neg $P1
    .return ($P1)

  abs:
    unless $S0 == 'abs' goto not_evaluable
    $P1 = abs $P1
    .return ($P1)

    # sqrt/1
    # sign/1
    # float_integer_part/1
    # float_fractional_part/1
    # float/1
    # floor/1
    # truncate/1
    # round/1
    # ceiling/1

  binary:
    $P1 = term.'args'()
    $P2 = $P1[1]
    $P1 = $P1[0]
    $P1 = 'eval_arith'($P1)
    $P2 = 'eval_arith'($P2)

  add:
    unless $S0 == '+' goto subtract
    $P1 = $P1 + $P2
    .return ($P1)

  subtract:
    unless $S0 == '-' goto multiply
    $P1 = $P1 - $P2
    .return ($P1)

  multiply:
    unless $S0 == '*' goto divide
    $P1 = $P1 * $P2
    .return ($P1)

  divide:
    unless $S0 == '/' goto intdiv
    # Coerce the values to nums so that we get floating point division in the
    # case where both values are integers.
    $N1 = $P1
    $N2 = $P2
    $N1 = $N1 / $N2
    $P1 = box $N1
    .return ($P1)

  intdiv:
    unless $S0 == '//' goto rem
    $I0 = isa $P1, 'Integer'
    if $I0 goto intdiv_check2
    $P0 = get_global 'Float'
    type = box 'integer'
    culprit = $P0.'create'($P1)
    goto type_error
  intdiv_check2:
    $I0 = isa $P2, 'Integer'
    if $I0 goto do_intdiv
    $P0 = get_global 'Float'
    type = box 'integer'
    culprit = $P0.'create'($P2)
    goto type_error
  do_intdiv:
    $P1 = $P1 / $P2
    .return ($P1)

  rem:
    unless $S0 == 'rem' goto mod
    $I0 = isa $P1, 'Integer'
    if $I0 goto intdiv_check2
    $P0 = get_global 'Float'
    type = box 'integer'
    culprit = $P0.'create'($P1)
    goto type_error
  rem_check2:
    $I0 = isa $P2, 'Integer'
    if $I0 goto do_intdiv
    $P0 = get_global 'Float'
    type = box 'integer'
    culprit = $P0.'create'($P2)
    goto type_error
  do_rem:
    $I1 = $P1
    $I2 = $P2
    $I3 = mod $I1, $I2
    $I3 = $I3 * $I2
    $I1 = $I1 - $I3
    $P1 = box $I1
    .return ($P1)

  mod:
    unless $S0 == 'mod' goto not_evaluable
    $I0 = isa $P1, 'Integer'
    if $I0 goto intdiv_check2
    $P0 = get_global 'Float'
    type = box 'integer'
    culprit = $P0.'create'($P1)
    goto type_error
  mod_check2:
    $I0 = isa $P2, 'Integer'
    if $I0 goto do_intdiv
    $P0 = get_global 'Float'
    type = box 'integer'
    culprit = $P0.'create'($P2)
    goto type_error
  do_mod:
    $P1 = mod $P1, $P2
    .return ($P1)
    # float_truncate/2
    # float_round/2

  nonterm:
    term = term.'value'()
    .return (term)

  instantiation_error:
    # TODO: Throw an exception.
  type_error:
    $P0 = get_global 'Term'
    type = $P0.'from_data'(type)
    $P0 = $P0.'from_data'('type_error', type, culprit)
    .tailcall 'error'($P0)
  not_evaluable:
    type = box 'not_evaluable'
    culprit = term
    goto type_error
.end
