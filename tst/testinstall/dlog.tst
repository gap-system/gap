#@local R, o
gap> START_TEST( "dlog.tst" );

# DLog
gap> R:= Integers mod 71;;  o:= One( R );;
gap> DLog( 2*o, 4*o );
2
gap> R:= Integers mod 17;;  o:= One( R );;
gap> DLog( 2*o, 3*o );
fail
gap> R:= Integers mod 9;;  o:= One( R );;
gap> DLog( 2*o, 4*o );
2
gap> DLog( 3*o, 4*o );
Error, <obj> is not invertible
gap> ForAll( Primes, p -> p = 2 or DLog( Z(p^2), Z(p^2)^2 ) = 2 );
true
gap> ForAll( Primes, p -> p = 2 or DLog( Z(p^2)^2, Z(p^2) ) = fail );
true

#
gap> STOP_TEST( "dlog.tst" );
