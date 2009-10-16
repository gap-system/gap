#############################################################################
####
##
#W  anupqopt.gd                ANUPQ package                    Werner Nickel
#W                                                                Greg Gamble
##
##  Declares functions to do with option manipulation.
##    
#H  @(#)$Id: anupqopt.gd,v 1.2 2002/03/01 14:06:09 gap Exp $
##
#Y  Copyright (C) 2001  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.anupqopt_gd :=
    "@(#)$Id: anupqopt.gd,v 1.2 2002/03/01 14:06:09 gap Exp $";

#############################################################################
##
#V  PQ_FUNCTION . . . . . . . . . internal functions called by user functions 
##
DeclareGlobalVariable( "PQ_FUNCTION", 
  Concatenation( [
    "A record whose fields are (function) names and whose values are\n",
    "the internal functions called by the functions with those names." ] )
  );

#############################################################################
##
#V  ANUPQoptions  . . . . . . . . . . . . . . . . . . . .  admissible options
##
DeclareGlobalVariable( "ANUPQoptions", 
  Concatenation( [
    "A record of lists of names of admissible ANUPQ options.\n",
    "Each field is the name of an ANUPQ function and the\n",
    "corresponding value is the list of names of admissible\n",
    "for the function." ] )
  );

#############################################################################
##
#F  AllANUPQoptions() . . . . . . . .  lists all options of the ANUPQ package
##
DeclareGlobalFunction( "AllANUPQoptions" );

#############################################################################
##
#V  ANUPQGlobalOptions . . . . .  options that can be set globally by PqStart
##
##  A list of the options that `PqStart' can set and thereby  make  available
##  to any function  interacting  with  the  {\ANUPQ}  process  initiated  by
##  `PqStart'.
##
DeclareGlobalVariable( "ANUPQGlobalOptions", 
  Concatenation( [
    "A list of the options that PqStart can set and thereby make available\n",
    "to any function interacting with the ANUPQ process initiated by PqStart."
    ] )
  );

#############################################################################
##
#V  ANUPQoptionChecks . . . . . . . . . . . the checks for admissible options
##
DeclareGlobalVariable( "ANUPQoptionChecks", 
  Concatenation( [
    "A record of lists of names of admissible ANUPQ options.\n",
    "A record whose fields are the names of admissible ANUPQ options,\n",
    "and whose values are one-argument functions that return `true' when\n",
    "given a value that is a valid value for the option, and `false'\n",
    "otherwise." ] )
  );

#############################################################################
##
#V  ANUPQoptionTypes . . . . . .  the types (in words) for admissible options
##
DeclareGlobalVariable( "ANUPQoptionTypes", 
  Concatenation( [
    "A record whose fields are the names of admissible ANUPQ options\n",
    "and whose values are words in angle brackets representing the valid\n",
    "types of the options." ] )
  );

#############################################################################
##
#F  PQ_OTHER_OPTS_CHK( <funcname>, <interactive> ) . check opts belong to f'n
##
DeclareGlobalFunction( "PQ_OTHER_OPTS_CHK" );

#############################################################################
##
#F  VALUE_PQ_OPTION( <optname> ) . . . . . . . . . enhancement of ValueOption
#F  VALUE_PQ_OPTION( <optname>, <defaultval> ) 
#F  VALUE_PQ_OPTION( <optname>, <datarec> ) 
#F  VALUE_PQ_OPTION( <optname>, <defaultval>, <datarec> ) 
##
DeclareGlobalFunction( "VALUE_PQ_OPTION" );
  
#############################################################################
##
#F  PQ_OPTION_CHECK(<basefn>,<datarec>) . check optns present/setable if nec.
##
DeclareGlobalFunction( "PQ_OPTION_CHECK" );
  
#############################################################################
##
#F  PQ_CUSTOMISE_OUTPUT(<datarec>, <subopt>, <suboptstring>, <suppstrings>)
##    
DeclareGlobalFunction( "PQ_CUSTOMISE_OUTPUT" );

#############################################################################
##
#F  PQ_APG_CUSTOM_OUTPUT(<datarec>, <subopt>, <suboptstring>, <suppstrings>)
##    
DeclareGlobalFunction( "PQ_APG_CUSTOM_OUTPUT" );

#############################################################################
##
#F  SET_ANUPQ_OPTIONS( <funcname>, <options> ) . set options from OptionStack
##    
DeclareGlobalFunction( "SET_ANUPQ_OPTIONS" );

#############################################################################
##
#F  ANUPQoptError( <funcname>, <optnames> ) . . . . . create an error message
##
DeclareGlobalFunction( "ANUPQoptError" );

#############################################################################
##
#F  ANUPQextractOptions( <funcname>, <i>, <args> ) . . . . .  extract options
##
DeclareGlobalFunction( "ANUPQextractOptions" );

#E  anupqopt.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
