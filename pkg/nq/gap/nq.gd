##############################################################################
##
#A  nq.gd                   Oktober 2002                         Werner Nickel
##
##  This file contains the declaration part of the interface to my NQ program.
##

DeclareGlobalFunction( "NqReadOutput" );
DeclareGlobalFunction( "NqStringFpGroup" );
DeclareGlobalFunction( "NqStringExpTrees" );
DeclareGlobalFunction( "NqInitFromTheLeftCollector" );
DeclareGlobalFunction( "NqPcpGroupByCollector" );
DeclareGlobalFunction( "NqPcpGroupByNqOutput" );
DeclareGlobalFunction( "NqPcpElementByWord" );
DeclareGlobalFunction( "NqBuildManual" );
DeclareGlobalFunction( "NqElementaryDivisors" );
DeclareGlobalFunction( "NqEpimorphismByNqOutput" );

DeclareGlobalFunction( "NilpotentEngelQuotient" );
DeclareGlobalFunction( "LowerCentralFactors" );

DeclareGlobalVariable( "NqGlobalVariables" );
DeclareGlobalVariable( "NqDefaultOptions" );
DeclareGlobalVariable( "NqOneTimeOptions" );
DeclareGlobalVariable( "NqRuntime" );
DeclareGlobalVariable( "NqGapOutput" );


DeclareOperation( "NilpotentQuotient", 
        [ IsObject, IsPosInt ] );

DeclareOperation( "NilpotentQuotientIdentical", 
        [ IsObject, IsObject, IsPosInt ] );

DeclareOperation( "NqEpimorphismNilpotentQuotient", 
        [ IsObject, IsPosInt ] );

DeclareInfoClass( "InfoNQ" );
