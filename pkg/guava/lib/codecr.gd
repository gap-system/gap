#############################################################################
##
#A  codecr.gd               GUAVA library                       Reinald Baart
#A                                                         Jasper Cramwinckel
#A                                                            Erik Roijackers
#A                                                                Eric Minkes
##
##  This file contains functions for calculating with code covering radii
##
#H  @(#)$Id: codecr.gd,v 1.5 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/codecr_gd") :=
    "@(#)$Id: codecr.gd,v 1.5 2004/12/20 21:26:06 gap Exp $";

########################################################################
##
#F  CoveringRadius( <code> )
##
##  Return the covering radius of <code>
##  In case a special algorithm for this code exist, call
##  it first.
##
##  Not useful for large codes.
##
##  That's why I changed it, see the manual for more details
##  -- eric minkes.
##
DeclareAttribute("CoveringRadius", IsCode); 

########################################################################
##
#F  SpecialCoveringRadius( <code> )
##
##  Special function to calculate the covering radius of a code 
##  None implemented yet. 
##
DeclareAttribute("SpecialCoveringRadius", IsCode); 

########################################################################
##
#F  BoundsCoveringRadius( <code> )
##
##  Find a lower and an upper bound for the covering radius of code.
##
DeclareOperation("BoundsCoveringRadius", [IsCode]); 

########################################################################
##
#F  SetBoundsCoveringRadius( <code>, <cr> )
##  SetBoundsCoveringRadius( <code>, <interval> )
##
##  Enable the user to set the covering radius (or bounds) him/herself.
##  Was SetCoveringRadius in GAP3 version of GUAVA. 
## 
DeclareOperation("SetBoundsCoveringRadius", [IsCode, IsVector]);  

########################################################################
##
#F  IncreaseCoveringRadiusLowerBound(
##      <code> [, <stopdistance> ] [, <startword> ] )
##
DeclareOperation("IncreaseCoveringRadiusLowerBound", 
					[IsCode, IsInt, IsVector]); 

########################################################################
##
#F  ExhaustiveSearchCoveringRadius( <code> )
##
##  Try to compute the covering radius. Don't compute all coset
##  leaders, but increment the lower bound as soon as a coset leader
##  is found.
##
DeclareOperation("ExhaustiveSearchCoveringRadius", [IsCode, IsBool]); 

########################################################################
##
#F  CoveringRadiusLowerBoundTable
##


########################################################################
##
#F  GeneralLowerBoundCoveringRadius( <n>, <size> [, <F> ] )
##  GeneralLowerBoundCoveringRadius( <code> )
##
DeclareOperation("GeneralLowerBoundCoveringRadius", [IsCode]); 

########################################################################
##
#F  LowerBoundCoveringRadiusSphereCovering( <n>, <r> [, <F> ] [, true ] )
##
DeclareOperation("LowerBoundCoveringRadiusSphereCovering", 
						[IsInt, IsInt, IsInt, IsBool]); 

########################################################################
##
#F  LowerBoundCoveringRadiusVanWee1( ... )
##
DeclareOperation("LowerBoundCoveringRadiusVanWee1", 
						[IsInt, IsInt, IsInt, IsBool]); 

#############################################################################
##
#F  LowerBoundCoveringRadiusVanWee2( <n>, <r> ) Counting Excess bound
##
DeclareOperation("LowerBoundCoveringRadiusVanWee2", 
						[IsInt, IsInt, IsBool]); 

#############################################################################
##
#F  LowerBoundCoveringRadiusCountingExcess( <n>, <r> )
##
DeclareOperation("LowerBoundCoveringRadiusCountingExcess", 
						[IsInt, IsInt, IsBool]); 

########################################################################
##
#F  LowerBoundCoveringRadiusEmbedded1( <n>, <r> [, <givesize> ] )
##
DeclareOperation("LowerBoundCoveringRadiusEmbedded1", 
						[IsInt, IsInt, IsInt, IsBool]); 

########################################################################
##
#F  LowerBoundCoveringRadiusEmbedded2( <n>, <r> [, <givesize> ] )
##
DeclareOperation("LowerBoundCoveringRadiusEmbedded2", 
						[IsInt, IsInt, IsInt, IsBool]); 

#############################################################################
##
#F  LowerBoundCoveringRadiusInduction( <n>, <r> ) Induction bound
##
DeclareOperation("LowerBoundCoveringRadiusInduction", [IsInt, IsInt]);  

########################################################################
##
#F  GeneralUpperBoundCoveringRadius( <code> )
##
DeclareOperation("GeneralUpperBoundCoveringRadius", [IsCode]); 

########################################################################
##
#F  UpperBoundCoveringRadiusRedundancy( <code> )
##
##  Return the redundancy of the code as an upper bound for
##  the covering radius.
##
##  Only for linear codes.
##
DeclareOperation("UpperBoundCoveringRadiusRedundancy", [IsCode]); 

########################################################################
##
#F  UpperBoundCoveringRadiusDelsarte( <code> )
##
DeclareOperation("UpperBoundCoveringRadiusDelsarte", [IsCode]); 

########################################################################
##
#F  UpperBoundCoveringRadiusStrength( <code> )
##
##  Return (q-1)n/q as an upper bound for <code>, if it
##  has strength 1 (i.e. every coordinate contains each element
##  of the field the same number of times).
##
DeclareOperation("UpperBoundCoveringRadiusStrength", [IsCode]); 

########################################################################
##
#F  UpperBoundCoveringRadiusGriesmerLike( <code> )
##
DeclareOperation("UpperBoundCoveringRadiusGriesmerLike", [IsCode]);  

########################################################################
##
#F  UpperBoundCoveringRadiusCyclicCode( <code> )
##
DeclareOperation("UpperBoundCoveringRadiusCyclicCode", [IsCode]);  



