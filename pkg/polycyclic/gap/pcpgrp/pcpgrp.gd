#############################################################################
##
#W  pcpgrp.gd                    Polycyc                         Bettina Eick
##

# fitting.gi
DeclareAttribute( "SemiSimpleEfaSeries", IsPcpGroup );
DeclareAttribute( "IsNilpotentByFinite", IsGroup );
DeclareAttribute( "FCCentre", IsGroup );
DeclareGlobalFunction( "NilpotentByAbelianByFiniteSeries" );

# maxsub.gi
KeyDependentOperation( "MaximalSubgroupClassesByIndex", 
                       IsGroup, IsPosInt, ReturnTrue );
# findex/nindex.gi
KeyDependentOperation( "LowIndexSubgroupClasses", 
                       IsGroup, IsPosInt, ReturnTrue );
KeyDependentOperation( "LowIndexNormalSubgroups", 
                       IsGroup, IsPosInt, ReturnTrue );
DeclareGlobalFunction( "NilpotentByAbelianNormalSubgroup" );

# polyz.gi
DeclareGlobalFunction( "PolyZNormalSubgroup" );

# torsion.gi
DeclareAttribute( "TorsionSubgroup", IsGroup );
DeclareAttribute( "NormalTorsionSubgroup", IsGroup );
DeclareProperty(  "IsTorsionFree", IsGroup );
DeclareAttribute( "FiniteSubgroupClasses", IsGroup );
DeclareGlobalFunction( "RootSet" );

# schur and tensor
DeclareGlobalFunction("CompleteConjugatesInCentralCover");
DeclareGlobalFunction("EvalConsistency");
DeclareGlobalFunction("QuotientBySystem");
DeclareAttribute( "NonAbelianTensorSquare", IsGroup );
DeclareAttribute( "NonAbelianExteriorSquare", IsGroup );

DeclareOperation( "NqEpimorphismNilpotentQuotient", [IsGroup, IsPosInt]);

