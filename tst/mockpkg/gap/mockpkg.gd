#
# mockpkg: A mock package for use by the GAP test suite
#
# Declarations
#

DeclareGlobalFunction( "mockpkg_GlobalFunction" );
DeclareOperation( "mockpkg_Operation", [ IsObject, IsInt ] );
DeclareAttribute( "mockpkg_Attribute", IsGroup );
DeclareProperty( "mockpkg_Property", IsGroup );
