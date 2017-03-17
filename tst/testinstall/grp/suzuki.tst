gap> START_TEST("suzuki.tst");

#
gap> G:=SuzukiGroup(2);
Sz(2)
gap> IsMatrixGroup(G);
true
gap> Size(G);
20
gap> SuzukiGroup(8);
Sz(8)
gap> Size(last);
29120

#
gap> H:=SuzukiGroup(IsPermGroup,2);
Sz(2)
gap> IsPermGroup(H);
true

#
gap> SuzukiGroup(3);
Error, <q> must be a non-square power of 2
gap> SuzukiGroup(IsPermGroup,3);
Error, <q> must be a non-square power of 2
gap> SuzukiGroup(4);
Error, <q> must be a non-square power of 2
gap> SuzukiGroup(2,4);
Error, usage: SuzukiGroup( [<filter>, ] <q> )

#
gap> SuzukiGroup(IsFpGroup,2);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `SuzukiGroupCons' on 2 arguments

#
gap> STOP_TEST("suzuki.tst", 1);
