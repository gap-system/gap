#@local G,epi,p,check
gap> START_TEST("schur.tst");

# `EpimorphismSchurCover' must return a stem extension of the right size
gap> check:=function(G)
>      local epi,D,ker;
>      epi:=EpimorphismSchurCover(G);
>      D:=Source(epi);
>      ker:=KernelOfMultiplicativeGeneralMapping(epi);
>      if Image(epi)<>G then return "not surjective"; fi;
>      if not IsCentral(D,ker) then return "kernel not central"; fi;
>      if not IsSubset(DerivedSubgroup(D),ker) then
>        return "not a stem extension"; fi;
>      if Size(D)<>Size(G)*Size(ker) then return "wrong size"; fi;
>      if AbelianInvariants(ker)<>AbelianInvariantsMultiplier(G) then
>        return "inconsistent with AbelianInvariantsMultiplier"; fi;
>      return true;
>    end;;

# larger groups, compared with the multipliers listed in the ATLAS
gap> AbelianInvariantsMultiplier(MathieuGroup(11));
[  ]
gap> AbelianInvariantsMultiplier(MathieuGroup(12));
[ 2 ]
gap> AbelianInvariantsMultiplier(MathieuGroup(22));
[ 3, 4 ]
gap> AbelianInvariantsMultiplier(MathieuGroup(23));
[  ]
gap> AbelianInvariantsMultiplier(AlternatingGroup(7));
[ 2, 3 ]
gap> AbelianInvariantsMultiplier(AlternatingGroup(8));
[ 2 ]
gap> AbelianInvariantsMultiplier(PSL(2,25));
[ 2 ]
gap> AbelianInvariantsMultiplier(PSL(3,4));
[ 3, 4, 4 ]
gap> AbelianInvariantsMultiplier(PSU(4,2));
[ 2 ]
gap> AbelianInvariantsMultiplier(SP(6,2));
[ 2 ]
gap> AbelianInvariantsMultiplier(SuzukiGroup(8));
[ 2, 2 ]

# `SchuMu' returns the p-part of the multiplier
gap> G:=MathieuGroup(22);;
gap> for p in [2,3,5,7,11] do
>      Print(p,": ",AbelianInvariants(Kernel(SchuMu(G,p))),"\n");
>    od;
2: [ 4 ]
3: [ 3 ]
5: [  ]
7: [  ]
11: [  ]

#
gap> check(AlternatingGroup(6));
true
gap> check(SmallGroup(96,64));
true
gap> check(PSL(2,11));
true

# matrix groups are handled via a permutation image; the cover is a finitely
# presented group, so anything beyond its order is expensive to verify here
gap> epi:=EpimorphismSchurCover(SP(6,2));;
gap> Size(Kernel(epi));
2
gap> Size(Source(epi))=2*Size(SP(6,2));
true

#
gap> STOP_TEST("schur.tst");
