#############################################################################
####
##
#W  anupqi.gd              ANUPQ package                          Greg Gamble
##
##  This file declares interactive functions that execute individual pq  menu
##  options.
##
#H  @(#)$Id: anupqi.gd,v 1.2 2002/03/01 14:06:09 gap Exp $
##
#Y  Copyright (C) 2001  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.anupqi_gd :=
    "@(#)$Id: anupqi.gd,v 1.2 2002/03/01 14:06:09 gap Exp $";

#############################################################################
##
#F  PQ_UNBIND( <datarec>, <fields> ) . . . . . unbind fields of a data record
##
DeclareGlobalFunction( "PQ_UNBIND" );

#############################################################################
##
#F  PQ_AUT_GROUP( <G> ) . . . . . . . . . . . . . . . . .  automorphism group
##
DeclareGlobalFunction( "PQ_AUT_GROUP" );

#############################################################################
##
#F  PQ_AUT_INPUT( <datarec>, <G> : <options> ) . . . . . . automorphism input
##
DeclareGlobalFunction( "PQ_AUT_INPUT" );

#############################################################################
##
#F  PQ_MANUAL_AUT_INPUT(<datarec>,<mlist>) . automorphism input w/o an Aut gp
##
DeclareGlobalFunction( "PQ_MANUAL_AUT_INPUT" );

#############################################################################
##
#F  PQ_AUT_ARG_CHK(<minnargs>, <args>) . checks args for a func defining auts
##
DeclareGlobalFunction( "PQ_AUT_ARG_CHK" );

#############################################################################
##
#F  PQ_PC_PRESENTATION( <datarec>, <menu> ) . . . . . .  p-Q/SP menu option 1
##
DeclareGlobalFunction( "PQ_PC_PRESENTATION" );

#############################################################################
##
#F  PqPcPresentation( <i> : <options> ) . . user version of p-Q menu option 1
#F  PqPcPresentation( : <options> )
##
DeclareGlobalFunction( "PqPcPresentation" );

#############################################################################
##
#F  PQ_SAVE_PC_PRESENTATION( <datarec>, <filename> ) . . .  p-Q menu option 2
##
DeclareGlobalFunction( "PQ_SAVE_PC_PRESENTATION" );

#############################################################################
##
#F  PQ_PATH_CURRENT_DIRECTORY() . . . . . . . . . .  essentially the UNIX pwd
##
DeclareGlobalFunction( "PQ_PATH_CURRENT_DIRECTORY" );

#############################################################################
##
#F  PQ_CHK_PATH(<filename>, <rw>, <datarec>) . . . . . . .  check/add to path
##
DeclareGlobalFunction( "PQ_CHK_PATH" );

#############################################################################
##
#F  PqSavePcPresentation( <i>, <filename> ) . .  user ver. of p-Q menu opt. 2
#F  PqSavePcPresentation( <filename> )
##
DeclareGlobalFunction( "PqSavePcPresentation" );

#############################################################################
##
#F  PQ_RESTORE_PC_PRESENTATION( <datarec>, <filename> ) . . p-Q menu option 3
##
DeclareGlobalFunction( "PQ_RESTORE_PC_PRESENTATION" );

#############################################################################
##
#F  PqRestorePcPresentation( <i>, <filename> ) . user ver. of p-Q menu opt. 3
#F  PqRestorePcPresentation( <filename> )
##
DeclareGlobalFunction( "PqRestorePcPresentation" );

#############################################################################
##
#F  PQ_DISPLAY_PRESENTATION( <datarec> ) . . . . . . . . .  any menu option 4
##
DeclareGlobalFunction( "PQ_DISPLAY_PRESENTATION" );

#############################################################################
##
#F  PQ_GRP_EXISTS_CHK( <datarec> ) . . check the `pq' binary knows about a gp
##
DeclareGlobalFunction( "PQ_GRP_EXISTS_CHK" );

#############################################################################
##
#F  PQ_SET_GRP_DATA( <datarec> ) .  save group data of current class of group
##
DeclareGlobalFunction( "PQ_SET_GRP_DATA" );

#############################################################################
##
#F  PQ_DATA( <datarec> ) . . . . gets class/gen'r data from (A)p-Q menu opt 4
##
DeclareGlobalFunction( "PQ_DATA" );

