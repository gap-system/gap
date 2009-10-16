#############################################################################
####
##
#W  doGrp.g             ACE Research Example                      Greg Gamble
##
##  Provides  a  generic  way  of  trying  some  easy  applications  of   the
##  pgrelfind.g functions.
##
#H  @(#)$Id: doGrp.g,v 1.3 2001/08/21 11:40:16 gap Exp $
##
#Y  Copyright (C) 2001  Centre for Discrete Mathematics and Computing
#Y                      Department of Computer Science & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.doGrp_g :=
    "@(#)$Id: doGrp.g,v 1.3 2001/08/21 11:40:16 gap Exp $";

ACEResExample := rec(filename := "doGrp.g", print := false);
if IsBound(IsACEResExampleOK) and IsACEResExampleOK() then
  Print(
    "# IsACEResExampleOK() sets ACEResExample.grp     from options grp, n\n",
    "#                          ACEResExample.newgens from option  newgens\n");
  if ACEResExample.newgens <> fail then
    ACEResExample.G :=
        ACE_PRINT_AND_EVAL(
            "ACEResExample.G",
            JoinStringsWithSeparator(
                     ["TranslatePresentation([a, b],",
                      "ACEResExample.grp.rels,",
                      "ACEResExample.grp.sgens,",
                      "ACEResExample.newgens)"],
                     "\n                                              ")
            );
    ACEResExample.Gn :=
        ACE_PRINT_AND_EVAL(
            "ACEResExample.Gn",
            JoinStringsWithSeparator(
                     ["PGRelFind(ACEResExample.G.fgens,",
                      "ACEResExample.G.rels,",
                      "ACEResExample.G.sgens)"],
                     "\n                                   ")
            );
  else
    ACEResExample.G :=
        ACE_PRINT_AND_EVAL(
            "ACEResExample.G",
            JoinStringsWithSeparator(
                     ["PGRelFind([a, b],",
                      "ACEResExample.grp.rels,",
                      "ACEResExample.grp.sgens)"],
                     "\n                                  ")
            );
  fi;
elif ACEResExample.print then
## Begin
# IsACEResExampleOK() sets ACEResExample.grp     from options grp, n
#                          ACEResExample.newgens from option  newgens
if ACEResExample.newgens <> fail then
  ACEResExample.G := TranslatePresentation([a, b],
                                           ACEResExample.grp.rels,
                                           ACEResExample.grp.sgens,
                                           ACEResExample.newgens);
  ACEResExample.Gn := PGRelFind(ACEResExample.G.fgens,
                                ACEResExample.G.rels,
                                ACEResExample.G.sgens);
else
  ACEResExample.G := PGRelFind([a, b],
                               ACEResExample.grp.rels,
                               ACEResExample.grp.sgens);
fi;
## End
elif not IsBound(IsACEResExampleOK) then
  Print("Error, ACEReadResearchExample: functions and variables undefined.\n",
        "Please type: 'ACEReadResearchExample();'\n",
        "and try again.\n");
fi;

#E  doGrp.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
