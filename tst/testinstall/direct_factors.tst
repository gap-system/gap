gap> START_TEST("direct_factors.tst");
gap> D := DihedralGroup(12);; Df := DirectFactorsOfGroup(D);; IsSet(Df); List(Df, IdGroup); 
true
[ [ 6, 1 ], [ 2, 1 ] ]
gap> U := Df[1];; V := Df[2];;
gap> ComplementNormalSubgroup(D, U)=V;
true
gap> IsTrivialNormalIntersection(D, U, V);
true
gap> U := Center(D);; V := Centralizer(D, DerivedSubgroup(D));;
gap> IsTrivialNormalIntersection(D, U, V);
false
gap> MinimalNormalSubgroups(D);;
gap> U := Df[1];; V := Df[2];;
gap> IsTrivialNormalIntersection(D, U, V);
true
gap> U := Center(D);; V := Centralizer(D, DerivedSubgroup(D));;
gap> IsTrivialNormalIntersection(D, U, V);
false
gap> ComplementNormalSubgroup(D, D);
Group([  ])
gap> ComplementNormalSubgroup(D, DerivedSubgroup(Center(D)))=D;
true
gap> ComplementNormalSubgroupNC(D, D);
Group([  ])
gap> ComplementNormalSubgroupNC(D, DerivedSubgroup(Center(D)))=D;
true
gap> G:=SmallGroup(16,7);; C := Center(G);; ComplementNormalSubgroup(G,C);
fail
gap> G := DirectProduct(D, D, D);;
gap> List(DirectFactorsOfGroup(G), IdGroup);
[ [ 6, 1 ], [ 6, 1 ], [ 6, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ] ]
gap> G := DirectProduct(D, D);; NormalSubgroups(G);;
gap> List(DirectFactorsOfGroup(G), IdGroup);
[ [ 6, 1 ], [ 6, 1 ], [ 2, 1 ], [ 2, 1 ] ]
gap> D := DihedralGroup(8);; G := DirectProduct(D, D);; NormalSubgroups(G);;
gap> List(DirectFactorsOfGroup(G), IdGroup);
[ [ 8, 3 ], [ 8, 3 ] ]
gap> List(DirectFactorsOfGroup(SmallGroup(64,226):useKN), IdGroup);
[ [ 8, 3 ], [ 8, 3 ] ]
gap> D := DihedralGroup(12);; NormalSubgroups(D);;
gap> List(DirectFactorsOfGroup(D), IdGroup);
[ [ 6, 1 ], [ 2, 1 ] ]
gap> Q := QuaternionGroup(8);; NormalSubgroups(Q);;
gap> List(DirectFactorsOfGroup(Q), IdGroup);
[ [ 8, 4 ] ]
gap> G := SmallGroup(48, 1);; NormalSubgroups(G);;
gap> List(DirectFactorsOfGroup(G), IdGroup);
[ [ 48, 1 ] ]
gap> DirectFactorsOfGroup(Group(()));
[ Group(()) ]
gap> F := FreeGroup("x","y");; x := F.1;; y := F.2;;
gap> DirectFactorsOfGroup(F/[x*y*x^(-1)*y^(-1)]);
[ Group([ x ]), Group([ y ]) ]
gap> IsList(DirectFactorsOfGroup(F/[x*y*x^(-1)*y^(-1)]));
true
gap> DirectFactorsOfGroup(F/[(x*y)^30,x*y*x^(-1)*y^(-1)]);
[ Group([ x ]), Group([ (x*y)^15 ]), Group([ (x*y)^10 ]), Group([ (x*y)^6 ]) ]
gap> List(DirectFactorsOfGroup(F/[(x*y)^30,(x*y^7)^11,x*y*x^(-1)*y^(-1)]),IdGroup);
[ [ 4, 1 ], [ 5, 1 ], [ 9, 1 ], [ 11, 1 ] ]
gap> List(DirectFactorsOfGroup(SmallGroup(256, 56091)), IdGroup);
[ [ 256, 56091 ] ]
gap> for G in AllGroups(16) do Print(List(DirectFactorsOfGroup(G), IdGroup),"\n"); od;
[ [ 16, 1 ] ]
[ [ 4, 1 ], [ 4, 1 ] ]
[ [ 16, 3 ] ]
[ [ 16, 4 ] ]
[ [ 8, 1 ], [ 2, 1 ] ]
[ [ 16, 6 ] ]
[ [ 16, 7 ] ]
[ [ 16, 8 ] ]
[ [ 16, 9 ] ]
[ [ 2, 1 ], [ 2, 1 ], [ 4, 1 ] ]
[ [ 2, 1 ], [ 8, 3 ] ]
[ [ 2, 1 ], [ 8, 4 ] ]
[ [ 16, 13 ] ]
[ [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ] ]
gap> List(DirectFactorsOfGroup(SmallGroup(1728,31093)), IdGroup);
[ [ 64, 266 ], [ 27, 3 ] ]
gap> List(DirectFactorsOfGroup(SmallGroup(120,29)), IdGroup);
[ [ 2, 1 ], [ 60, 3 ] ]
gap> List(DirectFactorsOfGroup(SmallGroup(240,112)), IdGroup);
[ [ 3, 1 ], [ 80, 29 ] ]
gap> List(DirectFactorsOfGroup(SmallGroup(64,214)), IdGroup);
[ [ 64, 214 ] ]
gap> List(DirectFactorsOfGroup(SmallGroup(64,215)), IdGroup);
[ [ 64, 215 ] ]
gap> List(DirectFactorsOfGroup(SmallGroup(64,226):useKN), IdGroup);
[ [ 8, 3 ], [ 8, 3 ] ]
gap> DirectFactorsOfGroup(SymmetricGroup(4));
[ Sym( [ 1 .. 4 ] ) ]
gap> DirectFactorsOfGroup(SymmetricGroup(5));
[ Sym( [ 1 .. 5 ] ) ]
gap> G := Group([ (4,8)(6,10), (4,6,10,8,12), (2,4,12)(6,10,8), (3,9)(4,6,10,8,12)(7,11), (3,5)(4,6,10,8,12)(9,11), (1,3,11,9,5)(4,6,10,8,12) ]);;
gap> DirectFactorsOfGroup(G)=[G];
true
gap> G := Group([ (4,8)(6,10), (4,6,10,8,12), (2,4,12)(6,10,8), (3,9)(4,6,10,8,12)(7,11), (3,5)(4,6,10,8,12)(9,11), (1,3,11,9,5)(4,6,10,8,12) ]);;
gap> NormalSubgroups(G);;
gap> DirectFactorsOfGroup(G)=[G];
true
gap> STOP_TEST("direct_factors.tst", 10000);
