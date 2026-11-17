# ZeroSameMutability for GF2 matrices reused the type of its argument, so the
# zero matrix inherited properties stored there, such as IsOne and IsZero.
gap> START_TEST("2026-09-28-ZeroSameMutability-GF2.tst");

#
gap> m := IdentityMat( 2, GF(2) );; ConvertToMatrixRep( m, 2 );;
gap> z := ZeroSameMutability( m );;
gap> IsGF2MatrixRep( z ); IsMutable( z );
true
true
gap> MakeImmutable( m );; IsOne( m ); IsZero( m );
true
false
gap> z := ZeroSameMutability( m );;
gap> IsGF2MatrixRep( z ); IsMutable( z );
true
false
gap> IsOne( z ); IsZero( z );
false
true
gap> IsOne( 0 * m ); IsZero( 0 * m );
false
true

#
gap> STOP_TEST("2026-09-28-ZeroSameMutability-GF2.tst");
