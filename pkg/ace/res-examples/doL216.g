#############################################################################
####
##
#W  doL216.g            ACE Research Example                      Greg Gamble
##
##  Provides some easy applications of the pgrelfind.g functions,  using  the
##  perfect simple group L_2(16).
##
#H  @(#)$Id: doL216.g,v 1.1 2001/03/11 23:01:32 gap Exp $
##
#Y  Copyright (C) 2001  Centre for Discrete Mathematics and Computing
#Y                      Department of Computer Science & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.doL216_g :=
    "@(#)$Id: doL216.g,v 1.1 2001/03/11 23:01:32 gap Exp $";

ACEResExample := rec(filename := "doL216.g", print := false);
if IsBound(IsACEResExampleOK) and IsACEResExampleOK() then
  Print("gap> Print(\"L2_16:\\n\", L2_16, \"\\n\");\n");
  Print("L2_16:\n", L2_16, "\n");
  L216 := 
      ACE_PRINT_AND_EVAL(
          "L216", 
          Concatenation(
              "TranslatePresentation([a,b], L2_16.rels, L2_16.sgens,\n",
              "             ",
              "                      [a^3*b, a^2*b])"
              )
          );
  L216n := ACE_PRINT_AND_EVAL("L216n",
                              "PGRelFind(L216.fgens, L216.rels, L216.sgens)");
elif ACEResExample.print then
## Begin
Print("L2_16:\n", L2_16, "\n");
L216 := TranslatePresentation([a,b], L2_16.rels, L2_16.sgens, 
                              [a^3*b, a^2*b]);
L216n := PGRelFind(L216.fgens, L216.rels, L216.sgens); 
## End
elif not IsBound(IsACEResExampleOK) then
  Print("Error, ACEReadResearchExample: functions and variables undefined.\n",
        "Please type: 'ACEReadResearchExample();'\n",
        "and try again.\n");
fi;

#E  doL216.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
