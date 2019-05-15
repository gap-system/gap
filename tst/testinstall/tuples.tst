gap> START_TEST("tuples.tst");
gap> D8 := DihedralGroup(IsPermGroup, 8);;
gap> fam := FamilyObj(D8);
<Family: "CollectionsFamily(...)">
gap> ElementsFamily(fam);
<Family: "PermutationsFamily">
gap> dpf := DirectProductFamily([fam, fam]);
<Family: "CollectionsFamily(...)">
gap> IsDirectProductElementFamily(ElementsFamily(dpf));
true

#
gap> STOP_TEST("tuples.tst");
