#############################################################################
##
#W basic.gd               POLENTA package                     Bjoern Assmann
##
## Methods for the calculation of 
## constructive pc-sequences for polycyclic rational matrix groups
##
#H  @(#)$Id: basic.gd,v 1.2 2004/10/22 18:12:57 gap Exp $
##
#Y 2003
##


#############################################################################
##
#F DetermineAdmissiblePrime(gensOfG)
##
## determines a prime number which does not divide  the denominators
## of the entries of the matrices in gensOfG and which does not divide the
## the entries of the inverses of the matrices in gensOfG
##
## input is a list of generators of a rational polycyclic matrix group
##
DeclareGlobalFunction( "DetermineAdmissiblePrime" );

############################################################################
##
#F POL_NormalSubgroupGeneratorsOfK_p(pcgs,gensOfRealG)
##
## pcgs is a constructive pc-Sequence for I_p(G) 
## (image of G under the p-congruence hom.).
## This function calculates  normal subgroupgenerators for K_p(G)
## (the kernel of the p-congruence hom.)
##
DeclareGlobalFunction( "POL_NormalSubgroupGeneratorsOfK_p" );

#############################################################################
##
#F Exp2Groupelement(list,exp)
##
DeclareGlobalFunction( "Exp2Groupelement" );
  
#############################################################################
##
#F CopyMatrixList(list)
##
DeclareGlobalFunction( "CopyMatrixList" );

#############################################################################
##
#F POL_CopyVectorList(list)
##
DeclareGlobalFunction( "POL_CopyVectorList" );

#############################################################################
##
#F POL_NormalSubgroupGeneratorsU_p( pcgs_GU, gens, gens_K_p )
##
## pcgs_GU  is a constructive pc-Sequence for G/U,
## this function calculates normal subgroupgenerators for U_p(G)
##
DeclareGlobalFunction( "POL_NormalSubgroupGeneratorsU_p" );

#############################################################################
##
#E






