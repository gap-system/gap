#############################################################################
##
#A  cryst2.gi                 Cryst library                      Bettina Eick
#A                                                              Franz G"ahler
#A                                                              Werner Nickel
##
#Y  Copyright 1997-1999  by  Bettina Eick,  Franz G"ahler  and  Werner Nickel
##
##  More methods for affine crystallographic groups
##

#############################################################################
##
#M  IsSolvableGroup( S ) . . . . . . . . . . . . . . . . . . .IsSolvableGroup
##
InstallMethod( IsSolvableGroup, 
    "for AffineCrystGroup, via PointGroup", 
    true, [ IsAffineCrystGroupOnLeftOrRight ], 0,
    S -> IsSolvableGroup( PointGroup( S ) ) );


#############################################################################
##
#M  IsCyclic( S ) . . . . . . . . . . . . . . . . . . . . . . . . . .IsCyclic
##
InstallMethod( IsCyclic, 
    "for AffineCrystGroup", 
    true, [ IsAffineCrystGroupOnLeftOrRight ], 0,
function( S )
    local P, T;
    P := PointGroup(S);
    T := TranslationBasis(S);
    if   Length(T) = 0 then
        return IsCyclic(P);
    elif Length(T) > 1 then
        return false;
    elif IsTrivial(P) then
        return true;
    else
        return IsCyclic(P) and T=CocVecs(S);
    fi;
end );


#############################################################################
##
#M  Index( G, H ) . . . . . . . . . . . . . . . . . . . . . . . . . . . Index
##
InstallMethod( IndexOp, "AffineCrystGroupOnRight", IsIdenticalObj, 
    [ IsAffineCrystGroupOnRight, IsAffineCrystGroupOnRight ], 0,
function( G, H )
    if not IsSubgroup( G, H ) then
        Error( "H must be a subgroup of G" );
    fi;
    return IndexNC( G, H );
end );

InstallMethod( IndexOp, "AffineCrystGroupOnLeft", IsIdenticalObj, 
    [ IsAffineCrystGroupOnLeft, IsAffineCrystGroupOnLeft ], 0,
function( G, H )
    if not IsSubgroup( G, H ) then
        Error( "H must be a subgroup of G" );
    fi;
    return IndexNC( G, H );
end );

InstallMethod( IndexNC, "AffineCrystGroupOnRight", IsIdenticalObj, 
    [ IsAffineCrystGroupOnRight, IsAffineCrystGroupOnRight ], 0,
function( G, H )
    local TG, TH, IP, M;
    TG := TranslationBasis( G );
    TH := TranslationBasis( H );
    if Length( TG ) > Length( TH ) then return infinity; fi;
    IP := Index( PointGroup( G ), PointGroup( H ) );
    if IsFinite( G ) then
        return IP;
    else
        M := List( TH, x -> SolutionMat( TG, x ) );
        return IP * DeterminantMat( M ); 
    fi;
end );

InstallMethod( IndexNC, "AffineCrystGroupOnLeft", IsIdenticalObj, 
    [ IsAffineCrystGroupOnLeft, IsAffineCrystGroupOnLeft ], 0,
function( G, H )
    local TG, TH, IP, M;
    TG := TranslationBasis( G );
    TH := TranslationBasis( H );
    if Length( TG ) > Length( TH ) then return infinity; fi;
    IP := Index( PointGroup( G ), PointGroup( H ) );
    if IsFinite( G ) then
        return IP;
    else
        M := List( TH, x -> SolutionMat( TG, x ) );
        return IP * DeterminantMat( M ); 
    fi;
end );


