#############################################################################
##
#W  vspcrow.tst                 GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  (The test file `vspcmat.tst' should contain the same tests,
##  applied to matrix spaces.)
##
##  To be listed in testinstall.g
##
gap> START_TEST("vspcrow.tst");

#############################################################################
##
##  1. Construct Gaussian and non-Gaussian row spaces
##
gap> z:= LeftModuleByGenerators( GF(3), [], [ 0*Z(9) ] );
<vector space over GF(3), with 0 generators>
gap> IsGaussianRowSpace( z );
true
gap> IsNonGaussianRowSpace( z );
false
gap> v:= LeftModuleByGenerators( GF(9), [ [ Z(3), Z(3), Z(3) ] ] );
<vector space over GF(3^2), with 1 generators>
gap> IsGaussianRowSpace( v );
true
gap> IsNonGaussianRowSpace( v );
false
gap> v = LeftModuleByGenerators( GF(9), [ [ Z(3), Z(3), Z(3) ] ], Zero( v ) );
true
gap> w:= LeftModuleByGenerators( GF(9), [ [ Z(27), Z(3), Z(3) ] ] );
<vector space over GF(3^2), with 1 generators>
gap> IsGaussianRowSpace( w );
false
gap> IsNonGaussianRowSpace( w );
true
gap> w = LeftModuleByGenerators( GF(9), [ [ Z(27), Z(3), Z(3) ] ], Zero( w ) );
true

#############################################################################
##
##  2. Methods for bases of non-Gaussian row spaces
##
gap> Dimension( w );
1
gap> n:= NiceVector( w, [ Z(27), Z(3), Z(3) ] );
[ Z(3), Z(3), Z(3^2)^3, Z(3), 0*Z(3), 0*Z(3), Z(3), 0*Z(3), 0*Z(3) ]
gap> UglyVector( w, n ) = [ Z(27), Z(3), Z(3) ];
true

#############################################################################
##
##  3. Methods for semi-echelonized bases of Gaussian row spaces
##
gap> v:= LeftModuleByGenerators( GF(9),
>     [ [ Z(3), Z(3), Z(3) ], [ Z(3), Z(3), 0*Z(3) ] ] );
<vector space over GF(3^2), with 2 generators>
gap> b:= SemiEchelonBasis( v );
SemiEchelonBasis( <vector space over GF(3^2), with 2 generators>, ... )
gap> lc:= LinearCombination( b, [ Z(3)^0, Z(3) ] );
[ Z(3)^0, Z(3)^0, 0*Z(3) ]
gap> Coefficients( b, lc );
[ Z(3)^0, Z(3) ]
gap> SiftedVector( b, [ Z(3), 0*Z(3), 0*Z(3) ] );
[ 0*Z(3), Z(3)^0, 0*Z(3) ]
gap> SiftedVector( b, [ 0*Z(3), 0*Z(3), Z(3) ] );
[ 0*Z(3), 0*Z(3), 0*Z(3) ]
gap> b:= Basis( v, [ [ Z(3), Z(3), Z(3) ] ] );
fail
gap> b:= Basis( v, [ [ Z(3), Z(3), Z(3) ], [ Z(3), Z(3), 0*Z(3) ] ] );
Basis( <vector space over GF(3^2), with 2 generators>, 
[ [ Z(3), Z(3), Z(3) ], [ Z(3), Z(3), 0*Z(3) ] ] )
gap> IsSemiEchelonized( b );
false
gap> b:= Basis( v, [ [ Z(3), Z(3), Z(3) ], [ 0*Z(3), 0*Z(3), Z(3) ] ] );
Basis( <vector space over GF(3^2), with 2 generators>, 
[ [ Z(3), Z(3), Z(3) ], [ 0*Z(3), 0*Z(3), Z(3) ] ] )
gap> IsSemiEchelonized( b );
false
gap> b:= Basis( v, [ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ Z(3)^0, Z(3)^0, 0*Z(3) ] ] );
Basis( <vector space over GF(3^2), with 2 generators>, 
[ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ Z(3)^0, Z(3)^0, 0*Z(3) ] ] )
gap> IsSemiEchelonized( b );
false
gap> b:= Basis( v, [ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] );
SemiEchelonBasis( <vector space over GF(3^2), with 2 generators>, 
[ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] )
gap> IsSemiEchelonized( b );
true

