# Regression test for https://github.com/gap-system/gap/issues/6782
# Tails of perm group pcgs whose normal series is not elementary abelian
gap> s := Socle(SymmetricGroup(4));;
gap> p := Pcgs(s);;
gap> i := InducedPcgsByPcSequence(p, p{[1, 2]});;
gap> i = p and ParentPcgs(i) = p;
true
gap> List(i, x -> ExponentsOfPcElement(i, x));
[ [ 1, 0 ], [ 0, 1 ] ]

# A4 as normal closure of a 3-cycle; its pcgs has normal steps [ 1, 2, 4 ]
gap> U := SolvableNormalClosurePermGroup(SymmetricGroup(4), [ (1,2,3) ]);;
gap> p := Pcgs(U);;
gap> i := InducedPcgsByPcSequence(p, p{[2, 3]});;
gap> Size(Group(AsList(i))) = 4 and ParentPcgs(i) = p;
true
gap> ExponentsOfPcElement(i, i[1] * i[2]);
[ 1, 1 ]

# C4 x C4, a single normal step with non-elementary abelian factor
gap> G := WreathProduct(CyclicGroup(IsPermGroup, 4), CyclicGroup(IsPermGroup, 2));;
gap> U := SolvableNormalClosurePermGroup(G, [ G.1 ]);;
gap> p := Pcgs(U);;
gap> i := InducedPcgsByPcSequence(p, AsList(p));;
gap> i = p and ParentPcgs(i) = p;
true
gap> ForAll(U, x -> PcElementByExponents(i, ExponentsOfPcElement(i, x)) = x);
true
