#############################################################################
##
#A  bounds.gd               GUAVA library                       Reinald Baart
#A                                                        &Jasper Cramwinckel
#A                                                           &Erik Roijackers
##
##  This file contains functions for calculating with bounds
##
#H  @(#)$Id: bounds.gd,v 1.5 2004/12/20 21:26:06 gap Exp $
##
## added LowerBoundGilbertVarshamov, LowerBoundSpherePacking
##
Revision.("guava/lib/bounds_gd") :=
    "@(#)$Id: bounds.gd,v 1.5 2004/12/20 21:26:06 gap Exp $";

#############################################################################
##
#F  LowerBoundGilbertVarshamov( <n>, <d>, <q> )  . . .Gilbert-Varshamov bound
##
## added 9-2004 by wdj
DeclareOperation("LowerBoundGilbertVarshamov", [IsInt, IsInt, IsInt]); 

#############################################################################
##
#F  LowerBoundSpherePacking( <n>, <r>, <q> )  . . . sphere packing lower bound
##                                                 for unrestricted codes
##
## added 11-2004 by wdj
DeclareOperation("LowerBoundSpherePacking", [IsInt, IsInt, IsInt]); 

#############################################################################
##
#F  UpperBoundHamming( <n>, <d>, <q> )  . . . . . . . . . . . . Hamming bound
##
DeclareOperation("UpperBoundHamming", [IsInt, IsInt, IsInt]); 

#############################################################################
##
#F  UpperBoundSingleton( <n>, <d>, <q> )  . . . . . . . . . . Singleton bound
##
DeclareOperation("UpperBoundSingleton", [IsInt, IsInt, IsInt]);  

#############################################################################
##
#F  UpperBoundPlotkin( <n>, <d>, <q> )  . . . . . . . . . . . . Plotkin bound
##
DeclareOperation("UpperBoundPlotkin", [IsInt, IsInt, IsInt]); 

#############################################################################
##
#F  UpperBoundGriesmer( <n>, <d>, <q> ) . . . . . . . . . . .  Griesmer bound
##
DeclareOperation("UpperBoundGriesmer", [IsInt, IsInt, IsInt]);  

#############################################################################
##
#F  UpperBoundElias( <n>, <d>, <q> )  . . . . . . . . . . . . . . Elias bound
##
DeclareOperation("UpperBoundElias", [IsInt, IsInt, IsInt]); 

#############################################################################
##
#F  UpperBoundJohnson( <n>, <d> ) . . . . . . . . . . Johnson bound for <q>=2
##
DeclareOperation("UpperBoundJohnson", [IsInt, IsInt]); 

#############################################################################
##
#F  UpperBound( <n>, <d> [, <F>] )  . . . .  upper bound for minimum distance
##
##  calculates upperbound for a code C of word length n, minimum distance at
##  least d over an alphabet Q of size q, using the minimum of the Hamming,
##  Plotkin and Singleton bound.
##
DeclareOperation("UpperBound", [IsInt, IsInt, IsInt]); 

#############################################################################
##
#F  IsPerfectCode( <C> )  . . . . . .  determines whether C is a perfect code
##
DeclareProperty("IsPerfectCode", IsCode); 

#############################################################################
##
#F  IsMDSCode( <C> )  . . .  checks if C is a Maximum Distance Separable Code
##
DeclareProperty("IsMDSCode", IsCode); 

#############################################################################
##
#F  OptimalityCode( <C> ) . . . . . . . . . .  estimate for optimality of <C>
##
##  OptimalityCode(C) returns the difference between the smallest known upper-
##  bound and the actual size of the code. Note that the value of the
##  function UpperBound is not allways equal to the actual upperbound A(n,d)
##  thus the result may not be equal to 0 for all optimal codes!
##
DeclareOperation("OptimalityCode", [IsCode]); 

#############################################################################
##
#F  OptimalityLinearCode( <C> ) .  estimate for optimality of linear code <C>
##
##  OptimalityLinearCode(C) returns the difference between the smallest known
##  upperbound on the size of a linear code and the actual size.
##
DeclareOperation("OptimalityLinearCode", [IsCode]); 

#############################################################################
##
#F  BoundsMinimumDistance( <n>, <k>, <F> )  . .  gets data from bounds tables
##
##  LowerBoundMinimumDistance uses (n, k, q, true)
##  LowerBoundMinimumDistance uses (n, k, q, false) 
DeclareGlobalFunction("BoundsMinimumDistance"); 

