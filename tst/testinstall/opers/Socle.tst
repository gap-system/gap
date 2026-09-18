gap> START_TEST("Socle.tst");
gap> Socle(Group(()));
Group(())
gap> D := DihedralGroup(8);;
gap> Socle(D) = ClosureSubgroup(TrivialSubgroup(D), Union(Set(MinimalNormalSubgroups(D), GeneratorsOfGroup)));
true
gap> Size(Socle(D));
2
gap> Socle(D) = Center(D);
true
gap> D := DihedralGroup(IsFpGroup, 8);;
gap> Socle(D) = ClosureSubgroup(TrivialSubgroup(D), Union(Set(MinimalNormalSubgroups(D), GeneratorsOfGroup)));
true
gap> Size(Socle(D));
2
gap> Socle(D) = Center(D);
true
gap> D := DihedralGroup(IsPermGroup, 8);;
gap> Socle(D) = ClosureSubgroup(TrivialSubgroup(D), Union(Set(MinimalNormalSubgroups(D), GeneratorsOfGroup)));
true
gap> Size(Socle(D));
2
gap> Socle(D) = Center(D);
true
gap> D := Group((1,3),(1,2,3,4));;
gap> Socle(D) = ClosureSubgroup(TrivialSubgroup(D), Union(Set(MinimalNormalSubgroups(D), GeneratorsOfGroup)));
true
gap> Size(Socle(D));
2
gap> Socle(D) = Center(D);
true
gap> DDD := DirectProduct(D, D, D);;
gap> StructureDescription(Socle(DDD));
"C2 x C2 x C2"
gap> Socle(DDD) = ClosureSubgroup(TrivialSubgroup(DDD), Union(Set(MinimalNormalSubgroups(DDD), GeneratorsOfGroup)));
true
gap> Socle(DDD) = Center(DDD);
true
gap> Q := QuaternionGroup(8);;
gap> Socle(Q) = ClosureSubgroup(TrivialSubgroup(Q), Union(Set(MinimalNormalSubgroups(Q), GeneratorsOfGroup)));
true
gap> Size(Socle(Q));
2
gap> Socle(Q) = Center(Q);
true
gap> Socle(SymmetricGroup(4)) = Group((1,2)(3,4),(1,3)(2,4));
true
gap> AlternatingGroup(5) = Socle(SymmetricGroup(5));
true
gap> AlternatingGroup(5) = Socle(AlternatingGroup(5));
true
gap> G := Group((1,2),(3,4),(5,6),(7,8));;
gap> IsElementaryAbelian(G);
true
gap> Socle(G)=G;
true
gap> G:=Group([ (2,7,4,8,6,5,3), (2,3)(6,7), (1,2)(3,4)(5,6)(7,8) ]);; # = PrimitiveGroup(8,3)
gap> Socle(G) = Group([ (1,7)(2,8)(3,5)(4,6), (1,3)(2,4)(5,7)(6,8), (1,2)(3,4)(5,6)(7,8) ]);
true
gap> k := 5;; P := SylowSubgroup(SymmetricGroup(4*k), 2);; A := Group((4*k+1, 4*k+2, 4*k+3));; G := ClosureGroup(P, A);;
gap> Socle(G) = Group([ (21,22,23), (1,2)(3,4)(5,6)(7,8)(9,10)(11,12)(13,14)(15,16), (17,18)(19,20) ]);
true
gap> G := Group([ (1,2,3,5,4), (1,3)(2,4)(6,7) ]);;
gap> Socle(G) = Group((1,2,3),(3,4,5),(6,7));
true
gap> G := SymmetricGroup(IsPcGroup, 4);;
gap> StructureDescription(Socle(G));
"C2 x C2"
#@if IsPackageMarkedForLoading( "smallgrp", "" )
gap> A := DihedralGroup(16);;
gap> B := ExtraspecialGroup( 27, 3 );;
gap> C := ExtraspecialGroup( 125, 25 );;
gap> D := DirectProduct(A, B, C, SmallGroup(1536, 2));;
gap> StructureDescription(Socle(D));
"C30 x C6 x C2 x C2 x C2"
gap> Socle(D) = Center(D);
true
#@fi
gap> Socle(FittingSubgroup(SymmetricGroup(4))) = Group([ (1,4)(2,3), (1,3)(2,4) ]);
true
gap> G := Group([ (4,8)(6,10), (4,6,10,8,12), (2,4,12)(6,10,8), (3,9)(4,6,10,8,12)
> (7,11), (3,5)(4,6,10,8,12)(9,11), (1,3,11,9,5)(4,6,10,8,12) ]);;
gap> Socle(G) = Group([ (3,7)(5,9), (5,11)(7,9), (1,5,3)(7,11,9), (2,8,10)(4,6,12), (4,6)(10,12) ]);
true
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
gap> G := Group([], IdentityMat (4, GF(2)));;
gap> IsTrivial(Socle(G));
true
gap> STOP_TEST("Socle.tst");
