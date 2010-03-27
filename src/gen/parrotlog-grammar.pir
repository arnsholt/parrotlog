
.namespace []
.sub "_block11"  :anon :subid("10_1269727965.58325")
.annotate "line", 0
    get_hll_global $P14, ["parrotlog";"Grammar"], "_block13" 
    capture_lex $P14
.annotate "line", 9
    get_hll_global $P14, ["parrotlog";"Grammar"], "_block13" 
    capture_lex $P14
    $P148 = $P14()
.annotate "line", 1
    .return ($P148)
.end


.namespace []
.sub "" :load :init :subid("post46") :outer("10_1269727965.58325")
.annotate "line", 0
    .const 'Sub' $P12 = "10_1269727965.58325" 
    .local pmc block
    set block, $P12
    $P149 = get_root_global ["parrot"], "P6metaclass"
    $P149."new_class"("parrotlog::Grammar", "HLL::Grammar" :named("parent"))
.end


.namespace ["parrotlog";"Grammar"]
.sub "_block13"  :subid("11_1269727965.58325") :outer("10_1269727965.58325")
.annotate "line", 9
    .const 'Sub' $P139 = "44_1269727965.58325" 
    capture_lex $P139
    .const 'Sub' $P132 = "42_1269727965.58325" 
    capture_lex $P132
    .const 'Sub' $P125 = "40_1269727965.58325" 
    capture_lex $P125
    .const 'Sub' $P118 = "38_1269727965.58325" 
    capture_lex $P118
    .const 'Sub' $P112 = "36_1269727965.58325" 
    capture_lex $P112
    .const 'Sub' $P107 = "34_1269727965.58325" 
    capture_lex $P107
    .const 'Sub' $P102 = "32_1269727965.58325" 
    capture_lex $P102
    .const 'Sub' $P92 = "28_1269727965.58325" 
    capture_lex $P92
    .const 'Sub' $P86 = "26_1269727965.58325" 
    capture_lex $P86
    .const 'Sub' $P73 = "24_1269727965.58325" 
    capture_lex $P73
    .const 'Sub' $P60 = "22_1269727965.58325" 
    capture_lex $P60
    .const 'Sub' $P46 = "18_1269727965.58325" 
    capture_lex $P46
    .const 'Sub' $P32 = "16_1269727965.58325" 
    capture_lex $P32
    .const 'Sub' $P22 = "14_1269727965.58325" 
    capture_lex $P22
    .const 'Sub' $P15 = "12_1269727965.58325" 
    capture_lex $P15
.annotate "line", 46
    .const 'Sub' $P139 = "44_1269727965.58325" 
    capture_lex $P139
.annotate "line", 9
    .return ($P139)
.end


.namespace ["parrotlog";"Grammar"]
.sub "" :load :init :subid("post47") :outer("11_1269727965.58325")
.annotate "line", 9
    get_hll_global $P14, ["parrotlog";"Grammar"], "_block13" 
    .local pmc block
    set block, $P14
.annotate "line", 47
    get_hll_global $P146, ["parrotlog"], "Grammar"
    $P146."O"(":prec<u>, :assoc<left>", "%multiplicative")
.annotate "line", 48
    get_hll_global $P147, ["parrotlog"], "Grammar"
    $P147."O"(":prec<t>, :assoc<left>", "%additive")
.end


.namespace ["parrotlog";"Grammar"]
.sub "TOP"  :subid("12_1269727965.58325") :method :outer("11_1269727965.58325")
.annotate "line", 9
    .local string rx16_tgt
    .local int rx16_pos
    .local int rx16_off
    .local int rx16_eos
    .local int rx16_rep
    .local pmc rx16_cur
    (rx16_cur, rx16_pos, rx16_tgt) = self."!cursor_start"()
    rx16_cur."!cursor_debug"("START ", "TOP")
    .lex unicode:"$\x{a2}", rx16_cur
    .local pmc match
    .lex "$/", match
    length rx16_eos, rx16_tgt
    set rx16_off, 0
    lt rx16_pos, 2, rx16_start
    sub rx16_off, rx16_pos, 1
    substr rx16_tgt, rx16_tgt, rx16_off
  rx16_start:
    $I10 = self.'from'()
    ne $I10, -1, rxscan20_done
    goto rxscan20_scan
  rxscan20_loop:
    ($P10) = rx16_cur."from"()
    inc $P10
    set rx16_pos, $P10
    ge rx16_pos, rx16_eos, rxscan20_done
  rxscan20_scan:
    set_addr $I10, rxscan20_loop
    rx16_cur."!mark_push"(0, rx16_pos, $I10)
  rxscan20_done:
.annotate "line", 10
  # rx subrule "statementlist" subtype=capture negate=
    rx16_cur."!cursor_pos"(rx16_pos)
    $P10 = rx16_cur."statementlist"()
    unless $P10, rx16_fail
    rx16_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("statementlist")
    rx16_pos = $P10."pos"()
  alt21_0:
.annotate "line", 11
    set_addr $I10, alt21_1
    rx16_cur."!mark_push"(0, rx16_pos, $I10)
  # rxanchor eos
    ne rx16_pos, rx16_eos, rx16_fail
    goto alt21_end
  alt21_1:
  # rx subrule "panic" subtype=method negate=
    rx16_cur."!cursor_pos"(rx16_pos)
    $P10 = rx16_cur."panic"("Syntax error")
    unless $P10, rx16_fail
    rx16_pos = $P10."pos"()
  alt21_end:
.annotate "line", 9
  # rx pass
    rx16_cur."!cursor_pass"(rx16_pos, "TOP")
    rx16_cur."!cursor_debug"("PASS  ", "TOP", " at pos=", rx16_pos)
    .return (rx16_cur)
  rx16_fail:
    (rx16_rep, rx16_pos, $I10, $P10) = rx16_cur."!mark_fail"(0)
    lt rx16_pos, -1, rx16_done
    eq rx16_pos, -1, rx16_fail
    jump $I10
  rx16_done:
    rx16_cur."!cursor_fail"()
    rx16_cur."!cursor_debug"("FAIL  ", "TOP")
    .return (rx16_cur)
    .return ()
.end


.namespace ["parrotlog";"Grammar"]
.sub "!PREFIX__TOP"  :subid("13_1269727965.58325") :method
.annotate "line", 9
    $P18 = self."!PREFIX__!subrule"("statementlist", "")
    new $P19, "ResizablePMCArray"
    push $P19, $P18
    .return ($P19)
.end


.namespace ["parrotlog";"Grammar"]
.sub "ws"  :subid("14_1269727965.58325") :method :outer("11_1269727965.58325")
.annotate "line", 9
    .local string rx23_tgt
    .local int rx23_pos
    .local int rx23_off
    .local int rx23_eos
    .local int rx23_rep
    .local pmc rx23_cur
    (rx23_cur, rx23_pos, rx23_tgt) = self."!cursor_start"()
    rx23_cur."!cursor_debug"("START ", "ws")
    .lex unicode:"$\x{a2}", rx23_cur
    .local pmc match
    .lex "$/", match
    length rx23_eos, rx23_tgt
    set rx23_off, 0
    lt rx23_pos, 2, rx23_start
    sub rx23_off, rx23_pos, 1
    substr rx23_tgt, rx23_tgt, rx23_off
  rx23_start:
    $I10 = self.'from'()
    ne $I10, -1, rxscan26_done
    goto rxscan26_scan
  rxscan26_loop:
    ($P10) = rx23_cur."from"()
    inc $P10
    set rx23_pos, $P10
    ge rx23_pos, rx23_eos, rxscan26_done
  rxscan26_scan:
    set_addr $I10, rxscan26_loop
    rx23_cur."!mark_push"(0, rx23_pos, $I10)
  rxscan26_done:
