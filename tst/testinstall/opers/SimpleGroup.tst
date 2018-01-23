gap> START_TEST("SimpleGroup.tst");

#
gap> SimpleGroup("Sz(8)");
Sz(8)
gap> SimpleGroup("Suzuki(32)");
Sz(32)
gap> SimpleGroup("Suz(8)");
Sz(8)
gap> SimpleGroup("Sz(9)");
Error, Illegal Parameter for Suzuki groups
gap> SimpleGroup("Suz(16)");
Error, Illegal Parameter for Suzuki groups

#
gap> SimpleGroup("R(27)");
Ree(27)
gap> SimpleGroup("Ree(27)");
Ree(27)
gap> SimpleGroup("2G(243)");
Ree(243)
gap> SimpleGroup("Ree(9)");
Error, Illegal Parameter for Ree groups
gap> SimpleGroup("Ree(16)");
Error, Illegal Parameter for Ree groups

#
gap> STOP_TEST("SimpleGroup.tst", 10000);
