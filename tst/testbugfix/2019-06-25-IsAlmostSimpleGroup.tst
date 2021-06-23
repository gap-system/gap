# IsSimpleGroup does *not* imply IsAlmostSimpleGroup, as the latter only
# holds for certain extensions of *nonabelian* simple groups.

#
gap> RankFilter(IsSimpleGroup) < RankFilter(IsAlmostSimpleGroup and IsSimpleGroup);
true
gap> RankFilter(IsAlmostSimpleGroup) < RankFilter(IsAlmostSimpleGroup and IsSimpleGroup);
true

#
gap> G:=CyclicGroup(5);
<pc group of size 5 with 1 generator>
gap> IsAlmostSimpleGroup(G);
false
gap> IsSimpleGroup(G);
true
gap> IsAlmostSimpleGroup(G);
false
