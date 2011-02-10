# vim:syntax=perl6
class Parrotlog::Compiler is HLL::Compiler;

our $origpaths;
our $origdecl;
our $paths;

INIT {
    Parrotlog::Compiler.language('Parrotlog');
    Parrotlog::Compiler.parsegrammar(Parrotlog::Grammar);
    Parrotlog::Compiler.parseactions(Parrotlog::Actions);

    $origpaths := PAST::Var.new(:name<origpaths>, :scope<lexical>);
    $origdecl := PAST::Var.new(:name<origpaths>, :scope<parameter>);
    $paths := PAST::Var.new(:name<paths>, :scope<lexical>);
}

method command_line(@args, *%adverbs) {
    my $parrotclass := self.HOW.get_parrotclass(self);
    my $parent := $parrotclass.parents[0];
    my $method := $parent.find_method('command_line');
    my $*DIRECTIVES := 0;
    return $method(self, @args, |%adverbs);
}

method evalfiles($files, *@args, *%adverbs) {
    my $parrotclass := self.HOW.get_parrotclass(self);
    my $parent := $parrotclass.parents[0];
    my $method := $parent.find_method('evalfiles');
    my $*DIRECTIVES := 1;
    return $method(self, $files, |@args, |%adverbs);
}

method past($source, *%adverbs) {
    my $ast := $source.ast;
    # Main driver code. On program start, set up backtracking stack and call
    # main/0.
    my $past := PAST::Block.new(:hll<parrotlog>, :blocktype<immediate>);

    $past.push: PAST::Var.new(:scope<lexical>, :name<paths>, :isdecl,
        :viviself(call_internal('paths')));

    # Call main/0 on the initial pass, jump to error condition on backtrack.
    $past.push: PAST::Op.new(:pasttype<unless>,
        PAST::Op.new(:pirop<isnull>, $paths),
        PAST::Op.new(:name<main/0>, :pasttype<call>, $paths),
        PAST::Op.new(:inline("    say '# OHNOES TEH MANATEE'"))); # XXX: Final failure code goes here.

    # Compile all the clauses.
    for $ast -> $predicate {
        $past.push: compile_predicate($predicate, $ast{$predicate});
    }

    return $past;
}

sub compile_predicate($predicate, $clauses) {
    my $block := PAST::Block.new(:name($predicate), :blocktype<declaration>);

    # Find the arity of the predicate.
    my $a_clause := $clauses[0];
    $a_clause := $a_clause.args[0]
        if $a_clause.arity == 2 && $a_clause.functor eq ':-';
    my $arity := $a_clause.arity;

    my @args;
    $block.push: $origdecl;
    @args.push: $origpaths;
    my $i := 0;
    while $i < $arity {
        $i++;
        my $name := "arg" ~ $i;
        $block.push: PAST::Var.new(:name($name), :scope<parameter>);
        @args.push: PAST::Var.new(:name($name), :scope<lexical>);
    }

    $block.push: PAST::Var.new(:name<paths>, :scope<lexical>, :isdecl,
        :viviself(@args[0]));

    $block.push: compile_clauses($clauses, @args);

    return $block;
}

sub compile_clauses(@clauses, @args) {
    if @clauses {
        my $clause := @clauses.shift;
        return choicepoint(
            compile_clause($clause, @args),
            compile_clauses(@clauses, @args));
    }
    else {
        return call_internal('fail', @args[0]);
    }
}

sub compile_clause($clause, @args) {
    my $head;
    my $body;
    if $clause.arity == 2 && $clause.functor eq ':-' {
        $head := $clause.args[0];
        $body := $clause.args[1];
    }
    else {
        $head := $clause;
    }

    my $past := PAST::Block.new(:blocktype<immediate>);

    my %vars;
    for $clause.variable_set.contents -> $var {
        $past.push: PAST::Var.new(:name($var), :isdecl, :scope<lexical>,
            :viviself(variable($var)));
        %vars{$var} := PAST::Var.new(:name($var), :scope<lexical>);
    }

    # Section 7.6.1, converting a term to the head of a clause.
    my $i := 0;
    for $head.args -> $arg {
        $past.push: procedure_call(
            '=/2',
            $paths,
            @args[$i+1],
            $head.args[$i].past);
        $i++;
    }

    $past.push: $body.as_query
        if pir::defined($body);
    $past.push: $paths;

    return $past;
}

sub choicepoint($first, $second) {
    return PAST::Stmts.new(
        PAST::Op.new(:pasttype<bind>,
            $paths,
            call_internal('choicepoint', $paths)),
        PAST::Op.new(:pasttype<unless>,
            PAST::Op.new(:pirop<isnull>, $paths),
            $first,
            $second)
    );
}

sub call_internal($function, *@args) {
    return PAST::Op.new(:pasttype<call>,
        # XXX: This has the potential for breakage if weird names are passed in.
        PAST::Op.new(:inline("    %r = get_root_global ['_parrotlog'], '$function'")),
        |@args);
}

sub variable($name?) {
    my $obj :=  PAST::Op.new(
        :inline("    %r = root_new ['_parrotlog'; 'Variable']"));
    if pir::defined($name) {
        return PAST::Stmts.new(
            PAST::Op.new(:pasttype<callmethod>, :name<name>,
                $obj,
                PAST::Val.new(:value($name))),
            $obj);
    }
    else {
        return $obj;
    }
}

sub procedure_call($name, *@args) {
    return PAST::Op.new(:pasttype<bind>,
        $paths,
        PAST::Op.new(:pasttype<call>, :name($name), |@args));
}
