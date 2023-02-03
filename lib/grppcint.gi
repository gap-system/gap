#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler, Bettina Eick.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the methods for the intersection of polycyclic groups.
##


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
BindGlobal( "GlasbyCover", function( S, A, B, pcgsK )
    local   Am, Bm, z, i;

    # Decompose the intersection <H> /\ <K> /\ <N>.
    Am :=  AsList( S.intersection );
    Bm := List( Am, x -> x / SiftedPcElement( pcgsK, x ) );

    # Now cover the other generators.
    for i  in [ 1 .. Length( A ) ]  do
        z := S.factorization(LeftQuotient( A[i], B[i]) );
        A[ i ] := A[ i ] * z.u;

        # what is the aim of this arithmetic? We can save one inversion
        #B[ i ] := B[ i ] * ( z.n / SiftedPcElement( pcgsK, z.n ) ) ^ -1;
        B[ i ] := B[ i ] * (SiftedPcElement( pcgsK, z.n )/z.n);
    od;

    # Concatenate them and return. The are not normalized.
    Append( A, Am );
    Append( B, Bm );
end );


#############################################################################
##
#F  GlasbyShift( <C>, <B> )
##
BindGlobal( "GlasbyShift", function( C, B )
    return List( C, x -> x / SiftedPcElement( B, x ) );
end );


#############################################################################
##
#F  GlasbyStabilizer( <pcgs>, <A>, <B>, <pcgsL>)
##
BindGlobal( "GlasbyStabilizer", function( pcgs, A, B, pcgsL )
    local   f,  transl,  matA,  pt;

    f     := GF( Order( pcgsL[1] ) );

    transl := function( a )
        return ExponentsOfPcElement(pcgsL,SiftedPcElement(B,a)) * One(f);
    end;

    A := InducedPcgsByPcSequenceNC( pcgs, A );
    #U := SubgroupByPcgs( GroupOfPcgs(pcgs), A );
    matA  := AffineActionLayer( A, pcgsL, transl );

    pt := List( pcgsL, x -> Zero( f ) );
    Add( pt, One( f ) );
    pt := ImmutableVector(f, pt);

    # was: return Pcgs( Stabilizer( U, pt, A, matA, OnRight ) );
    # we cannot simply return this pcgs here, as we cannot guarantee that
    # the pcgs of this group will be compatible with the pcgs wrt. which we
    # are computing.
    #return InducedPcgs(pcgs, Stabilizer( U, pt, A, matA, OnRight ) );
    return StabilizerPcgs(A, pt, matA, OnRight );
end );


#############################################################################
##
#F  AvoidedLayers
##
BindGlobal( "AvoidedLayers", function( pcgs, pcgsH, pcgsK )

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
    primes := Set( avoided, x -> weights[x][3] );
    for p in primes do
        sylow := Filtered( firsts{[1..Length(firsts)-1]},
                           x -> weights[x][3] = p );
        if IsSubset( avoided, sylow ) then
            Append( res, sylow );
        fi;
    od;

    return Set(res);
end );