#############################################################################
##
#M  ClosureGroup( G, elm ) . . . . . . . . .closure of a group and an element
##
InstallMethod( ClosureGroup,
    "AffineCrystGroupOnRight method for group and element", IsCollsElms, 
    [ IsAffineCrystGroupOnRight, IsMultiplicativeElementWithInverse ], 0,
function( G, elm )

    local gens, C; 

    if not IsAffineMatrixOnRight( elm ) then
        Error( "elm must be an affine matrix acting OnRight" );
    fi;

    gens:= GeneratorsOfGroup( G );

    # try to avoid adding an element to a group that already contains it
    if elm in gens or elm^-1 in gens or elm = One( G ) then
        return G;
    fi;

    # make the closure group
    C := AffineCrystGroupOnRightNC( Concatenation( gens, [ elm ] ) );

    # if <G> is infinite then so is <C>
    if HasIsFinite( G ) and not IsFinite( G ) then
        SetIsFinite( C, false );
        SetSize( C, infinity );
    fi;

    return C;

end );

InstallMethod( ClosureGroup,
    "AffineCrystGroupOnLeft method for group and element", IsCollsElms, 
    [ IsAffineCrystGroupOnLeft, IsMultiplicativeElementWithInverse ], 0,
function( G, elm )

    local gens, C; 

    if not IsAffineMatrixOnLeft( elm ) then
        Error( "elm must be an affine matrix acting OnLeft" );
    fi;

    gens:= GeneratorsOfGroup( G );

    # try to avoid adding an element to a group that already contains it
    if elm in gens or elm^-1 in gens or elm = One( G ) then
        return G;
    fi;

    # make the closure group
    C := AffineCrystGroupOnLeftNC( Concatenation( gens, [ elm ] ) );

    # if <G> is infinite then so is <C>
    if HasIsFinite( G ) and not IsFinite( G ) then
        SetIsFinite( C, false );
        SetSize( C, infinity );
    fi;

    return C;

end );


#############################################################################
##
#M  ConjugateGroup( <G>, <g> ) . . . . . . . . . . . . . . . . ConjugateGroup
##
##
InstallMethod( ConjugateGroup,
    "method for AffineCrystGroupOnRight and element", IsCollsElms, 
    [ IsAffineCrystGroupOnRight, IsMultiplicativeElementWithInverse ], 0,
function( G, g )
    local gen, H, d, T;

    if not IsAffineMatrixOnRight( g ) then
        Error( "g must be an affine matrix action OnRight" );
    fi;

    # if <G> is trivial conjugating is trivial
    if IsTrivial(G)  then
        return G;
    fi;

    # create the domain
    gen := List( GeneratorsOfGroup( G ), x -> g^-1 * x * g );
    H := AffineCrystGroupOnRightNC( gen );
    if HasTranslationBasis( G ) then
        d := DimensionOfMatrixGroup( G ) - 1;
        T := TranslationBasis( G );
        AddTranslationBasis( H, T*g{[1..d]}{[1..d]} );
    fi;

    # maintain useful information
    UseIsomorphismRelation( G, H );

    return H;

end );

InstallMethod( ConjugateGroup,
    "method for AffineCrystGroupOnLeft and element", IsCollsElms, 
    [ IsAffineCrystGroupOnLeft, IsMultiplicativeElementWithInverse ], 0,
function( G, g )
    local gen, H, d, T;

    if not IsAffineMatrixOnLeft( g ) then
        Error( "g must be an affine matrix action OnLeft" );
    fi;

    # if <G> is trivial conjugating is trivial
    if IsTrivial(G)  then
        return G;
    fi;

    # create the domain
    gen := List( GeneratorsOfGroup( G ), x -> g * x * g^-1 );
    H := AffineCrystGroupOnLeftNC( gen );
    if HasTranslationBasis( G ) then
        d := DimensionOfMatrixGroup( G ) - 1;
        T := TranslationBasis( G );
        AddTranslationBasis( H, T*g{[1..d]}{[1..d]} );
    fi;

    # maintain useful information
    UseIsomorphismRelation( G, H );

    return H;

end );


#############################################################################
##
#M  RightCosets( G, H ) . . . . . . . . . . . . . . . . . . . . . RightCosets
##
InstallMethod( RightCosetsNC, "AffineCrystGroupOnRight", 
    true, [ IsAffineCrystGroupOnRight, IsAffineCrystGroupOnRight ], 0,
function( G, H )

    local orb, pnt, img, gen, rep;

    # first some simple checks
    if Length( TranslationBasis(G) ) <> Length( TranslationBasis(H) ) then
        Error("sorry, there are infinitely many cosets");
    fi;

    orb := [ RightCoset( H, One( H ) ) ];
    for pnt in orb do
        rep := Representative( pnt );
        for gen in GeneratorsOfGroup( G ) do
            img := RightCoset( H, rep*gen );
            if not img in orb  then
                Add( orb, img );
            fi;
        od;
    od;
    return orb;

end );    

