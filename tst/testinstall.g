#############################################################################
##
#W  testinstall.g               GAP library                      Frank Celler
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  This file runs all tests from the directory 'tst/testinstall' of the
##  GAP distribution. It is recommented to read it after GAP installation.
##
##  The documentation states the following:
##
##  <#GAPDoc Label="[1]{testinstall.g}">
##  If you want to run a quick test of your &GAP; installation 
##  (though this is not required), you can read in a test script 
##  that exercises some &GAP;'s capabilities.
##  <P/>
##  <Log><![CDATA[
##  gap> Read( Filename( DirectoriesLibrary( "tst" ), "testinstall.g" ) );
##  ]]></Log>
##  <P/>
##  <#/GAPDoc>
##

Print( "You should start GAP4 using `gap -A -x 80 -r -m 100m -o 1g -K 2g'.\n\n" );

TestDirectory( [ DirectoriesLibrary( "tst/testinstall" ) ],
               rec(exitGAP := true) );
  
# Should never get here
FORCE_QUIT_GAP(1);

#############################################################################
##
#E
