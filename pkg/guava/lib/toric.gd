#############################################################################
##
#A  toric.gd                  GUAVA library                      David Joyner
##
##  this file contains declarations for toric codes
##
#H  @(#)$Id: toric.gd,v 1.3 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/toric_gd") :=
    "@(#)$Id: toric.gd,v 1.3 2004/12/20 21:26:06 gap Exp $";


#############################################################################
##
#F  ToricPoints(<n>,<F>)
##
##  returns the points in $(F^*)^n$.
##  
DeclareGlobalFunction("ToricPoints");

#############################################################################
##
#F  ToricCode(<L>,<F>)
##
##  This function returns the same toric code as in J. P. Hansen, "Toric
##  surfaces and error-correcting codes", except that the polytope can be
##  more general This is a truncated RS code. <L> is a list of integral
##  vectors (in Hansen's case, <L> is the list of integral vectors in a
##  polytope) and <F> is the finite field. The characteristic of <F> must
##  be different from 2.
##  
DeclareGlobalFunction("ToricCode");

#############################################################################
##
#F  GeneralizedReedMullerCode(<Pts>, <r>, <F>)
#F  GeneralizedReedMullerCode(<d>, <r>, <F>)
##
## 
DeclareOperation("GeneralizedReedMullerCode",[IsList,IsInt,IsField]);
