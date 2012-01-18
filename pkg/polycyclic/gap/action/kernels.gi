#############################################################################
##
#W  kernels.gi                   Polycyc                         Bettina Eick
##

#############################################################################
##
#F  InducedByPcp( pcpG, pcpU, actG )
##
InducedByPcp := function( pcpG, pcpU, actG )
    if IsMultiplicativeElement( pcpU ) then 
        return MappedVector( ExponentsByPcp( pcpG, pcpU ), actG );
    fi;
    if AsList(pcpU) = AsList(pcpG) then 
        return actG; 
    else
        return List(pcpU, x-> MappedVector(ExponentsByPcp(pcpG,x),actG));
    fi;
end;

#############################################################################
##
#W KernelOfFiniteMatrixAction( G, mats, f )
##
KernelOfFiniteMatrixAction := function( G, mats, f )
    local d, I, U, i, actU, stab;

    if Length( mats ) = 0 then return G; fi;
    d := Length( mats[1] );
    I := IdentityMat( d, f );

    # loop over basis and stabilize each point
    U := G;
    for i in [1..d] do
        actU := InducedByPcp( Pcp(G), Pcp(U), mats );
        stab := PcpOrbitStabilizer( I[i], Pcp(U), actU, OnRight );
        U := SubgroupByIgs( G, stab.stab );
    od;
    
    # that's it
    return U;
end;

#############################################################################
##
#W KernelOfFiniteAction( G, pcp )
##
## If pcp defines an elementary abelian layer, then we compute the kernel
## of the action of G. If pcp is free abelian, then we compute the kernel
## of the action mod 3.
##
KernelOfFiniteAction := function( G, pcp )
    local rels, p, f, pcpG, actG;
   
    # get the char and the field
    rels := RelativeOrdersOfPcp( pcp );
    p := rels[1];
    if p = 0 then p := 3; fi;
    f := GF(p);

    # get the action of G on pcp
    pcpG := Pcp(G);
    actG := LinearActionOnPcp( pcpG, pcp );
    actG := InducedByField( actG, f );

    # centralize
    return KernelOfFiniteMatrixAction( G, actG, f );
end;

#############################################################################
##
#F RelationLatticeMod( gens, f )
##
RelationLatticeMod := function( gens, f )
    local mats, l, pcgs, free, r, defn, g, e, null, base, i;

    # induce to f
    mats := InducedByField( gens, f );
    l := Length( mats );

    # compute independent gens
    pcgs := BasePcgsByPcFFEMatrices( mats );
    free := FreeGensByBasePcgs( pcgs );
    r := Length( free.gens );
    if r = 0 then return IdentityMat(l); fi;

    # set up relation system
    defn := [];
    for g in mats do
        e := ExponentsByBasePcgs( pcgs, g );
        Add( defn, e * free.prei );
    od;

    # solve it mod relative orders
    null := NullspaceMatMod( defn, free.rels );

    # determine lattice basis
    base := NormalFormIntMat( null, 2 ).normal;
    base := Filtered( base, x -> PositionNonZero(x) <= l );

    ## do a temporary check
    #for i in [1..Length(base)] do
    #    if not MappedVector( base[i], mats ) = mats[1]^0 then
    #        Error("found non-relation");
    #    fi;
    #od;

    return base;
end;

#############################################################################
##
#F IsRelation( mats, rel ) . . . . . . . .check if rel is a relation for mats
##
IsRelation := function( mats, rel )
    local   M1,  M2,  i;
    M1 := mats[1]^0;
    M2 := mats[1]^0;
    for i in [1..Length(mats)] do
        if rel[i] > 0 then
            M1 := M1*mats[i]^rel[i];
        elif rel[i] < 0 then
            M2 := M2*mats[i]^-rel[i];
        fi;
    od;
    return M1 = M2;
end;

#############################################################################
##
#F ApproxRelationLattice( mats, k, p ). .  . . . . . . . k step approximation
##
ApproxRelationLattice := function( mats, k, p )
    local lat, i, new, ind, len;

    # set up
    lat := IdentityMat( Length(mats) );

    # compute new lattices and intersect
    for i in [1..k] do
        p := NextPrimeInt(p);
        new := RelationLatticeMod( mats, GF(p) );
        lat := LatticeIntersection( lat, new );
    od;

    # find short vectors
    lat := LLLReducedBasis( lat ).basis;

    # did we find any relations?
    for i in [1..Length(lat)] do
        if not IsRelation( mats, lat[i] ) then lat[i] := false; fi;
    od;
    return rec( rels := Filtered( lat, x -> not IsBool(x) ), prime := p );
end;

#############################################################################
##
#F VerifyIndependence( mats )
##
VerifyIndependence := function( mats )
    local base, prim, dixn, done, L, p, i, N, w, d;

    if Length( mats ) = 1 and mats[1] <> mats[1]^0 then return true; fi;

    Print("   verifying linear independence \n");
    base := AlgebraBase( mats );
    d := Length( base );
    Print("     got ", Length( mats ), " generators and dimension ", d,"\n");

    if Length( mats ) >= d then return false; fi;
    prim := PrimitiveAlgebraElement( mats, base );
    Print("     computing dixon bound \n");
    dixn := Length(mats[1]) * LogDixonBound( mats, prim )^2;
    Print("     found ", dixn, "\n");
    done := false;

    # set up
    L := IdentityMat( Length(mats) );
    p := 1;

    while not done do
        Print("     next step verification \n");

        # compute new lattices and intersect
        for i in [1..d] do
            p := NextPrimeInt(p);
            N := RelationLatticeMod( mats, GF(p) );
            L := LatticeIntersection( L, N );
        od;

        # find short vectors
        L := LLLReducedBasis( L ).basis;
        w := Minimum( List( L, x -> x * x ) );
        Print("     got shortest vector ", w, "\n");

        # check dixon bound
        if w > dixn then return true; fi;

        # check rels
        for i in [1..Length(L)] do
            if IsRelation( mats, L[i] ) then return false; fi;
        od;
    od;
