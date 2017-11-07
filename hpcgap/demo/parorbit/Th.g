# This enumerates the orbit of the sporadic simple Thompson group (Th)
# on the cosets of its first maximal subgroup. The orbit contains
# 143127000 points and uses about 35GB of main memory.
# A non-parallel orbit algorithm takes about 1.5 hours.

LoadPackage("orb");

Read("Thdata.g");   # actually reads Thdata.g.gz

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

# Now enumerate the orbit of v under the action of the group generated
# by gens with "OnSubspacesByCanonicalBasis" as action function.
# The following should work on a big machine with 64GB of main memory
# and use about 1.5 hours and 35GB main memory:

start := Runtime();
o := Orb(gens,v,OnSubspacesByCanonicalBasisRO,
         rec(treehashsize := 200000000,report := 100000));
Enumerate(o);
t := Runtime()-start;
Print("Runtime [ms]:",t,"\n");
