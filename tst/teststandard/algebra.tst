#@local f, gens, a, q, dec
gap> START_TEST( "algebra.tst" );

# 'CentralIdempotentsOfAlgebra' need not require 'IsAlgebraWithOne'.
gap> f:= GF(2);;
gap> gens:= GeneratorsOfGroup( SymmetricGroup( 4 ) );;
gap> a:= AlgebraWithOne( f, List( gens, x -> PermutationMat( x, 4, f ) ) );;
gap> q:= a / RadicalOfAlgebra( a );;
gap> dec:= DirectSumDecomposition( q );;
gap> Length( dec );
2
gap> ForAny( dec, IsAlgebraWithOne );
false
gap> List( dec, One );
[ fail, fail ]
gap> List( dec, CentralIdempotentsOfAlgebra );;

#
gap> STOP_TEST( "algebra.tst" );
