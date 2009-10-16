#############################################################################
####
##
#W  doL33.g             ACE Research Example                      Greg Gamble
##
##  Provides some easy applications of the pgrelfind.g functions,  using  the
##  perfect simple group L_3(3).
##
#H  @(#)$Id: doL33.g,v 1.1 2001/03/11 23:01:32 gap Exp $
##
#Y  Copyright (C) 2001  Centre for Discrete Mathematics and Computing
#Y                      Department of Computer Science & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.doL33_g :=
    "@(#)$Id: doL33.g,v 1.1 2001/03/11 23:01:32 gap Exp $";

ACEResExample := rec(filename := "doL33.g", print := false);
if IsBound(IsACEResExampleOK) and IsACEResExampleOK() then
  Print("gap> Print(\"L3_3s[1]:\\n\", L3_3s[1], \"\\n\");\n");
  Print("L3_3s[1]:\n", L3_3s[1], "\n");
  L33 := ACE_PRINT_AND_EVAL(
             "L33", "PGRelFind([a, b], L3_3s[1].rels, L3_3s[1].sgens)");
elif ACEResExample.print then
## Begin
Print("L3_3s[1]:\n", L3_3s[1], "\n");
L33 := PGRelFind([a, b], L3_3s[1].rels, L3_3s[1].sgens); 
## End
elif not IsBound(IsACEResExampleOK) then
  Print("Error, ACEReadResearchExample: functions and variables undefined.\n",
        "Please type: 'ACEReadResearchExample();'\n",
        "and try again.\n");
fi;

#E  doL33.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
