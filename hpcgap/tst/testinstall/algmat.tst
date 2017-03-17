#############################################################################
##
#W  algmat.tst                  GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
gap> START_TEST("algmat.tst");

#############################################################################
gap> Ring( [ [ [ Z(9), Z(3) ], [ Z(3), 0*Z(3) ] ],
>            [ [ 0*Z(9), Z(27) ], [ Z(3)^0, Z(3) ] ] ] );
<algebra over GF(3), with 2 generators>
gap> Ring( [ [ 1, E(5) ], [ E(5), 0 ] ] );
<free left module over Integers, and ring, with 1 generators>
gap> Ring( [ [ 1, 0 ], [ 0, 0 ] ], [ [ 0, E(5) ], [ E(7), 5 ] ] );
<free left module over Integers, and ring, with 2 generators>
gap> RingWithOne( [ [ [ Z(9), Z(3) ], [ Z(3), 0*Z(3) ] ],
>                  [ [ 0*Z(9), Z(27) ], [ Z(3)^0, Z(3) ] ] ] );
<algebra-with-one over GF(3), with 2 generators>
gap> RingWithOne( [ [ 1, E(5) ], [ E(5), 0 ] ] );
<free left module over Integers, and ring-with-one, with 1 generators>
gap> RingWithOne( [ [ 1, 0 ], [ 0, 0 ] ], [ [ 0, E(5) ], [ E(7), 5 ] ] );
<free left module over Integers, and ring-with-one, with 2 generators>
gap> mat:= [ [ 1, E(4) ], [ 1, 1 ] ];
[ [ 1, E(4) ], [ 1, 1 ] ]
gap> r:= DefaultRing( [ mat ] );
<algebra over Rationals, with 1 generators>
gap> mat in r;
true

#############################################################################
gap> z:= Algebra( GF(3), [], [ [ 0*Z(9), 0*Z(3) ], [ 0*Z(3), 0*Z(3) ] ] );
<algebra over GF(3)>
gap> IsGaussianMatrixSpace( z );
true
gap> IsTrivial( z );
true
gap> Dimension( z );
0
gap> a:= Algebra( GF(3), [ [ [ Z(9), Z(3) ], [ Z(3), 0*Z(3) ] ],
>                   [ [ 0*Z(9), Z(27) ], [ Z(3)^0, Z(3) ] ] ] );
<algebra over GF(3), with 2 generators>
gap> IsNonGaussianMatrixSpace( a );
true
gap> Dimension( a );
24
gap> b:= Algebra( Rationals, [ [ [ 1, E(5) ], [ E(5), 0 ] ] ] );
<algebra over Rationals, with 1 generators>
gap> IsNonGaussianMatrixSpace( b );
true
gap> Dimension( b );
8
gap> c:= Algebra( CF(5), [ [ [ 1, E(5) ], [ E(5), 0 ] ] ],
>                     [ [ 0, 0 ], [ 0, 0 ] ] );
<algebra over CF(5), with 1 generators>
gap> IsGaussianMatrixSpace( c );
true
gap> Dimension( c );
2
gap> d:= Algebra( Rationals, [ [ [ 1, 0 ], [ 0, 0 ] ],
>                       [ [ 0, E(3) ], [ E(4), 5 ] ] ] );
<algebra over Rationals, with 2 generators>
gap> IsNonGaussianMatrixSpace( d );
true
gap> Dimension( d );
16

#############################################################################
gap> uz:= AlgebraWithOne( GF(3), [],
>                            [ [ 0*Z(9), 0*Z(3) ], [ 0*Z(3), 0*Z(3) ] ] );
<algebra-with-one over GF(3), with 0 generators>
gap> IsGaussianMatrixSpace( uz );
true
gap> IsTrivial( uz );
false
gap> Dimension( uz );
1
gap> ua:= AlgebraWithOne( GF(3), [ [ [ Z(9), Z(3) ], [ Z(3), 0*Z(3) ] ],
>                   [ [ 0*Z(9), Z(27) ], [ Z(3)^0, Z(3) ] ] ] );
<algebra-with-one over GF(3), with 2 generators>
gap> IsNonGaussianMatrixSpace( ua );
true
gap> Dimension( ua );
24
gap> ub:= AlgebraWithOne( Rationals, [ [ [ 1, E(5) ], [ E(5), 0 ] ] ] );
<algebra-with-one over Rationals, with 1 generators>
gap> IsNonGaussianMatrixSpace( ub );
true
gap> Dimension( ub );
8
gap> uc:= AlgebraWithOne( CF(5), [ [ [ 1, E(5) ], [ E(5), 0 ] ] ],
>                     [ [ 0, 0 ], [ 0, 0 ] ] );
<algebra-with-one over CF(5), with 1 generators>
gap> IsGaussianMatrixSpace( uc );
true
gap> Dimension( uc );
2
gap> ud:= AlgebraWithOne( Rationals, [ [ [ 1, 0 ], [ 0, 0 ] ],
>                       [ [ 0, E(3) ], [ E(4), 5 ] ] ] );
<algebra-with-one over Rationals, with 2 generators>
gap> IsNonGaussianMatrixSpace( ud );
true
gap> Dimension( ud );
16

