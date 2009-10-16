#############################################################################
##
#W    init.g                 The vecenume package               Steve Linton
##
##    @(#)$Id: init.g,v 1.1 2002/08/26 09:34:50 sal Exp $
##

# announce the package version and test for the existence of the binary
DeclarePackage("vecenum","0.1",ReturnTrue);

# install the documentation
DeclarePackageAutoDocumentation( "vecenum", "doc" );

if BANNER and not QUIET then
  ReadPkg("vecenum", "gap/banner.g");
fi;
# read the function declarations
ReadPkg("vecenum","gap/vecenum.gd");

