#############################################################################
####
##
#W  doU34.g             ACE Research Example                      Greg Gamble
##
##  Provides some easy applications of the pgrelfind.g functions,  using  the
##  perfect simple group U_3(4).
##
#H  @(#)$Id: doU34.g,v 1.1 2001/03/11 23:01:32 gap Exp $
##
#Y  Copyright (C) 2001  Centre for Discrete Mathematics and Computing
#Y                      Department of Computer Science & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.doU34_g :=
    "@(#)$Id: doU34.g,v 1.1 2001/03/11 23:01:32 gap Exp $";

ACEResExample := rec(filename := "doU34.g", print := false);
if IsBound(IsACEResExampleOK) and IsACEResExampleOK() then
  Print("gap> Print(\"U3_4s[1]:\\n\", U3_4s[1], \"\\n\");\n");
  Print("U3_4s[1]:\n", U3_4s[1], "\n");
  U34 := ACE_PRINT_AND_EVAL(
             "U34", "PGRelFind([a, b], U3_4s[1].rels, U3_4s[1].sgens)");
elif ACEResExample.print then
## Begin
Print("U3_4s[1]:\n", U3_4s[1], "\n");
U34 := PGRelFind([a, b], U3_4s[1].rels, U3_4s[1].sgens); 
## End
elif not IsBound(IsACEResExampleOK) then
  Print("Error, ACEReadResearchExample: functions and variables undefined.\n",
        "Please type: 'ACEReadResearchExample();'\n",
        "and try again.\n");
fi;

#E  doU34.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
