#@local F, F3, M, N, P, Q, R, v, w, u, l, d, h, x, L
gap> START_TEST( "matobjpacked.tst" );
gap> ReadGapRoot( "tst/testinstall/MatrixObj/testpacked.g" );

#
# Differential tests: entries, =, <, Set, hash, copies and round trips
# through every constructor input, against Unpack, plain lists and
# IsGenericMatrixRep (see testpacked.g)
#
gap> PackedTestRing( GF(2), 1 );
true
gap> PackedTestRing( GF(2), 2 );
true
gap> PackedTestRing( GF(3), 1 );
true
gap> PackedTestRing( GF(7), 1 );
true
gap> PackedTestRing( GF(7), 2 );
true
gap> PackedTestRing( GF(257), 1 );
true
gap> PackedTestRing( GF(65521), 1 );
true
gap> PackedTestRing( GF(NextPrimeInt(2^61)), 1 );
true
gap> PackedTestRing( GF(NextPrimeInt(2^63)), 1 );
true
gap> PackedTestRing( Integers mod 6, 1 );
true
gap> PackedTestRing( Integers mod (2^64 - 1), 1 );
true

#
# Filters, attributes, printing
#
gap> M := NewMatrix( IsPackedMatrixRep, GF(2), 3, [ [ 1, 0, 1 ], [ 0, 1, 1 ] ] * Z(2) );
<2x3 packed matrix over GF(2)>
gap> IsMatrixObj( M ) and IsDataObjectRep( M ) and IsCopyable( M );
true
gap> IsList( M ) or IsRowListMatrix( M ) or IsPositionalObjectRep( M );
false
gap> [ ConstructingFilter( M ), CompatibleVectorFilter( M ) ];
[ <Representation "IsPackedMatrixRep">, <Representation "IsPackedVectorRep"> ]
gap> [ BaseDomain( M ), NumberRows( M ), NumberColumns( M ) ];
[ GF(2), 2, 3 ]
gap> [ OneOfBaseDomain( M ), ZeroOfBaseDomain( M ) ];
[ Z(2)^0, 0*Z(2) ]
gap> Print( M, "\n" );
NewMatrix(IsPackedMatrixRep,GF(2),3,
[ [ Z(2)^0, 0*Z(2), Z(2)^0 ], [ 0*Z(2), Z(2)^0, Z(2)^0 ] ])
gap> String( M );
"NewMatrix(IsPackedMatrixRep,GF(2),3,[ [ Z(2)^0, 0*Z(2), Z(2)^0 ], [ 0*Z(2), Z\
(2)^0, Z(2)^0 ] ])"
gap> EvalString( String( M ) ) = M;
true
gap> Display( M );
<2x3 packed matrix over GF(2):
[[ Z(2)^0, 0*Z(2), Z(2)^0 ]
 [ 0*Z(2), Z(2)^0, Z(2)^0 ]
]>
gap> Display( Immutable( M ) );
<immutable 2x3 packed matrix over GF(2):
[[ Z(2)^0, 0*Z(2), Z(2)^0 ]
 [ 0*Z(2), Z(2)^0, Z(2)^0 ]
]>
gap> M[1];
Error, row access unsupported; use M[i,j] or RowsOfMatrix(M)
gap> v := NewVector( IsPackedVectorRep, GF(7), [ 1, 2, 3 ] * Z(7)^0 );
<packed vector over GF(7) of length 3>
gap> IsVectorObj( v ) and IsDataObjectRep( v ) and not IsList( v );
true
gap> [ ConstructingFilter( v ), BaseDomain( v ), Length( v ) ];
[ <Representation "IsPackedVectorRep">, GF(7), 3 ]
gap> [ OneOfBaseDomain( v ), ZeroOfBaseDomain( v ) ];
[ Z(7)^0, 0*Z(7) ]
gap> Print( v, "\n" );
NewVector(IsPackedVectorRep,GF(7),[ Z(7)^0, Z(7)^2, Z(7) ])
gap> EvalString( String( v ) ) = v;
true
gap> Display( v );
<a packed vector over GF(7):
[ Z(7)^0, Z(7)^2, Z(7) ]
>
gap> Immutable( v );
<immutable packed vector over GF(7) of length 3>
gap> R := Integers mod 6;;
gap> N := NewMatrix( IsPackedMatrixRep, R, 2, [ [ 1, 5 ] ] * One( R ) );
<1x2 packed matrix over (Integers mod 6)>
gap> Print( N, "\n" );
NewMatrix(IsPackedMatrixRep,(Integers mod 6),2,
[ [ ZmodnZObj( 1, 6 ), ZmodnZObj( 5, 6 ) ] ])
gap> EvalString( String( N ) ) = N;
true
gap> F := GF( NextPrimeInt( 2^63 ) );;
gap> P := NewMatrix( IsPackedMatrixRep, F, 1, [ [ -1 ] ] * One( F ) );;
gap> P[1,1];
ZmodpZObj( 9223372036854775836, 9223372036854775837 )
gap> EvalString( String( P ) ) = P;
true

