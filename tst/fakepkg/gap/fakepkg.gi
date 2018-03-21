#
# fakepkg: A fake package for use by the GAP test suite
#
# Implementations
#
InstallGlobalFunction( fakepkg_GlobalFunction,
function()
	Print( "This is a placeholder function, replace it with your own code.\n" );
end );

InstallMethod( fakepkg_Operation, [ IsGroup, IsPosInt ], { G, n } -> n );

InstallMethod( fakepkg_Attribute, [ IsSolvableGroup ], G -> G );

InstallMethod( fakepkg_Property, [ IsNilpotentGroup ], IsAbelian );
