# Weyl group E8 presentation typo
gap> G:=WeylGroupFp("E",8);;
gap> Index(G,Subgroup(G,GeneratorsOfGroup(G){[1,2,3,5,6,7,8]}));
17280
