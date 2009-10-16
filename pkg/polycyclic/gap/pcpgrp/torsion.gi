############################################################################
##
#W  torsion.gi                   Polycyc                         Bettina Eick
##

############################################################################
##
#F TorsionSubgroup( H )
##
## Let T be the set of all elements of finite order in H. If T is a subgroup
## of H, then it is called the torsion subgroup of H. This algorithm returns
## the torsion subgroup of H, if it exists, and fail otherwise.
##
## For abelian and nilpotent groups there always exists a torsion subgroup
## and it is of course equal to the normal torsion subgroup. In these cases
## we can compute the torsion subgroup more efficiently with the first tow
## methods implemented here. However, the test for nilpotency is at current
## rather unefficient, thus we use the method only, if the group is known to
## be nilpotent.
##
TorsionSubgroupAbelianPcpGroup := function( G )
    local pcp, rels, subs;
    pcp := Pcp( G, "snf" );
    rels := RelativeOrdersOfPcp( pcp );
    subs := Filtered( [1..Length(pcp)], x -> rels[x] > 0 );
    return Subgroup( G, pcp{subs} );
end;

TorsionSubgroupNilpotentPcpGroup := function( G )
    local U, D, pcp, rels, subs;
    U := ShallowCopy( G );
    while not IsFinite( U ) do
        D := DerivedSubgroup( U );
        Info( InfoPcpGrp, 1, "got layer ", RelativeOrdersOfPcp( Pcp(U,D) ) );
        pcp := Pcp( U, D, "snf" );
        rels := RelativeOrdersOfPcp( pcp );
        Info( InfoPcpGrp, 1, "reduced to orders ", rels );
        subs := Filtered( [1..Length(pcp)], x -> rels[x] > 0 );
        U :=  SubgroupByIgs( G, Igs(D), pcp{subs} );
    od;
    return U;
end;

TorsionSubgroupPcpGroup := function( G )
    local efa, m, T, sub, i, pcp, gens, rels, H, N, new, com, g; 

    # set up
    efa := PcpsOfEfaSeries( G );
    
    # get the finite bit at the bottom of efa
    m := Length( efa );
    T := [];
    while m >= 1 and RelativeOrdersOfPcp( efa[m] )[1] > 0 do
        T := AddIgsToIgs( GeneratorsOfPcp( efa[m] ), T );
        m := m - 1;
    od;
    T := SubgroupByIgs( G, T );
    sub := [];

    # loop over the rest 
    for i in Reversed( [1..m] ) do

        # get the abelian layer
        pcp  := efa[i];
        gens := GeneratorsOfPcp( pcp );
        rels := RelativeOrdersOfPcp( pcp );
        Info( InfoPcpGrp, 1, "start layer of orders ", rels );

        # if it is finite, then we compute
        if rels[1] <> 0 then

            H := SubgroupByIgs( G, DenominatorOfPcp( efa[i] ) );
            for g in gens do
                N := ShallowCopy( H ); 
                H := SubgroupByIgs( G, AddIgsToIgs( [g], Igs( N ) ) );

                # compute complement to N in H mod T
                new := ExtendedSeriesPcps( sub, N );
                com := ComplementClassesEfaPcps( H, H, new );

                # check classes
                if Length( com ) = 1 and IndexNC( H, com[1].norm ) = 1 then
                    T := com[1].repr;
                    sub := ModuloSeriesPcps( sub, T!.compgens, "snf" );
                elif Length( com ) > 0 then
                    return fail;
                fi;
            od;
            sub := ExtendedSeriesPcps( sub, GroupOfPcp( pcp ) );
        else
            sub := Concatenation( [pcp], sub );
        fi;
    od;
    return T;
end;

InstallMethod( TorsionSubgroup, true, [IsPcpGroup], 0,
function( G )
    local U;
    if IsAbelian(G) then
        U := TorsionSubgroupAbelianPcpGroup( G );
    elif HasIsNilpotentGroup( G ) and IsNilpotentGroup(G) then
        U := TorsionSubgroupNilpotentPcpGroup( G );
    else
        U := TorsionSubgroupPcpGroup( G ); 
    fi; 
    if not IsBool(U) then 
        SetNormalTorsionSubgroup( G, U );
        SetIsTorsionFree( G, Size(U)=1 );
    fi;
    return U;
end );

