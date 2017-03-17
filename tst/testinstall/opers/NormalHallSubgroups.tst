gap> START_TEST("NormalHallSubgroups.tst");
gap> for G in AllGroups(60) do Print(List(NormalHallSubgroups(G), IdGroup), "\n"); od;
[ [ 1, 1 ], [ 5, 1 ], [ 3, 1 ], [ 15, 1 ], [ 12, 1 ], [ 60, 1 ] ]
[ [ 1, 1 ], [ 3, 1 ], [ 5, 1 ], [ 15, 1 ], [ 20, 1 ], [ 60, 2 ] ]
[ [ 1, 1 ], [ 3, 1 ], [ 5, 1 ], [ 15, 1 ], [ 60, 3 ] ]
[ [ 1, 1 ], [ 3, 1 ], [ 5, 1 ], [ 15, 1 ], [ 4, 1 ], [ 12, 2 ], [ 20, 2 ], 
  [ 60, 4 ] ]
[ [ 1, 1 ], [ 60, 5 ] ]
[ [ 1, 1 ], [ 3, 1 ], [ 5, 1 ], [ 15, 1 ], [ 20, 3 ], [ 60, 6 ] ]
[ [ 1, 1 ], [ 3, 1 ], [ 5, 1 ], [ 15, 1 ], [ 60, 7 ] ]
[ [ 1, 1 ], [ 3, 1 ], [ 5, 1 ], [ 15, 1 ], [ 60, 8 ] ]
[ [ 1, 1 ], [ 5, 1 ], [ 4, 2 ], [ 12, 3 ], [ 20, 5 ], [ 60, 9 ] ]
[ [ 1, 1 ], [ 3, 1 ], [ 5, 1 ], [ 20, 4 ], [ 15, 1 ], [ 60, 10 ] ]
[ [ 1, 1 ], [ 5, 1 ], [ 3, 1 ], [ 12, 4 ], [ 15, 1 ], [ 60, 11 ] ]
[ [ 1, 1 ], [ 3, 1 ], [ 5, 1 ], [ 15, 1 ], [ 60, 12 ] ]
[ [ 1, 1 ], [ 4, 2 ], [ 3, 1 ], [ 12, 5 ], [ 5, 1 ], [ 20, 5 ], [ 15, 1 ], 
  [ 60, 13 ] ]
gap> for G in AllGroups(60) do primes := PrimeDivisors(Size(G)); l := []; for pi in IteratorOfCombinations(primes) do N := HallSubgroup(G, pi); if N<>fail and IsGroup(N) and IsNormal(G, N) then AddSet(l, N); fi; od; if l <> NormalHallSubgroups(G) then Print(IdGroup(G), "\n"); fi; od;
gap> List(AllSmallGroups(168), G -> List(NormalHallSubgroups(G), Size));
[ [ 1, 7, 21, 56, 168 ], [ 1, 8, 7, 21, 56, 168 ], [ 1, 7, 3, 21, 24, 168 ], 
  [ 1, 3, 7, 21, 56, 168 ], [ 1, 3, 7, 21, 168 ], 
  [ 1, 3, 7, 21, 8, 24, 56, 168 ], [ 1, 7, 21, 56, 168 ], 
  [ 1, 7, 21, 56, 168 ], [ 1, 7, 21, 56, 168 ], [ 1, 7, 21, 56, 168 ], 
  [ 1, 7, 21, 56, 168 ], [ 1, 3, 7, 21, 168 ], [ 1, 3, 7, 21, 168 ], 
  [ 1, 3, 7, 21, 168 ], [ 1, 3, 7, 21, 168 ], [ 1, 3, 7, 21, 168 ], 
  [ 1, 3, 7, 21, 168 ], [ 1, 3, 7, 21, 168 ], [ 1, 8, 7, 21, 56, 168 ], 
  [ 1, 8, 7, 21, 56, 168 ], [ 1, 8, 7, 21, 56, 168 ], 
  [ 1, 7, 8, 24, 56, 168 ], [ 1, 7, 8, 56, 168 ], [ 1, 3, 7, 21, 56, 168 ], 
  [ 1, 3, 7, 21, 56, 168 ], [ 1, 3, 7, 21, 56, 168 ], 
  [ 1, 3, 7, 21, 56, 168 ], [ 1, 3, 7, 21, 56, 168 ], 
  [ 1, 7, 3, 21, 24, 168 ], [ 1, 7, 3, 21, 24, 168 ], 
  [ 1, 7, 3, 21, 24, 168 ], [ 1, 7, 3, 21, 24, 168 ], 
  [ 1, 7, 3, 21, 24, 168 ], [ 1, 3, 7, 21, 168 ], [ 1, 3, 7, 21, 168 ], 
  [ 1, 3, 7, 21, 168 ], [ 1, 3, 7, 21, 168 ], [ 1, 3, 7, 21, 168 ], 
  [ 1, 3, 7, 21, 8, 24, 56, 168 ], [ 1, 3, 7, 21, 8, 24, 56, 168 ], 
  [ 1, 3, 7, 21, 8, 24, 56, 168 ], [ 1, 168 ], [ 1, 8, 56, 168 ], 
  [ 1, 3, 8, 24, 56, 168 ], [ 1, 7, 24, 168 ], [ 1, 7, 168 ], 
  [ 1, 7, 56, 21, 168 ], [ 1, 7, 56, 168 ], [ 1, 7, 56, 168 ], 
  [ 1, 3, 7, 21, 168 ], [ 1, 8, 7, 56, 21, 168 ], [ 1, 7, 8, 24, 56, 168 ], 
  [ 1, 8, 7, 56, 168 ], [ 1, 3, 7, 56, 21, 168 ], [ 1, 7, 3, 24, 21, 168 ], 
  [ 1, 3, 7, 21, 168 ], [ 1, 8, 3, 24, 7, 56, 21, 168 ] ]