#
# Dimensions: empty objects need no special case; the largest dimension
# is 2^32 - 1
#
gap> List( [ [ 0, 0 ], [ 0, 3 ], [ 3, 0 ] ],
>          d -> NewZeroMatrix( IsPackedMatrixRep, GF(3), d[1], d[2] ) );
[ <0x0 packed matrix over GF(3)>, <0x3 packed matrix over GF(3)>, 
  <3x0 packed matrix over GF(3)> ]
gap> List( last, Unpack );
[ [  ], [  ], [ [  ], [  ], [  ] ] ]
gap> NewMatrix( IsPackedMatrixRep, GF(3), 3, [] ) = NewMatrix( IsPackedMatrixRep, GF(3), 2, [] );
false
gap> IsOne( NewIdentityMatrix( IsPackedMatrixRep, GF(3), 0 ) );
true
gap> NewZeroVector( IsPackedVectorRep, GF(3), 0 );
<packed vector over GF(3) of length 0>
gap> NewZeroVector( IsPackedVectorRep, GF(3), 0 ) = NewZeroVector( IsPackedVectorRep, GF(5), 0 );
false
gap> NewZeroMatrix( IsPackedMatrixRep, GF(2), 2^32 - 1, 0 );
<4294967295x0 packed matrix over GF(2)>
gap> NewZeroVector( IsPackedVectorRep, GF(2), -1 );
Error, PACKMAT_ZERO_VECTOR: <len> must be an integer in [0..2^32-1] (not the i\
nteger -1)
#@if GAPInfo.BytesPerVariable = 8
gap> NewZeroMatrix( IsPackedMatrixRep, GF(2), 2^32, 0 );
Error, PACKMAT_ZERO_MATRIX: <nrows> must be an integer in [0..2^32-1] (not the\
 integer 4294967296)
gap> MemoryUsage( NewZeroMatrix( IsPackedMatrixRep, GF(2), 8, 8 ) );
48
#@fi

#
# Constructors with filters and example objects
#
gap> M := ZeroMatrix( IsPackedMatrixRep, GF(5), 2, 3 );
<2x3 packed matrix over GF(5)>
gap> IsZero( M ) and IsMutable( M );
true
gap> ZeroMatrix( 3, 1, M );
<3x1 packed matrix over GF(5)>
gap> IdentityMatrix( 2, M );
<2x2 packed matrix over GF(5)>
gap> IsOne( last ) and not IsOne( ZeroMatrix( 2, 2, M ) );
true
gap> ZeroVector( 4, M );
<packed vector over GF(5) of length 4>
gap> Unpack( Vector( [ 1, 2 ] * Z(5), ZeroVector( 4, M ) ) );
[ Z(5), Z(5)^2 ]
gap> Unpack( Matrix( [ [ 1, 2 ] ] * Z(5), M ) );
[ [ Z(5), Z(5)^2 ] ]
gap> Unpack( NewMatrix( IsPackedMatrixRep, GF(5), 2, [ 1, 2, 3, 4 ] * Z(5) ) );
[ [ Z(5), Z(5)^2 ], [ Z(5)^0, Z(5)^3 ] ]
gap> NewMatrix( IsPackedMatrixRep, GF(5), 3, [ 1, 2, 3, 4 ] * Z(5) );
Error, NewMatrix: Length of <list> is not a multiple of <ncols>
gap> NewMatrix( IsPackedMatrixRep, GF(5), 3, [ [ 1, 2 ] * Z(5) ] );
Error, the entries of <list> must have length <ncols>

