#############################################################################
##
#W  pcpgrp.gd                    Polycyc                         Bettina Eick
##

# fitting.gi
DeclareAttribute( "SemiSimpleEfaSeries", IsPcpGroup );
DeclareAttribute( "FCCentre", IsGroup );
DeclareGlobalFunction( "NilpotentByAbelianByFiniteSeries" );

DeclareProperty( "IsNilpotentByFinite", IsGroup );
InstallTrueMethod( IsNilpotentByFinite, IsNilpotentGroup );
InstallTrueMethod( IsNilpotentByFinite, IsGroup and IsFinite );


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
DeclareAttribute( "FiniteSubgroupClasses", IsGroup );
DeclareGlobalFunction( "RootSet" );

DeclareProperty(  "IsTorsionFree", IsGroup );
InstallSubsetMaintenance( IsTorsionFree, IsGroup and IsTorsionFree, IsGroup );
InstallTrueMethod( IsTorsionFree, IsGroup and IsTrivial );
InstallTrueMethod( IsTorsionFree, IsFreeGroup );


DeclareProperty( "IsFreeAbelian", IsGroup );
InstallSubsetMaintenance( IsFreeAbelian, IsGroup and IsFreeAbelian, IsGroup );
InstallTrueMethod( IsFreeAbelian, IsGroup and IsTrivial );
InstallTrueMethod( IsFreeAbelian, IsFinitelyGeneratedGroup and IsTorsionFree and IsAbelian);
InstallTrueMethod( IsAbelian, IsGroup and IsFreeAbelian );
InstallTrueMethod( IsTorsionFree, IsGroup and IsFreeAbelian );


# schur and tensor
DeclareGlobalFunction("CompleteConjugatesInCentralCover");
DeclareGlobalFunction("EvalConsistency");
DeclareGlobalFunction("QuotientBySystem");
DeclareAttribute( "NonAbelianTensorSquare", IsGroup );
DeclareAttribute( "NonAbelianExteriorSquare", IsGroup );

DeclareOperation( "NqEpimorphismNilpotentQuotient", [IsGroup, IsPosInt]);

