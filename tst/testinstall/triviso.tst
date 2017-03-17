#############################################################################
##
#W  triviso.tst
#Y  Bernhard Reinke
##
#############################################################################
##

gap> START_TEST("triviso.tst");
gap> G := Group(());
Group(())
gap> phi := IsomorphismPermGroup(G);
[  ] -> [  ]
gap> HasIsBijective(phi);
true
gap> inv := InverseGeneralMapping(phi);
[  ] -> [  ]
gap> HasIsMapping(inv);
true
gap> STOP_TEST( "triviso.tst", 1);
