#############################################################################
##
#W  quick.g
##

TestDirectory( Filename( DirectoriesLibrary( "tst" ), "core/quick" ),
               rec(exitGAP := true) );
  
# Should never get here
FORCE_QUIT_GAP(1);


#############################################################################
##
#E

