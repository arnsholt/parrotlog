# Section 8.3, Type testing

# Section 8.3.1, var/1
.sub 'var/1'
    .param pmc paths
    .param pmc var

    $P0 = get_root_global ['_parrotlog'], 'Variable'
    $I0 = $P0.'ACCEPTS'(var)
    unless $I0, fail
    $I0 = var.'bound'()
    if $I0, fail
    .return (paths)
  fail:
    $P0 = get_root_global ['_parrotlog'], 'fail'
    $P0(paths)
.end

# Section 8.3.2, atom/1
.sub 'atom/1'
    .param pmc paths
    .param pmc var

    $P0 = get_root_global ['_parrotlog'], 'Variable'
    $I0 = $P0.'ACCEPTS'(var)
    unless $I0, nonvar
    $I0 = var.'bound'()
    unless $I0, fail
    var = var.'value'()

  nonvar:
    $P0 = get_root_global ['_parrotlog'], 'Term'
    $I0 = $P0.'ACCEPTS'(var)
    unless $I0, fail
    $I0 = var.'arity'()
    unless $I0 == 0 goto fail
    .return (paths)
  fail:
    $P0 = get_root_global ['_parrotlog'], 'fail'
    $P0(paths)
.end

# Section 8.3.3, integer/1
.sub 'integer/1'
    .param pmc paths
    .param pmc var

    $P0 = get_root_global ['_parrotlog'], 'Variable'
    $I0 = $P0.'ACCEPTS'(var)
    unless $I0, nonvar
    $I0 = var.'bound'()
    unless $I0, fail
    var = var.'value'()

  nonvar:
    $P0 = get_root_global ['_parrotlog'], 'Int'
    $I0 = $P0.'ACCEPTS'(var)
    unless $I0, fail
    .return (paths)
  fail:
    $P0 = get_root_global ['_parrotlog'], 'fail'
    $P0(paths)
.end

# Section 8.3.4, real/1
# XXX: The draft standard calls this real/1, while inriasuite calls it
# float/1. Must investigate.
.sub 'float/1'
    .param pmc paths
    .param pmc var

    $P0 = get_root_global ['_parrotlog'], 'Variable'
    $I0 = $P0.'ACCEPTS'(var)
    unless $I0, nonvar
    $I0 = var.'bound'()
    unless $I0, fail
    var = var.'value'()

  nonvar:
    $P0 = get_root_global ['_parrotlog'], 'Float'
    $I0 = $P0.'ACCEPTS'(var)
    unless $I0, fail
    .return (paths)
  fail:
    $P0 = get_root_global ['_parrotlog'], 'fail'
    $P0(paths)
.end

# Section 8.3.5, atomic/1
# Section 8.3.6, compound/1
.sub 'compound/1'
    .param pmc paths
    .param pmc var

    $P0 = get_root_global ['_parrotlog'], 'Variable'
    $I0 = $P0.'ACCEPTS'(var)
    unless $I0, nonvar
    $I0 = var.'bound'()
    unless $I0, fail
    var = var.'value'()

  nonvar:
    $P0 = get_root_global ['_parrotlog'], 'Term'
    $I0 = $P0.'ACCEPTS'(var)
    unless $I0, fail
    $I0 = var.'arity'()
    unless $I0 > 0 goto fail
    .return (paths)
  fail:
    $P0 = get_root_global ['_parrotlog'], 'fail'
    $P0(paths)
.end

# Section 8.3.7, nonvar/1
# Section 8.3.8, number/1
