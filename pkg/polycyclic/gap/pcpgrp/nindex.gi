#############################################################################
##
#W  nindex.gi                    Polycyc                         Bettina Eick
##
##  A method to compute the normal subgroups of given index.
##

#############################################################################
##
#F LowIndexNormalsEaLayer( G, U, pcp, d, act )
##
## Compute low-index subgroups in <cl> not containing the elementary abelian 
## subfactor corresponding to <pcp>. The index of the computed subgroups
## is limited by p^d.
##
LowIndexNormalsEaLayer := function( G, U, pcp, d, act )
    local p, l, fld, C, modu, invs, orbs, com, o, sub, inv, e, stab, indu, 
          L, fac, new, i, tmp, mats, t;

    # a first trivial case
    if d = 0 or Length( pcp ) = 0 then return []; fi;
    p := RelativeOrdersOfPcp(pcp)[1];
    l := Length( pcp );
    fld := GF(p);

    # create class record with action of U
    C := rec( group := U );
    C.normal := pcp;
    C.factor := Pcp( U, GroupOfPcp( pcp ) );
    C.super  := Pcp( G, U );

    # add matrix action on layer
    C.mats := MappedAction( C.factor, act ) * One( fld );
    C.smats := MappedAction( C.super, act ) * One( fld );

    # add info on extension
    AddFieldCR( C );
    AddRelatorsCR( C );
    AddOperationCR( C );

    # invariant subspaces
    mats := Concatenation( C.mats, C.smats );
    modu := GModuleByMats( mats, C.dim, C.field );
    invs := MTX.BasesSubmodules( modu );
    invs := Filtered( invs, x -> Length( x ) < C.dim );
    invs := Filtered( invs, x -> l - Length( x ) <= d );
    com  := [];
    while Length( invs ) > 0 do
        o := invs[Length(invs)];
        Unbind( invs[Length(invs)] );
        t := U!.open / p^(l - Length(o));
        if IsInt( t ) then

            # copy sub and adjust the entries to the layer
            sub := InduceToFactor(C, rec(repr := o,stab := AsList(C.super))); 
            AddInversesCR( sub );

            # compute the desired complements
            new := InvariantComplementsCR( sub );
    
            # add information on index
            for i in [1..Length(new)] do new[i]!.open := t; od;
    
            # append them
            Append( com, new );

            # if there are no complements, then reduce invs
            if Length( new ) = 0 then 
                invs := Filtered( invs, x -> not IsSubbasis( o, x ) );
            fi;
        fi;
    od;
    return com;
end;

#############################################################################
##
#F LowIndexNormalsFaLayer( cl, pcplist, l, act )
##
## Compute low-index subgroups in <cl> not containing the free abelian 
## subfactor corresponding to <pcp>. The index of the computed subgroups
## is limited by l.
##
LowIndexNormalsFaLayer := function( G, U, adj, l, act )
    local m, L, fac, grp, pr, todo, done, news, i, use, cl, d, tmp;

    fac := Collected( Factors( l ) );
    grp := [U];
    for pr in fac do
        todo := ShallowCopy( grp );
        done := [];
        news := [];
        for i in [1..pr[2]] do
           use := adj[pr[1]][i];
           for L in todo do
                d   := ValuationInt( L!.open, pr[1] );
                tmp := LowIndexNormalsEaLayer( G, L, use, d, act );
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
#F LowIndexNormalsBySeries( G, n, pcps )
##
LowIndexNormalsBySeries := function( G, n, pcps )
    local U, grps, all, i, pcp, p, A, mats, new, adj, cl, l, d, act, tmp; 

    # set up 
    all := Pcp( G );

    # the first layer
    grps := SubgroupsFirstLayerByIndex( G, pcps[1], n );
    for i in [1..Length(grps)] do
        grps[i].repr!.open := grps[i].open;
        grps[i] := grps[i].repr;
    od;

    # loop down the series
    for i in [2..Length(pcps)] do

        pcp := pcps[i];
        p   := RelativeOrdersOfPcp( pcp )[1];
        A   := GroupOfPcp( pcp );
        Info( InfoPcpGrp, 1, "starting layer ",i, " of type ",p, " ^ ",
               Length(pcp), " with ",Length(grps), " groups");

        # compute action on layer
        mats := List( all, x -> List(pcp, y -> ExponentsByPcp(pcp, y^x)));
        act := rec( pcp := all, mats := mats );

        # loop over all subgroups 
        new := [];
        adj := [];
        for U in grps do

            # now pass it on
            l := U!.open;
            if l > 1 and p = 0 then
                if not IsBound( adj[l] ) then
                    adj[l] := PowerPcpsByIndex( pcp, l );
                fi;
                tmp := LowIndexNormalsFaLayer( G, U, adj[l], l, act );
                Info( InfoPcpGrp, 2, " found ", Length(tmp), " new groups");
                Append( new, tmp );
            elif l > 1 then 
                d := ValuationInt( l, p );
                tmp := LowIndexNormalsEaLayer( G, U, pcp, d, act );
                Info( InfoPcpGrp, 2, " found ", Length(tmp), " new groups");
                Append( new, tmp );
            fi;
        od;
        Append( grps, new );
    od;
    return Filtered( grps, x -> x!.open = 1 );
end;

#############################################################################
##
#F LowIndexNormalSubgroups( G, n )
##
LowIndexNormalSubgroupsPcpGroup := function( G, n )
    local efa;
    if n = 1 then return [G]; fi;
    efa := PcpsOfEfaSeries( G );
    return LowIndexNormalsBySeries( G, n, efa );
end;

InstallMethod( LowIndexNormalSubgroupsOp, "for pcp groups",
               true, [IsPcpGroup, IsPosInt], 0,
function( G, n ) return LowIndexNormalSubgroupsPcpGroup( G, n ); end );

#############################################################################
##
#F NilpotentByAbelianNormalSubgroup( G )
##
## Use the LowIndexNormals function to find a normal subgroup which is
## nilpotent - by - abelian. Every polycyclic group has such a normal
## subgroup.
##
## This is usually done more effectively by NilpotenByAbelianByFiniteSeries.
## We only use this function as alternative for special cases.
##
InstallGlobalFunction( NilpotentByAbelianNormalSubgroup, function( G )
    local sub, i, j, f, N, low, L;

    if IsNilpotent( DerivedSubgroup( G ) ) then return G; fi;
    sub := [[G]];
    while true do
        i := Length( sub ) + 1;
        sub[i] := [];
        Info( InfoPcpGrp, 1, "test normal subgroups of index ", i );
        f := Factors( i );
        j := i / f[1];
        for N in sub[j] do
            low := LowIndexNormalSubgroups( N, f[1] );
            for L in low do
                if IsNilpotent( DerivedSubgroup( L ) ) then
                    return L;
                else
                    AddSet( sub[i], L );
                fi;
            od;
        od;
    od;
end );


