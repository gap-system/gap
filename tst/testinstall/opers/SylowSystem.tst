gap> START_TEST("SylowSystem.tst");
gap> G := Group([], IdentityMat (4, GF(2)));;
gap> IsEmpty(SylowSystem(G));
true
gap> STOP_TEST("SylowSystem.tst", 10000);
