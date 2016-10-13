gap> START_TEST("LatticeByCyclicExtension.tst");

#
gap> G:=SmallGroup(500,1);
<pc group of size 500 with 5 generators>
gap> fun:=g->IsInt(4/Size(g));;
gap> LatticeByCyclicExtension(G);
<subgroup lattice of <pc group of size 500 with 5 generators>, 12 classes, 
164 subgroups>
gap> LatticeByCyclicExtension(G, fun);
<subgroup lattice of <pc group of size 500 with 5 generators>, 3 classes, 
127 subgroups, restricted under further condition l!.func>
gap> LatticeByCyclicExtension(G, [fun,fun]);
<subgroup lattice of <pc group of size 500 with 5 generators>, 3 classes, 
127 subgroups, restricted under further condition l!.func>

#
gap> STOP_TEST("LatticeByCyclicExtension.tst", 1);
