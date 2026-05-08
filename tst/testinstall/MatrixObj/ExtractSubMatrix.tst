gap> START_TEST("ExtractSubMatrix.tst");
gap> IsBoundGlobal("EXTRACT_SUB_MATRIX");
true
gap> EXTRACT_SUB_MATRIX = ExtractSubMatrix;
true
gap> m1 := [ [ 1, 2, 3 ], [ 4, 5, 6 ] ];
[ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
gap> ExtractSubMatrix( m1, [ 2, 1 ], [ 3, 1 ] );
[ [ 6, 4 ], [ 3, 1 ] ]
gap> m2 := IdentityMatrix( Integers, 4 );;
gap> Unpack( ExtractSubMatrix( m2, [ 2, 4 ], [ 4, 2 ] ) );
[ [ 0, 1 ], [ 1, 0 ] ]
# IsGF2MatrixRep
gap> m1 := IdentityMatrix( GF(2), 100 );
<a 100x100 matrix over GF2>
gap> m2 := ExtractSubMatrix( m1, [ 11..30 ], [ 11..30 ] );
<a 20x20 matrix over GF2>
gap> IsOne(m2);
true
# Is8BitMatrixRep
gap> m1 := IdentityMatrix( GF(3), 100 );
< mutable compressed matrix 100x100 over GF(3) >
gap> m2 := ExtractSubMatrix( m1, [ 11..30 ], [ 11..30 ] );
< mutable compressed matrix 20x20 over GF(3) >
gap> IsOne(m2);
true
gap> m2 := IdentityMatrix( Integers, 4 );;
gap> Unpack( ExtractSubMatrix( m2, [ 2, 4 ], [ 4, 2 ] ) );
[ [ 0, 1 ], [ 1, 0 ] ]
gap> STOP_TEST("ExtractSubMatrix.tst");
