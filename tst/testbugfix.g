#############################################################################
##
#W  testbugfix.g              GAP library                    Markus Pfeiffer
##
##
#Y  Copyright (C) 2015, The GAP Group
##
##  This file runs the tst/teststandard/bugfix.tst test from the
##  'tst/teststandard' directory of the GAP distribution. To run it, use this:
##
##  gap> Read( Filename( DirectoriesLibrary( "tst" ), "testbugfix.g" ) );
##

Print( "You should start GAP4 using `gap -A -x 80 -r -m 100m -o 1g -K 2g'.\n",
       "The more GAP4stones you get, the faster your system is.\n",
       "The runtime of the following tests (in general) increases.\n",
       "******************************************************************\n",
       "You should expect the test to take about five minutes and show about\n",
       "125000 GAP4stones on an Intel Core 2 Duo / 2.53 GHz machine.\n",
       "For a quick test taking about one minute, use 'testinstall.g'\n",
       "******************************************************************\n",
       "The `next' time is an approximation of the running time ",
       "for the next file.\n\n" );

TestDirectory( [ Filename( DirectoriesLibrary( "tst" ), "teststandard/bugfix.tst") ] ,
               rec(exitGAP := true) );

# Should never get here
FORCE_QUIT_GAP(1);

#############################################################################
##
#E

