#############################################################################
####
##
#W  doL28.g             ACE Research Example                      Greg Gamble
##
##  Provides some easy applications of the pgrelfind.g functions,  using  the
##  perfect simple group L_2(8).
##
#H  @(#)$Id: doL28.g,v 1.4 2001/08/21 11:40:16 gap Exp $
##
#Y  Copyright (C) 2000  Centre for Discrete Mathematics and Computing
#Y                      Department of Computer Science & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.doL28_g :=
    "@(#)$Id: doL28.g,v 1.4 2001/08/21 11:40:16 gap Exp $";

ACEResExample := rec(filename := "doL28.g", print := false);
if IsBound(IsACEResExampleOK) and IsACEResExampleOK() then
  Print("gap> Print(\"L2_8:\\n\", L2_8, \"\\n\");\n");
  Print("L2_8:\n", L2_8, "\n");
  L28 := 
      ACE_PRINT_AND_EVAL(
          "L28", 
          Concatenation(
              "TranslatePresentation([a,b], L2_8.rels, L2_8.sgens,\n",
              "            ",
              "                      [a^3*b, a^2*b])"
              )
          );
  ACEResExample.options :=
      [ "ACEworkspace := 2 * 10^3",
        "head := x*y*x*y*x*y^-1*x*y*x*y",
        "Ntails := 256",
        "maxTailLength := 6",
        "minMiddleLength := 4",
        "maxMiddleLength := 20",
        "Nrandom := 1000",
        "Nrandom := len -> 1000 * (LogInt(len + 1, 2) + 1)"];
  ACEResExample.option := ValueOption("optex");
  if ACEResExample.option = fail then
    ACEResExample.option := [];
  elif IsPosInt(ACEResExample.option) then
    ACEResExample.option := [ ACEResExample.option ];
  fi;
  if IsList(ACEResExample.option) and 
     IsSubset([1 .. Length(ACEResExample.options)], ACEResExample.option) then
    L28n := 
        ACE_PRINT_AND_EVAL(
            "L28n",
            Concatenation(
                "PGRelFind(L28.fgens, L28.rels, L28.sgens\n",
                "                       : ",
                JoinStringsWithSeparator(
                    List(ACEResExample.option, 
                         i -> ACEResExample.options[i]),
                    ",\n                         "),
                ")"
                )
            );
    Print("\nWould you like to try another option example?\n");
  else
    Print("Error, illegal value for option `optex'.\n",
          "Usage: 'ACEReadResearchExample(\"doL28.g\" [: optex := <n>]);'\n",
          "       'ACEReadResearchExample(\"doL28.g\" [: optex := <list>);'\n",
          "where <n> is an integer, or <list> is a list of integers,\n",
          "in the range [1 .. ",
          Length(ACEResExample.options), "]\n");
  fi;
  Print("\nThe table below indicates the equivalent action of ",
        "'optex := <n>':\n\n",
        "    Value of <n>    Equivalent to\n",
        "    ------------    -------------\n");
  ACEResExample.i := 1;
  repeat
    Print("         ", ACEResExample.i, "          '", 
          ACEResExample.options[ACEResExample.i], "'\n");
    ACEResExample.i := ACEResExample.i + 1;
  until ACEResExample.i > Length(ACEResExample.options);
  Print("\nNote: `optex' may also be a list containing a subset ",
        "of the above <n>.\n");

elif ACEResExample.print then
## Begin
Print("L2_8:\n", L2_8, "\n");
L28 := TranslatePresentation([a,b], L2_8.rels, L2_8.sgens, [a^3*b, a^2*b]);
# Using option "ACEworkspace" (default is 10^6)
L28n := PGRelFind(L28.fgens, L28.rels, L28.sgens 
                  : ACEworkspace := 2 * 10^3);
# Using option "head" (default is x*y*x*y*x*y^-1)
L28n := PGRelFind(L28.fgens, L28.rels, L28.sgens 
                  : head := x*y*x*y*x*y^-1*x*y*x*y);
# Using option "Ntails" ... Ntails should be <= 2048 (default)
L28n := PGRelFind(L28.fgens, L28.rels, L28.sgens 
                  : Ntails := 256);
# Using option "maxTailLength" (overrides Ntails if used)
L28n := PGRelFind(L28.fgens, L28.rels, L28.sgens 
                  : maxTailLength := 6);
# Using option "minMiddleLength" (default is 0)
L28n := PGRelFind(L28.fgens, L28.rels, L28.sgens 
                  : minMiddleLength := 4);
# Using option "maxMiddleLength" (default is 30)
L28n := PGRelFind(L28.fgens, L28.rels, L28.sgens 
                  : maxMiddleLength := 20);
# Using option "Nrandom" (default is 0 = sequential and exhaustive)
L28n := PGRelFind(L28.fgens, L28.rels, L28.sgens 
                  : Nrandom := 1000);
# Using option "Nrandom" again ... but this time Nrandom is a function
#                                  of middle length
L28n := PGRelFind(L28.fgens, L28.rels, L28.sgens
                  : Nrandom := len -> 1000 * (LogInt(len + 1, 2) + 1));
## End
else
  Print("Error, ACEReadResearchExample: functions and variables undefined.\n",
        "Please type: 'ACEReadResearchExample();'\n",
        "and try again.\n");
fi;

#E  doL28.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
