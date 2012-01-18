#############################################################################
##
#W  orbnorm.gi                   Polycyc                         Bettina Eick
##
##  The orbit-stabilizer algorithm for subgroups of Z^d.
##
if not IsBound( CHECK_INTNORM ) then CHECK_INTNORM := false; fi;

#############################################################################
##
#F Action functions OnVectorspace/LatticeBases( base, mat )
##
OnVectorspaceBases := function( base, mat )
    local imgs;
    imgs := base * mat;
    TriangulizeMat( imgs );
    return imgs;
end;

OnLatticeBases := function( base, mat )
    local imgs;
    imgs := base * mat;
    return NormalFormIntMat( imgs, 2 ).normal;
end;

#############################################################################
##
#F CheckNormalizer( G, S, linG, U )
##
CheckNormalizer := function( G, S, linG, U )
    local linS, m, u, R;

    # the trivial case
    if Length( Pcp(G) ) = 0 then return true; fi;

    # first check that S is stabilizing
    linS := InducedByPcp( Pcp(G), Pcp(S), linG );
    for m in linS do
        for u in U do
            if IsBool( PcpSolutionIntMat( U, u*m ) ) then return false; fi;
        od;
    od;

    # now consider the random stabilizer
    R := RandomPcpOrbitStabilizer( U, Pcp(G), linG, OnLatticeBases );
    if ForAny( R.stab, x -> not x in S ) then return false; fi;

    return true;
end;

#############################################################################
##
#F CheckConjugacy( G, g, linG, U, W )
##
CheckConjugacy := function( G, g, linG, U, W )
    local m, u;
    if Length( U ) <> Length( W ) then return IsBool( g ); fi;
    if Length(Pcp(G)) = 0 then return U = W; fi;
    m := InducedByPcp( Pcp(G), g, linG );
    for u in U do 
        if IsBool( PcpSolutionIntMat( W, u*m ) ) then return false; fi;
    od;
    return true;
end;
    
#############################################################################
##
#F BasisOfNormalizingSubfield( baseK, baseU )
##
BasisOfNormalizingSubfield := function( baseK, baseU )
    local d, e, baseL, i, syst, subs;
    d := Length(baseK);
    e := Length(baseU );
    baseL := IdentityMat( d );
    for i in [1..e] do
        syst := List( baseK, x -> baseU[i] * x );
        Append( syst, baseU );
        subs := TriangulizedNullspaceMat( syst );
        subs := subs{[1..Length(subs)]}{[1..d]};
        baseL := SumIntersectionMat( baseL, subs )[2];
    od;
    return List( baseL, x -> LinearCombination( baseK, x ) );
end;

#############################################################################
##
#F NormalizerHomogeneousAction( G, linG, baseU ) . . . . . . . . . . . N_G(U)
##
## V is a homogenous G-module via linG (and thus linG spans a field). 
## U is a subspace of V and baseU is an echelonised basis for U.
##
NormalizerHomogeneousAction := function( G, linG, baseU )
    local K, baseK, baseL, L, exp, U, linU;

    # check for trivial cases
    if ForAll(linG, x -> x = x^0) or Length(baseU) = 0 or 
       Length(baseU) = Length(baseU[1]) then return G; 
    fi;
    
    # get field
    K := FieldByMatricesNC( linG );
    baseK := BasisVectors( Basis( K ) );
    
    # determine normalizing subfield and its units
    baseL := BasisOfNormalizingSubfield( baseK, baseU );
    L := FieldByMatrixBasisNC( baseL );
    U := UnitGroup( L );
    linU := GeneratorsOfGroup(U);

    # find G cap L = G cap U as subgroup of G
    exp := IntersectionOfUnitSubgroups( K, linG, linU );
    return Subgroup( G, List( exp, x -> MappedVector( x, Pcp(G) ) ) );
end;

