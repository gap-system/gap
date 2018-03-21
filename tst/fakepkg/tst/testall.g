#
# fakepkg: A fake package for use by the GAP test suite
#
# This file runs package tests. It is also referenced in the package
# metadata in PackageInfo.g.
#
LoadPackage( "fakepkg" );

TestDirectory(DirectoriesPackageLibrary( "fakepkg", "tst" ),
  rec(exitGAP := true));

FORCE_QUIT_GAP(1); # if we ever get here, there was an error
