gap> START_TEST("Semidirectdecompositions.tst");
gap> List(AllSmallGroups(12),G->List(SemidirectDecompositions(G), NH->[IdGroup(NH[1]), IdGroup(NH[2])]));
[ [ [ [ 1, 1 ], [ 12, 1 ] ], [ [ 3, 1 ], [ 4, 1 ] ], [ [ 12, 1 ], [ 1, 1 ] ] ]
    , 
  [ [ [ 1, 1 ], [ 12, 2 ] ], [ [ 3, 1 ], [ 4, 1 ] ], [ [ 4, 1 ], [ 3, 1 ] ], 
      [ [ 12, 2 ], [ 1, 1 ] ] ], 
  [ [ [ 1, 1 ], [ 12, 3 ] ], [ [ 4, 2 ], [ 3, 1 ] ], [ [ 12, 3 ], [ 1, 1 ] ] ]
    , 
  [ [ [ 1, 1 ], [ 12, 4 ] ], [ [ 2, 1 ], [ 6, 1 ] ], [ [ 2, 1 ], [ 6, 1 ] ], 
      [ [ 3, 1 ], [ 4, 2 ] ], [ [ 6, 1 ], [ 2, 1 ] ], [ [ 6, 1 ], [ 2, 1 ] ], 
      [ [ 6, 2 ], [ 2, 1 ] ], [ [ 6, 2 ], [ 2, 1 ] ], [ [ 12, 4 ], [ 1, 1 ] ],
      [ [ 6, 1 ], [ 2, 1 ] ], [ [ 6, 1 ], [ 2, 1 ] ] ], 
  [ [ [ 1, 1 ], [ 12, 5 ] ], [ [ 2, 1 ], [ 6, 2 ] ], [ [ 2, 1 ], [ 6, 2 ] ], 
      [ [ 2, 1 ], [ 6, 2 ] ], [ [ 2, 1 ], [ 6, 2 ] ], [ [ 4, 2 ], [ 3, 1 ] ], 
      [ [ 3, 1 ], [ 4, 2 ] ], [ [ 6, 2 ], [ 2, 1 ] ], [ [ 6, 2 ], [ 2, 1 ] ], 
      [ [ 6, 2 ], [ 2, 1 ] ], [ [ 6, 2 ], [ 2, 1 ] ], [ [ 12, 5 ], [ 1, 1 ] ],
      [ [ 6, 2 ], [ 2, 1 ] ], [ [ 6, 2 ], [ 2, 1 ] ], [ [ 2, 1 ], [ 6, 2 ] ], 
      [ [ 2, 1 ], [ 6, 2 ] ] ] ]
