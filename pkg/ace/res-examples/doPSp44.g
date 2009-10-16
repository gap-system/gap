#############################################################################
####
##
#W  doPSp44.g           ACE Research Example                      Greg Gamble
##
##  Provides some easy applications of the pgrelfind.g functions,  using  the
##  perfect simple group PSp_4(4).
##
#H  @(#)$Id: doPSp44.g,v 1.2 2001/08/21 11:40:16 gap Exp $
##
#Y  Copyright (C) 2001  Centre for Discrete Mathematics and Computing
#Y                      Department of Computer Science & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.doPSp44_g :=
    "@(#)$Id: doPSp44.g,v 1.2 2001/08/21 11:40:16 gap Exp $";

ACEResExample := rec(filename := "doPSp44.g", print := false);
if IsBound(IsACEResExampleOK) and IsACEResExampleOK() then
  Print("gap> Print(\"PSp4_4s[4]:\\n\", PSp4_4s[4], \"\\n\");\n");
  Print("PSp4_4s[4]:\n", PSp4_4s[4], "\n");
  PSp44 := 
      ACE_PRINT_AND_EVAL(
        "PSp44", 
        Concatenation(
            "TranslatePresentation([a,b], PSp4_4s[4].rels, PSp4_4s[4].sgens,\n",
            "                                    ",
            "[a, a*b])"
            )
        );
  PSp44n := 
      ACE_PRINT_AND_EVAL(
        "PSp44n",
        Concatenation(
            "PGRelFind(PSp44.fgens, PSp44.rels, PSp44.sgens\n",
            "                         : ",
            JoinStringsWithSeparator(
                     ["head := x*y*x*y^-6*x*y^7",
                      "maxTailLength := 4",
                      "minMiddleLength := 2",
                      "maxMiddleLength := 60",
                      "Nrandom := len -> 4000 * (LogInt(len + 1, 2) + 1)"],
                     ",\n                           "),
            ")"
            )
        );
elif ACEResExample.print then
## Begin
Print("PSp4_4s[4]:\n", PSp4_4s[4], "\n");
PSp44 := TranslatePresentation([a,b], PSp4_4s[4].rels, PSp4_4s[4].sgens,
                               [a, a*b]);
PSp44n := PGRelFind(PSp44.fgens, PSp44.rels, PSp44.sgens
                    : head := x*y*x*y^-6*x*y^7,
                      maxTailLength := 4,
                      minMiddleLength := 2,
                      maxMiddleLength := 60,
                      Nrandom := len -> 4000 * (LogInt(len + 1, 2) + 1)); 
## End
elif not IsBound(IsACEResExampleOK) then
  Print("Error, ACEReadResearchExample: functions and variables undefined.\n",
        "Please type: 'ACEReadResearchExample();'\n",
        "and try again.\n");
fi;

#E  doPSp44.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
