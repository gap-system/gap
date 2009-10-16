#############################################################################
##
#W  testall.g              GAP 4 package `atlasrep'             Thomas Breuer
##
#H  @(#)$Id: testall.g,v 1.7 2007/02/28 17:33:57 gap Exp $
##
#Y  Copyright (C)  2002,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

LoadPackage( "atlasrep" );

dirs:= DirectoriesPackageLibrary( "atlasrep", "tst" );

# Make sure that the component is bound to either `true' or `false'.
if not IsBound( CMeatAxe.FastRead ) or CMeatAxe.FastRead <> true then
  CMeatAxe.FastRead:= false;
fi;

# Run the standard tests with this value.
ReadTest( Filename( dirs, "docxpl.tst" ) );
ReadTest( Filename( dirs, "atlasrep.tst" ) );

# Now run the tests with the other value.
CMeatAxe.FastRead:= not CMeatAxe.FastRead;
ReadTest( Filename( dirs, "docxpl.tst" ) );
ReadTest( Filename( dirs, "atlasrep.tst" ) );

# Reset the value.
CMeatAxe.FastRead:= not CMeatAxe.FastRead;


#############################################################################
##
#E

