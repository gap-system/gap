#############################################################################
##
#W  vspchom.tst                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

gap> START_TEST("$Id$");


#############################################################################
##
##  tests for linear mappings given by images
##

gap> f:= GF(3);
GF(3)
gap> v:= GF(27);
GF(3^3)
gap> w:= f^2;
( GF(3)^2 )

gap> map1:= LeftModuleGeneralMappingByImages( f, v, [ Z(3)^0 ], [ Z(27) ] );
[ Z(3)^0 ] -> [ Z(3^3) ]
gap> ImagesSource( map1 );
VectorSpace( GF(3), [ Z(3^3) ] )
gap> PreImagesRange( map1 );
VectorSpace( GF(3), [ Z(3)^0 ] )
gap> CoKernelOfAdditiveGeneralMapping( map1 );
VectorSpace( GF(3), [  ] )
gap> KernelOfAdditiveGeneralMapping( map1 );
VectorSpace( GF(3), [  ] )
gap> IsSingleValued( map1 );
true
gap> IsInjective( map1 );
true
gap> ImagesRepresentative( map1, 0*Z(3)^0 );
0*Z(3)
gap> ImagesRepresentative( map1, Z(3)^0 );
Z(3^3)
gap> PreImagesRepresentative( map1, 0*Z(3) );
0*Z(3)
gap> PreImagesRepresentative( map1, Z(27) );
Z(3)^0
gap> 2 * map1 = - map1;
true
gap> Z(3) * map1 = - map1;
true

gap> map2:= LeftModuleGeneralMappingByImages( v, w,
>       CanonicalBasis( v ),
>       [ [ Z(3)^0, 0*Z(3)^0 ], [ Z(3)^0, Z(3)^0 ], [ 0*Z(3)^0, Z(3)^0 ] ] );
CanonicalBasis( GF(3^3) ) -> [ [ Z(3)^0, 0*Z(3) ], [ Z(3)^0, Z(3)^0 ], 
  [ 0*Z(3), Z(3)^0 ] ]
gap> ImagesSource( map2 );
VectorSpace( GF(3), [ [ Z(3)^0, 0*Z(3) ], [ Z(3)^0, Z(3)^0 ], 
  [ 0*Z(3), Z(3)^0 ] ] )
gap> PreImagesRange( map2 );
GF(3^3)
gap> CoKernelOfAdditiveGeneralMapping( map2 );
VectorSpace( GF(3), [  ] )
gap> KernelOfAdditiveGeneralMapping( map2 );
VectorSpace( GF(3), [ Z(3^3)^18 ] )
gap> IsSingleValued( map2 );
true
gap> IsInjective( map2 );
false
gap> ImagesRepresentative( map2, Z(27) );
[ Z(3)^0, Z(3)^0 ]
gap> ImagesRepresentative( map2, Z(9) );
fail
gap> PreImagesRepresentative( map2, [ Z(3)^0, Z(3)^0 ] );
Z(3^3)
gap> PreImagesRepresentative( map2, [ 0*Z(3)^0, 0*Z(3)^0 ] );
0*Z(3)
gap> 2 * map2 = - map2;
true
gap> Z(3) * map2 = - map2;
true

gap> map3:= LeftModuleGeneralMappingByImages( w, v,
>        [ [ Z(3)^0, 0*Z(3)^0 ], [ Z(3)^0, Z(3)^0 ], [ 0*Z(3)^0, Z(3)^0 ] ],
>        CanonicalBasis( v ) );
[ [ Z(3)^0, 0*Z(3) ], [ Z(3)^0, Z(3)^0 ], [ 0*Z(3), Z(3)^0 ] 
 ] -> CanonicalBasis( GF(3^3) )
gap> ImagesSource( map3 );
GF(3^3)
gap> PreImagesRange( map3 );
VectorSpace( GF(3), [ [ Z(3)^0, 0*Z(3) ], [ Z(3)^0, Z(3)^0 ], 
  [ 0*Z(3), Z(3)^0 ] ] )
