gap> START_TEST("IsomorphismGroups.tst");

# Assertions at level 2 kill runtime of automorphism group computations
gap> SetAssertionLevel(0);;

#
gap> g:=PerfectGroup(IsPermGroup,15360,1);;
gap> h:=g^(1,2);;
gap> Length(CharacteristicSubgroups(g));
5
gap> Length(CharacteristicSubgroups(h));
5
gap> IsomorphismGroups(g,h)<>fail;
true

#
gap> STOP_TEST("IsomorphismGroups.tst",1);
