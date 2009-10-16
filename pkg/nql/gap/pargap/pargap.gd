############################################################################
##
#W pargap/pargap.gd		NQL				René Hartung
##
#H   @(#)$Id: pargap.gd,v 1.2 2009/07/02 12:37:14 gap Exp $
##
Revision.("nql/gap/pargap/pargap_gd"):=
  "@(#)$Id: pargap.gd,v 1.2 2009/07/02 12:37:14 gap Exp $";

# force the slaves to load the NQL-package
if IsMaster() then BroadcastMsg("RequirePackage(\"NQL\")"); fi;

# declaration for misc.gi
DeclareGlobalFunction( "NQLPar_CollectorToFunction" );
DeclareGlobalFunction( "NQLPar_MapRelations" );

# declaration for store.gi
DeclareGlobalFunction( "NQLPar_MapRelationsStoring" );

# declaration for consist.gi
DeclareGlobalFunction( "NQLPar_ListOfConsistencyChecks" );
DeclareGlobalFunction( "NQLPar_CheckConsRel" );
DeclareGlobalFunction( "NQLPar_MSCheckConsistencyRelations");
DeclareGlobalFunction( "NQLPar_CheckConsistencyRelations");

# declaration for induce.gi
DeclareGlobalFunction( "NQLPar_InduceEndomorphism" );
