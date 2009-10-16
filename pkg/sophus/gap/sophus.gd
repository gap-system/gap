#############################################################################
##
#W  sophus.gd                 Sophus package                 Csaba Schneider 
##
#W  Declarations for the Sophus package.
##
#H  $Id: sophus.gd,v 1.5 2004/07/02 09:20:08 gap Exp $

DeclareInfoClass( "LieInfo" );

DeclareRepresentation( "IsNilpotentLieAutomorphismRep",
                       IsAlgebraGeneralMapping,
        ["mingenset", "mingensetimgs", "basis", "basisimgs", 
         "matrix"] );

IsNilpotentLieAutomorphism := IsMapping and IsNilpotentLieAutomorphismRep;

DeclareProperty( "IsLieNilpotentOverFp", IsLieNilpotent );

DeclareAttribute( "AutomorphismGroupOfNilpotentLieAlgebra",
                  IsLieAlgebra );

DescendantsOfStep1OfAbelianLieAlgebra := NewOperation( 
            "DescendantsOfStep1OfAbelianLieAlgebra", [ IsPosInt, IsPosInt ] );

Descendants := NewOperation( 
            "Descendants", [ IsLieAlgebra, IsPosInt ] );

MinimalGeneratorNumber := NewAttribute( "MinimalGeneratorNumber", 
                                  IsLieNilpotent );

LiftAutorphismToLieCover := NewOperation( "LiftAutorphismToLieCover", 
                                     [ IsNilpotentLieAutomorphism ] );

LinearActionOnMultiplicator := NewOperation( "LinearActionOnMultiplicator", 
                                     [ IsNilpotentLieAutomorphism ] );

NilpotentLieAutomorphism := NewOperation( "NilpotentLieAutomorphism", 
                            [ IsLieNilpotentOverFp, IsList, IsList ] );

IsLieCover := NewProperty( "IsLieCover", IsLieNilpotentOverFp );

CoverOf := NewAttribute( "CoverOf", IsLieCover );

CoverHomomorphism := NewAttribute( "CoverHomomorphism", IsLieCover );

LieCover := NewAttribute( "LieCover", IsLieAlgebra );

LieNucleus := NewAttribute( "LieNucleus", IsLieNilpotentOverFp );

LieMultiplicator := NewAttribute( "LieMultiplicator", IsLieNilpotentOverFp );

LiftIsomorphismToLieCover := NewOperation( "LiftIsomorphismToLieCover", [ IsLieAlgebra, IsLieAlgebra, IsMatrix ] );

AreIsomorphicNilpotentLieAlgebras := NewOperation( "AreIsomorphicNilpotentLieAlgebras", [ IsLieAlgebra, IsLieAlgebra ] );

IsLieAlgebraWithNB := NewProperty( "IsLieAlgebraWithNB", 
		                    IsLieNilpotentOverFp );

NilpotentBasis := NewAttribute( "NilpotentBasis", IsLieAlgebra, 
				"mutable"  );
    
IsNilpotentBasis := NewProperty( "IsNilpotentBasis", IsBasis );

LieNBDefinitions := NewAttribute( "LieNBDefinitions", IsNilpotentBasis );

LieNBWeights := NewAttribute( "LieNBWeights", IsNilpotentBasis );






