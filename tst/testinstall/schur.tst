#@local G,epi,check
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

#
gap> AbelianInvariantsMultiplier(TrivialGroup(IsPermGroup));
[  ]
gap> AbelianInvariantsMultiplier(CyclicGroup(60));
[  ]

# for an abelian group with invariants n_i the multiplier is the direct sum
# of the cyclic groups of order gcd(n_i,n_j) for i<j
gap> AbelianInvariantsMultiplier(AbelianGroup([4,4,2]));
[ 2, 2, 4 ]
gap> AbelianInvariantsMultiplier(AbelianGroup([6,6]));
[ 2, 3 ]
gap> AbelianInvariantsMultiplier(AbelianGroup([12,6,2]));
[ 2, 2, 2, 3 ]

#
gap> AbelianInvariantsMultiplier(SymmetricGroup(4));
[ 2 ]
gap> AbelianInvariantsMultiplier(AlternatingGroup(6));
[ 2, 3 ]
gap> AbelianInvariantsMultiplier(SL(2,3));
[  ]
gap> AbelianInvariantsMultiplier(SL(3,2));
[ 2 ]

# the multiplier of a finitely presented group
gap> G:=FreeGroup("a","b");;
gap> G:=G/ParseRelators(G,"a2,b3,(ab)5");;
gap> AbelianInvariantsMultiplier(G);
[ 2 ]

# `SchurCover' is the source of `EpimorphismSchurCover', for every group
gap> IsIdenticalObj(SchurCover(G),Source(EpimorphismSchurCover(G)));
true
gap> G:=DihedralGroup(8);;
gap> IsIdenticalObj(SchurCover(G),Source(EpimorphismSchurCover(G)));
true
gap> G:=SymmetricGroup(4);;
gap> IsIdenticalObj(SchurCover(G),Source(EpimorphismSchurCover(G)));
true

# groups for which the Sylow subgroup based algorithm returned wrong results
# before it was disabled in GAP 4.5, namely SmallGroup(48,30) = A4 : C4 and
# SmallGroup(48,48) = C2 x S4
gap> G:=Group((1,2,3),(1,2)(3,4),(1,2)(5,6,7,8));;
gap> AbelianInvariantsMultiplier(G);
[ 2 ]
gap> AbelianInvariantsMultiplier(Group((1,2),(3,4,5,6),(3,4)));
[ 2, 2 ]

#
gap> check(TrivialGroup(IsPermGroup));
true
gap> check(CyclicGroup(6));
true
gap> check(DihedralGroup(8));
true
gap> check(SymmetricGroup(4));
true
gap> check(AlternatingGroup(5));
true
gap> check(Group((1,2,3),(1,2)(3,4),(1,2)(5,6,7,8)));
true
gap> check(Group((1,2),(3,4,5,6),(3,4)));
true

# matrix groups are handled via a permutation image
gap> check(SL(2,5));
true
gap> check(SL(3,2));
true
gap> check(GL(2,3));
true

# restricting to a set of primes
gap> epi:=EpimorphismSchurCover(AlternatingGroup(6),[2]);;
gap> AbelianInvariants(Kernel(epi));
[ 2 ]
gap> epi:=EpimorphismSchurCover(AlternatingGroup(6),[3]);;
gap> AbelianInvariants(Kernel(epi));
[ 3 ]
gap> epi:=EpimorphismSchurCover(AlternatingGroup(6),[5,7]);;
gap> AbelianInvariants(Kernel(epi));
[  ]
gap> epi:=EpimorphismSchurCover(DihedralGroup(8),[3]);;
gap> AbelianInvariants(Kernel(epi));
[  ]

#
gap> STOP_TEST("schur.tst");
