# vim:syntax=perl6

=begin spec

The spec gives five, mutually exclusive types for terms: variables, integers,
floating point numbers, atoms and compound terms (section 7.1).

Variables, atoms (as compound terms of arity 0) and compound terms we handle
properly already. Data types for ints and floats are still TODO.

=end spec

# PrologTerm: Base class for all Prolog types.
class PrologTerm {
    # Section 7.1.1.1, variable set of a term
    method variable_set() { pir::die("virtual method!"); }

    # Section 7.1.1.3, existential variables set of a term
    method existential_vars() { pir::die("virtual method!"); }

    # Section 7.1.1.4, free variables set of a term
    method free_vars($term) { pir::die("virtual method!"); }

    method past() { pir::die("virtual method!"); }
}

# Variables and terms. The variable code is largely inspired by the Perl code
# in this PerlMonks post:  http://www.perlmonks.org/?node_id=193649
=begin Variable

Variable is the internal data structure used for Prolog Variables.

=end Variable
class Variable is PrologTerm {
    has $!value;
    has $!name;

    method value() {
        if $!value ~~ Variable {
            return $!value.value;
        }
        else {
            return $!value;
        }
    }

    method name($name?) {
        if pir::defined($name) {
            $!name := $name;
        }

        return $!name;
    }

    method references($other) {
        if self =:= $other        { return 1; }
        elsif $!value ~~ Variable { return $!value.references($other); }
        else                      { return 0; }
    }

    method bind($other) {
        if $!value ~~ Variable {
            $!value.bind($other);
        }
        elsif $!value ~~ PrologTerm {
            pir::die("Attempted to bind bound Variable");
        }
        else {
            #if $other ~~ Variable
            if $other ~~ Variable {
                # Make sure $other isn't bound to self.
                return 0 if $other.references(self);
                $!value := $other;
            }
            elsif $other ~~ PrologTerm {
                $!value := $other;
            }
            else {
                my $class := pir::class__PP($other);
                pir::die("Can't bind object of class $class");
            }
        }
    }

    method bound() {
        if    $!value ~~ Variable   { return $!value.bound; }
        elsif $!value ~~ PrologTerm { return 1;}
        else                        { return 0; }
    }

    method unbind() {
        $!value := Undef;
    }

    method variable_set() {
        my $set := Set.new;
        # Only add self if it's a named variable.
        $set.add: $!name if pir::defined($!name);
        return $set;
    }

    method existential_vars() { return Set.new; }

    method free_vars($v) {
        # If the variable set of V contains the var the free variable set is
        # empty, else it's the variable set of the var.
        return $v.variable_set.contains(self) ?? Set.new !! self.variable_set;
    }

    method output() {
        # XXX: This can probably be improved.
        #return $!name ?? $!name !! '_';
        if self.bound {
            return $!value.output;
        }
        else {
            return $!name ?? $!name !! '_';
        }
    }

    method past() {
        if pir::defined($!name) {
            return PAST::Var.new(:name($!name), :scope<lexical>);
        }
        else {
            return PAST::Op.new(:inline("    %r = root_new ['_parrotlog'; 'Variable']"));
        }
    }

    method as_query($in_block = 0) {
        return Term.from_data('call', self).as_query;
    }
}

class Int is PrologTerm {
    has $!value;

    method create($value) {
        my $i := Int.new;
        $i.value($value);
        return $i;
    }

    method value($value?) {
        if pir::defined($value) {
            $!value := $value
        }

        return $!value;
    }

    method variable_set() { return Set.new; }
    method existential_vars() { return Set.new; }
    method free_vars($t) { return Set.new; }

    method output() { return "$!value" }

    method past() {
        my $class := PAST::Op.new(
            :inline("    %r = get_root_global ['_parrotlog'], 'Int'"));
        my $call := PAST::Op.new(:name<create>, :pasttype<callmethod>,
            $class,
            PAST::Val.new(:value($!value)));

        return $call;
    }

    method as_query($in_block = 0) {
        type_error('callable', self);
    }
}

class Float is PrologTerm {
    has $!value;

    method create($value) {
        my $f := Float.new;
        $f.value($value);
        return $f;
    }

    method value($value?) {
        if pir::defined($value) {
            $!value := $value
        }

        return $!value;
    }

    method variable_set() { return Set.new; }
    method existential_vars() { return Set.new; }
    method free_vars($t) { return Set.new; }

    method output() { return "$!value" }

