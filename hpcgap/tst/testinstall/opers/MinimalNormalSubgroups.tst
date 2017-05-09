gap> START_TEST("Socle.tst");
gap> A := [];; B := [];; C := [];; D := [];; G := [];;
gap> MinimalNormalSubgroups(Group(()));
[  ]
gap> G := Group(());; NormalSubgroups(G);; MinimalNormalSubgroups(G);
[  ]
gap> D := DihedralGroup(8);;
gap> MinimalNormalSubgroups(D) = [ Center(D) ];
true
gap> List(MinimalNormalSubgroups(D), IdGroup);
[ [ 2, 1 ] ]
gap> D := DihedralGroup(IsFpGroup, 8);;
gap> MinimalNormalSubgroups(D) = [ Center(D) ];
true
gap> List(MinimalNormalSubgroups(D), IdGroup);
[ [ 2, 1 ] ]
gap> D := Group((1,3),(1,2,3,4));;
gap> MinimalNormalSubgroups(D) = [ Center(D) ];
true
gap> List(MinimalNormalSubgroups(D), IdGroup);
[ [ 2, 1 ] ]
gap> DDD := DirectProduct(D, D, D);;
gap> List(MinimalNormalSubgroups(DDD), IdGroup);
[ [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ] ]
gap> Q := QuaternionGroup(8);;
gap> MinimalNormalSubgroups(Q) = [ Center(Q) ];
true
gap> List(MinimalNormalSubgroups(Q), IdGroup);
[ [ 2, 1 ] ]
gap> MinimalNormalSubgroups(SymmetricGroup(4)) = [ Group((1,2)(3,4),(1,3)(2,4)) ];
true
gap> List(MinimalNormalSubgroups(SymmetricGroup(5)), IdGroup);
[ [ 60, 5 ] ]
gap> List(MinimalNormalSubgroups(AlternatingGroup(5)), IdGroup);
[ [ 60, 5 ] ]
gap> G := Group((1,2),(3,4),(5,6),(7,8));;
gap> IsElementaryAbelian(G);
true
gap> Size(MinimalNormalSubgroups(G));
15
gap> MinimalNormalSubgroups(PrimitiveGroup(8,3)) = [ Group([ (1,7)(2,8)(3,5)(4,6), (1,3)(2,4)(5,7)(6,8), (1,2)(3,4)(5,6)(7,8) ]) ];
true
gap> k := 5;; P := SylowSubgroup(SymmetricGroup(4*k), 2);; A := Group((4*k+1, 4*k+2, 4*k+3));; G := ClosureGroup(P, A);; IsNilpotentGroup(G);;
gap> Set(MinimalNormalSubgroups(G)) = Set([ Group([ (1,2)(3,4)(5,6)(7,8)(9,10)(11,12)(13,14)(15,16) ]), Group([ (17,18)(19,20) ]), Group([ (1,2)(3,4)(5,6)(7,8)(9,10)(11,12)(13,14)(15,16)(17,18)(19,20) ]), Group([ (21,22,23) ]) ]);
true
gap> G := SmallGroup(24,12);;
gap> SortedList(List(MinimalNormalSubgroups(G), IdGroup));
[ [ 4, 2 ] ]
gap> A := DihedralGroup(16);;
gap> B := SmallGroup(27, 3);;
gap> C := SmallGroup(125, 4);;
gap> D := DirectProduct(A, B, C, SmallGroup(1536, 2));;
gap> SortedList(List(MinimalNormalSubgroups(D), IdGroup));
[ [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], 
  [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], 
  [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], 
  [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], 
  [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 3, 1 ], [ 3, 1 ], [ 3, 1 ], [ 3, 1 ], 
  [ 5, 1 ] ]
gap> G := Group([ (4,8)(6,10), (4,6,10,8,12), (2,4,12)(6,10,8), (3,9)(4,6,10,8,12)(7,11), (3,5)(4,6,10,8,12)(9,11), (1,3,11,9,5)(4,6,10,8,12) ]);;

