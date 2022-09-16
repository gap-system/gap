# Verify AllHomomorphisms works for finite solvable groups
# which are not in the filter CanEasilyComputePcgs: for such groups,
# we used to invoke MinimalGeneratingSet, but it is not actually
# implemented for them...
gap> F:=FreeGroup(3);; G:=F/[F.1^2, F.2^2, Comm(F.1,F.2), F.3];;
gap> IsSolvableGroup(G);
true
gap> Length(AllHomomorphisms(G, SmallGroup(8,1)));
4
