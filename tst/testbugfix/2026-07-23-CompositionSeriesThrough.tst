# Regression test for https://github.com/gap-system/gap/pull/6464
gap> G := SmallGroup(8, 5);;
gap> gens := GeneratorsOfGroup(G);;
gap> larger := Subgroup(G, [gens[1], gens[2] * gens[3]]);;
gap> smaller := Subgroup(G, [gens[2] * gens[3]]);;
gap> series := CompositionSeriesThrough(G, [larger, smaller]);;
gap> ForAll([1 .. Length(series) - 1],
>           i -> Size(series[i]) > Size(series[i + 1]));
true
gap> ForAll([larger, smaller], x -> x in series);
true
