gap> START_TEST("vecmat.tst");

#
# construct finite field of size 9 that is not GF(9)
gap> F9 := AlgebraicExtension(GF(3), CyclotomicPolynomial(GF(3), 4));;

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

# zero vector over GF(9)
gap> F := GF(9);; v := ListWithIdenticalEntries( 3, Zero(F) );
[ 0*Z(3), 0*Z(3), 0*Z(3) ]
gap> w := ImmutableVector( 9, v );
[ 0*Z(3), 0*Z(3), 0*Z(3) ]
gap> v = w;
true
gap> IsMutable(w);
false
gap> w := ImmutableVector( F, v );
[ 0*Z(3), 0*Z(3), 0*Z(3) ]
gap> v = w;
true
gap> IsMutable(w);
false
gap> w := ImmutableVector( F, v, true );
[ 0*Z(3), 0*Z(3), 0*Z(3) ]
gap> v = w;
true
gap> IsMutable(w);
false

# zero vector over GF(9) but not in internal format
gap> F := F9;; v := ListWithIdenticalEntries( 3, Zero(F) );
[ !0*Z(3), !0*Z(3), !0*Z(3) ]
gap> w := ImmutableVector( 9, v );
[ !0*Z(3), !0*Z(3), !0*Z(3) ]
gap> v = w;
true
gap> IsMutable(w);
false
gap> w := ImmutableVector( F, v );
[ !0*Z(3), !0*Z(3), !0*Z(3) ]
gap> v = w;
true
gap> IsMutable(w);
false
gap> w := ImmutableVector( F, v, true );
[ !0*Z(3), !0*Z(3), !0*Z(3) ]
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

#
# ImmutableMatrix
#

# identity matrix over rationals
gap> F := Rationals;; m := IdentityMat( 3, F );
[ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ]
gap> w := ImmutableMatrix( F, m );
[ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ]
gap> m = w;
true
gap> IsMutable(w);
false
gap> w := ImmutableMatrix( F, m, true );
[ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ]
gap> m = w;
true
gap> IsMutable(w);
false

# identity matrix over GF(2)
gap> F := GF(2);; m := IdentityMat( 3, F );
[ <a GF2 vector of length 3>, <a GF2 vector of length 3>, 
  <a GF2 vector of length 3> ]
gap> w := ImmutableMatrix( 2, m );
<an immutable 3x3 matrix over GF2>
gap> m = w;
true
gap> IsMutable(w);
false
gap> w := ImmutableMatrix( F, m );
<an immutable 3x3 matrix over GF2>
gap> m = w;
true
gap> IsMutable(w);
false
gap> w := ImmutableMatrix( F, m, true );
<an immutable 3x3 matrix over GF2>
gap> m = w;
true
gap> IsMutable(w);
false

# identity matrix over GF(9)
gap> F := GF(9);; m := IdentityMat( 3, F );
[ [ Z(3)^0, 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0, 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), Z(3)^0 ] ]
gap> w := ImmutableMatrix( 9, m );
[ [ Z(3)^0, 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0, 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), Z(3)^0 ] ]
gap> m = w;
true
gap> IsMutable(w);
false
gap> w := ImmutableMatrix( F, m );
[ [ Z(3)^0, 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0, 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), Z(3)^0 ] ]
gap> m = w;
true
gap> IsMutable(w);
false
gap> w := ImmutableMatrix( F, m, true );
[ [ Z(3)^0, 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0, 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), Z(3)^0 ] ]
gap> m = w;
true
gap> IsMutable(w);
false

# identity matrix over GF(9) but not in internal format
gap> F := F9;; m := IdentityMat( 3, F );
[ [ !Z(3)^0, !0*Z(3), !0*Z(3) ], [ !0*Z(3), !Z(3)^0, !0*Z(3) ], 
  [ !0*Z(3), !0*Z(3), !Z(3)^0 ] ]
gap> w := ImmutableMatrix( 9, m );
[ [ !Z(3)^0, !0*Z(3), !0*Z(3) ], [ !0*Z(3), !Z(3)^0, !0*Z(3) ], 
  [ !0*Z(3), !0*Z(3), !Z(3)^0 ] ]
gap> m = w;
true
gap> IsMutable(w);
false
gap> w := ImmutableMatrix( F, m );
[ [ !Z(3)^0, !0*Z(3), !0*Z(3) ], [ !0*Z(3), !Z(3)^0, !0*Z(3) ], 
  [ !0*Z(3), !0*Z(3), !Z(3)^0 ] ]
gap> m = w;
true
gap> IsMutable(w);
false
gap> w := ImmutableMatrix( F, m, true );
[ [ !Z(3)^0, !0*Z(3), !0*Z(3) ], [ !0*Z(3), !Z(3)^0, !0*Z(3) ], 
  [ !0*Z(3), !0*Z(3), !Z(3)^0 ] ]
gap> m = w;
true
gap> IsMutable(w);
false

# identity matrix over a ring with zero divisors
gap> F := Integers mod 6;; m := IdentityMat( 3, F );
[ [ ZmodnZObj( 1, 6 ), ZmodnZObj( 0, 6 ), ZmodnZObj( 0, 6 ) ], 
  [ ZmodnZObj( 0, 6 ), ZmodnZObj( 1, 6 ), ZmodnZObj( 0, 6 ) ], 
  [ ZmodnZObj( 0, 6 ), ZmodnZObj( 0, 6 ), ZmodnZObj( 1, 6 ) ] ]