#
# Entries. As for IsGenericMatrixRep, integers are rejected, and FFEs of
# larger fields that lie in the base domain are accepted.
#
gap> NewMatrix( IsGenericMatrixRep, GF(3), 2, [ [ 1, 2 ] ] );
Error, the elements in <list> must lie in <basedomain>
gap> NewMatrix( IsPackedMatrixRep, GF(3), 2, [ [ 1, 2 ] ] );
Error, <x> must lie in the base domain
gap> Unpack( NewMatrix( IsPackedMatrixRep, GF(3), 2, [ [ Z(9)^4, Z(9)^0 ] ] ) );
[ [ Z(3), Z(3)^0 ] ]
gap> M := NewMatrix( IsPackedMatrixRep, GF(3), 2, [ [ Z(3), Z(3) ] ] );;
gap> M[1,1] := 1;
Error, <x> must lie in the base domain
gap> M[1,1] := Z(9);
Error, <x> must lie in the base domain
gap> M[1,1] := Z(5);
Error, <x> must lie in the base domain
gap> M[1,1] := Z(9)^4;; M[1,1];
Z(3)
gap> M[1,2] := ZmodnZObj( FamilyObj( Z(3) ), 0 );; Unpack( M );
[ [ Z(3), 0*Z(3) ] ]
gap> N := NewMatrix( IsPackedMatrixRep, R, 1, [ [ ZmodnZObj( 2, 6 ) ] ] );;
gap> N[1,1] := ZmodnZObj( 2, 4 );
Error, <x> must lie in the base domain
gap> N[1,1] := 2;
Error, <x> must lie in the base domain

#
# Indices are checked
#
gap> M[2,1];
Error, Matrix Element: <row> must be in [1..NrRows(<M>)] (not the integer 2)
gap> M[1,3];
Error, Matrix Element: <col> must be in [1..NrCols(<M>)] (not the integer 3)
gap> M[2^70,1];
Error, Matrix Element: <row> must be in [1..NrRows(<M>)] (not a large positive\
 integer)
gap> M[2,1] := Z(3);
Error, Matrix Assignment: <row> must be in [1..NrRows(<M>)] (not the integer 2\
)
gap> M[1,3] := Z(3);
Error, Matrix Assignment: <col> must be in [1..NrCols(<M>)] (not the integer 3\
)
gap> v[4];
Error, Vector Element: <pos> must be in [1..Length(<v>)] (not the integer 4)
gap> v[4] := Z(7);
Error, Vector Assignment: <pos> must be in [1..Length(<v>)] (not the integer 4\
)

#
# Mutability: MakeImmutable switches the type
#
gap> M := NewMatrix( IsPackedMatrixRep, GF(3), 2, [ [ Z(3), Z(3) ] ] );;
gap> N := ShallowCopy( M );;
gap> MakeImmutable( N );
<immutable 1x2 packed matrix over GF(3)>
gap> IsIdenticalObj( TypeObj( N ), PackedRepContext( GF(3) ).immutableMatrix );
true
gap> N = M and N[1,2] = Z(3);
true
gap> N[1,1] := Z(3);
Error, Matrix Assignment: <mat> must be a mutable matrix (not a data object)
gap> SetMatElm( N, 1, 1, Z(3) );
Error, Matrix Assignment: <mat> must be a mutable matrix (not a data object)
gap> IsMutable( ShallowCopy( N ) ) and IsMutable( MutableCopyMatrix( N ) );
true
gap> w := Immutable( v );;
gap> w[1] := Z(7);
Error, Vector Assignment: <v> must be a mutable vector (not a data object)
gap> IsMutable( ShallowCopy( w ) );
true

