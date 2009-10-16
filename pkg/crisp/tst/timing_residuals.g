############################################################################
##
##  timing_residuals.g              CRISP                 Burkhard H\"ofling
##
##  @(#)$ $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
LoadPackage ("crisp");
ReadPackage ("crisp", "tst/timing_test.g");
ReadPackage ("crisp", "tst/timing_samples.g");


nilp := SaturatedFormation (rec (\in := IsNilpotent, 
   locdef := LocalDefinitionFunction (NilpotentGroups),
   char := AllPrimes));

nilp2 := SaturatedFormation (rec (\in := IsNilpotent, 
   char := AllPrimes));

tests :=
[ [tmp -> Residual (tmp, nilp), Size, "locdef", []],
  [tmp -> Residual (tmp, nilp2), Size, "in", []],
  [tmp -> Residual (tmp, NilpotentGroups),  Size, "res", []],
];

Print ("nilpotent residual\n");
DoTests (groups, tests);

23groups := PiGroups ([2,3]);
23groups2 := SaturatedFormation (rec (
   \in := MemberFunction (23groups),
   locdef := LocalDefinitionFunction (23groups),
   char := [2,3]));
   
23groups3 := SaturatedFormation (rec (
   \in := MemberFunction (23groups),
   char := [2,3]));

tests :=
[ [tmp -> Residual (tmp, 23groups2), Size, "locdef", []],
  [tmp -> Residual (tmp, 23groups3), Size, "in", []],
  [tmp -> Residual (tmp, 23groups),  Size, "res", []],
];

Print ("[2,3]-residual\n");
DoTests (groups, tests);

2groups := PGroups (2);
2groups2 := SaturatedFormation (rec (
   \in := MemberFunction (2groups),
   locdef := LocalDefinitionFunction (2groups),
   char := [2]));
   
2groups3 := SaturatedFormation (rec (
   \in := MemberFunction (2groups),
   char := [2]));
   
tests :=
[ [tmp -> Residual (tmp, 2groups2), Size, "locdef", []],
  [tmp -> Residual (tmp, 2groups3), Size, "in", []],
  [tmp -> Residual (tmp, 2groups),  Size, "res", []],
];

Print ("2-residual\n");
DoTests (groups, tests);

nilp23 := Intersection (NilpotentGroups, PiGroups ([2,3]));
nilp23_2 := SaturatedFormation (rec (
   \in := G -> IsNilpotent (G) and MemberFunction (23groups)(G),
   locdef := function (G, p)
      if p in [2,3] then
         return LocalDefinitionFunction (NilpotentGroups)(G, p);
      else
         return fail;
      fi;
   end,
   char := [2,3]));
   
nilp23_3 := SaturatedFormation (rec (
   \in := G -> IsNilpotent (G) and MemberFunction (23groups)(G),
   char := [2,3]));

tests :=
[ [tmp -> Residual (tmp, nilp23_2), Size, "locdef", []],
  [tmp -> Residual (tmp, nilp23_3), Size, "in", []],
  [tmp -> Residual (tmp, nilp23),  Size, "res", []],
];


Print ("nilp.[2,3]-residual\n");
DoTests (groups, tests);


############################################################################
##
#E
##