InstallMethod( RightCosetsNC, "AffineCrystGroupOnLeft", 
    true, [ IsAffineCrystGroupOnLeft, IsAffineCrystGroupOnLeft ], 0,
function( G, H )

    local orb, pnt, img, gen, rep;

    # first some simple checks
    if Length( TranslationBasis(G) ) <> Length( TranslationBasis(H) ) then
        Error("sorry, there are infinitely many cosets");
    fi;

    orb := [ RightCoset( H, One( H ) ) ];
    for pnt in orb do
        rep := Representative( pnt );
        for gen in GeneratorsOfGroup( G ) do
            img := RightCoset( H, rep*gen );
            if not img in orb  then
                Add( orb, img );
            fi;
        od;
    od;
    return orb;

end );    


#############################################################################
##
#M  CanonicalRightCosetElement( S, rep ) . . . . . CanonicalRightCosetElement
##
InstallMethod( CanonicalRightCosetElement, "for AffineCrystGroupOnRight", 
    IsCollsElms, [ IsAffineCrystGroupOnRight, IsObject ], 0,
function( S, rep )

    local P, d, m, T, mm, res; 

    P := PointGroup( S );
    d := DimensionOfMatrixGroup( P );
    m := rep{[1..d]}{[1..d]};
    T := ReducedLatticeBasis( TranslationBasis( S )*m );

    mm  := CanonicalRightCosetElement( P, m );
    res := PreImagesRepresentative( PointHomomorphism( S ), mm*m^-1 ) * rep;
    res[d+1]{[1..d]} := VectorModL( res[d+1]{[1..d]}, T );
    return res;

end );

InstallMethod( CanonicalRightCosetElement, "for AffineCrystGroupOnLeft", 
    IsCollsElms, [ IsAffineCrystGroupOnLeft, IsObject ], 0,
function( S, rep )

    local P, d, m, T, mm, res; 

    P := PointGroup( S );
    d := DimensionOfMatrixGroup( P );
    m := rep{[1..d]}{[1..d]};
    T := ReducedLatticeBasis( TranslationBasis( S )*m );

    mm  := CanonicalRightCosetElement( P, m );
    res := PreImagesRepresentative( PointHomomorphism( S ), mm*m^-1 ) * rep;
    res{[1..d]}[d+1] := VectorModL( res{[1..d]}[d+1], T );
    return res;

end );


