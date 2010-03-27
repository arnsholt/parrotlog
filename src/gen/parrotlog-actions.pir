
.namespace []
.sub "_block11"  :anon :subid("10_1269727966.1586")
.annotate "line", 0
    get_hll_global $P14, ["parrotlog";"Actions"], "_block13" 
    capture_lex $P14
.annotate "line", 3
    get_hll_global $P14, ["parrotlog";"Actions"], "_block13" 
    capture_lex $P14
    $P176 = $P14()
.annotate "line", 1
    .return ($P176)
.end


.namespace []
.sub "" :load :init :subid("post25") :outer("10_1269727966.1586")
.annotate "line", 0
    .const 'Sub' $P12 = "10_1269727966.1586" 
    .local pmc block
    set block, $P12
    $P177 = get_root_global ["parrot"], "P6metaclass"
    $P177."new_class"("parrotlog::Actions", "HLL::Actions" :named("parent"))
.end


.namespace ["parrotlog";"Actions"]
.sub "_block13"  :subid("11_1269727966.1586") :outer("10_1269727966.1586")
.annotate "line", 3
    .const 'Sub' $P166 = "24_1269727966.1586" 
    capture_lex $P166
    .const 'Sub' $P156 = "23_1269727966.1586" 
    capture_lex $P156
    .const 'Sub' $P146 = "22_1269727966.1586" 
    capture_lex $P146
    .const 'Sub' $P136 = "21_1269727966.1586" 
    capture_lex $P136
    .const 'Sub' $P126 = "20_1269727966.1586" 
    capture_lex $P126
    .const 'Sub' $P99 = "18_1269727966.1586" 
    capture_lex $P99
    .const 'Sub' $P72 = "16_1269727966.1586" 
    capture_lex $P72
    .const 'Sub' $P55 = "15_1269727966.1586" 
    capture_lex $P55
    .const 'Sub' $P28 = "13_1269727966.1586" 
    capture_lex $P28
    .const 'Sub' $P15 = "12_1269727966.1586" 
    capture_lex $P15
.annotate "line", 35
    .const 'Sub' $P166 = "24_1269727966.1586" 
    capture_lex $P166
.annotate "line", 3
    .return ($P166)
.end


.namespace ["parrotlog";"Actions"]
.sub "TOP"  :subid("12_1269727966.1586") :method :outer("11_1269727966.1586")
    .param pmc param_18
.annotate "line", 3
    new $P17, 'ExceptionHandler'
    set_addr $P17, control_16
    $P17."handle_types"(58)
    push_eh $P17
    .lex "self", self
    .lex "$/", param_18
.annotate "line", 4
    find_lex $P19, "$/"
    get_hll_global $P20, ["PAST"], "Block"
    find_lex $P21, "$/"
    unless_null $P21, vivify_26
    new $P21, "Hash"
  vivify_26:
    set $P22, $P21["statementlist"]
    unless_null $P22, vivify_27
    new $P22, "Undef"
  vivify_27:
    $P23 = $P22."ast"()
    find_lex $P24, "$/"
    $P25 = $P20."new"($P23, "parrotlog" :named("hll"), $P24 :named("node"))
    $P26 = $P19."!make"($P25)
.annotate "line", 3
    .return ($P26)
  control_16:
    .local pmc exception 
    .get_results (exception) 
    getattribute $P27, exception, "payload"
    .return ($P27)
.end


.namespace ["parrotlog";"Actions"]
.sub "statementlist"  :subid("13_1269727966.1586") :method :outer("11_1269727966.1586")
    .param pmc param_31
.annotate "line", 7
    .const 'Sub' $P42 = "14_1269727966.1586" 
    capture_lex $P42
    new $P30, 'ExceptionHandler'
    set_addr $P30, control_29
    $P30."handle_types"(58)
    push_eh $P30
    .lex "self", self
    .lex "$/", param_31
.annotate "line", 8
    new $P32, "Undef"
    .lex "$past", $P32
    get_hll_global $P33, ["PAST"], "Stmts"
    find_lex $P34, "$/"
    $P35 = $P33."new"($P34 :named("node"))
    store_lex "$past", $P35
