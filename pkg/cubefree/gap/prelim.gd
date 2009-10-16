#############################################################################
##
#W  prelim.gd           Cubefree                               Heiko Dietrich
##                                                              
#H   @(#)$Id: prelim.gd,v 1.1 2007/05/08 07:58:50 gap Exp $
##


##############################################################################
##
#P  IsCubeFreeInt( n )
##
## return true if the integer n is cube-free
##
DeclareProperty( "IsCubeFreeInt", IsInt );


##############################################################################
##
#P  IsSquareFreeInt( n )
##
## returns true if the integer n is square-free
##
DeclareProperty( "IsSquareFreeInt", IsInt );


############################################################################# 
## 
#F  ConstructAllCFSimpleGroups( n ) 
## 
## returns all cube-free simple groups of order n up to isomorphism
##
DeclareGlobalFunction("ConstructAllCFSimpleGroups");

 
############################################################################# 
## 
#F  ConstructAllCFNilpotentGroups( n ) 
## 
## returns all cube-free nilpotent groups of order n up to isomorphism
##
DeclareGlobalFunction("ConstructAllCFNilpotentGroups");