#############################################################################
##
#M  Intersection2( G1, G2 ) . . . . . . . . . intersection of two CrystGroups
##
InstallMethod( Intersection2, "two AffineCrystGroupsOnRight", IsIdenticalObj, 
    [ IsAffineCrystGroupOnRight, IsAffineCrystGroupOnRight ], 0,
function( G1, G2 )

    local d, P1, P2, P, T1, T2, T, L, gen, gen1, gen2, orb, set, 
          rep, stb, pnt, i, img, sch, new, g, g1, g2, t1, t2, s, t, R;

    # get the intersections of the point groups and the translation groups
    d  := DimensionOfMatrixGroup( G1 ) - 1;
    P1 := PointGroup(G1);  
    P2 := PointGroup(G2);
    P  := Intersection( P1, P2 );
    T1 := TranslationBasis( G1 );
    T2 := TranslationBasis( G2 );
    T  := IntersectionModule( T1, T2 );
    L  := UnionModule( T1, T2 );

    gen  := GeneratorsOfGroup( P );
    gen1 := List( gen, x -> PreImagesRepresentative( 
                                   PointHomomorphism( G1 ), x) );
    gen2 := List( gen, x -> PreImagesRepresentative( 
                                   PointHomomorphism( G2 ), x)^-1 );

    orb := [ MutableMatrix( One( G1 ) ) ];
    set := [ One( G1 ) ];
    rep := [ One( P ) ];
    stb := TrivialSubgroup( P );

    # get the subgroup of P that can be lifted to the intersection
    for pnt  in orb  do
        for i in [1..Length( gen )] do
            img := gen2[i]*pnt*gen1[i];
            img[d+1]{[1..d]} := VectorModL( img[d+1]{[1..d]}, L ); 
            if not img in set  then
                Add( orb, img );
                AddSet( set, img );
                Add( rep, rep[Position(orb,pnt)]*gen[i] );
            else
                sch := rep[Position(orb,pnt)]*gen[i]
                       / rep[Position(orb,img)];
                if not sch in stb  then
                    stb := ClosureGroup( stb, sch );
                fi;
            fi;
        od;
    od;

    # determine the lift of stb
    new := [];
    for g in GeneratorsOfGroup( stb ) do
        g1 := PreImagesRepresentative( PointHomomorphism( G1 ), g );
        g1 := AffMatMutableTrans( g1 );
        if Length(T1) > 0 then
            g2 := PreImagesRepresentative( PointHomomorphism( G2 ), g );
            t1 := g1[d+1]{[1..d]};
            t2 := g2[d+1]{[1..d]};
            s  := IntSolutionMat( Concatenation( T1, -T2 ), t2-t1 ); 
            g1[d+1]{[1..d]} := t1+s{[1..Length(T1)]}*T1;
        fi;
        Add( new, g1 );
    od;

    # add the translations
    for t in T do
        g1 := IdentityMat( d+1 );
        g1[d+1]{[1..d]} := t;
        Add( new, g1 );
    od;

    R := AffineCrystGroupOnRightNC( new, One( G1 ) );
    AddTranslationBasis( R, T );
    return R;

end );

InstallMethod( Intersection2, "two AffineCrystGroupsOnLeft", IsIdenticalObj, 
    [ IsAffineCrystGroupOnLeft, IsAffineCrystGroupOnLeft ], 0,
function( G1, G2 )
    local T1, T2, I; 
    T1 := TransposedMatrixGroup( G1 );
    T2 := TransposedMatrixGroup( G2 );
    I  := Intersection2( T1, T2 );
    return TransposedMatrixGroup( I );
end );


#############################################################################
##
#M  NormalizerPointGroupInGLnZ( <P> ) . . . . . . .Normalizer of a PointGroup
##
InstallMethod( NormalizerPointGroupInGLnZ, 
    true, [ IsPointGroup ], 0,
function( P )
    local S, T;
    S := AffineCrystGroupOfPointGroup( P );
    T := InternalBasis( S );
    if T <> One(P) then
        return NormalizerInGLnZ( P^(T^-1) )^T;
    else
        return NormalizerInGLnZ( P );
    fi;
end );


#############################################################################
##
#M  CentralizerPointGroupInGLnZ( G ) . . . . . . .Centralizer of a PointGroup
##
InstallMethod( CentralizerPointGroupInGLnZ, "via NormalizerPointGroupInGLnZ", 
    true, [ IsPointGroup ], 0,
function( G )
    return Centralizer( NormalizerPointGroupInGLnZ( G ), G );
end );


#############################################################################
##
#F  CentralizerElement
##
CentralizerElement := function( G, u, TT )

    local d, I, U, L, orb, set, rep, stb, pnt, gen, img, sch, v;

    d := DimensionOfMatrixGroup( G ) - 1;
    I := IdentityMat( d );
    U := List( TT, t -> t * (u{[1..d]}{[1..d]} - I) );
    L := ReducedLatticeBasis( U );
   
    orb := [ MutableMatrix( u ) ];
    set := [ u ];
    rep := [ MutableMatrix( One( G ) ) ];
    stb := TrivialSubgroup( G );
    for pnt  in orb  do
        for gen  in GeneratorsOfGroup( G ) do
            img := pnt^gen;
            # reduce image mod L
            img[d+1]{[1..d]} := VectorModL( img[d+1]{[1..d]}, L );
            if not img in set  then
                Add( orb, img );
                AddSet( set, img );
                Add( rep, rep[Position(orb,pnt)]*gen );
            else
                sch := rep[Position(orb,pnt)]*gen
                       / rep[Position(orb,img)];
                # check if a translation conjugate of sch is in stabilizer
                v := u^sch - u;
                v := v[d+1]{[1..d]};
                if v <> 0 * v then
                     Assert(0, U <> [] );
                     v := IntSolutionMat( U, v );
                     Assert( 0, v <> fail );
                     sch[d+1]{[1..d]} := sch[d+1]{[1..d]} + v*TT; 
                fi;
                stb := ClosureGroup( stb, sch );
            fi;
        od;
    od;
    return stb;