.annotate "line", 9
    find_lex $P37, "$/"
    unless_null $P37, vivify_28
    new $P37, "Hash"
  vivify_28:
    set $P38, $P37["statement"]
    unless_null $P38, vivify_29
    new $P38, "Undef"
  vivify_29:
    defined $I39, $P38
    unless $I39, for_undef_30
    iter $P36, $P38
    new $P49, 'ExceptionHandler'
    set_addr $P49, loop48_handler
    $P49."handle_types"(65, 67, 66)
    push_eh $P49
  loop48_test:
    unless $P36, loop48_done
    shift $P40, $P36
  loop48_redo:
    .const 'Sub' $P42 = "14_1269727966.1586" 
    capture_lex $P42
    $P42($P40)
  loop48_next:
    goto loop48_test
  loop48_handler:
    .local pmc exception 
    .get_results (exception) 
    getattribute $P50, exception, 'type'
    eq $P50, 65, loop48_next
    eq $P50, 67, loop48_redo
  loop48_done:
    pop_eh 
  for_undef_30:
.annotate "line", 10
    find_lex $P51, "$/"
    find_lex $P52, "$past"
    $P53 = $P51."!make"($P52)
.annotate "line", 7
    .return ($P53)
  control_29:
    .local pmc exception 
    .get_results (exception) 
    getattribute $P54, exception, "payload"
    .return ($P54)
.end


.namespace ["parrotlog";"Actions"]
.sub "_block41"  :anon :subid("14_1269727966.1586") :outer("13_1269727966.1586")
    .param pmc param_43
.annotate "line", 9
    .lex "$_", param_43
    find_lex $P44, "$past"
    find_lex $P45, "$_"
    $P46 = $P45."ast"()
    $P47 = $P44."push"($P46)
    .return ($P47)
.end


.namespace ["parrotlog";"Actions"]
.sub "statement"  :subid("15_1269727966.1586") :method :outer("11_1269727966.1586")
    .param pmc param_58
.annotate "line", 13
    new $P57, 'ExceptionHandler'
    set_addr $P57, control_56
    $P57."handle_types"(58)
    push_eh $P57
    .lex "self", self
    .lex "$/", param_58
.annotate "line", 14
    find_lex $P59, "$/"
    find_lex $P62, "$/"
    unless_null $P62, vivify_31
    new $P62, "Hash"
  vivify_31:
    set $P63, $P62["statement_control"]
    unless_null $P63, vivify_32
    new $P63, "Undef"
  vivify_32:
    if $P63, if_61
    find_lex $P67, "$/"
    unless_null $P67, vivify_33
    new $P67, "Hash"
  vivify_33:
    set $P68, $P67["EXPR"]
    unless_null $P68, vivify_34
    new $P68, "Undef"
  vivify_34:
    $P69 = $P68."ast"()
    set $P60, $P69
    goto if_61_end
  if_61:
    find_lex $P64, "$/"
    unless_null $P64, vivify_35
    new $P64, "Hash"
  vivify_35:
    set $P65, $P64["statement_control"]
    unless_null $P65, vivify_36
    new $P65, "Undef"
  vivify_36:
    $P66 = $P65."ast"()
    set $P60, $P66
  if_61_end:
    $P70 = $P59."!make"($P60)
.annotate "line", 13
    .return ($P70)
  control_56:
    .local pmc exception 
    .get_results (exception) 
    getattribute $P71, exception, "payload"
    .return ($P71)
.end


.namespace ["parrotlog";"Actions"]
.sub "statement_control:sym<say>"  :subid("16_1269727966.1586") :method :outer("11_1269727966.1586")
    .param pmc param_75
.annotate "line", 17
    .const 'Sub' $P86 = "17_1269727966.1586" 
    capture_lex $P86
    new $P74, 'ExceptionHandler'
    set_addr $P74, control_73
    $P74."handle_types"(58)
    push_eh $P74
    .lex "self", self
    .lex "$/", param_75
.annotate "line", 18
    new $P76, "Undef"
    .lex "$past", $P76
    get_hll_global $P77, ["PAST"], "Op"
    find_lex $P78, "$/"
    $P79 = $P77."new"("say" :named("name"), "call" :named("pasttype"), $P78 :named("node"))
    store_lex "$past", $P79
