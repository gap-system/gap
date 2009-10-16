#############################################################################
####
##
#W  doJ1.g              ACE Research Example                      Greg Gamble
##
##  Provides some easy applications of the pgrelfind.g functions,  using  the
##  perfect simple group J_1.
##
#H  @(#)$Id: doJ1.g,v 1.1 2001/03/11 23:01:32 gap Exp $
##
#Y  Copyright (C) 2001  Centre for Discrete Mathematics and Computing
#Y                      Department of Computer Science & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.doJ1_g :=
    "@(#)$Id: doJ1.g,v 1.1 2001/03/11 23:01:32 gap Exp $";

ACEResExample := rec(filename := "doJ1.g", print := false);
if IsBound(IsACEResExampleOK) and IsACEResExampleOK() then
  Print("gap> Print(\"J1s[13]:\\n\", J1s[13], \"\\n\");\n");
  Print("J1s[13]:\n", J1s[13], "\n");
  J1 := ACE_PRINT_AND_EVAL(
            "J1", "PGRelFind([a, b], J1s[13].rels, J1s[13].sgens)");
elif ACEResExample.print then
## Begin
Print("J1s[13]:\n", J1s[13], "\n");
J1 := PGRelFind([a, b], J1s[13].rels, J1s[13].sgens); 
## End
elif not IsBound(IsACEResExampleOK) then
  Print("Error, ACEReadResearchExample: functions and variables undefined.\n",
        "Please type: 'ACEReadResearchExample();'\n",
        "and try again.\n");
fi;

#E  doJ1.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
