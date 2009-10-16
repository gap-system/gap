############################################################################
##
#W  testall.gi  		The NQL-package			 René Hartung
##
##   @(#)$Id: testall.gi,v 1.1 2008/08/28 07:44:41 gap Exp $
##

LoadPackage("NQL");
dir := DirectoriesPackageLibrary( "NQL", "tst" );

# examples from the manual
ReadTest( Filename( dir, "manual.tst" ) );

# results for self-similar groups from ExamplesOfLPresentations
ReadTest( Filename( dir, "res.tst" ) );
