#############################################################################
##
##  Some tests for permutation groups and friends(takes a few seconds to run)
##
#@local g, dc, ac, p, s, dc1, u, part, iso,l,it,i
gap> START_TEST("permgrp.tst");
gap> Size(Normalizer(SymmetricGroup(100),PrimitiveGroup(100,1)));
1209600
gap> g:=Image(RegularActionHomomorphism(AbelianGroup([4,5,5])));;
gap> Size(Normalizer(SymmetricGroup(100),g));       
96000

# the following tests used to choke GAP, because GAP failed to find
# certain intermediate subgroups, such as M11; as such, the degrees
# of symmetric groups in these tests are crucial
gap> g:=SymmetricGroup(11);;s:=SylowSubgroup(g,11);;
gap> dc:=DoubleCosetRepsAndSizes(g,s,s);;
gap> Length(dc);Sum(dc,x->x[2])=Size(g);
329900
true
gap> g:=SymmetricGroup(13);;s:=SylowSubgroup(g,13);;
gap> ac:=AscendingChain(g,s);;
gap> Maximum(List([2..Length(ac)],x->Index(ac[x],ac[x-1])))<600000;
true
gap> g:=SymmetricGroup(5);;p:=SylowSubgroup(g,5);;
gap> Length(IntermediateSubgroups(g,p).subgroups);
3
gap> g:=SL(6,2);;
gap> p:=Image(IsomorphismPermGroup(g));;
gap> s:=SylowSubgroup(p,7);;
gap> Length(IntermediateSubgroups(p,s).subgroups);
71
gap> g:=SymmetricGroup(9);;s:=SylowSubgroup(g,3);;
gap> dc:=DoubleCosetRepsAndSizes(g,s,s);;
gap> Length(dc);Sum(dc,x->x[2])=Size(g);
88
true
gap> dc1:=DoubleCosetRepsAndSizes(g,s,s:sisyphus);;
gap> Collected(List(dc,x->x[2]))=Collected(List(dc1,x->x[2]));
true

# The purpose of the following test is to test groups with a large number
# of classes.  The assertions for checking the classes will slow the
# calculation down beyond usability, thus change assertion level
gap> SetAssertionLevel(1);
gap> g:=Group((1,27,22,31,13,3,25,24,29,16)(2,28,21,32,14,4,26,23,30,15)
> (5,17,37,43,33,8,19,40,41,35)(6,18,38,44,34,7,20,39,42,36)(9,12)
> (10,11), (1,20,21,33,26,2,19,22,34,25)(3,17,23,35,28)(4,18,24,36,27)
> (5,30,14,12,42)(6,29,13,11,41)(7,31,16,9,43)(8,32,15,10,44));;
gap> IsSolvableGroup(g);
true
gap> Sum(ConjugacyClasses(g),Size);
461373440
gap> g:=Group((1,2,4,3)(5,9,20,36,24,41,37,30,15,27,6,11,19,34,23,43,38,
> 32,16,25)(7,10,18,35,22,42,39,29,13,28,8,12,17,33,21,44,40,31,14,26),
> (1,20,38,30,42)(2,17,40,29,43,3,19,39,32,41,4,18,37,31,44)
> (5,36,13,23,10,6,33,15,24,11,8,34,14,22,12)(7,35,16,21,9)(25,27,28));;
gap> IsSolvableGroup(g);
true
gap> Sum(ConjugacyClasses(g),Size);
1384120320

# Construct modules
gap> g:=PerfectGroup(IsPermGroup,7500,1);;
gap> s:=IrreducibleModules(g,GF(2));;
gap> Collected(List(s[2],x->x.dimension));
[ [ 1, 1 ], [ 4, 2 ], [ 24, 5 ], [ 40, 1 ], [ 60, 1 ], [ 80, 1 ] ]
gap> Collected(List(s[2],MTX.IsAbsolutelyIrreducible));
[ [ true, 2 ], [ false, 9 ] ]
gap> s:=First(s[2],x->x.dimension=24);;
gap> p:=PermrepSemidirectModule(g,s).group;;
gap> Size(p);
125829120000

# Condition test
gap> g:=SymmetricGroup(10);;
gap> s:=Group((1,3,2)(5,8)(6,9)(7,10), (2,3)(4,10,5)(6,9,8));;
gap> u:=SubgroupConditionAbove(g,x->OnSets([1,2,3],x)=[1,2,3],s);;
gap> Size(u);
30240

# automorphisms and maximals rep code
gap> g:=PerfectGroup(IsPermGroup,30720,5);;
gap> Size(AutomorphismGroup(g));
1843200
gap> g:=PerfectGroup(IsPermGroup,967680,5);;
gap> FactPermRepMaxDesc(g,Centre(g),5);;
gap> DegreeNaturalHomomorphismsPool(g,Centre(g))<30;
true

# Partition stabilizer
gap> g:=PrimitiveGroup(36,16);;
gap> part:=[[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,17],
> [16,18,19,20,21,22,23,24,25,26,27,28,29,30,32,33],[31,34,35,36]];;
gap> u:=PartitionStabilizerPermGroup(g,part);;
gap> Size(u);
4608
gap> Size(g)/Length(Orbit(g,part,OnTuplesSets));
4608

# simplicity
gap> g:=PerfectGroup(IsPermGroup,360,1);;
gap> IsSimpleGroup(g);
true
gap> IsNonabelianSimpleGroup(g);
true

# small double coset
gap> g:=TransitiveGroup(12,291);;
gap> s:=SylowSubgroup(g,3);;
gap> Length(DoubleCosets(g,s,s));
24
gap> iso:=IsomorphismPcGroup(g);;
gap> Length(DoubleCosets(Image(iso,g),Image(iso,s),Image(iso,s)));
24

# some lattice and deductions
gap> MinimalFaithfulPermutationDegree(PerfectGroup(IsPermGroup,7680,1));
76
gap> g:=SymmetricGroup(6);;
gap> it:=DescSubgroupIterator(g);;
gap> l:=[];;for i in it do Add(l,i);od;Length(l);
56
gap> it:=DescSubgroupIterator(g:skip:=20);;
gap> l:=[];;for i in it do Add(l,i);od;

# conjugator
gap> w:=WreathProduct(SymmetricGroup(6),Group((1,2)));;
gap> d:=DerivedSubgroup(w);;
gap> d:=DerivedSubgroup(d);;
gap> a:=Image(Embedding(w,3),(1,2));;
gap> hom:=ConjugatorAutomorphism(w,a);;
gap> hom:=AsGroupGeneralMappingByImages(hom);;
gap> HasIsConjugatorAutomorphism(hom);
false
gap> IsConjugatorAutomorphism(hom);
true

#
gap> STOP_TEST( "permgrp.tst", 1);