#############################################################################
##  
#F  ConjugatingFieldElement( baseK, baseU, baseW )  . . . . . . . . . U^k = W
##
ConjugatingFieldElement := function( baseK, baseU, baseW )
    local d, e, baseL, i, syst, subs, k;

    # compute the full space of conjugating elements
    d := Length(baseK);
    e := Length(baseW );
    baseL := IdentityMat( d );
    for i in [1..e] do
        syst := List( baseK, x -> baseU[i] * x );
        Append( syst, baseW );
        subs := TriangulizedNullspaceMat( syst );
        subs := subs{[1..Length(subs)]}{[1..d]};
        baseL := SumIntersectionMat( baseL, subs )[2];
    od;

    # if baseL is empty, then there is no solution
    if Length(baseL) = 0 then return false; fi;

    # get one (integral) solution
    k := baseL[Length(baseL)];
    k := k * Lcm( List( k, DenominatorRat ) );
    return LinearCombination( baseK, k ); 
end;

#############################################################################
##
#F ConjugacyHomogeneousAction( G, linG, baseU, baseW ) . . . . . . . U^g = W?
##
## V is a homogenous G-module via linG. U and W are subspaces of V with bases
## baseU and baseW, respectively. The function computes N_G(U) and U^g = W if
## g exists. If no g exists, then false is returned.
##
ConjugacyHomogeneousAction := function( G, linG, baseU, baseW )
    local K, baseK, baseL, L, U, a, f, b, C, g, N, k, h;

    # check for trivial cases
    if Length(baseU) <> Length(baseW) then return false; fi;
    if baseU = baseW then
       return rec( norm := NormalizerHomogeneousAction( G, linG, baseU ),
                   conj := One(G) );
    fi;

    # get field - we need the maximal order in this case!
    K := FieldByMatricesNC( linG );
    baseK := BasisVectors( MaximalOrderBasis( K ) );

    # determine conjugating field element
    k := ConjugatingFieldElement( baseK, baseW, baseU );
    if IsBool(k) then return false; fi;
    h := k^-1;

    # determine normalizing subfield
    baseL := BasisOfNormalizingSubfield( baseK, baseU );
    L := FieldByMatrixBasisNC( baseL );

    # get norm and root
    a := Determinant( k );
    f := Length(baseK) / Length(baseL);
    b := RootInt( a, f );
    if b^f <> a then return false; fi;

    # solve norm equation in L and sift 
    C := NormCosetsOfNumberField( L, b );
    C := List( C, x -> x * h );
    C := Filtered( C, x -> IsUnitOfNumberField( K, x ) );
    if Length(C) = 0 then return false; fi;

    # add unit group of L
    U := GeneratorsOfGroup(UnitGroup(L));
    C := rec( reprs := C, units := U{[2..Length(U)]} );

    # find an element of G cap Lh in G
    h := IntersectionOfTFUnitsByCosets( K, linG, C );
    if IsBool( h ) then return false; fi;
    g := MappedVector( h.repr, Pcp(G) );
    N := Subgroup( G, List( h.ints, x -> MappedVector( x, Pcp(G) ) ) );

    # that's it
    return rec( norm := N, conj := g );
end;

#############################################################################
##
#F AffineActionAsTensor( linG, nath )
##
AffineActionAsTensor := function( linG, nath )
    local actsF, actsS, affG, i, t, j, d, b;

    # action on T / S for T = U + S and action on S
    actsF := List(linG, x -> InducedActionFactorByNHLB(x, nath ));
    actsS := List(linG, x -> InducedActionSubspaceByNHLB(x, nath ));

    # determine affine action on H^1 wrt U
    affG := [];
    for i in [1..Length(linG)] do

        # the linear part is the diagonal action on the tensor
        t := KroneckerProduct( actsF[i], actsS[i] );
        for j in [1..Length(t)] do Add( t[j], 0 ); od;

        # the affine part is determined by the derivation wrt nath.factor
        b := PreimagesBasisOfNHLB( nath );
        d := (actsF[i]^-1 * b) * linG[i] - b;
        d := Flat( List( d, x -> ProjectionByNHLB( x, nath ) ) );
        Add( d, 1 ); 
        Add( t, d );

        # t is the affine action - store it
        Add( affG, t );
    od;
    return affG;
end;

#############################################################################
##
#F DifferenceVector( base, nath )
##
## Determines the vector (s1, ..., se) with nath.factor[i]+si in base.
##
DifferenceVector := function( base, nath )
    local b, k, f, v;
    b := PreimagesBasisOfNHLB( nath );
    k := KernelOfNHLB( nath );
    f := Concatenation( k, base );
    v := List(b, x -> PcpSolutionIntMat(f, x){[1..Length(k)]});
    v := - Flat(v);
    Add( v, 1 );
    return v;
