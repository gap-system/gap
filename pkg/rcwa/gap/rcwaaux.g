#############################################################################
##
#W  rcwaaux.g                 GAP4 Package `RCWA'                 Stefan Kohl
##
#H  @(#)$Id: rcwaaux.g,v 1.26 2008/06/23 14:14:43 stefan Exp $
##
##  This file contains auxiliary functions for the RCWA package.
##
Revision.rcwaaux_g :=
  "@(#)$Id: rcwaaux.g,v 1.26 2008/06/23 14:14:43 stefan Exp $";

#############################################################################
##
#F  RCWABuildManual( ) . . . . . . . . . . . . . . . . . . . build the manual
##
##  This function builds the manual of the RCWA package in the file formats
##  LaTeX, PDF, HTML and ASCII-text.
##
##  This is done using the GAPDoc package by Frank Lübeck and Max Neunhöffer.
##
BindGlobal( "RCWABuildManual", 

  function ( )

    local  RCWADir;

    RCWADir := GAPInfo.PackagesInfo.("rcwa")[1].InstallationPath;
    MakeGAPDocDoc( Concatenation( RCWADir, "/doc/" ), "rcwa.xml",
                   [ "../gap/rcwaaux.g",
                     "../gap/rcwamap.gd", "../gap/rcwamap.gi",
                     "../gap/rcwagrp.gd", "../gap/rcwagrp.gi" ],
                     "RCWA", "../../../" );
  end );

#############################################################################
##
#F  RCWATest( [ <test1> [, <test2> [, ... ]]] ) . . . . . . . read test files
##
##  Performs tests of the RCWA package.
##
##  The function makes use of an adaptation of the test file tst/testall.g
##  of the GAP Library to this package. 
##
BindGlobal( "RCWATest",

  function ( )

    local  RCWADir, dir;

    RCWADir := GAPInfo.PackagesInfo.("rcwa")[1].InstallationPath;
    dir := Concatenation( RCWADir, "/tst/" );
    Read( Concatenation( dir, "testall.g" ) );
  end );

#############################################################################
##
#F  RCWADoThingsToBeDoneBeforeTest(  )
#F  RCWADoThingsToBeDoneAfterTest(  )
##
BindGlobal( "RCWADoThingsToBeDoneBeforeTest",

  function (  )
    RESCLASSES_WARNINGLEVEL_BUFFER := InfoLevel(InfoWarning);;
    SetInfoLevel(InfoWarning,0);
    RESCLASSES_VIEWINGFORMAT_BUFFER := RESCLASSES_VIEWINGFORMAT;;
    ResidueClassUnionViewingFormat("short");
    CallFuncList(HideGlobalVariables,ONE_LETTER_GLOBALS);
  end );

BindGlobal( "RCWADoThingsToBeDoneAfterTest",

  function (  )
    CallFuncList(UnhideGlobalVariables,ONE_LETTER_GLOBALS);
    ResidueClassUnionViewingFormat(RESCLASSES_VIEWINGFORMAT_BUFFER);
    SetInfoLevel(InfoWarning,RESCLASSES_WARNINGLEVEL_BUFFER);
  end );

#############################################################################
##
#F  RCWAReadExamples( ) . . . . . . . . . . . . . . . . .  read examples file
##
BindGlobal( "RCWAReadExamples", function ( )
                                  ReadPackage("rcwa","examples/examples.g");
                                end );

#############################################################################
##
#F  RCWAReadCTProductClassification( ) . . . . .  read examples/ctprodclass.g
##
BindGlobal( "RCWAReadCTProductClassification",
            function ( )
              ReadPackage("rcwa","examples/ctprodclass.g");
            end );

ResidueClassUnionViewingFormat( "short" );

#############################################################################
##
#E  rcwaaux.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here