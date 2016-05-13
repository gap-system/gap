#############################################################################
##
#W  simplegrpit.tst          GAP Library                     Markus Pfeiffer
##
##
#Y  Copyright (C)  2015,  The GAP Group
##
##

## The independence test is not really correct because the simple groups iterator is not required to output the finite simple groups in order.

gap> START_TEST("simplegrpit.tst");
gap> it := SimpleGroupsIterator(1);
<iterator>
gap> IsDoneIterator(it);
false
gap> NextIterator(it); NextIterator(it); NextIterator(it); NextIterator(it);
A5
PSL(2,7)
A6
PSL(2,8)
gap> it2 := ShallowCopy(it);
<iterator>
gap> NextIterator(it2) = NextIterator(it);
true
gap> NextIterator(it);; NextIterator(it);; NextIterator(it);;
gap> NextIterator(it) = NextIterator(it2);
false
gap> it := SimpleGroupsIterator(100000);
<iterator>
gap> NextIterator(it);
PSL(2,59)
gap> it := SimpleGroupsIterator(20000,80000:NOPSL2);;
gap> for g in it do Print(g,"\n"); od;
A8
PSL(3,4)
PSp(4,3)
Sz(8)
PSU(3,4)
gap> IsDoneIterator(it);
true
gap> STOP_TEST("simplegrpit.tst", 960000);

