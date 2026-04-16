#@local e, v, v2, w, M, z, rows, a, b, c, d, p, ev, n, ai, inv, zm, zs
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
gap> a:= NewZeroMatrix( IsGenericMatrixRep, Integers, 2, 0 );
<2x0-matrix over Integers>
gap> b:= NewZeroMatrix( IsGenericMatrixRep, Integers, 0, 3 );
<0x3-matrix over Integers>
gap> c:= NewZeroMatrix( IsGenericMatrixRep, Integers, 0, 0 );
<0x0-matrix over Integers>
gap> d:= NewZeroMatrix( IsGenericMatrixRep, Integers, 0, 2 );
<0x2-matrix over Integers>
gap> z:= NewZeroMatrix( IsGenericMatrixRep, Integers, 2, 3 );
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
gap> M:= NewMatrix( IsGenericMatrixRep, Integers, 3, [ [ 0, 0, 2 ], [ 0, 0, 0 ] ] );;
gap> PositionNonZeroInRow( M, 1 );
3
gap> PositionNonZeroInRow( M, 1, 2 );
3
gap> PositionNonZeroInRow( M, 2 );
4

#
gap> M:= NewMatrix( IsGenericMatrixRep, Integers, 3,
>                   [ [ 1, 2, 3 ], [ 4, 5, 6 ] ] );;
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
gap> STOP_TEST( "matobjgeneric.tst" );