gap> for G in AllGroups(168) do primes := PrimeDivisors(Size(G)); l := []; for pi in IteratorOfCombinations(primes) do N := HallSubgroup(G, pi); if N<>fail and IsGroup(N) and IsNormal(G, N) then AddSet(l, N); fi; od; if l <> NormalHallSubgroups(G) then Print(IdGroup(G), "\n"); fi; od;
gap> List(AllPrimitiveGroups(DegreeAction, 8), G -> List(NormalHallSubgroups(G), Size));
[ [ 1, 56, 8 ], [ 1, 168, 56, 8 ], [ 1, 1344 ], [ 1, 168 ], [ 1, 336 ], 
  [ 1, 20160 ], [ 1, 40320 ] ]
gap> List(NormalHallSubgroups(PrimitiveGroup(8,2)), Size);
[ 1, 168, 56, 8 ]
gap> Positions(List(AllTransitiveGroups(DegreeAction, 6), G -> NormalHallSubgroupsFromSylows(G, "any")), fail);
[ 7, 8, 11, 12, 14, 15, 16 ]
gap> N := PSL(2,32);; aut := SylowSubgroup(AutomorphismGroup(N),5);;
gap> G := SemidirectProduct(aut, N);;
gap> Size(NormalHallSubgroupsFromSylows(G, "any"));
32736
gap> A4 := AlternatingGroup(4);;
gap> HallSubgroup(A4, [2])=Group((1,2)(3,4),(1,3)(2,4));
true
gap> HallSubgroup(A4, [3]);; Length(ComputedHallSubgroups(A4));
4
gap> NormalHallSubgroupsFromSylows(A4, "any")=Group((1,2)(3,4),(1,3)(2,4));
true
gap> D := DihedralGroup(8);; NormalHallSubgroupsFromSylows(D, "any");
fail
gap> HasNormalHallSubgroups(D);
true
gap> NormalHallSubgroupsFromSylows(D)=[TrivialSubgroup(D), D];
true
gap> NormalHallSubgroupsFromSylows(D, "any");
fail
gap> D := DihedralGroup(12);; 
gap> List(NormalHallSubgroups(D), Size);
[ 1, 3, 12 ]
gap> Size(NormalHallSubgroupsFromSylows(D, "any"));
3
gap> NormalHallSubgroupsFromSylows(Group(()), "any");
fail
gap> Length(NormalHallSubgroups(Group(())));
1
gap> STOP_TEST("NormalHallSubgroups.tst", 1);
