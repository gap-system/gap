# `IsSingleValued' and `CoKernelOfMultiplicativeGeneralMapping' for a mapping
# of pc groups skipped any generator whose prescribed image occurred among the
# images of the pcgs. Inconsistent images were thus accepted, and the
# resulting mapping silently used the images of the pcgs instead.
# See https://github.com/gap-system/gap/issues/6514
gap> G := SmallGroup(4, 2);; p := Pcgs(G);;
gap> gens := [ p[1], p[2], p[1]*p[2] ];;
gap> IsSingleValued(GroupGeneralMappingByImagesNC(G, G, gens,
>      [ p[1], p[1], p[1] ]));
false
gap> GroupHomomorphismByImages(G, G, gens, [ p[1], p[1], p[1] ]);
fail
gap> Size(CoKernelOfMultiplicativeGeneralMapping(
>      GroupGeneralMappingByImagesNC(G, G, gens, [ p[1], p[1], p[1] ])));
2

# a consistent assignment on the same generators is still accepted
gap> h := GroupHomomorphismByImages(G, G, gens, [ p[1], p[1], One(G) ]);;
gap> List(gens, x -> Image(h, x)) = [ p[1], p[1], One(G) ];
true
gap> Size(CoKernelOfMultiplicativeGeneralMapping(
>      GroupGeneralMappingByImagesNC(G, G, gens, [ p[1], p[1], One(G) ])));
1

# the same for a non-abelian source and a proper image
gap> D := SmallGroup(8, 3);; q := Pcgs(D);;
gap> C := SmallGroup(4, 2);; c := Pcgs(C);;
gap> GroupHomomorphismByImages(D, C, [ q[1], q[2], q[1]*q[2] ],
>      [ One(C), c[1], One(C) ]);
fail

# `MorClassLoop' filters its candidates with `IsSingleValued', so
# `AllHomomorphismClasses' returned spurious duplicates. Its generating
# system is random, hence the repetition.
gap> H := SmallGroup(144, 88);; Q := SmallGroup(24, 12);;
gap> Set([1..20], i -> Length(AllHomomorphismClasses(H, Q)));
[ 17 ]
gap> Set([1..5], i -> Length(AllHomomorphisms(H, Q)));
[ 172 ]
