## bug 10 for fix 5
gap> R:= Integers mod 6;;
gap> Size( Ideal( R, [ Zero( R ) ] ) + Ideal( R, [ 2 * One( R ) ] ) );
3
