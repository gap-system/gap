############################################################################
##
##  print.g                         CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: print.g,v 1.3 2005/07/19 14:01:18 gap Exp $
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
   for j in [i..Length (cl)] do
      I := Intersection (cl[i], cl[j]);
      if InfoLevel (InfoTest) >= 3 then
         View (I);
         Print ("\n");
      fi;
      View (P);
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