.annotate "line", 18
  # rx subrule "ww" subtype=zerowidth negate=1
    rx23_cur."!cursor_pos"(rx23_pos)
    $P10 = rx23_cur."ww"()
    if $P10, rx23_fail
.annotate "line", 19
  # rx rxquantr27 ** 0..*
    set_addr $I31, rxquantr27_done
    rx23_cur."!mark_push"(0, rx23_pos, $I31)
  rxquantr27_loop:
  alt28_0:
    set_addr $I10, alt28_1
    rx23_cur."!mark_push"(0, rx23_pos, $I10)
  # rx literal  "#"
    add $I11, rx23_pos, 1
    gt $I11, rx23_eos, rx23_fail
    sub $I11, rx23_pos, rx23_off
    substr $S10, rx23_tgt, $I11, 1
    ne $S10, "#", rx23_fail
    add rx23_pos, 1
  # rx charclass_q N r 0..-1
    sub $I10, rx23_pos, rx23_off
    find_cclass $I11, 4096, rx23_tgt, $I10, rx23_eos
    add rx23_pos, rx23_off, $I11
  # rx rxquantr29 ** 0..1
    set_addr $I30, rxquantr29_done
    rx23_cur."!mark_push"(0, rx23_pos, $I30)
  rxquantr29_loop:
  # rx charclass nl
    ge rx23_pos, rx23_eos, rx23_fail
    sub $I10, rx23_pos, rx23_off
    is_cclass $I11, 4096, rx23_tgt, $I10
    unless $I11, rx23_fail
    substr $S10, rx23_tgt, $I10, 2
    iseq $I11, $S10, "\r\n"
    add rx23_pos, $I11
    inc rx23_pos
    (rx23_rep) = rx23_cur."!mark_commit"($I30)
  rxquantr29_done:
    goto alt28_end
  alt28_1:
  # rx charclass_q s r 1..-1
    sub $I10, rx23_pos, rx23_off
    find_not_cclass $I11, 32, rx23_tgt, $I10, rx23_eos
    add $I12, $I10, 1
    lt $I11, $I12, rx23_fail
    add rx23_pos, rx23_off, $I11
  alt28_end:
    (rx23_rep) = rx23_cur."!mark_commit"($I31)
    rx23_cur."!mark_push"(rx23_rep, rx23_pos, $I31)
    goto rxquantr27_loop
  rxquantr27_done:
.annotate "line", 17
  # rx pass
    rx23_cur."!cursor_pass"(rx23_pos, "ws")
    rx23_cur."!cursor_debug"("PASS  ", "ws", " at pos=", rx23_pos)
    .return (rx23_cur)
  rx23_fail:
.annotate "line", 9
    (rx23_rep, rx23_pos, $I10, $P10) = rx23_cur."!mark_fail"(0)
    lt rx23_pos, -1, rx23_done
    eq rx23_pos, -1, rx23_fail
    jump $I10
  rx23_done:
    rx23_cur."!cursor_fail"()
    rx23_cur."!cursor_debug"("FAIL  ", "ws")
    .return (rx23_cur)
    .return ()
.end


.namespace ["parrotlog";"Grammar"]
.sub "!PREFIX__ws"  :subid("15_1269727965.58325") :method
.annotate "line", 9
    new $P25, "ResizablePMCArray"
    push $P25, ""
    .return ($P25)
.end


.namespace ["parrotlog";"Grammar"]
.sub "statementlist"  :subid("16_1269727965.58325") :method :outer("11_1269727965.58325")
.annotate "line", 9
    .local string rx33_tgt
    .local int rx33_pos
    .local int rx33_off
    .local int rx33_eos
    .local int rx33_rep
    .local pmc rx33_cur
    (rx33_cur, rx33_pos, rx33_tgt) = self."!cursor_start"()
    rx33_cur."!cursor_debug"("START ", "statementlist")
    rx33_cur."!cursor_caparray"("statement")
    .lex unicode:"$\x{a2}", rx33_cur
    .local pmc match
    .lex "$/", match
    length rx33_eos, rx33_tgt
    set rx33_off, 0
    lt rx33_pos, 2, rx33_start
    sub rx33_off, rx33_pos, 1
    substr rx33_tgt, rx33_tgt, rx33_off
  rx33_start:
    $I10 = self.'from'()
    ne $I10, -1, rxscan36_done
    goto rxscan36_scan
  rxscan36_loop:
    ($P10) = rx33_cur."from"()
    inc $P10
    set rx33_pos, $P10
    ge rx33_pos, rx33_eos, rxscan36_done
  rxscan36_scan:
    set_addr $I10, rxscan36_loop
    rx33_cur."!mark_push"(0, rx33_pos, $I10)
  rxscan36_done:
.annotate "line", 24
  # rx subrule "ws" subtype=method negate=
    rx33_cur."!cursor_pos"(rx33_pos)
    $P10 = rx33_cur."ws"()
    unless $P10, rx33_fail
    rx33_pos = $P10."pos"()
  # rx rxquantr38 ** 1..*
    set_addr $I44, rxquantr38_done
    rx33_cur."!mark_push"(0, -1, $I44)
  rxquantr38_loop:
  alt39_0:
    set_addr $I10, alt39_1
    rx33_cur."!mark_push"(0, rx33_pos, $I10)
  # rx subrule "ws" subtype=method negate=
    rx33_cur."!cursor_pos"(rx33_pos)
    $P10 = rx33_cur."ws"()
    unless $P10, rx33_fail
    rx33_pos = $P10."pos"()
  # rx subrule "statement" subtype=capture negate=
    rx33_cur."!cursor_pos"(rx33_pos)
    $P10 = rx33_cur."statement"()
    unless $P10, rx33_fail
    rx33_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("statement")
    rx33_pos = $P10."pos"()
  # rx subrule "ws" subtype=method negate=
    rx33_cur."!cursor_pos"(rx33_pos)
    $P10 = rx33_cur."ws"()
    unless $P10, rx33_fail
    rx33_pos = $P10."pos"()
    goto alt39_end
  alt39_1:
  # rx subrule "ws" subtype=method negate=
    rx33_cur."!cursor_pos"(rx33_pos)
    $P10 = rx33_cur."ws"()
    unless $P10, rx33_fail
    rx33_pos = $P10."pos"()
  # rx subrule "ws" subtype=method negate=
    rx33_cur."!cursor_pos"(rx33_pos)
    $P10 = rx33_cur."ws"()
    unless $P10, rx33_fail
    rx33_pos = $P10."pos"()
  alt39_end:
    (rx33_rep) = rx33_cur."!mark_commit"($I44)
    rx33_cur."!mark_push"(rx33_rep, rx33_pos, $I44)
  # rx literal  ";"
    add $I11, rx33_pos, 1
    gt $I11, rx33_eos, rx33_fail
    sub $I11, rx33_pos, rx33_off
    substr $S10, rx33_tgt, $I11, 1
    ne $S10, ";", rx33_fail
    add rx33_pos, 1
    goto rxquantr38_loop
  rxquantr38_done:
  # rx subrule "ws" subtype=method negate=
    rx33_cur."!cursor_pos"(rx33_pos)
    $P10 = rx33_cur."ws"()
    unless $P10, rx33_fail
    rx33_pos = $P10."pos"()
  # rx pass
    rx33_cur."!cursor_pass"(rx33_pos, "statementlist")
    rx33_cur."!cursor_debug"("PASS  ", "statementlist", " at pos=", rx33_pos)
    .return (rx33_cur)
  rx33_fail:
