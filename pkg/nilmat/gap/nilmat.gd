
DeclareInfoClass( "InfoNilMat" );

##
## Attributes and Properties
##
DeclareAttribute( "JordanSplitting", IsGroup );
DeclareAttribute( "PiPrimarySplitting", IsGroup ); 
DeclareProperty( "IsUnipotentMatGroup", IsGroup );

## 
## Global Functions
##
DeclareGlobalFunction( "ClassLimit" );
DeclareGlobalFunction( "AbelianNormalSeries" );
DeclareGlobalFunction( "IsNilpotentMatGroup" );
DeclareGlobalFunction( "IsFiniteNilpotentMatGroup" );
DeclareGlobalFunction( "SizeOfNilpotentMatGroup" );
DeclareGlobalFunction( "IsCompletelyReducibleNilpotentMatGroup" );
DeclareGlobalFunction( "SylowSubgroupsOfNilpotentFFMatGroup" );
DeclareGlobalFunction( "NilpotentPrimitiveMatGroups" );
DeclareGlobalFunction( "SizesOfNilpotentPrimitiveMatGroups" );
DeclareGlobalFunction( "MaximalAbsolutelyIrreducibleNilpotentMatGroup" );
DeclareGlobalFunction( "MonomialNilpotentMatGroup" );
DeclareGlobalFunction( "ReducibleNilpotentMatGroup" );

