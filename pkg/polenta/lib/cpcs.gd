#############################################################################
##
#W cpcs.gd              POLENTA package                     Bjoern Assmann
##
## Methods for the calculation of
## constructive pc-sequences for rational matrix groups
##
#H  @(#)$Id: cpcs.gd,v 1.6 2011/09/23 13:36:31 gap Exp $
##
#Y 2003
##

#############################################################################
##
#F CPCS_PRMGroup( arg )
##
## arg[1]=G is a rational polycyclic rational matrix group
##
DeclareGlobalFunction( "CPCS_PRMGroup" );

#############################################################################
##
#F CPCS_NonAbelianPRMGroup( arg )
##
## arg[1]=G is an non-abelian rational polycyclic rational matrix group
##
DeclareGlobalFunction( "CPCS_NonAbelianPRMGroup" );

#############################################################################
##
#F CPCS_AbelianPRMGroup( G )
##
## G is an abelian polycyclic rational matrix group
##
DeclareGlobalFunction( "CPCS_AbelianPRMGroup" );

#############################################################################
##
#F CPCS_FactorGU_p( gens, pcgs_I_p, gens_K_p, pcgs_nue_K_p, radicalSeries,p)
##
## calculates a constructive pcs for the G/U_p(G)
##
DeclareGlobalFunction( "CPCS_FactorGU_p" );

#############################################################################
##
#F POL_PreImagesPcsNueK_p_G( gens_K_p, pcgs_nue_K_p )
##
DeclareGlobalFunction( "POL_PreImagesPcsNueK_p_G" );

#############################################################################
##
#F POL_PreImagesPcsI_p_G( pcgs_I_p, gens )
##
DeclareGlobalFunction( "POL_PreImagesPcsI_p_G" );

#############################################################################
##
#F TestPOL_PreImagesPcsI_p_G( preImgsI_p, p, pcgs_I_p );
##
DeclareGlobalFunction( "TestPOL_PreImagesPcsI_p_G" );

#############################################################################
##
#F ExponentVector_CPCS_FactorGU_p(pcgs_GU,g)
##
DeclareGlobalFunction( "ExponentVector_CPCS_FactorGU_p" );

#############################################################################
##
#F POL_GetPartinK_P(g,exp_h,preImgsI_p)
##
DeclareGlobalFunction( "POL_GetPartinK_P" );

#############################################################################
##
#F RelativeOrders_CPCS_FactorGU_p( pcgs_GU )
##
DeclareGlobalFunction( "RelativeOrders_CPCS_FactorGU_p" );

#############################################################################
##
#F POL_MergeCPCS( pcgs_U_p, pcgs_GU)
##
DeclareGlobalFunction( "POL_MergeCPCS" );

#############################################################################
##
#F ExponentVector_CPCS_PRMGroup( matrix, pcgs )
##
## pcgs is the constructive pcs of a rational polycyclic matrix group
##
DeclareGlobalFunction( "ExponentVector_CPCS_PRMGroup" );

##############################################################################
##
#F POL_TestIsUnipotenByAbelianGroupByRadSeries( gens, radSers )
##
DeclareGlobalFunction(  "POL_TestIsUnipotenByAbelianGroupByRadSeries" );

#############################################################################
##
#F CPCS_UnipotentByAbelianByRadSeries( gens, recordSeries )
##
## G is an abelian rational polycyclic rational matrix group
##
DeclareGlobalFunction( "CPCS_UnipotentByAbelianGroupByRadSeries" );

#############################################################################
##
#E
