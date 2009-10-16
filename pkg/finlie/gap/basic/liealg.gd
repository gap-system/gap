
##
## Attributes
##
DeclareAttribute( "CBS", IsLieAlgebra );
DeclareAttribute( "Table", IsLieAlgebra );
DeclareAttribute( "DepthLVector", IsObject );
DeclareAttribute( "LengthLVector", IsObject );
DeclareAttribute( "CanonicalFormOfLieAlgebra", IsLieAlgebra );

##
## Global Functions
##
DeclareGlobalFunction("InnerDerivations");
DeclareGlobalFunction("CanonicalFormOfSpecialTable");
DeclareGlobalFunction("CanonicalFormOfSolvableLieAlgebra");
DeclareGlobalFunction("IsomorphismOfLieAlgebras");
DeclareGlobalFunction("AreIsomorphicLieAlgebras");
DeclareGlobalFunction("AutomorphismGroupOfLieAlgebra");
DeclareGlobalFunction("AutomorphismGroupOfSolvableLieAlgebraBySpecial");
DeclareGlobalFunction("AutomorphismGroupOfSolvableLieAlgebraByFitting");
DeclareGlobalFunction("AutomorphismGroupOfSolvableLieAlgebra");
DeclareGlobalFunction("AutomorphismGroupOfLieAlgebraRandom");

##
## Info classes
##
DeclareInfoClass( "InfoLieAut" );

