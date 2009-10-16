#############################################################################
####
##
#A  anupq.gd                    ANUPQ package                  Eamonn O'Brien
#A                                                             & Frank Celler
##
##  Declaration file for ``general'' group functions and variables.
##
#A  @(#)$Id: anupq.gd,v 1.1 2002/02/15 08:53:47 gap Exp $
##
#Y  Copyright 1992-1994,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1992-1994,  School of Mathematical Sciences, ANU,     Australia
##
Revision.anupq_gd :=
    "@(#)$Id: anupq.gd,v 1.1 2002/02/15 08:53:47 gap Exp $";

#############################################################################
##
#F  ANUPQDirectoryTemporary( <dir> ) . . . . .  redefine ANUPQ temp directory
##
DeclareGlobalFunction( "ANUPQDirectoryTemporary" );

#############################################################################
##
#F  ANUPQerrorPq( <param> ) . . . . . . . . . . . . . . . . . report an error
##
DeclareGlobalFunction( "ANUPQerrorPq" );

#############################################################################
##
#F  ANUPQextractPqArgs( <args> )  . . . . . . . . . . . . . extract arguments
##
DeclareGlobalFunction( "ANUPQextractPqArgs" );

#############################################################################
##
#V  ANUPQGlobalVariables
##
DeclareGlobalVariable( "ANUPQGlobalVariables", 
                       "A list of names of ANUPQ global variables" );

#############################################################################
##
#F  ANUPQReadOutput . . . . read pq output without affecting global variables
##
DeclareGlobalFunction( "ANUPQReadOutput" );

#############################################################################
##
#F  PqEpimorphism( <arg> : <options> ) . . . . .  epimorphism onto p-quotient
##
DeclareGlobalFunction( "PqEpimorphism" );

#############################################################################
##
#F  Pq( <arg> : <options> ) . . . . . . . . . . . . . . . . . . .  p-quotient
##
DeclareGlobalFunction( "Pq" );

#############################################################################
##
#F  PqPCover( <arg> : <options> ) . . . . . .  p-covering group of p-quotient
##
DeclareGlobalFunction( "PqPCover" );

#############################################################################
##
#F  PQ_GROUP_FROM_PCP(<datarec>,<out>) . extract gp from pq pcp file into GAP
##
DeclareGlobalFunction( "PQ_GROUP_FROM_PCP" );

#############################################################################
##
#F  TRIVIAL_PQ_GROUP(<datarec>, <out>) . . . extract gp when trivial into GAP
##
DeclareGlobalFunction( "TRIVIAL_PQ_GROUP" );

#############################################################################
##
#F  PQ_EPI_OR_PCOVER(<args>:<options>) .  p-quotient, its epi. or its p-cover
##
DeclareGlobalFunction( "PQ_EPI_OR_PCOVER" );

#############################################################################
##
#F  PqRecoverDefinitions( <G> ) . . . . . . . . . . . . . . . . . definitions
##
##  This function finds a definition for each generator of the p-group <G>.
##  These definitions need not be the same as the ones used by pq.  But
##  they serve the purpose of defining each generator as a commutator or
##  power of earlier ones.  This is useful for extending an automorphism that
##  is given on a set of minimal generators of <G>.
##
DeclareGlobalFunction( "PqRecoverDefinitions" );
 
#############################################################################
##
#F  PqAutomorphism( <epi>, <autoimages> ) . . . . . . . . . . . . definitions
##
##  Take an automorphism of the preimage and produce the induced automorphism
##  of the image of the epimorphism.
##
DeclareGlobalFunction( "PqAutomorphism" );

#############################################################################
##
#F  PqLeftNormComm( <words> ) . . . . . . . . . . . . .  left norm commutator
##
DeclareGlobalFunction( "PqLeftNormComm" );

#############################################################################
##
#F  PqParseWord( <F>, <word> ) . . . . . . . . . . . . parse word through GAP
#F  PqParseWord( <n>, <word> )
##
DeclareGlobalFunction( "PqGAPRelators" );

#############################################################################
##
#F  PqParseWord( <word>, <n> ) . . . . . . . . . . . . parse word through GAP
##
DeclareGlobalFunction( "PqParseWord" );

#############################################################################
##
#F  PQ_EVALUATE( <string> ) . . . . . . . . . evaluate a string emulating GAP
##
DeclareGlobalFunction( "PQ_EVALUATE" );

#############################################################################
##
#F  PqExample() . . . . . . . . . . execute a pq example or display the index
#F  PqExample( <filename>[, PqStart] )
##
DeclareGlobalFunction( "PqExample" );

#############################################################################
##
#F  AllPqExamples() . . . . . . . . . .  list the names of all ANUPQ examples
##
DeclareGlobalFunction( "AllPqExamples" );

#############################################################################
##
#F  GrepPqExamples( <string> ) . . . . . . . grep ANUPQ examples for a string
##
DeclareGlobalFunction( "GrepPqExamples" );

#E  anupq.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
