gap> START_TEST("Socle.tst");
gap> Socle(Group(()));
Group(())
gap> D := DihedralGroup(8);;
gap> Socle(D) = ClosureSubgroup(TrivialSubgroup(D), Union(Set(MinimalNormalSubgroups(D), GeneratorsOfGroup)));
true
gap> IdGroup(Socle(D));
[ 2, 1 ]
gap> Socle(D) = Center(D);
true
gap> D := DihedralGroup(IsFpGroup, 8);;
gap> Socle(D) = ClosureSubgroup(TrivialSubgroup(D), Union(Set(MinimalNormalSubgroups(D), GeneratorsOfGroup)));
true
gap> IdGroup(Socle(D));
[ 2, 1 ]
gap> Socle(D) = Center(D);
true
gap> D := DihedralGroup(IsPermGroup, 8);;
gap> Socle(D) = ClosureSubgroup(TrivialSubgroup(D), Union(Set(MinimalNormalSubgroups(D), GeneratorsOfGroup)));
true
gap> IdGroup(Socle(D));
[ 2, 1 ]
gap> Socle(D) = Center(D);
true
gap> D := Group((1,3),(1,2,3,4));;
gap> Socle(D) = ClosureSubgroup(TrivialSubgroup(D), Union(Set(MinimalNormalSubgroups(D), GeneratorsOfGroup)));
true
gap> IdGroup(Socle(D));
[ 2, 1 ]
gap> Socle(D) = Center(D);
true
gap> DDD := DirectProduct(D, D, D);;
gap> IdGroup(Socle(DDD));
[ 8, 5 ]
gap> Socle(DDD) = ClosureSubgroup(TrivialSubgroup(DDD), Union(Set(MinimalNormalSubgroups(DDD), GeneratorsOfGroup)));
true
gap> Socle(DDD) = Center(DDD);
true
gap> Q := QuaternionGroup(8);;
gap> Socle(Q) = ClosureSubgroup(TrivialSubgroup(Q), Union(Set(MinimalNormalSubgroups(Q), GeneratorsOfGroup)));
true
gap> IdGroup(Socle(Q));
[ 2, 1 ]
gap> Socle(Q) = Center(Q);
true
gap> Socle(SymmetricGroup(4)) = Group((1,2)(3,4),(1,3)(2,4));
true
gap> IdGroup(Socle(SymmetricGroup(5)));
[ 60, 5 ]
gap> IdGroup(Socle(AlternatingGroup(5)));
[ 60, 5 ]
gap> G := Group((1,2),(3,4),(5,6),(7,8));;
gap> IsElementaryAbelian(G);
true
gap> Socle(G)=G;
true
gap> Socle(PrimitiveGroup(8,3)) = Group([ (1,7)(2,8)(3,5)(4,6), (1,3)(2,4)(5,7)(6,8), (1,2)(3,4)(5,6)(7,8) ]);
true
gap> k := 5;; P := SylowSubgroup(SymmetricGroup(4*k), 2);; A := Group((4*k+1, 4*k+2, 4*k+3));; G := ClosureGroup(P, A);;
gap> Socle(G) = Group([ (21,22,23), (1,2)(3,4)(5,6)(7,8)(9,10)(11,12)(13,14)(15,16), (17,18)(19,20) ]);
true
gap> G := Group([ (1,2,3,5,4), (1,3)(2,4)(6,7) ]);;

#gap> Socle(G) = Group((1,2,3),(3,4,5),(6,7));
#true
gap> G := SmallGroup(24,12);;
gap> IdGroup(Socle(G));
[ 4, 2 ]
gap> A := DihedralGroup(16);;
gap> B := SmallGroup(27, 3);;
gap> C := SmallGroup(125, 4);;
gap> D := DirectProduct(A, B, C, SmallGroup(1536, 2));;
gap> IdGroup(Socle(D));
[ 1440, 5958 ]
gap> Socle(D) = Center(D);
true
gap> Socle(FittingSubgroup(SymmetricGroup(4))) = Group([ (1,4)(2,3), (1,3)(2,4) ]);
true
gap> G := Group([ (4,8)(6,10), (4,6,10,8,12), (2,4,12)(6,10,8), (3,9)(4,6,10,8,12)
> (7,11), (3,5)(4,6,10,8,12)(9,11), (1,3,11,9,5)(4,6,10,8,12) ]);;

#gap> Socle(G) = Group([ (3,7)(5,9), (5,11)(7,9), (1,5,3)(7,11,9), (2,8,10)(4,6,12), (4,6)(10,12) ]);
#true
gap> F := FreeGroup("x", "y", "z");;
gap> x := F.1;; y := F.2;; z := F.3;;
gap> G := F/[x^(-1)*y^(-1)*x*y, x^(-1)*z^(-1)*x*z, z^(-1)*y^(-1)*z*y, (x*y)^180, (x*y^5)^168];;
gap> IsAbelian(G);;
gap> Size(Socle(G));
1260
gap> G := F/[x^2, y^2, x^(-1)*y^(-1)*x*y, z];;
gap> IsFinite(G);;
gap> Size(Socle(G));
4
gap> STOP_TEST("Socle.tst", 1);
