#############################################################################
##
#W  vspcrow.tst                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  (The test file 'vspcmat.tst' should contain the same tests.)
##

#############################################################################
##
##  1. Construct Gaussian and non-Gaussian row spaces
##
gap> z:= LeftModuleByGenerators( GF(3), [], [ 0*Z(9) ] );
VectorSpace( GF(3), [  ], [ 0*Z(3) ] )
gap> IsGaussianRowSpaceRep( z );
true
gap> IsNonGaussianRowSpaceRep( z );
false

gap> v:= LeftModuleByGenerators( GF(9), [ [ Z(3), Z(3), Z(3) ] ] );
VectorSpace( GF(3^2), [ [ Z(3), Z(3), Z(3) ] ] )
gap> IsGaussianRowSpaceRep( v );
true
gap> IsNonGaussianRowSpaceRep( v );
false
gap> v = LeftModuleByGenerators( GF(9), [ [ Z(3), Z(3), Z(3) ] ], Zero( v ) );
true

gap> w:= LeftModuleByGenerators( GF(9), [ [ Z(27), Z(3), Z(3) ] ] );
VectorSpace( GF(3^2), [ [ Z(3^3), Z(3), Z(3) ] ] )
gap> IsGaussianRowSpaceRep( w );
false
gap> IsNonGaussianRowSpaceRep( w );
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
[ 0*Z(3), Z(3)^0, 0*Z(3), Z(3), 0*Z(3), 0*Z(3), Z(3), 0*Z(3), 0*Z(3) ]
gap> UglyVector( w, n ) = [ Z(27), Z(3), Z(3) ];
true

#############################################################################
##
##  3. Methods for semi-echelonized bases of Gaussian row spaces
##
gap> v:= LeftModuleByGenerators( GF(9),
>     [ [ Z(3), Z(3), Z(3) ], [ Z(3), Z(3), 0*Z(3) ] ] );
VectorSpace( GF(3^2), [ [ Z(3), Z(3), Z(3) ], [ Z(3), Z(3), 0*Z(3) ] ] )
gap> b:= SemiEchelonBasis( v );
SemiEchelonBasis( VectorSpace( GF(3^2), 
[ [ Z(3), Z(3), Z(3) ], [ Z(3), Z(3), 0*Z(3) ] ] ), ... )
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
Basis( VectorSpace( GF(3^2), [ [ Z(3), Z(3), Z(3) ], [ Z(3), Z(3), 0*Z(3) ] 
 ] ), [ [ Z(3), Z(3), Z(3) ], [ Z(3), Z(3), 0*Z(3) ] ] )
gap> IsSemiEchelonized( b );
false
gap> b:= Basis( v, [ [ Z(3), Z(3), Z(3) ], [ 0*Z(3), 0*Z(3), Z(3) ] ] );
Basis( VectorSpace( GF(3^2), [ [ Z(3), Z(3), Z(3) ], [ Z(3), Z(3), 0*Z(3) ] 
 ] ), [ [ Z(3), Z(3), Z(3) ], [ 0*Z(3), 0*Z(3), Z(3) ] ] )
gap> IsSemiEchelonized( b );
false
gap> b:= Basis( v, [ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ Z(3)^0, Z(3)^0, 0*Z(3) ] ] );
Basis( VectorSpace( GF(3^2), [ [ Z(3), Z(3), Z(3) ], [ Z(3), Z(3), 0*Z(3) ] 
 ] ), [ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ Z(3)^0, Z(3)^0, 0*Z(3) ] ] )
gap> IsSemiEchelonized( b );
false
gap> b:= Basis( v, [ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] );
SemiEchelonBasis( VectorSpace( GF(3^2), 
[ [ Z(3), Z(3), Z(3) ], [ Z(3), Z(3), 0*Z(3) ] ] ), 
[ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] )
gap> IsSemiEchelonized( b );
true

#############################################################################
##
##  4. Methods for row spaces
##
gap> m:= Z(3)^0 * [ [ 1, 1 ], [ 1, 0 ], [ 0, 0 ] ];
[ [ Z(3)^0, Z(3)^0 ], [ Z(3)^0, 0*Z(3) ], [ 0*Z(3), 0*Z(3) ] ]
gap> im:= v * m;
VectorSpace( GF(3^2), [ [ Z(3)^0, Z(3) ], [ Z(3)^0, Z(3) ] ] )
gap> Dimension( im );
1
gap> im = v^m;
true
gap> w * m;
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

