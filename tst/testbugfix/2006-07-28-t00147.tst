# 2006/07/28 (RFM)
gap> g := CyclicGroup(1);;
gap> SchurCover(g);;
gap> sc := SchurCover(g);;
gap> IdGroup(sc);
[ 1, 1 ]
gap> epi := EpimorphismSchurCover(g);;
gap> Image(epi)=g;
true
gap> IdGroup(Source(epi));
[ 1, 1 ]
gap> G := SmallGroup(27,3);;
gap> IsCentralFactor(G);
true
gap> AbelianInvariantsMultiplier(G);
[ 3, 3 ]
gap> AbelianInvariants(Kernel(EpimorphismNonabelianExteriorSquare(G)));
[ 3, 3 ]
gap> ec := Epicentre(DirectProduct(CyclicGroup(25),CyclicGroup(5)));;
gap> IsTrivial(ec);
false
gap> ec := Epicentre(DirectProduct(CyclicGroup(3),CyclicGroup(3)));;
gap> IsTrivial(ec);
true
