#############################################################################
##
#W  read.g          Alnuth - ALgebraic NUmber THeory           Bettina Eick
##                                                          Andreas Distler
##
##  The files with GAP code are read here and global variables are defined.
##  Note that in Alnuth we cannot do this in completely arbitrary order.
##  Globals used in code should be known to avoid warnings.
##    

#############################################################################
##
#R alnuth global variables
##

# the directory path to the code files for the external program
if not IsBound( AL_PATH ) then 
    BindGlobal( "AL_PATH", DirectoriesPackageLibrary("alnuth", "gp"));
fi;

# options for execution of the external program
if not IsBound( AL_OPTIONS ) then
    BindGlobal( "AL_OPTIONS", ["-f", "-q"] );
fi;

# extra option to specify stack size for execution of PARI/GP
if not IsBound( AL_STACKSIZE ) then
    BindGlobal( "AL_STACKSIZE", "-s128M" );
fi;

# number of trials to find a primitve element with small minimal polynomial
if not IsBound( PRIM_TEST )  then   
    PRIM_TEST := 20;
fi; 

#############################################################################
##
#R read files
##
ReadPackage("alnuth", "defs.g");

ReadPackage("alnuth", "gap/setup.gi");
ReadPackage("alnuth", "gap/factors.gi");
ReadPackage("alnuth", "gap/kantin.gi");
ReadPackage("alnuth", "gap/matfield.gi");
ReadPackage("alnuth", "gap/polfield.gi");
ReadPackage("alnuth", "gap/field.gi");
ReadPackage("alnuth", "gap/unithom.gi");
ReadPackage("alnuth", "gap/matunits.gi");
ReadPackage("alnuth", "gap/rels.gi");
ReadPackage("alnuth", "gap/present.gi");
ReadPackage("alnuth", "gap/isom.gi");
ReadPackage("alnuth", "gap/rationals.gi");

ReadPackage("alnuth", "exam/unimod.gi");
ReadPackage("alnuth", "exam/rationals.gi");
ReadPackage("alnuth", "exam/fields.gi");

#############################################################################
##
#E
