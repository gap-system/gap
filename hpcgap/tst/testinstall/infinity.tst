#############################################################################
##
#W  infinity.tst                GAP Library                  Markus Pfeiffer
##
##
#Y  Copyright (C) 2014,  University of St Andrews, Scotland
##
##
gap> START_TEST("infinity.tst");
gap> infinity;
infinity
gap> -infinity;
-infinity
gap> infinity + infinity;
infinity
gap> -infinity - infinity;
-infinity
gap> infinity + 1;
infinity
gap> 1 + infinity;
infinity
gap> -infinity + 1;
-infinity
gap> 1 - infinity;
-infinity
gap> 1 < infinity; infinity < 1;
true
false
gap> -infinity < 1; 1 < -infinity;
true
false
gap> -infinity < infinity;
true
gap> infinity < -infinity;
false
gap> STOP_TEST( "infinity.tst", 260000);

#############################################################################
##
#E
