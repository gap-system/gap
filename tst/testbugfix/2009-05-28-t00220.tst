# 2009/05/28 (BH)
gap> G:=AlternatingGroup(4);;
gap> N:=Subgroup(G,[(1,2)(3,4),(1,3)(2,4)]);;
gap> H:=DirectProduct(CyclicGroup(2),CyclicGroup(2));;
gap> A:=AutomorphismGroup(H);;
gap> P:=SylowSubgroup(A,3);;
gap> epi:=NaturalHomomorphismByNormalSubgroup(G,N);;
gap> iso:=IsomorphismGroups(FactorGroup(G,N),P);;
gap> f:=CompositionMapping(IsomorphismGroups(FactorGroup(G,N),P),epi);;
gap> SemidirectProduct(G,f,H);
<pc group of size 48 with 5 generators>
