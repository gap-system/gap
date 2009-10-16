############################################################################
##
##  timing_samples.g                CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: timing_samples.g,v 1.3 2005/07/19 14:01:18 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
LoadPackage ("format");

groups := [
 ["format","grp/g93.gi", "g93", "31:3"],
 ["format","grp/OOF.gi", "OOF"],
 ["format","grp/ONF.gi", "ONF"],
 ["format","grp/FI22.gi", "G", "FI22"],
 ["format","grp/LUX2_12.gi", "LUX2_12"],
 ["format","grp/UPP.gi", "G", "UPP"],
 ["format","grp/DARK.gi","G", "DARK"],
 ["format","grp/LUX.gi", "G", "LUXwrS3"],
];

if IsBound (FAST_TEST) and FAST_TEST then
   groups := groups{[1..3]};
fi;


############################################################################
##
#E
##
