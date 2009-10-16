#############################################################################
##
#W  read.g            GAP share package `cmeataxe'              Thomas Breuer
##
#H  @(#)$Id: read.g,v 1.1 2000/04/19 09:07:19 gap Exp $
##
#Y  Copyright (C)  2000,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

# Print the banner if wanted.
if not QUIET and BANNER  then
  Print( "----------------------------------------------------------\n",
         "Loading  C-MeatAxe ", PACKAGES_VERSIONS.cmeataxe,
         " (The C-MeatAxe),\n",
         "by Micheal Ringe (Micheal.Ringe@math.rwth-aachen.de)\n",
         "----------------------------------------------------------\n" );
fi;

# Read the actual code.
if not IsBound( InfoCMeatAxe ) then
  # This file is also part of the AtlasRep share package.
  ReadPkg( "cmeataxe", "gap/scanmtx.g" );
fi;

ReadPkg( "cmeataxe", "gap/cmeataxe.gd");

ReadPkg( "cmeataxe", "gap/cmeataxe.gi");
ReadPkg( "cmeataxe", "gap/mapermut.gi");

# Set the directory for the data files dealt with by the standalone programs.
CMeatAxeSetDirectory( DirectoryTemporary( "cmeataxe" ) );
if not QUIET then
  Print( "The C-MeatAxe functions are available now.\n",
         "All files dealt with by the C-MeatAxe standalone programs\n",
         "will be placed in the directory `", CMeatAxeDirectoryCurrent(),
         "'.\n",
         "GAP will try to remove this directory and all files\n",
         "contained in it at the end of the GAP session.\n",
         "If you want to use another directory and keep the files\n",
         "then you can change to the directory object <dir>\n",
         "using `SetCMeatAxeDirectory( <dir> )'.\n",
         "----------------------------------------------------------\n" );
fi;


#############################################################################
##
#E

