#############################################################################
##
#W  vspcmali.tst                GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  This file ontains tests for vector spaces of Lie matrices.
##
##  (The test files 'vspcrow.tst' and 'vspcmat.tst' should contain the same
##  tests.)
##
gap> START_TEST("vspcmali.tst");

#############################################################################
##
##  1. Construct Gaussian and non-Gaussian Lie matrix spaces
##
gap> z:= LeftModuleByGenerators( GF(3), [], LieObject( [ [ 0*Z(9) ] ] ) );
<vector space of dimension 0 over GF(3)>
gap> IsGaussianMatrixSpace( z );
true
gap> IsNonGaussianMatrixSpace( z );
false
gap> v:= LeftModuleByGenerators( GF(9),
>            [ LieObject( [ [ Z(3), Z(3) ], [ Z(3), Z(3) ] ] ) ] );
<vector space over GF(3^2), with 1 generators>
gap> IsGaussianMatrixSpace( v );
true
gap> IsNonGaussianMatrixSpace( v );
false
gap> v = LeftModuleByGenerators( GF(9),
>            [ LieObject( [ [ Z(3), Z(3) ], [ Z(3), Z(3) ] ] ) ], Zero( v ) );
true
gap> w:= LeftModuleByGenerators( GF(9),
>            [ LieObject( [ [ Z(27), Z(3) ], [ Z(3), Z(3) ] ] ) ] );
<vector space over GF(3^2), with 1 generators>
gap> IsGaussianMatrixSpace( w );
false
gap> IsNonGaussianMatrixSpace( w );
true
gap> w = LeftModuleByGenerators( GF(9),
>          [ LieObject( [ [ Z(27), Z(3) ], [ Z(3), Z(3) ] ] ) ], Zero( w ) );
true

#############################################################################
##
##  2. Methods for bases of non-Gaussian matrix spaces
##
gap> Dimension( w );
1
gap> n:= NiceVector( w, LieObject( [ [ Z(27), Z(3) ], [ Z(3), Z(3) ] ] ) );
[ Z(3^3), Z(3), Z(3), Z(3) ]
gap> UglyVector( w, n ) = [ [ Z(27), Z(3) ], [ Z(3), Z(3) ] ];
false
gap> UglyVector( w, n ) = LieObject( [ [ Z(27), Z(3) ], [ Z(3), Z(3) ] ] );
true

#############################################################################
##
##  3. Methods for semi-echelonized bases of Gaussian matrix spaces
##
gap> v:= LeftModuleByGenerators( GF(9),
>     [ LieObject( [ [ Z(3), Z(3) ], [ Z(3),   Z(3) ] ] ),
>       LieObject( [ [ Z(3), Z(3) ], [ Z(3), 0*Z(3) ] ] ) ] );
<vector space over GF(3^2), with 2 generators>
gap> b:= SemiEchelonBasis( v );
SemiEchelonBasis( <vector space over GF(3^2), with 2 generators>, ... )
gap> lc:= LinearCombination( b, [ Z(3)^0, Z(3) ] );
LieObject( [ [ Z(3)^0, Z(3)^0 ], [ Z(3)^0, 0*Z(3) ] ] )
gap> Coefficients( b, lc );
[ Z(3)^0, Z(3) ]
gap> SiftedVector( b, LieObject( [ [ Z(3), Z(3) ], [ 0*Z(3), 0*Z(3) ] ] ) );
LieObject( [ [ 0*Z(3), 0*Z(3) ], [ Z(3)^0, 0*Z(3) ] ] )
gap> SiftedVector( b, LieObject( [ [ 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3) ] ] ) );
LieObject( [ [ 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3) ] ] )
gap> b:= Basis( v, [ LieObject( [ [ Z(3), Z(3) ], [ Z(3), Z(3) ] ] ) ] );
fail
gap> b:= Basis( v, [ LieObject( [ [ Z(3), Z(3) ], [ Z(3),   Z(3) ] ] ),
>                    LieObject( [ [ Z(3), Z(3) ], [ Z(3), 0*Z(3) ] ] ) ] );
Basis( <vector space over GF(3^2), with 2 generators>, 
[ LieObject( [ [ Z(3), Z(3) ], [ Z(3), Z(3) ] ] ), 
  LieObject( [ [ Z(3), Z(3) ], [ Z(3), 0*Z(3) ] ] ) ] )