#############################################################################
##
#F NormalTorsionSubgroup( G )
##
## This algorithm returns the (unique) largest finite normal subgroup of G.
##
NormalTorsionSubgroupPcpGroup := function( G )
    local efa, m, T, sub, i, pcp, gens, rels, H, N, new, com, g; 

    # set up
    efa := PcpsOfEfaSeries( G );
    
    # get the finite bit at the bottom of efa
    m := Length( efa );
    T := [];
    while m >= 1 and RelativeOrdersOfPcp( efa[m] )[1] > 0 do
        T := AddIgsToIgs( GeneratorsOfPcp( efa[m] ), T );
        m := m - 1;
    od;
    T := SubgroupByIgs( G, T );
    sub := [ ];

    # loop over the rest 
    for i in Reversed( [1..m] ) do

        # get the abelian layer
        pcp  := efa[i];
        gens := GeneratorsOfPcp( pcp );
        rels := RelativeOrdersOfPcp( pcp );
        Info( InfoPcpGrp, 1, "start layer of orders ", rels );

        # if it is finite, then we compute
        if rels[1] <> 0 then

            H := SubgroupByIgs( G, DenominatorOfPcp( efa[i] ) );
            for g in gens do
                N := ShallowCopy( H ); 
                H := SubgroupByIgs( G, AddIgsToIgs( [g], Igs(N) ));

                # compute complement to N in H mod T
                new := ExtendedSeriesPcps( sub, N );
                com := InvariantComplementsEfaPcps( H, H, new );

                # check classes
                if Length( com ) > 0 then
                    T := com[1];
                    sub := ModuloSeriesPcps( sub, T!.compgens, "snf" );
                fi;
            od;
            sub := ExtendedSeriesPcps( sub, GroupOfPcp( pcp ) );
        else
            sub := Concatenation( [pcp], sub );
        fi;
    od;
    return T;
end;

InstallMethod( NormalTorsionSubgroup, true, [IsPcpGroup], 0,
function( G )
    if IsAbelian(G) then
        return TorsionSubgroupAbelianPcpGroup( G );
    elif HasIsNilpotentGroup( G ) and IsNilpotentGroup(G) then
        return TorsionSubgroupNilpotentPcpGroup( G );
    else
        return NormalTorsionSubgroupPcpGroup( G );
    fi; 
end );

#############################################################################
##
#F IsTorsionFree( G )
##
IsTorsionFreePcpGroup := function( G )
    local pcs, rel, n, i, N, K, com;

    # the trival group
    if Size(G) = 1 then return true; fi;

    # now check
    pcs := RefinedIgs( G );
    rel := pcs.rel; pcs := pcs.pcs;
    if ForAll( rel, x -> x > 0 ) then return false; fi;
    n := Length( pcs );
    i := First( Reversed( [1..n] ), x -> rel[x] = 0 );
    if i < n then return false; fi;

    # loop upwards
    while i >= 1 do
        if rel[i] > 0 then

            # compute subgroups
            N := Subgroup( G, pcs{[i+1..n]} );
            K := Subgroup( G, pcs{[i..n]} );

            # compute complements
            com := ComplementClasses( K, N );

            # check them
            if Length( com ) > 0 then return false; fi;
        fi;
        i := i - 1;
    od;
    return true;
end;

InstallMethod( IsTorsionFree, true, [IsPcpGroup], 0,
function( G ) return IsTorsionFreePcpGroup(G); end );

#############################################################################
##
#F IsSubbasis( big, small )
##
IsSubbasis := function( big, small )
    if Length( small ) >= Length( big ) then return false; fi;
    return ForAll( small, x -> not IsBool( SolutionMat( big, x ) ) );
end;

