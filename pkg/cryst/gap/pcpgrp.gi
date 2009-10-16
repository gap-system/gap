#############################################################################
##
#A  pgpgrp.gi                  Cryst library                     Bettina Eick
#A                                                              Franz G"ahler
#A                                                              Werner Nickel
##
#Y  Copyright 1997-1999  by  Bettina Eick,  Franz G"ahler  and  Werner Nickel
##

#############################################################################
##
#M  IsomorphismPcpGroup( <P> ) . . . . . . . . . . . . . . . . for PointGroup
##
InstallMethod( IsomorphismPcpGroup,
    "for PointGroup", true, [ IsPointGroup ], 0,
function ( P )
    local mono, N, repr, F, gens, prei, iso;

    # compute an isomorphic permutation group
    mono := NiceMonomorphism( P );
    N    := NiceObject( P );

    # distinguish between solvable and non-solvable case
    if not IsSolvableGroup( N ) then return fail; fi;

    repr := IsomorphismPcpGroup( N );
    F    := Image( repr );
    gens := Igs( F );
    prei := List( gens, x -> PreImagesRepresentative( repr, x ) );
    prei := List( prei, x -> PreImagesRepresentative( mono, x ) );

    iso := GroupHomomorphismByImagesNC( P, F, prei, gens );
    SetMappingGeneratorsImages( iso, [ prei, gens ] );
    SetIsBijective( iso, true );
    SetKernelOfMultiplicativeGeneralMapping( iso, TrivialSubgroup( P ) );
    return iso;
end );

#############################################################################
##
#M  IsomorphismPcpGroup( <S> )  . . . . . . for AffineCrystGroupOnLeftOrRight
##
InstallMethod( IsomorphismPcpGroup,
    "for AffineCrystGroup", true, [ IsAffineCrystGroupOnLeftOrRight ], 0,
function( S )
    local P, N, T, iso, F, gensF, gensN, matsP, d, n, t, matsT, i, mats, 
          coll, j, r, g, e, o, s, G, new, v; 

    # get presentation for the point group
    P   := PointGroup( S );
    N   := NiceObject( P );
    T   := TranslationBasis( S );
    iso := IsomorphismPcpGroup( N );
    if IsBool( iso ) then return fail; fi;

    # determine preimages
    F := Image( iso );
    gensF := Cgs(F);
    gensN := List( gensF, x -> PreImagesRepresentative( iso, x ) );
    matsP := List( gensN, x -> ImagesRepresentative( NiceToCryst( P ), x ) );

    # set up some variables
    d := DimensionOfMatrixGroup( S ) - 1;
    n := Length( gensN );
    t := Length( T );

    # get mats of translation
    matsT := List( [1..t], x -> IdentityMat( d+1 ) );
    for i in [1..Length( matsT )] do
        if IsAffineCrystGroupOnRight( S ) then
            matsT[i][d+1]{[1..d]} := T[i];
        else
            matsT[i]{[1..d]}[d+1] := T[i];
        fi;
    od;
    mats := Concatenation( matsP, matsT );

    # compute collector
    coll := FromTheLeftCollector( n + t );
    
    # point group rels
    for i in [1..n] do

        # compute power rel
        r := RelativeOrderPcp( gensF[i] );
        g := gensF[i]^r;
        e := Exponents( gensF[i]^r );
        s := matsP[i]^-r * MappedVector( e, matsP );
        if t > 0 then
            if IsAffineCrystGroupOnRight( S ) then
                v := SolutionMat( T, - s[d+1]{[1..d]} );
            else
                v := SolutionMat( T, - s{[1..d]}[d+1] );
            fi;
            e := Concatenation( e, v );
        fi;
        o := ObjByExponents( coll, e );
        SetRelativeOrder( coll, i, r );
        SetPower( coll, i, o );

        for j in [1..i-1] do

            # get conjugate rel
            g := gensF[i]^gensF[j];
            e := Exponents( gensF[i]^gensF[j] );
            s := (matsP[i]^matsP[j])^-1 * MappedVector( e, matsP );
            if t > 0 then
                if IsAffineCrystGroupOnRight( S ) then
                    v := SolutionMat( T, - s[d+1]{[1..d]} );
                else
                    v := SolutionMat( T, - s{[1..d]}[d+1] );
                fi;
                e := Concatenation( e, v );
            fi;
            o := ObjByExponents( coll, e );
            SetConjugate( coll, i, j, o );
        od;
    od;

    # operation rels
    e := List( [1..n], x -> 0 );
    for i in [1..n] do
        for j in [1..t] do
            s := matsT[j]^matsP[i];
            if IsAffineCrystGroupOnRight( S ) then
                v := SolutionMat( T, s[d+1]{[1..d]} );
            else
                v := SolutionMat( T, s{[1..d]}[d+1] );
            fi;
            o := ObjByExponents( coll, Concatenation( e, v ) );
            SetConjugate( coll, n+j, i, o );
        od;
    od;

    # set up homomorphims
    G := PcpGroupByCollector( coll );
    new := GroupHomomorphismByImagesNC( S, G, mats, Cgs(G));
    SetMappingGeneratorsImages( new, [ mats, Cgs(G) ] );
    SetIsFromAffineCrystGroupToPcpGroup( new, true );
    SetIsBijective( new, true );
    SetKernelOfMultiplicativeGeneralMapping( new, TrivialSubgroup( S ) );
    return new;
end );

