############################################################################
##
##  timing_injectors.g              CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: timing_injectors.g,v 1.5 2005/07/19 14:01:18 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
LoadPackage ("crisp");
ReadPackage ("crisp", "tst/timing_test.g");
ReadPackage ("crisp", "tst/timing_samples.g");

nilpFormat := Formation ("Nilpotent");


InjectorFromRadicalFunctionFormat :=  
   function (G, radfunc, hom)
   
      # same as usual injector method, but uses CoveringSubgroupWrtFormation
      # from the package FORMAT to compute the Carter subgroups

      local natQ, I, J, nat, H, N, C, W, i, gens, nilpser;
         
      I := radfunc (G);
      if hom then
         natQ := NaturalHomomorphismByNormalSubgroup (G, I);
         H := Image (natQ);
      else
         H := G;
      fi;
      
      # compute a normal series from I to G with nilpotent factors
      nilpser := [];
      while not IsTrivial (H) do
         Add (nilpser, H);
         H := Residual (H, NilpotentGroups);
      od;
   
      if hom then
         nilpser := Reversed (nilpser);
      else
         nilpser := List (Reversed (nilpser), H -> 
         ClosureGroup (I, H));
      fi;
      
      # treat the nilpotent factors
   
      for i in [2..Length (nilpser)] do
   
         Info (InfoInjector, 1, "starting step ",i-1);
         H := nilpser[i];
   
         # I is an F-injector of H
   
         Info (InfoInjector, 2, "computing normalizer");
   
         if i > 2 then 
            if hom then
               J := ImagesSet (natQ, I);
               nat := NaturalHomomorphismByNormalSubgroup (
                  NormalizerOfPronormalSubgroup (H, J), J);
               N := ImagesSource (nat);
            else
               N := NormalizerOfPronormalSubgroup (H, I);
            fi;
         else # otherwise I is trivial
            N := H;
         fi;
         
         Info (InfoInjector, 3, " normalizer has order ", 
            Size (N));
   
         Info (InfoInjector, 2, "computing Carter subgroup");
         C := CoveringSubgroupWrtFormation (N, nilpFormat);
         Info (InfoInjector, 3, " carter subgroup has order ", 
            Size (C));
   
         if hom then
            if i > 2 then
               W := PreImagesSet (nat, C);
            else 
               W := C;
            fi;
            W := PreImagesSet (natQ, W);
         else
            W := ClosureGroup (I, C);
         fi;
         Info (InfoInjector, 3, " preimage of carter subgroup has order ", 
            Size (W));
         
         Info (InfoInjector, 2, " computing radical");
   
         # the radical has to be computed in the full group
         I := radfunc (W);
         Info (InfoInjector, 3, " injector has order ", Size (I));
      od;
      return I;
   end;
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
			   return G;
			fi;
			comp := ChiefSeriesUnderAction (G, M);
			for j in [2..Length (comp)] do
				nat:= NaturalHomomorphismByNormalSubgroup (C, comp[j]);
				C := PreImage (nat, Centralizer (Image (nat), Image (nat, comp[j-1])));
			od;
			return C;
		end));

tests :=
[ [tmp -> Injector (tmp, O235hypercentralWithoutRad), Size, "in", []],
  [tmp -> Injector (tmp, O235hypercentralWithRad),  Size, "rad", []],
  [tmp -> InjectorFromRadicalFunctionFormat (tmp, 
  		G -> Radical (G, O235hypercentralWithRad), true), Size, "radF", []],
  [tmp -> Injector (tmp, O235hypercentralWithRad),  Size, "rad", []],
];

Print ("D_{2,3,5}-injector\n");
DoTests (groups, tests);



nilp := FittingClass (rec (\in := IsNilpotent));
metanilp := FittingProduct (nilp, nilp);
MetaNilpotentGroups := FittingProduct (NilpotentGroups, NilpotentGroups);


tests :=
[ [tmp -> Injector (tmp, metanilp), Size,  "in", []],
  [tmp -> Injector (tmp, MetaNilpotentGroups),  Size, "rad", []],
  [tmp -> InjectorFromRadicalFunctionFormat (tmp, 
  		G -> Radical (G, MetaNilpotentGroups), true), Size, "radF", []],
  [tmp -> Injector (tmp, MetaNilpotentGroups),  Size, "rad", []],
];

Print ("metanilpotent injector\n");
DoTests (groups, tests);

tests :=
[ [tmp -> Injector (tmp, nilp), Size,  "hom, in", []],
  [tmp -> Injector (tmp, NilpotentGroups),  Size, "hom, rad", []],
];

Print ("nilpotent injector\n");
DoTests (groups, tests);

23groups := PiGroups ([2,3]);
FermatPrimes := Class (p -> IsPrime (p) and p = 2^LogInt (p, 2) + 1);
class := PiGroups (FermatPrimes);

tests :=
[ [tmp -> Injector (tmp, FittingClass (rec(\in :=MemberFunction (class)))), Size,  "hom, in", []],
  [tmp -> Injector (tmp, class),  Size, "hall", []],
];

Print (class,"-injector\n");
DoTests (groups, tests);


############################################################################
##
#E
##
