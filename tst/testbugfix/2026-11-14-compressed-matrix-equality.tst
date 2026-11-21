# Equal compressed matrices over GF(2) and a larger field compared as
# unequal, although they are equal as lists.
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
gap> MutableCopyMat( m2 ) = MutableCopyMat( m4 );
true
gap> m2 = Z(4) * m4;
false
gap> Length( Set( [ m2, m4, m8 ] ) );
1
