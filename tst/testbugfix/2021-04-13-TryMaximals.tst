#4395, reported by Andries Brouwer
gap> g:=SimpleGroup("3D4(2)");;
gap> hs:=List(IsomorphicSubgroups(g,SymmetricGroup(4)),Image);;
gap> Length(TryMaximalSubgroupClassReps(g));
9
