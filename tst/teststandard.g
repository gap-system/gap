#############################################################################
##
#W  testall.g                   GAP library                      Frank Celler
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
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
##  The test requires up to 1 GB of memory and runs about one hour on an
##  Intel Core 2 Duo / 2.53 GHz machine, and produces an output similar 
##  to the <File>testinstall.g</File> test.
##  <#/GAPDoc>
##

Print( "You should start GAP4 using `gap -A -x 80 -r -m 100m -o 1g'.\n",
       "The more GAP4stones you get, the faster your system is.\n",
       "The runtime of the following tests (in general) increases.\n",
       "******************************************************************\n",
       "You should expect the test to take about *ONE HOUR* and show about\n",
       "125000 GAP4stones on an Intel Core 2 Duo / 2.53 GHz machine.\n",
       "For a quick test taking about one minute, use 'testinstall.g'\n",
       "******************************************************************\n",
       "The `next' time is an approximation of the running time ",
       "for the next file.\n\n" );

TestDirectory( [
  Filename( DirectoriesLibrary( "tst" ), "teststandard" ),
  Filename( DirectoriesLibrary( "tst" ), "testinstall" )],
  rec( exitGAP := true,
       testOptions := rec(compareFunction := "uptowhitespace") ) );
  
# Should never get here
FORCE_QUIT_GAP(1);

#############################################################################
##
#E

