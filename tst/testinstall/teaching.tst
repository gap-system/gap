#@local H, G

gap> START_TEST( "teaching.tst" );

#
gap> H:= CyclicGroup( infinity );;  G:= CyclicGroup( 2 );;
gap> AllHomomorphisms( H, G );  # test for 'H' that does not know to be infinite
Error, the first argument must be a finite group

#
gap> H:= CyclicGroup( infinity );;  G:= CyclicGroup( 2 );;
gap> IsFinite( H );
false
gap> AllHomomorphisms( H, G );  # test for 'H' that knows to be infinite
Error, the first argument must be a finite group

#
gap> STOP_TEST( "teaching.tst" );
