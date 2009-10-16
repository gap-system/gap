############################################################################
##
#W  schumu.gd			NQL				René Hartung
##
#H   @(#)$Id: schumu.gd,v 1.2 2009/08/31 07:55:23 gap Exp $
##
Revision.("nql/gap/schumu_gd"):=
  "@(#)$Id: schumu.gd,v 1.2 2009/08/31 07:55:23 gap Exp $";

############################################################################
##
#A  GeneratingSetOfMultiplier( <LpGroup> )
##
DeclareAttribute( "GeneratingSetOfMultiplier", IsLpGroup and 
                   HasIsInvariantLPresentation and IsInvariantLPresentation );

############################################################################
##
#O  FiniteRankSchurMultiplier( <LpGroup>, <int> )
##
DeclareOperation( "FiniteRankSchurMultiplier", [ IsLpGroup and 
                   HasIsInvariantLPresentation and IsInvariantLPresentation, 
                   IsPosInt ] );

############################################################################
##
#O  EndomorphismsOfFRSchurMultiplier( <LpGroup>, <int> )
##
DeclareOperation( "EndomorphismsOfFRSchurMultiplier", [ IsLpGroup and 
                   HasIsInvariantLPresentation and IsInvariantLPresentation, 
                   IsPosInt ] );

############################################################################
##
#F  NQL_BuildCoveringGroup
##
DeclareGlobalFunction( "NQL_BuildCoveringGroup" );

############################################################################
##
#F  NQL_InduceEndosToCover
##
DeclareGlobalFunction( "NQL_InduceEndosToCover" );

############################################################################
##
#F  NQL_QSystemOfCoveringGroup
##
DeclareGlobalFunction( "NQL_QSystemOfCoveringGroup" );

############################################################################
##
#O  EpimorphismFiniteRankSchurMultipliers( <LpGroup>, <int>, <int> )
##
DeclareOperation( "EpimorphismFiniteRankSchurMultipliers", [ IsLpGroup and 
                   HasIsInvariantLPresentation and IsInvariantLPresentation, 
                   IsPosInt, IsPosInt ] );

############################################################################
##
#F  ImageInFiniteRankSchurMultiplier( <LpGroup>, <int>, <elm> )
##
DeclareGlobalFunction( "ImageInFiniteRankSchurMultiplier" );

############################################################################
##
#F  NQL_SchuMuFromCover( <QS>, <gens>, <Endos> )
##
DeclareGlobalFunction( "NQL_SchuMuFromCover" );


############################################################################
##
#O DwyerQuotient( <LpGroup>, <int> )
##
DeclareOperation( "DwyerQuotient", [ IsGroup, IsPosInt ] );
