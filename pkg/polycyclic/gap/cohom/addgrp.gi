#############################################################################
##
#W  addgrp.gi                    Polycyc                         Bettina Eick
##
##  In our case cohomology groups are factors Z / B where Z and B are either 
##  free or elementary abelian. In the elementary abelian case we can repr.
##  such factors by vector spaces. In the free abelian case we need machery
##  for f.g. abelian groups in additive notation.
##

#############################################################################
##
#F AdditiveIgsParallel
##
AdditiveIgsParallel := function( gens, imgs )
    local n, zero, ind, indd, todo, tododo, g, gg, d, h, hh, k, eg, 
          eh, e, c, i, sub;

    if Length( gens ) = 0 then return [gens, imgs]; fi;

    # get information
    n    := Length( gens[1] );
    zero := 0 * gens[1];

    # create new list from pcs/ppcs
    ind  := List( [1..n], x -> false );
    indd := List( [1..n], x -> false );

    # create a to-do list from gens/pgens
    todo  := ShallowCopy( gens );
    tododo:= ShallowCopy( imgs );

    # loop over to-do list until it is empty
    # c := [];
    while Length( todo ) > 0  do
        g  := todo[Length(todo)];
        gg := tododo[Length(todo)];
        d  := PositionNonZero( g );
        Unbind( todo[Length(todo)] );
        Unbind( tododo[Length(tododo)] );

        # shift g into ind
        while d < n+1 do
            h  := ind[d];
            hh := indd[d];
            if not IsBool( h ) then

                # reduce g with h
                eg := g[d]; if IsFFE( eg ) then eg := IntFFE(eg); fi;
                eh := h[d]; if IsFFE( eh ) then eh := IntFFE(eh); fi;
                e  := Gcdex( eg, eh );

                # adjust ind[d] by gcd
                ind[d]  := (e.coeff1 * g) + (e.coeff2 * h);
                indd[d] := (e.coeff1 * gg) + (e.coeff2 * hh);
                # if e.coeff1 <> 0 then Add( c, d ); fi;

                # adjust g
                g  := (e.coeff3 * g) + (e.coeff4 * h);
                gg := (e.coeff3 * gg) + (e.coeff4 * hh);
            else

                # just add g into ind
                ind[d]  := g;
                indd[d] := gg;
                g  := 0 * g;
                gg := 0 * gg;
                # Add( c, d );
            fi;
            d := PositionNonZero( g );
        od;
    od;

    # return resulting list
    return [Filtered( ind, x -> not IsBool( x ) ),
            Filtered( indd, x -> not IsBool( x ) ) ];
end;

#############################################################################
##
#F AbelianExponents( g, gens, rels, pcpN )
##
AbelianExponents := function( g, gens, rels, pcpN )
    local dept, depN, exp, d, j, e, n;

    # get depths and set up
    dept := List( gens, PositionNonZero );
    depN := List( pcpN, PositionNonZero );
    exp  := List( gens, x -> 0 );
    n    := Length( gens[1] );
    if Length( gens ) = 0 then return exp; fi;

    # go through and reduce g
    d := PositionNonZero( g );
    g := ShallowCopy( g );
    while d <= n do

        # get exponent in pcpF
        if d in dept then
            j := Position( dept, d );
            e := ReducingCoefficient( g[d], gens[j][d], 0 );
            if IsBool( e ) then return fail; fi;
            if rels[j] > 0 then e := e mod rels[j]; fi;
            exp[j] := e;
            g := -e * gens[j] + g;
        fi;
        # reduce with pcpN
        if d in depN and PositionNonZero( g ) = d then
            j := Position( depN, d );
            e := ReducingCoefficient( g[d], pcpN[j][d], 0 );
            if IsBool( e ) then return fail; fi;
            g := -e * pcpN[j] + g;
        fi;

        # if g has still depth d then there is something wrong
        if PositionNonZero(g) <= d then
            Error("wrong reduction in ExponentsByPcp");
        fi;

        d := PositionNonZero( g );
    od;

    # finally return
    return exp;
end;

