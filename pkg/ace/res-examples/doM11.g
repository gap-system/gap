#############################################################################
####
##
#W  doM11.g             ACE Research Example                      Greg Gamble
##
##  Provides some easy applications of the pgrelfind.g functions,  using  the
##  perfect simple group M_11.
##
#H  @(#)$Id: doM11.g,v 1.1 2001/03/11 23:01:32 gap Exp $
##
#Y  Copyright (C) 2001  Centre for Discrete Mathematics and Computing
#Y                      Department of Computer Science & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.doM11_g :=
    "@(#)$Id: doM11.g,v 1.1 2001/03/11 23:01:32 gap Exp $";

ACEResExample := rec(filename := "doM11.g", print := false);
if IsBound(IsACEResExampleOK) and IsACEResExampleOK() then
  Print("gap> Print(\"M11:\\n\", M11, \"\\n\");\n");
  Print("M11:\n", M11, "\n");
  M11t := 
      ACE_PRINT_AND_EVAL(
        "M11t", 
        "TranslatePresentation([a,b], M11.rels, M11.sgens, [a, a*b])"
        );
  M11n := ACE_PRINT_AND_EVAL("M11n",
                             "PGRelFind(M11t.fgens, M11t.rels, M11t.sgens)");
elif ACEResExample.print then
## Begin
Print("M11:\n", M11, "\n");
M11t := TranslatePresentation([a,b], M11.rels, M11.sgens, [a, a*b]);
M11n := PGRelFind(M11t.fgens, M11t.rels, M11t.sgens); 
## End
elif not IsBound(IsACEResExampleOK) then
  Print("Error, ACEReadResearchExample: functions and variables undefined.\n",
        "Please type: 'ACEReadResearchExample();'\n",
        "and try again.\n");
fi;

#E  doM11.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