#############################################################################
##
#F OperationAndSpaces( pcpG, pcp )
##
OperationAndSpaces := function( pcpG, pcp )
    local act;

    # construct matrices
    act := rec();
    act.mats := LinearActionOnPcp( pcpG, pcp );
    act.dim  := Length(pcp);
    act.char := RelativeOrdersOfPcp( pcp )[1];

    # add spaces if useful
    if act.char > 0 then
        act.one  := IdentityMat( act.dim );
        act.cent := ForAll( act.mats, x -> x = act.one );
        if act.cent or act.char^act.dim <= 1000 then
            act.spaces := AllSubspaces( act.dim, act.char );
        fi;
    fi;
    return act;
end;

#############################################################################
##
#F TranslateAction( C, pcp, mats )
##
TranslateAction := function( C, pcp, mats )
    C.mats := List(C.factor, x -> MappedVector(ExponentsByPcp(pcp, x),mats));
    C.smats := List(C.super, x -> MappedVector(ExponentsByPcp(pcp, x),mats));
    if C.char > 0 then
        C.mats := C.mats * One( C.field );
        C.smats := C.smats * One( C.field );
    fi;
end;

#############################################################################
##
#F SubgroupBySubspace( pcp, exp )
##
SubgroupBySubspace := function( pcp, exp )
    local gens;
    gens := List( exp, x -> MappedVector( IntVector( x ), pcp ) );
    gens := AddIgsToIgs( gens, DenominatorOfPcp( pcp ) );
    return SubgroupByIgs( GroupOfPcp( pcp ), gens );
end;

#############################################################################
##
#F InduceMatricesAndExtension( C, sub )
##
InduceMatricesAndExtension := function( C, sub )
    local e, l, all, new, A, ext, i, r, j, tmp;

    if Length( sub ) = 0 then return; fi;

    e := Length( sub );
    l := Length( sub[1] );
    all := Concatenation( C.mats, C.smats );
    Add(all, IdentityMat(l, C.field));
    new := SMTX.SubQuotActions( all, sub, l, e, C.field, 2 );

    # get induced matrices
    C.mats := new.qmatrices{[1..Length(C.mats)]};
    C.smats := new.qmatrices{[Length(C.mats)+1..Length(all)-1]};

    # induce extension
    A := new.nbasis^-1;
    for i in [1..Length(C.extension)] do
        ext := [];
        for j in [e+1..l] do
            r := Sum( List( [1..l], k -> C.extension[i][k] * A[k][j] ) );
            Add( ext, r );
        od;
        C.extension[i] := ext;
     od;
     return;
end;

#############################################################################
##
#F InduceToFactor( C, sub )
##
## C.normal is el ab and sub is an invariant subspace
##
InduceToFactor := function( C, sub )
    local D, L;
      
    # make a copy and adjust this
    D := StructuralCopy( C );

    # adjust D.super
    if sub.stab <> AsList( D.super ) then
        D.smats := List( sub.stab, 
                x -> MappedVector( ExponentsByPcp( D.super, x), D.smats));
        D.super := sub.stab;
    fi;

    # adjust D.normal
    if Length( sub.repr ) > 0 then

        # adjust dim and one to correct dimension
        D.dim := Length(C.normal) - Length( sub.repr );
        D.one := IdentityMat( D.dim, D.field );          

        # adjust the layer pcp 
        L := SubgroupBySubspace( D.normal, sub.repr );
        D.normal := Pcp( GroupOfPcp( D.normal ), L );

        # induce matrices and add inverses
        InduceMatricesAndExtension( D, sub.repr );
    fi;
    return D;
end;

#############################################################################
##
#F SupplementClassesCR( C ) . . .  supplements to an elementary abelian layer
##
SupplementClassesCR := function( C )
    local orbs, com, orb, D, t;

    # catch a trivial case
    if Length( C.normal ) = 1 then 
        AddInversesCR( C );
        return ComplementClassesCR( C ); 
    fi;

    # compute all U-invariant submodules in A 
    orbs := OrbitsInvariantSubspaces( C, C.dim );

    # lift from U to R-classes of complements
    com := [];
    while Length( orbs ) > 0 do
        orb := orbs[Length(orbs)];
        Unbind( orbs[Length(orbs)] );
        D := InduceToFactor( C, orb );
        AddInversesCR( D );
        t := ComplementClassesCR( D );
        Append( com, t );
        if Length( t ) = 0 then
            orbs := Filtered( orbs, x -> not IsSubbasis( orb.repr, x.repr ) );
        fi;
    od;
    return com;
