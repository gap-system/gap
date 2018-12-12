#@local G,inv,phi
gap> START_TEST("triviso.tst");
gap> G := Group(());
Group(())
gap> phi := IsomorphismPermGroup(G);
IdentityMapping( Group(()) )
gap> HasIsBijective(phi);
true
gap> inv := InverseGeneralMapping(phi);
IdentityMapping( Group(()) )
gap> HasIsMapping(inv);
true
gap> STOP_TEST( "triviso.tst", 1);
