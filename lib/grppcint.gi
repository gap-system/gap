#############################################################################
##
#W  grppcint.gi                 GAP Library                      Frank Celler
#W                                                             & Bettina Eick
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for the intersection of polycylic groups.
##
Revision.grppcint_gi :=
    "@(#)$Id$";


#############################################################################
##

#V  GS_SIZE . . . . . . . . . . . . . . . .  size from which on we use glasby
##
GS_SIZE := 20;


#############################################################################
##

#F  GlasbyCover( <S>, <A>, <B>, <pcgsK> )
##
##  Glasby's  generalized  covering  algorithmus.  <S> := <H>/\<N> * <K>/\<N>
##  and <A> < <H>, <B> < <K>. <A> ( and also <B> ) generate the  intersection
##  modulo <S>.
##
GlasbyCover := function( S, A, B, pcgsK )
    local   Am, Bm, z, i;

    # Decompose the intersection <H> /\ <K> /\ <N>.
    Am := S.intersection;
    Bm := List( Am, x -> x / SiftedPcElement( pcgsK, x ) );

    # Now cover the other generators.
    for i  in [ 1 .. Length( A ) ]  do
        z := S.factorization( A[i] ^ -1 * B[i] );
        A[ i ] := A[ i ] * z.u;
        B[ i ] := B[ i ] * ( z.n / SiftedPcElement( pcgsK, z.n ) ) ^ -1;
    od;

    # Concatenate them and return. The are not normalized.
    Append( A, Am );
    Append( B, Bm );
end;


#############################################################################
##
#F  GlasbyShift( <C>, <B> )
##
GlasbyShift := function( C, B )
    return List( C, x -> x / SiftedPcElement( B, x ) );
end;


#############################################################################
##
#F  GlasbyStabilizer( <pcgs>, <A>, <B>, <pcgsS>, <pcgsR> );
##
GlasbyStabilizer := function( pcgs, A, B, pcgsS, pcgsR )
    local   pcgsL,  f,  transl,  U,  matA,  pt;

    pcgsL := pcgsS mod pcgsR; 
    f     := GF( Order( pcgsL[1] ) );
    B     := InducedPcgsByPcSequence( pcgs, B );
    
    transl := function( a ) 
        return ExponentsOfPcElement(pcgsL,SiftedPcElement(B,a)) * One(f);
    end;

    A := InducedPcgsByPcSequence( pcgs, A );
    U := SubgroupByPcgs( GroupOfPcgs(pcgs), A );
    matA  := AffineOperationLayer( A, pcgsL, transl );

    pt := List( pcgsL, x -> Zero( f ) );
    Add( pt, One( f ) );
    return GeneratorsOfGroup( Stabilizer( U, pt, A, matA, OnRight ) );
end;


#############################################################################
##
#F  AvoidedLayers
##
AvoidedLayers := function( pcgs, pcgsH, pcgsK )

    local occur, h, k, first, next, avoided, primes, p, sylow, res, i, 
          firsts, weights;

    # get the gens, which do not occur in H or K
    occur := List( [ 1..Length( pcgs ) ], x -> 0 );
    for h in pcgsH do
        occur := occur + ExponentsOfPcElement( pcgs, h );
    od;
    for k in pcgsK do
        occur := occur + ExponentsOfPcElement( pcgs, k );
    od;

    # make a list of the avoided layers
    avoided := [ ];
    firsts  := LGFirst( pcgs );
    weights := LGWeights( pcgs );
    for i  in [ 1..Length( firsts )-1 ]  do
        first := firsts[i];
        next  := firsts[i+1];
        if Maximum( occur{[first..next-1]} ) = 0  then
            Add( avoided, first );
        fi;
    od;

    # get the avoided heads
    res := [ ];
    for i in avoided do
        if weights[i][2] = 1 then
            Add( res, i );
        fi;
    od;

    # get the avoided Sylow subgroups
    primes := Set( List( avoided, x -> weights[x][3] ) );
    for p in primes do
        sylow := Filtered( firsts{[1..Length(firsts)-1]},
                           x -> weights[x][3] = p );
        if IsSubset( avoided, sylow ) then
            Append( res, sylow );
        fi;
    od;

    return Set(res);
end;