#############################################################################
##
#F  PQ_DATA_CHK( <args> ) . . .  call PQ_DATA if class/gen'r data out-of-date
##
DeclareGlobalFunction( "PQ_DATA_CHK" );

#############################################################################
##
#F  PqFactoredOrder( <i> ) . the `pq' binary's current group's factored order
#F  PqFactoredOrder()
##
DeclareGlobalFunction( "PqFactoredOrder" );

#############################################################################
##
#F  PqOrder( <i> ) . . . .  the order of the current group of the `pq' binary
#F  PqOrder()
##
DeclareGlobalFunction( "PqOrder" );

#############################################################################
##
#F  PqPClass( <i> ) . . . the p class of the current group of the `pq' binary
#F  PqPClass()
##
DeclareGlobalFunction( "PqPClass" );

#############################################################################
##
#F  PqNrPcGenerators( <i> ) . number of pc gen'rs of `pq' binary's current gp
#F  PqNrPcGenerators()
##
DeclareGlobalFunction( "PqNrPcGenerators" );

#############################################################################
##
#F  PqWeight( <i>, <j> ) . . . . . . . . . . . . . . .  weight of a generator
#F  PqWeight( <j> )
##
DeclareGlobalFunction( "PqWeight" );

#############################################################################
##
#F  PqCurrentGroup( <i> ) . . . . extracts the current quotient as a pc group
#F  PqCurrentGroup()
##
DeclareGlobalFunction( "PqCurrentGroup" );

#############################################################################
##
#F  PqDisplayPcPresentation( <i> ) . . . .  user version of p-Q menu option 4
#F  PqDisplayPcPresentation()
##
DeclareGlobalFunction( "PqDisplayPcPresentation" );

#############################################################################
##
#F  PQ_SET_OUTPUT_LEVEL(<datarec>, <lev>) . . . .  p-Q/SP/A p-Q menu option 5
##
DeclareGlobalFunction( "PQ_SET_OUTPUT_LEVEL" );

#############################################################################
##
#F  PqSetOutputLevel( <i>, <lev> ) .  user version of p-Q/SP/A p-Q menu opt 5
#F  PqSetOutputLevel( <lev> )
##
DeclareGlobalFunction( "PqSetOutputLevel" );

#############################################################################
##
#F  PQ_NEXT_CLASS( <datarec> ) . . . . . . . . . . . . . .  p-Q menu option 6
##
DeclareGlobalFunction( "PQ_NEXT_CLASS" );

#############################################################################
##
#F  PqNextClass( <i> ) . . . . . . . . . .  user version of p-Q menu option 6
#F  PqNextClass()
##
DeclareGlobalFunction( "PqNextClass" );

#############################################################################
##
#F  PQ_P_COVER( <datarec> ) . . . . . . . . . . . . . . . . p-Q menu option 7
##
DeclareGlobalFunction( "PQ_P_COVER" );

#############################################################################
##
#F  PqComputePCover( <i> ) . . . . . . . .  user version of p-Q menu option 7
#F  PqComputePCover()
##
DeclareGlobalFunction( "PqComputePCover" );

#############################################################################
##
#F  PQ_EVALUATE_IDENTITIES(<datarec>) . evaluate Identities option identities
##
DeclareGlobalFunction( "PQ_EVALUATE_IDENTITIES" );

#############################################################################
##
#F  PqEvaluateIdentities( <i> ) . . . . evaluate Identities option identities
#F  PqEvaluateIdentities()
##
DeclareGlobalFunction( "PqEvaluateIdentities" );

#############################################################################
##
#F  PQ_FINISH_NEXT_CLASS( <datarec> ) . . .  take the p-cover to a next class
##
DeclareGlobalFunction( "PQ_FINISH_NEXT_CLASS" );

#############################################################################
##
#F  PQ_COLLECT( <datarec>, <word> ) . . . . . . . . . . . A p-Q menu option 1
##
DeclareGlobalFunction( "PQ_COLLECT" );

#############################################################################
##
#F  PQ_CHECK_WORD( <datarec>, <wordOrList>, <ngens> ) . .  check word or list
##
DeclareGlobalFunction( "PQ_CHECK_WORD" );

#############################################################################
##
#F  PQ_WORD( <datarec> ) . . . .  parse pq output for a word in pc generators
##
DeclareGlobalFunction( "PQ_WORD" );

