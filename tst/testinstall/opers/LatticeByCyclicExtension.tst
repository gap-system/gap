gap> START_TEST("LatticeByCyclicExtension.tst");

#
gap> G:=SmallGroup(625,1);
<pc group of size 625 with 4 generators>
gap> A:=AutomorphismGroup(G);
<group of size 500 with 7 generators>
gap> fun:=g->IsInt(4/Size(g));;
gap> LatticeByCyclicExtension(A);
<subgroup lattice of <group of size 500 with 7 generators>, 12 classes, 
12 subgroups>
gap> LatticeByCyclicExtension(A, fun);
<subgroup lattice of <group of size 500 with 7 generators>, 3 classes, 
3 subgroups, restricted under further condition l!.func>
gap> LatticeByCyclicExtension(A, [fun,fun]);
<subgroup lattice of <group of size 500 with 7 generators>, 3 classes, 
3 subgroups, restricted under further condition l!.func>

#
gap> STOP_TEST("LatticeByCyclicExtension.tst", 1);
