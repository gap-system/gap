#
# Try to load its kernel extension
#
gap> LoadPackage("mockpkg");
true
gap> IsKernelExtensionAvailable("mockpkg");
true
gap> LoadKernelExtension("mockpkg");
true
gap> TestCommand();
true
