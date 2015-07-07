#############################################################################
##
#W  testinstall.g               GAP library                      Frank Celler
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  This file lists those files in the directory <F>tst/testinstall</F> of
##  the &GAP; distribution, which are recommended to be read after a &GAP;
##  installation.
##
##  <P/>
##  The documentation states the following:
##  <P/>
##  <#GAPDoc Label="[1]{testinstall.g}">
##  If you want to run a quick test of your &GAP; installation 
##  (though this is not required), you can read in a test script 
##  that exercises some &GAP;'s capabilities.
##  <P/>
##  <Log><![CDATA[
##  gap> Read( Filename( DirectoriesLibrary( "tst" ), "testinstall.g" ) );
##  ]]></Log>
##  <P/>
##  The test requires about 750MB of memory and runs about one 
##  minute on an Intel Core 2 Duo / 2.53 GHz machine.
##  You will get a large number of lines with output about the progress
##  of the tests.
##  <#/GAPDoc>
##

Print( "You should start GAP4 using `gap -A -x 80 -r -m 100m -o 750m'.\n",
       "The more GAP4stones you get, the faster your system is.\n",
       "The runtime of the following tests (in general) increases.\n",
       "You should expect the test to take about one minute and show about\n",
       "100000 GAP4stones on an Intel Core 2 Duo / 2.53 GHz machine.\n",
       "The `next' time is an approximation of the running time ",
       "for the next file.\n\n" );

Reread( Filename( DirectoriesLibrary( "tst" ), "testutil.g" ) );

TestDirectory( Filename( DirectoriesLibrary( "tst" ), "testinstall" ),
               rec(exitGAP := true) );
  
# Should never get here
FORCE_QUIT_GAP(1);


#############################################################################
##
#E

