M1 := [[-1,0],[0,1]];
M2 := [[1,1],[0,1]];
g := Group(M1,M2);
gg := Group(M1);
t := TrivialSubgroup(g);
s := GraphicSubgroupLattice(g);

