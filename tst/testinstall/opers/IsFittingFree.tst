gap> START_TEST("IsFittingFree.tst");

#
gap> IsFittingFree(TrivialGroup());
true
gap> IsFittingFree(Group(()));
true

# a nontrivial solvable group is never Fitting-free
gap> IsFittingFree(CyclicGroup(6));
false
gap> IsFittingFree(DihedralGroup(8));
false
gap> List([1..6], n -> IsFittingFree(SymmetricGroup(n)));  # S1 is trivial
[ true, false, false, false, true, true ]

# nonabelian simple groups are Fitting-free, abelian simple ones are not
gap> IsFittingFree(AlternatingGroup(5));
true
gap> IsFittingFree(PSL(3,2));
true
gap> IsFittingFree(CyclicGroup(7));
false

# a nontrivial solvable normal subgroup destroys the property
gap> IsFittingFree(SL(2,5));
false
gap> IsFittingFree(PSL(2,5));
true
gap> IsFittingFree(DirectProduct(AlternatingGroup(5), CyclicGroup(2)));
false
gap> IsFittingFree(DirectProduct(AlternatingGroup(5), AlternatingGroup(6)));
true
gap> IsFittingFree(SymmetricGroup(5));
true

# pc groups and matrix groups
gap> IsFittingFree(SymmetricGroup(IsPcGroup,4));
false
gap> IsFittingFree(GL(3,2));  # simple, isomorphic to PSL(3,2) above
true
gap> IsFittingFree(GL(2,3));  # solvable
false

# the property agrees with the definition
#@if IsPackageMarkedForLoading( "smallgrp", "" )
gap> ForAll([1..100], n -> ForAll([1..NrSmallGroups(n)],
>      i -> IsFittingFree(SmallGroup(n,i))
>           = IsTrivial(FittingSubgroup(SmallGroup(n,i)))));
true
#@fi

# knowing the property makes the Fitting subgroup and the solvable radical trivial
gap> G := SymmetricGroup(5);;
gap> SetIsFittingFree(G, true);
gap> FittingSubgroup(G);
Group(())
gap> SolvableRadical(G);
Group(())

# conversely a known Fitting subgroup decides the property, also for groups
# which are not known to be finite
gap> G := FreeGroup(2);;
gap> SetFittingSubgroup(G, TrivialSubgroup(G));
gap> IsFittingFree(G);
true

# Fitting-free groups are Frattini-free
gap> G := AlternatingGroup(6);;
gap> IsFittingFree(G);
true
gap> HasIsFrattiniFree(G) and IsFrattiniFree(G);
true

#
gap> STOP_TEST("IsFittingFree.tst");
