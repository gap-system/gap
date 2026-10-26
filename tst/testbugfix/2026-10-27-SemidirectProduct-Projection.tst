# Regression test for https://github.com/gap-system/gap/issues/5046
# Projection of a semidirect product with a vector space
gap> check := function(P)
>   local info, pi, emb, gens;
>   info := SemidirectProductInfo(P);
>   pi := Projection(P);
>   emb := Embedding(P, 1);
>   gens := GeneratorsOfGroup(info.group);
>   return [ Image(pi) = info.group,
>     Kernel(pi) = Image(Embedding(P, 2)),
>     ForAll(GeneratorsOfGroup(Image(Embedding(P, 2))),
>            x -> IsOne(ImagesRepresentative(pi, x))),
>     ForAll(gens, g -> ImagesRepresentative(pi, ImagesRepresentative(emb, g)) = g),
>     ForAll(gens, g -> ImagesRepresentative(pi, PreImagesRepresentative(pi, g)) = g) ];
> end;;

# matrix group, from the issue
gap> a := [[4,1],[0,3]]*One(GF(11));;
gap> b := [[0,3],[7,10]]*One(GF(11));;
gap> P := SemidirectProduct(Group(a, b), GF(11)^2);;
gap> Size(P);
14520
gap> check(P);
[ true, true, true, true, true ]

# permutation group
gap> P := SemidirectProduct(SymmetricGroup(3), GF(2)^3);;
gap> check(P);
[ true, true, true, true, true ]

# matrix group over a proper subfield
gap> g := Group((3,4,5), (1,2,3));;
gap> mats := [[[Z(2^2),0*Z(2)],[0*Z(2),Z(2^2)^2]],
>             [[Z(2)^0,Z(2)^0], [Z(2)^0,0*Z(2)]]];;
gap> hom := GroupHomomorphismByImages(g, Group(mats), [g.1, g.2], mats);;
gap> P := SemidirectProduct(g, hom, GF(16)^2);;
gap> check(P);
[ true, true, true, true, true ]
