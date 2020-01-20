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

dirs := [
  DirectoriesLibrary( "tst/teststandard" ),
  DirectoriesLibrary( "tst/testinstall" ),
];
TestDirectory( dirs, rec(exitGAP := true) );
  
# Should never get here
ForceQuitGap(1);
