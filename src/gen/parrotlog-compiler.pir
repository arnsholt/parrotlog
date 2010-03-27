
.namespace []
.sub "_block11"  :anon :subid("10_1269727966.38371")
.annotate "line", 0
    get_hll_global $P14, ["parrotlog";"Compiler"], "_block13" 
    capture_lex $P14
.annotate "line", 3
    get_hll_global $P14, ["parrotlog";"Compiler"], "_block13" 
    capture_lex $P14
    $P20 = $P14()
.annotate "line", 1
    .return ($P20)
.end


.namespace []
.sub "" :load :init :subid("post12") :outer("10_1269727966.38371")
.annotate "line", 0
    .const 'Sub' $P12 = "10_1269727966.38371" 
    .local pmc block
    set block, $P12
    $P21 = get_root_global ["parrot"], "P6metaclass"
    $P21."new_class"("parrotlog::Compiler", "HLL::Compiler" :named("parent"))
.end


.namespace ["parrotlog";"Compiler"]
.sub "_block13"  :subid("11_1269727966.38371") :outer("10_1269727966.38371")
.annotate "line", 3
    .return ()
.end


.namespace ["parrotlog";"Compiler"]
.sub "" :load :init :subid("post13") :outer("11_1269727966.38371")
.annotate "line", 3
    get_hll_global $P14, ["parrotlog";"Compiler"], "_block13" 
    .local pmc block
    set block, $P14
.annotate "line", 4
    get_hll_global $P15, ["parrotlog"], "Compiler"
    $P15."language"("parrotlog")
.annotate "line", 5
    get_hll_global $P16, ["parrotlog"], "Compiler"
    get_hll_global $P17, ["parrotlog"], "Grammar"
    $P16."parsegrammar"($P17)
.annotate "line", 6
    get_hll_global $P18, ["parrotlog"], "Compiler"
    get_hll_global $P19, ["parrotlog"], "Actions"
    $P18."parseactions"($P19)
.end