#############################################################################
gap> IsUnit( c, Zero( c ) );
false
gap> r:= [ [ 1, 1 ], [ 1, 1 ] ]; r in c; IsUnit( c, r );
[ [ 1, 1 ], [ 1, 1 ] ]
false
false
gap> r:= [ [ 1, 1 ], [ 0, 1 ] ]; r in c; IsUnit( c, r );
[ [ 1, 1 ], [ 0, 1 ] ]
false
false
gap> IsUnit( c, [ [ 1, E(5) ], [ E(5), 0 ] ] );
true
gap> IdentityMat( 2, GF(3) );
[ [ Z(3)^0, 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ]

#############################################################################
gap> IsAssociative( a );
true
gap> rada:= RadicalOfAlgebra( a );
<algebra of dimension 0 over GF(3)>
gap> Dimension( rada );
0
gap> IsAssociative( c );
true
gap> radc:= RadicalOfAlgebra( c );
<algebra of dimension 0 over CF(5)>
gap> Dimension( radc );
0

#############################################################################
gap> cen:= Centralizer( c, GeneratorsOfAlgebra( c )[1] );
<algebra of dimension 2 over CF(5)>
gap> cen = c;
true
gap> cen:= Centralizer( c, cen );
<algebra of dimension 2 over CF(5)>
gap> cen = c;
true
gap> cen:= Centralizer( uc, GeneratorsOfAlgebra( uc )[1] );
<algebra-with-one of dimension 2 over CF(5)>
gap> cen = uc;
true
gap> cen:= Centralizer( uc, cen );
<algebra-with-one of dimension 2 over CF(5)>
gap> cen = uc;
true
gap> cen:= Centralizer( a, GeneratorsOfAlgebra( a )[1] );
<algebra of dimension 12 over GF(3)>
gap> Dimension( cen );
12
gap> cen:= Centralizer( a, cen );
<algebra of dimension 12 over GF(3)>
gap> Dimension( cen );
12
gap> cen:= Centralizer( ua, One( ua ) );
<algebra-with-one of dimension 24 over GF(3)>
gap> cen = ua;
true
gap> cen:= Centralizer( ua, GeneratorsOfAlgebra( ua )[2] );
<algebra-with-one of dimension 12 over GF(3)>
gap> Dimension( cen );
12
gap> cen:= Centralizer( ua, cen );
<algebra-with-one of dimension 12 over GF(3)>
gap> Dimension( cen );
12

#############################################################################
gap> fullcen:= FullMatrixAlgebraCentralizer( CF(5),
>                  GeneratorsOfAlgebra( c ) );
<algebra-with-one of dimension 2 over CF(5)>
gap> Dimension( fullcen );
2
gap> fullcen:= FullMatrixAlgebraCentralizer( GF(3^6),
>                  GeneratorsOfAlgebra( a ) );
<algebra-with-one of dimension 1 over GF(3^6)>
gap> Dimension( fullcen );
1

#############################################################################
gap> f:= GF(2)^[3,3];
( GF(2)^[ 3, 3 ] )
gap> f = FullMatrixFLMLOR( GF(2), 3 );
true
gap> IsFullMatrixModule( f );
true
gap> IsAlgebra( f );
true
gap> u:= Algebra( GF(2),
>         [ [ [ 1, 1, 1 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ] * Z(2) ] );
<algebra over GF(2), with 1 generators>
gap> Dimension( u );
2
gap> IsSubset( f, u );
true
gap> cenu:= Centralizer( f, u );
<algebra-with-one of dimension 5 over GF(2)>
gap> Dimension( cenu );
5
gap> v:= FreeLeftModule( GF(2),
>         [ [ [ 1, 1, 1 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ] * Z(2) ] );
<vector space over GF(2), with 1 generators>
gap> Dimension( v );
1
gap> IsSubset( f, v );
true
gap> cenv:= Centralizer( f, v );
<algebra-with-one of dimension 5 over GF(2)>
gap> Dimension( cenv );
5
gap> IsSubset( cenv, cenu );
true
gap> cenv = Centralizer( f, GeneratorsOfLeftModule( v ) );
true
gap> 
gap> Centralizer( f, [] ) = f;
true

#############################################################################
gap> l:= FullMatrixLieAlgebra( GF(2), 3 );
<Lie algebra over GF(2), with 5 generators>
gap> Dimension( l );
9

#############################################################################
gap> sum:= DirectSumOfAlgebras( f, f );
<algebra over GF(2), with 6 generators>
gap> Dimension( sum ) = 2 * Dimension( f );
true
gap> IsFullMatrixModule( sum );
false
gap> sum:= DirectSumOfAlgebras( l, l );
<Lie algebra over GF(2), with 10 generators>
gap> Dimension( sum ) = 2 * Dimension( l );
true
gap> IsFullMatrixModule( sum );
false
gap> sum:= DirectSumOfAlgebras( l, f );
<algebra of dimension 18 over GF(2)>
gap> Dimension( sum ) = 2 * Dimension( l );
true
gap> IsFullMatrixModule( sum );
false

#############################################################################
gap> n:= NullAlgebra( GF(3) );;
gap> Dimension( n );
0
gap> b:= Basis( n );
SemiEchelonBasis( <algebra of dimension 0 over GF(3)>, [  ] )
gap> BasisVectors( b );
[  ]
gap> zero:= Zero( n );
EmptyMatrix( 3 )
gap> Coefficients( b, zero );
[  ]
gap> zero + zero = zero;
true
gap> zero * zero = zero;
true
gap> [] * zero;
[  ]
gap> zero * [];
[  ]
gap> Z(3) * zero = zero;
true
gap> zero * Z(3) = zero;
true
gap> zero^3 = zero;
true
gap> zero^-3 = zero;
true

#############################################################################

# missing: F.p. algebras

# missing: standard bases of matrix algebras,
#          fingerprints, 'RepresentativeOperation'

# missing: natural modules, abstract expressions, field multiplicity

#############################################################################
gap> STOP_TEST( "algmat.tst", 1);

#############################################################################
##
#E
