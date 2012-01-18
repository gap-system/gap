#############################################################################
##
#W  init.g               GAP 4 package CTblLib                  Thomas Breuer
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

if IsBound( GAPInfo ) then

  # Read the declaration part.
  ReadPackage( "ctbllib", "gap4/ctadmin.tbd" );
  ReadPackage( "ctbllib", "gap4/construc.gd" );
  ReadPackage( "ctbllib", "gap4/ctblothe.gd" );

  # Read functions concerning Deligne-Lusztig names.
  ReadPackage( "ctbllib", "dlnames/dlnames.gd" );

  # Read obsolete variable names if this happens also in the GAP library.
  if GAPInfo.UserPreferences.ReadObsolete <> false then
    ReadPackage( "ctbllib", "gap4/obsolete.gd" );
  fi;

else

  # GAP 3.4.4
  ReadPkg( "ctbllib", "gap3/ctadmin" );

fi;

#############################################################################
##
#E