gap> w := ImmutableMatrix( F, m );
[ [ ZmodnZObj( 1, 6 ), ZmodnZObj( 0, 6 ), ZmodnZObj( 0, 6 ) ], 
  [ ZmodnZObj( 0, 6 ), ZmodnZObj( 1, 6 ), ZmodnZObj( 0, 6 ) ], 
  [ ZmodnZObj( 0, 6 ), ZmodnZObj( 0, 6 ), ZmodnZObj( 1, 6 ) ] ]
gap> m = w;
true
gap> IsMutable(w);
false
gap> w := ImmutableMatrix( F, m, true );
[ [ ZmodnZObj( 1, 6 ), ZmodnZObj( 0, 6 ), ZmodnZObj( 0, 6 ) ], 
  [ ZmodnZObj( 0, 6 ), ZmodnZObj( 1, 6 ), ZmodnZObj( 0, 6 ) ], 
  [ ZmodnZObj( 0, 6 ), ZmodnZObj( 0, 6 ), ZmodnZObj( 1, 6 ) ] ]
gap> m = w;
true
gap> IsMutable(w);
false

# empty matrix
gap> m := ImmutableMatrix( Rationals, [] );
[  ]
gap> IsMutable(m);
false
gap> m := ImmutableMatrix( GF(2), [] );
[  ]
gap> IsMutable(m);
false
gap> m := ImmutableMatrix( GF(7), [] );
[  ]
gap> IsMutable(m);
false
gap> m := ImmutableMatrix( Integers mod 4, [] );
[  ]
gap> IsMutable(m);
false

#
# Test matrix access functions (see also listindex.tst)
#
gap> TestReadMatEntry := function(m)
>     local dim;
>     dim := DimensionsMat(m);
>     dim := [ [1..dim[1]], [1..dim[2]] ];
>     return ForAll(dim[1], row->ForAll(dim[2], col-> m[row,col] = m[row][col]));
> end;;

#
gap> F := GF(2);; m := IdentityMat( 3, F );;
gap> TestReadMatEntry(m);
true
gap> m[1,4];
Error, List Element: <list>[4] must have an assigned value
gap> m[4,1];
Error, List Element: <list>[4] must have an assigned value

#
gap> m := ImmutableMatrix( 2, m );
<an immutable 3x3 matrix over GF2>
gap> TestReadMatEntry(m);
true
gap> m[1,4];
Error, column index 4 exceeds 3, the number of columns
gap> m[4,1];
Error, row index 4 exceeds 3, the number of rows

#
gap> F := GF(9);; m := IdentityMat( 3, F );;
gap> TestReadMatEntry(m);
true
gap> m[1,4];
Error, List Element: <list>[4] must have an assigned value
gap> m[4,1];
Error, List Element: <list>[4] must have an assigned value

#
gap> m := ImmutableMatrix( 9, m );;
gap> TestReadMatEntry(m);
true
gap> m[1,4];
Error, column index 4 exceeds 3, the number of columns
gap> m[4,1];
Error, row index 4 exceeds 3, the number of rows

#
# some tests for GF(2) rep
#
gap> F := GF(2);;
gap> m := ImmutableMatrix( F, IdentityMat( 3, F ) );
<an immutable 3x3 matrix over GF2>
gap> v := ImmutableVector( F, [1,0,1] * One(F) );
<an immutable GF2 vector of length 3>
gap> m * v = v;
true
gap> v * m = v;
true
gap> v * v;
0*Z(2)
gap> m * m = m;
true

# test greased matrix mult
gap> m := ImmutableMatrix( F, IdentityMat( 150, F ) );
<an immutable 150x150 matrix over GF2>
gap> m * m = m;
true
gap> PROD_GF2MAT_GF2MAT_SIMPLE(m,m) = m;
true
gap> PROD_GF2MAT_GF2MAT_ADVANCED(m,m,8,1) = m;
true

#
#
#
gap> F:=GF(3);;
gap> v:=[ Z(3)^0, Z(3), Z(3)^0, 0*Z(3), Z(3)^0, Z(3)^0, Z(3)^0, Z(3)^0 ];;
gap> vecs:=[ 
>   [ Z(3)^0, 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3) ], 
>   [ 0*Z(3), Z(3)^0, 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3) ], 
>   [ 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3), 0*Z(3) ], 
>   [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3) ], 
>   [ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3), Z(3)^0, 0*Z(3) ], 
>   [ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3), Z(3)^0 ] ];;
gap> AClosestVectorCombinationsMatFFEVecFFE(vecs,F,v,1,1);
[ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3), Z(3)^0 ]
gap> AClosestVectorCombinationsMatFFEVecFFECoords(vecs,F,v,1,1);
[ [ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3), Z(3)^0 ], 
  [ 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ] ]
gap> DistancesDistributionMatFFEVecFFE(vecs,F,v);
[ 0, 4, 6, 60, 109, 216, 192, 112, 30 ]
gap> DistancesDistributionVecFFEsVecFFE(vecs,v);
[ 0, 0, 0, 0, 0, 4, 0, 1, 1 ]

#
gap> v1:=[ Z(3)^0, Z(3), Z(3)^0, 0*Z(3), Z(3)^0, Z(3)^0, Z(3)^0, Z(3)^0 ];;
gap> v2:=[ Z(3), Z(3)^0, Z(3)^0, 0*Z(3), Z(3)^0, Z(3)^0, Z(3)^0, Z(3)^0 ];;
gap> DistanceVecFFE(v1,v2);
2

#
gap> STOP_TEST("vecmat.tst");
