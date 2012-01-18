#############################################################################
##
#W subgroups.gd            POLENTA package                     Bjoern Assmann
##
## Methods for the calculation of
## certain subgroups of matrix groups
##
#H  @(#)$Id: subgroups.gd,v 1.4 2011/09/23 13:36:33 gap Exp $
##
#Y 2004
##

#############################################################################
##
#F POL_TriangNSGFI_NonAbelianPRMGroup( arg )
##
## arg[1] = G is an non-abelian  polycyclic rational matrix group
##
DeclareGlobalFunction( "POL_TriangNSGFI_NonAbelianPRMGroup" );

#############################################################################
##
#F POL_TriangNSGFI_PRMGroup( arg )
##
## arg[1] = G is a rational polycyclic rational matrix group
##
DeclareGlobalFunction( "POL_TriangNSGFI_PRMGroup" );

#############################################################################
##
#M TriangNormalSubgroupFiniteInd( G )
##
## G is a matrix group over the Rationals.
## Returned is triangularizable normal subgroup of finite index
##
#DeclareOperation( "TriangNormalSubgroupFiniteInd", [ IsMatrixGroup ] );

#############################################################################
##
#M SubgroupsUnipotentByAbelianByFinite( G )
##
## G is a matrix group over the Rationals.
## Returned is triangularizable normal subgroup K of finite index
## and an unipotent normal subgroup U of K such that K/U is abelian.
##
DeclareOperation( "SubgroupsUnipotentByAbelianByFinite" , [ IsMatrixGroup ] );

#############################################################################
##
#E
