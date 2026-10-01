#@local F, gens, G, cl, H, K, a, filt, v, iso
gap> START_TEST( "matgroup.tst" );

#
# a GL(2,4) whose elements are matrix objects rather than plain lists
#
gap> F:= GF(4);;
gap> gens:= [ Matrix( IsPlistMatrixRep, F, [ [ Z(4), 0*Z(4) ], [ 0*Z(4), Z(4)^0 ] ] ),
>             Matrix( IsPlistMatrixRep, F, [ [ Z(4)^0, Z(4)^0 ], [ Z(4)^0, 0*Z(4) ] ] ) ];;
gap> ForAll( gens, IsMatrixObj ) and ForAny( gens, IsMatrix ) = false;
true
gap> G:= Group( gens );;
gap> IsMatrixGroup( G );  IsFiniteFieldMatrixGroup( G );
true
true

#
gap> DimensionOfMatrixGroup( G );
2
gap> FieldOfMatrixGroup( G );  DefaultFieldOfMatrixGroup( G );
GF(2^2)
GF(2^2)
gap> Size( G );
180
gap> Size( AsSSortedList( G ) );
180
gap> Size( Image( IsomorphismPermGroup( G ) ) );
180
gap> Size( DerivedSubgroup( G ) );  Size( Centre( G ) );
60
3
gap> Size( SylowSubgroup( G, 3 ) );  Exponent( G );
9
30
gap> IsAbelian( G );  IsSolvableGroup( G );
false
false

#
gap> cl:= ConjugacyClasses( G );;
gap> Length( cl );  Sum( cl, Size );
15
180
gap> ForAll( cl, c -> Representative( c ) in G );
true

#
# a proper subgroup, so that the natural-GL shortcuts do not apply
#
gap> H:= Group( gens[1] );;
gap> Size( H );  IsAbelian( H );
3
true
gap> IsSubgroup( G, H );
true

#
# 'FlushCaches' makes 'GF(4)' return a new object; the cached nice
# monomorphism of the full GL must not be reused across that boundary
#
gap> G:= GL( 2, GF(4) : ConstructingFilter:= IsPlistMatrixRep );;
gap> Size( Image( NiceMonomorphism( G ) ) );
180
gap> FlushCaches();
gap> G:= GL( 2, GF(4) : ConstructingFilter:= IsPlistMatrixRep );;
gap> ForAll( GeneratorsOfGroup( G ), g -> PreImagesRepresentative(
>        NiceMonomorphism( G ), ImagesRepresentative( NiceMonomorphism( G ), g ) ) = g );
true

#
# a group of plist matrices that is not a full GL, so that
# IsomorphismPermGroup uses a sparse linear action
#
gap> F:= GF(9);;
gap> gens:= [ Matrix( IsPlistMatrixRep, F,
>               [ [ Z(9), 0*Z(9), 0*Z(9) ], [ 0*Z(9), Z(9)^0, 0*Z(9) ],
>                 [ 0*Z(9), 0*Z(9), Z(9)^0 ] ] ),
>             Matrix( IsPlistMatrixRep, F,
>               [ [ Z(9)^0, Z(9)^0, 0*Z(9) ], [ 0*Z(9), Z(9)^0, Z(9)^0 ],
>                 [ 0*Z(9), 0*Z(9), Z(9)^0 ] ] ) ];;
gap> G:= Group( gens );;
gap> ForAll( [ 1 .. 10 ], function( s )
>      local iso;
>      # the random start vectors must not matter
>      Reset( GlobalMersenneTwister, s );  Reset( GlobalRandomSource, s );
>      iso:= IsomorphismPermGroup( Group( gens ) );
>      return Size( Image( iso ) ) = 1944 and
>             ForAll( gens, x -> PreImagesRepresentative( iso, Image( iso, x ) ) = x );
>    end );
true
gap> iso:= IsomorphismPermGroup( G );;
gap> Size( Image( iso ) );
1944
gap> ForAll( gens, x -> PreImagesRepresentative( iso, Image( iso, x ) ) = x );
true

#
# a group of matrix objects without row access, which is not a full GL
#
gap> F:= GF(9);;
gap> gens:= [ Matrix( IsGenericMatrixRep, F,
>               [ [ Z(9), 0*Z(9), 0*Z(9) ], [ 0*Z(9), Z(9)^0, 0*Z(9) ],
>                 [ 0*Z(9), 0*Z(9), Z(9)^0 ] ] ),
>             Matrix( IsGenericMatrixRep, F,
>               [ [ Z(9)^0, Z(9)^0, 0*Z(9) ], [ 0*Z(9), Z(9)^0, Z(9)^0 ],
>                 [ 0*Z(9), 0*Z(9), Z(9)^0 ] ] ) ];;
gap> G:= Group( gens );;
gap> Size( G );  IsNaturalGL( G );
1944
false
gap> Length( ConjugacyClasses( G ) );  Size( DerivedSubgroup( G ) );
30
81
gap> v:= Vector( F, [ Z(9)^0, 0*Z(9), 0*Z(9) ] );;
gap> Length( Orbit( G, v, OnRight ) );  Size( Stabilizer( G, v, OnRight ) );
648
3
gap> Size( Centralizer( G, gens[1] ) );  Size( Normalizer( G, Group( gens[1] ) ) );
24
24
gap> Length( NormalSubgroups( G ) );
11
gap> MTX.IsIrreducible( GModuleByMats( gens, F ) );
false
gap> SortedList( List( MTX.CompositionFactors( GModuleByMats( gens, F ) ),
>                      x -> x.dimension ) );
[ 1, 1, 1 ]
gap> Length( MTX.BasesSubmodules( GModuleByMats( gens, F ) ) );
4
gap> iso:= IsomorphismPermGroup( G );;
gap> Size( Image( iso ) );
1944
gap> ForAll( gens, x -> PreImagesRepresentative( iso, Image( iso, x ) ) = x );
true

#
# over a finite field whose elements are not FFEs, the default field is
# the base domain; the generators' entries are not inspected
#
gap> K:= AlgebraicExtension( GF(2),
>             UnivariatePolynomial( GF(2), Z(2)^0 * [ 1, 1, 1 ] ) );;
gap> a:= RootOfDefiningPolynomial( K );;
gap> for filt in [ IsPlistMatrixRep, IsGenericMatrixRep ] do
>      G:= Group( Matrix( filt, K, [ [ a, Zero(K) ], [ Zero(K), One(K) ] ] ) );
>      Print( DefaultFieldOfMatrixGroup( G ) = K, "\n" );
>    od;
true
true
gap> DefaultFieldOfMatrixGroup( Group( [ [ a, Zero(K) ], [ Zero(K), One(K) ] ] ) ) = K;
true

#
gap> STOP_TEST( "matgroup.tst" );
