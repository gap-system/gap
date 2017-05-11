#############################################################################
##
#W  permgrp.tst                GAP Library                     
##
##
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
gap> STOP_TEST( "permgrp.tst", 1);

#############################################################################
##
#E