#############################################################################
##
#F  PQ_CHK_COLLECT_COMMAND_ARGS( <args> ) . . check args for a collect cmd ok
##
DeclareGlobalFunction( "PQ_CHK_COLLECT_COMMAND_ARGS" );

#############################################################################
##
#F  PqCollect( <i>, <word> ) . . . . . .  user version of A p-Q menu option 1
#F  PqCollect( <word> )
##
DeclareGlobalFunction( "PqCollect" );

#############################################################################
##
#F  PQ_SOLVE_EQUATION( <datarec>, <a>, <b> ) . . . . . .  A p-Q menu option 2
##
DeclareGlobalFunction( "PQ_SOLVE_EQUATION" );

#############################################################################
##
#F  PqSolveEquation( <i>, <a>, <b> ) . .  user version of A p-Q menu option 2
#F  PqSolveEquation( <a>, <b> )
##
DeclareGlobalFunction( "PqSolveEquation" );

#############################################################################
##
#F  PQ_COMMUTATOR( <datarec>, <words>, <pow>, <item> ) . A p-Q menu opts 3/24
##
DeclareGlobalFunction( "PQ_COMMUTATOR" );

#############################################################################
##
#F  PQ_COMMUTATOR_CHK_ARGS( <args> ) . . . . check args for commutator cmd ok
##
DeclareGlobalFunction( "PQ_COMMUTATOR_CHK_ARGS" );

#############################################################################
##
#F  PqCommutator( <i>, <words>, <pow> ) . user version of A p-Q menu option 3
#F  PqCommutator( <words>, <pow> )
##
DeclareGlobalFunction( "PqCommutator" );

#############################################################################
##
#F  PQ_SETUP_TABLES_FOR_NEXT_CLASS( <datarec> ) . . . . . A p-Q menu option 6
##
DeclareGlobalFunction( "PQ_SETUP_TABLES_FOR_NEXT_CLASS" );

#############################################################################
##
#F  PqSetupTablesForNextClass( <i> ) . .  user version of A p-Q menu option 6
#F  PqSetupTablesForNextClass()
##
DeclareGlobalFunction( "PqSetupTablesForNextClass" );

#############################################################################
##
#F  PQ_INSERT_TAILS( <datarec>, <weight>, <which> )  . .  A p-Q menu option 7
##
DeclareGlobalFunction( "PQ_INSERT_TAILS" );

#############################################################################
##
#F  PQ_CHK_TAILS_ARGS( <args> ) . . . . .  check args for insert tails cmd ok
##
DeclareGlobalFunction( "PQ_CHK_TAILS_ARGS" );

#############################################################################
##
#F  PqAddTails( <i>, <weight> ) . . . .  adds tails using A p-Q menu option 7
#F  PqAddTails( <weight> )
##
DeclareGlobalFunction( "PqAddTails" );

#############################################################################
##
#F  PqComputeTails( <i>, <weight> ) . . computes tails using A p-Q menu opt 7
#F  PqComputeTails( <weight> )
##
DeclareGlobalFunction( "PqComputeTails" );

#############################################################################
##
#F  PqTails( <i>, <weight> ) . computes and adds tails using A p-Q menu opt 7
#F  PqTails( <weight> )
##
DeclareGlobalFunction( "PqTails" );

#############################################################################
##
#F  PQ_DO_CONSISTENCY_CHECKS(<datarec>, <weight>, <type>) .  A p-Q menu opt 8
##
DeclareGlobalFunction( "PQ_DO_CONSISTENCY_CHECKS" );

#############################################################################
##
#F  PqDoConsistencyChecks(<i>,<weight>,<type>) . user ver of A p-Q menu opt 8
#F  PqDoConsistencyChecks( <weight>, <type> )
##
DeclareGlobalFunction( "PqDoConsistencyChecks" );

#############################################################################
##
#F  PQ_COLLECT_DEFINING_RELATIONS( <datarec> ) . . . . .  A p-Q menu option 9
##
DeclareGlobalFunction( "PQ_COLLECT_DEFINING_RELATIONS" );

#############################################################################
##
#F  PqCollectDefiningRelations( <i> ) . . user version of A p-Q menu option 9
#F  PqCollectDefiningRelations()
##
DeclareGlobalFunction( "PqCollectDefiningRelations" );

