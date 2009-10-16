#############################################################################
##
#W  pcpexpo.gi                   Polycyc                         Bettina Eick
##

#############################################################################
##
#F ReducingCoefficient( <g>, <h> ) . . . . . . . . .f with g * h^-f = 1 mod r
#F ReducingCoefficient( <a>, <b>, <r> ) . . . . . . . . . . . . . . a/b mod r
##
ReducingCoefficient := function( arg )
    local e, f, a, b, r, n;

    if Length( arg ) = 2 then
        a := LeadingExponent( arg[1] );
        b := LeadingExponent( arg[2] );
        r := FactorOrder( arg[1] );
        n := IsBound( arg[2]!.normed ) and arg[2]!.normed;
    elif Length( arg ) = 3 then
        a := arg[1];
        b := arg[2];
        r := arg[3];
        n := false;
    fi;

    if b = 0 then
        return fail;

    elif b = 1 then
        return a;

    elif r = 0 then
        e := a/b;
        if not IsInt( e ) then return fail; fi;
        return e;

    elif IsPrime( r ) then
        return a/b mod r;

    elif n then
        f := a/b;
        if not IsInt( f ) then return fail; fi;
        return f mod r;

    else
        e := Gcdex( r, b );
        f := a / e.gcd;
        if not IsInt(f) then return fail; fi;
        return f * e.coeff2 mod r;
    fi;
end;

#############################################################################
##
#F ReducedByIgs( <igs>, <g> ) 
##
InstallGlobalFunction( ReducedByIgs, function( igs, g )
    local  dep, j, e;

    if Length( igs ) = 0 then return g; fi;
    dep := List( igs, Depth );
    j   := Position( dep, Depth(g) );
    while not IsBool( j ) do
        e  := ReducingCoefficient( g, igs[j] );
        if IsBool( e ) then return g; fi;
        g  := g * igs[j]^-e;
        j  := Position( dep, Depth( g ) );
    od;
    return g;
end );

#############################################################################
##
#F ExponentsByIgs( igs, g ) . . . . . . . . . . .exponents of g wrt to an igs
##
## Note that this functions returns fail, if g is not in <pcs>.
##
InstallGlobalFunction( ExponentsByIgs, function( pcs, g )
    local dep, exp, j, e; 

    # pcs is an induced pc sequence
    dep := List( pcs, Depth );
    exp := List( pcs, x -> 0 );

    # go through and reduce
    j   := Position( dep, Depth(g) );
    while not IsBool( j ) do
        e  := ReducingCoefficient( g, pcs[j] );
        if IsBool( e ) then return fail; fi;
        exp[j] := e;
        g := pcs[j]^-e * g;
        j := Position( dep, Depth(g) );
    od;

    # return exp or fail
    if g <> g^0 then return fail; fi;
    return exp;
end );

#############################################################################
##
#F ReduceByRels( rels, exp )
##
ReduceByRels := function( rels, exp )
    local i;
    for i in [1..Length(exp)] do
        if rels[i] > 0 then exp[i] := exp[i] mod rels[i]; fi;
    od;
    return exp;
end;

#############################################################################
##
#F ExponentsByPcp( pcp, g ).. . . . . . . . . . . . .  exponents of g wrt pcp
##
## Note that this function might return fail, if g is not in <pcp>. But
## it might also just return a wrong exponent vector.
##
InstallGlobalFunction( ExponentsByPcp, function( pcp, g )
    local gens, rels, dept, pcpN, depN, exp, d, j, e, i;

    # the trivial case
    if Length( pcp ) = 0 then return []; fi;

    # first the special case of tail pcps
    if IsList( pcp!.tail ) then
        exp := Exponents(g){pcp!.tail};
        if IsBound( pcp!.mult ) then
            for i in [1..Length(exp)] do
                if pcp!.rels[i] = 0 then 
                    exp[i] := exp[i] / pcp!.mult[i];
                else
                    exp[i] := exp[i] / pcp!.mult[i] mod pcp!.rels[i];
                fi;
            od;
        else
            for i in [1..Length(exp)] do
                if pcp!.rels[i] <> 0 then 
                    exp[i] := exp[i] mod pcp!.rels[i];
                fi;
            od;
        fi;
        if IsBound( pcp!.cyc ) then 
            exp := TranslateExp( pcp!.cyc, exp );
        fi;
        return exp;
    fi;

    # get info from pcp
    gens := pcp!.gens;
    rels := pcp!.rels;
    dept := List( gens, Depth );
    exp  := List( gens, x -> 0 );
    if Length( gens ) = 0 then return exp; fi;

    # get denominator pcp - might be the empty list
    pcpN := DenominatorOfPcp( pcp );
    depN := List( pcpN, Depth );
    
    # go through and reduce g 
    d := Depth( g );
    while d < pcp!.tail and (d in dept or d in depN) do

        # get exponent in pcpF
        if d in dept then
            j := Position( dept, d );
            e := ReducingCoefficient( g, gens[j] );
            if IsBool( e ) then return fail; fi;
            if rels[j] > 0 then e := e mod rels[j]; fi;
            exp[j] := e;
            g := gens[j]^-e * g;
        fi;

        # reduce with pcpN
        if d in depN and Depth( g ) = d then
            j := Position( depN, d );
            e := ReducingCoefficient( g, pcpN[j] );
            if IsBool( e ) then return fail; fi;
            g := pcpN[j]^-e * g;
        fi;

        # if g has still depth d then there is something wrong
        if Depth(g) <= d then 
            Error("wrong reduction in ExponentsByPcp");
        fi;
    
        d := Depth( g );
    od;

    # if it is an snf pcp then we need to rewrite exponents
    if IsBound( pcp!.cyc ) then exp := TranslateExp( pcp!.cyc, exp ); fi;

    # finally return
    return exp;
end );

