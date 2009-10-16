#############################################################################
##
#W  number.gd           Cubefree                               Heiko Dietrich
##                                                              
#H   @(#)$Id: number.gd,v 1.1 2007/05/08 07:58:50 gap Exp $
##


##############################################################################
##
#F  NumberCFSolvableGroups( arg )
##
## Counts the number of all cubefree solvable groups using the one-to-one
## correspondence. If the argument is [size,false] then the SmallGrps
## library is not used. If the argument is 'size' or [size,true] then
## it will be used.
##
DeclareGlobalFunction("NumberCFSolvableGroups");


##############################################################################
##
#F  NumberCFGroups( size )
##
## Counts all groups of cube-free order n.  If the argument is [size,false]
## then the SmallGrps library is not used. If the argument is 'size' or
## [size,true] then the SmallGroups library will be used.
##
DeclareGlobalFunction("NumberCFGroups");
