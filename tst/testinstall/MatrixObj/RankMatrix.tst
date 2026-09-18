#@local M, mat
gap> START_TEST( "RankMatrix.tst" );

# nonsquare matrix
gap> mat:= [[1,2,1,2],[1,0,1,0],[2,2,2,2]];;
gap> M:= NewMatrix( IsPlistMatrixRep, GF(5), 4, mat*Z(5)^0 );
<3x4-matrix over GF(5)>
gap> RankMatrix( M );
2

# 0x0 matrix
gap> M:= ZeroMatrix( IsPlistRep, GF(9), 0, 0 );
[  ]
gap> RankMatrix( M );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `RankMatrix' on 1 arguments
gap> M:= ZeroMatrix( IsPlistMatrixRep, GF(9), 0, 0 );
<0x0-matrix over GF(3^2)>
gap> RankMatrix( M );
0

#
gap> STOP_TEST( "RankMatrix.tst" );
