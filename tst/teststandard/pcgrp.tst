gap> START_TEST("pcgrp.tst");

# big abelian groups
gap> g:=AbelianGroup(ListWithIdenticalEntries(200,3));;
gap> p:=Pcgs(g);;
gap> hom:=GroupHomomorphismByImages(g,g,p,Reversed(p));;
gap> Inverse(hom);;
gap> p mod InducedPcgsByPcSequence(p,p{[1..100]});;

#############################################################################
gap> STOP_TEST( "pcgrp.tst", 1);