.annotate "line", 9
    (rx33_rep, rx33_pos, $I10, $P10) = rx33_cur."!mark_fail"(0)
    lt rx33_pos, -1, rx33_done
    eq rx33_pos, -1, rx33_fail
    jump $I10
  rx33_done:
    rx33_cur."!cursor_fail"()
    rx33_cur."!cursor_debug"("FAIL  ", "statementlist")
    .return (rx33_cur)
    .return ()
.end


.namespace ["parrotlog";"Grammar"]
.sub "!PREFIX__statementlist"  :subid("17_1269727965.58325") :method
.annotate "line", 9
    new $P35, "ResizablePMCArray"
    push $P35, ""
    .return ($P35)
.end


.namespace ["parrotlog";"Grammar"]
.sub "statement"  :subid("18_1269727965.58325") :method :outer("11_1269727965.58325")
.annotate "line", 9
    .local string rx47_tgt
    .local int rx47_pos
    .local int rx47_off
    .local int rx47_eos
    .local int rx47_rep
    .local pmc rx47_cur
    (rx47_cur, rx47_pos, rx47_tgt) = self."!cursor_start"()
    rx47_cur."!cursor_debug"("START ", "statement")
    .lex unicode:"$\x{a2}", rx47_cur
    .local pmc match
    .lex "$/", match
    length rx47_eos, rx47_tgt
    set rx47_off, 0
    lt rx47_pos, 2, rx47_start
    sub rx47_off, rx47_pos, 1
    substr rx47_tgt, rx47_tgt, rx47_off
  rx47_start:
    $I10 = self.'from'()
    ne $I10, -1, rxscan50_done
    goto rxscan50_scan
  rxscan50_loop:
    ($P10) = rx47_cur."from"()
    inc $P10
    set rx47_pos, $P10
    ge rx47_pos, rx47_eos, rxscan50_done
  rxscan50_scan:
    set_addr $I10, rxscan50_loop
    rx47_cur."!mark_push"(0, rx47_pos, $I10)
  rxscan50_done:
  alt51_0:
.annotate "line", 26
    set_addr $I10, alt51_1
    rx47_cur."!mark_push"(0, rx47_pos, $I10)
.annotate "line", 27
  # rx subrule "ws" subtype=method negate=
    rx47_cur."!cursor_pos"(rx47_pos)
    $P10 = rx47_cur."ws"()
    unless $P10, rx47_fail
    rx47_pos = $P10."pos"()
  # rx subrule "statement_control" subtype=capture negate=
    rx47_cur."!cursor_pos"(rx47_pos)
    $P10 = rx47_cur."statement_control"()
    unless $P10, rx47_fail
    rx47_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("statement_control")
    rx47_pos = $P10."pos"()
  # rx subrule "ws" subtype=method negate=
    rx47_cur."!cursor_pos"(rx47_pos)
    $P10 = rx47_cur."ws"()
    unless $P10, rx47_fail
    rx47_pos = $P10."pos"()
    goto alt51_end
  alt51_1:
.annotate "line", 28
  # rx subrule "ws" subtype=method negate=
    rx47_cur."!cursor_pos"(rx47_pos)
    $P10 = rx47_cur."ws"()
    unless $P10, rx47_fail
    rx47_pos = $P10."pos"()
  # rx subrule "EXPR" subtype=capture negate=
    rx47_cur."!cursor_pos"(rx47_pos)
    $P10 = rx47_cur."EXPR"()
    unless $P10, rx47_fail
    rx47_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("EXPR")
    rx47_pos = $P10."pos"()
  # rx subrule "ws" subtype=method negate=
    rx47_cur."!cursor_pos"(rx47_pos)
    $P10 = rx47_cur."ws"()
    unless $P10, rx47_fail
    rx47_pos = $P10."pos"()
  alt51_end:
.annotate "line", 26
  # rx pass
    rx47_cur."!cursor_pass"(rx47_pos, "statement")
    rx47_cur."!cursor_debug"("PASS  ", "statement", " at pos=", rx47_pos)
    .return (rx47_cur)
  rx47_fail:
.annotate "line", 9
    (rx47_rep, rx47_pos, $I10, $P10) = rx47_cur."!mark_fail"(0)
    lt rx47_pos, -1, rx47_done
    eq rx47_pos, -1, rx47_fail
    jump $I10
  rx47_done:
    rx47_cur."!cursor_fail"()
    rx47_cur."!cursor_debug"("FAIL  ", "statement")
    .return (rx47_cur)
    .return ()
.end


.namespace ["parrotlog";"Grammar"]
.sub "!PREFIX__statement"  :subid("19_1269727965.58325") :method
.annotate "line", 9
    new $P49, "ResizablePMCArray"
    push $P49, ""
    push $P49, ""
    .return ($P49)
.end


.namespace ["parrotlog";"Grammar"]
.sub "statement_control"  :subid("20_1269727965.58325") :method
.annotate "line", 31
    $P57 = self."!protoregex"("statement_control")
    .return ($P57)
.end


.namespace ["parrotlog";"Grammar"]
.sub "!PREFIX__statement_control"  :subid("21_1269727965.58325") :method
.annotate "line", 31
    $P59 = self."!PREFIX__!protoregex"("statement_control")
    .return ($P59)
.end


.namespace ["parrotlog";"Grammar"]
.sub "statement_control:sym<say>"  :subid("22_1269727965.58325") :method :outer("11_1269727965.58325")
.annotate "line", 9
    .local string rx61_tgt
    .local int rx61_pos
    .local int rx61_off
    .local int rx61_eos
    .local int rx61_rep
    .local pmc rx61_cur
    (rx61_cur, rx61_pos, rx61_tgt) = self."!cursor_start"()
    rx61_cur."!cursor_debug"("START ", "statement_control:sym<say>")
    rx61_cur."!cursor_caparray"("EXPR")
    .lex unicode:"$\x{a2}", rx61_cur
    .local pmc match
    .lex "$/", match
    length rx61_eos, rx61_tgt
    set rx61_off, 0
    lt rx61_pos, 2, rx61_start
    sub rx61_off, rx61_pos, 1
    substr rx61_tgt, rx61_tgt, rx61_off
  rx61_start:
    $I10 = self.'from'()
    ne $I10, -1, rxscan64_done
    goto rxscan64_scan
  rxscan64_loop:
    ($P10) = rx61_cur."from"()
    inc $P10
    set rx61_pos, $P10
    ge rx61_pos, rx61_eos, rxscan64_done
  rxscan64_scan:
    set_addr $I10, rxscan64_loop
    rx61_cur."!mark_push"(0, rx61_pos, $I10)
  rxscan64_done:
