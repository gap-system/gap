#############################################################################
##
#W  testbugfix.g              GAP library                    Markus Pfeiffer
##
##
#Y  Copyright (C) 2015, The GAP Group
##
##  This file lists those files in the directory <F>tst</F> of the &GAP;
##  distribution that are recommended to be read after a &GAP; installation.
##
##  Each entry in the argument list of <C>RunStandardTests</C> is a pair that
##  consists of the filename (relative to the <F>tst</F> directory) and the
##  scaling factor that occurs in the <C>STOP_TEST</C> call at the end of the
##  test file.
##  <P/>
##  The documentation states the following:
##  <P/>
##  <#GAPDoc Label="[1]{testbugfix.g}">
##  If you want to run a more advanced check (this is not required and 
##  make take up to an hour), you can read <File>testall.g</File>
##  which is an extended test script performing all tests from the 
##  <File>tst</File> directory.
##  <P/>
##  <Log><![CDATA[
##  gap> Read( Filename( DirectoriesLibrary( "tst" ), "testbugfix.g" ) );
##  ]]></Log>
##  <P/>
##  <#/GAPDoc>
##

Print( "You should start GAP4 using `gap -A -x 80 -r -m 100m -o 750m'.\n",
       "The more GAP4stones you get, the faster your system is.\n",
       "The runtime of the following tests (in general) increases.\n",
       "******************************************************************\n",
       "You should expect the test to take about *ONE HOUR* and show about\n",
       "125000 GAP4stones on an Intel Core 2 Duo / 2.53 GHz machine.\n",
       "For a quick test taking about one minute, use 'testinstall.g'\n",
       "******************************************************************\n",
       "The `next' time is an approximation of the running time ",
       "for the next file.\n\n" );

Reread( Filename( DirectoriesLibrary( "tst" ), "testutil.g" ) );

TestDirectory( [ Filename( DirectoriesLibrary( "tst" ), "teststandard/bugfix.tst") ] ,
               rec(exitGAP := true) );

# Should never get here
FORCE_QUIT_GAP(1);

#############################################################################
##
#E

