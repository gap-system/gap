# Compressed matrices and vectors are lists, not matrix or vector objects,
# so they compare as lists. See issues #6672 and #6693.
gap> START_TEST( "2026-11-16-compressed-not-matobj.tst" );

# membership of a GF(2) matrix compressed over GF(4)
gap> G := Group( [ [ 1, 1 ], [ 0, 1 ] ] * Z(2), [ [ 0, 1 ], [ 1, 0 ] ] * Z(2) );;
gap> y := [ [ 1, 0 ], [ 1, 1 ] ] * Z(2);;
gap> x := ImmutableMatrix( GF(4), y );;
gap> Is8BitMatrixRep( x );
true
gap> x in G;
true

# equal compressed matrices over different fields
gap> l := Z(2) * [ [ 0, 1 ], [ 1, 1 ] ];;
gap> m2 := ImmutableMatrix( GF(2), l );;  IsGF2MatrixRep( m2 );
true
gap> m4 := ImmutableMatrix( GF(4), l );;  Is8BitMatrixRep( m4 );
true
gap> m8 := ImmutableMatrix( GF(8), l );;
gap> m2 = m4;  m4 = m2;  m2 = m8;
true
true
true
gap> m2 < m4 or m4 < m2;
false
gap> MutableCopyMat( m2 ) = MutableCopyMat( m4 );
true
gap> m2 = Z(4) * m4;
false
gap> Length( Set( [ m2, m4, m8 ] ) );
1

# 'ImmutableMatrix' changes the field of a compressed matrix as for lists
gap> m := ImmutableMatrix( GF(4), l );;
gap> n := ImmutableMatrix( GF(2), m );;
gap> IsGF2MatrixRep( n ) and n = m;
true
gap> ImmutableMatrix( GF(3), m );
Error, CopyToVectorRep: Vector cannot be written over GF(3)
gap> ImmutableMatrix( GF(3), ImmutableMatrix( GF(9), [ [ Z(9) ] ] ) );
Error, CopyToVectorRep: Vector cannot be written over GF(3)

# quotients of immutable compressed vectors are immutable
gap> v := ImmutableVector( GF(3), Z(3) * [ 1, 2, 0 ] );;
gap> IsMutable( v / Z(3) );
false
gap> w := ImmutableVector( GF(2), Z(2) * [ 1, 0, 1 ] );;
gap> IsMutable( w / Z(2) );
false

#
gap> STOP_TEST( "2026-11-16-compressed-not-matobj.tst" );
