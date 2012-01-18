#############################################################################
##
#W  read.g               GAP 4 package CTblLib                  Thomas Breuer
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

# database attributes
if IsPackageMarkedForLoading( "Browse", ">=1.6" ) then
  DeclareAutoreadableVariables( "ctbllib", "gap4/ctdbattr.g",
      [ "CTblLibData" ] );
  DeclareAutoreadableVariables( "ctbllib", "gap4/ctbltoc.g",
      [ "CTblLibGroupInfoString", "BrowseCTblLibInfo" ] );
fi;

# Read the implementation part. 
ReadPackage( "ctbllib", "gap4/ctadmin.tbi" );
ReadPackage( "ctbllib", "gap4/construc.gi" );
ReadPackage( "ctbllib", "gap4/ctblothe.gi" );
#ReadPackage( "ctbllib", "gap4/test.g"  );

# Read functions concerning Deligne-Lusztig names.
DeclareAutoreadableVariables( "ctbllib", "dlnames/dllib.g",
    [ "DeltigLibUnipotentCharacters", "DeltigLibGetRecord" ] );

ReadPackage( "ctbllib", "dlnames/dlnames.gi" );
if IsPackageMarkedForLoading( "chevie", ">= 1.0" ) then
  DeclareAutoreadableVariables( "ctbllib", "dlnames/dlconstr.g",
      [ "DeltigConstructionFcts" ] );
  DeclareAutoreadableVariables( "ctbllib", "dlnames/dltest.g",
      [ "DeltigTestFcts", "DeltigTestFunction" ] );
fi;


#############################################################################
##
#E

