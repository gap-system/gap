#############################################################################
##
#W read.g                                                   Laurent Bartholdi
##
#H   @(#)$Id: read.g,v 1.9 2012/01/17 10:57:01 gap Exp $
##
#Y Copyright (C) 2008, Laurent Bartholdi
##
#############################################################################
##
##  This file reads the implementations, and in principle could be reloaded
##  during a GAP session.
#############################################################################

#############################################################################
##
#R Read the install files.
##
ReadPackage("float", "lib/polynomial.gi");

if IsBound(MPFR_INT) then
    ReadPackage("float", "lib/mpfr.gi");
fi;
if IsBound(MPFI_INT) then
    ReadPackage("float", "lib/mpfi.gi");
fi;
if IsBound(MPC_INT) then
    ReadPackage("float", "lib/mpc.gi");
fi;
if IsBound(@FPLLL) then
    ReadPackage("float", "lib/fplll.gi");
fi;
if IsBound(CXSC_INT) then
    ReadPackage("float", "lib/cxsc.gi");
fi;
#############################################################################

#E read.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
