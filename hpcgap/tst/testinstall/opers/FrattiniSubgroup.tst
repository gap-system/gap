gap> START_TEST("FrattiniSubgroup.tst");

#
gap> FrattiniSubgroup(Group(()));
Group(())
gap> FrattiniSubgroup(Group((1,3),(1,2,3,4)));
Group([ (1,3)(2,4) ])
gap> D := DihedralGroup(IsFpGroup,8);;
gap> IsNilpotentGroup(D);;
gap> FrattiniSubgroup(D)=Group([ D.1^2 ]);
true
gap> F := FreeGroup("x", "y", "z");; x := F.1;; y := F.2;; z := F.3;;
gap> G := F/[x^(-1)*y^(-1)*x*y, x^(-1)*z^(-1)*x*z, z^(-1)*y^(-1)*z*y, x^180, y^168];;
gap> IsAbelian(G);;
gap> HasIsAbelian(FrattiniSubgroup(G));
true
gap> GeneratorsOfGroup(FrattiniSubgroup(G));
[ (x^-195*y^196)^6, (x^-1*y)^630, (x^-1*y)^840 ]
gap> G := DirectProduct(DihedralGroup(IsPcGroup,8), SmallGroup(27,4));;
gap> IsNilpotentGroup(G);
true
gap> F := FrattiniSubgroup(G);;
gap> IdGroup(F);
[ 6, 2 ]
gap> HasIsNilpotentGroup(F);
true

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

#gap> f := FrattiniSubgroup(g);
#<group of 2x2 matrices of size 2 over GF(5)>
#gap> HasIsNilpotentGroup(f);
#true
gap> p := SylowSubgroup(g, 2);;
gap> HasIsNilpotentGroup(p);
true
gap> HasIsNilpotentGroup(FrattiniSubgroup(p));
true

#
gap> g := SL(IsPermGroup,2,5);;

#gap> f := FrattiniSubgroup(g);;
#gap> HasIsNilpotentGroup(f);
#true
gap> p := SylowSubgroup(g, 2);;
gap> HasIsNilpotentGroup(p);
true
gap> HasIsNilpotentGroup(FrattiniSubgroup(p));
true

#
gap> STOP_TEST("FrattiniSubgroup.tst", 1);
