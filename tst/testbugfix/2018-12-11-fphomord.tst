# hom. order of infinite group in special case (fixing #3097)
gap> f := FreeGroup(2);;
gap> x := GroupHomomorphismByImages(f,f,[f.1,f.2],[f.2,f.1]);;
gap> Order(x);
2
