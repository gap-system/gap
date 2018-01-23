gap> START_TEST("IsPNilpotent.tst");

#
gap> G:=SymmetricGroup(3);;
gap> List([2,3,5], p -> IsPNilpotent(G,p));
[ true, false, true ]

#
gap> G:=SymmetricGroup(3);;
gap> SpecialPcgs(G);;
gap> List([2,3,5], p -> IsPNilpotent(G,p));
[ true, false, true ]

#
gap> STOP_TEST("IsPNilpotent.tst", 10000);
