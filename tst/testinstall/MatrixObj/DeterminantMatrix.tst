#@local M, mat
gap> START_TEST( "DeterminantMatrix.tst" );

# nonsquare matrix
gap> mat:= [[1,2,1,2],[1,0,1,0],[2,2,2,2]];;
gap> M:= NewMatrix( IsPlistMatrixRep, GF(5), 4, mat*Z(5)^0 );;
gap> DeterminantMatrix( M );
Error, DeterminantMat: <mat> must be a nonempty square matrix

# 0x0 matrix
gap> M:= ZeroMatrix( IsPlistRep, GF(9), 0, 0 );
[  ]
gap> DeterminantMatrix( M );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DeterminantMatrix' on 1 arguments
gap> M:= ZeroMatrix( IsPlistMatrixRep, GF(9), 0, 0 );
<0x0-matrix over GF(3^2)>
gap> DeterminantMatrix( M );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `DeterminantMatrix' on 1 arguments

# square nonempty matrix
gap> mat:= [[1,2,1],[1,0,1],[2,2,2]];;
gap> M:= NewMatrix( IsPlistMatrixRep, GF(5), 3, mat*Z(5)^0 );;
gap> DeterminantMatrix( M );
0*Z(5)

#
gap> STOP_TEST( "DeterminantMatrix.tst" );
