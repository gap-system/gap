#############################################################################
##
#W  init.g                GAP 4 package `ctbllib'               Thomas Breuer
##
#H  @(#)$Id: init.g,v 1.15 2005/05/17 08:52:14 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

if IsBound( GAPInfo ) then

  # Read the declaration part.
  ReadPackage( "ctbllib", "gap4/ctadmin.tbd" );
  ReadPackage( "ctbllib", "gap4/construc.gd" );
  ReadPackage( "ctbllib", "gap4/ctblothe.gd" );
  ReadPackage( "ctbllib", "gap4/test.gd" );

  # Read functions concerning Deligne-Lusztig names.
  ReadPackage( "ctbllib", "dlnames/dlnames.gd" );

else

  # GAP 3.4.4
  ReadPkg( "ctbllib", "gap3/ctadmin" );

fi;

#############################################################################
##
#E

