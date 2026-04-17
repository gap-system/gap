#@local e, v, v2, w, M, z, rows, a, b, c, d, p, ev, n, ai, inv, zm, zs, N, T, lp, lp0, s
gap> START_TEST( "matobjgeneric.tst" );

#
# MakeIsPlistVectorRep: test input validation
#
gap> e:= MakeIsPlistVectorRep( Integers, [], true );
<plist vector over Integers of length 0>
gap> v:= MakeIsPlistVectorRep( Integers, [ 1 ], true );
<plist vector over Integers of length 1>
gap> v2:= NewVector( IsPlistVectorRep, Integers, [ 1, 0 ] );
<plist vector over Integers of length 2>
gap> w:= MakeIsPlistVectorRep( Rationals, [ 1 ], true );
<plist vector over Rationals of length 1>

#
gap> MakeIsGenericMatrixRep( Integers, 2, [ v ], true );
Error, the entries of <list> must be plain lists
gap> M:= MakeIsGenericMatrixRep( Integers, 2, [], true );
<0x2-matrix over Integers>
gap> MakeIsGenericMatrixRep( Integers, 1, [ [ 1 ] ], true );
<1x1-matrix over Integers>
gap> MakeIsGenericMatrixRep( Integers, 2, [ [ 1 ] ], true );
Error, the entries of <list> must have length <ncols>
gap> MakeIsGenericMatrixRep( Integers, 1, [ [ 1/2 ] ], true );
Error, the elements in <list> must lie in <basedomain>
gap> MakeIsGenericMatrixRep( GF(2), 1, [ [ Z(2) ] ], true );
<1x1-matrix over GF(2)>
gap> MakeIsGenericMatrixRep( GF(2), 1, [ [ Z(4) ] ], true );
Error, the elements in <list> must lie in <basedomain>

#
gap> NewMatrix( IsGenericMatrixRep, Integers, 2, [] );
<0x2-matrix over Integers>
gap> NewMatrix( IsGenericMatrixRep, Integers, 2, [ 1 ] );
Error, NewMatrix: Length of <list> is not a multiple of <ncols>
gap> NewMatrix( IsGenericMatrixRep, Integers, 2, [ [ 1 ] ] );
Error, the entries of <list> must have length <ncols>
gap> NewMatrix( IsGenericMatrixRep, Integers, 2, [ [ 1, 2 ] ] );
<1x2-matrix over Integers>
gap> NewMatrix( IsGenericMatrixRep, Integers, 2, [ v ] );
Error, the entries of <list> must have length <ncols>
gap> M:= NewMatrix( IsGenericMatrixRep, Integers, 2, [ [ 1, 2 ], [ 3, 4 ] ] );
<2x2-matrix over Integers>
gap> IsMutable( M );
true
gap> Unpack( M );
[ [ 1, 2 ], [ 3, 4 ] ]
gap> M[2,1];
3
gap> M[1];
Error, row access unsupported; use M[i,j] or RowsOfMatrix(M)
gap> M[2,2] := 5;;
gap> Unpack( M );
[ [ 1, 2 ], [ 3, 5 ] ]

#
gap> rows:= RowsOfMatrix( M );
[ <immutable plist vector over Integers of length 2>, 
  <immutable plist vector over Integers of length 2> ]
gap> Length( rows );
2
gap> IsPlistVectorRep( rows[1] );
true
gap> Unpack( rows[1] );
[ 1, 2 ]
gap> M[1,1] := 77;;
gap> rows[1][1];
1

#
gap> M:= NewMatrix( IsGenericMatrixRep, Integers, 2, [ v2, v2 ] );;
gap> Unpack( M );
[ [ 1, 0 ], [ 1, 0 ] ]

#
# Empty matrices and empty vectors
#
#
gap> a:= ZeroMatrix( IsGenericMatrixRep, Integers, 2, 0 );
<2x0-matrix over Integers>
gap> b:= ZeroMatrix( IsGenericMatrixRep, Integers, 0, 3 );
<0x3-matrix over Integers>
gap> c:= ZeroMatrix( IsGenericMatrixRep, Integers, 0, 0 );
<0x0-matrix over Integers>
gap> d:= ZeroMatrix( IsGenericMatrixRep, Integers, 0, 2 );
<0x2-matrix over Integers>
gap> z:= ZeroMatrix( IsGenericMatrixRep, Integers, 2, 3 );
<2x3-matrix over Integers>
gap> IsMutable( z );
true
gap> Unpack( z );
[ [ 0, 0, 0 ], [ 0, 0, 0 ] ]

