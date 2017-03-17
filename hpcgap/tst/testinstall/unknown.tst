#############################################################################
##
#W  unknown.tst                GAP Library                      Thomas Breuer
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  Exclude from testinstall.g: why?
##
gap> START_TEST("unknown.tst");
gap> LargestUnknown:= 0;;
gap> u:= Unknown();
Unknown(1)
gap> IsUnknown( u );
true
gap> IsUnknown( 1 );
false
gap> u = Unknown( 1 );
true
gap> u = Unknown();
false
gap> Unknown() = u;
false
gap> u = 1;
false
gap> 1 = u;
false
gap> u < Unknown( 1 );
false
gap> u < Unknown();
true
gap> Unknown() < u;
false
gap> u < 1;
false
gap> 1 < u;
true
gap> u + u;
Unknown(6)
gap> u + 1;
Unknown(7)
gap> u + 0;
Unknown(1)
gap> 1 + u;
Unknown(8)
gap> 0 + u;
Unknown(1)
gap> u - u;
0
gap> u - Unknown();
Unknown(10)
gap> u - 1;
Unknown(11)
gap> u - 0;
Unknown(1)
gap> 0 - u;
Unknown(12)
gap> u * Unknown();
Unknown(14)
gap> u * 1;
Unknown(1)
gap> u * 2;
Unknown(15)
gap> 1 * u;
Unknown(1)
gap> 2 * u;
Unknown(16)
gap> u * 0;
0
gap> 0 * u;
0
gap> u / 1;
Unknown(1)
gap> u / 2;
Unknown(17)
gap> u ^ 0;
1
gap> u ^ 1;
Unknown(1)
gap> u ^ 2;
Unknown(18)
gap> STOP_TEST( "unknown.tst", 1);

#############################################################################
##
#E
