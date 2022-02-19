#
# mockpkg: A mock package for use by the GAP test suite
#
# Reading the declaration part of the package.
#

#if not LoadKernelExtension("mockpkg") then
#  Error("could not load 'mockpkg' kernel extension")
#fi;

ReadPackage( "mockpkg", "gap/mockpkg.gd");
