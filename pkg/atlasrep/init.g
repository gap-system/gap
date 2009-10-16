#############################################################################
##
#W  init.g                 GAP 4 package `atlasrep'             Thomas Breuer
##
#H  @(#)$Id: init.g,v 1.26 2007/04/05 09:12:53 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

# Read the declaration part.
ReadPackage( "atlasrep", "gap/bbox.gd"     );
if not IsBound( InfoCMeatAxe ) then
  # This file is also part of the C-{\MeaAxe} package.
  ReadPackage( "atlasrep", "gap/scanmtx.gd" );
  ReadPackage( "atlasrep", "gap/scanmtx.gi" );
fi;
ReadPackage( "atlasrep", "gap/access.gd"   );
ReadPackage( "atlasrep", "gap/types.gd"    );
ReadPackage( "atlasrep", "gap/interfac.gd" );
ReadPackage( "atlasrep", "gap/mindeg.gd"   );
ReadPackage( "atlasrep", "gap/utils.gd"    );
ReadPackage( "atlasrep", "gap/test.gd"     );


#############################################################################
##
#E

