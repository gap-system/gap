#@local M
gap> START_TEST( "DiagonalMatrix.tst" );

# with base domain and vector of diagonal entries
gap> Is8BitMatrixRep( DiagonalMatrix( GF(9), [ 1, 2 ] * Z(3)^0 ) );
true
gap> DiagonalMatrix( GF(9), [] );
Error, Is8BitMatrixRep with zero rows not yet supported
gap> IsPlistMatrixRep( DiagonalMatrix( Integers, [ 1, 2 ] ) );
true
gap> IsPlistMatrixRep( DiagonalMatrix( Integers, [] ) );
true

# with constructing filter, base domain, and vector of diagonal entries
gap> Is8BitMatrixRep( DiagonalMatrix( Is8BitMatrixRep, GF(9), [ 1, 2 ] * Z(3)^0 ) );
true
gap> IsPlistMatrixRep( DiagonalMatrix( IsPlistMatrixRep, GF(9), [] ) );
true
gap> IsPlistRep( DiagonalMatrix( IsPlistRep, Integers, [ 1, 2 ] ) );
true

# with vector of diagonal entries and example matrix
gap> M:= Matrix( IsPlistMatrixRep, Integers, [ 1 ], 1 );;
gap> DiagonalMatrix( [ 1, 2 ], M );
<2x2-matrix over Integers>
gap> DiagonalMatrix( [], M );
<0x0-matrix over Integers>
gap> M:= [ [ 1 ] ];;
gap> DiagonalMatrix( [ 1, 2 ], M );
[ [ 1, 0 ], [ 0, 2 ] ]
gap> DiagonalMatrix( [], M );
[  ]
gap> M:= Matrix( IsPlistMatrixRep, GF(3), [ Z(3) ], 1 );;
gap> DiagonalMatrix( [ 1, 2 ] * Z(3), M );
<2x2-matrix over GF(3)>
gap> DiagonalMatrix( [ 1, 2 ], M );
Error, <ob> must lie in the base domain of <m>

# with vector of diagonal entries only (choose a default representation)
gap> Is8BitMatrixRep( DiagonalMatrix( [ 1, 2 ] * Z(3) ) );
true
gap> IsPlistMatrixRep( DiagonalMatrix( [ 1, 2 ] ) );
true
gap> DiagonalMatrix( [] );
Error, do not know over which ring the matrix shall be defined

#
gap> STOP_TEST( "DiagonalMatrix.tst" );