#############################################################################
##
#F  GlasbyIntersection
##
BindGlobal( "GlasbyIntersection", function( pcgs, pcgsH, pcgsK )
    local m, G, first, avoid, A, B, i, start, next, HmN, KmN,
          sum, pcgsS, pcgsR, C, D,
          new, U, deptH, deptK,pcgsL,depthS,depthN;

    # compute a cgs for <H> and <K>
    G := GroupOfPcgs( pcgs );
    m := Length( pcgs );

    # use the special pcgs
    first   := LGFirst( pcgs );
    avoid   := AvoidedLayers( pcgs, pcgsH, pcgsK );

    deptH := List( pcgsH, x -> DepthOfPcElement( pcgs, x ) );
    deptK := List( pcgsK, x -> DepthOfPcElement( pcgs, x ) );

    # go down the elementary abelian series. <A> < <H>, <B> < <K>.
    A := [ ];
    B := [ ];
    depthN:=[1..m];
    for i in [ 1..Length(first)-1 ] do
        start := first[i];
        next  := first[i+1];
        depthS := depthN;
        depthN := [next..m];
        if not start in avoid then
            #pcgsN := InducedPcgsByPcSequenceNC( pcgs, pcgs{depthN} );
            HmN := pcgsH{Filtered( [1..Length(deptH)],
                         x -> start <= deptH[x] and next > deptH[x] )};
            KmN := pcgsK{Filtered( [1..Length(deptK)],
                         x -> start <= deptK[x] and next > deptK[x] )};

            #pcgsHmN := Concatenation( HmN, pcgsN );
            #pcgsHmN := InducedPcgsByPcSequenceNC( pcgs, pcgsHmN );
            #pcgsHF  := pcgsHmN mod pcgsN;
            #pcgsKmN := Concatenation( KmN, pcgsN );
            #pcgsKmN := InducedPcgsByPcSequenceNC( pcgs, pcgsKmN );
            #pcgsKF  := pcgsKmN mod pcgsN;


            # SumFactorizationFunction takes *LISTS* as arguments 2,3, so we
            # don't need to make pcgs at all.
            #pcgsHF := ModuloTailPcgsByList(pcgs,HmN,[next..m]);
            #pcgsKF := ModuloTailPcgsByList(pcgs,KmN,[next..m]);
            #sum := SumFactorizationFunctionPcgs( pcgs, pcgsHF, pcgsKF, pcgsN );

            # and `SFF' now takes a tail depth, so the expensive sifting to
            # find the identity can be ignored.
            sum := SumFactorizationFunctionPcgs( pcgs, HmN, KmN, next );

            # Maybe there is nothing left to stabilize.
            if Length( sum.sum ) = next - start then
                C := ShallowCopy( AsList( A ) );
                D := ShallowCopy( AsList( B ) );
            else
                # GlasbyStabilizer would make a pcgs out of it first anyhow
                B     := InducedPcgsByPcSequenceNC( pcgs, B );
                if Length(sum.sum)>0 then
                  pcgsS := InducedPcgsByPcSequenceNC( pcgs, pcgs{depthS} );
                  pcgsR := Concatenation( sum.sum, pcgs{depthN} );
                  pcgsR := InducedPcgsByPcSequenceNC( pcgs, pcgsR );
                  pcgsL:=pcgsS mod pcgsR;
                else
                  pcgsL:=ModuloTailPcgsByList(pcgs,
                                              pcgs{Difference(depthS,depthN)},
                                              depthN);

                fi;

                C := GlasbyStabilizer( pcgs, A, B, pcgsL );
                C := ShallowCopy( AsList( C ) );
                #D := GlasbyShift( C, InducedPcgsByPcSequenceNC(pcgs, B) );
                D := GlasbyShift( C, B );
                D := ShallowCopy( AsList( D ) );
            fi;

            # Now we can cover <C> and <D>.
            GlasbyCover( sum, C, D, pcgsK );
            A := ShallowCopy( C );
            B := ShallowCopy( D ) ;
        fi;
    od;

    # <A> is the unnormalized intersection.
    new := InducedPcgsByPcSequenceNC( pcgs, A );
    U   := SubgroupByPcgs( G, new );
    return U;
end );


#############################################################################
##
#F  ZassenhausIntersection( pcgs, pcgsN, pcgsU )
##
BindGlobal( "ZassenhausIntersection", function( pcgs, pcgsN, pcgsU )
    local sw, m, ins, g, new;

    if Length(pcgsN)=0 then
      return SubgroupByPcgs( GroupOfPcgs( pcgs ), pcgsN );
    fi;
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
        new := InducedPcgsByPcSequenceNC( pcgs, ins );
        ins := SubgroupByPcgs( GroupOfPcgs( pcgs ), new );
        return ins;
    else
        new := ExtendedIntersectionSumPcgs( pcgs, pcgsN, pcgsU, true );
        new := InducedPcgsByPcSequenceNC( pcgs, new.intersection );
        ins := SubgroupByPcgs( GroupOfPcgs( pcgs ), new );
        return ins;
    fi;
end );


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

    # check for trivial cases
    if IsInt(Size(V)/Size(U))
       and ForAll( GeneratorsOfGroup(U), x -> x in V ) then
        return U;
    # here we can test Size(V)<Size(U): if they are the same the test before
    # would have found out.
    elif Size(V)<Size(U) and IsInt(Size(U)/Size(V))
      and ForAll( GeneratorsOfGroup(V), x -> x in U ) then
        return V;
    fi;

    G := GroupOfPcgs(home);
    if Size(U) < GS_SIZE  then
        return SubgroupNC( G, Filtered( AsList(U), x -> x in V and
                                                   x <> Identity(V) ) );
    elif Size(V) < GS_SIZE  then
        return SubgroupNC( G, Filtered( AsList(V), x -> x in U  and
                                                   x <> Identity(U) ) );
    fi;

    # compute nice pcgs's
    pcgs  := SpecialPcgs(home);
    pcgsU := InducedPcgs(pcgs, U );
    pcgsV := InducedPcgs(pcgs, V );

  # disabled calls to `ZassenhausIntersection' that seems to be not
  # applicable. AH, 4/12/05
  #  # test if one the groups is known to be normal
  #  if IsNormal( G, U ) then
  #      return ZassenhausIntersection( pcgs, pcgsU, pcgsV );
  #  elif IsNormal( G, V ) then
  #      return ZassenhausIntersection( pcgs, pcgsV, pcgsU );
  #  fi;

    return GlasbyIntersection( pcgs, pcgsU, pcgsV );

end );

#############################################################################
##
#M  NormalIntersection( <G>, <U> )  . . . . . intersection with normal subgrp
##
InstallMethod( NormalIntersection,
    "method for two groups with home pcgs",
    IsIdenticalObj, [ IsGroup and HasHomePcgs, IsGroup and HasHomePcgs],
function( G, H )
local home;
  home:=HomePcgs(G);
  if home<>HomePcgs(H) then
    TryNextMethod();
  fi;
  return ZassenhausIntersection(home,InducedPcgs(home,G),InducedPcgs(home,H));
end );
