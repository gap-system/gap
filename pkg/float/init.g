#############################################################################
##
#W init.g                                                   Laurent Bartholdi
##
#H   @(#)$Id: init.g,v 1.8 2011/09/27 21:26:05 gap Exp $
##
#Y Copyright (C) 2008, Laurent Bartholdi
##
#############################################################################
##
##  This file reads the declarations of the packages' new objects
##
#############################################################################

#############################################################################
##
#I Create info class to be able to debug loading
##
InfoFloat := NewInfoClass("InfoFloat");
SetInfoLevel(InfoFloat, 1);

Revision.float := rec();

#############################################################################
BindGlobal("MAKEDOC@", function()
    MakeGAPDocDoc(Concatenation(GAPInfo.PackagesLoaded.float[1],"/doc"),"float",
            ["../lib/float.gd","../PackageInfo.g"],"float");
end);

if GAPInfo.TermEncoding = "UTF-8" then
    BindGlobal("FLOAT_INFINITY_STRING","∞"); # UChar(8734)
    BindGlobal("FLOAT_EMPTYSET_STRING","∅"); # UChar(8709)
    BindGlobal("FLOAT_REAL_STRING","ℂ"); # UChar(8450) or UChar(8477)
    BindGlobal("FLOAT_I_STRING","ⅈ"); # UChar(8520)
else
    BindGlobal("FLOAT_INFINITY_STRING","inf");
    BindGlobal("FLOAT_EMPTYSET_STRING","empty");
    BindGlobal("FLOAT_REAL_STRING","reals");
    BindGlobal("FLOAT_I_STRING","i");
fi;

CallFuncList(function()
    local f;
    f := Filename(DirectoriesPackagePrograms("float"),"mp_float.so");
    if f<>fail then
        LoadDynamicModule(f);
        if not ISBOUND_GLOBAL("MPFR_INT") then
            Unbind(GAPInfo.PackagesLoaded.float);
            Error("float: Something went wrong when loading the kernel module ",f);
        fi;
    fi;

    f := Filename(DirectoriesPackagePrograms("float"),"cxsc_float.so");
    if f<>fail then
        LoadDynamicModule(f);
        if not ISBOUND_GLOBAL("CXSC_INT") then
            Unbind(GAPInfo.PackagesLoaded.float);
            Error("float: Something went wrong when loading the kernel module ",f);
        fi;
    fi;
end,[]);

#############################################################################
##
#R Read the declaration files.
##
ReadPackage("float", "lib/float.gd");

#############################################################################

#E init.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