gap> IsSemiEchelonized( b );
false
gap> b:= Basis( v, [ LieObject( [ [ Z(3), Z(3) ], [ Z(3), Z(3) ] ] ),
>                    LieObject( [ [ 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3) ] ] ) ] );
Basis( <vector space over GF(3^2), with 2 generators>, 
[ LieObject( [ [ Z(3), Z(3) ], [ Z(3), Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3) ] ] ) ] )
gap> IsSemiEchelonized( b );
false
gap> b:= Basis( v,
>        [ LieObject( [ [ Z(3)^0, Z(3)^0 ], [ Z(3)^0, Z(3)^0 ] ] ),
>          LieObject( [ [ Z(3)^0, Z(3)^0 ], [ Z(3)^0, 0*Z(3) ] ] ) ] );
Basis( <vector space over GF(3^2), with 2 generators>, 
[ LieObject( [ [ Z(3)^0, Z(3)^0 ], [ Z(3)^0, Z(3)^0 ] ] ), 
  LieObject( [ [ Z(3)^0, Z(3)^0 ], [ Z(3)^0, 0*Z(3) ] ] ) ] )
gap> IsSemiEchelonized( b );
false
gap> b:= Basis( v,
>           [ LieObject( [ [ Z(3)^0, Z(3)^0 ], [ Z(3)^0, Z(3)^0 ] ] ),
>             LieObject( [ [ 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ] ) ] );
SemiEchelonBasis( <vector space over GF(3^2), with 2 generators>, 
[ LieObject( [ [ Z(3)^0, Z(3)^0 ], [ Z(3)^0, Z(3)^0 ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ] ) ] )
gap> IsSemiEchelonized( b );
true

#############################################################################
##
##  4. Methods for Lie matrix spaces
##
gap> [ [] ] in w;
false
gap> Zero( w ) in w;
true
gap> [ [ 0, 0 ], [ 0, 1 ] ] in w;
false
gap> Z(3) * [ [ 0, 0 ], [ 0, 1 ], [ 0, 0 ] ] in w;
false
gap> [ [ Z(27), Z(3) ], [ Z(3), Z(3) ] ] in w;
false
gap> LieObject( [ [ 0, 0 ], [ 0, 1 ] ] ) in w;
false
gap> LieObject( Z(3) * [ [ 0, 0 ], [ 0, 1 ], [ 0, 0 ] ] ) in w;
false
gap> LieObject( [ [ Z(27), Z(3) ], [ Z(3), Z(3) ] ] ) in w;
true
gap> [ [] ] in v;
false
gap> Zero( v ) in v;
true
gap> [ [ 0, 0 ], [ 0, 1 ] ] in v;
false
gap> Z(3) * [ [ 0, 0 ], [ 0, 1 ], [ 0, 0 ] ] in v;
false
gap> Z(3) * [ [ 0, 0 ], [ 0, 1 ] ] in v;
false
gap> LieObject( [ [ 0, 0 ], [ 0, 1 ] ] ) in v;
false
gap> LieObject( Z(3) * [ [ 0, 0 ], [ 0, 1 ], [ 0, 0 ] ] ) in v;
false
gap> LieObject( Z(3) * [ [ 0, 0 ], [ 0, 1 ] ] ) in v;
true
gap> BasisNC( v,
>     [ LieObject( [ [ Z(3)^0, Z(3)^0 ], [ Z(3)^0, Z(3)^0 ] ] ),
>       LieObject( [ [ 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ] ) ] );
SemiEchelonBasis( <vector space over GF(3^2), with 2 generators>, 
[ LieObject( [ [ Z(3)^0, Z(3)^0 ], [ Z(3)^0, Z(3)^0 ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ] ) ] )
gap> Basis( v );
SemiEchelonBasis( <vector space over GF(3^2), with 2 generators>, 
[ LieObject( [ [ Z(3)^0, Z(3)^0 ], [ Z(3)^0, Z(3)^0 ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ] ) ] )
gap> SemiEchelonBasis( v );
SemiEchelonBasis( <vector space over GF(3^2), with 2 generators>, 
[ LieObject( [ [ Z(3)^0, Z(3)^0 ], [ Z(3)^0, Z(3)^0 ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ] ) ] )
gap> b:= SemiEchelonBasis( v,
>         [ LieObject( [ [ Z(3), Z(3) ], [ Z(3), Z(3) ] ] ), 
>           LieObject( [ [ 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ] ) ] );
fail
gap> b:= SemiEchelonBasis( v,
>         [ LieObject( [ [ Z(3)^0, Z(3)^0 ], [ Z(3)^0, Z(3)^0 ] ] ), 
>           LieObject( [ [ 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ] ) ] );
SemiEchelonBasis( <vector space over GF(3^2), with 2 generators>, 
[ LieObject( [ [ Z(3)^0, Z(3)^0 ], [ Z(3)^0, Z(3)^0 ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ] ) ] )
gap> b:= SemiEchelonBasisNC( v,
>         [ LieObject( [ [ Z(3)^0, Z(3)^0 ], [ Z(3)^0, Z(3)^0 ] ] ), 
>           LieObject( [ [ 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ] ) ] );
SemiEchelonBasis( <vector space over GF(3^2), with 2 generators>, 
[ LieObject( [ [ Z(3)^0, Z(3)^0 ], [ Z(3)^0, Z(3)^0 ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ] ) ] )
gap> c1:= CanonicalBasis( v );;
gap> Print( c1, "\n" );
CanonicalBasis( VectorSpace( GF(3^2), 
[ LieObject( [ [ Z(3), Z(3) ], [ Z(3), Z(3) ] ] ), 
  LieObject( [ [ Z(3), Z(3) ], [ Z(3), 0*Z(3) ] ] ) ] ) )
gap> c2:= CanonicalBasis( VectorSpace( GF(3), BasisVectors( b ) ) );;
gap> Print( c2, "\n" );
CanonicalBasis( VectorSpace( GF(3), 
[ LieObject( [ [ Z(3)^0, Z(3)^0 ], [ Z(3)^0, Z(3)^0 ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ] ) ] ) )
gap> c1 = c2;
true
gap> w:= LeftModuleByGenerators( GF(9),
>         [ LieObject( [ [ Z(27), Z(3) ], [ Z(3), Z(3) ] ] ),
>           LieObject( [ [ Z(27), Z(3) ], [ Z(3), Z(3) ] ] ),
>           LieObject( [ [ 0*Z(3), Z(3) ], [ Z(3), Z(3) ] ] ) ] );
<vector space over GF(3^2), with 3 generators>
gap> Basis( w );
Basis( <vector space over GF(3^2), with 3 generators>, ... )
gap> b:= Basis( w,
>         [ LieObject( [ [ 0*Z(3), Z(3) ], [ Z(3), Z(3) ] ] ),
>           LieObject( [ [ Z(27), Z(3) ], [ Z(3), Z(3) ] ] ) ] );;
gap> Print( b, "\n" );
Basis( VectorSpace( GF(3^2), 
[ LieObject( [ [ Z(3^3), Z(3) ], [ Z(3), Z(3) ] ] ), 
  LieObject( [ [ Z(3^3), Z(3) ], [ Z(3), Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), Z(3) ], [ Z(3), Z(3) ] ] ) ] ), 
[ LieObject( [ [ 0*Z(3), Z(3) ], [ Z(3), Z(3) ] ] ), 
  LieObject( [ [ Z(3^3), Z(3) ], [ Z(3), Z(3) ] ] ) ] )
gap> IsBasisByNiceBasis( b );
true
gap> Coefficients( b, LieObject( [ [ Z(27), 0*Z(3) ], [ 0*Z(3), 0*Z(3) ] ] ) );
[ Z(3), Z(3)^0 ]
gap> IsZero( Zero( v ) );
true
gap> ForAny( b, IsZero );
false
gap> ww:= AsVectorSpace( GF(3), w );;
gap> Print( ww, "\n" );
VectorSpace( GF(3), [ LieObject( [ [ Z(3^3), Z(3) ], [ Z(3), Z(3) ] ] ), 
  LieObject( [ [ Z(3^3), Z(3) ], [ Z(3), Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), Z(3) ], [ Z(3), Z(3) ] ] ), 
  LieObject( [ [ Z(3^6)^119, Z(3^2)^5 ], [ Z(3^2)^5, Z(3^2)^5 ] ] ), 
  LieObject( [ [ Z(3^6)^119, Z(3^2)^5 ], [ Z(3^2)^5, Z(3^2)^5 ] ] ), 
  LieObject( [ [ 0*Z(3), Z(3^2)^5 ], [ Z(3^2)^5, Z(3^2)^5 ] ] ) ] )
gap> Dimension( ww );
4
gap> w = ww;
true
gap> AsVectorSpace( GF(27), w );
fail
gap> u:= GF( 3^6 )^[ 2, 3 ];
( GF(3^6)^[ 2, 3 ] )
gap> u:= LeftModuleByGenerators( GF(3^6),
>            List( GeneratorsOfLeftModule( u ), LieObject ) );;
gap> Print( u, "\n" );
VectorSpace( GF(3^6), 
[ LieObject( [ [ Z(3)^0, 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), Z(3)^0, 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), Z(3)^0 ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ Z(3)^0, 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0, 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] ) ] )
gap> IsFullMatrixModule( u );
true
gap> u;
<vector space of dimension 6 over GF(3^6)>
gap> uu:= AsVectorSpace( GF(9), u );;
gap> Print( uu, "\n" );
VectorSpace( GF(3^2), 
[ LieObject( [ [ Z(3)^0, 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), Z(3)^0, 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), Z(3)^0 ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ Z(3)^0, 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0, 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] ), 
  LieObject( [ [ Z(3^6), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), Z(3^6), 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), Z(3^6) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ Z(3^6), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3^6), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3^6) ] ] ), 
  LieObject( [ [ Z(3^6)^2, 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), Z(3^6)^2, 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), Z(3^6)^2 ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ Z(3^6)^2, 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3^6)^2, 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3^6)^2 ] ] ) 
 ] )
