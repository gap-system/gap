#############################################################################
##
#A  codefun.gd               GUAVA                              Reinald Baart
#A                                                        &Jasper Cramwinckel
#A                                                           &Erik Roijackers
##
##  This file contains non-dispatched functions to get info of codes
##
#H  @(#)$Id: codefun.gd,v 1.5 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/codefun_gd") :=
    "@(#)$Id: codefun.gd,v 1.5 2004/12/20 21:26:06 gap Exp $";

#############################################################################
##
#F  GuavaToLeon( <C>, <file> )  .  converts a code to a form Leon can read it
##
##  converts a code in Guava format to a library in a format that is readable
##  by Leon's programs.
##
DeclareOperation("GuavaToLeon", [IsCode, IsString]); 

#############################################################################
##
#F  WeightHistogram ( <C> [, <height>] )  . . . . .  plots the weights of <C>
##
##  The maximum length of the columns is <height>. Default height is one
##  third of the screen size.
##
DeclareOperation("WeightHistogram", [IsCode, IsInt]); 

#############################################################################
##
#F  MergeHistories( <C>, <S> [, <C1> .. <Cn> ] ) . . . . . .  list of strings
##
##
DeclareGlobalFunction("MergeHistories"); 