#############################################################################
##
#M  ImagesRepresentative( <iso>, <elm> ) for IsFromAffineCrystGroupToPcpGroup
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
    [IsGroupGeneralMappingByImages and IsFromAffineCrystGroupToPcpGroup,
     IsMultiplicativeElementWithInverse ], 0,
function( iso, elm )

    local d, S, T, elmP, isoP, exp, genS, elm2, v;

    d := Length( elm ) - 1;
    S := Source( iso );
    T := TranslationBasis( S );

    elmP := elm{[1..d]}{[1..d]};
    isoP := IsomorphismPcpGroup( PointGroup( S ) );
    exp  := Exponents( ImagesRepresentative( isoP, elmP ) );

    genS := MappingGeneratorsImages( iso )[1];
    elm2 := MappedVector( exp, genS{[1..Length(exp)]} );
    if Length( T ) > 0 then
        if IsAffineCrystGroupOnRight( S ) then
            v := elm[d+1]{[1..d]} - elm2[d+1]{[1..d]};
        else
            v := elm{[1..d]}[d+1] - elm2{[1..d]}[d+1];
        fi;
        exp := Concatenation( exp, SolutionMat( T, v ) );
    fi;
    return PcpElementByExponents( Collector( One( Range( iso ) ) ), exp );

end );

#############################################################################
##
#M  NaturalHomomorphismByNormalSubgroup( <G>, <N> )  for solv. AffineCrystGrp
##
InstallMethod( NaturalHomomorphismByNormalSubgroupOp, 
    "for AffineCrystGroup, via pcp representation", IsIdenticalObj,
    [ IsAffineCrystGroupOnRight, IsAffineCrystGroupOnRight ], 10,
function( G, N )
    local iso, hom;
    if not IsSolvableGroup( G ) then
        TryNextMethod();
    fi;
    iso := IsomorphismPcpGroup( G );
    hom := NaturalHomomorphismByPcp( Pcp( Image(iso), Image(iso,N) ) );
    return CompositionMapping( hom, iso );
end );

InstallMethod( NaturalHomomorphismByNormalSubgroupOp,
    "for AffineCrystGroup, via pcp representation", IsIdenticalObj,
    [ IsAffineCrystGroupOnLeft, IsAffineCrystGroupOnLeft ], 10,
function( G, N )
    local iso, hom;
    if not IsSolvableGroup( G ) then
        TryNextMethod();
    fi;
    iso := IsomorphismPcpGroup( G );
    hom := NaturalHomomorphismByPcp( Pcp( Image(iso), Image(iso,N) ) );
    return CompositionMapping( hom, iso );
end );




