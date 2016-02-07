gap> START_TEST("FrattiniSubgroup.tst");

#
gap> FrattiniSubgroup(SymmetricGroup(3));
Group(())
gap> FrattiniSubgroup(SymmetricGroup(4));
Group(())
gap> FrattiniSubgroup(SymmetricGroup(5));
Group(())

#
gap> FrattiniSubgroup(CyclicGroup(IsPermGroup, 3));
Group(())
gap> FrattiniSubgroup(CyclicGroup(IsPermGroup, 9));
Group([ (1,4,7)(2,5,8)(3,6,9) ])
gap> FrattiniSubgroup(CyclicGroup(IsPcGroup, 3));
Group([  ])
gap> FrattiniSubgroup(CyclicGroup(IsPcGroup, 9));
Group([ f2 ])

#
gap> List(AllSmallGroups(60), g -> Size(FrattiniSubgroup(g)));
[ 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1 ]
gap> ForAll(AllSmallGroups(60), g -> IsNormal(g, FrattiniSubgroup(g)));
true

#
gap> g := SL(2,5);;
gap> f := FrattiniSubgroup(g);
<group of 2x2 matrices of size 2 over GF(5)>
gap> HasIsNilpotentGroup(f);
true
gap> p := SylowSubgroup(g, 2);;
gap> HasIsNilpotentGroup(p);
true
gap> HasIsNilpotentGroup(FrattiniSubgroup(p));
true

#
gap> g := SL(IsPermGroup,2,5);;
gap> f := FrattiniSubgroup(g);;
gap> HasIsNilpotentGroup(f);
true
gap> p := SylowSubgroup(g, 2);;
gap> HasIsNilpotentGroup(p);
true
gap> HasIsNilpotentGroup(FrattiniSubgroup(p));
true

#
gap> STOP_TEST("FrattiniSubgroup.tst", 1);
