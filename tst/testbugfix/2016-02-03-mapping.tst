# The following test verifies we handle pcgs with large primes in them efficiently.
# See also GitHub pull requests #576 and #578
gap> V := AsVectorSpace (GF(2), GF(2^17));;
gap> h := BlownUpMat(Basis(V), [[Z(2^17)]]);;
gap> ConvertToMatrixRep(h);;
gap> G := CyclicGroup (2^17-1);;
gap> H := Group (h);;
gap> hom := GroupHomomorphismByImagesNC (G, H, [G.1], [h]);;
gap> ImagesRepresentative(hom, G.1^2) = h^2;
true
