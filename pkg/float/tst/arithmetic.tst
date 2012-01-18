#############################################################################
##
#W  arithmetic.tst              Float Package               Laurent Bartholdi
##
#H  @(#)$Id: arithmetic.tst,v 1.1 2011/09/27 14:46:55 gap Exp $
##
#Y  Copyright (C) 2011,  Laurent Bartholdi
##
#############################################################################
##
##  This file tests basic arithmetic
##
#############################################################################

gap> START_TEST("arithmetic");
gap> 
gap> x := 1.0;;
gap> IsOne(x);
true
gap> IsZero(x);
false
gap> y := 4*Atan(x);;
gap> y > 3.14 and y < 3.15;
true
gap> x+x = 2.0;
true
gap> x-x = 0.0;
true
gap> Sqrt(x) = 1.0;
true
gap> AbsoluteValue(Sin(y)) < 1.e-10;
true
gap> STOP_TEST( "arithmetic.tst", 3*10^8 );
arithmetic

#E arithmetic.tst . . . . . . . . . . . . . . . . . . . . . . . . . . . .ends here
