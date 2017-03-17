#############################################################################
##
#W  algsc.tst                   GAP library                     Thomas Breuer
##
##
#Y  Copyright 1997,    Lehrstuhl D für Mathematik,   RWTH Aachen,    Germany
##
gap> START_TEST("algsc.tst");

#############################################################################
##
##  Expl. 0: Quaternion algebra
##
gap> T0 := [
>            [[[1],[1]],[[2],[ 1]],[[3],[ 1]],[[4],[ 1]]],
>            [[[2],[1]],[[1],[-1]],[[4],[ 1]],[[3],[-1]]],
>            [[[3],[1]],[[4],[-1]],[[1],[-1]],[[2],[ 1]]],
>            [[[4],[1]],[[3],[ 1]],[[2],[-1]],[[1],[-1]]],
>            0, 0 ];;
gap> id:= IdentityFromSCTable( T0 );
[ 1, 0, 0, 0 ]
gap> v:= [ 0, 1, 1, 1 ];;
gap> v = QuotientFromSCTable( T0, v, id );
true
gap> q:= QuotientFromSCTable( T0, id, v );
[ 0, -1/3, -1/3, -1/3 ]
gap> v = QuotientFromSCTable( T0, id, q );
true
gap> a:= AlgebraByStructureConstants( Rationals, T0 );
<algebra of dimension 4 over Rationals>
gap> Dimension( a );
4
gap> v:= ObjByExtRep( ElementsFamily( FamilyObj( a ) ), [ 0, 1, 0, 1 ] );
v.2+v.4
gap> One( v ); v^0;
v.1
v.1
gap> Zero( v ); 0*v;
0*v.1
0*v.1
gap> Inverse( v ); v^-1;
(-1/2)*v.2+(-1/2)*v.4
(-1/2)*v.2+(-1/2)*v.4
gap> AdditiveInverse( v ); -v;
(-1)*v.2+(-1)*v.4
(-1)*v.2+(-1)*v.4
gap> b:= Basis( a );
CanonicalBasis( <algebra of dimension 4 over Rationals> )
gap> Coefficients( b, v );
[ 0, 1, 0, 1 ]
gap> w:= LinearCombination( b, [ 1, 2, 3, 4 ] );
v.1+(2)*v.2+(3)*v.3+(4)*v.4
gap> v + w;
v.1+(3)*v.2+(3)*v.3+(5)*v.4
gap> v * w;
(-6)*v.1+(-2)*v.2+(-2)*v.3+(4)*v.4
gap> v = w;
false
gap> v < w;
true
gap> w < v;
false
gap> s:= Subalgebra( a, [ v, 0*v, v^0, w ] );
<algebra over Rationals, with 4 generators>
gap> Dimension( s );
4
gap> v:= Subspace( a, [ v, 0*v, v^0, w ] );
<vector space over Rationals, with 4 generators>
gap> Dimension( v );
3

#############################################################################
##
##  Expl. 1: $2.A6$, gen. by 20 quaternionic reflections over $H(\sqrt{3})$
##
gap> q:= QuaternionAlgebra( FieldByGenerators( Rationals, [ Sqrt(3) ] ) );
<algebra-with-one of dimension 4 over NF(12,[ 1, 11 ])>
gap> gens:= GeneratorsOfAlgebra( q );
[ e, i, j, k ]
gap> z:= Zero( q );;
gap> e:= gens[1];; i:= gens[2];; j:= gens[3];; k:= gens[4];;
gap> theta:= Sqrt(3) * j;
(-E(12)^7+E(12)^11)*j
gap> w:= ( -e + theta ) / 2;
(-1/2)*e+(-1/2*E(12)^7+1/2*E(12)^11)*j
gap> vectors:= [ [ theta, z ], [ (i+e)*w, w ], [ w, (i-e)*w ] ];;
gap> gens:= List( vectors, x -> ReflectionMat( x, w ) );;
gap> g:= GroupByGenerators( gens );;
gap> orb:= Orbit( g, vectors[1] );;
gap> permgrp:= Action( g, orb, OnRight );;
gap> Size( permgrp );
720

