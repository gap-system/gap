#############################################################################
####
##
#W  options.gd                 ACE Package                        Greg Gamble
##
##  This file declares functions and records for manipulating ACE options.
##    
#H  @(#)$Id: options.gd,v 1.15 2006/01/26 16:11:31 gap Exp $
##
#Y  Copyright (C) 2000  Centre for Discrete Mathematics and Computing
#Y                      Department of Information Technology & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.("ace/gap/options_gd") :=
    "@(#)$Id: options.gd,v 1.15 2006/01/26 16:11:31 gap Exp $";


#############################################################################
##
#D  Declare variables.
##

DeclareGlobalVariable("KnownACEOptions",
  Concatenation([
    "A record whose fields are the known ACE options. The value of\n",
    "each record field (option) is a list [ leastlength, listorfn ],\n",
    "where leastlength an integer specifying the least length of an\n",
    "abbreviation of the option and listorfn is either a list of\n",
    "allowed values or a function that can be used to test that the\n",
    "value of an option is valid."])
  );

DeclareGlobalVariable("ACEOptionSynonyms",
  Concatenation([
    "A record whose fields are known `preferred' ACE (interface) options\n",
    "that have synonyms. The values are lists of synonymous alternatives."])
  );

DeclareGlobalVariable("NonACEbinOptions",
  "A list of known ACE (interface) options that are not ACE binary options"
  );

DeclareGlobalVariable("ACE_INTERACT_FUNC_OPTIONS",
  "A list of non ACE options that are used by the interactive ACE functions"
  );

DeclareGlobalVariable("ACEParameterOptions",
  Concatenation([
    "A record whose fields are the known ACE (interface) options for which\n",
    "the ACE binary has a default value."])
  );

DeclareGlobalVariable("ACEStrategyOptions",
  "A list of known ACE (interface) options that are strategy options"
  );

DeclareGlobalVariable("ACE_OPT_TRANSLATIONS",
  Concatenation([
    "A record whose fields are the known ACE (interface) options for which\n",
    "the ACE binary has a different name; its values are the ACE binary names"])
  );

DeclareGlobalVariable("ACE_OPT_ACTIONS",
  Concatenation([
    "A record whose fields are the known ACE (interface) options for which\n",
    "their is a special action; its values are the actions (as strings)"])
  );

DeclareGlobalVariable("ACE_ERRORS",
  "A record of ACE (interface) error messages"
  );

DeclareGlobalVariable("ACE_OPT_SENTINELS",
  "A record of ACE option sentinels (functions matching last lines of output)"
  );

#############################################################################
##
#D  Declare functions.
##

DeclareGlobalFunction("IS_INC_POS_INT_LIST");
DeclareGlobalFunction("IS_ACE_STRINGS");
DeclareGlobalFunction("IsKnownACEOption");
DeclareGlobalFunction("ACEPreferredOptionName");
DeclareGlobalFunction("IsACEParameterOption");
DeclareGlobalFunction("IsACEStrategyOption");
DeclareGlobalFunction("ACE_OPTIONS");
DeclareGlobalFunction("ACE_OPT_NAMES");
DeclareGlobalFunction("MATCHES_KNOWN_ACE_OPT_NAME");
DeclareGlobalFunction("FULL_ACE_OPT_NAME");
DeclareGlobalFunction("ACE_OPTION_SYNONYMS");
DeclareGlobalFunction("ACE_IF_EXPR");
DeclareGlobalFunction("ACE_VALUE_OPTION");
DeclareGlobalFunction("ACE_VALUE_OPTION_ERROR");
DeclareGlobalFunction("VALUE_ACE_OPTION");
DeclareGlobalFunction("DATAREC_VALUE_ACE_OPTION");
DeclareGlobalFunction("ACE_COSET_TABLE_STANDARD");
DeclareGlobalFunction("ACE_VALUE_ECHO");
DeclareGlobalFunction("TO_ACE_GENS");
DeclareGlobalFunction("ACE_WORDS");
DeclareGlobalFunction("ACE_RELS");
DeclareGlobalFunction("ToACEGroupGenerators");
DeclareGlobalFunction("ToACEWords");
DeclareGlobalFunction("ACE_FGENS_ARG_CHK");
DeclareGlobalFunction("ACE_WORDS_ARG_CHK");
DeclareGlobalFunction("PROCESS_ACE_OPTIONS");
DeclareGlobalFunction("PROCESS_ACE_OPTION");
DeclareGlobalFunction("ACEOptionData");
DeclareGlobalFunction("SANITISE_ACE_OPTIONS");
DeclareGlobalFunction("NEW_ACE_OPTIONS");
# For backward compatibility.
DeclareSynonym("FlushOptionsStack", ResetOptionsStack);

#E  options.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