end;


#############################################################################
##
#F  CentralizerAffineCrystGroup( G, obj ) . . centralizer of subgroup/element
##
CentralizerAffineCrystGroup := function ( G, obj )

    local d, P, T, e, I, M, m, L, i, U, o, gen, Q, C, u;

    d := DimensionOfMatrixGroup( G ) - 1;
    P := PointGroup( G );
    T := TranslationBasis( G );
    e := Length( T );
    I := IdentityMat( d );

    # we first determine the subgroup of G that centralizes the 
    # point group and the translation group of obj or its span

    if IsGroup( obj ) then
        M := PointGroup( obj );
        L := List( [1..e], x -> [] );
        gen := GeneratorsOfGroup( M );
        for i in [ 1..Length( gen ) ] do
            L{[1..e]}{[1..d]+(i-1)*d} := T*(gen[i]-I);
        od;
        P := Centralizer( P, M );
        P := Stabilizer( P, TranslationBasis( obj ), OnRight );
        U := Filtered( GeneratorsOfGroup(obj), x -> x{[1..d]}{[1..d]} <> I );
    else
        if not IsAffineMatrixOnRight( obj ) then
            Error( "obj must be an affine matrix acting OnRight" );
        fi;
        M := obj{[1..d]}{[1..d]};
        L := T*(M - I);
        P := Centralizer( P, M );
        o := Order( M );
        m := obj^o;
        P := Stabilizer( P, m[d+1]{[1..d]} );
        if o > 1 then U := [ obj ]; else U := []; fi;
    fi; 

    gen := List( GeneratorsOfGroup( P ), 
                 x -> PreImagesRepresentative( PointHomomorphism( G ), x ) );

    # if G is finite
    if e = 0 then
        return SubgroupNC( G, gen );
    fi;
    
    # we keep only translation generators which centralize obj
    Q := IdentityMat( e );
    if L <> [] then
        L := RowEchelonFormT( L, Q );
    fi;
    for i in [ Length( L )+1..e ] do
        Add( gen, AugmentedMatrix( I, Q[i]*T ) );
    od;

    # C centralizes the point group and the translation group of obj
    C := SubgroupNC( G, gen );     
    
    # now find the centralizer for each u in U
    for u in U do
        C := CentralizerElement( C, u, T );
        T := TranslationBasis( C );
    od;

    return C;

end;


#############################################################################
##
#M  Centralizer( G, obj ) . . . . . . . . . . centralizer of subgroup/element
##
InstallMethod( CentralizerOp, "AffineCrystGroupOnRight and element", 
    IsCollsElms, [ IsAffineCrystGroupOnRight, IsMatrix ], 0,
function( G, m )
    if not IsAffineMatrixOnRight( m ) then
        Error( "m must be an affine matrix acting OnRight" );
    fi;
    return CentralizerAffineCrystGroup( G, m );
end );

InstallMethod( CentralizerOp, "AffineCrystGroupOnLeft and element", 
    IsCollsElms, [ IsAffineCrystGroupOnLeft, IsMatrix ], 0,
function( G, m )
    local T, C;
    if not IsAffineMatrixOnLeft( m ) then
        Error( "m must be an affine matrix acting OnLeft" );
    fi;
    T := TransposedMatrixGroup( G );
    C := CentralizerAffineCrystGroup( T, TransposedMat( m ) );
    return TransposedMatrixGroup( C );
end );

