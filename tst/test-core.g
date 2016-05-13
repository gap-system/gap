#############################################################################
##
#W  test-core.g
##

TestDirectory( Filename( DirectoriesLibrary( "tst" ), "core" ),
               rec(exitGAP := true) );
  
# Should never get here
FORCE_QUIT_GAP(1);


#############################################################################
##
#E

