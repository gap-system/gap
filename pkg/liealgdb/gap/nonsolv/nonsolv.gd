DeclareOperation( "NonSolvableLieAlgebra", 
			[ IsField and IsFinite, IsList ] );

DeclareOperation( "AllSimpleLieAlgebras", 
[ IsField and IsFinite, IsPosInt ] );

DeclareCategory( "IsLieAlgDBCollection_NonSolvable", IsLieAlgDBCollection );

IsLieAlgDBParListIteratorDimension6Characteristic3CompRep := 
  NewRepresentation( "IsLieAlgDBParListIteratorDimension6Characteristic3CompRep",
          IsComponentObjectRep, [ "counter", "param", "dim", "field" ] );

DeclareGlobalFunction( "LieAlgDBParListIteratorDimension6Characteristic3" );

DeclareOperation( "AllNonSolvableLieAlgebras", 
			[ IsField and IsFinite, IsPosInt ] );

DeclareGlobalFunction( "ExtensionOfsl2BySoluble" );
DeclareGlobalFunction( "ExtensionOfW121BySoluble" );
DeclareGlobalFunction( "ExtensionOfW12ByAbelian" );
DeclareGlobalFunction( "ExtensionOfsl2ByV2a" );

