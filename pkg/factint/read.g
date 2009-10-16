#############################################################################
##
#W  read.g                 GAP4 Package `FactInt'                 Stefan Kohl
##
#H  @(#)$Id: read.g,v 1.4 2007/09/18 16:46:24 stefan Exp $
##

# Read the implementation part of the package.

ReadPackage( "factint", "gap/factintaux.g" );
ReadPackage( "factint", "gap/general.gi" );
ReadPackage( "factint", "gap/pminus1.gi" );
ReadPackage( "factint", "gap/pplus1.gi" );
ReadPackage( "factint", "gap/ecm.gi" );
ReadPackage( "factint", "gap/cfrac.gi" );
ReadPackage( "factint", "gap/mpqs.gi" );

#############################################################################
##
#E  read.g . . . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here