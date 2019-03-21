#############################################################################
##
##  This file runs all tests from 'tst/testinstall' and 'tst/teststandard'
##  directories of the GAP distribution.
##
##  <#GAPDoc Label="[1]{teststandard.g}">
##  If you want to run a more advanced check (this is not required and 
##  make take up to an hour), you can read <File>teststandard.g</File>
##  which is an extended test script performing all tests from the 
##  <File>tst</File> directory.
##  <P/>
##  <Log><![CDATA[
##  gap> Read( Filename( DirectoriesLibrary( "tst" ), "teststandard.g" ) );
##  ]]></Log>
##  <P/>
##  <#/GAPDoc>
##

Print( "You should start GAP4 using `gap -A -x 80 -r -m 100m -o 1g -K 2g'.\n\n" );

dirs := [
  DirectoriesLibrary( "tst/teststandard" ),
  DirectoriesLibrary( "tst/testinstall" ),
];
TestDirectory( dirs, rec(exitGAP := true) );
  
# Should never get here
FORCE_QUIT_GAP(1);
