#############################################################################
##
#W  read.g              GAP 4 package `atlasrep'                Thomas Breuer
##
#H  @(#)$Id: read.g,v 1.18 2010/05/19 16:50:54 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

# Read the implementation part. 
ReadPackage( "atlasrep", "gap/bbox.gi"     );
ReadPackage( "atlasrep", "gap/access.gi"   );
ReadPackage( "atlasrep", "gap/types.gi"    );
ReadPackage( "atlasrep", "gap/interfac.gi" );
ReadPackage( "atlasrep", "gap/mindeg.gi"   );
ReadPackage( "atlasrep", "gap/utils.gi"    );
ReadPackage( "atlasrep", "gap/test.gi"     );

if IsPackageMarkedForLoading( "Browse", "1.2" ) then
  ReadPackage( "atlasrep", "gap/brmindeg.g" );
  if IsPackageMarkedForLoading( "ctbllib", "" ) then
    ReadPackage( "atlasrep", "gap/brspor.g"   );
  fi;
fi;


#############################################################################
##
#E

