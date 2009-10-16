#############################################################################
####
##
#A  anustab.gd                  ANUPQ package                  Eamonn O'Brien
#A                                                              Werner Nickel
##
#A  @(#)$Id: anustab.gd,v 1.1 2002/02/15 08:53:47 gap Exp $
##
#Y  Copyright 1993-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1993-2001,  School of Mathematical Sciences, ANU,     Australia
##
#W  Greg Gamble reformulated the original code as a function and  then  split
#W  the original `anustab.g' into the declare/install files anustab.g[di].
##
##  Declare file for function to  compute  the  stabiliser  of  an  allowable
##  subgroup; description is written to file LINK_output.
##
Revision.anustab_gd :=
    "@(#)$Id: anustab.gd,v 1.1 2002/02/15 08:53:47 gap Exp $";

#############################################################################
##
#F  PqStabiliserOfAllowableSubgroup( )
##
DeclareGlobalFunction( "PqStabiliserOfAllowableSubgroup" );

#E  anustab.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