.annotate "line", 32
  # rx subrule "ws" subtype=method negate=
    rx61_cur."!cursor_pos"(rx61_pos)
    $P10 = rx61_cur."ws"()
    unless $P10, rx61_fail
    rx61_pos = $P10."pos"()
  # rx subcapture "sym"
    set_addr $I10, rxcap_66_fail
    rx61_cur."!mark_push"(0, rx61_pos, $I10)
  # rx literal  "say"
    add $I11, rx61_pos, 3
    gt $I11, rx61_eos, rx61_fail
    sub $I11, rx61_pos, rx61_off
    substr $S10, rx61_tgt, $I11, 3
    ne $S10, "say", rx61_fail
    add rx61_pos, 3
    set_addr $I10, rxcap_66_fail
    ($I12, $I11) = rx61_cur."!mark_peek"($I10)
    rx61_cur."!cursor_pos"($I11)
    ($P10) = rx61_cur."!cursor_start"()
    $P10."!cursor_pass"(rx61_pos, "")
    rx61_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("sym")
    goto rxcap_66_done
  rxcap_66_fail:
    goto rx61_fail
  rxcap_66_done:
  # rx subrule "ws" subtype=method negate=
    rx61_cur."!cursor_pos"(rx61_pos)
    $P10 = rx61_cur."ws"()
    unless $P10, rx61_fail
    rx61_pos = $P10."pos"()
  # rx rxquantr68 ** 1..*
    set_addr $I71, rxquantr68_done
    rx61_cur."!mark_push"(0, -1, $I71)
  rxquantr68_loop:
  # rx subrule "ws" subtype=method negate=
    rx61_cur."!cursor_pos"(rx61_pos)
    $P10 = rx61_cur."ws"()
    unless $P10, rx61_fail
    rx61_pos = $P10."pos"()
  # rx subrule "EXPR" subtype=capture negate=
    rx61_cur."!cursor_pos"(rx61_pos)
    $P10 = rx61_cur."EXPR"()
    unless $P10, rx61_fail
    rx61_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("EXPR")
    rx61_pos = $P10."pos"()
  # rx subrule "ws" subtype=method negate=
    rx61_cur."!cursor_pos"(rx61_pos)
    $P10 = rx61_cur."ws"()
    unless $P10, rx61_fail
    rx61_pos = $P10."pos"()
    (rx61_rep) = rx61_cur."!mark_commit"($I71)
    rx61_cur."!mark_push"(rx61_rep, rx61_pos, $I71)
  # rx literal  ","
    add $I11, rx61_pos, 1
    gt $I11, rx61_eos, rx61_fail
    sub $I11, rx61_pos, rx61_off
    substr $S10, rx61_tgt, $I11, 1
    ne $S10, ",", rx61_fail
    add rx61_pos, 1
    goto rxquantr68_loop
  rxquantr68_done:
  # rx subrule "ws" subtype=method negate=
    rx61_cur."!cursor_pos"(rx61_pos)
    $P10 = rx61_cur."ws"()
    unless $P10, rx61_fail
    rx61_pos = $P10."pos"()
  # rx pass
    rx61_cur."!cursor_pass"(rx61_pos, "statement_control:sym<say>")
    rx61_cur."!cursor_debug"("PASS  ", "statement_control:sym<say>", " at pos=", rx61_pos)
    .return (rx61_cur)
  rx61_fail:
.annotate "line", 9
    (rx61_rep, rx61_pos, $I10, $P10) = rx61_cur."!mark_fail"(0)
    lt rx61_pos, -1, rx61_done
    eq rx61_pos, -1, rx61_fail
    jump $I10
  rx61_done:
    rx61_cur."!cursor_fail"()
    rx61_cur."!cursor_debug"("FAIL  ", "statement_control:sym<say>")
    .return (rx61_cur)
    .return ()
.end


.namespace ["parrotlog";"Grammar"]
.sub "!PREFIX__statement_control:sym<say>"  :subid("23_1269727965.58325") :method
.annotate "line", 9
    new $P63, "ResizablePMCArray"
    push $P63, ""
    .return ($P63)
.end


.namespace ["parrotlog";"Grammar"]
.sub "statement_control:sym<print>"  :subid("24_1269727965.58325") :method :outer("11_1269727965.58325")
.annotate "line", 9
    .local string rx74_tgt
    .local int rx74_pos
    .local int rx74_off
    .local int rx74_eos
    .local int rx74_rep
    .local pmc rx74_cur
    (rx74_cur, rx74_pos, rx74_tgt) = self."!cursor_start"()
    rx74_cur."!cursor_debug"("START ", "statement_control:sym<print>")
    rx74_cur."!cursor_caparray"("EXPR")
    .lex unicode:"$\x{a2}", rx74_cur
    .local pmc match
    .lex "$/", match
    length rx74_eos, rx74_tgt
    set rx74_off, 0
    lt rx74_pos, 2, rx74_start
    sub rx74_off, rx74_pos, 1
    substr rx74_tgt, rx74_tgt, rx74_off
  rx74_start:
    $I10 = self.'from'()
    ne $I10, -1, rxscan77_done
    goto rxscan77_scan
  rxscan77_loop:
    ($P10) = rx74_cur."from"()
    inc $P10
    set rx74_pos, $P10
    ge rx74_pos, rx74_eos, rxscan77_done
  rxscan77_scan:
    set_addr $I10, rxscan77_loop
    rx74_cur."!mark_push"(0, rx74_pos, $I10)
  rxscan77_done:
.annotate "line", 33
  # rx subrule "ws" subtype=method negate=
    rx74_cur."!cursor_pos"(rx74_pos)
    $P10 = rx74_cur."ws"()
    unless $P10, rx74_fail
    rx74_pos = $P10."pos"()
  # rx subcapture "sym"
    set_addr $I10, rxcap_79_fail
    rx74_cur."!mark_push"(0, rx74_pos, $I10)
  # rx literal  "print"
    add $I11, rx74_pos, 5
    gt $I11, rx74_eos, rx74_fail
    sub $I11, rx74_pos, rx74_off
    substr $S10, rx74_tgt, $I11, 5
    ne $S10, "print", rx74_fail
    add rx74_pos, 5
    set_addr $I10, rxcap_79_fail
    ($I12, $I11) = rx74_cur."!mark_peek"($I10)
    rx74_cur."!cursor_pos"($I11)
    ($P10) = rx74_cur."!cursor_start"()
    $P10."!cursor_pass"(rx74_pos, "")
    rx74_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("sym")
    goto rxcap_79_done
  rxcap_79_fail:
    goto rx74_fail
  rxcap_79_done:
  # rx subrule "ws" subtype=method negate=
    rx74_cur."!cursor_pos"(rx74_pos)
    $P10 = rx74_cur."ws"()
    unless $P10, rx74_fail
    rx74_pos = $P10."pos"()
  # rx rxquantr81 ** 1..*
    set_addr $I84, rxquantr81_done
    rx74_cur."!mark_push"(0, -1, $I84)
  rxquantr81_loop:
  # rx subrule "ws" subtype=method negate=
    rx74_cur."!cursor_pos"(rx74_pos)
    $P10 = rx74_cur."ws"()
    unless $P10, rx74_fail
    rx74_pos = $P10."pos"()
  # rx subrule "EXPR" subtype=capture negate=
    rx74_cur."!cursor_pos"(rx74_pos)
    $P10 = rx74_cur."EXPR"()
    unless $P10, rx74_fail
    rx74_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("EXPR")
    rx74_pos = $P10."pos"()
  # rx subrule "ws" subtype=method negate=
    rx74_cur."!cursor_pos"(rx74_pos)
    $P10 = rx74_cur."ws"()
    unless $P10, rx74_fail
    rx74_pos = $P10."pos"()
    (rx74_rep) = rx74_cur."!mark_commit"($I84)
    rx74_cur."!mark_push"(rx74_rep, rx74_pos, $I84)
  # rx literal  ","
    add $I11, rx74_pos, 1
    gt $I11, rx74_eos, rx74_fail
    sub $I11, rx74_pos, rx74_off
    substr $S10, rx74_tgt, $I11, 1
    ne $S10, ",", rx74_fail
    add rx74_pos, 1
    goto rxquantr81_loop
  rxquantr81_done:
  # rx subrule "ws" subtype=method negate=
    rx74_cur."!cursor_pos"(rx74_pos)
    $P10 = rx74_cur."ws"()
    unless $P10, rx74_fail
    rx74_pos = $P10."pos"()
  # rx pass
    rx74_cur."!cursor_pass"(rx74_pos, "statement_control:sym<print>")
    rx74_cur."!cursor_debug"("PASS  ", "statement_control:sym<print>", " at pos=", rx74_pos)
    .return (rx74_cur)
  rx74_fail:
.annotate "line", 9
    (rx74_rep, rx74_pos, $I10, $P10) = rx74_cur."!mark_fail"(0)
    lt rx74_pos, -1, rx74_done
    eq rx74_pos, -1, rx74_fail
    jump $I10
  rx74_done:
    rx74_cur."!cursor_fail"()
    rx74_cur."!cursor_debug"("FAIL  ", "statement_control:sym<print>")
    .return (rx74_cur)
    .return ()
.end


.namespace ["parrotlog";"Grammar"]
.sub "!PREFIX__statement_control:sym<print>"  :subid("25_1269727965.58325") :method
.annotate "line", 9
    new $P76, "ResizablePMCArray"
    push $P76, ""
    .return ($P76)
.end


.namespace ["parrotlog";"Grammar"]
.sub "term:sym<integer>"  :subid("26_1269727965.58325") :method :outer("11_1269727965.58325")
.annotate "line", 9
    .local string rx87_tgt
    .local int rx87_pos
    .local int rx87_off
    .local int rx87_eos
    .local int rx87_rep
    .local pmc rx87_cur
    (rx87_cur, rx87_pos, rx87_tgt) = self."!cursor_start"()
    rx87_cur."!cursor_debug"("START ", "term:sym<integer>")
    .lex unicode:"$\x{a2}", rx87_cur
    .local pmc match
    .lex "$/", match
    length rx87_eos, rx87_tgt
    set rx87_off, 0
    lt rx87_pos, 2, rx87_start
    sub rx87_off, rx87_pos, 1
    substr rx87_tgt, rx87_tgt, rx87_off
  rx87_start:
    $I10 = self.'from'()
    ne $I10, -1, rxscan91_done
    goto rxscan91_scan
  rxscan91_loop:
    ($P10) = rx87_cur."from"()
    inc $P10
    set rx87_pos, $P10
    ge rx87_pos, rx87_eos, rxscan91_done
  rxscan91_scan:
    set_addr $I10, rxscan91_loop
    rx87_cur."!mark_push"(0, rx87_pos, $I10)
  rxscan91_done:
.annotate "line", 37
  # rx subrule "integer" subtype=capture negate=
    rx87_cur."!cursor_pos"(rx87_pos)
    $P10 = rx87_cur."integer"()
    unless $P10, rx87_fail
    rx87_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("integer")
    rx87_pos = $P10."pos"()
  # rx pass
    rx87_cur."!cursor_pass"(rx87_pos, "term:sym<integer>")
    rx87_cur."!cursor_debug"("PASS  ", "term:sym<integer>", " at pos=", rx87_pos)
    .return (rx87_cur)
  rx87_fail:
.annotate "line", 9
    (rx87_rep, rx87_pos, $I10, $P10) = rx87_cur."!mark_fail"(0)
    lt rx87_pos, -1, rx87_done
    eq rx87_pos, -1, rx87_fail
    jump $I10
  rx87_done:
    rx87_cur."!cursor_fail"()
    rx87_cur."!cursor_debug"("FAIL  ", "term:sym<integer>")
    .return (rx87_cur)
    .return ()
.end


.namespace ["parrotlog";"Grammar"]
.sub "!PREFIX__term:sym<integer>"  :subid("27_1269727965.58325") :method
.annotate "line", 9
    $P89 = self."!PREFIX__!subrule"("integer", "")
    new $P90, "ResizablePMCArray"
    push $P90, $P89
    .return ($P90)
.end


.namespace ["parrotlog";"Grammar"]
.sub "term:sym<quote>"  :subid("28_1269727965.58325") :method :outer("11_1269727965.58325")
.annotate "line", 9
    .local string rx93_tgt
    .local int rx93_pos
    .local int rx93_off
    .local int rx93_eos
    .local int rx93_rep
    .local pmc rx93_cur
    (rx93_cur, rx93_pos, rx93_tgt) = self."!cursor_start"()
    rx93_cur."!cursor_debug"("START ", "term:sym<quote>")
    .lex unicode:"$\x{a2}", rx93_cur
    .local pmc match
    .lex "$/", match
    length rx93_eos, rx93_tgt
    set rx93_off, 0
    lt rx93_pos, 2, rx93_start
    sub rx93_off, rx93_pos, 1
    substr rx93_tgt, rx93_tgt, rx93_off
  rx93_start:
    $I10 = self.'from'()
    ne $I10, -1, rxscan97_done
    goto rxscan97_scan
  rxscan97_loop:
    ($P10) = rx93_cur."from"()
    inc $P10
    set rx93_pos, $P10
    ge rx93_pos, rx93_eos, rxscan97_done
  rxscan97_scan:
    set_addr $I10, rxscan97_loop
    rx93_cur."!mark_push"(0, rx93_pos, $I10)
  rxscan97_done:
.annotate "line", 38
  # rx subrule "quote" subtype=capture negate=
    rx93_cur."!cursor_pos"(rx93_pos)
    $P10 = rx93_cur."quote"()
    unless $P10, rx93_fail
    rx93_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("quote")
    rx93_pos = $P10."pos"()
  # rx pass
    rx93_cur."!cursor_pass"(rx93_pos, "term:sym<quote>")
    rx93_cur."!cursor_debug"("PASS  ", "term:sym<quote>", " at pos=", rx93_pos)
    .return (rx93_cur)
  rx93_fail:
.annotate "line", 9
    (rx93_rep, rx93_pos, $I10, $P10) = rx93_cur."!mark_fail"(0)
    lt rx93_pos, -1, rx93_done
    eq rx93_pos, -1, rx93_fail
    jump $I10
  rx93_done:
    rx93_cur."!cursor_fail"()
    rx93_cur."!cursor_debug"("FAIL  ", "term:sym<quote>")
    .return (rx93_cur)
    .return ()
.end


.namespace ["parrotlog";"Grammar"]
.sub "!PREFIX__term:sym<quote>"  :subid("29_1269727965.58325") :method
.annotate "line", 9
    $P95 = self."!PREFIX__!subrule"("quote", "")
    new $P96, "ResizablePMCArray"
    push $P96, $P95
    .return ($P96)
.end


.namespace ["parrotlog";"Grammar"]
.sub "quote"  :subid("30_1269727965.58325") :method
.annotate "line", 40
    $P99 = self."!protoregex"("quote")
    .return ($P99)
.end


.namespace ["parrotlog";"Grammar"]
.sub "!PREFIX__quote"  :subid("31_1269727965.58325") :method
.annotate "line", 40
    $P101 = self."!PREFIX__!protoregex"("quote")
    .return ($P101)
.end


.namespace ["parrotlog";"Grammar"]
.sub "quote:sym<'>"  :subid("32_1269727965.58325") :method :outer("11_1269727965.58325")
.annotate "line", 9
    .local string rx103_tgt
    .local int rx103_pos
    .local int rx103_off
    .local int rx103_eos
    .local int rx103_rep
    .local pmc rx103_cur
    (rx103_cur, rx103_pos, rx103_tgt) = self."!cursor_start"()
    rx103_cur."!cursor_debug"("START ", "quote:sym<'>")
    .lex unicode:"$\x{a2}", rx103_cur
    .local pmc match
    .lex "$/", match
    length rx103_eos, rx103_tgt
    set rx103_off, 0
    lt rx103_pos, 2, rx103_start
    sub rx103_off, rx103_pos, 1
    substr rx103_tgt, rx103_tgt, rx103_off
  rx103_start:
    $I10 = self.'from'()
    ne $I10, -1, rxscan106_done
    goto rxscan106_scan
  rxscan106_loop:
    ($P10) = rx103_cur."from"()
    inc $P10
    set rx103_pos, $P10
    ge rx103_pos, rx103_eos, rxscan106_done
  rxscan106_scan:
    set_addr $I10, rxscan106_loop
    rx103_cur."!mark_push"(0, rx103_pos, $I10)
  rxscan106_done:
.annotate "line", 41
  # rx enumcharlist negate=0 zerowidth
    ge rx103_pos, rx103_eos, rx103_fail
    sub $I10, rx103_pos, rx103_off
    substr $S10, rx103_tgt, $I10, 1
    index $I11, "'", $S10
    lt $I11, 0, rx103_fail
  # rx subrule "quote_EXPR" subtype=capture negate=
    rx103_cur."!cursor_pos"(rx103_pos)
    $P10 = rx103_cur."quote_EXPR"(":q")
    unless $P10, rx103_fail
    rx103_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("quote_EXPR")
    rx103_pos = $P10."pos"()
  # rx pass
    rx103_cur."!cursor_pass"(rx103_pos, "quote:sym<'>")
    rx103_cur."!cursor_debug"("PASS  ", "quote:sym<'>", " at pos=", rx103_pos)
    .return (rx103_cur)
  rx103_fail:
.annotate "line", 9
    (rx103_rep, rx103_pos, $I10, $P10) = rx103_cur."!mark_fail"(0)
    lt rx103_pos, -1, rx103_done
    eq rx103_pos, -1, rx103_fail
    jump $I10
  rx103_done:
    rx103_cur."!cursor_fail"()
    rx103_cur."!cursor_debug"("FAIL  ", "quote:sym<'>")
    .return (rx103_cur)
    .return ()
.end


.namespace ["parrotlog";"Grammar"]
.sub "!PREFIX__quote:sym<'>"  :subid("33_1269727965.58325") :method
.annotate "line", 9
    new $P105, "ResizablePMCArray"
    push $P105, "'"
    .return ($P105)
.end


.namespace ["parrotlog";"Grammar"]
.sub "quote:sym<\">"  :subid("34_1269727965.58325") :method :outer("11_1269727965.58325")
.annotate "line", 9
    .local string rx108_tgt
    .local int rx108_pos
    .local int rx108_off
    .local int rx108_eos
    .local int rx108_rep
    .local pmc rx108_cur
    (rx108_cur, rx108_pos, rx108_tgt) = self."!cursor_start"()
    rx108_cur."!cursor_debug"("START ", "quote:sym<\">")
    .lex unicode:"$\x{a2}", rx108_cur
    .local pmc match
    .lex "$/", match
    length rx108_eos, rx108_tgt
    set rx108_off, 0
    lt rx108_pos, 2, rx108_start
    sub rx108_off, rx108_pos, 1
    substr rx108_tgt, rx108_tgt, rx108_off
  rx108_start:
    $I10 = self.'from'()
    ne $I10, -1, rxscan111_done
    goto rxscan111_scan
  rxscan111_loop:
    ($P10) = rx108_cur."from"()
    inc $P10
    set rx108_pos, $P10
    ge rx108_pos, rx108_eos, rxscan111_done
  rxscan111_scan:
    set_addr $I10, rxscan111_loop
    rx108_cur."!mark_push"(0, rx108_pos, $I10)
  rxscan111_done:
.annotate "line", 42
  # rx enumcharlist negate=0 zerowidth
    ge rx108_pos, rx108_eos, rx108_fail
    sub $I10, rx108_pos, rx108_off
    substr $S10, rx108_tgt, $I10, 1
    index $I11, "\"", $S10
    lt $I11, 0, rx108_fail
  # rx subrule "quote_EXPR" subtype=capture negate=
    rx108_cur."!cursor_pos"(rx108_pos)
    $P10 = rx108_cur."quote_EXPR"(":qq")
    unless $P10, rx108_fail
    rx108_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("quote_EXPR")
    rx108_pos = $P10."pos"()
  # rx pass
    rx108_cur."!cursor_pass"(rx108_pos, "quote:sym<\">")
    rx108_cur."!cursor_debug"("PASS  ", "quote:sym<\">", " at pos=", rx108_pos)
    .return (rx108_cur)
  rx108_fail:
.annotate "line", 9
    (rx108_rep, rx108_pos, $I10, $P10) = rx108_cur."!mark_fail"(0)
    lt rx108_pos, -1, rx108_done
    eq rx108_pos, -1, rx108_fail
    jump $I10
  rx108_done:
    rx108_cur."!cursor_fail"()
    rx108_cur."!cursor_debug"("FAIL  ", "quote:sym<\">")
    .return (rx108_cur)
    .return ()
.end


.namespace ["parrotlog";"Grammar"]
.sub "!PREFIX__quote:sym<\">"  :subid("35_1269727965.58325") :method
.annotate "line", 9
    new $P110, "ResizablePMCArray"
    push $P110, "\""
    .return ($P110)
.end


.namespace ["parrotlog";"Grammar"]
.sub "circumfix:sym<( )>"  :subid("36_1269727965.58325") :method :outer("11_1269727965.58325")
.annotate "line", 46
    .local string rx113_tgt
    .local int rx113_pos
    .local int rx113_off
    .local int rx113_eos
    .local int rx113_rep
    .local pmc rx113_cur
    (rx113_cur, rx113_pos, rx113_tgt) = self."!cursor_start"()
    rx113_cur."!cursor_debug"("START ", "circumfix:sym<( )>")
    .lex unicode:"$\x{a2}", rx113_cur
    .local pmc match
    .lex "$/", match
    length rx113_eos, rx113_tgt
    set rx113_off, 0
    lt rx113_pos, 2, rx113_start
    sub rx113_off, rx113_pos, 1
    substr rx113_tgt, rx113_tgt, rx113_off
  rx113_start:
    $I10 = self.'from'()
    ne $I10, -1, rxscan117_done
    goto rxscan117_scan
  rxscan117_loop:
    ($P10) = rx113_cur."from"()
    inc $P10
    set rx113_pos, $P10
    ge rx113_pos, rx113_eos, rxscan117_done
  rxscan117_scan:
    set_addr $I10, rxscan117_loop
    rx113_cur."!mark_push"(0, rx113_pos, $I10)
  rxscan117_done:
.annotate "line", 51
  # rx literal  "("
    add $I11, rx113_pos, 1
    gt $I11, rx113_eos, rx113_fail
    sub $I11, rx113_pos, rx113_off
    substr $S10, rx113_tgt, $I11, 1
    ne $S10, "(", rx113_fail
    add rx113_pos, 1
  # rx subrule "ws" subtype=method negate=
    rx113_cur."!cursor_pos"(rx113_pos)
    $P10 = rx113_cur."ws"()
    unless $P10, rx113_fail
    rx113_pos = $P10."pos"()
  # rx subrule "EXPR" subtype=capture negate=
    rx113_cur."!cursor_pos"(rx113_pos)
    $P10 = rx113_cur."EXPR"()
    unless $P10, rx113_fail
    rx113_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("EXPR")
    rx113_pos = $P10."pos"()
  # rx literal  ")"
    add $I11, rx113_pos, 1
    gt $I11, rx113_eos, rx113_fail
    sub $I11, rx113_pos, rx113_off
    substr $S10, rx113_tgt, $I11, 1
    ne $S10, ")", rx113_fail
    add rx113_pos, 1
  # rx pass
    rx113_cur."!cursor_pass"(rx113_pos, "circumfix:sym<( )>")
    rx113_cur."!cursor_debug"("PASS  ", "circumfix:sym<( )>", " at pos=", rx113_pos)
    .return (rx113_cur)
  rx113_fail:
.annotate "line", 46
    (rx113_rep, rx113_pos, $I10, $P10) = rx113_cur."!mark_fail"(0)
    lt rx113_pos, -1, rx113_done
    eq rx113_pos, -1, rx113_fail
    jump $I10
  rx113_done:
    rx113_cur."!cursor_fail"()
    rx113_cur."!cursor_debug"("FAIL  ", "circumfix:sym<( )>")
    .return (rx113_cur)
    .return ()
.end


.namespace ["parrotlog";"Grammar"]
.sub "!PREFIX__circumfix:sym<( )>"  :subid("37_1269727965.58325") :method
.annotate "line", 46
    $P115 = self."!PREFIX__!subrule"("", "(")
    new $P116, "ResizablePMCArray"
    push $P116, $P115
    .return ($P116)
.end


.namespace ["parrotlog";"Grammar"]
.sub "infix:sym<*>"  :subid("38_1269727965.58325") :method :outer("11_1269727965.58325")
.annotate "line", 46
    .local string rx119_tgt
    .local int rx119_pos
    .local int rx119_off
    .local int rx119_eos
    .local int rx119_rep
    .local pmc rx119_cur
    (rx119_cur, rx119_pos, rx119_tgt) = self."!cursor_start"()
    rx119_cur."!cursor_debug"("START ", "infix:sym<*>")
    .lex unicode:"$\x{a2}", rx119_cur
    .local pmc match
    .lex "$/", match
    length rx119_eos, rx119_tgt
    set rx119_off, 0
    lt rx119_pos, 2, rx119_start
    sub rx119_off, rx119_pos, 1
    substr rx119_tgt, rx119_tgt, rx119_off
  rx119_start:
    $I10 = self.'from'()
    ne $I10, -1, rxscan123_done
    goto rxscan123_scan
  rxscan123_loop:
    ($P10) = rx119_cur."from"()
    inc $P10
    set rx119_pos, $P10
    ge rx119_pos, rx119_eos, rxscan123_done
  rxscan123_scan:
    set_addr $I10, rxscan123_loop
    rx119_cur."!mark_push"(0, rx119_pos, $I10)
  rxscan123_done:
.annotate "line", 53
  # rx subcapture "sym"
    set_addr $I10, rxcap_124_fail
    rx119_cur."!mark_push"(0, rx119_pos, $I10)
  # rx literal  "*"
    add $I11, rx119_pos, 1
    gt $I11, rx119_eos, rx119_fail
    sub $I11, rx119_pos, rx119_off
    substr $S10, rx119_tgt, $I11, 1
    ne $S10, "*", rx119_fail
    add rx119_pos, 1
    set_addr $I10, rxcap_124_fail
    ($I12, $I11) = rx119_cur."!mark_peek"($I10)
    rx119_cur."!cursor_pos"($I11)
    ($P10) = rx119_cur."!cursor_start"()
    $P10."!cursor_pass"(rx119_pos, "")
    rx119_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("sym")
    goto rxcap_124_done
  rxcap_124_fail:
    goto rx119_fail
  rxcap_124_done:
  # rx subrule "O" subtype=capture negate=
    rx119_cur."!cursor_pos"(rx119_pos)
    $P10 = rx119_cur."O"("%multiplicative, :pirop<mul>")
    unless $P10, rx119_fail
    rx119_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("O")
    rx119_pos = $P10."pos"()
  # rx pass
    rx119_cur."!cursor_pass"(rx119_pos, "infix:sym<*>")
    rx119_cur."!cursor_debug"("PASS  ", "infix:sym<*>", " at pos=", rx119_pos)
    .return (rx119_cur)
  rx119_fail:
.annotate "line", 46
    (rx119_rep, rx119_pos, $I10, $P10) = rx119_cur."!mark_fail"(0)
    lt rx119_pos, -1, rx119_done
    eq rx119_pos, -1, rx119_fail
    jump $I10
  rx119_done:
    rx119_cur."!cursor_fail"()
    rx119_cur."!cursor_debug"("FAIL  ", "infix:sym<*>")
    .return (rx119_cur)
    .return ()
.end


.namespace ["parrotlog";"Grammar"]
.sub "!PREFIX__infix:sym<*>"  :subid("39_1269727965.58325") :method
.annotate "line", 46
    $P121 = self."!PREFIX__!subrule"("O", "*")
    new $P122, "ResizablePMCArray"
    push $P122, $P121
    .return ($P122)
.end


.namespace ["parrotlog";"Grammar"]
.sub "infix:sym</>"  :subid("40_1269727965.58325") :method :outer("11_1269727965.58325")
.annotate "line", 46
    .local string rx126_tgt
    .local int rx126_pos
    .local int rx126_off
    .local int rx126_eos
    .local int rx126_rep
    .local pmc rx126_cur
    (rx126_cur, rx126_pos, rx126_tgt) = self."!cursor_start"()
    rx126_cur."!cursor_debug"("START ", "infix:sym</>")
    .lex unicode:"$\x{a2}", rx126_cur
    .local pmc match
    .lex "$/", match
    length rx126_eos, rx126_tgt
    set rx126_off, 0
    lt rx126_pos, 2, rx126_start
    sub rx126_off, rx126_pos, 1
    substr rx126_tgt, rx126_tgt, rx126_off
  rx126_start:
    $I10 = self.'from'()
    ne $I10, -1, rxscan130_done
    goto rxscan130_scan
  rxscan130_loop:
    ($P10) = rx126_cur."from"()
    inc $P10
    set rx126_pos, $P10
    ge rx126_pos, rx126_eos, rxscan130_done
  rxscan130_scan:
    set_addr $I10, rxscan130_loop
    rx126_cur."!mark_push"(0, rx126_pos, $I10)
  rxscan130_done:
.annotate "line", 54
  # rx subcapture "sym"
    set_addr $I10, rxcap_131_fail
    rx126_cur."!mark_push"(0, rx126_pos, $I10)
  # rx literal  "/"
    add $I11, rx126_pos, 1
    gt $I11, rx126_eos, rx126_fail
    sub $I11, rx126_pos, rx126_off
    substr $S10, rx126_tgt, $I11, 1
    ne $S10, "/", rx126_fail
    add rx126_pos, 1
    set_addr $I10, rxcap_131_fail
    ($I12, $I11) = rx126_cur."!mark_peek"($I10)
    rx126_cur."!cursor_pos"($I11)
    ($P10) = rx126_cur."!cursor_start"()
    $P10."!cursor_pass"(rx126_pos, "")
    rx126_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("sym")
    goto rxcap_131_done
  rxcap_131_fail:
    goto rx126_fail
  rxcap_131_done:
  # rx subrule "O" subtype=capture negate=
    rx126_cur."!cursor_pos"(rx126_pos)
    $P10 = rx126_cur."O"("%multiplicative, :pirop<div>")
    unless $P10, rx126_fail
    rx126_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("O")
    rx126_pos = $P10."pos"()
  # rx pass
    rx126_cur."!cursor_pass"(rx126_pos, "infix:sym</>")
    rx126_cur."!cursor_debug"("PASS  ", "infix:sym</>", " at pos=", rx126_pos)
    .return (rx126_cur)
  rx126_fail:
.annotate "line", 46
    (rx126_rep, rx126_pos, $I10, $P10) = rx126_cur."!mark_fail"(0)
    lt rx126_pos, -1, rx126_done
    eq rx126_pos, -1, rx126_fail
    jump $I10
  rx126_done:
    rx126_cur."!cursor_fail"()
    rx126_cur."!cursor_debug"("FAIL  ", "infix:sym</>")
    .return (rx126_cur)
    .return ()
