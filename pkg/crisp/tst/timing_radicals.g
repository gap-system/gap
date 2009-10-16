############################################################################
##
##  timing_radicals.g               CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: timing_radicals.g,v 1.8 2005/07/19 14:01:18 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
LoadPackage ("crisp");
ReadPackage ("crisp", "tst/timing_test.g");
ReadPackage ("crisp", "tst/timing_samples.g");

IsHypercentral := function (G, H)

	local C;

	repeat
		C := H;
		H := CommutatorSubgroup (G, H);
	until C = H;
	return IsTrivial (H);
end;

O235hypercentralWithoutRad := FittingClass ( rec (
	\in := G -> IsHypercentral (G, Core (G, HallSubgroup (G,[2,3,5])))
));

O235hypercentralWithRad := FittingClass ( rec (
	\in := G -> IsHypercentral (G, Core (G, HallSubgroup (G,[2,3,5]))),
	rad := function (G)
			local C, ser, comp, i, j, M, N, F, nat;
			C := G;
			M := Core (G, HallSubgroup (G,[2,3,5]));
			if IsTrivial (M) then 
			   return C;
			   fi;
			comp := ChiefSeriesUnderAction (G, M);
			for j in [2..Length (comp)] do
				nat:= NaturalHomomorphismByNormalSubgroup (C, comp[j]);
				C := PreImage (nat, Centralizer (Image (nat), Image (nat, comp[j-1])));
			od;
			return C;
		end));


tests :=
[ [tmp -> Radical (tmp, O235hypercentralWithoutRad), Size, "in", []],
  [tmp -> Radical (tmp, O235hypercentralWithRad),  Size, "rad", []],
];

Print ("D_{2,3,5}-radical\n");
DoTests (groups, tests);



nilp := FittingClass (rec (\in := IsNilpotent));
fit := function (G)
   local pcgs, p, newpcgs, pcser, depths, x;
   
   pcgs := Pcgs (G);
   pcser := [];
   depths := [];
   for p in Set (Factors (Size (G))) do
      newpcgs := Pcgs (OneInvariantSubgroupMaxWrtNProperty (G, G, 
           function (U, V, R, data) 
              return Index (U, V) mod data = 0;
           end, 
           ReturnFail, 
           p));
        for x in newpcgs do
           AddPcElementToPcSequence (pcgs, pcser, depths, x);
        od;
    od;
    return GroupOfPcgs (InducedPcgsByPcSequenceNC (
       pcgs, pcser));
end;

tests :=
[ [tmp -> Radical (tmp, nilp), Size, "rad", []],
  [tmp -> Radical (tmp, NilpotentGroups),  Size, "fit", []],
  [fit, Size, "newfit", []],
];

Print ("nilpotent radical\n");
DoTests (groups, tests);

metanilp := FittingProduct (nilp, nilp);
MetanilpotentGroups := FittingProduct (NilpotentGroups, NilpotentGroups);

tests :=
[ [tmp -> Radical (tmp, metanilp), Size, "rad", []],
  [tmp -> Radical (tmp, MetanilpotentGroups),  Size, "fit2", []],
];
Print ("metanilpotent radical\n");
DoTests (groups, tests);


23groups := PiGroups ([2,3]);
23groups2 := FittingClass (rec(\in := MemberFunction (23groups),
  char := [2,3]));
  
tests := 
[ [tmp -> Radical (tmp, 23groups2), Size, "in", []],
  [tmp -> Radical (tmp, 23groups),  Size, "core", []],
];

Print ("[2,3]-radical\n");
DoTests (groups, tests);

2groups := PGroups (2);
2groups2 := FittingClass (rec(\in := MemberFunction (2groups),
  char := [2]));
  
tests := 
[ [tmp -> Radical (tmp, 2groups2), Size, "in", []],
  [tmp -> Radical (tmp, 2groups),  Size, "core", []],
  [tmp -> OneInvariantSubgroupMaxWrtNProperty (tmp, tmp, 
     function (U, V, R, data) 
        return Index (U, V) mod 2 = 0;
     end, 
     ReturnFail, 
     rec ()), Size, "Nprop", []],
];
Print ("2-radical\n");
DoTests (groups, tests);

5groups := PGroups (5);
5groups5 := FittingClass (rec(\in := MemberFunction (5groups),
  char := [5]));
  
tests := 
[ [tmp -> Radical (tmp, 5groups5), Size, "in", []],
  [tmp -> Radical (tmp, 5groups),  Size, "core", []],
  [tmp -> OneInvariantSubgroupMaxWrtNProperty (tmp, tmp, 
     function (U, V, R, data) 
        return Index (U, V) mod 5 = 0;
     end, 
     ReturnFail, 
     rec ()), Size, "Nprop", []],
];
Print ("5-radical\n");
DoTests (groups, tests);

nilp23 := Intersection (NilpotentGroups, PiGroups ([2,3]));
   
nilp23_3 := FittingClass (rec (
   \in := G -> IsNilpotent (G) and MemberFunction (23groups)(G),
   char := [2,3]));
   
tests :=
[ [tmp -> Radical (tmp, nilp23_3), Size, "in", []],
  [tmp -> Radical (tmp, nilp23),  Size, "res", []],
];


Print ("nilp.[2,3]-residual\n");
DoTests (groups, tests);


############################################################################
##
#E
##
