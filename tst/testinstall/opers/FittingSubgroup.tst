gap> START_TEST("FittingSubgroup.tst");

#
gap> G:=SylowSubgroup(SymmetricGroup(5),2);;
gap> HasIsNilpotentGroup(G);
true
gap> IsIdenticalObj(G, FittingSubgroup(G));
true

#
gap> G := CyclicGroup(IsPermGroup, 12);;
gap> IsIdenticalObj(G, FittingSubgroup(G));
true
gap> G := CyclicGroup(IsPcGroup, 12);;
gap> IsIdenticalObj(G, FittingSubgroup(G));
true

#
gap> List(AllSmallGroups(60), g -> Size(FittingSubgroup(g)));
[ 30, 30, 30, 60, 1, 15, 15, 15, 20, 30, 30, 30, 60 ]
gap> ForAll(AllSmallGroups(60), g -> IsNormal(g, FittingSubgroup(g)));
true

#
gap> g := SL(2,5);;
gap> f := FittingSubgroup(g);; Size(f);
2
gap> HasIsNilpotentGroup(f);
true
gap> p := SylowSubgroup(g, 2);;
gap> HasIsNilpotentGroup(p);
true
gap> HasIsNilpotentGroup(FittingSubgroup(p));
true

#
gap> g := SL(IsPermGroup,2,5);;
gap> f := FittingSubgroup(g);;
gap> HasIsNilpotentGroup(f);
true
gap> p := SylowSubgroup(g, 2);;
gap> HasIsNilpotentGroup(p) and IsNilpotentGroup(p);
true
gap> HasFittingSubgroup(p) and HasIsNilpotentGroup(FittingSubgroup(p)) and FittingSubgroup(p)=p;
true

#
gap> STOP_TEST("FittingSubgroup.tst", 1);
