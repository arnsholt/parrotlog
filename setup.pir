#!/usr/bin/env parrot
# $Id$

=head1 NAME

setup.pir - Python distutils style

=head1 DESCRIPTION

No Configure step, no Makefile generated.

=head1 USAGE

    $ parrot setup.pir build
    $ parrot setup.pir test
    $ sudo parrot setup.pir install

=cut

.sub 'main' :main
    .param pmc args
    $S0 = shift args
    load_bytecode 'distutils.pbc'

    .local int reqsvn
    $P0 = open 'PARROT_REVISION', 'r'
    $S0 = readline $P0
    reqsvn = $S0
    close $P0

    .local pmc config
    config = get_config()
    $I0 = config['revision']
    unless reqsvn > $I0 goto L1
    $S1 = "Parrot revision r"
    $S0 = reqsvn
    $S1 .= $S0
    $S1 .= " required (currently r"
    $S0 = $I0
    $S1 .= $S0
    $S1 .= ")\n"
    printerr $S1
    end
  L1:

    $P0 = new 'Hash'
    $P0['name'] = 'parrotlog'
    $P0['abstract'] = 'the parrotlog compiler'
    $P0['description'] = 'the parrotlog for Parrot VM.'

    # build
#    $P1 = new 'Hash'
#    $P1['parrotlog_ops'] = 'src/ops/parrotlog.ops'
#    $P0['dynops'] = $P1

#    $P2 = new 'Hash'
#    $P3 = split ' ', 'src/pmc/parrotlog.pmc'
#    $P2['parrotlog_group'] = $P3
#    $P0['dynpmc'] = $P2

    $P4 = new 'Hash'
    $P4['src/gen_actions.pir'] = 'src/parrotlog/Actions.pm'
    $P4['src/gen_compiler.pir'] = 'src/parrotlog/Compiler.pm'
    $P4['src/gen_grammar.pir'] = 'src/parrotlog/Grammar.pm'
    $P4['src/gen_runtime.pir'] = 'src/parrotlog/Runtime.pm'
    $P0['pir_nqp-rx'] = $P4

    $P5 = new 'Hash'
    $P6 = split "\n", <<'SOURCES'
src/parrotlog.pir
src/gen_actions.pir
src/gen_compiler.pir
src/gen_grammar.pir
src/gen_runtime.pir
SOURCES
    $S0 = pop $P6
    $P5['parrotlog/parrotlog.pbc'] = $P6
    $P5['parrotlog.pbc'] = 'parrotlog.pir'
    $P0['pbc_pir'] = $P5

    $P7 = new 'Hash'
    $P7['parrot-parrotlog'] = 'parrotlog.pbc'
    $P0['installable_pbc'] = $P7

    # test
    $S0 = get_parrot()
    $S0 .= ' parrotlog.pbc'
    $P0['prove_exec'] = $S0

    # install
    $P0['inst_lang'] = 'parrotlog/parrotlog.pbc'

    # dist
    $P0['doc_files'] = 'README'

    .tailcall setup(args :flat, $P0 :flat :named)
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

