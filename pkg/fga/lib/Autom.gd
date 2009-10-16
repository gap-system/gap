#############################################################################
##
#W  Autom.gd                FGA package                    Christian Sievers
##
##  Declarations for methods to create and compute with inverse automata
##
#H  @(#)$Id: Autom.gd,v 1.2 2003/04/08 14:41:26 gap Exp $
##
#Y  2003
##
Revision.("fga/lib/Autom_gd") :=
    "@(#)$Id: Autom.gd,v 1.2 2003/04/08 14:41:26 gap Exp $";

DeclareCategory( "IsInvAutomatonCategory", IsObject);

DeclareOperation( "TrivialInvAutomaton", [ IsFreeGroup ]);
DeclareOperation( "InvAutomatonInsertGenerator",
    [ IsInvAutomatonCategory and IsMutable, IsElementOfFreeGroup ] );

DeclareGlobalFunction( "FGA_newstate" );
DeclareGlobalFunction( "FGA_connectpos" );
DeclareGlobalFunction( "FGA_connect" );
DeclareGlobalFunction( "FGA_define" );
DeclareGlobalFunction( "FGA_find" );
DeclareGlobalFunction( "FGA_merge" );
DeclareGlobalFunction( "FGA_coincidence" );
DeclareGlobalFunction( "FGA_delta" );
DeclareGlobalFunction( "FGA_deltas" );
DeclareGlobalFunction( "FGA_TmpState" );
DeclareGlobalFunction( "FGA_trace" );
DeclareGlobalFunction( "FGA_backtrace" );
DeclareGlobalFunction( "FGA_InsertGenerator" );
DeclareGlobalFunction( "FGA_AutomInsertGeneratorLetterRep" );
DeclareGlobalFunction( "FGA_InsertGeneratorLetterRep" );
DeclareGlobalFunction( "FGA_FromGroupWithGenerators" );
DeclareGlobalFunction( "FGA_FromGeneratorsLetterRep");
DeclareGlobalFunction( "FGA_Check" );
DeclareGlobalFunction( "FGA_FindGeneratorsAndStates" );
DeclareGlobalFunction( "FGA_repr" );
DeclareGlobalFunction( "FGA_initial" );
DeclareGlobalFunction( "FGA_reducedPos" );
DeclareGlobalFunction( "FGA_Index" );
DeclareGlobalFunction( "FGA_AsWordLetterRepInFreeGenerators" );

DeclareAttribute( "FGA_States", IsInvAutomatonCategory );
DeclareAttribute( "FGA_GeneratorsLetterRep", IsInvAutomatonCategory );


#############################################################################
##
#E
