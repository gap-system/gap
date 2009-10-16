#############################################################################
##
#A  divisors.gd                GUAVA library                      David Joyner
##
##  this file contains declarations for divisors on curves
##
#H  @(#)$Id: divisors.gd,v 1.1 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/divisors.gd") :=
    "@(#)$Id: divisors.gd,v 1.1 2004/12/20 21:26:06 gap Exp $";


#############################################################################
##
#F  AffinePointsOnCurve(<f>, <R>, <E>)
##
##  returns the points in $f(x,y)=0$ where $(x,y) \in E$ and 
##  $f\in R=F[x,y]$, $E/F$ finite fields.
##  
DeclareGlobalFunction("AffinePointsOnCurve");
#DeclareOperation("AffinePointsOnCurve",[IsPolynomial,IsRing,IsField]);