#
gap> M:= NewIdentityMatrix( IsGenericMatrixRep, Integers, 2 );;
gap> Unpack( M );
[ [ 1, 0 ], [ 0, 1 ] ]

#
gap> a = NewMatrix( IsGenericMatrixRep, Integers, 0, [ [], [] ] );
true
gap> b = NewMatrix( IsGenericMatrixRep, Integers, 3, [] );
true
gap> c = NewMatrix( IsGenericMatrixRep, Integers, 0, [] );
true
gap> d = NewMatrix( IsGenericMatrixRep, Integers, 2, [] );
true

#
gap> p:= a * b;
<2x3-matrix over Integers>
gap> Unpack( p );
[ [ 0, 0, 0 ], [ 0, 0, 0 ] ]
gap> p:= d * a;
<0x0-matrix over Integers>
gap> Unpack( p );
[  ]
gap> p:= c * b;
<0x3-matrix over Integers>
gap> Unpack( p );
[  ]

# empty vector times (necessarily also empty) matrix
gap> ev:= NewVector( IsPlistVectorRep, Integers, [] );
<plist vector over Integers of length 0>
gap> a * ev;
<plist vector over Integers of length 2>
gap> Unpack( last );
[ 0, 0 ]
gap> ev * b;
<plist vector over Integers of length 3>
gap> Unpack( last );
[ 0, 0, 0 ]

# non-empty vector times empty matrix
gap> v2:= NewVector( IsPlistVectorRep, Integers, [ 1, 2 ] );
<plist vector over Integers of length 2>
gap> d * v2;
<plist vector over Integers of length 0>
gap> Unpack( last );
[  ]
gap> Unpack( v2 * a );
[  ]

#
gap> b + b;
<0x3-matrix over Integers>
gap> b - b;
<0x3-matrix over Integers>
gap> -b;
<0x3-matrix over Integers>
gap> ZeroMutable( b );
<0x3-matrix over Integers>

#
gap> InverseMutable( c );
<0x0-matrix over Integers>
gap> InverseSameMutability( c );
<0x0-matrix over Integers>

#
gap> M:= Matrix( IsGenericMatrixRep, Integers, [ [ 0, 0, 2 ], [ 0, 0, 0 ] ] );;
gap> PositionNonZeroInRow( M, 1 );
3
gap> PositionNonZeroInRow( M, 1, 2 );
3
gap> PositionNonZeroInRow( M, 2 );
4

#
gap> M:= Matrix( IsGenericMatrixRep, Integers, [ [ 1, 2, 3 ], [ 4, 5, 6 ] ] );;
gap> MultMatrixRowLeft( M, 1, -1 );;
gap> Unpack( M );
[ [ -1, -2, -3 ], [ 4, 5, 6 ] ]
gap> MultMatrixRowRight( M, 2, 2 );;
gap> Unpack( M );
[ [ -1, -2, -3 ], [ 8, 10, 12 ] ]
gap> AddMatrixRowsLeft( M, 1, 2, 3 );;
gap> Unpack( M );
[ [ 23, 28, 33 ], [ 8, 10, 12 ] ]
gap> AddMatrixRowsRight( M, 2, 1, 2 );;
gap> Unpack( M );
[ [ 23, 28, 33 ], [ 54, 66, 78 ] ]
gap> SwapMatrixRows( M, 1, 2 );;
gap> Unpack( M );
[ [ 54, 66, 78 ], [ 23, 28, 33 ] ]

#
# Test Inverse / InverseMutable
#
gap> M:= Matrix( IsGenericMatrixRep, Integers, [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ] ] );;
gap> InverseMutable( M );
Error, InverseMutable: matrix must be square
gap> M:= Matrix( IsGenericMatrixRep, GF(2), [ [ Z(2)^0, Z(2)^0 ], [ Z(2)^0, 0*Z(2) ] ] );;
gap> N:= InverseMutable( M );;
gap> Display( N );
<2x2-matrix over GF(2):
[[ 0*Z(2), Z(2)^0 ]
 [ Z(2)^0, Z(2)^0 ]
]>
gap> IsOne( N * M );
true
gap> IsOne( M * N );
true
gap> M:= Matrix( IsGenericMatrixRep, Rationals, [ [ 1, 2 ], [ 3, 5 ] ] );;
gap> N:= InverseMutable( M );;
gap> Display( N );
<2x2-matrix over Rationals:
[[ -5, 2 ]
 [ 3, -1 ]
]>