gap> n := 60;; for k in [1..NumberSmallGroups(n)] do G := SmallGroup(n,k);; NH := SemidirectDecompositionsOfFiniteGroup(G, "any");; if NH=fail then Print("fail\n"); else Print(List(NH, IdGroup),"\n"); fi; od;
[ [ 3, 1 ], [ 20, 2 ] ]
[ [ 3, 1 ], [ 20, 1 ] ]
[ [ 3, 1 ], [ 20, 1 ] ]
[ [ 4, 1 ], [ 15, 1 ] ]
fail
[ [ 3, 1 ], [ 20, 3 ] ]
[ [ 3, 1 ], [ 20, 3 ] ]
[ [ 3, 1 ], [ 20, 4 ] ]
[ [ 4, 2 ], [ 15, 1 ] ]
[ [ 3, 1 ], [ 20, 4 ] ]
[ [ 3, 1 ], [ 20, 5 ] ]
[ [ 3, 1 ], [ 20, 4 ] ]
[ [ 4, 2 ], [ 15, 1 ] ]
gap> n := 12;; for k in [1..NumberSmallGroups(n)] do G := SmallGroup(n,k);; NH := SemidirectDecompositionsOfFiniteGroup(G, "str");; if NH=fail then Print("fail\n"); else Print(List(NH, IdGroup),"\n"); fi; od;
[ [ 3, 1 ], [ 4, 1 ] ]
[ [ 4, 1 ], [ 3, 1 ] ]
[ [ 4, 2 ], [ 3, 1 ] ]
[ [ 3, 1 ], [ 4, 2 ] ]
[ [ 4, 2 ], [ 3, 1 ] ]
gap> G := Group((1,2,3),(2,3,4));;
gap> List(SemidirectDecompositionsOfFiniteGroup(G,NormalSubgroups(G)),NH->[IdGroup(NH[1]), IdGroup(NH[2])]);
[ [ [ 1, 1 ], [ 12, 3 ] ], [ [ 12, 3 ], [ 1, 1 ] ], [ [ 4, 2 ], [ 3, 1 ] ] ]
gap> List(SemidirectDecompositionsOfFiniteGroup(G,"all"),NH->[IdGroup(NH[1]), IdGroup(NH[2])]);
[ [ [ 1, 1 ], [ 12, 3 ] ], [ [ 12, 3 ], [ 1, 1 ] ], [ [ 4, 2 ], [ 3, 1 ] ] ]
gap> List(SemidirectDecompositionsOfFiniteGroup(G, "any"), IdGroup);
[ [ 4, 2 ], [ 3, 1 ] ]
gap> List(SemidirectDecompositionsOfFiniteGroup(G, "str"), IdGroup);
[ [ 4, 2 ], [ 3, 1 ] ]
gap> G := Group((1,2),(1,2,3,4));; Ns := [Group((1,2)(3,4),(1,3)(2,4))];;
gap> List(SemidirectDecompositionsOfFiniteGroup(G, Ns, "any"),IdGroup);
[ [ 4, 2 ], [ 6, 1 ] ]
gap> List(SemidirectDecompositions(G),NH->[IdGroup(NH[1]), IdGroup(NH[2])]);
[ [ [ 1, 1 ], [ 24, 12 ] ], [ [ 24, 12 ], [ 1, 1 ] ], [ [ 12, 3 ], [ 2, 1 ] ],
  [ [ 4, 2 ], [ 6, 1 ] ] ]
gap> List(SemidirectDecompositionsOfFiniteGroup(G,"all"),NH->[IdGroup(NH[1]), IdGroup(NH[2])]);
[ [ [ 1, 1 ], [ 24, 12 ] ], [ [ 24, 12 ], [ 1, 1 ] ], [ [ 12, 3 ], [ 2, 1 ] ],
  [ [ 4, 2 ], [ 6, 1 ] ] ]
gap> List(SemidirectDecompositionsOfFiniteGroup(G, "any"), IdGroup);
[ [ 12, 3 ], [ 2, 1 ] ]
gap> List(SemidirectDecompositionsOfFiniteGroup(G, "str"), IdGroup);
[ [ 12, 3 ], [ 2, 1 ] ]
gap> G := Group((1,2,3),(3,4,5));;
gap> List(SemidirectDecompositions(G),NH->[IdGroup(NH[1]), IdGroup(NH[2])]);
[ [ [ 1, 1 ], [ 60, 5 ] ], [ [ 60, 5 ], [ 1, 1 ] ] ]
gap> SemidirectDecompositionsOfFiniteGroup(G, "any");
fail
gap> SemidirectDecompositionsOfFiniteGroup(G, "str");
fail
gap> G := Group((1,2),(1,2,3,4,5));; List(SemidirectDecompositionsOfFiniteGroup(G, "any"), IdGroup);
[ [ 60, 5 ], [ 2, 1 ] ]
gap> G := SmallGroup(32,8);; SemidirectDecompositionsOfFiniteGroup(G, "any");
fail
gap> N := PSL(2,32);; aut := SylowSubgroup(AutomorphismGroup(N),5);;
gap> G := SemidirectProduct(aut, N);; StructureDescription(G);
"PSL(2,32) : C5"
gap> SemidirectDecompositionsOfFiniteGroup(G, "any", "full");
Error, usage: SemidirectDecompositionsOfFiniteGroup(<G> [, <Ns>] [, <mthd>])
gap> G := Group([ (4,8)(6,10), (4,6,10,8,12), (2,4,12)(6,10,8), (3,9)(4,6,10,8,12)(7,11), (3,5)(4,6,10,8,12)(9,11), (1,3,11,9,5)(4,6,10,8,12) ]);;
gap> Length(SemidirectDecompositions(G));
8
gap> F := FreeGroup("r", "s");; r := F.1;; s := F.2;;
gap> G := F/[s^2, r^3, s*r*s*r];;
gap> Length(SemidirectDecompositions(G));
3
gap> STOP_TEST("Semidirectdecompositions.tst", 1);
