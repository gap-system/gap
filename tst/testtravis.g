#############################################################################
##
#W  testtravis.g               GAP library                   Markus Pfeiffer
##
##
#Y  Copyright (C) 2015, The GAP Group
##
##  This file is similar to teststandard.g, but skips the 'tst/testinstall'
##  tests, which are run by a separate Travis job; this help us match Travis
##  CI resource limits. To run it, use this command:
##
##  gap> Read( Filename( DirectoriesLibrary( "tst" ), "testtravis.g" ) );
##

Print( "You should start GAP4 using `gap -A -x 80 -r -m 100m -o 1g -K 2g'.\n\n" );

TestDirectory( [
  Filename( DirectoriesLibrary( "tst" ), "teststandard" ),
  Filename( DirectoriesLibrary( "tst" ),
       Concatenation("test", String(8*GAPInfo.BytesPerVariable), "bit"))],
  rec(exitGAP := true) );
  
# Should never get here
FORCE_QUIT_GAP(1);

#############################################################################
##
#E
