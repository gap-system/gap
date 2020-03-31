gap> START_TEST("IsomorphismGroups.tst");

# Assertions at level 2 kill runtime of automorphism group computations
gap> SetAssertionLevel(0);;

#
gap> g:=PerfectGroup(IsPermGroup,7680,1);;
gap> h:=g^(1,2);;
gap> CharacteristicSubgroups(g);;
gap> CharacteristicSubgroups(h);;
gap> IsomorphismGroups(g,h)<>fail;
true

#
gap> STOP_TEST("IsomorphismGroups.tst",1);