gap> uuu:= AsVectorSpace( GF(27), uu );;
gap> Print( uuu, "\n" );
VectorSpace( GF(3^3), 
[ LieObject( [ [ Z(3)^0, 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), Z(3)^0, 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), Z(3)^0 ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ Z(3)^0, 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0, 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] ), 
  LieObject( [ [ Z(3^6), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), Z(3^6), 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), Z(3^6) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ Z(3^6), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3^6), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3^6) ] ] ), 
  LieObject( [ [ Z(3^6)^2, 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), Z(3^6)^2, 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), Z(3^6)^2 ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ Z(3^6)^2, 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3^6)^2, 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3^6)^2 ] ] ), 
  LieObject( [ [ Z(3^2), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), Z(3^2), 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), Z(3^2) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ Z(3^2), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3^2), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3^2) ] ] ), 
  LieObject( [ [ Z(3^6)^92, 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), Z(3^6)^92, 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), Z(3^6)^92 ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ Z(3^6)^92, 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3^6)^92, 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3^6)^92 ] ] ), 
  LieObject( [ [ Z(3^6)^93, 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), Z(3^6)^93, 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), Z(3^6)^93 ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ Z(3^6)^93, 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3^6)^93, 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3^6)^93 ] ] ) 
 ] )
gap> uuuu:= AsVectorSpace( GF(3^6), uu );;
gap> Print( uuuu, "\n" );
VectorSpace( GF(3^6), 
[ LieObject( [ [ Z(3)^0, 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), Z(3)^0, 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), Z(3)^0 ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ Z(3)^0, 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0, 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] ), 
  LieObject( [ [ Z(3^6), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), Z(3^6), 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), Z(3^6) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ Z(3^6), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3^6), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3^6) ] ] ), 
  LieObject( [ [ Z(3^6)^2, 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), Z(3^6)^2, 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), Z(3^6)^2 ], [ 0*Z(3), 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ Z(3^6)^2, 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3^6)^2, 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3^6)^2 ] ] ) 
 ] )
