# Verify SubgroupsSolvableGroup honor retnorm=true if the
# input is a trivial group.
# See https://github.com/gap-system/gap/pull/4855
gap> G:=TrivialGroup(IsPermGroup);
Group(())
gap> SubgroupsSolvableGroup(G);
[ Group(()) ]
gap> SubgroupsSolvableGroup(G, rec(retnorm:=true));
[ [ Group(()) ], [ Group(()) ] ]
