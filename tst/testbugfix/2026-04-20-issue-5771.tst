## Regression test for #5771. The MinimalGeneratingSet method for pc-groups
## greedily appended a fifth generator, even though later adjustments make
## that generator redundant. The minimal generating set for this group has
## size 4, but GAP gave one of size 5, with one redundant generator.

gap> START_TEST("2026-04-20-issue-5771.tst");
gap> G := function()
> local f, g, g1, g2, g3, g4, g5, g6, g7, g8, g9, rws, rels, x;
>   f := FreeGroup(IsSyllableWordsFamily, 9);
>   g := GeneratorsOfGroup(f);
>   g1 := g[1]; g2 := g[2]; g3 := g[3]; g4 := g[4]; g5 := g[5];
>   g6 := g[6]; g7 := g[7]; g8 := g[8]; g9 := g[9];
>   rws := SingleCollector(f, [ 2, 2, 2, 2, 3, 3, 3, 3, 3 ]);
>   rels := [
>     [5,1,g5], [9,1,g9], [5,2,g5], [6,2,g6], [7,2,g7],
>     [8,2,g8], [9,2,g9], [6,3,g6], [7,3,g7], [8,3,g8],
>     [5,4,g5], [6,4,g6], [7,4,g7], [8,4,g8], [9,4,g9]
>   ];
>   for x in rels do
>     SetCommutator(rws, x[1], x[2], x[3]);
>   od;
>   return GroupByRwsNC(rws);
> end();;
gap> m := MinimalGeneratingSet(G);;
gap> Length(m) = 4 and
> ForAll([1..Length(m)],
>   i -> Index(G, SubgroupNC(G, m{Filtered([1..Length(m)], j -> j <> i)})) > 1);
true
gap> STOP_TEST("2026-04-20-issue-5771.tst");
