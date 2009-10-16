#############################################################################
##
#W    groups.gd                                                 Karel Dekimpe
#W                                                               Bettina Eick
##

DeclareProperty( "IsAlmostCrystallographic", IsGroup );
DeclareProperty( "IsAlmostBieberbachGroup", IsGroup );
DeclareAttribute( "AlmostCrystallographicInfo", IsGroup );
DeclareAttribute( "NaturalHomomorphismOnHolonomyGroup", IsGroup );
DeclareAttribute( "HolonomyGroup", IsGroup );

DeclareGlobalFunction( "AlmostCrystallographicDim3" );
DeclareGlobalFunction( "AlmostCrystallographicDim4" );
DeclareGlobalFunction( "AlmostCrystallographicGroup" );

DeclareGlobalFunction( "AlmostCrystallographicPcpDim3" );
DeclareGlobalFunction( "AlmostCrystallographicPcpDim4" );
DeclareGlobalFunction( "AlmostCrystallographicPcpGroup" );

DeclareGlobalFunction( "IsolatorSubgroup" );
DeclareAttribute( "OrientationModule", IsGroup );
DeclareOperation( "BettiNumber", [IsGroup, IsInt] );
DeclareAttribute( "BettiNumbers", IsGroup );

DeclareGlobalFunction( "HasExtensionOfType" );