gap> BasisByGeneratorsNC( v,
>     [ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] );
SemiEchelonBasis( VectorSpace( GF(3^2), 
[ [ Z(3), Z(3), Z(3) ], [ Z(3), Z(3), 0*Z(3) ] ] ), 
[ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] )
gap> BasisOfDomain( v );
SemiEchelonBasis( VectorSpace( GF(3^2), 
[ [ Z(3), Z(3), Z(3) ], [ Z(3), Z(3), 0*Z(3) ] ] ), 
[ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] )
gap> SemiEchelonBasisOfDomain( v );
SemiEchelonBasis( VectorSpace( GF(3^2), 
[ [ Z(3), Z(3), Z(3) ], [ Z(3), Z(3), 0*Z(3) ] ] ), 
[ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] )
gap> b:= SemiEchelonBasis( v,
>         [ [ Z(3), Z(3), Z(3) ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] );
fail
gap> b:= SemiEchelonBasis( v,
>         [ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] );
SemiEchelonBasis( VectorSpace( GF(3^2), 
[ [ Z(3), Z(3), Z(3) ], [ Z(3), Z(3), 0*Z(3) ] ] ), 
[ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] )
gap> b:= SemiEchelonBasisByGeneratorsNC( v,
>         [ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] );
SemiEchelonBasis( VectorSpace( GF(3^2), 
[ [ Z(3), Z(3), Z(3) ], [ Z(3), Z(3), 0*Z(3) ] ] ), 
[ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] )
gap> c1:= CanonicalBasis( v );
CanonicalBasis( VectorSpace( GF(3^2), 
[ [ Z(3), Z(3), Z(3) ], [ Z(3), Z(3), 0*Z(3) ] ] ) )
gap> c2:= CanonicalBasis( VectorSpace( GF(3), BasisVectors( b ) ) );
CanonicalBasis( VectorSpace( GF(3), 
[ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] ) )
gap> c1 = c2;
true

gap> w:= LeftModuleByGenerators( GF(9),
>         [ [ Z(27), Z(3), Z(3) ],
>           [ Z(27), Z(3), Z(3) ],
>           [ 0*Z(3), Z(3), Z(3) ] ] );
VectorSpace( GF(3^2), [ [ Z(3^3), Z(3), Z(3) ], [ Z(3^3), Z(3), Z(3) ], 
  [ 0*Z(3), Z(3), Z(3) ] ] )
gap> BasisOfDomain( w );
Basis( VectorSpace( GF(3^2), [ [ Z(3^3), Z(3), Z(3) ], [ Z(3^3), Z(3), Z(3) ],
  [ 0*Z(3), Z(3), Z(3) ] ] ), ... )
gap> b:= BasisByGenerators( w,
>         [ [ 0*Z(3), Z(3), Z(3) ], [ Z(27), Z(3), Z(3) ] ] );
Basis( VectorSpace( GF(3^2), [ [ Z(3^3), Z(3), Z(3) ], [ Z(3^3), Z(3), Z(3) ],
  [ 0*Z(3), Z(3), Z(3) ] ] ), 
[ [ 0*Z(3), Z(3), Z(3) ], [ Z(3^3), Z(3), Z(3) ] ] )
gap> IsBasisByNiceBasis( b );
true
gap> Coefficients( b, [ Z(27), 0*Z(3), 0*Z(3) ] );
[ Z(3), Z(3)^0 ]

gap> IsZero( Zero( v ) );
true
gap> ForAny( b, IsZero );
false

gap> ww:= AsVectorSpace( GF(3), w );
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
gap> uu:= AsVectorSpace( GF(9), u );
VectorSpace( GF(3^2), [ [ Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3) ], 
  [ 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ], [ Z(3^6), 0*Z(3), 0*Z(3), 0*Z(3) ], 
  [ 0*Z(3), Z(3^6), 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3^6), 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3^6) ], [ Z(3^6)^2, 0*Z(3), 0*Z(3), 0*Z(3) ], 
  [ 0*Z(3), Z(3^6)^2, 0*Z(3), 0*Z(3) ], [ 0*Z(3), 0*Z(3), Z(3^6)^2, 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3^6)^2 ] ] )
