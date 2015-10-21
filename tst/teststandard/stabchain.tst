#############################################################################
##
#W  stabchain.tst                   GAP library		     Markus Pfeiffer
##
##
##  Test orbit algorithms, which use hashing
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
gap> STOP_TEST( "stabchain.tst", 130120000);

#############################################################################
##
#E  
