#@local F, l, N, M
gap> START_TEST( "DirectSumMat.tst" );

# exotic arguments
gap> DirectSumMat();
[  ]
gap> DirectSumMat([]);
[  ]
gap> DirectSumMat([], []);
[  ]
gap> DirectSumMat([], [], [[1]]);
[ [ 1 ] ]

# plists (the situation from GAP 4.11.1)
gap> DirectSumMat([[1]], [[2]]);
[ [ 1, 0 ], [ 0, 2 ] ]
gap> DirectSumMat([[Z(2)]], [[Z(4)]]);
[ <a GF2 vector of length 2>, [ 0*Z(2), Z(2^2) ] ]
gap> DirectSumMat([[Z(2)]], [[Z(3)]]);
[ <a GF2 vector of length 2>, [ 0*Z(2), Z(3) ] ]
gap> F:= FunctionField( Rationals, 4 );;
gap> l:= IndeterminatesOfPolynomialRing( F );
[ x_1, x_2, x_3, x_4 ]
gap> N:= [ [ l[1], l[2] ],[ l[3], l[4] ] ];
[ [ x_1, x_2 ], [ x_3, x_4 ] ]
gap> DirectSumMat( N, N );
[ [ x_1, x_2, 0, 0 ], [ x_3, x_4, 0, 0 ], [ 0, 0, x_1, x_2 ], 
  [ 0, 0, x_3, x_4 ] ]

# matrix objects
gap> M:= Matrix( IsPlistMatrixRep, Rationals, [ 1, 2, 3, 4 ], 2 );
<2x2-matrix over Rationals>
gap> DirectSumMat( M ) = M;
true
gap> DirectSumMat( M, M );
<4x4-matrix over Rationals>
gap> DirectSumMat( [ M ] ) = M;
true
gap> DirectSumMat( [ M, M ] ) = DirectSumMat( M, M );
true
gap> DirectSumMat( M, [[ 1 ]] );
<3x3-matrix over Rationals>

#
gap> STOP_TEST( "DirectSumMat.tst" );
