# Size, membership and preimages for the translation subgroup of a
# semidirect product with a vector space must not take a minute
gap> P := SemidirectProduct(SU(3,3), GF(9)^3);;
gap> emb := Embedding(P, 2);;
gap> N := Image(emb);;
gap> HasSize(N);
true
gap> Size(N);
729
gap> v := [ 1, 0, 1 ] * Z(9);;
gap> ImagesRepresentative(emb, v) in N;
true
gap> PreImagesRepresentative(emb, ImagesRepresentative(emb, v)) = v;
true
gap> GeneratorsOfGroup(P)[1] in N;
false
gap> PreImagesRepresentative(emb, GeneratorsOfGroup(P)[1]);
Error, <elm> is not in the range of <map>
