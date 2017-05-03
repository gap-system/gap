#############################################################################
##
#X  Now read the implementation parts from the library.
##

ReadOrComplete( "lib/read5.g" );
ReadOrComplete( "lib/read6.g" );

ReadOrComplete( "lib/read7.g" ); # character theory stuff
ReadOrComplete( "lib/read8.g" ); # overloaded operations, compiler interface
ReadLib( "colorprompt.g"  );


#############################################################################
##
##  Load data libraries
##  The data libraries which may be absent cannot be completed, therefore
##  they must be read in here!

#############################################################################
##
#X  Read library of groups of small order
#X  Read identification routine
##
if TestPackageAvailability("smallgrp")=fail then
  ReadSmall( "readsml.g","small groups" );
fi;

#############################################################################
##
#X  Read transitive groups library
##

# first assign TransitiveGroupsAvailable to a dummy function to make it
# callable, even if the library is unavailable.
InstallGlobalFunction(TransitiveGroupsAvailable,deg->false);

TRANS_AVAILABLE:=ReadTrans( "trans.gd","transitive groups" );
TRANS_AVAILABLE:= TRANS_AVAILABLE and ReadTrans( "trans.grp",
                                        "transitive groups" );
TRANS_AVAILABLE:= TRANS_AVAILABLE and ReadTrans( "trans.gi",
                                        "transitive groups" );

if TRANS_AVAILABLE then
  ReadLib("galois.gd"); # the Galois group identification relies on the list
                        # of transitive groups
  ReadLib("galois.gi");
fi;

#############################################################################
##
#X  Read primitive groups library
##

# first assign PrimitiveGroupsAvailable to a dummy function to make it
# callable, even if the library is unavailable.
InstallGlobalFunction(PrimitiveGroupsAvailable,deg->false);

# only load component if not available as package
if TestPackageAvailability("primgrp")=fail then
  PRIM_AVAILABLE:=ReadPrim( "primitiv.gd","primitive groups" );
  PRIM_AVAILABLE:=PRIM_AVAILABLE and ReadPrim( "irredsol.gd","irreducible solvable groups" );
  PRIM_AVAILABLE:=PRIM_AVAILABLE and ReadPrim( "primitiv.grp",
                                       "primitive groups" );
  PRIM_AVAILABLE:=PRIM_AVAILABLE and ReadPrim( "primitiv.gi",
                                       "primitive groups" );

  PRIM_AVAILABLE:=PRIM_AVAILABLE and ReadPrim( "irredsol.grp",
                                       "irreducible solvable groups" );
  PRIM_AVAILABLE:=PRIM_AVAILABLE and ReadPrim( "irredsol.gi",
                                       "irreducible solvable groups" );
  PRIM_AVAILABLE:=PRIM_AVAILABLE and ReadPrim( "cohorts.grp",
                                       "irreducible solvable groups" );
fi;

#############################################################################
##
#E

