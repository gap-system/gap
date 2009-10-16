#############################################################################
##
#W  itc.gd                  	XGAP library                   Volkmar Felsch
#W                                                               Ludger Hippe
#W                                                          Joachim Neubueser
##
##
#Y  Copyright 1999,        Volkmar Felsch,              Aachen,       Germany
##
##  This file contains  declarations  for the  Interactive Todd-Coxeter coset
##  enumeration routines.
##


#############################################################################
##
#F  InteractiveTC( <G>, <H> )
##
##  starts  the  Interactive Todd-Coxeter  coset enumeration  routines  for a
##  finitely presented group <G> and a subgroup <H> of <G>.
##
DeclareGlobalFunction( "InteractiveTC" );


#############################################################################
##
##  list of global variables not thought for the user
##
DeclareGlobalFunction( "ItcBackTo" );
DeclareGlobalFunction( "ItcChangeDefaultTableSize" );
DeclareGlobalFunction( "ItcChangeSettings" );
DeclareGlobalFunction( "ItcClassOfGaps" );
DeclareGlobalFunction( "ItcClassSheetLeftPBDown" );
DeclareGlobalFunction( "ItcClear" );
DeclareGlobalFunction( "ItcClearTable" );
DeclareGlobalFunction( "ItcCloseGapSheets" );
DeclareGlobalFunction( "ItcCloseSheets" );
DeclareGlobalFunction( "ItcCloseTableFelsch" );
DeclareGlobalFunction( "ItcCloseTableGaps" );
DeclareGlobalFunction( "ItcCloseTableHLT" );
DeclareGlobalFunction( "ItcCoincSheetLeftPBDown" );
DeclareGlobalFunction( "ItcCoincSheetRightPBDown" );
DeclareGlobalFunction( "ItcCosetStepFelsch" );
DeclareGlobalFunction( "ItcCosetStepFill" );
DeclareGlobalFunction( "ItcCosetTableSheetLeftPBDown" );
DeclareGlobalFunction( "ItcCosetTableSheetRightPBDown" );
DeclareGlobalFunction( "ItcDefinitionsSheetPBDown" );
DeclareGlobalFunction( "ItcDisplayButtons" );
DeclareGlobalFunction( "ItcDisplayCosetTable" );
DeclareGlobalFunction( "ItcDisplayDefinition" );
DeclareGlobalFunction( "ItcDisplayDefinitionsTable" );
DeclareGlobalFunction( "ItcDisplayHeaderOfCosetTable" );
DeclareGlobalFunction( "ItcDisplayPendingCoincidences" );
DeclareGlobalFunction( "ItcDisplayRelationTable" );
DeclareGlobalFunction( "ItcDisplayRelatorsSheet" );
DeclareGlobalFunction( "ItcDisplaySubgroupGeneratorsSheet" );
DeclareGlobalFunction( "ItcDisplaySubgroupTable" );
DeclareGlobalFunction( "ItcEnableMenu" );
DeclareGlobalFunction( "ItcExtendTableSize" );
DeclareGlobalFunction( "ItcExtractPrecedingTable" );
DeclareGlobalFunction( "ItcExtractTable" );
DeclareGlobalFunction( "ItcFastCosetStepFelsch" );
DeclareGlobalFunction( "ItcFastCosetStepFill" );
DeclareGlobalFunction( "ItcFelsch" );
DeclareGlobalFunction( "ItcFillCosetTableEntry" );
DeclareGlobalFunction( "ItcFillGaps" );
DeclareGlobalFunction( "ItcFillRows" );
DeclareGlobalFunction( "ItcFillTrace" );
DeclareGlobalFunction( "ItcFillTraceHLT" );
DeclareGlobalFunction( "ItcFirstGapOfLengthOne" );
DeclareGlobalFunction( "ItcGapSheetLeftPBDown" );
DeclareGlobalFunction( "ItcGapSheetRightPBDown" );
DeclareGlobalFunction( "ItcGaps" );
DeclareGlobalFunction( "ItcHLT" );
DeclareGlobalFunction( "ItcHandlePendingCoincidence" );
DeclareGlobalFunction( "ItcHandlePendingDeductions" );
DeclareGlobalFunction( "ItcInitializeInfoLine" );
DeclareGlobalFunction( "ItcInitializeParameters" );
DeclareGlobalFunction( "ItcIsAliveCoset" );
DeclareGlobalFunction( "ItcIsClosedRow" );
DeclareGlobalFunction( "ItcListColumnNumbers" );
DeclareGlobalFunction( "ItcMakeConsequences" );
DeclareGlobalFunction( "ItcMakeDigitStrings" );
DeclareGlobalFunction( "ItcMakeMenu" );
DeclareGlobalFunction( "ItcMarkCosets" );
DeclareGlobalFunction( "ItcNumberClassOfGaps" );
DeclareGlobalFunction( "ItcOpenClassSheet" );
DeclareGlobalFunction( "ItcQuery" );
DeclareGlobalFunction( "ItcQuit" );
DeclareGlobalFunction( "ItcReadDefinitions" );
DeclareGlobalFunction( "ItcRecolorDefs" );
DeclareGlobalFunction( "ItcRecolorPendingCosets" );
DeclareGlobalFunction( "ItcRecolorTableEntries" );
DeclareGlobalFunction( "ItcReconstructTable" );
DeclareGlobalFunction( "ItcReinitializeParameters" );
DeclareGlobalFunction( "ItcRelabelInfoLine" );
DeclareGlobalFunction( "ItcRelationTable" );
DeclareGlobalFunction( "ItcRelationTableSheetLeftPBDown" );
DeclareGlobalFunction( "ItcRelatorsSheetLeftPBDown" );
DeclareGlobalFunction( "ItcRepresentativeCoset" );
DeclareGlobalFunction( "ItcReset" );
DeclareGlobalFunction( "ItcScrollBy" );
DeclareGlobalFunction( "ItcScrollRelationTables" );
DeclareGlobalFunction( "ItcScrollTo" );
DeclareGlobalFunction( "ItcShortCut" );
DeclareGlobalFunction( "ItcShowCoincs" );
DeclareGlobalFunction( "ItcShowDefs" );
DeclareGlobalFunction( "ItcShowGaps" );
DeclareGlobalFunction( "ItcShowRels" );
DeclareGlobalFunction( "ItcShowSettings" );
DeclareGlobalFunction( "ItcShowSubgrp" );
DeclareGlobalFunction( "ItcSortDefinitions" );
DeclareGlobalFunction( "ItcString" );
DeclareGlobalFunction( "ItcStringRelationTable" );
DeclareGlobalFunction( "ItcSubgroupGeneratorsSheetLeftPBDown" );
DeclareGlobalFunction( "ItcSubgroupTableSheetLeftPBDown" );
DeclareGlobalFunction( "ItcUpdateDisplayedLists" );
DeclareGlobalFunction( "ItcUpdateFirstDef" );
DeclareGlobalFunction( "ItcWriteDefinitions" );
DeclareGlobalFunction( "ItcWriteStandardizedTable" );
DeclareGlobalFunction( "WidthOfSheetName" );


#############################################################################
##
#F  ItcExample( <name> )
##
DeclareGlobalFunction( "ItcExample" );


#############################################################################
##
#E