InstallMethod( CentralizerOp, "two AffineCrystGroupsOnRight", IsIdenticalObj, 
    [ IsAffineCrystGroupOnRight, IsAffineCrystGroupOnRight ], 0,
function( G1, G2 )
    return CentralizerAffineCrystGroup( G1, G2 );
end );

InstallMethod( CentralizerOp, "two AffineCrystGroupsOnLeft", IsIdenticalObj, 
    [ IsAffineCrystGroupOnLeft, IsAffineCrystGroupOnLeft ], 0,
function( G1, G2 )
    local G, U, C;
    G := TransposedMatrixGroup( G1 );
    U := TransposedMatrixGroup( G2 );
    C := CentralizerAffineCrystGroup( G, U );
    return TransposedMatrixGroup( C );
end );


#############################################################################
##
#M  TranslationNormalizer( S ) . . . . . . . . . . . . translation normalizer
##
InstallMethod( TranslationNormalizer, "for SpaceGroup acting OnRight", 
    true, [ IsAffineCrystGroupOnRight and IsSpaceGroup ], 0,
function( S )

    local P, T, d, N, M, I, Pgens, B, invB, g, i, Q, L, K, k, l, j, gen;

    P := PointGroup( S );
    T := TranslationBasis( S );
    d := DimensionOfMatrixGroup( S ) - 1;

    if Size( P ) = 1 then
        N := GroupByGenerators( [], IdentityMat( d+1 ) );
        N!.continuousTranslations := IdentityMat( d );
        return N;
    fi;

    M := List( [1..d], i->[] ); i := 0;
    I := IdentityMat( d );
    Pgens := GeneratorsOfGroup( P );
    if not IsStandardAffineCrystGroup( S ) then
        B := InternalBasis( S );
        invB := B^-1;
        Pgens := List( Pgens, x -> B * x * invB );
    fi;
    for g in Pgens do
        g := g - I;
        M{[1..d]}{[1..d]+i*d} := g;
        i := i+1;
    od;
    
    # first diagonalize M
    Q := IdentityMat( Length(M) );
    M := TransposedMat(M);
    M := RowEchelonForm( M );
    while not IsDiagonalMat(M) do
        M := TransposedMat(M);
        M := RowEchelonFormT(M,Q);
        if not IsDiagonalMat(M) then
            M := TransposedMat(M);
            M := RowEchelonForm(M);
        fi;
    od;

    # and then determine the solutions of x*M=0 mod Z
    if Length(M)>0 then
        L := List( [1..Length(M)], i -> [ 0 .. M[i][i]-1 ] / M[i][i] );
        L := List( Cartesian( L ), l -> l * Q{[1..Length(M)]} );
    else
        L := NullMat( 1, Length(Q) );
    fi;

    # get the kernel
    if Length(M) < Length(Q) then
        K := Q{[Length(M)+1..Length(Q)]};
        TriangulizeMat( K );
    else
        K := [];
    fi; 

    # reduce to basis modulo kernel
    Append( L, IdentityMat( d ) );
    for k in K do
        j := PositionProperty( k, x -> x=1 );
        for l in L do
            l := l-l[j]*k;
        od;
    od;
    L := ReducedLatticeBasis( L );

    # conjugate if not standard
    if not IsStandardAffineCrystGroup( S ) then
        L := L*T;
    fi;

    # get generators
    gen := List( L, x -> IdentityMat( d+1 ) );
    for i in [1..Length(L)] do
        gen[i][d+1]{[1..d]} := L[i];
    od;

    N := GroupByGenerators( gen, IdentityMat( d+1 ) );
    N!.continuousTranslations := K;

    return N;

end );

InstallMethod( TranslationNormalizer, "for SpaceGroup acting OnLeft", 
    true, [ IsAffineCrystGroupOnLeft and IsSpaceGroup ], 0,
function( S )
    local N1, gen, N;
    N1  := TranslationNormalizer( TransposedMatrixGroup( S ) );
    gen := List( GeneratorsOfGroup( N1 ), TransposedMat );
    N   := GroupByGenerators( gen, One( N1 ) );
    N!.continuousTranslations := N1!.continuousTranslations;
    return N;
end );

