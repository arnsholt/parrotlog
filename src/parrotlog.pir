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
