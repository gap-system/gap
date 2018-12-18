#############################################################################
##
##  Some tests for permutation groups and friends(takes a few seconds to run)
##
gap> START_TEST("permgrp.tst");
gap> Size(Normalizer(SymmetricGroup(100),PrimitiveGroup(100,1)));
1209600
gap> g:=Image(RegularActionHomomorphism(AbelianGroup([4,5,5])));;
gap> Size(Normalizer(SymmetricGroup(100),g));       
96000
gap> g:=SymmetricGroup(11);;s:=SylowSubgroup(g,NrMovedPoints(g));;
gap> dc:=DoubleCosetRepsAndSizes(g,s,s);;
gap> Length(dc);Sum(dc,x->x[2])=Size(g);
329900
true
gap> g:=SymmetricGroup(13);;s:=SylowSubgroup(g,NrMovedPoints(g));;
gap> ac:=AscendingChain(g,s);;
gap> Maximum(List([2..Length(ac)],x->Index(ac[x],ac[x-1])))<600000;
true
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

# Unbind variables so we can GC memory
gap> Unbind(g); Unbind(dc); Unbind(ac); Unbind(g); Unbind(p); Unbind(s);
gap> STOP_TEST( "permgrp.tst", 1);
