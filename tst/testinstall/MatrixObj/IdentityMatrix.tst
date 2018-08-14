gap> START_TEST("IdentityMatrix.tst");

#
gap> m:=IdentityMatrix( GF(2), 5 ); Display(m);
<a 5x5 matrix over GF2>
 1 . . . .
 . 1 . . .
 . . 1 . .
 . . . 1 .
 . . . . 1
gap> m:=IdentityMatrix( GF(3), 5 ); Display(m);
[ [ Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3) ], 
  [ 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ] ]
 1 . . . .
 . 1 . . .
 . . 1 . .
 . . . 1 .
 . . . . 1
gap> m:=IdentityMatrix( GF(4), 5 ); Display(m);
[ [ Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2) ], 
  [ 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2) ], 
  [ 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2) ], 
  [ 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2) ], 
  [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), Z(2)^0 ] ]
 1 . . . .
 . 1 . . .
 . . 1 . .
 . . . 1 .
 . . . . 1
gap> m:=IdentityMatrix( Integers, 5 ); Display(m);
<5x5-matrix over Integers>
<5x5-matrix over Integers:
[[ 1, 0, 0, 0, 0 ]
 [ 0, 1, 0, 0, 0 ]
 [ 0, 0, 1, 0, 0 ]
 [ 0, 0, 0, 1, 0 ]
 [ 0, 0, 0, 0, 1 ]
]>
gap> m:=IdentityMatrix( Integers mod 4, 5 ); Display(m);
<5x5-matrix over (Integers mod 4)>
<5x5-matrix over (Integers mod 4):
[[ ZmodnZObj( 1, 4 ), ZmodnZObj( 0, 4 ), ZmodnZObj( 0, 4 ), ZmodnZObj( 0, 4 ),
  ZmodnZObj( 0, 4 ) ]
 [ ZmodnZObj( 0, 4 ), ZmodnZObj( 1, 4 ), ZmodnZObj( 0, 4 ), ZmodnZObj( 0, 4 ),
  ZmodnZObj( 0, 4 ) ]
 [ ZmodnZObj( 0, 4 ), ZmodnZObj( 0, 4 ), ZmodnZObj( 1, 4 ), ZmodnZObj( 0, 4 ),
  ZmodnZObj( 0, 4 ) ]
 [ ZmodnZObj( 0, 4 ), ZmodnZObj( 0, 4 ), ZmodnZObj( 0, 4 ), ZmodnZObj( 1, 4 ),
  ZmodnZObj( 0, 4 ) ]
 [ ZmodnZObj( 0, 4 ), ZmodnZObj( 0, 4 ), ZmodnZObj( 0, 4 ), ZmodnZObj( 0, 4 ),
  ZmodnZObj( 1, 4 ) ]
]>

#
gap> m:=IdentityMatrix( Integers, 0 ); Display(m);
<0x0-matrix over Integers>
<0x0-matrix over Integers:
]>

# some error checking
gap> m:=IdentityMatrix( GF(2), -1 );
Error, <n> must be a non-negative integer (not a integer)
gap> m:=IdentityMatrix( GF(3), -1 );
Error, <n> must be a non-negative integer (not a integer)
gap> m:=IdentityMatrix( GF(4), -1 );
Error, <n> must be a non-negative integer (not a integer)
gap> m:=IdentityMatrix( Integers mod 4, -1 );
Error, <n> must be a non-negative integer (not a integer)

#
gap> STOP_TEST("IdentityMatrix.tst");