RedispatchOnCondition( TranslationNormalizer, true,
  [IsAffineCrystGroupOnRight], 
  [IsAffineCrystGroupOnRight and IsSpaceGroup], 0);

RedispatchOnCondition( TranslationNormalizer, true,
  [IsAffineCrystGroupOnLeft], 
  [IsAffineCrystGroupOnLeft and IsSpaceGroup], 0);

#############################################################################
##
#F  AffineLift( pnt, d )
##
AffineLift := function( pnt, d )

    local M, b, i, I, p, m, Q, j, s; 

    M := List( [1..d], i->[] ); b := []; i := 0;
    I := IdentityMat( d );
    for p in pnt do
        m := p[1]{[1..d]}{[1..d]} - I;
        M{[1..d]}{[1..d]+i*d} := m;
        Append( b, p[2] - p[1][d+1]{[1..d]} );
        i := i+1;
    od;

    Q := IdentityMat( d );
    
    M := TransposedMat(M);
    M := RowEchelonFormVector( M,b );
    while not IsDiagonalMat(M) do
        M := TransposedMat(M);
        M := RowEchelonFormT(M,Q);
        if not IsDiagonalMat(M) then
            M := TransposedMat(M);
            M := RowEchelonFormVector(M,b);
        fi;
    od;

    ##  Check if we have any solutions modulo Z.
    for j in [Length(M)+1..Length(b)] do
        if not IsInt( b[j] ) then
            return [];
        fi;
    od;
    s := List( [1..Length(M)], i -> b[i]/M[i][i] );
    for i in [Length(M)+1..d] do 
        Add( s, 0);
    od;
    return s*Q;

end;


#############################################################################
##
#M  AffineNormalizer( S ) . . . . . . . . . . . . . . . . . affine normalizer
##
InstallMethod( AffineNormalizer, "for SpaceGroup acting OnRight", true, 
    [ IsAffineCrystGroupOnRight and IsSpaceGroup ], 0,
function( S )

    local d, P, H, T, N, Pgens, Sgens, invT, gens, Pi, Si, hom, opr, orb, 
          g, m, set, rep, lst, pnt, img, t, sch, n, nn, normgens, TN, AN;

    d := DimensionOfMatrixGroup( S ) - 1;
    P := PointGroup( S );
    H := PointHomomorphism( S );
    T := TranslationBasis( S );
    N := NormalizerPointGroupInGLnZ( P ); 
    Pgens := GeneratorsOfGroup( P );
    Sgens := List( Pgens, x -> PreImagesRepresentative( H, x ) );

    # we work in a standard representation
    if not IsStandardAffineCrystGroup( S ) then
        invT := T^-1;
        gens := List( GeneratorsOfGroup( N ), x -> T * x * invT );
        Pgens := List( Pgens, x -> T * x * invT );
        Sgens := List( Sgens, x -> S!.conj * x * S!.invconj );
    else
        gens := GeneratorsOfGroup( N );
    fi;
    Pi  := Group( Pgens, One( P ) );
    Si  := Group( Sgens, One( S ) );
    hom := GroupHomomorphismByImagesNC( Si, Pi, Sgens, Pgens ); 

    # the operation we shall need in the stabilizer algorithm
    opr := function( data, g )
        local m, mm, res; 
        m  := data[1]{[1..d]}{[1..d]};
        mm := m^g;
        if m = mm then
            res := [ data[1], List( data[2]*g, FractionModOne ) ];
        else
           m := AffMatMutableTrans( PreImagesRepresentative( hom, mm ) );
           m[d+1]{[1..d]} := List( m[d+1]{[1..d]}, FractionModOne );
           res := [ m, List( data[2]*g, FractionModOne ) ];
        fi;
        return res;
    end;

    orb := [];
    for g in Sgens do
        m := AffMatMutableTrans( g );
        m[d+1]{[1..d]} := List( m[d+1]{[1..d]}, FractionModOne );
        Add( orb, [ m, m[d+1]{[1..d]} ] );
    od;
    orb := [ orb ];
    set := ShallowCopy( orb );

    rep := [ One( N ) ];
    lst := [];
    for pnt  in orb  do
        for g  in gens  do
            img := List( pnt, x -> opr( x, g ) );
            if not img in set  then
                Add( orb, img );
                AddSet( set, img );
                Add( rep, rep[Position(orb,pnt)]*g );
            else
                t := AffineLift( img, d );
                if t<>[] then
                    sch := rep[Position(orb,pnt)]*g;
                    n := IdentityMat( d+1 );
                    n{[1..d]}{[1..d]} := sch;
                    n[d+1]{[1..d]} := t;
                    AddSet( lst, n );
                fi;
            fi;
        od;
    od;

    if IsFinite( N ) then
        nn := Subgroup( N, [] );
        normgens := [];
        for g in lst do
            m := g{[1..d]}{[1..d]};
            if not m in nn then
                Add( normgens, g );
                nn := ClosureGroup( nn, m );
            fi;
        od;
    else
        normgens := lst;
    fi;
    
    m := IdentityMat( d+1 );
    m{[1..d]}{[1..d]} := T;
    if not IsStandardAffineCrystGroup( S ) then
        normgens := List( normgens, x -> x^m );
    fi;
    
    TN := TranslationNormalizer( S );
    Append( normgens, GeneratorsOfGroup( TN ) );
    AN := Group( normgens, One( S ) );
    AN!.continuousTranslations := TN!.continuousTranslations;

    # can AN be made an AffineCrystGroup?
    if IsFinite( N ) and AN!.continuousTranslations = [] then
        SetIsAffineCrystGroupOnRight( AN, true );
        lst := List( GeneratorsOfGroup( TN ), x -> x[d+1]{[1..d]} );
        lst := ReducedLatticeBasis( lst );
        AddTranslationBasis( AN, lst );
    fi;

    return AN;

end );

