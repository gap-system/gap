# This enumerates the orbit of the sporadic simple Janko group 4 (J4)
# on the cosets of its first maximal subgroup. The orbit contains
# 173067389 points and uses about 13 GB of main memory.
# A non-parallel orbit algorithm takes about 1000 seconds.

LoadPackage("orb");

Read("J4data.g");   # actually reads J4data.g.gz

if IsBound(MakeReadOnlyObj) then
    OnRightRO := function(x,g)
      local y;
      y := x*g;
      MakeReadOnlyObj(y);
      return y;
    end;
else
    OnRightRO := OnRight;
fi;

# Now enumerate the orbit of v under the action of the group generated
# by gens with "OnRight" as action function.
# The following works on my machine and uses about 1000 seconds and
# 13 GB main memory:

start := Runtime();
o := Orb(gens,v,OnRightRO,rec(treehashsize := 300000000, report := 1000000));
Enumerate(o);
t := Runtime()-start;
Print("Runtime [ms]:",t,"\n");
