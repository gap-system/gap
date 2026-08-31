#@local f,tuples,map,comp,id,inv,g,z,mf,d,hom,D,emb,prj,F,fp,fhom,aut,frob
#@local V,W,vf,C2,C6,pchom,rel
gap> START_TEST("preimages.tst");

# perm group homomorphism by images: injective, not surjective
gap> f := GroupHomomorphismByImages(Group((1,2)), SymmetricGroup(3),
> [(1,2)], [(1,2)]);;
gap> PreImagesRepresentative(f, (1,2));
(1,2)
gap> PreImagesRepresentative(f, (1,2,3));
fail
gap> PreImagesRepresentative(f, (1,4));
Error, <elm> is not in the range of mapping <hom>
gap> PreImagesElm(f, (1,2));
RightCoset(Group(()),(1,2))
gap> PreImagesElm(f, (1,2,3));
fail
gap> PreImagesElm(f, (1,4));
Error, <elm> is not in the range of <map>
gap> PreImagesSet(f, Group((1,2)));
Group([ (1,2) ])
gap> PreImagesSet(f, Group((1,2,3)));
Group(())
gap> PreImagesSet(f, Group((1,4)));
Error, <elms> is not a subgroup of the range of <map>

# constant time access general mapping
gap> tuples := [DirectProductElement([(),()]),
> DirectProductElement([(1,2),(1,2)])];;
gap> map := GeneralMappingByElements(Group((1,2)), SymmetricGroup(3), tuples);;
gap> PreImagesRepresentative(map, (1,2));
(1,2)
gap> PreImagesRepresentative(map, (1,2,3));
fail
gap> PreImagesRepresentative(map, (1,4));
Error, <elm> is not in the range of <map>
gap> PreImagesElm(map, (1,2));
[ (1,2) ]
gap> PreImagesElm(map, (1,2,3));
fail
gap> PreImagesElm(map, (1,4));
Error, <elm> is not in the range of <map>
gap> PreImagesSet(map, [(), (1,2,3)]);
[ () ]
gap> PreImagesSet(map, [(1,4)]);
Error, <elms> is not a subset of the range of <map>

# composition mapping
gap> comp := CompositionMapping(GroupHomomorphismByImages(SymmetricGroup(3),
> SymmetricGroup(4), [(1,2),(1,2,3)], [(1,2),(1,2,3)]), map);;
gap> IsCompositionMappingRep(comp);
true
gap> PreImagesRepresentative(comp, (1,2));
(1,2)
gap> PreImagesRepresentative(comp, (1,2,3));
fail
gap> PreImagesRepresentative(comp, (1,5));
Error, <elm> is not in the range of mapping <com>
gap> PreImagesElm(comp, (1,2));
[ (1,2) ]
gap> PreImagesElm(comp, (1,2,3));
fail
gap> PreImagesElm(comp, (1,5));
Error, <elm> is not in the range of mapping <com>
gap> PreImagesSet(comp, [(), (1,2,3)]);
[ () ]
gap> PreImagesSet(comp, [(1,5)]);
Error, <elms> is not a subset of the range of mapping <com>

# identity mapping
gap> id := IdentityMapping(SymmetricGroup(3));;
gap> PreImagesRepresentative(id, (1,2));
(1,2)
gap> PreImagesRepresentative(id, (1,4));
Error, <elm> is not in the range of mapping <id>
gap> PreImagesElm(id, (1,2));
[ (1,2) ]
gap> PreImagesElm(id, (1,4));
Error, <elm> is not in the range of mapping <id>
gap> PreImagesSet(id, [(1,2)]);
[ (1,2) ]
gap> PreImagesSet(id, [(1,4)]);
Error, <elms> is not a subset of the range of mapping <id>

# inverse general mapping
gap> g := GroupHomomorphismByImages(Group((1,2,3)), Group((4,5,6)),
> [(1,2,3)], [(4,5,6)]);;
gap> inv := InverseGeneralMapping(g);;
gap> PreImagesRepresentative(inv, (1,2,3));
(4,5,6)
gap> PreImagesRepresentative(inv, (1,2));
Error, <elm> is not in the range of mapping <hom>
gap> PreImagesElm(inv, (1,3,2));
RightCoset(Group(()),(4,6,5))
gap> PreImagesElm(inv, (1,2));
Error, <elm> is not in the range of <map>