#############################################################################
##
##  Expl. 2: Poincare Lie algebra
##
gap> T1:= EmptySCTable( 10, 0, "antisymmetric" );;
gap> SetEntrySCTable( T1, 1, 3, [2,4] );
gap> SetEntrySCTable( T1, 1, 4, [-2,3] );
gap> SetEntrySCTable( T1, 1, 5, [-2,6] );
gap> SetEntrySCTable( T1, 1, 6, [2,5] );
gap> SetEntrySCTable( T1, 1, 8, [2,9] );
gap> SetEntrySCTable( T1, 1, 9, [-2,8] );
gap> SetEntrySCTable( T1, 2, 3, [2,3] );
gap> SetEntrySCTable( T1, 2, 4, [2,4] );
gap> SetEntrySCTable( T1, 2, 5, [-2,5] );
gap> SetEntrySCTable( T1, 2, 6, [-2,6] );
gap> SetEntrySCTable( T1, 2, 7, [2,7] );
gap> SetEntrySCTable( T1, 2, 10, [-2,10] );
gap> SetEntrySCTable( T1, 3, 5, [1,2] );
gap> SetEntrySCTable( T1, 3, 6, [1,1] );
gap> SetEntrySCTable( T1, 3, 9, [2,7] );
gap> SetEntrySCTable( T1, 3, 10, [1,9] );
gap> SetEntrySCTable( T1, 4, 5, [1,1] );
gap> SetEntrySCTable( T1, 4, 6, [-1,2] );
gap> SetEntrySCTable( T1, 4, 8, [-2,7] );
gap> SetEntrySCTable( T1, 4, 10, [-1,8] );
gap> SetEntrySCTable( T1, 5, 7, [1,9] );
gap> SetEntrySCTable( T1, 5, 9, [2,10] );
gap> SetEntrySCTable( T1, 6, 7, [1,8] );
gap> SetEntrySCTable( T1, 6, 8, [2,10] );
gap> IdentityFromSCTable( T1 );
fail
gap> l1:= AlgebraByStructureConstants( Rationals, T1 );
<algebra of dimension 10 over Rationals>
gap> IsLieAlgebra( l1 );
true
gap> IsCommutative( l1 );
false
gap> IsAssociative( l1 );
false
gap> Dimension( l1 );
10
gap> ucs:= LieUpperCentralSeries( l1 );
[ <Lie algebra over Rationals, with 0 generators> ]
gap> lcs:= LieLowerCentralSeries( l1 );
[ <Lie algebra of dimension 10 over Rationals> ]
gap> IsLieSolvable( l1 );
false
gap> IsLieNilpotent( l1 );
false
gap> IsLieAbelian( l1 );
false
gap> c:= LieCentre( l1 );
<Lie algebra of dimension 0 over Rationals>
gap> gens:= GeneratorsOfAlgebra( l1 );
[ v.1, v.2, v.3, v.4, v.5, v.6, v.7, v.8, v.9, v.10 ]
gap> s1:= Subalgebra( l1, [ gens[1] ] );
<Lie algebra over Rationals, with 1 generators>
gap> Dimension( s1 );
1
gap> IsLieSolvable( s1 );
true
gap> IsLieNilpotent( s1 );
true
gap> IsLieAbelian( s1 );
true
gap> LieCentre( s1 );
<two-sided ideal in <Lie algebra of dimension 1 over Rationals>, (dimension 1
 )>
gap> LieCentralizer( l1, s1 );
<Lie algebra of dimension 4 over Rationals>
gap> ps:= ProductSpace( l1, s1 );
<vector space of dimension 6 over Rationals>
gap> LieCentralizer( l1, ps );
<Lie algebra of dimension 0 over Rationals>
gap> LieNormalizer( l1, ps );
<Lie algebra of dimension 4 over Rationals>