gap> CoKernelOfAdditiveGeneralMapping( map3 );
VectorSpace( GF(3), [ Z(3^3)^18 ] )
gap> KernelOfAdditiveGeneralMapping( map3 );
VectorSpace( GF(3), [  ] )
gap> IsSingleValued( map3 );
false
gap> IsInjective( map3 );
true
gap> ImagesRepresentative( map3, [ Z(3)^0, 0*Z(3)^0 ] );
Z(3)^0
gap> ImagesRepresentative( map3, [ 0*Z(3)^0, Z(3)^0 ] );
Z(3^3)^3
gap> PreImagesRepresentative( map3, Z(27) );
[ Z(3)^0, Z(3)^0 ]
gap> PreImagesRepresentative( map3, Z(3)^0 );
[ Z(3)^0, 0*Z(3) ]
gap> 2 * map3 = - map3;
true
gap> Z(3) * map3 = - map3;
true

gap> comp1:= CompositionMapping( map3, map2 );
CompositionMapping( CanonicalBasis( GF(3^3) ) -> 
[ [ Z(3)^0, 0*Z(3) ], [ Z(3)^0, Z(3)^0 ], [ 0*Z(3), Z(3)^0 ] ], 
[ [ Z(3)^0, 0*Z(3) ], [ Z(3)^0, Z(3)^0 ], [ 0*Z(3), Z(3)^0 ] 
 ] -> CanonicalBasis( GF(3^3) ) )
gap> IsInjective( comp1 );
false
gap> IsSingleValued( comp1 );
false
gap> IsSurjective( comp1 );
true

gap> comp2:= CompositionMapping( map2, map3 );
CompositionMapping( [ [ Z(3)^0, 0*Z(3) ], [ Z(3)^0, Z(3)^0 ], 
  [ 0*Z(3), Z(3)^0 ] ] -> CanonicalBasis( GF(3^3) ), CanonicalBasis( GF(3^
3) ) -> [ [ Z(3)^0, 0*Z(3) ], [ Z(3)^0, Z(3)^0 ], [ 0*Z(3), Z(3)^0 ] ] )
gap> IsInjective( comp2 );
true
gap> IsSingleValued( comp2 );
true
gap> IsSurjective( comp2 );
true

gap> comp3:= CompositionMapping( FrobeniusAutomorphism( v ), map1 );
[ Z(3)^0 ] -> [ Z(3^3)^3 ]
gap> IsInjective( comp3 );
true
gap> IsSingleValued( comp3 );
true
gap> IsSurjective( comp3 );
false
gap> 2 * comp3;
[ Z(3)^0 ] -> [ Z(3^3)^16 ]
gap> ImagesRepresentative( comp3, 0*Z(3)^0 );
0*Z(3)
gap> ImagesRepresentative( comp3, Z(3)^0 );
Z(3^3)^3

gap> sum:= map1 + map1;
[ Z(3)^0 ] -> [ Z(3^3)^14 ]
gap> sum + map1 = ZeroMapping( f, v );
true

gap> map4:= LeftModuleGeneralMappingByImages( v, v, CanonicalBasis( v ),
>            [ Z(27)^8, Z(3), Z(27) ] );
CanonicalBasis( GF(3^3) ) -> [ Z(3^3)^8, Z(3), Z(3^3) ]
gap> map4 + IdentityMapping( v );
CanonicalBasis( GF(3^3) ) -> [ Z(3^3)^15, Z(3^3)^3, Z(3^3)^10 ]
gap> IdentityMapping( v ) + map4;
CanonicalBasis( GF(3^3) ) -> [ Z(3^3)^15, Z(3^3)^3, Z(3^3)^10 ]


#############################################################################
##
##  tests for linear mappings given by matrices
##  (same tests as above)
##

gap> bf:= CanonicalBasis( GF(3) );
CanonicalBasis( GF(3) )
gap> bv:= CanonicalBasis( GF(27) );
CanonicalBasis( GF(3^3) )
gap> bw:= CanonicalBasis( f^2 );
CanonicalBasis( ( GF(3)^2 ) )