gap> uuu:= AsVectorSpace( GF(27), uu );
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
gap> uuuu:= AsVectorSpace( GF(3^6), uu );
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
VectorSpace( GF(3^2), [ [ Z(3)^0, 0*Z(3), 0*Z(3) ] ] )
gap> f:= v + c;
VectorSpace( GF(3^2), 
[ [ Z(3)^0, Z(3)^0, Z(3)^0 ], [ 0*Z(3), Z(3)^0, 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), Z(3)^0 ] ] )
gap> Intersection( v, c );
Subspace( VectorSpace( GF(3^2), 
[ [ Z(3), Z(3), Z(3) ], [ Z(3), Z(3), 0*Z(3) ] ] ), [  ] )
gap> Intersection( v, f ) = v;
true

gap> nv:= NormedVectors( v );;
gap> nv{ [ 1 .. 5 ] };
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
gap> subsp:= SubspacesDim( f, 2 );
Subspaces( ( GF(3^2)^3 ), 2 )
gap> Size( subsp );
91
gap> iter:= Iterator( subsp );;
gap> for i in [ 1 .. 6 ] do
>      NextIterator( iter );
>    od;
gap> IsDoneIterator( iter );
false
gap> NextIterator( iter );
Subspace( ( GF(3^2)^3 ), 
[ [ Z(3)^0, 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0, Z(3^2)^5 ] ] )

gap> subsp:= SubspacesAll( f );
Subspaces( ( GF(3^2)^3 ), "all" )
gap> Size( subsp );
184
gap> iter:= Iterator( subsp );;
gap> for i in [ 1 .. 6 ] do
>      NextIterator( iter );
>    od;
gap> IsDoneIterator( iter );
false
gap> NextIterator( iter );
Subspace( ( GF(3^2)^3 ), [ [ Z(3)^0, 0*Z(3), Z(3^2)^3 ] ] )

#############################################################################
##
##  7. Methods for mutable bases of Gaussian row spaces
##
gap> mb:= MutableBasisByGenerators( Rationals,
>          [ [ 1, 1, 1, 1 ], [ 0, 1, 1, 1 ], [ 1, 1, 1, 1 ] ] );
<mutable basis over Rationals, 2 vectors>
gap> IsMutableBasisOfGaussianRowSpaceRep( mb );
true
gap> CloseMutableBasis( mb, [ E(4), 0, 0, 0 ] );
gap> IsMutableBasisOfGaussianRowSpaceRep( mb );
false
gap> BasisVectors( mb );
[ [ 1, 1, 1, 1 ], [ 0, 1, 1, 1 ], [ E(4), 0, 0, 0 ] ]

gap> mb:= MutableBasisByGenerators( Rationals,
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
SemiEchelonBasis( VectorSpace( Rationals, [ [ 1, 1, 1, 1 ], [ 0, 1, 1, 1 ], 
  [ 0, 0, 1, 2 ], [ 0, 0, 0, 1 ] ] ), [ [ 1, 1, 1, 1 ], [ 0, 1, 1, 1 ], 
  [ 0, 0, 1, 2 ], [ 0, 0, 0, 1 ] ] )

gap> mb:= MutableBasisByGenerators( Rationals, [], [ 0, 0, 0, 0 ] );
<mutable basis over Rationals, 0 vectors>
gap> CloseMutableBasis( mb, [ 1, 2, 3, 4 ] );
gap> CloseMutableBasis( mb, [ 1, 2, 3, 5 ] );
gap> CloseMutableBasis( mb, [ 0, 0, 0, 7 ] );
gap> IsMutableBasisOfGaussianRowSpaceRep( mb );
true
gap> BasisVectors( mb );
[ [ 1, 2, 3, 4 ], [ 0, 0, 0, 1 ] ]
gap> ImmutableBasis( mb );
SemiEchelonBasis( VectorSpace( Rationals, [ [ 1, 2, 3, 4 ], [ 0, 0, 0, 1 ] 
 ] ), [ [ 1, 2, 3, 4 ], [ 0, 0, 0, 1 ] ] )

