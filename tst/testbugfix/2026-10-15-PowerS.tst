# PowerSi functions accept s( x, y ) as well as s( [ x, y ] ), see
# <https://github.com/gap-system/gap/issues/6710>
gap> L:= SimpleLieAlgebra( "A", 2, GF(5) );; b:= Basis( L );;
gap> s:= PowerS( L );;
gap> List( s, f -> f( b[1], b[4] ) );
[ 0*v.1, v.4, v.1, 0*v.1 ]
gap> List( s, f -> f( [ b[1], b[4] ] ) );
[ 0*v.1, v.4, v.1, 0*v.1 ]
