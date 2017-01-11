gap> START_TEST("numtheor.tst");

#
gap> PValuation(0,2);
infinity
gap> PValuation(100,2);
2
gap> PValuation(100,3);
0
gap> PValuation(13/85,5);
-1

#
gap> STOP_TEST( "numtheor.tst", 290000);
