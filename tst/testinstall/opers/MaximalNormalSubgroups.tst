gap> START_TEST("normal_hall_subgroups.tst");
gap> G := SymmetricGroup(4);; MaximalNormalSubgroups(G)=[DerivedSubgroup(G)];
true
gap> G := SymmetricGroup(5);; MaximalNormalSubgroups(G)=[DerivedSubgroup(G)];
true
gap> l := [2,4,8,3,9,5,25,7];; G := DirectProduct(List(l, CyclicGroup));;
gap> List(MaximalNormalSubgroups(G),N ->List(MinimalGeneratingSet(N),Order));
[ [ 2, 60, 6300 ], [ 2, 30, 12600 ], [ 2, 30, 12600 ], [ 60, 12600 ], 
  [ 60, 12600 ], [ 60, 12600 ], [ 60, 12600 ], [ 2, 60, 4200 ], 
  [ 2, 20, 12600 ], [ 2, 20, 12600 ], [ 2, 20, 12600 ], [ 2, 60, 2520 ], 
  [ 2, 12, 12600 ], [ 2, 12, 12600 ], [ 2, 12, 12600 ], [ 2, 12, 12600 ], 
  [ 2, 12, 12600 ], [ 2, 60, 1800 ] ]
gap> D := DihedralGroup(Factorial(10));;
gap> List(MaximalNormalSubgroups(G), StructureDescription);
[ "C6300 x C60 x C2", "C12600 x C30 x C2", "C12600 x C30 x C2", 
  "C12600 x C60", "C12600 x C60", "C12600 x C60", "C12600 x C60", 
  "C4200 x C60 x C2", "C12600 x C20 x C2", "C12600 x C20 x C2", 
  "C12600 x C20 x C2", "C2520 x C60 x C2", "C12600 x C12 x C2", 
  "C12600 x C12 x C2", "C12600 x C12 x C2", "C12600 x C12 x C2", 
  "C12600 x C12 x C2", "C1800 x C60 x C2" ]
gap> STOP_TEST("normal_hall_subgroups.tst", 10000);
