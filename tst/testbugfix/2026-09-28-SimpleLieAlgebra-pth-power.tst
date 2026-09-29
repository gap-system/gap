# p-th power map of a restricted simple Lie algebra that is a proper
# subalgebra of its full s.c. algebra
gap> L:= SimpleLieAlgebra( "S", [ 1, 1, 1 ], GF(3) );;
gap> B:= Basis( L );;
gap> ForAll( B, x -> PthPowerImage( x ) = PthPowerImage( B, x ) );
true
gap> ForAll( B, x -> PthPowerImage( x, 2 ) = PthPowerImage( B, PthPowerImage( B, x ) ) );
true