.end


.namespace ["parrotlog";"Grammar"]
.sub "!PREFIX__infix:sym</>"  :subid("41_1269727965.58325") :method
.annotate "line", 46
    $P128 = self."!PREFIX__!subrule"("O", "/")
    new $P129, "ResizablePMCArray"
    push $P129, $P128
    .return ($P129)
.end


.namespace ["parrotlog";"Grammar"]
.sub "infix:sym<+>"  :subid("42_1269727965.58325") :method :outer("11_1269727965.58325")
.annotate "line", 46
    .local string rx133_tgt
    .local int rx133_pos
    .local int rx133_off
    .local int rx133_eos
    .local int rx133_rep
    .local pmc rx133_cur
    (rx133_cur, rx133_pos, rx133_tgt) = self."!cursor_start"()
    rx133_cur."!cursor_debug"("START ", "infix:sym<+>")
    .lex unicode:"$\x{a2}", rx133_cur
    .local pmc match
    .lex "$/", match
    length rx133_eos, rx133_tgt
    set rx133_off, 0
    lt rx133_pos, 2, rx133_start
    sub rx133_off, rx133_pos, 1
    substr rx133_tgt, rx133_tgt, rx133_off
  rx133_start:
    $I10 = self.'from'()
    ne $I10, -1, rxscan137_done
    goto rxscan137_scan
  rxscan137_loop:
    ($P10) = rx133_cur."from"()
    inc $P10
    set rx133_pos, $P10
    ge rx133_pos, rx133_eos, rxscan137_done
  rxscan137_scan:
    set_addr $I10, rxscan137_loop
    rx133_cur."!mark_push"(0, rx133_pos, $I10)
  rxscan137_done:
.annotate "line", 56
  # rx subcapture "sym"
    set_addr $I10, rxcap_138_fail
    rx133_cur."!mark_push"(0, rx133_pos, $I10)
  # rx literal  "+"
    add $I11, rx133_pos, 1
    gt $I11, rx133_eos, rx133_fail
    sub $I11, rx133_pos, rx133_off
    substr $S10, rx133_tgt, $I11, 1
    ne $S10, "+", rx133_fail
    add rx133_pos, 1
    set_addr $I10, rxcap_138_fail
    ($I12, $I11) = rx133_cur."!mark_peek"($I10)
    rx133_cur."!cursor_pos"($I11)
    ($P10) = rx133_cur."!cursor_start"()
    $P10."!cursor_pass"(rx133_pos, "")
    rx133_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("sym")
    goto rxcap_138_done
  rxcap_138_fail:
    goto rx133_fail
  rxcap_138_done:
  # rx subrule "O" subtype=capture negate=
    rx133_cur."!cursor_pos"(rx133_pos)
    $P10 = rx133_cur."O"("%additive, :pirop<add>")
    unless $P10, rx133_fail
    rx133_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("O")
    rx133_pos = $P10."pos"()
  # rx pass
    rx133_cur."!cursor_pass"(rx133_pos, "infix:sym<+>")
    rx133_cur."!cursor_debug"("PASS  ", "infix:sym<+>", " at pos=", rx133_pos)
    .return (rx133_cur)
  rx133_fail:
.annotate "line", 46
    (rx133_rep, rx133_pos, $I10, $P10) = rx133_cur."!mark_fail"(0)
    lt rx133_pos, -1, rx133_done
    eq rx133_pos, -1, rx133_fail
    jump $I10
  rx133_done:
    rx133_cur."!cursor_fail"()
    rx133_cur."!cursor_debug"("FAIL  ", "infix:sym<+>")
    .return (rx133_cur)
    .return ()
.end


.namespace ["parrotlog";"Grammar"]
.sub "!PREFIX__infix:sym<+>"  :subid("43_1269727965.58325") :method
.annotate "line", 46
    $P135 = self."!PREFIX__!subrule"("O", "+")
    new $P136, "ResizablePMCArray"
    push $P136, $P135
    .return ($P136)
.end


.namespace ["parrotlog";"Grammar"]
.sub "infix:sym<->"  :subid("44_1269727965.58325") :method :outer("11_1269727965.58325")
.annotate "line", 46
    .local string rx140_tgt
    .local int rx140_pos
    .local int rx140_off
    .local int rx140_eos
    .local int rx140_rep
    .local pmc rx140_cur
    (rx140_cur, rx140_pos, rx140_tgt) = self."!cursor_start"()
    rx140_cur."!cursor_debug"("START ", "infix:sym<->")
    .lex unicode:"$\x{a2}", rx140_cur
    .local pmc match
    .lex "$/", match
    length rx140_eos, rx140_tgt
    set rx140_off, 0
    lt rx140_pos, 2, rx140_start
    sub rx140_off, rx140_pos, 1
    substr rx140_tgt, rx140_tgt, rx140_off
  rx140_start:
    $I10 = self.'from'()
    ne $I10, -1, rxscan144_done
    goto rxscan144_scan
  rxscan144_loop:
    ($P10) = rx140_cur."from"()
    inc $P10
    set rx140_pos, $P10
    ge rx140_pos, rx140_eos, rxscan144_done
  rxscan144_scan:
    set_addr $I10, rxscan144_loop
    rx140_cur."!mark_push"(0, rx140_pos, $I10)
  rxscan144_done:
.annotate "line", 57
  # rx subcapture "sym"
    set_addr $I10, rxcap_145_fail
    rx140_cur."!mark_push"(0, rx140_pos, $I10)
  # rx literal  "-"
    add $I11, rx140_pos, 1
    gt $I11, rx140_eos, rx140_fail
    sub $I11, rx140_pos, rx140_off
    substr $S10, rx140_tgt, $I11, 1
    ne $S10, "-", rx140_fail
    add rx140_pos, 1
    set_addr $I10, rxcap_145_fail
    ($I12, $I11) = rx140_cur."!mark_peek"($I10)
    rx140_cur."!cursor_pos"($I11)
    ($P10) = rx140_cur."!cursor_start"()
    $P10."!cursor_pass"(rx140_pos, "")
    rx140_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("sym")
    goto rxcap_145_done
  rxcap_145_fail:
    goto rx140_fail
  rxcap_145_done:
  # rx subrule "O" subtype=capture negate=
    rx140_cur."!cursor_pos"(rx140_pos)
    $P10 = rx140_cur."O"("%additive, :pirop<sub>")
    unless $P10, rx140_fail
    rx140_cur."!mark_push"(0, -1, 0, $P10)
    $P10."!cursor_names"("O")
    rx140_pos = $P10."pos"()
  # rx pass
    rx140_cur."!cursor_pass"(rx140_pos, "infix:sym<->")
    rx140_cur."!cursor_debug"("PASS  ", "infix:sym<->", " at pos=", rx140_pos)
    .return (rx140_cur)
  rx140_fail:
.annotate "line", 46
    (rx140_rep, rx140_pos, $I10, $P10) = rx140_cur."!mark_fail"(0)
    lt rx140_pos, -1, rx140_done
    eq rx140_pos, -1, rx140_fail
    jump $I10
  rx140_done:
    rx140_cur."!cursor_fail"()
    rx140_cur."!cursor_debug"("FAIL  ", "infix:sym<->")
    .return (rx140_cur)
    .return ()
.end


.namespace ["parrotlog";"Grammar"]
.sub "!PREFIX__infix:sym<->"  :subid("45_1269727965.58325") :method
.annotate "line", 46
    $P142 = self."!PREFIX__!subrule"("O", "-")
    new $P143, "ResizablePMCArray"
    push $P143, $P142
    .return ($P143)
.end

