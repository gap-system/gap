# 'ImmutableMatrix' must not reinterpret compressed rows over a field that
# does not contain their entries. See issue #4075.
gap> START_TEST( "2026-11-16-ImmutableMatrix-foreign-field.tst" );
gap> v := ImmutableVector( GF(9), [ Z(9), Z(3) ] );;
gap> w := ImmutableVector( GF(9), [ Z(3)^0, Z(9)^2 ] );;
gap> ImmutableMatrix( GF(3), [ v, w ] );
Error, CopyToVectorRep: Vector cannot be written over GF(3)
gap> [ v, w ];
[ [ Z(3^2), Z(3) ], [ Z(3)^0, Z(3^2)^2 ] ]
gap> ImmutableMatrix( GF(3), IdentityMat( 2, GF(4) ) );
Error, CopyToVectorRep: Vector cannot be written over GF(3)

# conversions that are possible still work
gap> l := Z(2) * [ [ 1, 0 ], [ 1, 1 ] ];;
gap> rows := List( l, r -> ImmutableVector( GF(4), r ) );;
gap> n := ImmutableMatrix( GF(2), rows );;
gap> IsGF2MatrixRep( n ) and n = l;
true
gap> n := ImmutableMatrix( GF(8), rows );;
gap> Is8BitMatrixRep( n ) and Q_VEC8BIT( n[1] ) = 8 and n = l;
true

#
gap> STOP_TEST( "2026-11-16-ImmutableMatrix-foreign-field.tst" );