#############################################################################
##
##  4. Methods for row spaces
##
gap> m:= Z(3)^0 * [ [ 1, 1 ], [ 1, 0 ], [ 0, 0 ] ];
[ [ Z(3)^0, Z(3)^0 ], [ Z(3)^0, 0*Z(3) ], [ 0*Z(3), 0*Z(3) ] ]
gap> im:= v * m;;
gap> Print( im, "\n" );
VectorSpace( GF(3^2), [ [ Z(3)^0, Z(3) ], [ Z(3)^0, Z(3) ] ] )
gap> Dimension( im );
1
gap> im = v^m;
true
gap> im:= w * m;;
gap> Print( im, "\n" );
VectorSpace( GF(3^2), [ [ Z(3^3)^3, Z(3^3) ] ] )
gap> [] in w;
false
gap> Zero( w ) in w;
true
gap> [ 0, 0, 1 ] in w;
false
gap> Z(3) * [ 0, 1 ] in v;
false
gap> [ Z(27), Z(3), Z(3) ] in w;
true
gap> [] in v;
false
gap> Zero( v ) in v;
true
gap> [ 0, 0, 1 ] in v;
false
gap> Z(3) * [ 0, 1 ] in v;
false
gap> Z(3) * [ 0, 0, 1 ] in v;
true
gap> BasisNC( v,
>     [ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] );
SemiEchelonBasis( <vector space over GF(3^2), with 2 generators>, 
[ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] )
gap> Basis( v );
SemiEchelonBasis( <vector space over GF(3^2), with 2 generators>, 
[ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] )
gap> SemiEchelonBasis( v );
SemiEchelonBasis( <vector space over GF(3^2), with 2 generators>, 
[ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] )
gap> b:= SemiEchelonBasis( v,
>         [ [ Z(3), Z(3), Z(3) ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] );
fail
gap> b:= SemiEchelonBasis( v,
>         [ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] );
SemiEchelonBasis( <vector space over GF(3^2), with 2 generators>, 
[ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] )
gap> b:= SemiEchelonBasisNC( v,
>         [ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] );
SemiEchelonBasis( <vector space over GF(3^2), with 2 generators>, 
[ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] )
gap> c1:= CanonicalBasis( v );;
gap> Print( c1, "\n" );
CanonicalBasis( VectorSpace( GF(3^2), 
[ [ Z(3), Z(3), Z(3) ], [ Z(3), Z(3), 0*Z(3) ] ] ) )
gap> c2:= CanonicalBasis( VectorSpace( GF(3), BasisVectors( b ) ) );;
gap> Print( c2, "\n" );
CanonicalBasis( VectorSpace( GF(3), 
[ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] ) )
gap> c1 = c2;
true
gap> w:= LeftModuleByGenerators( GF(9),
>         [ [ Z(27), Z(3), Z(3) ],
>           [ Z(27), Z(3), Z(3) ],
>           [ 0*Z(3), Z(3), Z(3) ] ] );
<vector space over GF(3^2), with 3 generators>
gap> Basis( w );
Basis( <vector space over GF(3^2), with 3 generators>, ... )
gap> b:= Basis( w,
>         [ [ 0*Z(3), Z(3), Z(3) ], [ Z(27), Z(3), Z(3) ] ] );
Basis( <vector space of dimension 2 over GF(3^2)>, 
[ [ 0*Z(3), Z(3), Z(3) ], [ Z(3^3), Z(3), Z(3) ] ] )
gap> IsBasisByNiceBasis( b );
true
gap> Coefficients( b, [ Z(27), 0*Z(3), 0*Z(3) ] );
[ Z(3), Z(3)^0 ]
gap> IsZero( Zero( v ) );
true
gap> ForAny( b, IsZero );
false
gap> ww:= AsVectorSpace( GF(3), w );;
gap> Print( ww, "\n" );
VectorSpace( GF(3), [ [ Z(3^3), Z(3), Z(3) ], [ Z(3^3), Z(3), Z(3) ], 
  [ 0*Z(3), Z(3), Z(3) ], [ Z(3^6)^119, Z(3^2)^5, Z(3^2)^5 ], 
  [ Z(3^6)^119, Z(3^2)^5, Z(3^2)^5 ], [ 0*Z(3), Z(3^2)^5, Z(3^2)^5 ] ] )
gap> Dimension( ww );
4
gap> w = ww;
true
gap> AsVectorSpace( GF(27), w );
fail
gap> u:= GF( 3^6 )^4;
( GF(3^6)^4 )
gap> uu:= AsVectorSpace( GF(9), u );;
gap> Print( uu, "\n" );
VectorSpace( GF(3^2), [ [ Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3) ], 
  [ 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ], [ Z(3^6), 0*Z(3), 0*Z(3), 0*Z(3) ], 
  [ 0*Z(3), Z(3^6), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3^6), 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3^6) ], [ Z(3^6)^2, 0*Z(3), 0*Z(3), 0*Z(3) ], 
  [ 0*Z(3), Z(3^6)^2, 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3^6)^2, 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3^6)^2 ] ] )