end;

#############################################################################
##
#F NormalizerComplement( G, linG, baseU, baseS ) . . . . . . . . . . . N_G(U)
##
## U and S are free abelian subgroups of V such that U cap S = 0. The group
## acts via linG on the full space V. 
##
NormalizerComplement := function( G, linG, baseU, baseS )
    local baseT, nathT, affG, e;

    # catch the trivial cases
    if Length(baseS)=0 or Length(baseU)=0 then return G; fi;
    if ForAll( linG, x -> x = x^0 ) then return G; fi;

    baseT := LatticeBasis( Concatenation( baseU, baseS ) );
    nathT := NaturalHomomorphismByLattices( baseT, baseS );

    # compute a stabilizer under the affine action
    affG := AffineActionAsTensor( linG, nathT );
    e := DifferenceVector( baseU, nathT );
    return StabilizerIntegralAction( G, affG, e );
end;

#############################################################################
##
#F ConjugacyComplements( G, linG, baseU, baseW, baseS ) . . . . . . .U^g = W?
##
ConjugacyComplements := function( G, linG, baseU, baseW, baseS )
    local baseT, nathT, affG, e, f, os;

    # catch the trivial cases
    if Length(baseU)<>Length(baseW) then return false; fi;
    if baseU = baseW then return 
        rec( norm := NormalizerComplement( G, linG, baseU, baseS ),
             conj := One(G) );
    fi;

    baseT := LatticeBasis( Concatenation( baseU, baseS ) );
    nathT := NaturalHomomorphismByLattices( baseT, baseS );

    # compute the stabilizer of (0,..,0,1) under an affine action
    affG := AffineActionAsTensor( linG, nathT );
    e := DifferenceVector( baseU, nathT );
    f := DifferenceVector( baseW, nathT );
    os := OrbitIntegralAction( G, affG, e, f );
    if IsBool(os) then return os; fi;
    return rec( norm := os.stab, conj := os.prei );
end;

#############################################################################
##
#F NormalizerCongruenceAction( G, linG, baseU, ser ) . . . . . . . . . N_G(U)
##
NormalizerCongruenceAction := function( G, linG, baseU, ser )
    local V, S, i, d, linS, nath, indG, indS, U, M, I, H, subh, actS, T, F, 
          fach, UH, MH, s;

    # catch a trivial case
    if ForAll( linG, x -> x = x^0 ) then return G; fi;
    if Length(baseU) = 0 then return G; fi;

    # set up for induction over the module series
    V := IdentityMat( Length(baseU[1]) );
    S := G;

    # use induction over the module series
    for i in [1..Length(ser)-1] do
        d := Length( ser[i] ) - Length( ser[i+1] );
        Info( InfoIntNorm, 2, " ");
        Info( InfoIntNorm, 2, "  consider layer ", i, " of dim ",d);

        # do a check
        if Length(Pcp(S)) = 0 then return S; fi;

        # induce to the current layer V/ser[i+1];
        Info( InfoIntNorm, 2, "  induce to current layer");
        nath := NaturalHomomorphismByLattices( V, ser[i+1] );
        indG := List( linG, x -> InducedActionFactorByNHLB( x, nath ) );
        indS := InducedByPcp( Pcp(G), Pcp(S), indG );
        U := LatticeBasis( List( baseU, x -> ImageByNHLB( x, nath ) ) );
        M := LatticeBasis( List( ser[i], x -> ImageByNHLB( x, nath ) ) );
        F := IdentityMat(Length(indG[1]));

        # compute intersection
        I := StructuralCopy( LatticeIntersection( U, M ) );
        H := PurifyRationalBase( I );

        # first, use the action on the module M
        subh := NaturalHomomorphismByLattices( M, [] );
        actS := List( indS, x -> InducedActionFactorByNHLB( x, subh ) );
        I := LatticeBasis( List( I, x -> ImageByNHLB( x, subh ) ) );
        Info( InfoIntNorm, 2, "  normalize intersection ");  
        T := NormalizerHomogeneousAction( S, actS, I );
        if Length(Pcp(T)) = 0 then return T; fi;

        # reset action for the next step
        if Index(S,T) <> 1 then 
            indS := InducedByPcp( Pcp(G), Pcp(T), indG ); 
        fi;
        S := T;

        # next, consider the factor modulo the intersection hull H
        if Length(F) > Length(H) then 
            fach := NaturalHomomorphismByLattices( F, H );
            UH := LatticeBasis( List( U, x -> ImageByNHLB( x, fach ) ) );
            MH := LatticeBasis( List( M, x -> ImageByNHLB( x, fach ) ) );
            actS := List( indS, x -> InducedActionFactorByNHLB( x, fach ) );
            Info( InfoIntNorm, 2, "  normalize complement ");  
            T := NormalizerComplement( S, actS, UH, MH );
            if Length(Pcp(T)) = 0 then return T; fi;

            # again, reset action for the next step
            if Index(S,T) <> 1 then 
                indS := InducedByPcp( Pcp(G), Pcp(T), indG ); 
            fi;
            S := T;
        fi;

        # finally, add a finite orbit-stabilizer computation
        if H <> I then
            Info( InfoIntNorm, 2, "  add finite stabilizer computation");  
            s := PcpOrbitStabilizer( U, Pcp(S), indS, OnLatticeBases );
            S := SubgroupByIgs( S, s.stab );
        fi;
    od;
    Info( InfoIntNorm, 2, " "); 
    return S;
