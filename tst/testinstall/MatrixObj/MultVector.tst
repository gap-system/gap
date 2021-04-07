gap> START_TEST("MultVector.tst");

# Finite Fields
gap> v := NewVector( IsPlistVectorRep, GF(5), [Z(5)^1, Z(5)^2, Z(5)^0, Z(5)^4, 0*Z(5), Z(5)^3 ]  );
<plist vector over GF(5) of length 6>
gap> MultVector(v, Z(5)^3);
gap> Unpack(v);
[ Z(5)^0, Z(5), Z(5)^3, Z(5)^3, 0*Z(5), Z(5)^2 ]
gap> MultVector(v, -1);
gap> Unpack(v);
[ Z(5)^2, Z(5)^3, Z(5), Z(5), 0*Z(5), Z(5)^0 ]
gap> MultVector(v, Z(5)^3, 3, 4);
gap> Unpack(v);
[ Z(5)^2, Z(5)^3, Z(5)^0, Z(5)^0, 0*Z(5), Z(5)^0 ]

# Integers
gap> n := NewVector( IsPlistVectorRep, Integers, [1,2,0] );
<plist vector over Integers of length 3>
gap> IsIntVector(n);
true
gap> MultVector(n, 2);
gap> Unpack(n);
[ 2, 4, 0 ]

# Quaternions: multiplication from left and right
gap> Q := QuaternionAlgebra( Rationals );
<algebra-with-one of dimension 4 over Rationals>
gap> q := NewVector( IsPlistVectorRep, Q, [One(Q), Zero(Q), Q.2, Q.3] );
<plist vector over AlgebraWithOne( Rationals, [ e, i, j, k ] ) of length 4>
gap> MultVectorRight(q, Q.2);
gap> Unpack(q);
[ i, 0*e, (-1)*e, (-1)*k ]
gap> MultVectorLeft(q, Q.2);
gap> Unpack(q);
[ (-1)*e, 0*e, (-1)*i, j ]
gap> MultVectorRight(q, 1);
gap> Unpack(q);
[ (-1)*e, 0*e, (-1)*i, j ]
gap> MultVectorRight(q, Q.2, 3, 4);
gap> Unpack(q);
[ (-1)*e, 0*e, e, (-1)*k ]
gap> MultVectorLeft(q, Q.2, 3, 4);
gap> Unpack(q);
[ (-1)*e, 0*e, i, j ]
gap> STOP_TEST("MultVector.tst");
