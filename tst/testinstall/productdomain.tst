#@local D8, fam, dpf, d, emptyDPDDim2, emptyDPDDim3, dpdDim0, dpd
#@local range1, range2, g1, g2, dpdOfGroups, bijToRange, inv, tups
#@local dpdNotAttributeStoring
gap> START_TEST("productdomain.tst");

# DirectProductFamily
gap> D8 := DihedralGroup(IsPermGroup, 8);;
gap> fam := FamilyObj(D8);
<Family: "CollectionsFamily(...)">
gap> ElementsFamily(fam);
<Family: "PermutationsFamily">
gap> dpf := DirectProductFamily([fam, fam]);
<Family: "CollectionsFamily(...)">
gap> IsDirectProductElementFamily(ElementsFamily(dpf));
true
gap> DirectProductFamily([CyclotomicsFamily, ]);
Error, <args> must be a dense list of collection families

# DirectProductDomain
# of empty domains, dim 2
gap> d := Domain(FamilyObj([1]), []);
Domain([  ])
gap> emptyDPDDim2 := DirectProductDomain([d, d]);
DirectProductDomain([ Domain([  ]), Domain([  ]) ])
gap> Size(emptyDPDDim2);
0
gap> IsEmpty(emptyDPDDim2);
true
gap> DimensionOfDirectProductDomain(emptyDPDDim2);
2
gap> DirectProductElement([]) in emptyDPDDim2;
false

# of empty domains, dim 3
gap> emptyDPDDim3 := DirectProductDomain(d, 3);
DirectProductDomain([ Domain([  ]), Domain([  ]), Domain([  ]) ])
gap> Size(emptyDPDDim3);
0
gap> IsEmpty(emptyDPDDim3);
true
gap> DimensionOfDirectProductDomain(emptyDPDDim3);
3
gap> DirectProductElement([]) in emptyDPDDim3;
false

# of dimension 0
gap> range1 := Domain([1..5]);
Domain([ 1 .. 5 ])
gap> dpdDim0 := DirectProductDomain(range1, 0);
DirectProductDomain([  ])
gap> Size(dpdDim0);
1
gap> IsEmpty(dpdDim0);
false
gap> DimensionOfDirectProductDomain(dpdDim0);
0
gap> DirectProductElement([]) in dpdDim0;
true

# of domains of ranges
gap> range1;
Domain([ 1 .. 5 ])
gap> range2 := Domain([3..7]);
Domain([ 3 .. 7 ])
gap> dpd := DirectProductDomain([range1, range2]);
DirectProductDomain([ Domain([ 1 .. 5 ]), Domain([ 3 .. 7 ]) ])
gap> Size(dpd);
25
gap> DimensionOfDirectProductDomain(dpd);
2
gap> DirectProductElement([]) in dpd;
false
gap> DirectProductElement([6, 3]) in dpd;
false
gap> DirectProductElement([1, 3]) in dpd;
true

# DirectProductDomain
# of groups
gap> g1 := DihedralGroup(4);
<pc group of size 4 with 2 generators>
gap> g2 := DihedralGroup(IsPermGroup, 4);
Group([ (1,2), (3,4) ])
gap> dpdOfGroups := DirectProductDomain([g1, g2]);
DirectProductDomain([ Group( [ f1, f2 ] ), Group( [ (1,2), (3,4) ] ) ])
gap> Size(dpdOfGroups);
16
gap> DimensionOfDirectProductDomain(dpdOfGroups);
2
gap> DirectProductElement([]) in dpdOfGroups;
false
gap> DirectProductElement([1, 3]) in dpdOfGroups;
false
gap> DirectProductElement([g1.1, g2.1]) in dpdOfGroups;
true

# DirectProductDomain
# error handling
gap> DirectProductDomain([CyclotomicsFamily]);
Error, args must be a dense list of domains
gap> DirectProductDomain(dpd, -1);
Error, <k> must be a nonnegative integer

#
gap> STOP_TEST("productdomain.tst");