end;

#############################################################################
##
#F ConjugacyCongruenceAction( G, linG, baseU, baseW, ser ) . . . . . U^g = W?
##
ConjugacyCongruenceAction := function( G, linG, baseU, baseW, ser )
    local V, S, g, i, d, linS, moveW, nath, indS, U, W, M, IU, IW, H, F,
          subh, actS, s, UH, WH, MH, j, fach, indG;

    # catch some trivial cases
    if baseU = baseW then 
        return rec( norm := NormalizerCongruenceAction(G, linG, baseU, ser),
                    conj := One(G) ); 
    fi;
    if Length(baseU)<>Length(baseW) or ForAll( linG, x -> x = x^0 ) then 
        return false; 
    fi;

    # set up
    V := IdentityMat( Length(baseU[1]) );
    S := G;
    g := One( G );

    # use induction over the module series
    for i in [1..Length(ser)-1] do
        d := Length( ser[i] ) - Length( ser[i+1] );
        Info( InfoIntNorm, 2, " "); 
        Info( InfoIntNorm, 2, "  consider layer ", i, " of dim ",d);

        # get action of S on the full space
        moveW := LatticeBasis( baseW * InducedByPcp( Pcp(G), g, linG )^-1 );

        # do a check 
        if Length(Pcp(S))=0 and baseU<>moveW then return false; fi;
        if Length(Pcp(S))=0 and baseU=moveW then 
            return rec( norm := S, conj := g ); 
        fi;

        # induce to the current layer V/ser[i+1];
        Info( InfoIntNorm, 2, "  induce to layer ");
        nath := NaturalHomomorphismByLattices( V, ser[i+1] );
        indG := List( linG, x -> InducedActionFactorByNHLB( x, nath ) );
        indS := InducedByPcp( Pcp(G), Pcp(S), indG );
        U := LatticeBasis( List( baseU, x -> ImageByNHLB( x, nath ) ) );
        W := LatticeBasis( List( moveW, x -> ImageByNHLB( x, nath ) ) );
        M := LatticeBasis( List( ser[i], x -> ImageByNHLB( x, nath ) ) );
        F := IdentityMat(Length(indG[1]));

        # get intersections
        IU := LatticeIntersection( U, M );
        IW := LatticeIntersection( W, M );
        H := PurifyRationalBase( IU );

        # first, use action on the module M
        subh := NaturalHomomorphismByLattices( M, [] );
        actS := List( indS, x -> InducedActionFactorByNHLB( x, subh ) );
        IU := LatticeBasis( List( IU, x -> ImageByNHLB( x, subh ) ) );
        IW := LatticeBasis( List( IW, x -> ImageByNHLB( x, subh ) ) );
        Info( InfoIntNorm, 2, "  conjugate intersections ");
        s := ConjugacyHomogeneousAction( S, actS, IU, IW );
        if IsBool(s) then return false; fi;

        # reset action for next step
        g := g * s.conj;
        W := LatticeBasis( W * InducedByPcp( Pcp(G), s.conj, indG )^-1 );
        if Index(S,s.norm)<>1 then 
            indS := InducedByPcp(Pcp(G),Pcp(s.norm),indG); 
        fi;
        S := s.norm;

        # next, consider factor modulo the intersection hull H
        if Length(F) > Length(H) then 
            fach := NaturalHomomorphismByLattices( F, H );
            UH := LatticeBasis( List( U, x -> ImageByNHLB( x, fach ) ) );
            WH := LatticeBasis( List( W, x -> ImageByNHLB( x, fach ) ) );
            MH := LatticeBasis( List( M, x -> ImageByNHLB( x, fach ) ) );
            actS := List( indS, x -> InducedActionFactorByNHLB( x, fach ) );
            Info( InfoIntNorm, 2, "  conjugate complements ");
            s := ConjugacyComplements( S, actS, UH, WH, MH );
            if IsBool(s) then return false; fi;

            # again, reset action
            g := g * s.conj;
            W := LatticeBasis( W * InducedByPcp( Pcp(G), s.conj, indG )^-1 );
            if Index(S,s.norm)<>1 then 
                indS := InducedByPcp(Pcp(G),Pcp(s.norm),indG); 
            fi;
            S := s.norm;
        fi;

        # finally, add a finite orbit-stabilizer computation
        if H <> IU then 
            Info( InfoIntNorm, 2, "  add finite stabilizer computation");
            s := PcpOrbitStabilizer( U, Pcp(S), indS, OnLatticeBases );
            j := Position( s.orbit, W );
            if IsBool(j) then return false; fi;
            g := g * TransversalElement( j, s, One(G) );
            S := SubgroupByIgs( S, s.stab );
        fi;
        
    od;
    Info( InfoIntNorm, 2, " "); 
    return rec( norm := S, conj := g );
