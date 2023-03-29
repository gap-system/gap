gap> START_TEST("Concatenation.tst");

#
gap> Concatenation( );
[  ]
gap> Concatenation( [ ] );
[  ]
gap> Concatenation( [ 1 ] );
Error, Concatenation: arguments must be lists
gap> Concatenation( [ [ 1, 2 ] ] );
[ 1, 2 ]
gap> Concatenation( [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ] ] );
[ 1, 2, 3, 4, 5, 6 ]
gap> Concatenation( [ 1, 2 ], [ 3, 4 ], [ 5, 6 ] );
[ 1, 2, 3, 4, 5, 6 ]

#
gap> STOP_TEST("Concatenation.tst", 1);
