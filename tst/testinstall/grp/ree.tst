gap> START_TEST("ree.tst");

#
gap> G:=ReeGroup(3);
Ree(3)
gap> IsMatrixGroup(G);
true
gap> Size(G);
1512
gap> ReeGroup(27);
Ree(27)
gap> Size(last);
10073444472

#
gap> H:=ReeGroup(IsPermGroup,3);
Perm_Ree(3)
gap> IsPermGroup(H);
true

#
gap> ReeGroup(2);
Error, Usage: ReeGroup(<filter>,3^(1+2m))
gap> ReeGroup(IsPermGroup,2);
Error, Usage: ReeGroup(<filter>,3^(1+2m))
gap> ReeGroup(9);
Error, Usage: ReeGroup(<filter>,3^(1+2m))
gap> ReeGroup(3,9);
Error, usage: ReeGroup( [<filter>, ] <m> )

#
gap> ReeGroup(IsFpGroup,3);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ReeGroupCons' on 2 arguments

#
gap> STOP_TEST("ree.tst", 1);
