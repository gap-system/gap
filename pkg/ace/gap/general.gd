#############################################################################
####
##
#W  general.gd                 ACE Package                        Greg Gamble
##
##  This file declares mainly non-interactive ACE variables and functions.
##    
#H  @(#)$Id: general.gd,v 1.12 2006/01/26 16:11:31 gap Exp $
##
#Y  Copyright (C) 2000  Centre for Discrete Mathematics and Computing
#Y                      Department of Information Technology & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.("ace/gap/general_gd") :=
    "@(#)$Id: general.gd,v 1.12 2006/01/26 16:11:31 gap Exp $";


#############################################################################
##
#D  Declare variable.
##

DeclareGlobalVariable("ACETCENUM",
  "The ACE (Advanced Coset Enumerator) version of the coset enumerator TCENUM"
  );

#############################################################################
##
#D  Declare functions.
##

DeclareGlobalFunction("InfoACELevel");
DeclareGlobalFunction("SetInfoACELevel");
DeclareGlobalFunction("ACEPackageVersion");
DeclareGlobalFunction("CALL_ACE");
DeclareGlobalFunction("ACECosetTableFromGensAndRels");
DeclareGlobalFunction("IsACEStandardCosetTable");
DeclareGlobalFunction("IsACEGeneratorsInPreferredOrder");
DeclareGlobalFunction("ACE_READ_AS_FUNC");
DeclareGlobalFunction("ACEExample");
DeclareGlobalFunction("ACEReadResearchExample");
DeclareGlobalFunction("ACEPrintResearchExample");
DeclareGlobalFunction("ACEDirectoryTemporary");
DeclareGlobalFunction("ACE_ERROR");

#############################################################################
##
#D  Declare deprecated function.
##

DeclareGlobalFunction("CallACE");

#E  general.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
