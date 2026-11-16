gap> START_TEST("2022-09-09-MinimalGeneratingSet.tst");
gap> G:=Group((1,2),(2,3),(3,4));;
gap> H:=Image(IsomorphismFpGroup(G));;
gap> gens := MinimalGeneratingSet(H);;
gap> Length(gens) = 2 and Size(Subgroup(H, gens)) = 24;
true
gap> STOP_TEST("2022-09-09-MinimalGeneratingSet.tst");