InstallMethod( AffineNormalizer, "for SpaceGroup acting OnLeft", true, 
    [ IsAffineCrystGroupOnLeft and IsSpaceGroup ], 0,
function( S )
    local A1, A, gen;
    A1 := AffineNormalizer( TransposedMatrixGroup( S ) );
    if IsAffineCrystGroupOnRight( A1 ) then
        A := TransposedMatrixGroup( A1 );
    else
        gen := List( GeneratorsOfGroup( A1 ), TransposedMat );
        A   := Group( gen, One( A1 ) );
    fi;
    A!.continuousTranslations := A1!.continuousTranslations;
    return A;
end );


RedispatchOnCondition( AffineNormalizer, true,
  [IsAffineCrystGroupOnRight], 
  [IsAffineCrystGroupOnRight and IsSpaceGroup], 0);

RedispatchOnCondition( AffineNormalizer, true,
  [IsAffineCrystGroupOnLeft], 
  [IsAffineCrystGroupOnLeft and IsSpaceGroup], 0);

#############################################################################
##
#M  AffineInequivalentSubgroups( S, subs ) . . reps of affine ineq. subgroups
##
InstallGlobalFunction( AffineInequivalentSubgroups, function( S, subs )

    local C, A, opr, reps, orb, grp, gen, img;

    if subs = [] then
        return subs;
    fi;
    C := ShallowCopy( subs );
    A := AffineNormalizer( S );
    if A!.continuousTranslations <> [] then
        return fail;
    fi;

    reps := [];
    while C <> []  do
        if not IsSubgroup( S, C[1] ) then
            Error( "subs must be a list of subgroups of S" );
        fi;
        orb := [ C[1] ];
        for grp in orb do
            for gen in GeneratorsOfGroup( A ) do
                img := List( GeneratorsOfGroup( grp ), x -> x^gen );
                if not ForAny( orb, g -> ForAll( img, x -> x in g ) ) then
                    Add( orb, ConjugateGroup( grp, gen ) );
                fi;
            od;
        od;
        Add( reps, orb[1] );
        C := Filtered( C, x -> not x in orb );
    od;

    return reps;

end );

