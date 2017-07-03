gap> START_TEST("vecmat.tst");

#
# ImmutableVector
#

# zero vector over rationals
gap> F := Rationals;; v := ListWithIdenticalEntries( 3, Zero(F) );
[ 0, 0, 0 ]
gap> w := ImmutableVector( F, v );
[ 0, 0, 0 ]
gap> v = w;
true
gap> IsMutable(w);
false
gap> w := ImmutableVector( F, v, true ); 
[ 0, 0, 0 ]
gap> v = w;
true
gap> IsMutable(w);
false

# zero vector over GF(2)
gap> F := GF(2);; v := ListWithIdenticalEntries( 3, Zero(F) );
[ 0*Z(2), 0*Z(2), 0*Z(2) ]
gap> w := ImmutableVector( 2, v ); 
<an immutable GF2 vector of length 3>
gap> v = w;
true
gap> IsMutable(w);
false
gap> w := ImmutableVector( F, v ); 
<an immutable GF2 vector of length 3>
gap> v = w;
true
gap> IsMutable(w);
false
gap> w := ImmutableVector( F, v, true ); 
<an immutable GF2 vector of length 3>
gap> v = w;
true
gap> IsMutable(w);
false

# zero vector over GF(7)
gap> F := GF(7);; v := ListWithIdenticalEntries( 3, Zero(F) );
[ 0*Z(7), 0*Z(7), 0*Z(7) ]
gap> w := ImmutableVector( 7, v ); 
[ 0*Z(7), 0*Z(7), 0*Z(7) ]
gap> v = w;
true
gap> IsMutable(w);
false
gap> w := ImmutableVector( F, v ); 
[ 0*Z(7), 0*Z(7), 0*Z(7) ]
gap> v = w;
true
gap> IsMutable(w);
false
gap> w := ImmutableVector( F, v, true ); 
[ 0*Z(7), 0*Z(7), 0*Z(7) ]
gap> v = w;
true
gap> IsMutable(w);
false

# zero vector over a ring with zero divisors
gap> F := Integers mod 6;; v := ListWithIdenticalEntries( 3, Zero(F) );
[ ZmodnZObj( 0, 6 ), ZmodnZObj( 0, 6 ), ZmodnZObj( 0, 6 ) ]
gap> w := ImmutableVector( F, v ); 
[ ZmodnZObj( 0, 6 ), ZmodnZObj( 0, 6 ), ZmodnZObj( 0, 6 ) ]
gap> v = w;
true
gap> IsMutable(w);
false
gap> w := ImmutableVector( F, v, true ); 
[ ZmodnZObj( 0, 6 ), ZmodnZObj( 0, 6 ), ZmodnZObj( 0, 6 ) ]
gap> v = w;
true
gap> IsMutable(w);
false

# empty vectors
gap> v := ImmutableVector( Rationals, [] );
[  ]
gap> IsMutable(v);
false
gap> v := ImmutableVector( GF(2), [] );
[  ]
gap> IsMutable(v);
false
gap> v := ImmutableVector( GF(7), [] );
[  ]
gap> IsMutable(v);
false
gap> v := ImmutableVector( Integers mod 4, [] );
[  ]
gap> IsMutable(v);
false
gap> STOP_TEST("vecmat.tst");
