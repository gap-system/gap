# Index of cyclic subgroup not bounded by powers of generators
gap> g:=DirectProduct(WeylGroupFp("A",7),CyclicGroup(IsFpGroup,11));;
gap> Size(g);
443520
gap> FinIndexCyclicSubgroupGenerator(g,100000)<>fail;
true
