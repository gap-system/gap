#@local n, v, M
gap> START_TEST("matobjpacked.tst");

# Packed objects of the largest length, 2^32 - 1 (512 MB each)
#@if GAPInfo.BytesPerVariable = 8
gap> n := 2^32 - 1;;
gap> v := ZeroVector( IsPackedVectorRep, GF(2), n );;
gap> [ PositionNonZero( v ), PositionNonZero( v, 5 ), PositionLastNonZero( v ) ];
[ 4294967296, 4294967296, 0 ]
gap> v[n] := Z(2);;
gap> [ PositionNonZero( v ), PositionNonZero( v, n - 1 ), PositionNonZero( v, n ) ];
[ 4294967295, 4294967295, 4294967296 ]
gap> PositionLastNonZero( v );
4294967295
gap> v := 0;;
gap> M := ZeroMatrix( IsPackedMatrixRep, GF(2), 1, n );;
gap> [ PositionNonZeroInRow( M, 1 ), PositionNonZeroInRow( M, 1, 7 ) ];
[ 4294967296, 4294967296 ]
gap> M[1, n] := Z(2);;
gap> [ PositionNonZeroInRow( M, 1 ), PositionNonZeroInRow( M, 1, n ) ];
[ 4294967295, 4294967296 ]
gap> M := 0;;
#@fi

#
gap> STOP_TEST("matobjpacked.tst");
