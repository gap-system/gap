#############################################################################
##
#W  banner.g          GAP share package `sisyphos'              Thomas Breuer
##
#H  @(#)$Id: banner.g,v 1.2 2000/10/31 11:57:01 gap Exp $
##
#Y  Copyright (C)  2000,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

# Print the banner if wanted.
if not QUIET and BANNER then
  Print(
    "-------------------------------------------------\n",
    "Loading  Sisyphos ", PACKAGES_VERSIONS.sisyphos, "\n",
    "by Martin Wursthorn (Martin.Wursthorn@beatnix.de)\n",
    "-------------------------------------------------\n" );
fi;


#############################################################################
##
#E

