#############################################################################
##
#W  testtravis.g               GAP library                   Markus Pfeiffer
##
##
#Y  Copyright (C) 2015, The GAP Group
##
##  This file is similar to teststandard.g, but skips the 'tst/testextra'
##  tests, which are very slow. To run it, use this command:
##
##  gap> Read( Filename( DirectoriesLibrary( "tst" ), "testtravis.g" ) );
##

Print( "You should start GAP4 using `gap -A -x 80 -r -m 100m -o 1g -K 2g'.\n\n" );

bits := String(8*GAPInfo.BytesPerVariable);
TestDirectory( [
  DirectoriesLibrary( "tst/teststandard" ),
  DirectoriesLibrary( "tst/testinstall" ),
  DirectoriesLibrary( Concatenation("tst/test", bits, "bit"))
  ], rec(exitGAP := true) );
  
# Should never get here
FORCE_QUIT_GAP(1);

#############################################################################
##
#E
