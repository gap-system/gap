gap> START_TEST("MaximalNormalSubgroups.tst");
gap> G := SymmetricGroup(4);; MaximalNormalSubgroups(G)=[DerivedSubgroup(G)];
true
gap> G := SymmetricGroup(5);; MaximalNormalSubgroups(G)=[DerivedSubgroup(G)];
true
gap> G := AlternatingGroup(5);; Size(MaximalNormalSubgroups(G))=1 and IsTrivial(MaximalNormalSubgroups(G)[1]);
true
gap> l := [2,4,8,3,9,5,25,7];; G := DirectProduct(List(l, CyclicGroup));;
gap> SortedList(List(MaximalNormalSubgroups(G),N ->List(MinimalGeneratingSet(N),Order)));
[ [ 2, 12, 12600 ], [ 2, 12, 12600 ], [ 2, 12, 12600 ], [ 2, 12, 12600 ], 
  [ 2, 12, 12600 ], [ 2, 20, 12600 ], [ 2, 20, 12600 ], [ 2, 20, 12600 ], 
  [ 2, 30, 12600 ], [ 2, 30, 12600 ], [ 2, 60, 1800 ], [ 2, 60, 2520 ], 
  [ 2, 60, 4200 ], [ 2, 60, 6300 ], [ 60, 12600 ], [ 60, 12600 ], 
  [ 60, 12600 ], [ 60, 12600 ] ]
gap> A := AbelianGroup(IsFpGroup, [2,4,8,3,9,5,25,7]);;
gap> SortedList(List(MaximalNormalSubgroups(A),N -> AbelianInvariants(N)));
[ [ 2, 2, 3, 5, 7, 8, 9, 25 ], [ 2, 2, 3, 5, 7, 8, 9, 25 ], 
  [ 2, 3, 3, 4, 5, 7, 8, 25 ], [ 2, 3, 4, 4, 5, 7, 9, 25 ], 
  [ 2, 3, 4, 5, 5, 7, 8, 9 ], [ 2, 3, 4, 5, 8, 9, 25 ], 
  [ 2, 3, 4, 7, 8, 9, 25 ], [ 2, 3, 4, 7, 8, 9, 25 ], 
  [ 2, 3, 4, 7, 8, 9, 25 ], [ 2, 3, 4, 7, 8, 9, 25 ], 
  [ 2, 3, 4, 7, 8, 9, 25 ], [ 2, 4, 5, 7, 8, 9, 25 ], 
  [ 2, 4, 5, 7, 8, 9, 25 ], [ 2, 4, 5, 7, 8, 9, 25 ], 
  [ 3, 4, 5, 7, 8, 9, 25 ], [ 3, 4, 5, 7, 8, 9, 25 ], 
  [ 3, 4, 5, 7, 8, 9, 25 ], [ 3, 4, 5, 7, 8, 9, 25 ] ]
gap> ForAll(MaximalNormalSubgroups(A), N -> IsSubgroup(A, N) and IsNormal(A, N));
true
gap> D1 := DihedralGroup(Factorial(10));;
gap> SortedList(List(MaximalNormalSubgroups(D1), StructureDescription));
[ "C1814400", "D1814400", "D1814400" ]
gap> D2 := DihedralGroup(IsFpGroup, 36);;
gap> SortedList(List(MaximalNormalSubgroups(D2), StructureDescription));
[ "C18", "D18", "D18" ]
gap> ForAll(MaximalNormalSubgroups(D2), N -> IsSubgroup(D2, N) and IsNormal(D2, N));
true

# some infinite fp-groups
gap> F := FreeGroup("r", "s");; r := F.1;; s := F.2;;
gap> G := F/[r^(-1)*s^(-1)*r*s, r^18, s^24];;
gap> Length(MaximalNormalSubgroups(G));
7
gap> G := F/[s^2, s*r*s*r];;
gap> Length(MaximalNormalSubgroups(G));
3
gap> G := F/[s^2];;
gap> MaximalNormalSubgroups(G);
Error, number of maximal normal subgroups is infinity
gap> G := F/[s^2, r*s*r^(-1)*s^(-1)];;
gap> MaximalNormalSubgroups(G);
Error, number of maximal normal subgroups is infinity
gap> MaximalNormalSubgroups( AbelianGroup( [ 0 ] ) );
Error, number of maximal normal subgroups is infinity

# a finite fp-group
gap> G := F/[r^12, s^2, r*s*r^(-1)*s^(-1)];;
gap> SortedList(List(MaximalNormalSubgroups(G), AbelianInvariants));
[ [ 2, 2, 3 ], [ 2, 4 ], [ 3, 4 ], [ 3, 4 ] ]
gap> STOP_TEST("MaximalNormalSubgroups.tst", 1);
