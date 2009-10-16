############################################################################
##
##  timing_normals.g                CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: timing_normals.g,v 1.3 2005/07/19 14:01:18 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
if TestPackageAvailability ("crisp", "1.0") <> true then
   NormalSubgroupsSolvableOld := 
   	ApplicableMethod (NormalSubgroups, [DihedralGroup (8)]);
else
	Info (InfoWarning, 1, 
		"Cannot test library method for soluble groups because CRISP is already loaded");
fi;

LoadPackage ("crisp");
ReadPackage ("crisp", "tst/timing_test.g");
ReadPackage ("crisp", "tst/timing_samples.g");

Sizes := l -> Collected (List (l, Size));


tests :=
[ 
  [tmp -> NormalSubgroups (tmp), Sizes, "new", ["UPP",]],
  [tmp -> NormalSubgroupsAbove( tmp, TrivialSubgroup( tmp ), []),  Sizes, "class", ["DARK/6", "DARK", "UPP", "LUXwrS3"]],
];

if IsBound (NormalSubgroupsSolvableOld) then
   tests[3] := tests[2];
   tests[2] := [tmp ->  NormalSubgroupsSolvableOld (tmp), Sizes, "oldsolv", ["UPP",]];
fi;

Print ("normal subgroups\n");
DoTests (groups, tests);


############################################################################
##
#E
##
