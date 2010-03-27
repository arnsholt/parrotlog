
.namespace []
.sub "_block11"  :anon :subid("10_1269727966.54739")
.annotate "line", 0
    .const 'Sub' $P20 = "12_1269727966.54739" 
    capture_lex $P20
    .const 'Sub' $P13 = "11_1269727966.54739" 
    capture_lex $P13
.annotate "line", 3
    .const 'Sub' $P13 = "11_1269727966.54739" 
    capture_lex $P13
    .lex "print", $P13
.annotate "line", 8
    .const 'Sub' $P20 = "12_1269727966.54739" 
    capture_lex $P20
    .lex "say", $P20
.annotate "line", 1
    find_lex $P27, "print"
    find_lex $P28, "say"
    .return ($P28)
.end


.namespace []
.sub "print"  :subid("11_1269727966.54739") :outer("10_1269727966.54739")
    .param pmc param_16 :slurpy
.annotate "line", 3
    new $P15, 'ExceptionHandler'
    set_addr $P15, control_14
    $P15."handle_types"(58)
    push_eh $P15
    .lex "@args", param_16
.annotate "line", 4
    find_lex $P17, "@args"
    join $S18, "", $P17
    print $S18
.annotate "line", 3
    .return (1)
  control_14:
    .local pmc exception 
    .get_results (exception) 
    getattribute $P19, exception, "payload"
    .return ($P19)
.end


.namespace []
.sub "say"  :subid("12_1269727966.54739") :outer("10_1269727966.54739")
    .param pmc param_23 :slurpy
.annotate "line", 8
    new $P22, 'ExceptionHandler'
    set_addr $P22, control_21
    $P22."handle_types"(58)
    push_eh $P22
    .lex "@args", param_23
.annotate "line", 9
    find_lex $P24, "@args"
    join $S25, "", $P24
    say $S25
.annotate "line", 8
    .return (1)
  control_21:
    .local pmc exception 
    .get_results (exception) 
    getattribute $P26, exception, "payload"
    .return ($P26)
.end

