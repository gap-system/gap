# The orders of the non-PSL(2,q) simple groups come in two lists, the second
# loaded on demand. `SimpleGroupsIterator' asked for it when `start' reached
# 10^18, but the first list ends at 911215823217986880; in between nothing was
# loaded, `pos' stayed `fail', and building the iterator broke on indexing the
# list with it.
gap> it := SimpleGroupsIterator(10^18-1, 10^18-1);;
gap> IsDoneIterator(it);
true
gap> it := SimpleGroupsIterator(10^18-1, 11*10^17 : NOPSL2);;
gap> l := [];; for g in it do Add(l, g); od;
gap> List(l, Size);
[ 1053927211015007280 ]

# An order beyond the data is rejected when the iterator is built, before the
# search for the PSL(2,q) order to start from.
gap> SimpleGroupsIterator(10^28, 10^28);
Error, simple groups of order > 1000000000000000000000000000 are not available
