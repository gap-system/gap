#############################################################################
##
#W    init.g               Gap package `slal'
##
##

# Announce the package version 

DeclarePackage("slal", "0.0", true);


# Read the files...

# Small Lie algebras
ReadPkg( "singular", "gap/lietabs.g" );
ReadPkg( "singular", "gap/mpgong.g" );
ReadPkg( "singular", "gap/mm.g" );
ReadPkg( "singular", "gap/isola.g" );
ReadPkg( "singular", "gap/sla.g" );



# install the documentation
#DeclarePackageAutoDocumentation( "slal", "doc" );


DeclareInfoClass( "InfoSlal" );
# InfoLevel( InfoSlal );
SetInfoLevel( InfoSlal, 1);

