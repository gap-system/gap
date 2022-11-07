gap> START_TEST("2022-09-09-MinimalGeneratingSet.tst");
gap> G:=Group((1,2),(2,3),(3,4));;
gap> H:=Image(IsomorphismFpGroup(G));;
gap> MinimalGeneratingSet(H);
[ F1^-1*F2^-1*F3^-1, F1^-1*F2^-1*F3^-1*F2^-1*F1^-1 ]
gap> STOP_TEST("2022-09-09-MinimalGeneratingSet.tst", 1);
