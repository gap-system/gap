##############################################################################
##
#W  irrGL2.gd           Cubefree                                Heiko Dietrich
##
#H   @(#)$Id: irrGL2.gd,v 1.1 2007/05/08 07:58:50 gap Exp $
##

#############################################################################
##
#O  IrreducibleSubgroupsOfGL( 2, q )   
##
## computes the irreducible subgroups of GL(2,q), p>=5, up to conjugacy
## 
## 
DeclareOperation("IrreducibleSubgroupsOfGL",[IsPosInt,IsPosInt]);
