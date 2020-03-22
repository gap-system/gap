#@local f, a, gens
gap> START_TEST( "ideal.tst" );

# Make sure that there is a 'Representative' method for ideals.
gap> f:= GF(2);;
gap> a:= f^[2,2];;
gap> gens:= GeneratorsOfAlgebraWithOne( a );;
gap> Representative( LeftIdeal( a, [ gens[1] ] ) );;
gap> Representative( RightIdeal( a, [ gens[1] ] ) );;
gap> Representative( TwoSidedIdeal( a, [ gens[1] ] ) );;

#
gap> STOP_TEST( "ideal.tst" );
