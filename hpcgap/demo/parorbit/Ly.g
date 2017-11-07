# This enumerates the orbit of the sporadic simple Lyons group (Ly)
# on the cosets of its first maximal subgroup. The orbit contains
# 8835156 points and uses about 4 GB of main memory.
# A non-parallel orbit algorithm takes about 1730 seconds.

LoadPackage("orb");

Read("Lydata.g");   # actually reads Lydata.g.gz

# Now enumerate the orbit of v under the action of the group generated
# by gens with "OnSubspacesByCanonicalBasis" as action function.
# The following works on my machine and uses about 1730 seconds and
# 4 GB main memory:

if IsBound(MakeReadOnlySingleObj) then
    OnSubspacesByCanonicalBasisRO := function(x,g)
      local y;
      y := OnSubspacesByCanonicalBasis(x,g);
      MakeReadOnlySingleObj(y);
      return y;
    end;
else
    OnSubspacesByCanonicalBasisRO := OnSubspacesByCanonicalBasis;
fi;

start := Runtime();
o := Orb(gens,v,OnSubspacesByCanonicalBasisRO,rec(treehashsize := 20000000, 
                                                  report := 100000));
Enumerate(o);
t := Runtime()-start;
Print("Runtime [ms]:",t,"\n");
