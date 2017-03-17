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
gap> G := Group((6,7,8,9,10),(8,9,10),(1,2)(6,7),(1,2,3,4)(6,7,8,9));;
gap> Length(DerivedSeriesOfGroup(G));
4
gap> HasIsSolvableGroup(G) and not IsSolvable(G) and HasIsAbelian(G) and not IsAbelian(G);
true
gap> IsSolvableGroup(AbelianGroup([2,3,4,5,6,7,8,9,10]));
true
gap> HasIsSolvableGroup(AbelianGroup(IsFpGroup,[2,3,4,5,6,7,8,9,10]));
true
gap> IsSolvableGroup(AbelianGroup(IsFpGroup,[2,3,4,5,6,7,8,9,10]));
true
gap> IsSolvableGroup(Group(()));
true
gap> A := AbelianGroup([3,3,3]);; H := AutomorphismGroup(A);;
gap> B := SylowSubgroup(H, 13);; G := SemidirectProduct(B, A);;
gap> HasIsSolvableGroup(G) and IsSolvable(G);
true

## some fp-groups
## The following four tests check whether the current IsSolvable method using
## DerivedSeriesOfGroup indeed adds IsAbelian whenever it is appropriate. If
## later new methods for IsSolvable are added, these tests may fail. Then
## these four tests need to be modified accordingly.
gap> F := FreeGroup("r", "s");; r := F.1;; s := F.2;;
gap> G := F/[s^2, s*r*s*r];;
gap> IsSolvable(G) and HasIsAbelian(G) and not IsAbelian(G);
true
gap> F := FreeGroup("a", "b", "c", "d");; a := F.1;; b := F.2;; c := F.3;; d:= F.4;;
gap> G := F/[ a^2, b^2, a*b*a^(-1)*b^(-1), c, d ];;
gap> IsSolvable(G) and HasIsAbelian(G) and IsAbelian(G);
true
gap> G := F/[ a^2, b^2, c^2, (a*b)^3, (b*c)^3, (a*c)^2, d ];;
gap> IsSolvable(G) and HasIsAbelian(G) and not IsAbelian(G);
true
gap> G := F/[ a^2, b^2, c^2, d^2, (a*b)^3, (b*c)^3, (c*d)^3, (a*c)^2, (a*d)^2, (b*d)^2 ];;
gap> not IsSolvable(G) and HasIsAbelian(G) and not IsAbelian(G);
true
gap> STOP_TEST("IsSolvableGroup.tst", 1);