# zero mapping
gap> z := ZeroMapping(GF(3), GF(3));;
gap> PreImagesRepresentative(z, 0*Z(3));
0*Z(3)
gap> PreImagesRepresentative(z, Z(3));
fail
gap> PreImagesRepresentative(z, Z(9));
Error, <elm> is not in the range of mapping <zero>
gap> PreImagesElm(z, Z(3));
fail
gap> PreImagesElm(z, Z(9));
Error, <elm> is not in the range of mapping <zero>
gap> PreImagesSet(z, [0*Z(3), Z(3)]);
GF(3)
gap> PreImagesSet(z, [Z(9)]);
Error, <elms> is not a subset of the range of mapping <zero>

# mapping by function
gap> d := Domain([1, 2, 3, 4]);;
gap> mf := MappingByFunction(d, d, x -> Minimum(x + 1, 4));;
gap> PreImagesRepresentative(mf, 4);
3
gap> PreImagesRepresentative(mf, 1);
fail
gap> PreImagesElm(mf, 4);
[ 3, 4 ]
gap> PreImagesElm(mf, 1);
fail
gap> PreImagesElm(mf, 7);
Error, <elm> is not in the range of <map>

# action homomorphism
gap> hom := ActionHomomorphism(Group((1,2,3,4)), [1..4]);;
gap> PreImagesRepresentative(hom, (1,2,3,4));
(1,2,3,4)
gap> PreImagesRepresentative(hom, (1,2));
fail
gap> PreImagesRepresentative(hom, (1,5));
Error, <elm> is not in the range of mapping <hom>

# direct product of perm groups
gap> D := DirectProduct(Group((1,2)), Group((1,2,3)));;
gap> emb := Embedding(D, 2);;
gap> PreImagesRepresentative(emb, (3,4,5));
(1,2,3)
gap> PreImagesRepresentative(emb, (1,2));
fail
gap> PreImagesRepresentative(emb, (1,3));
Error, <g> is not in the range of mapping <emb>
gap> prj := Projection(D, 1);;
gap> PreImagesRepresentative(prj, (1,2));
(1,2)
gap> PreImagesRepresentative(prj, (1,3));
Error, <g> is not in the range of mapping <prj>

# homomorphism from fp group
gap> F := FreeGroup("a", "b");;
gap> fp := F / [F.1^2, F.2^3, (F.1*F.2)^2];;
gap> fhom := GroupHomomorphismByImages(fp, SymmetricGroup(3),
> GeneratorsOfGroup(fp), [(1,2), (1,2,3)]);;
gap> PreImagesRepresentative(fhom, (1,2));
a^-1
gap> PreImagesRepresentative(fhom, (1,4));
Error, <elm> is not in the range of mapping <hom>
gap> Size(PreImagesSet(fhom, Group((1,2,3))));
3
gap> PreImagesSet(fhom, Group((1,4)));
Error, <u> is not a subset of the range of <hom>

# field automorphisms
gap> aut := ANFAutomorphism(CF(5), 2);;
gap> PreImagesRepresentative(aut, E(5));
E(5)^3
gap> PreImagesRepresentative(aut, E(7));
Error, <elm> is not in the range of mapping <aut>
gap> PreImagesElm(aut, E(5));
[ E(5)^3 ]
gap> PreImagesElm(aut, E(7));
Error, <elm> is not in the range of mapping <aut>
gap> PreImagesSet(aut, CF(35));
Error, <F> is not a subset of the range of mapping <aut>
gap> frob := FrobeniusAutomorphism(GF(4));;
gap> PreImagesElm(frob, Z(8));
Error, <elm> is not in the range of <hom>

# vector space homomorphism: not surjective
gap> V := GF(2)^2;;
gap> W := GF(2)^3;;
gap> vf := LeftModuleHomomorphismByImages(V, W, Basis(V),
> [[Z(2), 0*Z(2), 0*Z(2)], [0*Z(2), Z(2), 0*Z(2)]]);;
gap> PreImagesRepresentative(vf, [Z(2), Z(2), 0*Z(2)]);
<an immutable GF2 vector of length 2>
gap> PreImagesRepresentative(vf, [0*Z(2), 0*Z(2), Z(2)]);
fail

# pc group homomorphism: not surjective
gap> C2 := CyclicGroup(IsPcGroup, 2);;
gap> C6 := CyclicGroup(IsPcGroup, 6);;
gap> pchom := GroupHomomorphismByImages(C2, C6, GeneratorsOfGroup(C2),
> [C6.1^3]);;
gap> PreImagesRepresentative(pchom, C6.1^3) = C2.1;
true
gap> PreImagesRepresentative(pchom, C6.1^2);
fail

# binary relation on points
gap> rel := BinaryRelationOnPoints([[1, 2], [2], [3]]);;
gap> PreImagesElm(rel, 2);
[ 1, 2 ]
gap> PreImagesElm(rel, 5);
Error, <n> is not in the range of <rel>
gap> STOP_TEST("preimages.tst");
