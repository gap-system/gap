# 2005/03/31 (TB)
gap> R:= Integers mod 6;;
gap> Size( Ideal( R, [ Zero( R ) ] ) + Ideal( R, [ 2 * One( R ) ] ) );
3
