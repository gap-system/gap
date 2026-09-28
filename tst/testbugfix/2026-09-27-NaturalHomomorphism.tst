# NaturalHomomorphism for a FactorGroup must warn, not error.
# See https://github.com/gap-system/gap/issues/2376
gap> G := SymmetricGroup(4);;
gap> F := FactorGroup(G, DerivedSubgroup(G));;
gap> hom := NaturalHomomorphism(F);;
#I  `NaturalHomomorphism` for a `FactorGroup` is deprecated; use `NaturalHomomorphismByNormalSubgroup` instead.
gap> Image(hom) = F and Kernel(hom) = DerivedSubgroup(G);
true
