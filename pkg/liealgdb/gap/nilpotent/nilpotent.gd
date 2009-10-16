_liealgdb_nilpotent_d6f2 := [];
_liealgdb_nilpotent_d7f2 := [];
_liealgdb_nilpotent_d8f2 := [];
_liealgdb_nilpotent_d9f2 := [];
_liealgdb_nilpotent_d7f3 := [];
_liealgdb_nilpotent_d7f5 := [];

DeclareOperation( "NrNilpotentLieAlgebras", 
		[ IsField and IsFinite, IsPosInt ] );

DeclareOperation( "AllNilpotentLieAlgebras", 
        [ IsField and IsFinite, IsPosInt ] );

DeclareCategory( "IsLieAlgDBCollection_Nilpotent", IsLieAlgDBCollection );