    method past() {
        my $class := PAST::Op.new(
            :inline("    %r = get_root_global ['_parrotlog'], 'Float'"));
        my $call := PAST::Op.new(:name<create>, :pasttype<callmethod>,
            $class,
            PAST::Val.new(:value($!value)));

        return $call;
    }

    method as_query($in_block = 0) {
        type_error('callable', self);
    }
}

class Set {
    has %!set;

    method union($other) {
        self.add(|$other.contents);
    }

    method diff($other) {
        for $other.contents -> $key {
            pir::delete__vQS(%!set, $key);
        }
    }

    method add(*@items) {
        for @items -> $item {
            %!set{$item} := 1;
        }
    }

    method contains($item) {
        return pir::exists__iQP(%!set, $item);
    }

    method contents() {
        my @keys;
        for %!set {
            @keys.push: $_.key;
        }

        return @keys;
    }
}

sub unify($paths, $x, $y) {
    if !($x ~~ PrologTerm) || !($y ~~ PrologTerm) {
        my $xc := pir::class__PP($x);
        my $yc := pir::class__PP($y);
        pir::die("Attempting to unify() something that isn't a Variable or a Term ($xc, $yc)");
    }

    if $x =:= $y {
        # XXX: ATM NQP ignores bare returns, so we return a value.
        return 1;
    }

    if $x ~~ Term && $y ~~ Term {
        # First, check that the functors and arities are the same.
        if $x.functor ne $y.functor
        || $x.arity   != $y.arity {
            fail($paths);
        }

        # Then, make sure the argument lists unify as well.
        my $i := 0;
        my @x := $x.args;
        my @y := $y.args;
        while $i < $x.args {
            unify($paths, @x[$i], @y[$i]);
            $i++;
        }

        return 1;
    }
    elsif ($x ~~ Variable && $y ~~ PrologTerm)
    ||    ($x ~~ PrologTerm && $y ~~ Variable) {
        # To simplify control flow.
        if !($x ~~ Variable) {
            my $tmp := $x;
            $x := $y;
            $y := $tmp;
        }

        my $var := $x;
        my $term := $y;

        if $var.bound {
            unify($paths, $var.value, $term);
        }
        else {
            # When backtracking, variable bindings have to be undone. Instead
            # of having unify() return a new backtracking stack, we just
            # stealthily change the failure callback to unbind first.
            my $cc := Q:PIR {
                $P0 = find_lex '$paths'
                %r = getattribute $P0, 'car'
            };
            my $cb := sub () { $var.unbind; $cc(); }
            Q:PIR {
                $P1 = find_lex '$cb'
                setattribute $P0, 'car', $P1
            };
            $var.bind($term);
        }
    }
    elsif $x ~~ Variable && $y ~~ Variable {
        if $x.bound && $y.bound {
            unify($paths, $x.value, $y.value);
        }
        # One or both unbound.
        else {
            if $x.bound {
                my $tmp := $x;
                $x := $y;
                $y := $tmp;
            }

            # When backtracking, variable bindings have to be undone. Instead
            # of having unify() return a new backtracking stack, we just
            # stealthily change the failure callback to unbind first.
            my $cc := Q:PIR {
                $P0 = find_lex '$paths'
                %r = getattribute $P0, 'car'
            };
            my $cb := sub () { $x.unbind; $cc(); }
            Q:PIR {
                $P1 = find_lex '$cb'
                setattribute $P0, 'car', $P1
            };
            $x.bind($y);
        }
    }
    elsif $x ~~ Int && $y ~~ Int {
        fail($paths) if $x.value != $y.value;
    }
    elsif $x ~~ Float && $y ~~ Float {
        fail($paths) if $x.value != $y.value;
    }
    else {
        fail($paths);
    }
}

# Directives: section 7.4.2
our %directives;
# Because NQP doesn't support hash literals.
INIT {
    %directives<dynamic>         := dynamic;
    %directives<multifile>       := multifile;
    %directives<discontiguous>   := discontiguous;
    %directives<op>              := op;
    %directives<char_conversion> := char_conversion;
    %directives<initialization>  := initialization;
    %directives<include>         := include;
    %directives<ensure_loaded>   := ensure_loaded;
}

sub handle_directive($ast) {
    $ast := $ast.args[0];
    pir::die("Unknown directive {$ast.functor}") if !%directives{$ast.functor};
    %directives{$ast.functor}(|$ast.args);
}
