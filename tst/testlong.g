#############################################################################
##
#W  testlong.g
##
##  This file runs all tests from the directory 'tst/testlong' of the
##  GAP distribution. It might take a very long time and potentially uses
##  a lot of memory
##

Print( "You should start GAP4 using `gap -A -x 80 -r -m 100m -o 32g'.\n",
       "The more GAP4stones you get, the faster your system is.\n",
       "\n" );

TestDirectory( Filename( DirectoriesLibrary( "tst" ), "long" ),
               rec(exitGAP := true) );
  
# Should never get here
FORCE_QUIT_GAP(1);


#############################################################################
##
#E