gap> uuu:= AsVectorSpace( GF(27), uu );;
gap> Print( uuu, "\n" );
VectorSpace( GF(3^3), [ [ Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3) ], 
  [ 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ], [ Z(3^6), 0*Z(3), 0*Z(3), 0*Z(3) ], 
  [ 0*Z(3), Z(3^6), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3^6), 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3^6) ], [ Z(3^6)^2, 0*Z(3), 0*Z(3), 0*Z(3) ], 
  [ 0*Z(3), Z(3^6)^2, 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3^6)^2, 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3^6)^2 ], [ Z(3^2), 0*Z(3), 0*Z(3), 0*Z(3) ], 
  [ 0*Z(3), Z(3^2), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3^2), 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3^2) ], [ Z(3^6)^92, 0*Z(3), 0*Z(3), 0*Z(3) ], 
  [ 0*Z(3), Z(3^6)^92, 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3^6)^92, 0*Z(3) ]
    , [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3^6)^92 ], 
  [ Z(3^6)^93, 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3^6)^93, 0*Z(3), 0*Z(3) ]
    , [ 0*Z(3), 0*Z(3), Z(3^6)^93, 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3^6)^93 ] ] )
gap> uuuu:= AsVectorSpace( GF(3^6), uu );;
gap> Print( uuuu, "\n" );
VectorSpace( GF(3^6), [ [ Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3) ], 
  [ 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ], [ Z(3^6), 0*Z(3), 0*Z(3), 0*Z(3) ], 
  [ 0*Z(3), Z(3^6), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3^6), 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3^6) ], [ Z(3^6)^2, 0*Z(3), 0*Z(3), 0*Z(3) ], 
  [ 0*Z(3), Z(3^6)^2, 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3^6)^2, 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3^6)^2 ] ] )
gap> u = uuu;
true
gap> c:= VectorSpace( GF(9), [ [ Z(3)^0, 0*Z(3), 0*Z(3) ] ] );
<vector space over GF(3^2), with 1 generators>
gap> f:= v + c;;
gap> Print( f, "\n" );
VectorSpace( GF(3^2), 
[ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), Z(3)^0, 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] )
gap> Intersection( v, c );
<vector space over GF(3^2), with 0 generators>
gap> Intersection( v, f ) = v;
true
gap> nv:= NormedRowVectors( v );;
gap> Print( nv{ [ 1 .. 5 ] }, "\n" );
[ [ 0*Z(3), 0*Z(3), Z(3)^0 ], [ Z(3)^0, Z(3)^0, 0*Z(3) ], 
  [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ Z(3)^0, Z(3)^0, Z(3) ], 
  [ Z(3)^0, Z(3)^0, Z(3^2) ] ]

#############################################################################
##
##  5. Methods for full row spaces
##
gap> IsFullRowModule( v );
false
gap> IsFullRowModule( f );
true
gap> c:= CanonicalBasis( f );
CanonicalBasis( ( GF(3^2)^3 ) )
gap> BasisVectors( c ) = IdentityMat( Length( c ), GF(3) );
true

#############################################################################
##
##  6. Methods for collections of subspaces of full row spaces
##
gap> subsp:= Subspaces( f, 2 );
Subspaces( ( GF(3^2)^3 ), 2 )
gap> Size( subsp );
91
gap> iter:= Iterator( subsp );;
gap> for i in [ 1 .. 6 ] do
>      NextIterator( iter );
>    od;
gap> IsDoneIterator( iter );
false
gap> Print( NextIterator( iter ), "\n" );
VectorSpace( GF(3^2), 
[ [ Z(3)^0, 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0, Z(3^2)^5 ] ] )
gap> subsp:= Subspaces( f );
Subspaces( ( GF(3^2)^3 ) )
gap> Size( subsp );
184
gap> iter:= Iterator( subsp );;
gap> for i in [ 1 .. 6 ] do
>      NextIterator( iter );
>    od;
gap> IsDoneIterator( iter );
false
gap> Print( NextIterator( iter ), "\n" );
VectorSpace( GF(3^2), [ [ Z(3)^0, 0*Z(3), Z(3^2)^3 ] ] )