#gap> MinimalNormalSubgroups(G) = Set([ Group([ (6,12)(8,10), (2,10)(4,12), (2,12)(6,10) ]), Group([ (5,11)(7,9), (3,9)(7,11), (1,9,5,11,7) ]) ]);
#true
gap> F := FreeGroup("x", "y", "z");;
gap> x := F.1;; y := F.2;; z := F.3;;
gap> G := F/[x^(-1)*y^(-1)*x*y, x^(-1)*z^(-1)*x*z, z^(-1)*y^(-1)*z*y, (x*y)^180, (x*y^5)^168];; IsAbelian(G);;
gap> Size(MinimalNormalSubgroups(G));
9
gap> G := F/[x^2, y^2, x^(-1)*y^(-1)*x*y, z];;
gap> IsFinite(G);;
gap> Size(MinimalNormalSubgroups(G));
3
gap> for G in AllGroups(60) do NormalSubgroups(G);; Print(Collected(List(Set(MinimalNormalSubgroups(G)), IdGroup)), "\n"); od;
[ [ [ 2, 1 ], 1 ], [ [ 3, 1 ], 1 ], [ [ 5, 1 ], 1 ] ]
[ [ [ 2, 1 ], 1 ], [ [ 3, 1 ], 1 ], [ [ 5, 1 ], 1 ] ]
[ [ [ 2, 1 ], 1 ], [ [ 3, 1 ], 1 ], [ [ 5, 1 ], 1 ] ]
[ [ [ 2, 1 ], 1 ], [ [ 3, 1 ], 1 ], [ [ 5, 1 ], 1 ] ]
[ [ [ 60, 5 ], 1 ] ]
[ [ [ 3, 1 ], 1 ], [ [ 5, 1 ], 1 ] ]
[ [ [ 3, 1 ], 1 ], [ [ 5, 1 ], 1 ] ]
[ [ [ 3, 1 ], 1 ], [ [ 5, 1 ], 1 ] ]
[ [ [ 4, 2 ], 1 ], [ [ 5, 1 ], 1 ] ]
[ [ [ 2, 1 ], 1 ], [ [ 3, 1 ], 1 ], [ [ 5, 1 ], 1 ] ]
[ [ [ 2, 1 ], 1 ], [ [ 3, 1 ], 1 ], [ [ 5, 1 ], 1 ] ]
[ [ [ 2, 1 ], 1 ], [ [ 3, 1 ], 1 ], [ [ 5, 1 ], 1 ] ]
[ [ [ 2, 1 ], 3 ], [ [ 3, 1 ], 1 ], [ [ 5, 1 ], 1 ] ]
gap> G := SmallGroup(120,5);; List(MinimalNormalSubgroups(G), IdGroup);
[ [ 2, 1 ] ]
gap> G := SmallGroup(120,34);; List(MinimalNormalSubgroups(G), IdGroup);
[ [ 60, 5 ] ]
gap> G := SmallGroup(120,35);; List(MinimalNormalSubgroups(G), IdGroup);
[ [ 2, 1 ], [ 60, 5 ] ]

# gap> for G in AllGroups(240) do if not IsSolvable(G) then NormalSubgroups(G);; Print(List(MinimalNormalSubgroups(G), IdGroup), "\n"); fi; od;
# [ [ 2, 1 ] ]
# [ [ 2, 1 ] ]
# [ [ 2, 1 ], [ 60, 5 ] ]
# [ [ 2, 1 ], [ 60, 5 ] ]
# [ [ 2, 1 ] ]
# [ [ 2, 1 ], [ 2, 1 ], [ 2, 1 ] ]
# [ [ 2, 1 ], [ 60, 5 ] ]
# [ [ 2, 1 ], [ 2, 1 ], [ 2, 1 ], [ 60, 5 ] ]
# gap> for G in AllGroups(360) do if not IsSolvable(G) then NormalSubgroups(G);; Print(List(MinimalNormalSubgroups(G), IdGroup), "\n"); fi; od;
# [ [ 2, 1 ], [ 3, 1 ] ]
# [ [ 360, 118 ] ]
# [ [ 3, 1 ], [ 60, 5 ] ]
# [ [ 3, 1 ], [ 60, 5 ] ]
# [ [ 3, 1 ], [ 60, 5 ] ]
# [ [ 2, 1 ], [ 3, 1 ], [ 60, 5 ] ]
gap> G := AbelianGroup([2, 3, 4, 5, 6, 7, 8, 9, 10]);;
gap> Collected(List(Set(MinimalNormalSubgroups(G)), Size));
[ [ 2, 31 ], [ 3, 13 ], [ 5, 6 ], [ 7, 1 ] ]
gap> G := ElementaryAbelianGroup(2^10);;
gap> Collected(List(Set(MinimalNormalSubgroups(G)), Size));
[ [ 2, 1023 ] ]
gap> G := ElementaryAbelianGroup(7^4);;
gap> Collected(List(Set(MinimalNormalSubgroups(G)), Size));
[ [ 7, 400 ] ]
gap> STOP_TEST("Socle.tst", 1);
