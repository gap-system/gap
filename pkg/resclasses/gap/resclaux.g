#############################################################################
##
#W  resclaux.g             GAP4 Package `ResClasses'              Stefan Kohl
##
#H  @(#)$Id: resclaux.g,v 1.21 2008/04/15 12:33:45 stefan Exp $
##
##  This file contains some auxiliary functions for the ResClasses package.
##
Revision.resclaux_g :=
  "@(#)$Id: resclaux.g,v 1.21 2008/04/15 12:33:45 stefan Exp $";

BindGlobal( "RESCLASSES_VIEWINGFORMAT", "long" );
RESCLASSES_VIEWINGFORMAT_BUFFER := RESCLASSES_VIEWINGFORMAT;
RESCLASSES_WARNINGLEVEL_BUFFER := InfoLevel( InfoWarning );

#############################################################################
##
#F  ResidueClassUnionViewingFormat( format ) . short <--> long viewing format
##
BindGlobal( "ResidueClassUnionViewingFormat",

  function ( format )

    if   not format in [ "short", "long" ]
    then Error( "viewing formats other than \"short\" and \"long\" ",
                "are not supported.\n");
    fi;
    MakeReadWriteGlobal( "RESCLASSES_VIEWINGFORMAT" );
    RESCLASSES_VIEWINGFORMAT := format;
    MakeReadOnlyGlobal( "RESCLASSES_VIEWINGFORMAT" );
  end );

#############################################################################
##
#F  ResClassesBuildManual( ) . . . . . . . . . . . . . . . . build the manual
##
##  This function builds the manual of the ResClasses package in the file
##  formats &LaTeX;, DVI, Postscript, PDF and HTML.
##
##  This is done using the GAPDoc package by Frank L\"ubeck and
##  Max Neunh\"offer.
##
BindGlobal( "ResClassesBuildManual",

  function ( )

    local  ResClassesDir;

    ResClassesDir := GAPInfo.PackagesInfo.("resclasses")[1].InstallationPath;
    MakeGAPDocDoc( Concatenation( ResClassesDir, "/doc/" ), "resclasses.xml",
                   [ "../gap/resclaux.g", "../gap/z_pi.gd", "../gap/z_pi.gi",
                     "../gap/resclass.gd", "../gap/resclass.gi" ],
                     "ResClasses", "../../../" );
  end );

#############################################################################
##
#F  ResClassesTest(  ) . . . . . . . . . . . . . . . . . . .  read test files
##
##  Performs tests of the ResClasses package.
##
##  This function makes use of an adaptation of the test file `tst/testall.g'
##  of the {\GAP}-library to this package. 
##
BindGlobal( "ResClassesTest",

  function (  )

    local  ResClassesDir, dir;

    ResClassesDir := GAPInfo.PackagesInfo.("resclasses")[1].InstallationPath;
    dir := Concatenation( ResClassesDir, "/tst/" );
    Read( Concatenation( dir, "testall.g" ) );
  end );

#############################################################################
##
#F  ResClassesDoThingsToBeDoneBeforeTest(  )
#F  ResClassesDoThingsToBeDoneAfterTest(  )
##
BindGlobal( "ResClassesDoThingsToBeDoneBeforeTest",

  function (  )
    RESCLASSES_WARNINGLEVEL_BUFFER := InfoLevel(InfoWarning);;
    SetInfoLevel(InfoWarning,0);
    RESCLASSES_VIEWINGFORMAT_BUFFER := RESCLASSES_VIEWINGFORMAT;;
    ResidueClassUnionViewingFormat("long");
    CallFuncList(HideGlobalVariables,ONE_LETTER_GLOBALS);
  end );

BindGlobal( "ResClassesDoThingsToBeDoneAfterTest",

  function (  )
    CallFuncList(UnhideGlobalVariables,ONE_LETTER_GLOBALS);
    ResidueClassUnionViewingFormat(RESCLASSES_VIEWINGFORMAT_BUFFER);
    SetInfoLevel(InfoWarning,RESCLASSES_WARNINGLEVEL_BUFFER);
  end );

#############################################################################
##
#E  resclaux.g . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here