.annotate "line", 19
    find_lex $P81, "$/"
    unless_null $P81, vivify_37
    new $P81, "Hash"
  vivify_37:
    set $P82, $P81["EXPR"]
    unless_null $P82, vivify_38
    new $P82, "Undef"
  vivify_38:
    defined $I83, $P82
    unless $I83, for_undef_39
    iter $P80, $P82
    new $P93, 'ExceptionHandler'
    set_addr $P93, loop92_handler
    $P93."handle_types"(65, 67, 66)
    push_eh $P93
  loop92_test:
    unless $P80, loop92_done
    shift $P84, $P80
  loop92_redo:
    .const 'Sub' $P86 = "17_1269727966.1586" 
    capture_lex $P86
    $P86($P84)
  loop92_next:
    goto loop92_test
  loop92_handler:
    .local pmc exception 
    .get_results (exception) 
    getattribute $P94, exception, 'type'
    eq $P94, 65, loop92_next
    eq $P94, 67, loop92_redo
  loop92_done:
    pop_eh 
  for_undef_39:
.annotate "line", 20
    find_lex $P95, "$/"
    find_lex $P96, "$past"
    $P97 = $P95."!make"($P96)
.annotate "line", 17
    .return ($P97)
  control_73:
    .local pmc exception 
    .get_results (exception) 
    getattribute $P98, exception, "payload"
    .return ($P98)
.end


.namespace ["parrotlog";"Actions"]
.sub "_block85"  :anon :subid("17_1269727966.1586") :outer("16_1269727966.1586")
    .param pmc param_87
.annotate "line", 19
    .lex "$_", param_87
    find_lex $P88, "$past"
    find_lex $P89, "$_"
    $P90 = $P89."ast"()
    $P91 = $P88."push"($P90)
    .return ($P91)
.end


.namespace ["parrotlog";"Actions"]
.sub "statement_control:sym<print>"  :subid("18_1269727966.1586") :method :outer("11_1269727966.1586")
    .param pmc param_102
.annotate "line", 23
    .const 'Sub' $P113 = "19_1269727966.1586" 
    capture_lex $P113
    new $P101, 'ExceptionHandler'
    set_addr $P101, control_100
    $P101."handle_types"(58)
    push_eh $P101
    .lex "self", self
    .lex "$/", param_102
.annotate "line", 24
    new $P103, "Undef"
    .lex "$past", $P103
    get_hll_global $P104, ["PAST"], "Op"
    find_lex $P105, "$/"
    $P106 = $P104."new"("print" :named("name"), "call" :named("pasttype"), $P105 :named("node"))
    store_lex "$past", $P106
.annotate "line", 25
    find_lex $P108, "$/"
    unless_null $P108, vivify_40
    new $P108, "Hash"
  vivify_40:
    set $P109, $P108["EXPR"]
    unless_null $P109, vivify_41
    new $P109, "Undef"
  vivify_41:
    defined $I110, $P109
    unless $I110, for_undef_42
    iter $P107, $P109
    new $P120, 'ExceptionHandler'
    set_addr $P120, loop119_handler
    $P120."handle_types"(65, 67, 66)
    push_eh $P120
  loop119_test:
    unless $P107, loop119_done
    shift $P111, $P107
  loop119_redo:
    .const 'Sub' $P113 = "19_1269727966.1586" 
    capture_lex $P113
    $P113($P111)
  loop119_next:
    goto loop119_test
  loop119_handler:
    .local pmc exception 
    .get_results (exception) 
    getattribute $P121, exception, 'type'
    eq $P121, 65, loop119_next
    eq $P121, 67, loop119_redo
  loop119_done:
    pop_eh 
  for_undef_42:
.annotate "line", 26
    find_lex $P122, "$/"
    find_lex $P123, "$past"
    $P124 = $P122."!make"($P123)
.annotate "line", 23
    .return ($P124)
  control_100:
    .local pmc exception 
    .get_results (exception) 
    getattribute $P125, exception, "payload"
    .return ($P125)
.end


.namespace ["parrotlog";"Actions"]
.sub "_block112"  :anon :subid("19_1269727966.1586") :outer("18_1269727966.1586")
    .param pmc param_114
.annotate "line", 25
    .lex "$_", param_114
    find_lex $P115, "$past"
    find_lex $P116, "$_"
    $P117 = $P116."ast"()
    $P118 = $P115."push"($P117)
    .return ($P118)
.end


.namespace ["parrotlog";"Actions"]
.sub "term:sym<integer>"  :subid("20_1269727966.1586") :method :outer("11_1269727966.1586")
    .param pmc param_129
