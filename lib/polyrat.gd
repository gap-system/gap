#############################################################################
##
#W  polyrat.gd                 GAP Library                   Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains attributes, properties and operations for univariate
##  polynomials over the rationals
##
Revision.polyrat_gd:=
  "@(#)$Id$";

#############################################################################
##
#F  PrimitivePolynomial( <f> )
##
##  takes a polynomial <f> with rational coefficients and
##  computes a new polynomial with integral coefficients, obtained by
##  multiplying with the Lcm of the denominators of the coefficients and
##  casting out the content (the Gcd of the coefficients). The operation
##  returns a list [<newpol>,<coeff>] such that `<coeff>\*<newpol>=<f>'.
##
DeclareOperation("PrimitivePolynomial",[IsPolynomial]);

#############################################################################
##
#A  MinimizedBombieriNorm( <f> ) . . . Tschirnhaus transf'd polynomial
##
##  This function applies linear Tschirnhaus transformations (x->x+i) to the
##  polynomial <f>, trying to get the bombieri norm of <f> small. It returns a
##  list [new polynomial, transformation <i>].
##
DeclareAttribute("MinimizedBombieriNorm",
   IsPolynomial and IsRationalFunctionsFamilyElement);

#############################################################################
##
#E  polyrat.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
