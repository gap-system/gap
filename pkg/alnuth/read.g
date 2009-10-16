#############################################################################
##
#W    read.g         Alnuth - Kant Interface                     Bettina Eick
##

#############################################################################
##
#R alnuth global variables
##
if not IsBound( KANTOUTPUT ) then 
    KANTOUTPUT := "/tmp/"; 
fi;

if not IsBound( ALNUTHPATH ) then 
    if CompareVersionNumbers( VERSION, "4.4" ) then
        ALNUTHPATH := PackageInfo("alnuth")[1].InstallationPath;
    else
        ALNUTHPATH := LOADED_PACKAGES.alnuth[1]![1];
        ReadPkg( "alnuth/gap/compat.g" );
    fi;
    ALNUTHPATH := Concatenation( ALNUTHPATH, "/lib/" );
fi;

if not IsBound( PRIM_TEST )  then   
    PRIM_TEST := 20;
fi; 

#############################################################################
##
#R read files
##
ReadPkg("alnuth/defs.g");

ReadPkg("alnuth/gap/factors.gi");
ReadPkg("alnuth/gap/kantin.gi");
ReadPkg("alnuth/gap/matfield.gi");
ReadPkg("alnuth/gap/polfield.gi");
ReadPkg("alnuth/gap/field.gi");
ReadPkg("alnuth/gap/unithom.gi");
ReadPkg("alnuth/gap/matunits.gi");
ReadPkg("alnuth/gap/rels.gi");
ReadPkg("alnuth/gap/present.gi");
ReadPkg("alnuth/gap/isom.gi");
ReadPkg("alnuth/gap/rationals.gi");

ReadPkg("alnuth/exam/unimod.gi");
ReadPkg("alnuth/exam/rationals.gi");
ReadPkg("alnuth/exam/fields.gi");
