############################################################################
##
##  timing_socle.g                 CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: timing_socle.g,v 1.2 2005/07/19 14:01:18 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##

LoadPackage ("crisp");
ReadPackage ("crisp", "tst/timing_test.g");
ReadPackage ("crisp", "tst/timing_samples.g");



tests :=
[ 
  [Socle, Size, "new", []],
  [Socle, Size, "Fit", [], FittingSubgroup],
  [G -> List (Set (FactorsInt (Size (G))), p -> PSocle (G, p)), 
  	l -> Product (l, Size), "psoc", []],
  [G -> List (Set (FactorsInt (Size (G))), p -> PSocle (G, p)), 
  	l -> Product (l, Size), "psoc", [], Socle],
];


Print ("Socle\n");
DoTests (groups, tests);


############################################################################
##
#E
##