end;

#############################################################################
##
#W KernelOfCongruenceMatrixActionGAP( G, mats )  . . G acts as ss cong subgrp
##
## Warning: G must be integral!
##
if not IsBound( VERIFY ) then VERIFY := true; fi;
KernelOfCongruenceMatrixActionGAP := function( G, mats )
    local p, U, pcp, K, gens, acts, rell, tmps;

    # set up
    p := 1;
    U := DerivedSubgroup(G);
    pcp := Pcp( G );

    # now loop
    repeat 
        K := U;
        gens := Pcp( G, K );
        acts := InducedByPcp( pcp, gens, mats );
        rell := ApproxRelationLattice( acts, Length(acts[1]), p );
        tmps := List( rell.rels, x -> MappedVector( x, gens ) );
        tmps := AddToIgs( DenominatorOfPcp( gens ), tmps );
        U := SubgroupByIgs( G, tmps );
        p := rell.prime;
    until Index( G, U ) = 1 or Index( U, K ) = 1;

    # verify if desired
    if Index( G, U ) > 1 and VERIFY then
        gens := Pcp( G, U );
        acts := InducedByPcp( pcp, gens, mats );
        if not VerifyIndependence( acts ) then 
            Error("  generators are not linearly independent");
        fi;
    fi;

    # that's it
    return U;
end;

#############################################################################
##
#F KernelOfCongruenceMatrixActionKANT( G, mats ) . . G acts as ss cong subgrp
##
KernelOfCongruenceMatrixActionKANT := function( G, mats )
    local H, base, prim, fact, full, f, s, h, imats, F, rels, gens;

    # the trivial case
    if ForAll( mats, x -> x^0 = x ) then return G; fi;

    # split into irreducibles
    base := AlgebraBase( mats );
    prim := PrimitiveAlgebraElement( base, List( base, Flat ) );
    fact := Factors( prim.poly );

    # catch the trivial case first - for increased efficiency
    if Length(fact) = 1 then
        F := FieldByMatricesNC( mats );
        SetPrimitiveElement( F, prim.elem );
        SetDefiningPolynomial( F, prim.poly );
        rels := RelationLatticeOfTFUnits( F, mats );
        return Subgroup( G, List( rels, x -> MappedVector( x, Pcp(G) ) ) );
    fi;

    # loop over subspaces
    full := mats[1]^0;
    gens := AsList( Pcp(G) );
    H := G;
    for f in fact do

        # induce matrices if necessary
        if Index( G, H ) > 1 then 
            mats := List( rels, x -> MappedVector( x, mats ) );
            G := H;
        fi;

        # get subspace
        s := NullspaceRatMat( Value( f, prim.elem ) );
        h := NaturalHomomorphismBySemiEchelonBases( full, s );

        # induce to factor
        imats := List( mats, x -> InducedActionSubspaceByNHSEB( x, h ) );
        if ForAny( imats, x -> x <> x^0 ) then
            F := FieldByMatricesNC( mats );
            SetPrimitiveElement( F, prim.elem );
            SetDefiningPolynomial( F, prim.poly );

            # compute kernel
            rels := RelationLatticeOfTFUnits( F, imats );
    
            # set up for iteration
            gens := List( rels, x -> MappedVector( x, gens ) );
            H := Subgroup( G, gens );
        fi;
    od;
   
    # that's it
    return H;
end;

#############################################################################
##
#F KernelOfCongruenceMatrixAction( G, mats )  . . . . . . . . header function
##
if not IsBound( UseKANT ) then UseKANT := true; fi;
KernelOfCongruenceMatrixAction := function( G, mats )
    if ForAll( mats, x -> x = x^0 ) then return G; fi;
    if UseKANT then 
        return KernelOfCongruenceMatrixActionKANT( G, mats );
    else
        return KernelOfCongruenceMatrixActionGAP( G, mats );
    fi;
end;

#############################################################################
##
#F KernelOfCongruenceAction( G, pcp ) . . . . . . . .G acts as ss cong subgrp
##
KernelOfCongruenceAction := function( G, pcp )
    local mats;
    mats := LinearActionOnPcp( Pcp(G), pcp );
    return KernelOfCongruenceMatrixAction( G, mats );
end;

#############################################################################
##
#F MemberByCongruenceMatrixAction( G, mats, m ) . . G acts as irr cong subgrp
##
## So far, this works only if G is an integral group.
##
MemberByCongruenceMatrixAction := function( G, mats, m )
    local F, r, e;

    # get field
    F := FieldByMatricesNC( mats );

    # check whether m is a unit in F
    if not IsUnitOfNumberField( F, m ) then return false; fi;

    # check if m is in G
    r := RelationLatticeOfTFUnits( F, Concatenation( [m], mats ) )[1];
    if PositionNonZero( r ) > 1 or AbsInt( r[1] ) <> 1 then return false; fi;

    # now translate to G
    e := -r{[2..Length(r)]} * r[1];
    return MappedVector( e, Pcp(G) );
end;


