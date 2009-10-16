############################################################################
##
##  in.g                            CRISP                 Burkhard H\"ofling
##
##  @(#)$ $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
LoadPackage ("crisp");
ReadPackage ("crisp", "tst/samples.g");

if PRINT_METHODS then
   TraceMethods (IsMemberOp);
fi;

for G in groups do
   Info (InfoTest, 1, G());
   old := fail;
   cl := classes(); 
   for i in [1..Length (cl)] do
      if InfoLevel (InfoTest) >= 2 then
         View (cl[i]);
         Print ("\n");
      fi;
      new := G() in cl[i];
      if old = fail then
         old := new;
      elif old <> new then
         Error ("different results");
      fi;
      for j in [i..Length (cl)] do
         I := Intersection (cl[i], cl[j]);
         if InfoLevel (InfoTest) >= 3 then
            View (I);
            Print ("\n");
         fi;
         new := G() in I;
         if old <> new then
            Error ("different results");
         fi;
      od;
   od;
   cl := classes(); 
   for C in cl do
      SetIsOrdinaryFormation (C, true);
   od;
   for C in cl do
      for D in cl do
         P := FormationProduct (C, D);
         if InfoLevel (InfoTest) >= 3 then
            View (C, "by", D);
            Print ("\n");
         fi;
         new := G() in P;
         if old <> new then
            Error ("different results");
         fi;
      od;
   od;
   cl := classes(); 
   for C in cl do
      SetIsFittingClass (C, true);
   od;
   for C in cl do
      for D in cl do
         P := FittingProduct (C, D);
         if InfoLevel (InfoTest) >= 3 then
            View (C, "by", D);
            Print ("\n");
         fi;
         new := G() in P;
         if old <> new then
            Error ("different results");
         fi;
      od;
   od;
od;

if PRINT_METHODS then
   UntraceMethods (IsMemberOp);
fi;

############################################################################
##
#E
##
