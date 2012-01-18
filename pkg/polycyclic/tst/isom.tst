gap> START_TEST("Test of isomorphisms from/to pcp groups");

#
# Extreme case: Test with trivial group
#
gap> K:=TrivialGroup(IsPcpGroup);
Pcp-group with orders [  ]
gap> iso:=IsomorphismPcGroup(K);
[  ] -> [  ]
gap> IsTrivial(Image(iso));
true
gap> iso:=IsomorphismPermGroup(K);
[  ] -> [  ]
gap> IsTrivial(Image(iso));
true
gap> iso:=IsomorphismFpGroup(K);
[  ] -> [  ]
gap> IsTrivial(Image(iso));
true

gap> iso:=IsomorphismPcpGroup(TrivialGroup(IsPcGroup));
[  ] -> [  ]
gap> IsTrivial(Image(iso));
true

gap> iso:=IsomorphismPcpGroup(TrivialGroup(IsPermGroup));
[  ] -> [  ]
gap> IsTrivial(Image(iso));
true


#
# Test with finite cyclic group
#
gap> K:=CyclicGroup(IsPcpGroup, 420);
Pcp-group with orders [ 420 ]

gap> iso:=IsomorphismPcGroup(K);
[ g1 ] -> [ f1 ]
gap> Size(Image(iso));
420
gap> IsCyclic(Image(iso));
true

gap> iso:=IsomorphismPermGroup(K);;
gap> Size(Image(iso));
420
gap> IsCyclic(Image(iso));
true

gap> iso:=IsomorphismFpGroup(K);
[ g1 ] -> [ f1 ]
gap> Size(Image(iso));
420
gap> IsCyclic(Image(iso));
true


#
# Test with infinite cyclic group
#
gap> K:=CyclicGroup(IsPcpGroup, infinity);
Pcp-group with orders [ 0 ]
gap> iso:=IsomorphismFpGroup(K);
[ g1 ] -> [ f1 ]
gap> IsCyclic(Image(iso));
true
gap> IsFinite(Image(iso));
false


#
# Test with dihedral group
#
gap> K:=DihedralGroup(IsPcpGroup, 16);;
gap> IdSmallGroup(K);
[ 16, 7 ]
gap> iso:=IsomorphismPermGroup(K);;
gap> IdSmallGroup(Image(iso));
[ 16, 7 ]
gap> iso:=IsomorphismPcGroup(K);;
gap> IdSmallGroup(Image(iso));
[ 16, 7 ]
gap> iso:=IsomorphismFpGroup(K);;
gap> IdSmallGroup(Image(iso));
[ 16, 7 ]



gap> STOP_TEST( "homs.tst", 10000000);

