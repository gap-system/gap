gap> START_TEST("MultVector.tst");

# Dense plain lists
gap> li := [ 1, -2, 0, 3 ];;
gap> MultVectorRight(li, -2);
gap> li;
[ -2, 4, 0, -6 ]
gap> MultVectorLeft(li, -1);
gap> li;
[ 2, -4, 0, 6 ]

# Plain row vectors of ffes
gap> lf := [ Z(5)^0, Z(5)^1, 0*Z(5), Z(5)^3 ];;
gap> IsRowVector(lf);
true
gap> MultVectorLeft(lf, Z(5)^2);
gap> lf;
[ Z(5)^2, Z(5)^3, 0*Z(5), Z(5) ]
gap> MultVectorRight(lf, Z(5)^3);
gap> lf;
[ Z(5), Z(5)^2, 0*Z(5), Z(5)^0 ]

# Compressed vectors: IsGF2VectorRep
gap> vg2 := NewVector( IsGF2VectorRep, GF(2),
>     [ Z(2)^0, 0*Z(2), Z(2)^0, Z(2)^0 ] );;
gap> IsGF2VectorRep(vg2);
true
gap> MultVectorLeft(vg2, Z(2)^0);
gap> Unpack(vg2);
[ Z(2)^0, 0*Z(2), Z(2)^0, Z(2)^0 ]
gap> MultVectorRight(vg2, Z(2)^0);
gap> Unpack(vg2);
[ Z(2)^0, 0*Z(2), Z(2)^0, Z(2)^0 ]

# Compressed vectors: Is8BitVectorRep
gap> vg5 := NewVector( Is8BitVectorRep, GF(5),
>     [ Z(5)^0, Z(5)^1, 0*Z(5), Z(5)^3 ] );;
gap> Is8BitVectorRep(vg5);
true
gap> MultVectorLeft(vg5, Z(5)^2);
gap> Unpack(vg5);
[ Z(5)^2, Z(5)^3, 0*Z(5), Z(5) ]
gap> MultVectorRight(vg5, Z(5)^3);
gap> Unpack(vg5);
[ Z(5), Z(5)^2, 0*Z(5), Z(5)^0 ]

# IsPlistVectorRep vectors
gap> vp := NewVector( IsPlistVectorRep, GF(5),
>     [ Z(5)^1, Z(5)^2, Z(5)^0, Z(5)^4, 0*Z(5), Z(5)^3 ] );
<plist vector over GF(5) of length 6>
gap> IsPlistVectorRep(vp);
true
gap> MultVectorLeft(vp, Z(5)^3);
gap> Unpack(vp);
[ Z(5)^0, Z(5), Z(5)^3, Z(5)^3, 0*Z(5), Z(5)^2 ]
gap> vp := NewVector( IsPlistVectorRep, GF(5),
>     [ Z(5)^1, Z(5)^2, Z(5)^0, Z(5)^4, 0*Z(5), Z(5)^3 ] );;
gap> MultVectorRight(vp, Z(5)^3);
gap> Unpack(vp);
[ Z(5)^0, Z(5), Z(5)^3, Z(5)^3, 0*Z(5), Z(5)^2 ]
gap> vp := NewVector( IsPlistVectorRep, GF(5),
>     [ Z(5)^1, Z(5)^2, Z(5)^0, Z(5)^4, 0*Z(5), Z(5)^3 ] );;
gap> MultVectorLeft(vp, Z(5)^3, 3, 4);
gap> Unpack(vp);
[ Z(5), Z(5)^2, Z(5)^3, Z(5)^3, 0*Z(5), Z(5)^3 ]
gap> vp := NewVector( IsPlistVectorRep, GF(5),
>     [ Z(5)^1, Z(5)^2, Z(5)^0, Z(5)^4, 0*Z(5), Z(5)^3 ] );;
gap> MultVectorRight(vp, Z(5)^3, 3, 4);
gap> Unpack(vp);
[ Z(5), Z(5)^2, Z(5)^3, Z(5)^3, 0*Z(5), Z(5)^3 ]
gap> n := NewVector( IsPlistVectorRep, Integers, [ 1, 2, 0 ] );
<plist vector over Integers of length 3>
gap> IsIntVector(n);
true
gap> MultVectorRight(n, 2);
gap> Unpack(n);
[ 2, 4, 0 ]
gap> MultVectorLeft(n, -1);
gap> Unpack(n);
[ -2, -4, 0 ]

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

#
gap> STOP_TEST("MultVector.tst");