#############################################################################
##
#F  PQ_DO_EXPONENT_CHECKS( <datarec>, <bnds> ) . . . . . A p-Q menu option 10
##
DeclareGlobalFunction( "PQ_DO_EXPONENT_CHECKS" );

#############################################################################
##
#F  PqDoExponentChecks(<i>[: Bounds := <list>]) . user ver A p-Q menu opt. 10
#F  PqDoExponentChecks([: Bounds := <list>])
##
DeclareGlobalFunction( "PqDoExponentChecks" );

#############################################################################
##
#F  PQ_ELIMINATE_REDUNDANT_GENERATORS( <datarec> ) . . . A p-Q menu option 11
##
DeclareGlobalFunction( "PQ_ELIMINATE_REDUNDANT_GENERATORS" );

#############################################################################
##
#F  PqEliminateRedundantGenerators( <i> ) .  user ver of A p-Q menu option 11
#F  PqEliminateRedundantGenerators()
##
DeclareGlobalFunction( "PqEliminateRedundantGenerators" );

#############################################################################
##
#F  PQ_REVERT_TO_PREVIOUS_CLASS( <datarec> ) . . . . . . A p-Q menu option 12
##
DeclareGlobalFunction( "PQ_REVERT_TO_PREVIOUS_CLASS" );

#############################################################################
##
#F  PqRevertToPreviousClass( <i> ) . . . user version of A p-Q menu option 12
#F  PqRevertToPreviousClass()
##
DeclareGlobalFunction( "PqRevertToPreviousClass" );

#############################################################################
##
#F  PQ_SET_MAXIMAL_OCCURRENCES( <datarec>, <noccur> ) . .  A p-Q menu opt. 13
##
DeclareGlobalFunction( "PQ_SET_MAXIMAL_OCCURRENCES" );

#############################################################################
##
#F  PqSetMaximalOccurrences( <i>, <noccur> ) . user ver of A p-Q menu opt. 13
#F  PqSetMaximalOccurrences( <noccur> )
##
DeclareGlobalFunction( "PqSetMaximalOccurrences" );

#############################################################################
##
#F  PQ_SET_METABELIAN( <datarec> ) . . . . . . . . . . . A p-Q menu option 14
##
DeclareGlobalFunction( "PQ_SET_METABELIAN" );

#############################################################################
##
#F  PqSetMetabelian( <i> ) . . . . . . . user version of A p-Q menu option 14
#F  PqSetMetabelian()
##
DeclareGlobalFunction( "PqSetMetabelian" );

#############################################################################
##
#F  PQ_DO_CONSISTENCY_CHECK( <datarec>, <c>, <b>, <a> ) . A p-Q menu option 15
##
DeclareGlobalFunction( "PQ_DO_CONSISTENCY_CHECK" );

#############################################################################
##
#F  PqDoConsistencyCheck(<i>, <c>, <b>, <a>) .  user ver of A p-Q menu opt 15
#F  PqDoConsistencyCheck( <c>, <b>, <a> )
#F  PqJacobi(<i>, <c>, <b>, <a>)
#F  PqJacobi( <c>, <b>, <a> )
##
DeclareGlobalFunction( "PqDoConsistencyCheck" );
DeclareSynonym( "PqJacobi", PqDoConsistencyCheck );

#############################################################################
##
#F  PQ_COMPACT( <datarec> ) . . . . . . . . . . . . . .  A p-Q menu option 16
##
DeclareGlobalFunction( "PQ_COMPACT" );

#############################################################################
##
#F  PqCompact( <i> ) . . . . . . . . . . user version of A p-Q menu option 16
#F  PqCompact()
##
DeclareGlobalFunction( "PqCompact" );

#############################################################################
##
#F  PQ_ECHELONISE( <datarec> ) . . . . . . . . . . . . . A p-Q menu option 17
##
DeclareGlobalFunction( "PQ_ECHELONISE" );

#############################################################################
##
#F  PqEchelonise( <i> ) . . . . . . . .  user version of A p-Q menu option 17
#F  PqEchelonise()
##
DeclareGlobalFunction( "PqEchelonise" );

#############################################################################
##
#F  PQ_SUPPLY_OR_EXTEND_AUTOMORPHISMS(<datarec>[,<mlist>])  A p-Q menu opt 18
##
DeclareGlobalFunction( "PQ_SUPPLY_OR_EXTEND_AUTOMORPHISMS" );

