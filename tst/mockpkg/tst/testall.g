#
# mockpkg: A mock package for use by the GAP test suite
#
# This file runs package tests. It is also referenced in the package
# metadata in PackageInfo.g.
#
LoadPackage( "mockpkg" );

TestDirectory(DirectoriesPackageLibrary( "mockpkg", "tst" ),
  rec(exitGAP := true));

ForceQuitGap(1); # if we ever get here, there was an error