# use AsAlgebra etc.
gap> KappaPerp( l1, ps );
<vector space of dimension 6 over Rationals>
gap> b:= Basis( l1 );
CanonicalBasis( <Lie algebra of dimension 10 over Rationals> )
gap> Print(AdjointMatrix( b, gens[1] ),"\n");
[ [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, -2, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 2, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 2, 0, 0, 0, 0 ], [ 0, 0, 0, 0, -2, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, -2, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 2, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ]
gap> der:= Derivations( b );
<Lie algebra of dimension 11 over Rationals>
gap> IsLieAlgebra( der );
true
gap> IsMatrixSpace( der );
true
gap> Dimension( der );
11
gap> Print(KillingMatrix( b ),"\n");
[ [ -24, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 24, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 12, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, -12, 0, 0, 0, 0 ], 
  [ 0, 0, 12, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, -12, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ]
gap> IsNilpotentElement( l1, gens[1] );
false
gap> IsNilpotentElement( s1, Random( s1 ) );
true
gap> IsRestrictedLieAlgebra( l1 );
false

# PthPowerImages( l1 );
gap> NonNilpotentElement( l1 );
v.1
gap> Print(AdjointBasis( b ),"\n");
Basis( VectorSpace( Rationals, 
[ [ [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, -2, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 2, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 2, 0, 0, 0, 0 ], [ 0, 0, 0, 0, -2, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, -2, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 2, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ], 
  [ [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 2, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 2, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, -2, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, -2, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 2, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, -2 ] ], 
  [ [ 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 ], 
      [ 0, -2, 0, 0, 0, 0, 0, 0, 0, 0 ], [ -2, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 2, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ], 
  [ [ 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, -1, 0, 0, 0, 0 ], 
      [ 2, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, -2, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, -2, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, -1 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ], 
  [ [ 0, 0, 0, -1, 0, 0, 0, 0, 0, 0 ], [ 0, 0, -1, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 2, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 2, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 2, 0 ] ], 
  [ [ 0, 0, -1, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ -2, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 2, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 2, 0, 0 ] ], 
  [ [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, -2, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, -1, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, -1, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ], 
  [ [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 2, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ -2, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, -2, 0, 0, 0, 0 ] ], 
  [ [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, -2, 0, 0, 0, 0, 0, 0, 0 ], [ 2, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, -2, 0, 0, 0, 0, 0 ] ], 
  [ [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, -1, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 2, 0, 0, 0, 0, 0, 0, 0, 0 ] ] 
 ] ), 
[ [ [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, -2, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 2, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 2, 0, 0, 0, 0 ], [ 0, 0, 0, 0, -2, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, -2, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 2, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ], 
  [ [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 2, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 2, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, -2, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, -2, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 2, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, -2 ] ], 
  [ [ 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 ], 
      [ 0, -2, 0, 0, 0, 0, 0, 0, 0, 0 ], [ -2, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 2, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ], 
  [ [ 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, -1, 0, 0, 0, 0 ], 
      [ 2, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, -2, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, -2, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, -1 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ], 
  [ [ 0, 0, 0, -1, 0, 0, 0, 0, 0, 0 ], [ 0, 0, -1, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 2, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 2, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 2, 0 ] ], 
  [ [ 0, 0, -1, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ -2, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 2, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 2, 0, 0 ] ], 
  [ [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, -2, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, -1, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, -1, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ], 
  [ [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 2, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ -2, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, -2, 0, 0, 0, 0 ] ], 
  [ [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, -2, 0, 0, 0, 0, 0, 0, 0 ], [ 2, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, -2, 0, 0, 0, 0, 0 ] ], 
  [ [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 ], 
      [ 0, 0, -1, 0, 0, 0, 0, 0, 0, 0 ], [ 0, 2, 0, 0, 0, 0, 0, 0, 0, 0 ] ] 
 ] )

#############################################################################
##
##  Expl. 3: Second example of Willem de Graaf
##
gap> T2:= EmptySCTable( 15, 0, "antisymmetric" );;
gap> SetEntrySCTable( T2, 1, 2, [-1,5] );
gap> SetEntrySCTable( T2, 1, 4, [-1,6] );
gap> SetEntrySCTable( T2, 1, 5, [-2,1] );
gap> SetEntrySCTable( T2, 1, 6, [-6,1] );
gap> SetEntrySCTable( T2, 1, 7, [-1,9] );
gap> SetEntrySCTable( T2, 1, 8, [-1,10] );
gap> SetEntrySCTable( T2, 1, 11, [3,5,1,6] );
gap> SetEntrySCTable( T2, 1, 12, [-1,13] );
gap> SetEntrySCTable( T2, 1, 13, [8,1] );
gap> SetEntrySCTable( T2, 1, 14, [4,1,1,10] );
gap> SetEntrySCTable( T2, 1, 15, [-3,9,1,10] );
gap> SetEntrySCTable( T2, 2, 3, [-1,7] );
gap> SetEntrySCTable( T2, 2, 5, [2,2] );
gap> SetEntrySCTable( T2, 2, 6, [-1,11] );
gap> SetEntrySCTable( T2, 2, 7, [-2,2] );
gap> SetEntrySCTable( T2, 2, 8, [-1,12] );
gap> SetEntrySCTable( T2, 2, 9, [-1,5,1,7] );
gap> SetEntrySCTable( T2, 2, 10, [-1,14] );
gap> SetEntrySCTable( T2, 2, 13, [-4,2,1,12] );
gap> SetEntrySCTable( T2, 2, 14, [-8,2] );
gap> SetEntrySCTable( T2, 2, 15, [-4,2,1,11] );
gap> SetEntrySCTable( T2, 3, 4, [-1,8] );
gap> SetEntrySCTable( T2, 3, 5, [1,9] );
gap> SetEntrySCTable( T2, 3, 6, [-1,10] );
gap> SetEntrySCTable( T2, 3, 7, [2,3] );
gap> SetEntrySCTable( T2, 3, 8, [-2,3] );
gap> SetEntrySCTable( T2, 3, 11, [1,5,1,6,-3,7,1,8,1,13] );
gap> SetEntrySCTable( T2, 3, 12, [-1,7,1,8] );
gap> SetEntrySCTable( T2, 3, 13, [-1,9,1,10] );
gap> SetEntrySCTable( T2, 3, 14, [4,3,1,10] );
gap> SetEntrySCTable( T2, 3, 15, [8,3] );
gap> SetEntrySCTable( T2, 4, 5, [-1,11] );
gap> SetEntrySCTable( T2, 4, 6, [6,4] );
gap> SetEntrySCTable( T2, 4, 7, [1,12] );
gap> SetEntrySCTable( T2, 4, 8, [2,4] );
gap> SetEntrySCTable( T2, 4, 9, [-1,5,-1,6,3,7,-1,8,-1,14] );
gap> SetEntrySCTable( T2, 4, 10, [1,6,3,8] );
gap> SetEntrySCTable( T2, 4, 13, [-4,4,3,12] );
gap> SetEntrySCTable( T2, 4, 14, [1,11,3,12] );
gap> SetEntrySCTable( T2, 4, 15, [-4,4,1,11] );
gap> SetEntrySCTable( T2, 5, 6, [-3,5,1,6] );
gap> SetEntrySCTable( T2, 5, 7, [-1,5,-1,7] );
gap> SetEntrySCTable( T2, 5, 8, [-1,13,1,14] );
gap> SetEntrySCTable( T2, 5, 9, [-2,1,1,9] );
gap> SetEntrySCTable( T2, 5, 10, [4,1,1,10] );
gap> SetEntrySCTable( T2, 5, 11, [6,2,-1,11] );
gap> SetEntrySCTable( T2, 5, 12, [4,2,-1,12] );
gap> SetEntrySCTable( T2, 5, 13, [4,5,1,13] );
gap> SetEntrySCTable( T2, 5, 14, [-4,5,-1,14] );
gap> SetEntrySCTable( T2, 5, 15, [-4,5,-1,6,-3,7,-1,14] );
gap> SetEntrySCTable( T2, 6, 7, [1,5,1,6,-3,7,1,8,1,13,1,14] );
gap> SetEntrySCTable( T2, 6, 8, [1,6,-3,8] );
gap> SetEntrySCTable( T2, 6, 9, [-4,1,3,9] );
gap> SetEntrySCTable( T2, 6, 10, [6,1,3,10] );
gap> SetEntrySCTable( T2, 6, 11, [6,4,-3,11] );
gap> SetEntrySCTable( T2, 6, 12, [4,4,-3,12] );
gap> SetEntrySCTable( T2, 6, 13, [4,6,3,13] );
gap> SetEntrySCTable( T2, 6, 14, [-3,5,4,6,3,8,3,13] );
gap> SetEntrySCTable( T2, 6, 15, [-1,6,-9,7,6,8,3,14] );
gap> SetEntrySCTable( T2, 7, 8, [-1,7,-1,8] );
gap> SetEntrySCTable( T2, 7, 9, [2,3,-1,9] );
gap> SetEntrySCTable( T2, 7, 10, [-4,3,-1,10] );
gap> SetEntrySCTable( T2, 7, 11, [-4,2,1,11] );
gap> SetEntrySCTable( T2, 7, 12, [-2,2,1,12] );
gap> SetEntrySCTable( T2, 7, 13, [-1,5,-4,7,1,8,1,14] );
gap> SetEntrySCTable( T2, 7, 14, [-4,7,1,14] );
gap> SetEntrySCTable( T2, 7, 15, [1,5,1,6,1,7,1,8,1,13] );
gap> SetEntrySCTable( T2, 8, 9, [-4,3,1,9] );
gap> SetEntrySCTable( T2, 8, 10, [6,3,1,10] );
gap> SetEntrySCTable( T2, 8, 11, [4,4,-1,11] );
gap> SetEntrySCTable( T2, 8, 12, [2,4,-1,12] );
gap> SetEntrySCTable( T2, 8, 13, [1,5,2,6,-3,8,1,14] );
gap> SetEntrySCTable( T2, 8, 14, [-1,5,6,7,3,8,-1,13] );
gap> SetEntrySCTable( T2, 8, 15, [-1,5,-1,6,3,7,3,8,-1,13] );
gap> SetEntrySCTable( T2, 9, 11, [-5,5,-2,6,6,7,-1,8,-1,13,-1,14] );
gap> SetEntrySCTable( T2, 9, 12, [-1,5,4,7,-1,8,1,13,-1,14] );
gap> SetEntrySCTable( T2, 9, 13, [-6,1,4,9] );
gap> SetEntrySCTable( T2, 9, 14, [-4,1,-4,3,-2,10] );
gap> SetEntrySCTable( T2, 9, 15, [-10,3,4,9] );
gap> SetEntrySCTable( T2, 10, 11, [3,5,4,6,3,8,3,13,-3,14] );
gap> SetEntrySCTable( T2, 10, 12, [-1,5,3,8,-1,13,-1,14] );
gap> SetEntrySCTable( T2, 10, 13, [10,1,4,10] );
gap> SetEntrySCTable( T2, 10, 14, [6,1,6,3,6,9,8,10] );
gap> SetEntrySCTable( T2, 10, 15, [18,3,4,10] );
gap> SetEntrySCTable( T2, 11, 13, [12,2,4,4,-6,12] );
gap> SetEntrySCTable( T2, 11, 14, [18,2,-4,11] );
gap> SetEntrySCTable( T2, 11, 15, [6,2,6,4,-8,11,6,12] );
gap> SetEntrySCTable( T2, 12, 13, [6,2,2,4,2,11,-8,12] );
gap> SetEntrySCTable( T2, 12, 14, [10,2,-4,12] );
gap> SetEntrySCTable( T2, 12, 15, [4,2,4,4,-2,11] );
gap> SetEntrySCTable( T2, 13, 14, [11,5,-3,8,1,13,1,14] );
gap> SetEntrySCTable( T2, 13, 15, [8,5,6,6,12,7,-6,8,4,13,-2,14] );
gap> SetEntrySCTable( T2, 14, 15, [3,5,4,6,18,7,3,8,3,13,-3,14] );
gap> l2:= AlgebraByStructureConstants( Rationals, T2 );
<algebra of dimension 15 over Rationals>
gap> IsLieAlgebra( l2 );
true
gap> IsCommutative( l2 );
false
gap> IsAssociative( l2 );
false
gap> Dimension( l2 );
15
gap> ucs:= LieUpperCentralSeries( l2 );
[ <two-sided ideal in <Lie algebra of dimension 15 over Rationals>, 
      (dimension 1)>, <Lie algebra over Rationals, with 0 generators> ]
gap> lcs:= LieLowerCentralSeries( l2 );
[ <Lie algebra of dimension 15 over Rationals>, 
  <Lie algebra of dimension 14 over Rationals> ]
gap> IsLieSolvable( l2 );
false
gap> IsLieNilpotent( l2 );
false
gap> IsLieAbelian( l2 );
false
gap> LieCentre( l2 );
<two-sided ideal in <Lie algebra of dimension 15 over Rationals>, (dimension 1
 )>
gap> gens:= GeneratorsOfAlgebra( l2 );;
gap> Print(gens,"\n");
[ v.1, v.2, v.3, v.4, v.5, v.6, v.7, v.8, v.9, v.10, v.11, v.12, v.13, v.14, 
  v.15 ]
gap> s2:= Subalgebra( l2, [ gens[1] ] );
<Lie algebra over Rationals, with 1 generators>
gap> Dimension( s2 );
1
gap> IsLieSolvable( s2 );
true
gap> IsLieNilpotent( s2 );
true
gap> IsLieAbelian( s2 );
true
gap> LieCentre( s2 );
<two-sided ideal in <Lie algebra of dimension 1 over Rationals>, (dimension 1
 )>
gap> LieCentralizer( l2, s2 );
<Lie algebra of dimension 9 over Rationals>
gap> ps:= ProductSpace( l2, s2 );
<vector space of dimension 6 over Rationals>
gap> LieCentralizer( l2, ps );
<Lie algebra of dimension 1 over Rationals>
gap> LieNormalizer( l2, ps );
<Lie algebra of dimension 10 over Rationals>
gap> Print( KappaPerp( l2, ps ), "\n" );
VectorSpace( Rationals, [ v.1, v.3, (-3)*v.5+v.6, v.5+(3)*v.7+v.8, v.9, v.10, 
  (3)*v.2+v.4+v.11, v.2+v.4+v.12, (4)*v.5+v.13, v.5+(-3)*v.7+v.14, 
  (-1)*v.5+(-6)*v.7+v.15 ] )
gap> b:= Basis( l2 );
CanonicalBasis( <Lie algebra of dimension 15 over Rationals> )
gap> Print(AdjointMatrix( b, gens[1] ),"\n");
[ [ 0, 0, 0, 0, -2, -6, 0, 0, 0, 0, 0, 0, 8, 4, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0 ], 
  [ 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, -3 ], 
  [ 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 1, 1 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ]
gap> der:= Derivations( b );
<Lie algebra of dimension 17 over Rationals>
gap> IsLieAlgebra( der );
true
gap> IsMatrixSpace( der );
true
gap> Dimension( der );
17
gap> Print(KillingMatrix( b ),"\n");
[ [ 0, -8, 0, -24, 0, 0, 0, 0, 0, 0, 48, 32, 0, 0, 0 ], 
  [ -8, 0, -8, 0, 0, 0, 0, 0, 16, -32, 0, 0, 0, 0, 0 ], 
  [ 0, -8, 0, -8, 0, 0, 0, 0, 0, 0, 32, 16, 0, 0, 0 ], 
  [ -24, 0, -8, 0, 0, 0, 0, 0, 32, -48, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 16, 48, -16, 32, 0, 0, 0, 0, -64, -64, -80 ], 
  [ 0, 0, 0, 0, 48, 144, -32, 48, 0, 0, 0, 0, -192, -144, -144 ], 
  [ 0, 0, 0, 0, -16, -32, 16, -16, 0, 0, 0, 0, 48, 64, 64 ], 
  [ 0, 0, 0, 0, 32, 48, -16, 16, 0, 0, 0, 0, -80, -80, -64 ], 
  [ 0, 16, 0, 32, 0, 0, 0, 0, 0, 0, -80, -48, 0, 0, 0 ], 
  [ 0, -32, 0, -48, 0, 0, 0, 0, 0, 0, 144, 80, 0, 0, 0 ], 
  [ 48, 0, 32, 0, 0, 0, 0, 0, -80, 144, 0, 0, 0, 0, 0 ], 
  [ 32, 0, 16, 0, 0, 0, 0, 0, -48, 80, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, -64, -192, 48, -80, 0, 0, 0, 0, 256, 208, 224 ], 
  [ 0, 0, 0, 0, -64, -144, 64, -80, 0, 0, 0, 0, 208, 256, 272 ], 
  [ 0, 0, 0, 0, -80, -144, 64, -64, 0, 0, 0, 0, 224, 272, 256 ] ]
gap> IsNilpotentElement( l2, gens[1] );
true
gap> IsNilpotentElement( s2, Random( s2 ) );
true
gap> IsRestrictedLieAlgebra( l2 );
false
gap> NonNilpotentElement( l2 );
v.5

#############################################################################
##
##  Expl. 4: Third example of Willem de Graaf (solvable Lie algebra)
##
gap> T3:= EmptySCTable( 14, 0, "antisymmetric" );;
gap> SetEntrySCTable( T3, 1, 5, [1,2] );
gap> SetEntrySCTable( T3, 1, 6, [1,3] );
gap> SetEntrySCTable( T3, 1, 7, [1,4] );
gap> SetEntrySCTable( T3, 1, 11, [-2,1] );
gap> SetEntrySCTable( T3, 1, 12, [-1,1] );
gap> SetEntrySCTable( T3, 1, 13, [-1,1] );
gap> SetEntrySCTable( T3, 1, 14, [-1,1] );
gap> SetEntrySCTable( T3, 2, 8, [1,3] );
gap> SetEntrySCTable( T3, 2, 9, [1,4] );
gap> SetEntrySCTable( T3, 2, 11, [-1,2] );
gap> SetEntrySCTable( T3, 2, 12, [-2,2] );
gap> SetEntrySCTable( T3, 2, 13, [-1,2] );
gap> SetEntrySCTable( T3, 2, 14, [-1,2] );
gap> SetEntrySCTable( T3, 3, 10, [1,4] );
gap> SetEntrySCTable( T3, 3, 11, [-1,3] );
gap> SetEntrySCTable( T3, 3, 12, [-1,3] );
gap> SetEntrySCTable( T3, 3, 13, [-2,3] );
gap> SetEntrySCTable( T3, 3, 14, [-1,3] );
gap> SetEntrySCTable( T3, 4, 11, [-1,4] );
gap> SetEntrySCTable( T3, 4, 12, [-1,4] );
gap> SetEntrySCTable( T3, 4, 13, [-1,4] );
gap> SetEntrySCTable( T3, 4, 14, [-2,4] );
gap> SetEntrySCTable( T3, 5, 8, [1,6] );
gap> SetEntrySCTable( T3, 5, 9, [1,7] );
gap> SetEntrySCTable( T3, 5, 11, [1,5] );
gap> SetEntrySCTable( T3, 5, 12, [-1,5] );
gap> SetEntrySCTable( T3, 6, 10, [1,7] );
gap> SetEntrySCTable( T3, 6, 11, [1,6] );
gap> SetEntrySCTable( T3, 6, 13, [-1,6] );
gap> SetEntrySCTable( T3, 7, 11, [1,7] );
gap> SetEntrySCTable( T3, 7, 14, [-1,7] );
gap> SetEntrySCTable( T3, 8, 10, [1,9] );
gap> SetEntrySCTable( T3, 8, 12, [1,8] );
gap> SetEntrySCTable( T3, 8, 13, [-1,8] );
gap> SetEntrySCTable( T3, 9, 12, [1,9] );
gap> SetEntrySCTable( T3, 9, 14, [-1,9] );
gap> SetEntrySCTable( T3, 10, 13, [1,10] );
gap> SetEntrySCTable( T3, 10, 14, [-1,10] );
gap> l3:= AlgebraByStructureConstants( Rationals, T3 );
<algebra of dimension 14 over Rationals>
gap> IsLieAlgebra( l3 );
true
gap> IsCommutative( l3 );
false
gap> IsAssociative( l3 );
false
gap> Dimension( l3 );
14
gap> ucs:= LieUpperCentralSeries( l3 );
[ <Lie algebra over Rationals, with 0 generators> ]
gap> lcs:= LieLowerCentralSeries( l3 );
[ <Lie algebra of dimension 14 over Rationals>, 
  <Lie algebra of dimension 10 over Rationals> ]
gap> IsLieSolvable( l3 );
true
gap> IsLieNilpotent( l3 );
false
gap> IsLieAbelian( l3 );
false
gap> LieCentre( l3 );
<Lie algebra of dimension 0 over Rationals>
gap> gens:= GeneratorsOfAlgebra( l3 );
[ v.1, v.2, v.3, v.4, v.5, v.6, v.7, v.8, v.9, v.10, v.11, v.12, v.13, v.14 ]
gap> s3:= Subalgebra( l3, [ gens[1] ] );
<Lie algebra over Rationals, with 1 generators>
gap> Dimension( s3 );
1
gap> IsLieSolvable( s3 );
true
gap> IsLieNilpotent( s3 );
true
gap> IsLieAbelian( s3 );
true
gap> LieCentre( s3 );
<two-sided ideal in <Lie algebra of dimension 1 over Rationals>, (dimension 1
 )>
gap> LieCentralizer( l3, s3 );
<Lie algebra of dimension 10 over Rationals>
gap> ps:= ProductSpace( l3, s3 );;
gap> Print( ps, "\n" );
VectorSpace( Rationals, [ v.2, v.3, v.4, v.1 ] )
gap> LieCentralizer( l3, ps );
<Lie algebra of dimension 4 over Rationals>
gap> LieNormalizer( l3, ps );
<Lie algebra of dimension 14 over Rationals>
gap> KappaPerp( l3, ps );
<vector space of dimension 14 over Rationals>
gap> b:= Basis( l3 );
CanonicalBasis( <Lie algebra of dimension 14 over Rationals> )
gap> Print(AdjointMatrix( b, gens[1] ),"\n");
[ [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -2, -1, -1, -1 ], 
  [ 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ]
gap> der:= Derivations( b );
<Lie algebra of dimension 14 over Rationals>
gap> IsLieAlgebra( der );
true
gap> IsMatrixSpace( der );
true
gap> Dimension( der );
14
gap> Print(KillingMatrix( b ),"\n");
[ [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 5, 5, 5 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 10, 5, 5 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 10, 5 ], 
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 5, 10 ] ]
gap> IsNilpotentElement( l3, gens[1] );
true
gap> IsNilpotentElement( s3, Random( s3 ) );
true
gap> IsRestrictedLieAlgebra( l3 );
false
gap> NonNilpotentElement( l3 );
v.11

#############################################################################
##
##  Expl. 5: Trivial s.c. algebra
##
gap> t:= AlgebraByStructureConstants( Rationals, [ 0, 0 ] );
<algebra over Rationals, with 0 generators>
gap> z:= Zero( t );
<zero of trivial s.c. algebra>
gap> Random( t );
<zero of trivial s.c. algebra>
gap> b:=Basis( t );
CanonicalBasis( <algebra of dimension 0 over Rationals> )
gap> coeff:= Coefficients( b, z );
<empty row vector>
gap> LinearCombination( b, coeff );
<zero of trivial s.c. algebra>
gap> LinearCombination( b, [] );
<zero of trivial s.c. algebra>
gap> c:= Centre( t );
<algebra of dimension 0 over Rationals>
gap> c = t;
true

#############################################################################
gap> STOP_TEST( "algsc.tst", 1);

#############################################################################
##
#E
