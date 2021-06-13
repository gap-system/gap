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
gap> LoadPackage("atlasrep");;
gap> perms:=AtlasGenerators("2.A5",1).generators;;
gap> mats:=AtlasGenerators("2.A5",4).generators;;
gap> gp:=Group(perms);;
gap> mo:=GModuleByMats(mats,GF(2));;
gap> coh:=TwoCohomologyGeneric(gp,mo);;
gap> Length(coh.cohomology);
1
gap> gp:=FpGroupCocycle(coh,coh.cohomology[1],true);;
gap> gp:=Image(IsomorphismPermGroup(gp));;
gap> Size(Group(GeneratorsOfGroup(gp)));
61440
gap> STOP_TEST( "perfect.tst", 1);
