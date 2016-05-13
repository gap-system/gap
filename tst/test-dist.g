#############################################################################
##
#W  test-dist-quick.g
##

TestDirectory( Filename( DirectoriesLibrary( "tst" ), "dist" ),
               rec(exitGAP := true) );
  
# Should never get here
FORCE_QUIT_GAP(1);


#############################################################################
##
#E

