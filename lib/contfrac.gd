#############################################################################
##
#W  contfrac.gd                                                   Stefan Kohl
##
#Y  Copyright (C) 2004 The GAP Group
##
#H  @(#)$Id$
##
##  This file contains declarations of functions for computing (with)
##  continued fraction expansions of real numbers.
##
Revision.contfrac_gd :=
    "@(#)$Id$";

#############################################################################
##
#F  ContinuedFractionExpansionOfRoot( <P>, <n> )
##
##  The first <n> terms of the continued fraction expansion of the only
##  positive real root of the polynomial <P> with integer coefficients.
##  The leading coefficient of <P> must be positive and the value of <P> at 0
##  must be negative. If the degree of <P> is 2 and <n> = 0, the function
##  computes one period of the continued fraction expansion of the root in
##  question. Anything may happen if <P> has three or more positive real
##  roots.
##
DeclareGlobalFunction( "ContinuedFractionExpansionOfRoot" );

#############################################################################
##
#F  ContinuedFractionApproximationOfRoot( <P>, <n> )
##
##  The <n>th continued fraction approximation of the only positive real root
##  of the polynomial <P> with integer coefficients. The leading coefficient
##  of <P> must be positive and the value of <P> at 0 must be negative.
##  Anything may happen if <P> has three or more positive real roots.
##
DeclareGlobalFunction( "ContinuedFractionApproximationOfRoot" );

#############################################################################
##
#E  contfrac.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