#############################################################################
##
#F  PqSupplyAutomorphisms(<i>, <mlist>) . . supply auts via A p-Q menu opt 18
#F  PqSupplyAutomorphisms( <mlist> )
##
DeclareGlobalFunction( "PqSupplyAutomorphisms" );

#############################################################################
##
#F  PqExtendAutomorphisms( <i> ) . . . . .  extend auts via A p-Q menu opt 18
#F  PqExtendAutomorphisms()
##
DeclareGlobalFunction( "PqExtendAutomorphisms" );

#############################################################################
##
#F  PQ_CLOSE_RELATIONS( <datarec>, <qfac> ) . . . . . .  A p-Q menu option 19
##
DeclareGlobalFunction( "PQ_CLOSE_RELATIONS" );

#############################################################################
##
#F  PqApplyAutomorphisms( <i>, <qfac> ) . .  user ver of A p-Q menu option 19
#F  PqApplyAutomorphisms( <qfac> )
##
DeclareGlobalFunction( "PqApplyAutomorphisms" );

#############################################################################
##
#F  PQ_DISPLAY( <datarec>, <opt>, <type>, <bnds> ) .  A p-Q menu option 20/21
##
DeclareGlobalFunction( "PQ_DISPLAY" );

#############################################################################
##
#F  PQ_BOUNDS( <datarec>, <hibnd> ) . . provide bounds from option or default
##
DeclareGlobalFunction( "PQ_BOUNDS" );

#############################################################################
##
#F  PqDisplayStructure(<i>[: Bounds := <list>]) . user ver A p-Q menu opt. 20
#F  PqDisplayStructure([: Bounds := <list>])
##
DeclareGlobalFunction( "PqDisplayStructure" );

#############################################################################
##
#F  PqDisplayAutomorphisms(<i>[: Bounds := <list>]) . u ver A p-Q menu opt 21
#F  PqDisplayAutomorphisms([: Bounds := <list>])
##
DeclareGlobalFunction( "PqDisplayAutomorphisms" );

#############################################################################
##
#F  PQ_COLLECT_DEFINING_GENERATORS( <datarec>, <word> ) . . A p-Q menu opt 23
##
DeclareGlobalFunction( "PQ_COLLECT_DEFINING_GENERATORS" );

#############################################################################
##
#F  PqCollectWordInDefiningGenerators(<i>,<word>) . u ver of A p-Q menu op 23
#F  PqCollectWordInDefiningGenerators( <word> )
##
DeclareGlobalFunction( "PqCollectWordInDefiningGenerators" );

#############################################################################
##
#F  PqCommutatorDefiningGenerators(<i>,<words>,<pow>) . user ver A p-Q opt 24
#F  PqCommutatorDefiningGenerators( <words>, <pow> )
##
DeclareGlobalFunction( "PqCommutatorDefiningGenerators" );

#############################################################################
##
#F  PQ_WRITE_PC_PRESENTATION( <datarec>, <filename> ) .  A p-Q menu option 25
##
DeclareGlobalFunction( "PQ_WRITE_PC_PRESENTATION" );

#############################################################################
##
#F  PqWritePcPresentation( <i>, <filename> ) . user ver. of A p-Q menu opt 25
#F  PqWritePcPresentation( <filename> )
##
DeclareGlobalFunction( "PqWritePcPresentation" );

#############################################################################
##
#F  PQ_WRITE_COMPACT_DESCRIPTION( <datarec> ) . . . . .  A p-Q menu option 26
##
DeclareGlobalFunction( "PQ_WRITE_COMPACT_DESCRIPTION" );

#############################################################################
##
#F  PqWriteCompactDescription( <i> ) . . user version of A p-Q menu option 26
#F  PqWriteCompactDescription()
##
DeclareGlobalFunction( "PqWriteCompactDescription" );

#############################################################################
##
#F  PQ_EVALUATE_CERTAIN_FORMULAE( <datarec> ) . . . . .  A p-Q menu option 27
##
DeclareGlobalFunction( "PQ_EVALUATE_CERTAIN_FORMULAE" );

#############################################################################
##
#F  PqEvaluateCertainFormulae( <i> ) . . user version of A p-Q menu option 27
#F  PqEvaluateCertainFormulae()
##
DeclareGlobalFunction( "PqEvaluateCertainFormulae" );

