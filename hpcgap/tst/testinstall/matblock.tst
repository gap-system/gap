#############################################################################
##
#W  matblock.tst                GAP Library                     Thomas Breuer
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
gap> START_TEST("matblock.tst");
gap> m1 := BlockMatrix( [ [ 1, 1, [[1,1],[0,1]] ],
>                         [ 1, 3, [[1,0],[0,1]] ],
>                         [ 2, 2, [[0,1],[1,0]] ],
>                         [ 3, 4, [[1,0],[0,0]] ] ], 3, 4 );
<block matrix of dimensions (3*2)x(4*2)>
gap> m2 := BlockMatrix( [ [ 1, 3, [[1,0],[0,1]] ],
>                         [ 2, 1, [[1,0],[0,1]] ],
>                         [ 3, 2, [[1,0],[0,1]] ] ], 3, 3 );
<block matrix of dimensions (3*2)x(3*2)>
gap> m3 := AsBlockMatrix( m2, 2, 2 );
<block matrix of dimensions (2*3)x(2*3)>
gap> z  := BlockMatrix( [], 3, 3, 2, 2, 0 );
<block matrix of dimensions (3*2)x(3*2)>
gap> Length( m1 ); DimensionsMat( m1 );
6
[ 6, 8 ]
gap> Length( m2 ); DimensionsMat( m2 );
6
[ 6, 6 ]
gap> Length( m3 ); DimensionsMat( m3 );
6
[ 6, 6 ]
gap> Length( z );  DimensionsMat( z );
6
[ 6, 6 ]
gap> m1[3];
[ 0, 0, 0, 1, 0, 0, 0, 0 ]
gap> z[2];
[ 0, 0, 0, 0, 0, 0 ]
gap> m2 = m3;
true
gap> p1:= m2 * m1;
<block matrix of dimensions (3*2)x(4*2)>
gap> p2:= m3 * m1;
[ [ 0, 0, 0, 0, 0, 0, 1, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0 ], 
  [ 1, 1, 0, 0, 1, 0, 0, 0 ], [ 0, 1, 0, 0, 0, 1, 0, 0 ], 
  [ 0, 0, 0, 1, 0, 0, 0, 0 ], [ 0, 0, 1, 0, 0, 0, 0, 0 ] ]
gap> p1 = p2;
true
gap> p3:= m1 * TransposedMat( m1 );
<block matrix of dimensions (3*2)x(3*2)>
gap> mm:= MatrixByBlockMatrix( m1 );
[ [ 1, 1, 0, 0, 1, 0, 0, 0 ], [ 0, 1, 0, 0, 0, 1, 0, 0 ], 
  [ 0, 0, 0, 1, 0, 0, 0, 0 ], [ 0, 0, 1, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 1, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0 ] ]
gap> mm * TransposedMat( mm ) = p3;
true
gap> p4:= TransposedMat( m1 ) * m2;
<block matrix of dimensions (4*2)x(3*2)>
gap> p3 = p4;
false
gap> z = AsBlockMatrix( z, 2, 2 );
true
gap> MatrixByBlockMatrix( m1 );
[ [ 1, 1, 0, 0, 1, 0, 0, 0 ], [ 0, 1, 0, 0, 0, 1, 0, 0 ], 
  [ 0, 0, 0, 1, 0, 0, 0, 0 ], [ 0, 0, 1, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 1, 0 ], [ 0, 0, 0, 0, 0, 0, 0, 0 ] ]
gap> MatrixByBlockMatrix( m2 );
[ [ 0, 0, 0, 0, 1, 0 ], [ 0, 0, 0, 0, 0, 1 ], [ 1, 0, 0, 0, 0, 0 ], 
  [ 0, 1, 0, 0, 0, 0 ], [ 0, 0, 1, 0, 0, 0 ], [ 0, 0, 0, 1, 0, 0 ] ]
gap> Print( m1 + m1, "\n" );
BlockMatrix( [ [ 1, 1, [ [ 2, 2 ], [ 0, 2 ] ] ], 
  [ 1, 3, [ [ 2, 0 ], [ 0, 2 ] ] ], [ 2, 2, [ [ 0, 2 ], [ 2, 0 ] ] ], 
  [ 3, 4, [ [ 2, 0 ], [ 0, 0 ] ] ] ],3,4,2,2,0 )
gap> m2 + m3;
[ [ 0, 0, 0, 0, 2, 0 ], [ 0, 0, 0, 0, 0, 2 ], [ 2, 0, 0, 0, 0, 0 ], 
  [ 0, 2, 0, 0, 0, 0 ], [ 0, 0, 2, 0, 0, 0 ], [ 0, 0, 0, 2, 0, 0 ] ]
gap> Print( AdditiveInverse( m3 ), "\n" );
BlockMatrix( [ [ 1, 1, [ [ 0, 0, 0 ], [ 0, 0, 0 ], [ -1, 0, 0 ] ] ], 
  [ 1, 2, [ [ 0, -1, 0 ], [ 0, 0, -1 ], [ 0, 0, 0 ] ] ], 
  [ 2, 1, [ [ 0, -1, 0 ], [ 0, 0, -1 ], [ 0, 0, 0 ] ] ], 
  [ 2, 2, [ [ 0, 0, 0 ], [ 0, 0, 0 ], [ -1, 0, 0 ] ] ] ],2,2,3,3,0 )
gap> m1 * [ 1, 2, 3, 4, 5, 6, 7, 8 ];
[ 8, 8, 4, 3, 7, 0 ]
gap> m2 * [ 1, 2, 3, 4, 5, 6 ];
[ 5, 6, 1, 2, 3, 4 ]
gap> [ 1, 2, 3, 4, 5, 6 ] * m1;
[ 1, 3, 4, 3, 1, 2, 5, 0 ]
gap> z * [ 1, 2, 3, 4, 5, 6 ];
[ 0, 0, 0, 0, 0, 0 ]
gap> [ 1, 2, 3, 4, 5, 6 ] * z;
[ 0, 0, 0, 0, 0, 0 ]
gap> 3 * m1;
<block matrix of dimensions (3*2)x(4*2)>
gap> Print( m2 * 5, "\n" );
BlockMatrix( [ [ 1, 3, [ [ 5, 0 ], [ 0, 5 ] ] ], 
  [ 2, 1, [ [ 5, 0 ], [ 0, 5 ] ] ], [ 3, 2, [ [ 5, 0 ], [ 0, 5 ] ] ] ],3,3,2,
2,0 )
gap> o1:= One( m2 );
<block matrix of dimensions (3*2)x(3*2)>
gap> o2:= One( z );
<block matrix of dimensions (3*2)x(3*2)>
gap> o1 = o2;
true
gap> STOP_TEST( "matblock.tst", 1);

#############################################################################
##
#E