gap> u = uuu;
true
gap> c:= VectorSpace( GF(9),
>          [ LieObject( [ [ Z(3)^0, 0*Z(3) ], [ 0*Z(3), 0*Z(3) ] ] ),
>            LieObject( [ [ 0*Z(3), Z(3)^0 ], [ 0*Z(3), 0*Z(3) ] ] ) ] );
<vector space over GF(3^2), with 2 generators>
gap> f:= v + c;;
gap> Print( f, "\n" );
VectorSpace( GF(3^2), [ LieObject( [ [ Z(3), Z(3) ], [ Z(3), Z(3) ] ] ), 
  LieObject( [ [ Z(3), Z(3) ], [ Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ Z(3)^0, 0*Z(3) ], [ 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), Z(3)^0 ], [ 0*Z(3), 0*Z(3) ] ] ) ] )
gap> Intersection( v, c );
<vector space of dimension 0 over GF(3^2)>
gap> Intersection( v, f ) = v;
true

#############################################################################
##
##  5. Methods for full matrix spaces
##
gap> IsFullMatrixModule( v );
false
gap> IsFullMatrixModule( f );
true
gap> c:= CanonicalBasis( f );
CanonicalBasis( <vector space of dimension 4 over GF(3^2)> )
gap> Print( BasisVectors( c ), "\n" );
[ LieObject( [ [ Z(3)^0, 0*Z(3) ], [ 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), Z(3)^0 ], [ 0*Z(3), 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3) ], [ Z(3)^0, 0*Z(3) ] ] ), 
  LieObject( [ [ 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ] ) ]

