#############################################################################
####
##
#W  doL232.g            ACE Research Example                      Greg Gamble
##
##  Provides some easy applications of the pgrelfind.g functions,  using  the
##  perfect simple group L_2(32).
##
#H  @(#)$Id: doL232.g,v 1.1 2001/03/11 23:01:32 gap Exp $
##
#Y  Copyright (C) 2001  Centre for Discrete Mathematics and Computing
#Y                      Department of Computer Science & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.doL232_g :=
    "@(#)$Id: doL232.g,v 1.1 2001/03/11 23:01:32 gap Exp $";

ACEResExample := rec(filename := "doL232.g", print := false);
if IsBound(IsACEResExampleOK) and IsACEResExampleOK() then
  Print("gap> Print(\"L2_32:\\n\", L2_32, \"\\n\");\n");
  Print("L2_32:\n", L2_32, "\n");
  L232 := 
      ACE_PRINT_AND_EVAL(
          "L232", 
          Concatenation(
              "TranslatePresentation([a,b], L2_32.rels, L2_32.sgens,\n",
              "             ",
              "                      [a^3*b, a^2*b])"
              )
          );
  L232n := ACE_PRINT_AND_EVAL("L232n",
                              "PGRelFind(L232.fgens, L232.rels, L232.sgens)");
elif ACEResExample.print then
## Begin
Print("L2_32:\n", L2_32, "\n");
L232 := TranslatePresentation([a,b], L2_32.rels, L2_32.sgens, 
                              [a^3*b, a^2*b]);
L232n := PGRelFind(L232.fgens, L232.rels, L232.sgens); 
## End
elif not IsBound(IsACEResExampleOK) then
  Print("Error, ACEReadResearchExample: functions and variables undefined.\n",
        "Please type: 'ACEReadResearchExample();'\n",
        "and try again.\n");
fi;

#E  doL232.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
