#
# run some of the demos from hpcgap/demo/
#
gap> START_TEST("demo.tst");

#
gap> ReadGapRoot("hpcgap/demo/cancel.g");
99

#
gap> ReadGapRoot("hpcgap/demo/factor.g");
Factoring 2^44-1 -> [ 3, 5, 23, 89, 397, 683, 2113 ] (FermatFactor)
Factoring 2^44+1 -> [ 17, 353, 2931542417 ] (SieveFactor)

#
gap> STOP_TEST( "demo.tst", 1 );