#############################################################################
##
#F  PQ_EVALUATE_ACTION( <datarec> ) . . . . . . . . . .  A p-Q menu option 28
##
DeclareGlobalFunction( "PQ_EVALUATE_ACTION" );

#############################################################################
##
#F  PqEvaluateAction( <i> ) . . . . . .  user version of A p-Q menu option 28
#F  PqEvaluateAction()
##
DeclareGlobalFunction( "PqEvaluateAction" );

#############################################################################
##
#F PQ_EVALUATE_ENGEL_IDENTITY( <datarec> ) . . . . . . . A p-Q menu option 29
##
DeclareGlobalFunction( "PQ_EVALUATE_ENGEL_IDENTITY" );

#############################################################################
##
#F PqEvaluateEngelIdentity( <i> ) . . .  user version of A p-Q menu option 29
#F PqEvaluateEngelIdentity()
##
DeclareGlobalFunction( "PqEvaluateEngelIdentity" );

#############################################################################
##
#F PQ_PROCESS_RELATIONS_FILE( <datarec> ) . . . . . . .  A p-Q menu option 30
##
DeclareGlobalFunction( "PQ_PROCESS_RELATIONS_FILE" );

#############################################################################
##
#F PqProcessRelationsFile( <i> ) . . . . user version of A p-Q menu option 30
#F PqProcessRelationsFile()
##
DeclareGlobalFunction( "PqProcessRelationsFile" );

#############################################################################
##
#F  PqSPComputePcpAndPCover(<i> : <options>) . . . user ver of SP menu opt. 1
#F  PqSPComputePcpAndPCover( : <options> )
##
DeclareGlobalFunction( "PqSPComputePcpAndPCover" );

#############################################################################
##
#F  PQ_SP_STANDARD_PRESENTATION(<datarec>[,<mlist>] :<options>) SP menu opt 2
##
DeclareGlobalFunction( "PQ_SP_STANDARD_PRESENTATION" );

#############################################################################
##
#F  PqSPStandardPresentation(<i>[,<mlist>]:<options>)  user ver SP menu opt 2
#F  PqSPStandardPresentation([<mlist>] : <options> )
##
DeclareGlobalFunction( "PqSPStandardPresentation" );

#############################################################################
##
#F  PQ_SP_SAVE_PRESENTATION( <datarec>, <filename> ) . . . . SP menu option 3
##
DeclareGlobalFunction( "PQ_SP_SAVE_PRESENTATION" );

#############################################################################
##
#F  PqSPSavePresentation( <i>, <filename> ) . .  user ver of SP menu option 3
#F  PqSPSavePresentation( <filename> )
##
DeclareGlobalFunction( "PqSPSavePresentation" );

#############################################################################
##
#F  PQ_SP_COMPARE_TWO_FILE_PRESENTATIONS(<datarec>,<f1>,<f2>) . SP menu opt 6
##
DeclareGlobalFunction( "PQ_SP_COMPARE_TWO_FILE_PRESENTATIONS" );

#############################################################################
##
#F  PqSPCompareTwoFilePresentations(<i>,<f1>,<f2>)  user ver of SP menu opt 6
#F  PqSPCompareTwoFilePresentations(<f1>,<f2>)
##
DeclareGlobalFunction( "PqSPCompareTwoFilePresentations" );

#############################################################################
##
#F  PQ_SP_ISOMORPHISM( <datarec> ) . . . . . . . . . . . . . SP menu option 8
##
DeclareGlobalFunction( "PQ_SP_ISOMORPHISM" );

#############################################################################
##
#F  PqSPIsomorphism( <i> ) . . . . . . . . . user version of SP menu option 8
#F  PqSPIsomorphism()
##
DeclareGlobalFunction( "PqSPIsomorphism" );

#############################################################################
##
#F  PQ_PG_SUPPLY_AUTS( <datarec>[, <mlist>], <menu> ) .  p-G/A p-G menu opt 1
##
DeclareGlobalFunction( "PQ_PG_SUPPLY_AUTS" );

#############################################################################
##
#F  PqPGSupplyAutomorphisms( <i>[, <mlist>] ) .  user ver of pG menu option 1
#F  PqPGSupplyAutomorphisms([<mlist>])
##
DeclareGlobalFunction( "PqPGSupplyAutomorphisms" );