end;

#############################################################################
##
#F FiniteSubgroupClassesBySeries( N, G, pcps, avoid )
##
FiniteSubgroupClassesBySeries := function( arg )
    local N, G, pcps, avoid, pcpG, grps, pcp, act, new, grp, C, tmp, i, 
          rels, U;

    if Length( arg ) = 2 then 
        G := arg[1];
        N := G;
        pcps := arg[2];
        avoid := [];
    elif Length( arg ) = 4 then 
        N := arg[1];
        G := arg[2];
        pcps := arg[3];
        avoid := arg[4];
    fi;

    pcpG := Pcp( G );
    grps := [ rec( repr := G, norm := N )];
    for pcp in pcps do
        rels := RelativeOrdersOfPcp( pcp );
        Info( InfoPcpGrp, 1, "next layer of orders ", rels );
        Info( InfoPcpGrp, 1, " with ", Length(grps), " groups");
        act := OperationAndSpaces( pcpG, pcp );
        new := [];
        for i in [1..Length( grps ) ] do
            grp := grps[i];
            Info( InfoPcpGrp, 1, "  group number ", i );

            # set up class record
            C := rec( );
            C.group  := grp.repr;
            C.super  := Pcp( grp.norm, grp.repr ); 
            C.factor := Pcp( grp.repr, GroupOfPcp( pcp ) );
            C.normal := pcp;

            # add extension info
            AddFieldCR( C );
            AddRelatorsCR( C );

            # add action
            TranslateAction( C, pcpG, act.mats );

            # if it is free abelian, compute complements
            if C.char = 0 then
                AddInversesCR( C );
                tmp := ComplementClassesCR( C );
                Info( InfoPcpGrp, 1, "  computed ", Length(tmp), 
                      " complements");
            else
                if IsBound( act.spaces ) then C.spaces := act.spaces; fi;
                tmp := SupplementClassesCR( C );
                Info( InfoPcpGrp, 1, "  computed ", Length(tmp), 
                      " supplements");
            fi;
            if Length( avoid ) > 0 then 
                for U in avoid do
                    tmp := Filtered( tmp, x -> not IsSubgroup( U, x.repr ) );
                od;
            fi;
            Append( new, tmp );
        od;
        
        if C.char = 0 then
            grps := ShallowCopy( new );
        else
            Append( grps, new );
        fi;
    od;

    # translate to classes and return
    for i in [1..Length(grps)] do
        tmp := ConjugacyClassSubgroups( G, grps[i].repr );
        SetStabilizerOfExternalSet( tmp, grps[i].norm );
        grps[i] := tmp;
    od;
    return grps;
end;

#############################################################################
##
#F FiniteSubgroupClasses( G )
##
FiniteSubgroupClassesPcpGroup := function( G )
    return FiniteSubgroupClassesBySeries( G, PcpsOfEfaSeries(G) );
end;

InstallMethod( FiniteSubgroupClasses, true, [IsPcpGroup], 0,
function( G ) 
    return FiniteSubgroupClassesPcpGroup(G); 
end );

#############################################################################
##
#F RootSet( G, H ) . . . . . . . . . . . . . . . . . . . . . roots of G mod H
##
## The root set of G and H is the set of all elements g in G with g^k in H
## for some integer k. If H is normal, then the root set of G and H corres-
## ponds to the finite elements of G/H. If G/H has a torsion subgroup, then
## this is the root set. Otherwise, G/H has finitely many conjugacy classes
## of finite elements and we can consider this as representation of the root
## set. Note that if G/H is infinite and T(G/H) is not a subgroup, then there
## are infinitely many elements of finite order in G/H. 
##
InstallGlobalFunction( RootSet, function( G, H )
    local nat, F, T;
    if not IsNormal( G, H ) then
        Print("function is available for normal subgroups only");
        return fail;
    fi;
    nat := NaturalHomomorphism( G, H );
    F   := Image( nat );
    T   := TorsionSubgroup( F );
    if T = fail then 
        Print( "RootSet is not a subgroup - not yet implemented" );
        return fail;
    fi;
    return PreImage( nat, T );
end );