#############################################################################
##
##  7. Methods for mutable bases of Gaussian row spaces
##
gap> mb:= MutableBasis( Rationals,
>          [ [ 1, 1, 1, 1 ], [ 0, 1, 1, 1 ], [ 1, 1, 1, 1 ] ] );
<mutable basis over Rationals, 2 vectors>
gap> IsMutableBasisOfGaussianRowSpaceRep( mb );
true
gap> CloseMutableBasis( mb, [ E(4), 0, 0, 0 ] );
gap> IsMutableBasisOfGaussianRowSpaceRep( mb );
false
gap> BasisVectors( mb );
[ [ 1, 1, 1, 1 ], [ 0, 1, 1, 1 ], [ E(4), 0, 0, 0 ] ]
gap> mb:= MutableBasis( Rationals,
>          [ [ 1, 1, 1, 1 ], [ 0, 1, 1, 1 ], [ 1, 1, 1, 1 ] ] );
<mutable basis over Rationals, 2 vectors>
gap> CloseMutableBasis( mb, [ 1, 2, 3, 4 ] );
gap> CloseMutableBasis( mb, [ 1, 2, 3, 5 ] );
gap> CloseMutableBasis( mb, [ 0, 0, 0, 7 ] );
gap> IsMutableBasisOfGaussianRowSpaceRep( mb );
true
gap> BasisVectors( mb );
[ [ 1, 1, 1, 1 ], [ 0, 1, 1, 1 ], [ 0, 0, 1, 2 ], [ 0, 0, 0, 1 ] ]
gap> ImmutableBasis( mb );
SemiEchelonBasis( <vector space of dimension 4 over Rationals>, 
[ [ 1, 1, 1, 1 ], [ 0, 1, 1, 1 ], [ 0, 0, 1, 2 ], [ 0, 0, 0, 1 ] ] )
gap> mb:= MutableBasis( Rationals, [], [ 0, 0, 0, 0 ] );
<mutable basis over Rationals, 0 vectors>
gap> CloseMutableBasis( mb, [ 1, 2, 3, 4 ] );
gap> CloseMutableBasis( mb, [ 1, 2, 3, 5 ] );
gap> CloseMutableBasis( mb, [ 0, 0, 0, 7 ] );
gap> IsMutableBasisOfGaussianRowSpaceRep( mb );
true
gap> BasisVectors( mb );
[ [ 1, 2, 3, 4 ], [ 0, 0, 0, 1 ] ]
gap> ImmutableBasis( mb );
SemiEchelonBasis( <vector space of dimension 2 over Rationals>, 
[ [ 1, 2, 3, 4 ], [ 0, 0, 0, 1 ] ] )

#############################################################################
##
##  8. Enumerations
##
gap> erg:= [];;  i:= 0;;
gap> dims:= [ 1,4,27,28,29,31,32,33,63,64,65,92,127,128,129,384 ];;
gap> p := fail;; for p in [ 2,3,7,19,53,101 ] do
>      for i in dims do
>        v:= BasisVectors( CanonicalBasis( GF(p)^i ) );
>        l:= List( v, x -> NumberFFVector( x, p ) );
>        AddSet( erg, l = List( [ 1 .. i ], j -> p^(i-j) ) );
>      od;
>    od;
gap> erg;
[ true ]

#############################################################################
##
##  9. Arithmetic
##
gap> A := [ [ Z(2^2)^2, 0*Z(2), Z(2^2), 0*Z(2), 0*Z(2), 0*Z(2) ], 
>   [ Z(2^2)^2, 0*Z(2), Z(2^2)^2, Z(2)^0, Z(2^2)^2, Z(2)^0 ], 
>   [ 0*Z(2), Z(2)^0, 0*Z(2), Z(2^2)^2, 0*Z(2), Z(2^2)^2 ], 
>   [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2), Z(2^2)^2, 0*Z(2) ], 
>   [ Z(2^2)^2, Z(2^2)^2, Z(2^2)^2, 0*Z(2), 0*Z(2), 0*Z(2) ], 
>   [ Z(2)^0, Z(2)^0, 0*Z(2), Z(2^2), 0*Z(2), Z(2^2)^2 ] ];;
gap> F := GF(4);;
gap> MinimalPolynomial(F, A);
x_1^6+Z(2^2)*x_1^5+x_1^4+Z(2^2)^2*x_1^3+x_1^2+Z(2^2)*x_1+Z(2)^0
gap> MinimalPolynomial(F, A);
x_1^6+Z(2^2)*x_1^5+x_1^4+Z(2^2)^2*x_1^3+x_1^2+Z(2^2)*x_1+Z(2)^0
gap> STOP_TEST( "vspcrow.tst", 1800000);

#############################################################################
##
#E
