#############################################################################
##
#W  polyrat.gd                 GAP Library                   Alexander Hulpke
##
#H  @(#)$Id: 
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains attributes, properties and operations for univariate
##  polynomials over the rationals
##
Revision.polyrat_gd:=
  "@(#)$Id$";

#############################################################################
##
#A  MinimizedBombieriNorm( <f> ) . . . Tschirnhaus transf'd polynomial
##
MinimizedBombieriNorm := NewAttribute("MinimizedBombieriNorm",
   IsPolynomial and IsRationalFunctionsFamilyElement);

#############################################################################
##
#E  polyrat.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
