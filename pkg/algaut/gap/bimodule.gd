DeclareCategory( "IsAlgebraBimodule", IsObject );

DeclareRepresentation( "IsAlgebraBimoduleRep",
        IsComponentObjectRep,
        ["actingalgebra", "bimodule", "leftaction", "rightaction"] );

DeclareGlobalFunction( "AlgebraBimodule" );
DeclareGlobalFunction( "AlgebraBimoduleByIdeals" );

DeclareAttribute( "Bimodule", IsAlgebraBimodule );
DeclareAttribute( "AActingAlgebra", IsAlgebraBimodule );
DeclareAttribute( "LLeftAction", IsAlgebraBimodule );
DeclareAttribute( "RRightAction", IsAlgebraBimodule );
