gap> START_TEST("ComplementClassesRepresentatives.tst");
gap> n := 0;; for G in AllGroups(60) do for N in NormalSubgroups(G) do if ComplementClassesRepresentatives(G, N)<>fail then n := n+1; fi; od; od; n;
133
gap> G := Group([ (4,8)(6,10), (4,6,10,8,12), (2,4,12)(6,10,8), (3,9)(4,6,10,8,12)(7,11), (3,5)(4,6,10,8,12)(9,11), (1,3,11,9,5)(4,6,10,8,12) ]);;
gap> N := NormalSubgroups(G)[2];;
gap> ComplementClassesRepresentatives(G, N);
#I  N and G/N are not solvable, computing all subgroups!
[ Group([ (2,10)(4,12), (2,4,12)(6,10,8) ]), Group([ (1,9)(2,10)(3,11)
  (4,12), (1,3,11)(2,4,12)(5,9,7)(6,10,8) ]), Group([ (2,10)(3,11)(4,12)
  (5,7), (1,9,5)(2,4,12)(3,7,11)(6,10,8) ]) ]
gap> G := SymmetricGroup(5);; N := AlternatingGroup(5);;
gap> List(ComplementClassesRepresentatives(G, N), IdGroup);
[ [ 2, 1 ] ]
gap> G := SymmetricGroup(6);; N := AlternatingGroup(6);;
gap> List(ComplementClassesRepresentatives(G, N), IdGroup);
[ [ 2, 1 ], [ 2, 1 ] ]
gap> STOP_TEST("ComplementClassesRepresentatives.tst", 10000);
