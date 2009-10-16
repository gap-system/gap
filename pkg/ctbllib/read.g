#############################################################################
##
#W  read.g                GAP 4 package `ctbllib'               Thomas Breuer
##
#H  @(#)$Id: read.g,v 1.6 2005/05/17 08:52:14 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

# Read the implementation part. 
ReadPackage( "ctbllib", "gap4/ctadmin.tbi" );
ReadPackage( "ctbllib", "gap4/construc.gi" );
ReadPackage( "ctbllib", "gap4/ctblothe.gi" );
ReadPackage( "ctbllib", "gap4/test.gi" );

# Read functions concerning Deligne-Lusztig names.
DeclareAutoreadableVariables( "ctbllib", "dlnames/dllib.g",
    [ "DeltigLibUnipotentCharacters", "DeltigLibGetRecord" ] );
ReadPackage( "ctbllib", "dlnames/dlnames.gi" );
if TestPackageAvailability( "chevie", "" ) <> fail then
  DeclareAutoreadableVariables( "ctbllib", "dlnames/dlconstr.g",
      [ "DeltigConstructionFcts" ] );
  DeclareAutoreadableVariables( "ctbllib", "dlnames/dltest.g",
      [ "DeltigTestFcts", "DeltigTestFunction" ] );
fi;


#############################################################################
##
#E

