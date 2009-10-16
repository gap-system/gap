#############################################################################
##
#W  interact.gd                ACE Package                        Greg Gamble
##
##  This file  declares  commands for using ACE interactively via IO Streams.
##    
#H  @(#)$Id: interact.gd,v 1.23 2006/01/26 16:11:31 gap Exp $
##
#Y  Copyright (C) 2000  Centre for Discrete Mathematics and Computing
#Y                      Department of Information Technology & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.("ace/gap/interact_gd") :=
    "@(#)$Id: interact.gd,v 1.23 2006/01/26 16:11:31 gap Exp $";

#############################################################################
##
#D  Declare functions for using ACE interactively via IO Streams.
##
DeclareGlobalFunction("ACE_IOINDEX");
DeclareGlobalFunction("ACE_IOINDEX_ARG_CHK");
DeclareGlobalFunction("ACEDataRecord");
DeclareGlobalFunction("ACEProcessIndex");
DeclareGlobalFunction("ACEProcessIndices");
DeclareGlobalFunction("IsACEProcessAlive");
DeclareGlobalFunction("ACEResurrectProcess");
DeclareGlobalFunction("READ_ACE_ERRORS");
DeclareGlobalFunction("ENSURE_NO_ACE_ERRORS");
DeclareGlobalFunction("INTERACT_TO_ACE_WITH_ERRCHK");
DeclareGlobalFunction("ACE_ENUMERATION_RESULT");
DeclareGlobalFunction("LAST_ACE_ENUM_RESULT");
DeclareGlobalFunction("ACEWrite");
DeclareGlobalFunction("ACERead");
DeclareGlobalFunction("ACEReadAll");
DeclareGlobalFunction("ACEReadUntil");
DeclareGlobalFunction("ACE_STATS");
DeclareGlobalFunction("ACE_COSET_TABLE");
DeclareGlobalFunction("ACE_MODE");
DeclareGlobalFunction("ACE_MODE_AFTER_SET_OPTS");
DeclareGlobalFunction("CHEAPEST_ACE_MODE");
DeclareGlobalFunction("ACE_LENLEX_CHK");
DeclareGlobalFunction("SET_ACE_ARGS");
DeclareGlobalFunction("NO_START_DO_ACE_OPTIONS");
DeclareGlobalFunction("ACEStart");
DeclareGlobalFunction("ACEQuit");
DeclareGlobalFunction("ACEQuitAll");
DeclareGlobalFunction("ACE_MODES");
DeclareGlobalFunction("ACEModes");
DeclareGlobalFunction("ACEContinue");
DeclareGlobalFunction("ACERedo");
DeclareGlobalFunction("ACE_EQUIV_PRESENTATIONS");
DeclareGlobalFunction("ACEAllEquivPresentations");
DeclareGlobalFunction("ACERandomEquivPresentations");
DeclareGlobalFunction("ACEGroupGenerators");
DeclareGlobalFunction("ACERelators");
DeclareGlobalFunction("ACESubgroupGenerators");
DeclareGlobalFunction("DISPLAY_ACE_REC_FIELD");
DeclareGlobalFunction("DisplayACEOptions");
DeclareGlobalFunction("DisplayACEArgs");
DeclareGlobalFunction("GET_ACE_REC_FIELD");
DeclareGlobalFunction("GetACEOptions");
DeclareGlobalFunction("GetACEArgs");
DeclareGlobalFunction("SET_ACE_OPTIONS");
DeclareGlobalFunction("ECHO_ACE_ARGS");
DeclareGlobalFunction("INTERACT_SET_ACE_OPTIONS");
DeclareGlobalFunction("SetACEOptions");
DeclareGlobalFunction("ACE_PARAMETER_WITH_LINE");
DeclareGlobalFunction("ACE_PARAMETER");
DeclareGlobalFunction("ACE_GAP_WORDS");
DeclareGlobalFunction("ACE_GENS");
DeclareGlobalFunction("ACE_ARGS");
DeclareGlobalFunction("ACEParameters");
DeclareGlobalFunction("ACEBinaryVersion");
DeclareGlobalFunction("EXEC_ACE_DIRECTIVE_OPTION");
DeclareGlobalFunction("ACE_IOINDEX_AND_NO_VALUE");
DeclareGlobalFunction("ACE_IOINDEX_AND_ONE_VALUE");
DeclareGlobalFunction("ACE_IOINDEX_AND_ONE_LIST");
DeclareGlobalFunction("ACE_IOINDEX_AND_LIST");
DeclareGlobalFunction("ACEDumpVariables");
DeclareGlobalFunction("ACEDumpStatistics");
DeclareGlobalFunction("ACEStyle");
DeclareGlobalFunction("ACEDisplayCosetTable");
DeclareGlobalFunction("IsCompleteACECosetTable");
DeclareGlobalFunction("ACECosetRepresentative");
DeclareGlobalFunction("ACECosetRepresentatives");
DeclareGlobalFunction("ACETransversal");
DeclareGlobalFunction("ACECycles");
DeclareSynonym("ACEPermutationRepresentation", ACECycles);
DeclareGlobalFunction("ACETraceWord");
DeclareGlobalFunction("ACE_ORDER");
DeclareGlobalFunction("ACEOrders");
DeclareGlobalFunction("ACEOrder");
DeclareGlobalFunction("ACECosetOrderFromRepresentative");
DeclareGlobalFunction("ACECosetsThatNormaliseSubgroup");
DeclareGlobalFunction("ACECosetTable");
DeclareGlobalFunction("ACEStats");
DeclareGlobalFunction("ACERecover");
DeclareGlobalFunction("ACEStandardCosetNumbering");
DeclareGlobalFunction("ACEAddRelators");
DeclareGlobalFunction("ACEAddSubgroupGenerators");
DeclareGlobalFunction("ACE_WORDS_OR_UNSORTED");
DeclareGlobalFunction("ACEDeleteRelators");
DeclareGlobalFunction("ACEDeleteSubgroupGenerators");
DeclareGlobalFunction("ACECosetCoincidence");
DeclareGlobalFunction("ACERandomCoincidences");
DeclareGlobalFunction("ACERandomlyApplyCosetCoincidence");
DeclareGlobalFunction("ACEConjugatesForSubgroupNormalClosure");

#E  interact.gd . . . . . . . . . . . . . . . . . . . . . . . . .  ends here 