#############################################################################
##
#F AdditiveFactorPcp( base, sub, r )
##
## To describe factors of additive abelian groups. r = 0 or r = p.
## We assume that base is in upper triangular form, but sub can be an
## arbitrary basis.
##
AdditiveFactorPcp := function( base, sub, r )
    local denom, deps, prei, rels, h, d, j, e, gens, imgs, zero, new, k,
          full, n, fimg, news, exp, chng, mat, i, g, l, rimg, newr, newp, 
          oldg, t, invs, tmps;

    # triangulise sub
    if r = 0 then
        denom := TriangulizedIntegerMat( sub );
    else
        denom := ShallowCopy( sub );
        TriangulizeMat( denom );
    fi; 

    deps := List( denom, PositionNonZero );
    prei := [];
    rels := [];

    # get modulo generators and their relative orders
    for h in base do
        d := PositionNonZero( h );
        j := Position( deps, d );
        if IsBool( j ) then
            Add( rels, r );
            Add( prei, h );
        elif r = 0 then
            e := AbsInt( denom[j][d] / h[d] );
            if e > 1 then
                Add( rels, e );
                Add( prei, h );
            fi;
        fi;
    od;
    l := Length( rels );

    # catch a special case
    if l = 0 then
        return rec( gens := [],
                    rels := [],
                    imgs := List( base, x -> [] ),
                    prei := prei,
                    denom := denom );
    fi;

    # first the case that r = p
    if r > 0 then
        gens := MutableIdentityMat( l ) * One( GF(r) );
        zero := 0 * gens[1];
        full := Concatenation( prei, denom );
        fimg := Concatenation( gens, List( denom, x -> zero ) );
        news := AdditiveIgsParallel( full, fimg );
        imgs := [];

        # get images for base elements
        for h in base do
            j := Position( prei, h );
            if IsInt( j ) then
                Add( imgs, gens[j] );
            else
                t := SolutionMat( news[1], h );
                t := t * news[2];
                Add( imgs, t );
            fi;
        od;

        return rec( gens := gens,
                    rels := rels,
                    imgs := imgs,
                    prei := prei,
                    denom := denom );
    fi;

    # now we are in case r = 0 - get isomorphism type of image
    mat := [];
    for i in [1..l] do
        g := rels[i] * prei[i];
        exp := AbelianExponents( g, prei, rels, denom );
        exp[i] := exp[i] - rels[i];
        Add( mat, exp );
    od;
    #new  := SmithNormalFormSQ( mat );
    new  := NormalFormIntMat( mat, 13 );

    # rewrite rels and prei
    tmps := TransposedMat( new.coltrans );
    invs := InverseIntMat( new.coltrans );
    newr := [];
    newp := [];
    oldg := [];
    for i in [1..Length(new.normal)] do
        if new.normal[i][i] <> 1 then
            Add( newr, new.normal[i][i] );
            Add( newp, invs[i] * prei );
            Add( oldg, tmps[i] );
        fi;
    od;
    oldg := TransposedMat( oldg );

    # get images of gcc
    zero := 0 * oldg[1];
    full := Concatenation( prei, denom );
    fimg := Concatenation( oldg, List( denom, x -> zero ) );
    news := AdditiveIgsParallel( full, fimg );
    imgs := [];

    for h in base do
        j := Position( prei, h );
        if IsInt( j ) then
            t := oldg[j];
        else
            t := PcpSolutionIntMat( news[1], h );
            t := t * news[2];
        fi;
        t := ShallowCopy(t);
        for i in [1..Length(t)] do
            if newr[i] > 0 then
                t[i] := t[i] mod newr[i];
            fi;
        od;
        Add( imgs, t );
    od;

    return rec( gens := IdentityMat( Length( newr )),
                rels := newr,
                imgs := imgs,
                prei := newp,
                denom := denom );
end;

SizeAddFactor := function( fact )
    if ForAny( fact.rels, x -> x = 0 ) then 
        return infinity; 
    else 
        return Product( fact.rels );
    fi;
end;

ElementsAddFactor := function( fact )
    return ExponentsByRels( fact.rels );
end;


