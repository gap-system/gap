gap> START_TEST("AbelianInvariants.tst");

#
gap> G := Group( [ [ [ 2, 1 ], [ 17, 8 ] ] ] );
Group([ [ [ 2, 1 ], [ 17, 8 ] ] ])
gap> AbelianInvariants(G);
[ 0 ]

#
gap> STOP_TEST( "AbelianInvariants.tst", 1);
