#############################################################################
####
##
#W  anupqhead.gd               ANUPQ package                    Werner Nickel
#W                                                                Greg Gamble
##
##  `Head' file for the GAP interface to the ANU pq binary by Eamonn O'Brien.
##    
#H  @(#)$Id: anupqhead.gd,v 1.2 2011/11/29 20:00:11 gap Exp $
##
#Y  Copyright (C) 2006  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

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