end;

#############################################################################
##
#F NormalizerIntegralAction( G, linG, U ) . . . . . . . . . . . . . . .N_G(U)
##
# FIXME: This function is documented and should be turned into a GlobalFunction
NormalizerIntegralAction := function( G, linG, U )
    local gensU, d, e, F, t, I, S, linS, K, linK, ser, T, orbf, N;

    # catch a trivial case
    if ForAll( linG, x -> x = x^0 ) then return G; fi;

    # do a check
    gensU := LatticeBasis( U );
    if gensU <> U then Error("function needs lattice basis as input"); fi;

    # get generators and check for trivial case
    if Length( U ) = 0 then return G; fi;
    d := Length( U[1] );
    e := Length( U );

    # compute modulo 3 first
    Info( InfoIntNorm, 1, "reducing by orbit-stabilizer mod 3");
    F := GF(3);
    t := InducedByField( linG, F );
    I := VectorspaceBasis( U * One(F) );
    S := PcpOrbitStabilizer( I, Pcp(G), t, OnVectorspaceBases );
    S := SubgroupByIgs( G, S.stab );
    linS := InducedByPcp( Pcp(G), Pcp(S), linG );

    # use congruence kernel
    Info( InfoIntNorm, 1, "determining 3-congruence subgroup");
    K := KernelOfFiniteMatrixAction( S, linS, F );
    linK := InducedByPcp( Pcp(G), Pcp(K), linG );

    # compute homogeneous series
    Info( InfoIntNorm, 1, "computing module series");
    ser := HomogeneousSeriesOfRationalModule( linG, linK, d );
    ser := List( ser, x -> PurifyRationalBase(x) );

    # get N_K(U)
    Info( InfoIntNorm, 1, "adding stabilizer for congruence subgroup");
    T := NormalizerCongruenceAction( K, linK, U, ser );

    # set up orbit stabilizer function for K
    orbf := function( K, actK, a, b )
            local o;
            o := ConjugacyCongruenceAction( K, actK, a, b, ser );
            if IsBool(o) then return o; fi;
            return o.conj;
            end;

    # add remaining stabilizer
    Info( InfoIntNorm, 1, "constructing block orbit-stabilizer");
    N := ExtendOrbitStabilizer( U, K, linK, S, linS, orbf, OnLatticeBases );
    N := AddIgsToIgs( N.stab, Igs(T) );
    N := SubgroupByIgs( G, N );

    # do a temporary check
    if CHECK_INTNORM then
        Info( InfoIntNorm, 1, "checking results");
        if not CheckNormalizer(G, N, linG, U) then
            Error("wrong norm in integral action");
        fi;
    fi;

    # now return
    return N;
