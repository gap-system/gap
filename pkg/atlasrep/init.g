#############################################################################
##
#W  init.g               GAP 4 package AtlasRep                 Thomas Breuer
##
#Y  Copyright (C)  2001,   Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##

# Read the declaration part.
ReadPackage( "atlasrep", "gap/bbox.gd"     );
if not IsBound( InfoCMeatAxe ) then
  # This file is also part of the C-MeaAxe package.
  ReadPackage( "atlasrep", "gap/scanmtx.gd" );
  ReadPackage( "atlasrep", "gap/scanmtx.gi" );
fi;
ReadPackage( "atlasrep", "gap/access.gd"   );
ReadPackage( "atlasrep", "gap/types.gd"    );
ReadPackage( "atlasrep", "gap/interfac.gd" );
ReadPackage( "atlasrep", "gap/mindeg.gd"   );
ReadPackage( "atlasrep", "gap/utils.gd"    );

# Read obsolete variable names if this happens also in the GAP library.
if not IsBound( GAPInfo.UserPreferences ) or
#T remove this if GAP 4.4 is not supported anymore
   GAPInfo.UserPreferences.ReadObsolete <> false then
  ReadPackage( "atlasrep", "gap/obsolete.gd" );
fi;


#############################################################################
##
#E

