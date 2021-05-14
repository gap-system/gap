gap> START_TEST( "magma.tst" );

#
gap> M:= MagmaByMultiplicationTable( [ [ 1, 1 ], [ 1, 1 ] ] );;
gap> IsGeneratorsOfMagmaWithInverses( Elements( M ) );
false

#
gap> STOP_TEST( "magma.tst" );
