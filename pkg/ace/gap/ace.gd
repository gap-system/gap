#############################################################################
####
##
#W  ace.gd                     ACE Package                   Alexander Hulpke
#W                                                                Greg Gamble
##
##  `Head' file for the GAP interface to the ACE (Advanced Coset Enumerator),
##  by George Havas and Colin Ramsay.  The original interface was written  by 
##  Alexander Hulpke and extensively modified by Greg Gamble.
##    
#H  @(#)$Id: ace.gd,v 1.1 2006/01/26 16:11:31 gap Exp $
##
#Y  Copyright (C) 2006  Centre for Discrete Mathematics and Computing
#Y                      Department of Information Technology & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.("ace/gap/ace_gd") :=
    "@(#)$Id: ace.gd,v 1.1 2006/01/26 16:11:31 gap Exp $";


#############################################################################
####
##
#V  ACEData . . . . . . . record used by various functions of the ACE package
##
DeclareGlobalVariable( "ACEData",
  "A record containing various data associated with the ACE package."
  );

#############################################################################
##
#I  InfoClass
##
DeclareInfoClass("InfoACE");

#E  ace.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here 
