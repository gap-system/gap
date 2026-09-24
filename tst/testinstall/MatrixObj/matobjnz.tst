#@local R, v, l, c
gap> START_TEST( "matobjnz.tst" );

# compare zmodnz vectors with lists, non-prime modulus
gap> R:= Integers mod 6;;
gap> v:= Vector( IsZmodnZVectorRep, R, [ 1, 2, 3 ] );;
gap> l:= One( R ) * [ 1, 2, 3 ];;
gap> v = l;
true
gap> l = v;
true
gap> v = One( R ) * [ 1, 2, 4 ];
false
gap> One( R ) * [ 1, 2 ] = v;
false

# prime modulus: list entries are FFEs
gap> v:= Vector( IsZmodnZVectorRep, GF(7), [ 1, 2, 3 ] );;
gap> l:= Z(7)^0 * [ 1, 2, 3 ];;
gap> v = l;
true
gap> l = v;
true

# a compressed vector is a vector object with another 'ConstructingFilter'
gap> c:= ShallowCopy( l );;
gap> ConvertToVectorRep( c, 7 );;
gap> v = c;
false
gap> c = v;
false

#
gap> STOP_TEST( "matobjnz.tst" );