#############################################################################
##
#F  PQ_PG_EXTEND_AUTOMORPHISMS( <datarec> ) . . . . . p-G/A p-G menu option 2
##
DeclareGlobalFunction( "PQ_PG_EXTEND_AUTOMORPHISMS" );

#############################################################################
##
#F  PqPGExtendAutomorphisms( <i> ) . . . .  user version of p-G menu option 2
#F  PqPGExtendAutomorphisms()
##
DeclareGlobalFunction( "PqPGExtendAutomorphisms" );

#############################################################################
##
#F  PQ_PG_RESTORE_GROUP(<datarec>, <cls>, <n>) . . . . . p-G/A p-G menu opt 3
##
DeclareGlobalFunction( "PQ_PG_RESTORE_GROUP" );

#############################################################################
##
#F  PqPGSetDescendantToPcp( <i>, <cls>, <n> ) . u ver of p-G/A p-G menu opt 3
#F  PqPGSetDescendantToPcp( <cls>, <n> )
#F  PqPGSetDescendantToPcp( <i> [: Filename := <name> ])
#F  PqPGSetDescendantToPcp([: Filename := <name> ])
#F  PqPGRestoreDescendantFromFile(<i>, <cls>, <n>)
#F  PqPGRestoreDescendantFromFile( <cls>, <n> )
#F  PqPGRestoreDescendantFromFile( <i> [: Filename := <name> ])
#F  PqPGRestoreDescendantFromFile([: Filename := <name> ])
##
DeclareGlobalFunction( "PqPGSetDescendantToPcp" );
DeclareSynonym( "PqPGRestoreDescendantFromFile", PqPGSetDescendantToPcp );

#############################################################################
##
#F  PQ_PG_CONSTRUCT_DESCENDANTS( <datarec> : <options> ) . . pG menu option 5
##
DeclareGlobalFunction( "PQ_PG_CONSTRUCT_DESCENDANTS" );

#############################################################################
##
#F  PqPGConstructDescendants( <i> : <options> ) . user ver. of p-G menu op. 5
#F  PqPGConstructDescendants( : <options> )
##
DeclareGlobalFunction( "PqPGConstructDescendants" );

#############################################################################
##
#F  PqAPGSupplyAutomorphisms( <i>[, <mlist>] ) . user ver of A p-G menu opt 1
#F  PqAPGSupplyAutomorphisms([<mlist>])
##
DeclareGlobalFunction( "PqAPGSupplyAutomorphisms" );

#############################################################################
##
#F  PqAPGSingleStage( <i> : <options> ) . user version of A p-G menu option 5
#F  PqAPGSingleStage( : <options> )
##
DeclareGlobalFunction( "PqAPGSingleStage" );

#############################################################################
##
#F  PQ_APG_DEGREE( <datarec>, <step>, <rank> ) . . . . .  A p-G menu option 6
##
DeclareGlobalFunction( "PQ_APG_DEGREE" );

#############################################################################
##
#F  PqAPGDegree(<i>,<step>,<rank>[: Exponent := <n>]) . u ver A p-G menu op 6
#F  PqAPGDegree( <step>, <rank> [: Exponent := <n> ])
##
DeclareGlobalFunction( "PqAPGDegree" );

#############################################################################
##
#F  PQ_APG_PERMUTATIONS( <datarec> ) . . . . . . . . . .  A p-G menu option 7
##
DeclareGlobalFunction( "PQ_APG_PERMUTATIONS" );

#############################################################################
##
#F  PqAPGPermutations( <i> : <options> ) . user version of A p-G menu optn. 7
#F  PqAPGPermutations( : <options> )
##
DeclareGlobalFunction( "PqAPGPermutations" );

#############################################################################
##
#F PQ_APG_ORBITS( <datarec> ) . . . . . . . . . . . . . . A p-G menu option 8
##
DeclareGlobalFunction( "PQ_APG_ORBITS" );

#############################################################################
##
#F PqAPGOrbits( <i> ) . . . . . . . . . . user version of A p-G menu option 8
#F PqAPGOrbits()
##
DeclareGlobalFunction( "PqAPGOrbits" );

#############################################################################
##
#F PQ_APG_ORBIT_REPRESENTATIVES( <datarec> ) . . . . . .  A p-G menu option 9
##
DeclareGlobalFunction( "PQ_APG_ORBIT_REPRESENTATIVES" );