#
# mutability after operations
#
gap> M:= Matrix( IsGenericMatrixRep, Rationals, [ [ 1, 2 ], [ 3, 5 ] ] );;
gap> IsMutable(M);
true
gap> N:= InverseSameMutability( M );;
gap> IsMutable(N);
true
gap> IsMutable( M * N );
true
gap> IsMutable( M + N );
true
gap> IsMutable( M - N );
true
gap> IsMutable( -M );
true
gap> MakeImmutable(M);;
gap> IsMutable( M * N );
true
gap> IsMutable( M + N );
true
gap> IsMutable( M - N );
true
gap> N:= InverseSameMutability( M );;
gap> IsMutable(N);
false
gap> IsMutable( M * N );
false
gap> IsMutable( M + N );
false
gap> IsMutable( M - N );
false
gap> IsMutable( -M );
false

#
gap> M:= Matrix( IsGenericMatrixRep, Integers, [ [ 1, 2 ], [ 3, 4 ] ] );;
gap> M[1,1] := 1/2;
Error, <ob> must lie in the base domain of <M>
gap> M[3,1] := 1;
Error, <row> is out of bounds
gap> M[1,3] := 1;
Error, <col> is out of bounds

#
gap> a:= Matrix( IsGenericMatrixRep, Integers, [ [ 1, 2 ] ] );;
gap> b:= Matrix( IsGenericMatrixRep, Rationals, [ [ 1, 2 ] ] );;
gap> a + b;
Error, <a> and <b> are not compatible
gap> a - b;
Error, <a> and <b> are not compatible
gap> c:= Matrix( IsGenericMatrixRep, Integers, [ [ 1 ], [ 2 ] ] );;
gap> c * c;
Error, \*: Matrices do not fit together
gap> d:= Matrix( IsGenericMatrixRep, Rationals, [ [ 1 ], [ 2 ] ] );;
gap> a * d;
Error, \*: Matrices not over same base domain

#
# ShallowCopy, MutableCopyMatrix
#
gap> M:= Matrix( IsGenericMatrixRep, Integers, [ [ 1, 2 ], [ 3, 4 ] ] );;
gap> N:= ShallowCopy( M );;
gap> N[1,1] := 99;;
gap> Unpack( M );
[ [ 1, 2 ], [ 3, 4 ] ]
gap> Unpack( N );
[ [ 99, 2 ], [ 3, 4 ] ]
gap> N:= MutableCopyMatrix( M );;
gap> N[1,2] := 77;;
gap> Unpack( M );
[ [ 1, 2 ], [ 3, 4 ] ]
gap> Unpack( N );
[ [ 1, 77 ], [ 3, 4 ] ]

#
# ExtractSubMatrix, CopySubMatrix
#
gap> Unpack( ExtractSubMatrix( M, [ 2, 1 ], [ 2 ] ) );
[ [ 4 ], [ 2 ] ]
gap> T:= ZeroMatrix( IsGenericMatrixRep, Integers, 2, 3 );;
gap> CopySubMatrix( M, T, [ 2, 1 ], [ 1, 2 ], [ 2 ], [ 3 ] );;
gap> Unpack( T );
[ [ 0, 0, 4 ], [ 0, 0, 2 ] ]
gap> CopySubMatrix( Matrix( IsGenericMatrixRep, Rationals, [ [ 1, 2 ] ] ),
>                   T, [ 1 ], [ 1 ], [ 1 ], [ 1 ] );
Error, <M> and <N> are not compatible

#
# TransposedMatMutable
#
gap> Unpack( TransposedMatMutable( M ) );
[ [ 1, 3 ], [ 2, 4 ] ]

#
# ChangedBaseDomain
#
gap> N:= ChangedBaseDomain( M, Rationals );;
gap> BaseDomain( N );
Rationals
gap> Unpack( N );
[ [ 1, 2 ], [ 3, 4 ] ]
gap> IsMutable( N );
true
gap> MakeImmutable( M );;
gap> N:= ChangedBaseDomain( M, Rationals );;
gap> IsMutable( N );
false

#
# ViewObj, PrintObj, Display, String
#
gap> M := Matrix( IsGenericMatrixRep, GF(2), [ [ Z(2)^0, 0*Z(2) ] ] );
<1x2-matrix over GF(2)>
gap> Print(M, "\n");
NewMatrix(IsGenericMatrixRep,GF(2),2,[ [ Z(2)^0, 0*Z(2) ] ])
gap> Display(M);
<1x2-matrix over GF(2):
[[ Z(2)^0, 0*Z(2) ]
]>
gap> String(M);
"NewMatrix(IsGenericMatrixRep,GF(2),2,[ [ Z(2)^0, 0*Z(2) ] ])"

