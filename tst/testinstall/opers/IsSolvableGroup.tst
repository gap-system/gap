gap> START_TEST("IsSolvableGroup.tst");
gap> List(AllGroups(120), IsSolvableGroup);
[ true, true, true, true, false, true, true, true, true, true, true, true, 
  true, true, true, true, true, true, true, true, true, true, true, true, 
  true, true, true, true, true, true, true, true, true, false, false, true, 
  true, true, true, true, true, true, true, true, true, true, true ]
gap> List(AllTransitiveGroups(DegreeAction, 8), IsSolvable);
[ true, true, true, true, true, true, true, true, true, true, true, true, 
  true, true, true, true, true, true, true, true, true, true, true, true, 
  true, true, true, true, true, true, true, true, true, true, true, true, 
  false, true, true, true, true, true, false, true, true, true, true, false, 
  false, false ]
gap> IsSolvable(DihedralGroup(24));
true
gap> IsSolvable(DihedralGroup(IsFpGroup,24));
true
gap> DerivedSeries(Group(()));
[ Group(()) ]
gap> IsSolvableGroup(AbelianGroup([2,3,4,5,6,7,8,9,10]));
true
gap> IsSolvableGroup(AbelianGroup(IsFpGroup,[2,3,4,5,6,7,8,9,10]));
true
gap> IsSolvableGroup(Group(()));
true
gap> A := AbelianGroup([3,3,3]);; H := AutomorphismGroup(A);;
gap> B := SylowSubgroup(H, 13);; G := SemidirectProduct(B, A);;
gap> HasIsSolvableGroup(G) and IsSolvable(G);
true
gap> F := FreeGroup("r", "s");; r := F.1;; s := F.2;;
gap> G := F/[s^2, s*r*s*r];;
gap> IsSolvable(G);
true
gap> STOP_TEST("IsSolvableGroup.tst", 10000);
