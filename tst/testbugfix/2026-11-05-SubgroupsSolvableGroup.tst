# Regression test for bug reported by H. Dietrich on 10/28/2026
gap> G := SmallGroup(12, 3);;
gap> a:=GroupHomomorphismByImages(G,G,[G.1,G.2,G.3],[G.1^2*G.2,G.3,G.2]);;
gap> Set(List(SubgroupsSolvableGroup(G, rec(actions := [a])), Size));
[ 1, 2, 3, 4, 12 ]
