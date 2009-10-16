#############################################################################
####
##
#W  doU33.g             ACE Research Example                      Greg Gamble
##
##  Provides some easy applications of the pgrelfind.g functions,  using  the
##  perfect simple group U_3(3).
##
#H  @(#)$Id: doU33.g,v 1.1 2001/03/11 23:01:32 gap Exp $
##
#Y  Copyright (C) 2001  Centre for Discrete Mathematics and Computing
#Y                      Department of Computer Science & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.doU33_g :=
    "@(#)$Id: doU33.g,v 1.1 2001/03/11 23:01:32 gap Exp $";

ACEResExample := rec(filename := "doU33.g", print := false);
if IsBound(IsACEResExampleOK) and IsACEResExampleOK() then
  Print("gap> Print(\"U3_3s[1]:\\n\", U3_3s[1], \"\\n\");\n");
  Print("U3_3s[1]:\n", U3_3s[1], "\n");
  U33 := 
      ACE_PRINT_AND_EVAL(
        "U33", 
        "TranslatePresentation([a,b], U3_3s[1].rels, U3_3s[1].sgens, [a, a*b])"
        );
  U33n := ACE_PRINT_AND_EVAL("U33n",
                             "PGRelFind(U33.fgens, U33.rels, U33.sgens)");
elif ACEResExample.print then
## Begin
Print("U3_3s[1]:\n", U3_3s[1], "\n");
U33 := TranslatePresentation([a,b], U3_3s[1].rels, U3_3s[1].sgens, [a, a*b]);
U33n := PGRelFind(U33.fgens, U33.rels, U33.sgens); 
## End
elif not IsBound(IsACEResExampleOK) then
  Print("Error, ACEReadResearchExample: functions and variables undefined.\n",
        "Please type: 'ACEReadResearchExample();'\n",
        "and try again.\n");
fi;

#E  doU33.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
