# 2005/08/25 (JS)
gap> G := Group((1,2));; PrimePGroup(G);
2
gap> PrimePGroup(Subgroup(G,[])); # returns 2 in 4.4.5
fail