#
# Base domains: each base domain object has its own context, so objects
# over equal but not identical base domains are unequal and unordered
#
gap> F3 := Field( Z(3) );;
gap> F3 = GF(3) and not IsIdenticalObj( F3, GF(3) );
true
gap> M := NewMatrix( IsPackedMatrixRep, GF(3), 2, [ [ Z(3), Z(3) ] ] );;
gap> N := NewMatrix( IsPackedMatrixRep, F3, 2, [ [ Z(3), Z(3) ] ] );;
gap> M = N or Unpack( M ) <> Unpack( N );
false
gap> M < N;
Error, \<: <a> and <b> must have the same base domain
gap> NewVector( IsPackedVectorRep, F3, [ Z(3) ] ) = NewVector( IsPackedVectorRep, GF(3), [ Z(3) ] );
false
gap> NewVector( IsPackedVectorRep, F3, [ Z(3) ] ) < NewVector( IsPackedVectorRep, GF(3), [ Z(3) ] );
Error, \<: <a> and <b> must have the same base domain
gap> Unpack( Matrix( IsPackedMatrixRep, F3, M ) ) = Unpack( M );
true
gap> M < NewMatrix( IsPackedMatrixRep, GF(5), 2, [ [ Z(5), Z(5) ] ] );
Error, \<: <a> and <b> must have the same base domain
gap> M = NewMatrix( IsGenericMatrixRep, GF(3), 2, [ [ Z(3), Z(3) ] ] );
false
gap> R := RingWithOne( ZmodnZObj( 1, 6 ) );;
gap> R = Integers mod 6 and not IsIdenticalObj( R, Integers mod 6 );
true
gap> NewVector( IsPackedVectorRep, R, [ ZmodnZObj( 1, 6 ) ] ) = NewVector( IsPackedVectorRep, Integers mod 6, [ ZmodnZObj( 1, 6 ) ] );
false

#
# Unsupported base domains
#
gap> NewMatrix( IsPackedMatrixRep, GF(4), 1, [] );
Error, packed matrices need GF(p) or Integers mod n with n < 2^64 as base doma\
in, not GF(2^2)
gap> NewVector( IsPackedVectorRep, Integers mod 2^64, [] );
Error, packed matrices need GF(p) or Integers mod n with n < 2^64 as base doma\
in, not (Integers mod 18446744073709551616)
gap> NewZeroVector( IsPackedVectorRep, Integers, 1 );
Error, packed matrices need GF(p) or Integers mod n with n < 2^64 as base doma\
in, not Integers

#
# Compressed GF(2) vectors keep stale bits beyond their length after Unbind;
# conversion must clear them, in rows of their own and in shared words
#
gap> u := List( [ 1 .. 70 ], i -> Z(2) );; ConvertToVectorRep( u, 2 );;
gap> Unbind( u[70] );; Unbind( u[69] );; IsGF2VectorRep( u );
true
gap> NewVector( IsPackedVectorRep, GF(2), u ) = NewVector( IsPackedVectorRep, GF(2), List( u ) );
true
gap> u := List( [ 1 .. 5 ], i -> Z(2) );; ConvertToVectorRep( u, 2 );;
gap> Unbind( u[5] );; Unbind( u[4] );; IsGF2VectorRep( u );
true
gap> NewMatrix( IsPackedMatrixRep, GF(2), 3, [ u, u ] ) = NewMatrix( IsPackedMatrixRep, GF(2), 3, [ List( u ), List( u ) ] );
true

#
# Hashing: SparseIntKey and dictionaries
#
gap> L := List( Tuples( [ 0, 1 ], 4 ), t -> NewMatrix( IsPackedMatrixRep, GF(2), 2, t * Z(2) ) );;
gap> h := SparseIntKey( false, L[1] );;
gap> IsSmallIntRep( h( L[1] ) ) and h( L[1] ) >= 0;
true
gap> Length( Set( L, h ) );
16
gap> h( L[5] ) = h( Immutable( ShallowCopy( L[5] ) ) );
true
gap> d := NewDictionary( L[1], true );;
gap> for x in [ 1 .. 16 ] do AddDictionary( d, L[x], x ); od;
gap> ForAll( [ 1 .. 16 ], x -> LookupDictionary( d, ShallowCopy( L[x] ) ) = x );
true
gap> LookupDictionary( d, NewMatrix( IsPackedMatrixRep, GF(2), 2, [ Z(2), Z(2) ] ) );
fail
gap> v := NewVector( IsPackedVectorRep, GF(7), [ Z(7) ] );;
gap> SparseIntKey( false, v )( v ) = SparseIntKey( false, v )( ShallowCopy( v ) );
true

#
gap> STOP_TEST( "matobjpacked.tst" );
