#############################################################################
##
#W    init.g             share package                          Karel Dekimpe
#W                                                               Bettina Eick
##

# SetInfoLevel( InfoWarning, 0 );

# announce the package version and test for the existence of the binary
DeclarePackage( "aclib","1.0", ReturnTrue );

# install the documentation
DeclarePackageAutoDocumentation( "aclib", "doc" );

# require other packages
pc := RequirePackage( "polycyclic" );
cs := RequirePackage( "crystcat" );

# read .gd files
ReadPkg( "aclib", "gap/groups.gd" );

