#############################################################################
##
#W  algsc.tst                   GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright 1996,    Lehrstuhl D fuer Mathematik,   RWTH Aachen,    Germany
##
gap> START_TEST("$Id$");

# Expl. 1: Quaternion algebra

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
<algebra over Rationals, with 4 generators>
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

gap> b:= BasisOfDomain( a );
CanonicalBasis( <algebra over Rationals, with 4 generators> )
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
Subspace( <algebra over Rationals, with 4 generators>, 
[ v.2+v.4, 0*v.1, v.1, v.1+(2)*v.2+(3)*v.3+(4)*v.4 ] )
gap> Dimension( v );
3


# Expl. 2: Poincare Lie algebra

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
<algebra over Rationals, with 10 generators>
gap> IsLieAlgebra( l1 );
true
gap> IsCommutative( l1 );
false
gap> IsAssociative( l1 );
false
gap> Dimension( l1 );
10


# Expl. 3: Second example of Willem de Graaf

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
<algebra over Rationals, with 15 generators>
gap> IsLieAlgebra( l2 );
true
gap> IsCommutative( l2 );
false
gap> IsAssociative( l2 );
false
gap> Dimension( l2 );
15


# Expl. 4: Third example of Willem de Graaf (solvable Lie algebra)

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
<algebra over Rationals, with 14 generators>
gap> IsLieAlgebra( l3 );
true
gap> IsCommutative( l3 );
false
gap> IsAssociative( l3 );
false
gap> Dimension( l3 );
14

gap> STOP_TEST( "algsc.tst", 100000 );


#############################################################################
##
#E  algsc.tst . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##



