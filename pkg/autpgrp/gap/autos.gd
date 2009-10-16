#############################################################################
##
#W  autos.gd                 AutPGrp package                     Bettina Eick
##
#H  @(#)$Id: autos.gd,v 1.8 2009/08/31 07:40:15 gap Exp $
##
Revision.("autpgrp/gap/autos_gd") :=
    "@(#)$Id: autos.gd,v 1.8 2009/08/31 07:40:15 gap Exp $";

#############################################################################
##
#C Choose functionality 
##
if not IsBound( InitAutGroup ) then InitAutGroup := false; fi;
if not IsBound( CHOP_MULT ) then CHOP_MULT := true; fi;
if not IsBound( NICE_STAB ) then NICE_STAB := true; fi;
if not IsBound( REDU_OPER ) then REDU_OPER := false; fi;
if not IsBound( USE_LABEL ) then USE_LABEL := false; fi;
if not IsBound( CHECK ) then CHECK := false; fi;

#############################################################################
##
#D Declarations for PGAutomorphisms
##
DeclareRepresentation( "IsPGAutomorphismRep",
                       IsGroupGeneralMappingByImages,
                       ["base", "baseimgs", "pcgs", "pcgsimgs"] );

IsPGAutomorphism := IsMapping and IsPGAutomorphismRep;
DeclareOperation( "PGAutomorphism", [ IsPGroup, IsList, IsList ] );


DeclareGlobalFunction( "AutomorphismGroupPGroup" );
DeclareGlobalFunction( "PcGroupAutPGroup" );
DeclareGlobalFunction( "ConvertHybridAutGroup" );
DeclareGlobalFunction( "PGOrbitStabilizer" );
DeclareGlobalFunction( "IdentityPGAutomorphism" );

DeclareGlobalFunction( "CountOrbitsGL" );
DeclareGlobalFunction( "NumberOfPClass2PGroups" );
DeclareGlobalFunction( "NumberOfClass2LieAlgebras" );

DeclareOperation( "PGMult", [IsObject, IsObject] );
DeclareOperation( "PGInverse",[IsObject] );
DeclareOperation( "PGPower",[IsInt, IsObject] );
DeclareOperation( "PGMultList", [IsList] );

#############################################################################
##
#V A version problem
##
if not CompareVersionNumbers( VERSION, "4.4") then 
    DeclareProperty("IsGroupOfAutomorphismsFiniteGroup", IsGroup);
fi;


############################################################################
## 
#V for external applications
##
DeclareGlobalFunction( "ImageAutPGroup" );
DeclareGlobalFunction( "InnerAutGroupPGroup" );
DeclareGlobalFunction( "ConvertAutGroup" );
DeclareGlobalFunction( "InduceAutGroup" );
DeclareGlobalFunction( "EcheloniseMat" );
DeclareGlobalFunction( "LinearActionAutGrp" );
DeclareGlobalFunction( "AddInfoCover" );
DeclareGlobalFunction( "InitAutomorphismGroupOver" );
