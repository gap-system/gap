#############################################################################
##
#W  testtravis.g               GAP library                   Markus Pfeiffer
##
##
#Y  Copyright (C) 2015, The GAP Group
##
##  This file runs a selection of tests from 'tst/testinstall' and
##  'tst/teststandard' directories of the GAP distribution. This
##  selection omits some longer tests from 'tst/teststandard' to
##  match Travis CI resource limits. To run it, use this command:
##
##  gap> Read( Filename( DirectoriesLibrary( "tst" ), "testtravis.g" ) );
##

Print( "You should start GAP4 using `gap -A -x 80 -r -m 100m -o 1g -K 2g'.\n\n" );

TestDirectory( [
  Filename( DirectoriesLibrary( "tst" ), "teststandard" ),
  Filename( DirectoriesLibrary( "tst" ), "testinstall" )],
  rec(exitGAP := true) );
  
# Should never get here
FORCE_QUIT_GAP(1);

#############################################################################
##
#E