#############################################################################
##
##  7. Methods for mutable bases of Gaussian matrix spaces
##
gap> mb:= MutableBasis( Rationals,
>          [ LieObject( [ [ 1, 1 ], [ 1, 1 ] ] ),
>            LieObject( [ [ 0, 1 ], [ 1, 1 ] ] ),
>            LieObject( [ [ 1, 1 ], [ 1, 1 ] ] ) ] );
<mutable basis over Rationals, 2 vectors>
gap> IsMutableBasisOfGaussianMatrixSpaceRep( mb );
true
gap> CloseMutableBasis( mb, LieObject( [ [ E(4), 0 ], [ 0, 0 ] ] ) );
gap> IsMutableBasisOfGaussianMatrixSpaceRep( mb );
false
gap> Print( BasisVectors( mb ), "\n" );
[ LieObject( [ [ 1, 1 ], [ 1, 1 ] ] ), LieObject( [ [ 0, 1 ], [ 1, 1 ] ] ), 
  LieObject( [ [ E(4), 0 ], [ 0, 0 ] ] ) ]
gap> mb:= MutableBasis( Rationals,
>          [ LieObject( [ [ 1, 1 ], [ 1, 1 ] ] ),
>            LieObject( [ [ 0, 1 ], [ 1, 1 ] ] ),
>            LieObject( [ [ 1, 1 ], [ 1, 1 ] ] ) ] );
<mutable basis over Rationals, 2 vectors>
gap> CloseMutableBasis( mb, LieObject( [ [ 1, 2 ], [ 3, 4 ] ] ) );
gap> CloseMutableBasis( mb, LieObject( [ [ 1, 2 ], [ 3, 5 ] ] ) );
gap> CloseMutableBasis( mb, LieObject( [ [ 0, 0 ], [ 0, 7 ] ] ) );
gap> IsMutableBasisOfGaussianMatrixSpaceRep( mb );
true
gap> bv:= BasisVectors( mb );;
gap> Print( bv, "\n" );
[ LieObject( [ [ 1, 1 ], [ 1, 1 ] ] ), LieObject( [ [ 0, 1 ], [ 1, 1 ] ] ), 
  LieObject( [ [ 0, 0 ], [ 1, 2 ] ] ), LieObject( [ [ 0, 0 ], [ 0, 1 ] ] ) ]
gap> ImmutableBasis( mb );
SemiEchelonBasis( <vector space of dimension 4 over Rationals>, 
[ LieObject( [ [ 1, 1 ], [ 1, 1 ] ] ), LieObject( [ [ 0, 1 ], [ 1, 1 ] ] ), 
  LieObject( [ [ 0, 0 ], [ 1, 2 ] ] ), LieObject( [ [ 0, 0 ], [ 0, 1 ] ] ) ] )
gap> mb:= MutableBasis( Rationals, [],
>             LieObject( [ [ 0, 0 ], [ 0, 0 ] ] ) );
<mutable basis over Rationals, 0 vectors>
gap> CloseMutableBasis( mb, LieObject( [ [ 1, 2 ], [ 3, 4 ] ] ) );
gap> CloseMutableBasis( mb, LieObject( [ [ 1, 2 ], [ 3, 5 ] ] ) );
gap> CloseMutableBasis( mb, LieObject( [ [ 0, 0 ], [ 0, 7 ] ] ) );
gap> IsMutableBasisOfGaussianMatrixSpaceRep( mb );
true
gap> BasisVectors( mb );
[ LieObject( [ [ 1, 2 ], [ 3, 4 ] ] ), LieObject( [ [ 0, 0 ], [ 0, 1 ] ] ) ]
gap> ImmutableBasis( mb );
SemiEchelonBasis( <vector space of dimension 2 over Rationals>, 
[ LieObject( [ [ 1, 2 ], [ 3, 4 ] ] ), LieObject( [ [ 0, 0 ], [ 0, 1 ] ] ) ] )
gap> STOP_TEST( "vspcmali.tst", 1);

#############################################################################
##
#E