gap> map5:= LeftModuleHomomorphismByMatrix( bf,
>               [ [ Z(3), Z(3), Z(3) ] ], bv );
<linear mapping by matrix, GF(3) -> GF(3^3)>
gap> ImagesSource( map5 );
VectorSpace( GF(3), [ Z(3^3)^19 ] )
gap> PreImagesRange( map5 );
GF(3)
gap> CoKernelOfAdditiveGeneralMapping( map5 );
<algebra of dimension 0 over GF(3)>
gap> KernelOfAdditiveGeneralMapping( map5 );
VectorSpace( GF(3), [ 0*Z(3) ] )
gap> IsSingleValued( map5 );
true
gap> IsInjective( map5 );
true
gap> ImagesRepresentative( map5, 0*Z(3)^0 );
0*Z(3)
gap> ImagesRepresentative( map5, Z(3)^0 );
Z(3^3)^19
gap> PreImagesRepresentative( map5, 0*Z(3) );
0*Z(3)
gap> PreImagesRepresentative( map5, Z(27) );
fail
gap> 2 * map5 = - map5;
true
gap> Z(3) * map5 = - map5;
true

gap> map6:= LeftModuleHomomorphismByMatrix( bv,
>            [ [ Z(3), Z(3) ], [ 0*Z(3), 0*Z(3) ], [ Z(3), 0*Z(3) ] ],
>            bw );
<linear mapping by matrix, GF(3^3) -> ( GF(3)^2 )>
gap> ImagesSource( map6 );
VectorSpace( GF(3), [ [ Z(3), Z(3) ], [ 0*Z(3), 0*Z(3) ], [ Z(3), 0*Z(3) ] ] )
gap> PreImagesRange( map6 );
GF(3^3)
gap> CoKernelOfAdditiveGeneralMapping( map6 );
VectorSpace( GF(3), [  ] )
gap> KernelOfAdditiveGeneralMapping( map6 );
VectorSpace( GF(3), [ 0*Z(3), Z(3^3), Z(3^3)^14 ] )
gap> IsSingleValued( map6 );
true
gap> IsInjective( map6 );
false
gap> ImagesRepresentative( map6, Z(27) );
[ 0*Z(3), 0*Z(3) ]
gap> ImagesRepresentative( map6, Z(9) );
fail
gap> PreImagesRepresentative( map6, [ Z(3)^0, Z(3)^0 ] );
Z(3)
gap> PreImagesRepresentative( map6, [ 0*Z(3)^0, 0*Z(3)^0 ] );
0*Z(3)
gap> 2 * map6 = - map6;
true
gap> Z(3) * map6 = - map6;
true

gap> map7:= LeftModuleHomomorphismByMatrix( bw,
>          [ [ Z(3)^0, 0*Z(3)^0, Z(3)^0 ], [ Z(3)^0, 0*Z(3)^0, Z(3)^0 ] ],
>          bv );
<linear mapping by matrix, ( GF(3)^2 ) -> GF(3^3)>
gap> ImagesSource( map7 );
VectorSpace( GF(3), [ Z(3^3)^21, Z(3^3)^21 ] )
gap> PreImagesRange( map7 );
( GF(3)^2 )
gap> CoKernelOfAdditiveGeneralMapping( map7 );
<algebra of dimension 0 over GF(3)>
gap> KernelOfAdditiveGeneralMapping( map7 );
VectorSpace( GF(3), [ [ 0*Z(3), 0*Z(3) ], [ Z(3)^0, Z(3) ], [ Z(3), Z(3)^0 ] 
 ] )
gap> IsSingleValued( map7 );
true
gap> IsInjective( map7 );
false
gap> ImagesRepresentative( map7, [ Z(3)^0, 0*Z(3)^0 ] );
Z(3^3)^21
gap> ImagesRepresentative( map7, [ 0*Z(3)^0, Z(3)^0 ] );
Z(3^3)^21
gap> PreImagesRepresentative( map7, Z(27) );
fail
gap> PreImagesRepresentative( map7, Z(3)^0 );
fail
gap> 2 * map7 = - map7;
true
gap> Z(3) * map7 = - map7;
true

gap> comp1:= CompositionMapping( map7, map6 );
<linear mapping by matrix, GF(3^3) -> GF(3^3)>
gap> IsInjective( comp1 );
false
gap> IsSingleValued( comp1 );
true
gap> IsSurjective( comp1 );
false

