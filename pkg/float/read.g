#############################################################################
##
#W read.g                                                   Laurent Bartholdi
##
#H   @(#)$Id: read.g,v 1.2 2008/06/14 15:45:40 gap Exp $
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
ReadPackage("float", "lib/float.gi");
if IsBound(MPFR_INT) then
    ReadPackage("float", "lib/mpfr.gi");
fi;
if IsBound(MPFI_INT) then
    ReadPackage("float", "lib/mpfi.gi");
fi;
if IsBound(MPC_INT) then
    ReadPackage("float", "lib/mpc.gi");
fi;
if IsBound(CXSC_INT) then
    ReadPackage("float", "lib/cxsc.gi");
fi;
#############################################################################

Float := 0; NewFloat := 0; # shut up warnings
InstallMethod(SelectFloat, "record", [IsRecord],
        function(r)
    if IsBound(Float) then
        Info(InfoFloat, 1, "Modifying global variable `Float'");
        MakeReadWriteGlobal("Float");
        Unbind(Float);
        MakeReadWriteGlobal("NewFloat");
        Unbind(NewFloat);
    fi;
    DeclareSynonym("Float", r);
    DeclareSynonym("NewFloat", r.New);
end);
Unbind(Float); Unbind(NewFloat);

if IsBound(MPFR_INT) then
    SelectFloat(MPFR);
elif IsBound(CXSC_INT) then
    SelectFloat(CXSC);
fi;
    
#E read.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
