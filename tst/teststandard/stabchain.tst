#############################################################################
##
#W  stabchain.tst                   GAP library		     Markus Pfeiffer
##
##
##  Test orbit algorithms, which use hashing
##  Also a few direct tests of SCRSift, since I have been working on it.
##     SL
##  Exclude from testinstall.g: why?
##
gap> START_TEST("stabchain.tst");
gap> G := SymmetricGroup(10);;
gap> Size(G);
3628800
gap> S := StabChain(G, [1,2,3,4,5,6,7,8,9]);;
gap> it := IteratorStabChain(S);;
gap> NextIterator(it);
()
gap> NextIterator(it);
(9,10)
gap> NextIterator(it);
(8,10)
gap> it2 := ShallowCopy(it);;
gap> NextIterator(it2);; b := NextIterator(it2);;
gap> NextIterator(it);; a := NextIterator(it);;
gap> a = b;
true
gap> while not IsDoneIterator(it) do NextIterator(it); od;;
gap> l := List(it2);;
gap> Length(l);
3628795
gap> SCRSift(S,(1,2));
()
gap> SCRSift(S,(1,11));
(1,11)
gap> SCRSift(S,(1,10));
()
gap> m := MathieuGroup(24);;
gap> S := StabChain(m,[1..24]);
<stabilizer chain record, Base [ 1, 2, 3, 4, 5, 6, 7 ], Orbit length 
24, Size: 244823040>
gap> SCRSift(S,(1,2));
(8,11)(9,21)(12,23)(14,16)(17,22)(18,24)(19,20)
gap> SCRSift(S,GeneratorsOfGroup(m)[1]);
()

# Unbind variables so we can GC memory
gap> Unbind(G); Unbind(S); Unbind(it); Unbind(it2); Unbind(l); Unbind(m);
gap> STOP_TEST( "stabchain.tst", 1);

#############################################################################
##
#E  