#############################################################################
##
#F PqAPGOrbitRepresentatives( <i> ) . . . user version of A p-G menu option 9
#F PqAPGOrbitRepresentatives()
##
DeclareGlobalFunction( "PqAPGOrbitRepresentatives" );

#############################################################################
##
#F PQ_APG_ORBIT_REPRESENTATIVE( <datarec> ) . . . . . .  A p-G menu option 10
##
DeclareGlobalFunction( "PQ_APG_ORBIT_REPRESENTATIVE" );

#############################################################################
##
#F PqAPGOrbitRepresentative( <i> ) . . . user version of A p-G menu option 10
#F PqAPGOrbitRepresentative()
##
DeclareGlobalFunction( "PqAPGOrbitRepresentative" );

#############################################################################
##
#F PQ_APG_STANDARD_MATRIX_LABEL( <datarec> ) . . . . . . A p-G menu option 11
##
DeclareGlobalFunction( "PQ_APG_STANDARD_MATRIX_LABEL" );

#############################################################################
##
#F PqAPGStandardMatrixLabel( <i> ) . . . user version of A p-G menu option 11
#F PqAPGStandardMatrixLabel()
##
DeclareGlobalFunction( "PqAPGStandardMatrixLabel" );

#############################################################################
##
#F PQ_APG_MATRIX_OF_LABEL( <datarec> ) . . . . . . . . . A p-G menu option 12
##
DeclareGlobalFunction( "PQ_APG_MATRIX_OF_LABEL" );

#############################################################################
##
#F PqAPGMatrixOfLabel( <i> ) . . . . . . user version of A p-G menu option 12
#F PqAPGMatrixOfLabel()
##
DeclareGlobalFunction( "PqAPGMatrixOfLabel" );

#############################################################################
##
#F PQ_APG_IMAGE_OF_ALLOWABLE_SUBGROUP( <datarec> ) . . . A p-G menu option 13
##
DeclareGlobalFunction( "PQ_APG_IMAGE_OF_ALLOWABLE_SUBGROUP" );

#############################################################################
##
#F PqAPGImageOfAllowableSubgroup( <i> )  user version of A p-G menu option 13
#F PqAPGImageOfAllowableSubgroup()
##
DeclareGlobalFunction( "PqAPGImageOfAllowableSubgroup" );

#############################################################################
##
#F PQ_APG_RANK_CLOSURE_OF_INITIAL_SEGMENT( <datarec> ) . A p-G menu option 14
##
DeclareGlobalFunction( "PQ_APG_RANK_CLOSURE_OF_INITIAL_SEGMENT" );

#############################################################################
##
#F PqAPGRankClosureOfInitialSegment( <i> )  user version of A p-G menu option 14
#F PqAPGRankClosureOfInitialSegment()
##
DeclareGlobalFunction( "PqAPGRankClosureOfInitialSegment" );

#############################################################################
##
#F PQ_APG_ORBIT_REPRESENTATIVE_OF_LABEL( <datarec> ) . . A p-G menu option 15
##
DeclareGlobalFunction( "PQ_APG_ORBIT_REPRESENTATIVE_OF_LABEL" );

#############################################################################
##
#F PqAPGOrbitRepresentativeOfLabel( <i> )  user version of A p-G menu option 15
#F PqAPGOrbitRepresentativeOfLabel()
##
DeclareGlobalFunction( "PqAPGOrbitRepresentativeOfLabel" );

#############################################################################
##
#F PQ_APG_WRITE_COMPACT_DESCRIPTION( <datarec> ) . . . . A p-G menu option 16
##
DeclareGlobalFunction( "PQ_APG_WRITE_COMPACT_DESCRIPTION" );

#############################################################################
##
#F PqAPGWriteCompactDescription( <i> ) . user version of A p-G menu option 16
#F PqAPGWriteCompactDescription()
##
DeclareGlobalFunction( "PqAPGWriteCompactDescription" );

#############################################################################
##
#F PQ_APG_AUTOMORPHISM_CLASSES( <datarec> ) . . . . . .  A p-G menu option 17
##
DeclareGlobalFunction( "PQ_APG_AUTOMORPHISM_CLASSES" );

#############################################################################
##
#F PqAPGAutomorphismClasses( <i> ) . . . user version of A p-G menu option 17
#F PqAPGAutomorphismClasses()
##
DeclareGlobalFunction( "PqAPGAutomorphismClasses" );

#E  anupqi.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
