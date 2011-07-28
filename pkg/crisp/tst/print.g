############################################################################
##
##  print.g                         CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: print.g,v 1.4 2011/05/26 10:01:17 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
LoadPackage ("crisp");
ReadPackage ("crisp", "tst/samples.g");

if PRINT_METHODS then
   TraceMethods (PrintObj, ViewObj);
fi;

old := fail;
cl := classes(); 
for i in [1..Length (cl)] do
   View (cl[i]);
   Print ("\n",cl[i], "\n");
   for j in [i+1..Length (cl)] do
      I := Intersection (cl[i], cl[j]);
      View (I);
      Print ("\n", I, "\n");
   od;
od;
for C in cl do
   SetIsOrdinaryFormation (C, true);
od;
for C in cl do
   for D in cl do
      P := FormationProduct (C, D);
      View (P);
      Print ("\n", P, "\n");
   od;
od;
cl := classes(); 
for C in cl do
   SetIsFittingClass (C, true);
od;
for C in cl do
   for D in cl do
      P := FittingProduct (C, D);
      View (P);
      Print ("\n", P, "\n");
   od;
od;

if PRINT_METHODS then
   UntraceMethods (PrintObj, ViewObj);
fi;


############################################################################
##
#E
##