end;

#############################################################################
##
#F ConjugacyIntegralAction( G, linG, U, W ) . . . . . . . . . . . . .U^g = W?
##
## returns N_G(U) and g in G with U^g = W if g exists.
## returns false otherwise.
##
# FIXME: This function is documented and should be turned into a GlobalFunction
ConjugacyIntegralAction := function( G, linG, U, W )
    local F, t, I, J, os, j, g, L, S, linS, K, linK, ser, orbf, h, T; 

    # do a check
    if U <> LatticeBasis(U) or W <> LatticeBasis(W) then 
        Error("function needs lattice bases as input"); 
    fi;

    # catch some trivial cases
    if U = W then
        return rec( norm := NormalizerIntegralAction(G, linG, U),
                    prei := One( G ) );
    fi;
    if Length(U)<>Length(W) or ForAll( linG, x -> x = x^0 ) then
        return false;
    fi;

    # compute modulo 3 first
    Info( InfoIntNorm, 1, "reducing by orbit-stabilizer mod 3");
    F := GF(3);
    t := InducedByField( linG, F );
    I := VectorspaceBasis( U * One(F) );
    J := VectorspaceBasis( W * One(F) );
    os := PcpOrbitStabilizer( I, Pcp(G), t, OnVectorspaceBases );
    j := Position( os.orbit, J );
    if IsBool(j) then return false; fi;
    g := TransversalElement( j, os, One(G) );
    L := LatticeBasis( W * InducedByPcp( Pcp(G), g, linG )^-1 );
    S := SubgroupByIgs( G, os.stab );
    linS := InducedByPcp( Pcp(G), Pcp(S), linG );

    # use congruence kernel
    Info( InfoIntNorm, 1, "determining 3-congruence subgroup");
    K := KernelOfFiniteMatrixAction( S, linS, F );
    linK := InducedByPcp( Pcp(G), Pcp(K), linG );

    # compute homogeneous series
    Info( InfoIntNorm, 1, "computing module series");
    ser := HomogeneousSeriesOfRationalModule( linG, linK, Length(U[1]) );
    ser := List( ser, x -> PurifyRationalBase(x) );

    # set up orbit stabilizer function for K
    orbf := function( K, linK, a, b )
            local o;
            o := ConjugacyCongruenceAction( K, linK, a, b, ser );
            if IsBool(o) then return o; fi;
            return o.conj;
            end;

    # determine block orbit and stabilizer
    Info( InfoIntNorm, 1, "constructing block orbit-stabilizer");
    os := ExtendOrbitStabilizer( U, K, linK, S, linS, orbf, OnRight );

    # get orbit element and preimage
    j := FindPosition( os.orbit, L, K, linK, orbf );
    if IsBool(j) then return false; fi;
    h := TransversalElement( j, os, One(G) );
    L := LatticeBasis( L * InducedByPcp( Pcp(G), h, linG )^-1 );
    g := orbf( K, linK, U, L ) * h * g;

    # get Stab_K(e) and thus Stab_G(e)
    Info( InfoIntNorm, 1, "adding stabilizer for congruence subgroup");
    T := NormalizerCongruenceAction( K, linK, U, ser );
    t := AddIgsToIgs( os.stab, Igs(T) );
    T := SubgroupByIgs( T, t );

    # do a temporary check
    if CHECK_INTNORM then
        Info( InfoIntNorm, 1, "checking results");
        if not CheckNormalizer( G, T, linG, U) then  
            Error("wrong norm in integral action"); 
        elif not CheckConjugacy(G, g, linG, U, W) then 
            Error("wrong conjugate in integral action"); 
        fi;
    fi;

    # now return
    return rec( stab := T, prei := g );
end;