.annotate "line", 29
    new $P128, 'ExceptionHandler'
    set_addr $P128, control_127
    $P128."handle_types"(58)
    push_eh $P128
    .lex "self", self
    .lex "$/", param_129
    find_lex $P130, "$/"
    find_lex $P131, "$/"
    unless_null $P131, vivify_43
    new $P131, "Hash"
  vivify_43:
    set $P132, $P131["integer"]
    unless_null $P132, vivify_44
    new $P132, "Undef"
  vivify_44:
    $P133 = $P132."ast"()
    $P134 = $P130."!make"($P133)
    .return ($P134)
  control_127:
    .local pmc exception 
    .get_results (exception) 
    getattribute $P135, exception, "payload"
    .return ($P135)
.end


.namespace ["parrotlog";"Actions"]
.sub "term:sym<quote>"  :subid("21_1269727966.1586") :method :outer("11_1269727966.1586")
    .param pmc param_139
.annotate "line", 30
    new $P138, 'ExceptionHandler'
    set_addr $P138, control_137
    $P138."handle_types"(58)
    push_eh $P138
    .lex "self", self
    .lex "$/", param_139
    find_lex $P140, "$/"
    find_lex $P141, "$/"
    unless_null $P141, vivify_45
    new $P141, "Hash"
  vivify_45:
    set $P142, $P141["quote"]
    unless_null $P142, vivify_46
    new $P142, "Undef"
  vivify_46:
    $P143 = $P142."ast"()
    $P144 = $P140."!make"($P143)
    .return ($P144)
  control_137:
    .local pmc exception 
    .get_results (exception) 
    getattribute $P145, exception, "payload"
    .return ($P145)
.end


.namespace ["parrotlog";"Actions"]
.sub "quote:sym<'>"  :subid("22_1269727966.1586") :method :outer("11_1269727966.1586")
    .param pmc param_149
.annotate "line", 32
    new $P148, 'ExceptionHandler'
    set_addr $P148, control_147
    $P148."handle_types"(58)
    push_eh $P148
    .lex "self", self
    .lex "$/", param_149
    find_lex $P150, "$/"
    find_lex $P151, "$/"
    unless_null $P151, vivify_47
    new $P151, "Hash"
  vivify_47:
    set $P152, $P151["quote_EXPR"]
    unless_null $P152, vivify_48
    new $P152, "Undef"
  vivify_48:
    $P153 = $P152."ast"()
    $P154 = $P150."!make"($P153)
    .return ($P154)
  control_147:
    .local pmc exception 
    .get_results (exception) 
    getattribute $P155, exception, "payload"
    .return ($P155)
.end


.namespace ["parrotlog";"Actions"]
.sub "quote:sym<\">"  :subid("23_1269727966.1586") :method :outer("11_1269727966.1586")
    .param pmc param_159
.annotate "line", 33
    new $P158, 'ExceptionHandler'
    set_addr $P158, control_157
    $P158."handle_types"(58)
    push_eh $P158
    .lex "self", self
    .lex "$/", param_159
    find_lex $P160, "$/"
    find_lex $P161, "$/"
    unless_null $P161, vivify_49
    new $P161, "Hash"
  vivify_49:
    set $P162, $P161["quote_EXPR"]
    unless_null $P162, vivify_50
    new $P162, "Undef"
  vivify_50:
    $P163 = $P162."ast"()
    $P164 = $P160."!make"($P163)
    .return ($P164)
  control_157:
    .local pmc exception 
    .get_results (exception) 
    getattribute $P165, exception, "payload"
    .return ($P165)
.end


.namespace ["parrotlog";"Actions"]
.sub "circumfix:sym<( )>"  :subid("24_1269727966.1586") :method :outer("11_1269727966.1586")
    .param pmc param_169
.annotate "line", 35
    new $P168, 'ExceptionHandler'
    set_addr $P168, control_167
    $P168."handle_types"(58)
    push_eh $P168
    .lex "self", self
    .lex "$/", param_169
    find_lex $P170, "$/"
    find_lex $P171, "$/"
    unless_null $P171, vivify_51
    new $P171, "Hash"
  vivify_51:
    set $P172, $P171["EXPR"]
    unless_null $P172, vivify_52
    new $P172, "Undef"
  vivify_52:
    $P173 = $P172."ast"()
    $P174 = $P170."!make"($P173)
    .return ($P174)
  control_167:
    .local pmc exception 
    .get_results (exception) 
    getattribute $P175, exception, "payload"
    .return ($P175)
.end

