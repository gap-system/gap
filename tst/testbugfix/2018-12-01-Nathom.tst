# Reported in github PR 3070
# Degenerate example where the subgroup can be formed without finiteness test (as the group
# is cyclic).
gap> G := Group([[[E(3),0,0],[0,E(3),0],[0,0,E(3)]],[[1,0,0],[0,0,1],[0,1,0]]]);;
gap> FactorGroup(G,Center(G));;