#############################################################################
##
#F  GlasbyIntersection
##
GlasbyIntersection := function( pcgs, pcgsH, pcgsK )
    local m, G, first, weights, avoid, A, B, i, start, next, HmN, KmN, 
          pcgsN, pcgsHmN, pcgsHF, pcgsKmN, pcgsKF, sum, pcgsS, pcgsR, C, D,
          new, U, fam; 

    # compute a cgs for <H> and <K>
    G := GroupOfPcgs( pcgs );
    m := Length( pcgs );
    fam := FamilyObj( OneOfPcgs( pcgs ) );

    # use the special pcgs
    first   := LGFirst( pcgs );
    weights := LGWeights( pcgs );
    avoid   := AvoidedLayers( pcgs, pcgsH, pcgsK );

    # go down the elementary abelian series. <A> < <H>, <B> < <K>.
    A := [ ];
    B := [ ];
    for i in [ 1..Length(first)-1 ] do
        start := first[i];
        next  := first[i+1];
        if not start in avoid then
            HmN := Filtered( pcgsH, 
                             x -> start <= DepthOfPcElement( pcgs, x ) and 
                                  next > DepthOfPcElement( pcgs, x ) );
            KmN := Filtered( pcgsK,
                             x -> start <= DepthOfPcElement( pcgs, x ) and
                                  next > DepthOfPcElement( pcgs, x ) );

            pcgsN   := InducedPcgsByPcSequenceNC( pcgs, pcgs{[next..m]} );
            pcgsHmN := PcgsByPcSequence( fam, Concatenation( HmN, pcgsN ));
            pcgsHF  := pcgsHmN mod pcgsN;
            pcgsKmN := PcgsByPcSequence( fam, Concatenation( KmN, pcgsN ) );
            pcgsKF  := pcgsKmN mod pcgsN;

            sum := SumFactorizationFunctionPcgs( pcgs, pcgsHF, pcgsKF );

            # Maybe there is nothing left to stabilize.
            if Length( sum.sum ) = next - start then
                C := A;
                D := B;
            else
                pcgsS := InducedPcgsByPcSequenceNC( pcgs, pcgs{[start..m]} );
                pcgsR := PcgsByPcSequence( fam, 
                                           Concatenation( sum.sum, pcgsN ) );
                C := GlasbyStabilizer( pcgs, A, B, pcgsS, pcgsR );
                D := GlasbyShift( C, B );
            fi;

            # Now we can cover <C> and <D>.
            GlasbyCover( sum, C, D, pcgsK );
            A := C;
            B := D;
        fi;
    od;

    # <A> is the unnormalized intersection.
    new := InducedPcgsByPcSequence( pcgs, A );
    U   := SubgroupByPcgs( G, A );
    return U;
end;


#############################################################################
##
#F  ZassenhausIntersection( pcgs, pcgsN, pcgsU )
##
ZassenhausIntersection := function( pcgs, pcgsN, pcgsU )
    local sw, m, ins, g, new;

    # If  <N>  is  composition subgroup, no calculation is needed. We can use
    # weights instead. Otherwise 'IntersectionSumAgGroup' will do the work.
    sw := DepthOfPcElement( pcgs, pcgsN[1] );
    m  := Length( pcgs );
    if pcgs{[sw..m]} = pcgsN then
        ins := [];
        for g in pcgsU do
            if DepthOfPcElement( pcgs, g ) >= sw  then
                Add( ins, g );
            fi;
        od;
        new := InducedPcgsByPcSequence( pcgs, ins );
        ins := SubgroupByPcgs( GroupOfPcgs( pcgs ), new );
        return ins;
    else
        new := ExtendedIntersectionSumPcgs( pcgs, pcgsN, pcgsU );
        new := InducedPcgsByPcSequence( pcgs, new.intersection );
        ins := SubgroupByPcgs( GroupOfPcgs( pcgs ), new );
        return ins;
    fi;
end;


#############################################################################
##

#M  Intersection2( <U>, <V> )
##
InstallMethod( Intersection2,
    "groups with pcgs",
    true, 
    [ IsGroup and HasHomePcgs,
      IsGroup and HasHomePcgs ],
    0,

function( U, V )
    local G, home, pcgs, pcgsU, pcgsV;

    # Check the parent and catch a trivial case
    home  := HomePcgs(U);
    if home <> HomePcgs(V) then
        TryNextMethod();
    fi;
    pcgs  := SpecialPcgs(home);
    pcgsU := InducedPcgsByGeneratorsNC( pcgs, GeneratorsOfGroup(U) );
    pcgsV := InducedPcgsByGeneratorsNC( pcgs, GeneratorsOfGroup(V) );

    # check sizes and so on
    if ForAll( pcgsU, x -> x in V ) then
        return U;
    elif ForAll( pcgsV, x -> x in U ) then
        return V;
    
    elif Size(U) < GS_SIZE  then
        return Subgroup( GroupOfPcgs(home), 
                         Filtered( AsList(U), x -> x in V and
                                                   x <> Identity(V) ) );
    elif Size(V) < GS_SIZE  then
        return Subgroup( GroupOfPcgs( home ), 
                         Filtered( AsList(V), x -> x in U  and
                                                   x <> Identity(U) ) );
    fi;

    # test if one the groups is known to be normal
    G := GroupOfPcgs(home);
    if IsNormal( G, U ) then
        return ZassenhausIntersection( pcgs, pcgsU, pcgsV );
    elif IsNormal( G, V ) then
        return ZassenhausIntersection( pcgs, pcgsV, pcgsU );
    fi;

    return GlasbyIntersection( pcgs, pcgsU, pcgsV );

end );


#############################################################################
##

#E  grppcpint.gi  . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
