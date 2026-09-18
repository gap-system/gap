# `PreImagesElm' for field homomorphisms compared `IsInjective' with 1
# (a GAP3 leftover), so the injective branch was dead and every nonzero
# element got the empty preimage. Fixing that exposed that Frobenius
# automorphisms had no `PreImagesRepresentative' method at all.
gap> frob := FrobeniusAutomorphism(GF(4));;
gap> PreImagesRepresentative(frob, Z(4));
Z(2^2)^2
gap> ImageElm(frob, PreImagesRepresentative(frob, Z(4))) = Z(4);
true
gap> PreImagesElm(frob, Z(4));
[ Z(2^2)^2 ]
gap> PreImagesElm(frob, 0*Z(4));
[ 0*Z(2) ]
gap> PreImagesSet(frob, GF(4)) = GF(4);
true

# a proper power of the Frobenius automorphism over a larger field
gap> aut := FrobeniusAutomorphism(GF(8))^2;;
gap> x := PreImagesRepresentative(aut, Z(8));;
gap> ImageElm(aut, x) = Z(8);
true
gap> PreImagesElm(aut, Z(8)) = [ x ];
true