gap> comp2:= CompositionMapping( map6, map7 );
<linear mapping by matrix, ( GF(3)^2 ) -> ( GF(3)^2 )>
gap> IsInjective( comp2 );
false
gap> IsSingleValued( comp2 );
true
gap> IsSurjective( comp2 );
false

gap> comp3:= CompositionMapping( FrobeniusAutomorphism( v ), map5 );
<linear mapping by matrix, GF(3) -> GF(3^3)>
gap> IsInjective( comp3 );
true
gap> IsSingleValued( comp3 );
true
gap> IsSurjective( comp3 );
false
gap> 2 * comp3;
<linear mapping by matrix, GF(3) -> GF(3^3)>
gap> ImagesRepresentative( comp3, 0*Z(3)^0 );
0*Z(3)
gap> ImagesRepresentative( comp3, Z(3)^0 );
Z(3^3)^5

gap> sum:= map1 + map1;
[ Z(3)^0 ] -> [ Z(3^3)^14 ]
gap> sum + map1 = ZeroMapping( f, v );
true

gap> map8:= LeftModuleHomomorphismByMatrix( bv,
>            [ [   Z(3),   Z(3),   Z(3) ],
>              [ 0*Z(3), 0*Z(3), Z(3)^0 ],
>              [   Z(3), 0*Z(3), 0*Z(3) ] ],
>            bv );
<linear mapping by matrix, GF(3^3) -> GF(3^3)>
gap> map8 + IdentityMapping( v );
<linear mapping by matrix, GF(3^3) -> GF(3^3)>
gap> IdentityMapping( v ) + map8;
<linear mapping by matrix, GF(3^3) -> GF(3^3)>


#############################################################################
##
##  tests for mixed cases
##

gap> map2 + map6;
CanonicalBasis( GF(3^3) ) -> [ [ 0*Z(3), Z(3) ], [ Z(3)^0, Z(3)^0 ], 
  [ Z(3), Z(3)^0 ] ]
gap> map6 + map2;
CanonicalBasis( GF(3^3) ) -> [ [ 0*Z(3), Z(3) ], [ Z(3)^0, Z(3)^0 ], 
  [ Z(3), Z(3)^0 ] ]

gap> # id:= IdentityMapping( v );
gap> # 2 * id;
gap> # id + id;
gap> # - id;
gap> # zero:= ZeroMapping( v, v );
gap> # 2 * zero;
gap> # zero + zero;
gap> # id + zero;
gap> # - zero;


#############################################################################
##
##  tests for natural homomorphisms
##

gap> NaturalHomomorphismBySubspace( v, TrivialSubspace( v ) )
>    = IdentityMapping( v );
true

gap> IsZero( NaturalHomomorphismBySubspace( v, v ) );
true

gap> nathom:= NaturalHomomorphismBySubspace( w,
>                 Subspace( w, [ [ Z(3), Z(3) ] ] ) );
<linear mapping by matrix, ( GF(3)^2 ) -> ( GF(3)^1 )>
gap> ImagesSource( nathom );
( GF(3)^1 )
gap> PreImagesRange( nathom );
( GF(3)^2 )
gap> CoKernelOfAdditiveGeneralMapping( nathom );
VectorSpace( GF(3), [  ] )
gap> KernelOfAdditiveGeneralMapping( nathom );
VectorSpace( GF(3), [ [ Z(3), Z(3) ] ] )
gap> IsInjective( nathom );
false
gap> IsSingleValued( nathom );
true
gap> IsSurjective( nathom );
true
gap> IsTotal( nathom );
true
gap> ImagesRepresentative( nathom, [ Z(3), Z(3)^0 ] );
[ Z(3)^0 ]
gap> ImagesRepresentative( nathom, [ Z(3)^0, Z(3)^0 ] );
[ 0*Z(3) ]
gap> PreImagesRepresentative( nathom, [ Z(3)^0 ] );
[ Z(3)^0, 0*Z(3) ]
gap> PreImagesRepresentative( nathom, [ 0*Z(3) ] );
[ 0*Z(3), 0*Z(3) ]
gap> 2 * nathom = - nathom;
true
gap> Z(3) * nathom = - nathom;
true


