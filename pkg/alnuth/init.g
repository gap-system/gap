#############################################################################
##
#W    init.g       Alnuth -  Kant interface                      Bettina Eick
##

DeclarePackage( "alnuth", "2.2.5", function() return true; end );
DeclarePackageDocumentation( "alnuth", "doc" );

#############################################################################
##
#R  read .gd files
##
ReadPkg("alnuth/gap/factors.gd");
ReadPkg("alnuth/gap/field.gd");
ReadPkg("alnuth/gap/kantin.gd");

#############################################################################
##
#R  read other packages
##
RequirePackage("polycyclic");

