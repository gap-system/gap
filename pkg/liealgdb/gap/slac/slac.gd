DeclareAttribute( "LieAlgebraIdentification", IsLieAlgebra );

DeclareOperation( "AllSolvableLieAlgebras", 
                           [ IsField and IsFinite, IsPosInt ] );

DeclareOperation( "SolvableLieAlgebra", 
                           [ IsField, IsList ] );

DeclareOperation( "NilpotentLieAlgebra", 
                           [ IsField, IsList ] );

DeclareCategory( "IsLieAlgDBCollection_Solvable", IsLieAlgDBCollection );