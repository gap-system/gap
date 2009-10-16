#############################################################################
##
#W  findex.gi                    Polycyc                         Bettina Eick
##
##  Conjugacy classes of subgroups of given index.
##

#############################################################################
##
#F SubgroupsFirstLayerByIndex( G, pcp, n ) 
##
## All subgroup of index dividing n.
##
SubgroupsFirstLayerByIndex := function( G, pcp, n )
    local m, p, l, d, idm, exp, i, t, j, f, c, denom, dep, ind, base, k, e;

    # set up
    p := RelativeOrdersOfPcp( pcp )[1];
    l := Length( pcp );

    # reset n, if the layer is finite, and compute divisors
    if p > 0 then 
        m := Gcd( n, p^l ); 
    else
        m := n;
    fi;
    d := Filtered( DivisorsInt( m ), x -> x <> m );
    if Length( d ) = 0 then 
        return [rec( repr := G, norm := G, open := n )];
    fi;
    
    # create all normed bases in m^l 
    idm := IdentityMat( l );
    exp := [[]];
    for i in [1..l] do

        # create subspaces of same dimension
        t := [];
        for e in exp do
            for j in [1..m^Length(e)-1] do
                f := StructuralCopy( e );
                c := CoefficientsQadic( j, m );
                for k in [1..Length(c)] do
                    f[k][i] := c[k];
                od;  
                Add( t, f );
            od;
        od;
        Append( exp, t );

        # add higher dimension
        t := [];
        for e in exp do
            for j in d do
                if ForAll( e, x -> x[i] < j ) then
                    f := StructuralCopy( e );
                    Add( f, idm[i] * j );
                    Add( t, f );
                fi;
            od;
        od;
        Append( exp, t );

    od;
            
    # convert each basis to a pcs
    denom := DenominatorOfPcp( pcp );
    for i in [1..Length(exp)] do
        e   := exp[i];
        dep := List( e, PositionNonZero );
        ind := List( [1..Length(e)], x -> e[x][dep[x]] );
        ind := Product( ind ) * m^(l - Length(e));
        if ind <= m then
            base := [];
            for k in [1..l] do
                j := Position( dep, k );
                if not IsBool( j ) then
                    Add( base, MappedVector( e[j], pcp ) );
                elif p = 0 then
                    Add( base, MappedVector( m * idm[k], pcp ) );
                fi;
            od;
            exp[i] := AddIgsToIgs( base, denom );
            exp[i] := rec( repr := SubgroupByIgs( G, exp[i] ),
                           norm := G,
                           open := n / ind );
            if not IsInt( exp[i].open ) then Error(); fi;
        else
            exp[i] := false;
        fi;
    od;
    return Filtered( exp, x -> not IsBool(x) );
end;

#############################################################################
##
#F MappedAction( gens, rec )
##
MappedAction := function( gens, act )
    return List(gens, x->MappedVector(ExponentsByPcp(act.pcp, x), act.mats));
end;

#############################################################################
##
#F LowIndexSubgroupsEaLayer( cl, pcp, d, act )
##
## Compute low-index subgroups in <cl> not containing the elementary abelian 
## subfactor corresponding to <pcp>. The index of the computed subgroups
## is limited by p^d.
##
LowIndexSubgroupsEaLayer := function( cl, pcp, d, act )
    local p, l, fld, C, modu, invs, orbs, com, o, sub, inv, e, stab, indu, 
          L, fac, new, i, tmp, t;

    # a first trivial case
    if d = 0 or Length( pcp ) = 0 then return []; fi;
    p := RelativeOrdersOfPcp(pcp)[1];
    l := Length( pcp );
    fld := GF(p);

    # create class record with action of U
    C := rec( group := cl.repr );
    C.normal := pcp;
    C.factor := Pcp( cl.repr, GroupOfPcp( pcp ) );
    C.super  := Pcp( cl.norm, cl.repr );

    # add matrix action on layer
    C.central := act.central;
    C.mats := MappedAction( C.factor, act ) * One( fld );
    C.smats := MappedAction( C.super, act ) * One( fld );

    # add info on extension
    AddFieldCR( C );
    AddRelatorsCR( C );
    AddOperationCR( C );

    # invariant subspaces
    orbs := OrbitsInvariantSubspaces( C, C.dim );
    com  := [];
    while Length( orbs ) > 0 do
        o := orbs[Length(orbs)];
        Unbind( orbs[Length(orbs)] );
        t := cl.open / p^(l - Length(o.repr));
        if IsInt( t ) then

            # copy sub and adjust the entries to the layer
            sub := InduceToFactor( C, o ); 
            AddInversesCR( sub );

            # finally, compute the desired complements
            new := ComplementClassesCR( sub );
            for i in [1..Length(new)] do new[i].open := t; od;
            Append( com, new );

            # if there are no complements, then reduce invs
            if Length( new ) = 0 then 
                orbs := Filtered( orbs, x -> not IsSubbasis( o.repr, x.repr ) );
            fi;
        fi;
    od;
    return com;
