#############################################################################
##
#W  unknown.tst                GAP Library                      Thomas Breuer
##
#H  @(#)$Id: unknown.tst,v 4.6 2005/05/05 15:04:16 gap Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  Exclude from testall.g: why?
##

gap> START_TEST("$Id: unknown.tst,v 4.6 2005/05/05 15:04:16 gap Exp $");

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

gap> STOP_TEST( "unknown.tst", 170000 );

#############################################################################
##
#E

