#############################################################################
####
##
#W  anupqhead.gd               ANUPQ package                    Werner Nickel
#W                                                                Greg Gamble
##
##  `Head' file for the GAP interface to the ANU pq binary by Eamonn O'Brien.
##    
#H  @(#)$Id: anupqhead.gd,v 1.1 2006/01/24 04:42:40 gap Exp $
##
#Y  Copyright (C) 2006  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.anupqhead_gd :=
    "@(#)$Id: anupqhead.gd,v 1.1 2006/01/24 04:42:40 gap Exp $";


#############################################################################
##
#V  ANUPQData . . record used by various functions of the ANUPQ package
##
DeclareGlobalVariable( "ANUPQData",
  "A record containing various data associated with the ANUPQ package."
);

#############################################################################
##  
#I  InfoClass
##
DeclareInfoClass( "InfoANUPQ" );

#E  anupqhead.gd . . . . . . . . . . . . . . . . . . . . . . . . .  ends here 
