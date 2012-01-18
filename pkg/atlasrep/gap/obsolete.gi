#############################################################################
##
#W  obsolete.gi          GAP 4 package AtlasRep                 Thomas Breuer
##
#Y  Copyright (C)  2011,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains implementations of global variables
##  that had been documented in earlier versions of the AtlasRep package.
##


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestClassScripts( ... )
#F  AtlasOfGroupRepresentationsTestCompatibleMaxes( ... )
#F  AtlasOfGroupRepresentationsTestFileHeaders( ... )
#F  AtlasOfGroupRepresentationsTestFiles( ... )
#F  AtlasOfGroupRepresentationsTestGroupOrders( ... )
#F  AtlasOfGroupRepresentationsTestStdCompatibility( ... )
#F  AtlasOfGroupRepresentationsTestSubgroupOrders( ... )
#F  AtlasOfGroupRepresentationsTestWords( ... )
##
##  These functions are deprecated since version 1.5 of the package.
##
if not IsBound( AGR.Test ) then
  ReadPackage( "atlasrep", "gap/test.g" );
fi;

InstallGlobalFunction( AtlasOfGroupRepresentationsTestClassScripts,
    AGR.Test.ClassScripts );
InstallGlobalFunction( AtlasOfGroupRepresentationsTestCompatibleMaxes,
    AGR.Test.CompatibleMaxes );
InstallGlobalFunction( AtlasOfGroupRepresentationsTestFileHeaders,
    AGR.Test.FileHeaders );
InstallGlobalFunction( AtlasOfGroupRepresentationsTestFiles,
    AGR.Test.Files );
InstallGlobalFunction( AtlasOfGroupRepresentationsTestGroupOrders,
    AGR.Test.GroupOrders );
InstallGlobalFunction( AtlasOfGroupRepresentationsTestStdCompatibility,
    AGR.Test.StdCompatibility );
InstallGlobalFunction( AtlasOfGroupRepresentationsTestSubgroupOrders,
    AGR.Test.MaxesOrders );
InstallGlobalFunction( AtlasOfGroupRepresentationsTestWords,
    AGR.Test.Words );


#############################################################################
##
#E