end;

#############################################################################
##
#F LowIndexSubgroupsFaLayer( cl, pcplist, l, act )
##
## Compute low-index subgroups in <cl> not containing the free abelian 
## subfactor corresponding to <pcp>. The index of the computed subgroups
## is limited by l.
##
LowIndexSubgroupsFaLayer := function( clG, adj, l, act )
    local fac, grp, pr, todo, done, news, i, use, cl, d, tmp;

    fac := Collected( Factors( l ) );
    grp := [clG];
    for pr in fac do
        todo := ShallowCopy( grp );
        done := [];
        news := [];
        for i in [1..pr[2]] do
            use := adj[pr[1]][i];
            for cl in todo do
                d   := ValuationInt( cl.open, pr[1] );
                tmp := LowIndexSubgroupsEaLayer( cl, use, d, act );
                Append( news, tmp );
            od;
            Append( done, todo );
            todo := ShallowCopy( news );
            news := [];
        od;
        grp := Concatenation( done, todo );
    od;

    # return computed groups without the original group
    return grp{[2..Length(grp)]};
end;

#############################################################################
##
#F PowerPcpsByIndex( pcp, l )
##
PowerPcpsByIndex := function( pcp, l )
    local fac, ser, s, B, pr, i, A;

    # loop over series trough A/B
    fac := Collected( Factors( l ) );

    # create pcp's 
    ser := [];
    s   := 1;
    B   := GroupOfPcp( pcp );
    for pr in fac do
        ser[pr[1]] := [];
        for i in [1..pr[2]] do
            s := s * pr[1];
            A := ShallowCopy( B );
            B := SubgroupByIgs( GroupOfPcp( pcp ), 
                                 DenominatorOfPcp( pcp ), 
                                 List( pcp, x -> x^s ) );
            ser[pr[1]][i] := Pcp( A, B );
        od;
    od;
    return ser;
end;

#############################################################################
##
#F LowIndexSubgroupsBySeries( G, n, pcps )
##
LowIndexSubgroupsBySeries := function( G, n, pcps )
    local grps, all, i, pcp, p, A, mats, new, adj, cl, l, d, act, tmp; 

    # set up 
    all := Pcp( G );

    # the first layer
    grps := SubgroupsFirstLayerByIndex( G, pcps[1], n );

    # loop down the series
    for i in [2..Length(pcps)] do

        pcp := pcps[i];
        p   := RelativeOrdersOfPcp( pcp )[1];
        A   := GroupOfPcp( pcp );
        Info( InfoPcpGrp, 1, "starting layer ",i, " of type ",p, " ^ ",
               Length(pcp), " with ",Length(grps), " groups");

        # compute action on layer - note if it is central
        mats := List( all, x -> List(pcp, y -> ExponentsByPcp(pcp, y^x)));
        act := rec( pcp := all, mats := mats );
        act.central := ForAll( mats, x -> x = x^0 );

        # loop over all subgroups 
        new := [];
        adj := [];
        for cl in grps do

            # now pass it on
            l := cl.open;
            if l > 1 and p = 0 then
                if not IsBound( adj[l] ) then
                    adj[l] := PowerPcpsByIndex( pcp, l );
                fi;
                tmp := LowIndexSubgroupsFaLayer( cl, adj[l], l, act );
                Info( InfoPcpGrp, 2, " found ", Length(tmp), " new groups");
                Append( new, tmp );
            elif l > 1 then 
                d := ValuationInt( l, p );
                tmp := LowIndexSubgroupsEaLayer( cl, pcp, d, act );
                Info( InfoPcpGrp, 2, " found ", Length(tmp), " new groups");
                Append( new, tmp );
            fi;
        od;
        Append( grps, new );
    od;
    return Filtered( grps, x -> x.open = 1 );
end;

#############################################################################
##
#F LowIndexSubgroupClasses( G, n )
##
LowIndexSubgroupClassesPcpGroup := function( G, n )
    local efa, grps, i, tmp;

    # loop over series
    efa := PcpsOfEfaSeries( G );
    grps := LowIndexSubgroupsBySeries( G, n, efa );

    # translate to classes and return
    for i in [1..Length(grps)] do
        tmp := ConjugacyClassSubgroups( G, grps[i].repr );
        SetStabilizerOfExternalSet( tmp, grps[i].norm );
        grps[i] := tmp;
    od;
    return grps;
end;

InstallMethod( LowIndexSubgroupClassesOp, "for pcp groups",
               true, [IsPcpGroup, IsPosInt], 0,
function( G, n ) return LowIndexSubgroupClassesPcpGroup( G, n ); end );

