#############################################################################
##
##  Test for cohomology and isomorphism: Recompute perfect groups
##
gap> START_TEST("perfect.tst");
gap> READ_GAP_ROOT("tst/testextra/makeperfect.g");;
gap> l:=Practice(1920);;
gap> Length(l);
7
gap> l:=Practice(10752);;
gap> Length(l);
9
gap> STOP_TEST( "perfect.tst", 1);
