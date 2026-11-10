#@local g1,g2,g3,d1,d2,d3,d4,F,a,au,hom,P,pi
gap> START_TEST("gprd.tst");

# Test that information about IsNilpotentGroup is preserved by DirectProduct
gap> g1 := SymmetricGroup(3);;
gap> IsNilpotentGroup(g1);
false
gap> g2 := CyclicGroup(IsPermGroup, 6);;
gap> IsNilpotentGroup(g2);
true
gap> d1 := DirectProduct(g1, g1);;
gap> HasIsNilpotentGroup(d1) and not IsNilpotentGroup(d1);
true
gap> d2 := DirectProduct(g1, g2);;
gap> HasIsNilpotentGroup(d2) and not IsNilpotentGroup(d2);
true
gap> d3 := DirectProduct(g2, g2);;
gap> HasIsNilpotentGroup(d3) and IsNilpotentGroup(d3);
true
gap> g3 := Group([(1,2), (1,2,3)]);;
gap> d4 := DirectProduct(g3, g3, g3);;
gap> (HasIsNilpotentGroup(g3) and HasIsNilpotentGroup(d4)
> and not IsNilpotentGroup(d4)) or (not HasIsNilpotentGroup(g3) and not
> HasIsNilpotentGroup(d4));
true

# Test that information about IsFinite is preserved by DirectProduct
gap> g1 := SymmetricGroup(3);;
gap> HasIsFinite(g1) and IsFinite(g1);
true
gap> g2 := FreeGroup(1);;
gap> IsFinite(g2);
false
gap> d1 := DirectProduct(g1, g1);;
gap> HasIsFinite(d1) and IsFinite(d1);
true
gap> d2 := DirectProduct(g1, g2);;
gap> HasIsFinite(d2) and not IsFinite(d2);
true
gap> d3 := DirectProduct(g2, g2);;
gap> HasIsFinite(d3) and not IsFinite(d3);
true
gap> g3 := SymmetricGroup(5);;
gap> d4 := DirectProduct(g1, g2, g3);;
gap> HasIsFinite(d4) and not IsFinite(d4);
true

#
gap> d1 := DirectProductOfPermGroupsWithMovedPoints([g1, g1, g1], [[1..4], [1..4], [1..4]]);;
gap> MovedPoints(d1);
[ 1, 2, 3, 5, 6, 7, 9, 10, 11 ]
gap> HasIsFinite(d1) and IsFinite(d1);
true

# Embeddings and projection of a semidirect product with an fp group
gap> F := FreeGroup("a");; g1 := F / [ F.1^2 ];;
gap> g2 := Group((1,2,3));;
gap> a := GroupHomomorphismByImages(g2, g2, [ (1,2,3) ], [ (1,3,2) ]);;
gap> au := Group(a);; SetIsGroupOfAutomorphisms(au, true);
gap> hom := GroupHomomorphismByImages(g1, au, [ g1.1 ], [ a ]);;
gap> P := SemidirectProduct(g1, hom, g2);;
gap> IsFpGroup(P) and Size(P) = 6;
true
gap> Source(Embedding(P, 1)) = g1 and Source(Embedding(P, 2)) = g2;
true
gap> pi := Projection(P);;
gap> ImagesRepresentative(pi, ImagesRepresentative(Embedding(P, 1), g1.1)) = g1.1;
true
gap> IsTrivial(Image(pi, Image(Embedding(P, 2))));
true

#
gap> STOP_TEST("gprd.tst");
