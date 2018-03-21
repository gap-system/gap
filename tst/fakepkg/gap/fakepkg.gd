#
# fakepkg: A fake package for use by the GAP test suite
#
# Declarations
#

DeclareGlobalFunction( "fakepkg_GlobalFunction" );
DeclareOperation( "fakepkg_Operation", [ IsObject, IsInt ] );
DeclareAttribute( "fakepkg_Attribute", IsGroup );
DeclareProperty( "fakepkg_Property", IsGroup );
