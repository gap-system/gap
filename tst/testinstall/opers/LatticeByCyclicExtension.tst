gap> START_TEST("LatticeByCyclicExtension.tst");

# construct SmallGroup(500,1)
gap> H:=CyclicGroup(4);;
gap> N:=CyclicGroup(125);;
gap> A:=AutomorphismGroup(N);;
gap> alpha:=GroupHomomorphismByImages(H,A,[H.1],[A.1^50]);;
gap> G:=SemidirectProduct(H, alpha, N);;

#
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
gap> STOP_TEST("LatticeByCyclicExtension.tst");
