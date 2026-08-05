gap> START_TEST("IsFrattiniFree.tst");

#
gap> IsFrattiniFree(TrivialGroup());
true
gap> IsFrattiniFree(Group(()));
true

# abelian groups: Frattini-free iff the exponent is squarefree
gap> List([1..12], n -> IsFrattiniFree(CyclicGroup(n)));
[ true, true, true, false, true, true, true, false, false, true, true, false ]
gap> IsFrattiniFree(AbelianGroup([2,2,3,5]));
true
gap> IsFrattiniFree(AbelianGroup([2,2,3,9]));
false

# p-groups: Frattini-free iff elementary abelian
gap> IsFrattiniFree(ElementaryAbelianGroup(27));
true
gap> IsFrattiniFree(DihedralGroup(8));
false
gap> IsFrattiniFree(QuaternionGroup(8));
false
gap> IsFrattiniFree(ExtraspecialGroup(27,3));
false

# nilpotent groups: Frattini-free iff all Sylow subgroups are elementary abelian
gap> G := DirectProduct(ElementaryAbelianGroup(4), ElementaryAbelianGroup(9));;
gap> IsNilpotentGroup(G);
true
gap> IsFrattiniFree(G);
true
gap> G := DirectProduct(ElementaryAbelianGroup(4), CyclicGroup(9));;
gap> IsNilpotentGroup(G);
true
gap> IsFrattiniFree(G);
false

# groups of squarefree order are Frattini-free
gap> IsFrattiniFree(SymmetricGroup(3));
true
gap> IsFrattiniFree(DihedralGroup(IsPermGroup, 110));
true

# solvable groups whose order is not squarefree
gap> IsFrattiniFree(AlternatingGroup(4));
true
gap> IsFrattiniFree(Group((1,2,3,4,5),(2,3,5,4)));  # Frobenius group of order 20
true

# simple groups are Frattini-free, quasisimple ones need not be
gap> IsFrattiniFree(AlternatingGroup(5));
true
gap> IsFrattiniFree(PSL(3,2));
true
gap> IsFrattiniFree(SL(2,5));
false

#
gap> IsFrattiniFree(SymmetricGroup(4));
true
gap> IsFrattiniFree(SymmetricGroup(IsPcGroup, 4));
true
gap> IsFrattiniFree(GL(2,3));
false
gap> IsFrattiniFree(DirectProduct(AlternatingGroup(5), CyclicGroup(4)));
false

# the property agrees with the definition
#@if IsPackageMarkedForLoading( "smallgrp", "" )
gap> ForAll([1..100], n -> ForAll([1..NrSmallGroups(n)],
>      i -> IsFrattiniFree(SmallGroup(n,i))
>           = IsTrivial(FrattiniSubgroup(SmallGroup(n,i)))));
true
#@fi

# knowing the property makes computing the Frattini subgroup trivial
gap> G := SymmetricGroup(5);;
gap> SetIsFrattiniFree(G, true);
gap> FrattiniSubgroup(G);
Group(())

# conversely, a known Frattini subgroup decides the property, also for
# groups which are not known to be finite
gap> G := FreeGroup(2);;
gap> SetFrattiniSubgroup(G, TrivialSubgroup(G));
gap> IsFrattiniFree(G);
true

# implied properties
gap> G := Group((1,2,3,4,5,6,7),(2,3,5)(4,7,6));;
gap> IsFrattiniFree(G);
true
gap> HasIsElementaryAbelian(G);
false
gap> G := AbelianGroup(IsPermGroup, [7,7]);;
gap> IsPGroup(G) and IsFrattiniFree(G);
true
gap> HasIsElementaryAbelian(G) and IsElementaryAbelian(G);
true
gap> G := AbelianGroup(IsPermGroup, [6,6]);;
gap> IsNilpotentGroup(G) and IsFrattiniFree(G);
true
gap> HasIsCommutative(G) and IsCommutative(G);
true

#
gap> STOP_TEST("IsFrattiniFree.tst");
