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
gap> STOP_TEST("ExtractSubMatrix.tst");