#
gap> MakeImmutable( M );
<immutable 1x2-matrix over GF(2)>
gap> Print(M, "\n");
NewMatrix(IsGenericMatrixRep,GF(2),2,[ [ Z(2)^0, 0*Z(2) ] ])
gap> Display(M);
<immutable 1x2-matrix over GF(2):
[[ Z(2)^0, 0*Z(2) ]
]>
gap> String(M);
"NewMatrix(IsGenericMatrixRep,GF(2),2,[ [ Z(2)^0, 0*Z(2) ] ])"

#
gap> M :=Matrix( IsGenericMatrixRep, Integers, [ [ 1, 2 ], [ 3, 4 ] ] );
<2x2-matrix over Integers>
gap> Print(M, "\n");
NewMatrix(IsGenericMatrixRep,Integers,2,[ [ 1, 2 ], [ 3, 4 ] ])
gap> Display(M);
<2x2-matrix over Integers:
[[ 1, 2 ]
 [ 3, 4 ]
]>
gap> String(M);
"NewMatrix(IsGenericMatrixRep,Integers,2,[ [ 1, 2 ], [ 3, 4 ] ])"

#
gap> MakeImmutable( M );
<immutable 2x2-matrix over Integers>
gap> Print(M, "\n");
NewMatrix(IsGenericMatrixRep,Integers,2,[ [ 1, 2 ], [ 3, 4 ] ])
gap> Display(M);
<immutable 2x2-matrix over Integers:
[[ 1, 2 ]
 [ 3, 4 ]
]>
gap> String(M);
"NewMatrix(IsGenericMatrixRep,Integers,2,[ [ 1, 2 ], [ 3, 4 ] ])"

#
# vec * mat, mat * vec
#
gap> M:= Matrix( IsGenericMatrixRep, Integers, [ [ 1, 2 ], [ 3, 4 ] ] );;
gap> v:= Vector( Integers, [ 1, 2 ] );
<plist vector over Integers of length 2>
gap> Display( M * v );
<a plist vector over Integers:
[ 5, 11 ]
>
gap> Display( v * M );
<a plist vector over Integers:
[ 7, 10 ]
>

#
gap> M * [ 1, 2 ];
[ 5, 11 ]
gap> [ 1, 2 ] * M;
[ 7, 10 ]

#
gap> R:= Integers mod 6;;
gap> M:= Matrix( IsGenericMatrixRep, R, One(R) * [ [ 1, 2 ], [ 3, 4 ] ] );;
gap> v:= NewVector( IsZmodnZVectorRep, R, One(R) * [ 1, 2 ] );
<vector mod 6: [ 1, 2 ]>
gap> Display( M * v );
<a zmodnz vector over (Integers mod 6):
[ 5, 5 ]
>
gap> Display( v * M );
<a zmodnz vector over (Integers mod 6):
[ 1, 4 ]
>

# error handling
gap> M * [ 1, 2, 3 ];
Error, <M> and <v> are not compatible
gap> [ 1, 2, 3 ] * M;
Error, <v> and <M> are not compatible
gap> M * [ Z(2), Z(2) ];
Error, <M> and <v> are not compatible
gap> [ Z(2), Z(2) ] * M;
Error, <v> and <M> are not compatible

# multiplication with empty list is not well-defined: we don't know if
# is meant to be a vector of length 0, or something else; so rather
# error out
gap> a:= ZeroMatrix( IsGenericMatrixRep, Integers, 2, 0 );;
gap> b:= ZeroMatrix( IsGenericMatrixRep, Integers, 0, 3 );;
gap> a * [];
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `BaseDomain' on 1 arguments
gap> [] * b;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `BaseDomain' on 1 arguments

#
# families
#
gap> M:= NewZeroMatrix( IsGenericMatrixRep, Integers, 2, 3 );
<2x3-matrix over Integers>
gap> IsMutable( M );
true
gap> IsCyclotomicCollColl( M );
true
gap> IsFFECollColl( M );
false

#
gap> M:= NewZeroMatrix( IsGenericMatrixRep, GF(257), 2, 3 );
<2x3-matrix over GF(257)>
gap> IsMutable( M );
true
gap> IsCyclotomicCollColl( M );
false
gap> IsFFECollColl( M );
true

#
gap> STOP_TEST( "matobjgeneric.tst" );
