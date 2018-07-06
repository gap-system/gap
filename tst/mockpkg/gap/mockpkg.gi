#
# mockpkg: A mock package for use by the GAP test suite
#
# Implementations
#
InstallGlobalFunction( mockpkg_GlobalFunction,
function()
	Print( "This is a placeholder function, replace it with your own code.\n" );
end );

InstallMethod( mockpkg_Operation, [ IsGroup, IsPosInt ], { G, n } -> n );

InstallMethod( mockpkg_Attribute, [ IsSolvableGroup ], G -> G );

InstallMethod( mockpkg_Property, [ IsNilpotentGroup ], IsAbelian );