#############################################################################
##
##  tests for spaces of linear mappings
##

gap> hom:= Hom( f, v, w );
Hom( GF(3), GF(3^3), ( GF(3)^2 ) )
gap> IsFullHomModule( hom );
true
gap> Dimension( hom );
6
gap> Random( hom ) in hom;
true
gap> map6 in hom;
true
gap> sub:= Subspace( hom, [ map6 ] );
VectorSpace( GF(3), [ <linear mapping by matrix, GF(3^3) -> ( GF(3)^2 )> ] )
gap> BasisVectors( BasisOfDomain( sub ) );
[ <linear mapping by matrix, GF(3^3) -> ( GF(3)^2 )> ]

gap> sub:= LeftModuleByGenerators( f, [ map6 ] );
VectorSpace( GF(3), [ <linear mapping by matrix, GF(3^3) -> ( GF(3)^2 )> ] )
gap> Dimension( sub );
1
gap> zero:= ZeroMapping( v, w );
ZeroMapping( GF(3^3), ( GF(3)^2 ) )
gap> triv:= LeftModuleByGenerators( f, [], zero );
VectorSpace( GF(3), [  ], ZeroMapping( GF(3^3), ( GF(3)^2 ) ) )
gap> IsSubset( hom, triv );
true

gap> mb:= MutableBasisByGenerators( f, [], zero );
<mutable basis over GF(3), 0 vectors>
gap> CloseMutableBasis( mb, map6 );
gap> ImmutableBasis( mb );
Basis( VectorSpace( GF(3), 
[ <linear mapping by matrix, GF(3^3) -> ( GF(3)^2 )> ] ), 
[ <linear mapping by matrix, GF(3^3) -> ( GF(3)^2 )> ] )


#############################################################################
##
##  tests for algebras of linear mappings
##

gap> endo:= End( f, v );
End( GF(3), GF(3^3) )
gap> id:= IdentityMapping( v );
IdentityMapping( GF(3^3) )
gap> zero:= ZeroMapping( v, v );
ZeroMapping( GF(3^3), GF(3^3) )
gap> id in endo;
true
gap> zero in endo;
true

gap> RingByGenerators( [ id ] );
<algebra over GF(3), with 1 generators>
gap> DefaultRingByGenerators( [ id ] );
<algebra over GF(3), with 1 generators>
gap> RingWithOneByGenerators( [ id ] );
<algebra-with-one over GF(3), with 1 generators>

gap> a:= AlgebraByGenerators( f, [], zero );
<algebra over GF(3)>
gap> Dimension( a );
0
gap> a:= AlgebraByGenerators( f, [ id ] );
<algebra over GF(3), with 1 generators>
gap> Dimension( a );
1

gap> a:= AlgebraWithOneByGenerators( f, [], zero );
<algebra-with-one over GF(3), with 0 generators>
gap> Dimension( a );
1
gap> a:= AlgebraWithOneByGenerators( f, [ id ] );
<algebra-with-one over GF(3), with 1 generators>
gap> Dimension( a );
1

gap> IsFullHomModule( a );
false
gap> IsFullHomModule( endo );
true
gap> Dimension( endo );
9
gap> Random( endo ) in endo;
true
gap> GeneratorsOfLeftModule( endo );
[ <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)> ]
gap> b:= BasisOfDomain( endo );
Basis( End( GF(3), GF(3^3) ), 
[ <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)> ] )
gap> BasisVectors( b );
[ <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)>, 
  <linear mapping by matrix, GF(3^3) -> GF(3^3)> ]
gap> Coefficients( b, id );
[ Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ]
gap> map:= LeftModuleHomomorphismByMatrix( bv, 2 * IdentityMat( 3, f ), bv );
<linear mapping by matrix, GF(3^3) -> GF(3^3)>
gap> Coefficients( b, map );
[ Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3) ]


gap> endoendo:= End( f, endo );
End( GF(3), End( GF(3), GF(3^3) ) )
gap> Dimension( endoendo );
81

gap> STOP_TEST( "vspchom.tst", 37810000 );


#############################################################################
##
#E  vspchom.tst . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
