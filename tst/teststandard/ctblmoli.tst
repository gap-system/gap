gap> START_TEST("ctblmoli.tst");

#
# the following test comes from https://github.com/gap-system/gap/issues/300
# this used to give a wrong value for ValueMolienSeries(m,0) of 26/27 instead
# of the correct value 1
#
gap> g:=SymplecticGroup(6,3);;
gap> h:=Stabilizer(g,Z(3)*[1,0,0,0,0,0]);;
gap> t:=CharacterTable(h);;
gap> chi:=Irr(t)[7];;
gap> chi[1];
9
gap> m:=MolienSeries(t,chi);;
gap> List( [ 0 .. 20 ], i -> ValueMolienSeries( m, i ) );
[ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 5, 0, 0 ]
gap> List( [ 0,3 .. 48 ], i -> ValueMolienSeries( m, i ) );
[ 1, 0, 0, 0, 2, 0, 5, 0, 13, 3, 33, 15, 87, 58, 203, 178, 472 ]

#
gap> STOP_TEST( "ctblmoli.tst", 1);
