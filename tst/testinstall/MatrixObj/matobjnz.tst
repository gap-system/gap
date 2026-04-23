#@local R, z, pol, M, v, w, s, c, MM, S, T
gap> START_TEST( "matobjnz.tst" );

#
gap> ReadGapRoot( "tst/testinstall/MatrixObj/testmatobj.g" );

# vectors over a prime field
gap> R:= Integers mod 5;;
gap> TestZeroVector( IsZmodnZVectorRep, R, 0 );;
gap> TestZeroVector( IsZmodnZVectorRep, R, 3 );;
gap> Vector( IsZmodnZVectorRep, GF(5), [ 1/5 ] );
Error, <list> must be a list of reduced integers or of elements in <basedomain\
>
gap> Vector( IsZmodnZVectorRep, GF(25), [ Z(5) ] );
Error, <basedomain> must be Integers mod <n> for some <n>
gap> Vector( IsZmodnZVectorRep, GF(5), [ Z(25) ] );
Error, <list> must be a list of reduced integers or of elements in <basedomain\
>
gap> Vector( GF(2), [ 1 ] );
Error, cannot copy <l> to 'IsGF2VectorRep'
gap> Vector( GF(5), [ 1 ] );
Error, cannot copy <l> to 'Is8BitVectorRep'
gap> Vector( GF(257), [ 1 ] );
Error, the elements in <list> must lie in <basedomain>
gap> IsZmodnZVectorRep( Vector( GF( NextPrimeInt( 2^16 ) ), [] ) );
true
gap> IsZmodnZVectorRep( Vector( GF( NextPrimeInt( 2^16 ) ), [ 1 ] ) );
true

# vectors over a residue class ring that is not a field
gap> R:= Integers mod 6;;
gap> TestZeroVector( IsZmodnZVectorRep, R, 0 );;
gap> TestZeroVector( IsZmodnZVectorRep, R, 3 );;
gap> Vector( R, [ 1/2 ] );
Error, <list> must be a list of reduced integers or of elements in <basedomain\
>
gap> Vector( R, [ One( Integers mod 4 ) ] );
Error, <list> must be a list of reduced integers or of elements in <basedomain\
>
gap> z:= NewZeroVector( IsZmodnZVectorRep, R, 3 );;
gap> Vector( [ 1 .. 10 ], z );
Error, <list> must be a list of reduced integers or of elements in <basedomain\
>
gap> IsZmodnZVectorRep( Vector( R, [ 1 ] ) );
true

# matrices over a prime field
gap> R:= Integers mod 5;;
gap> TestZeroMatrix( IsZmodnZMatrixRep, R, 0, 0 );;
gap> TestZeroMatrix( IsZmodnZMatrixRep, R, 3, 4 );;
gap> TestIdentityMatrix( IsZmodnZMatrixRep, R, 3 );;
gap> pol:= X(R)^3 + 1;;
gap> TestCompanionMatrix( IsZmodnZMatrixRep, pol, R );;
gap> M:= Matrix( IsZmodnZMatrixRep, R, [ 1, 2, 3, 4 ], 2 );;
gap> TestElementaryTransforms( M, 3*One(R) );
gap> TestWholeMatrixTransforms( M, 3*One(R) );
gap> TestPositionNonZeroInRow( M );
gap> M:= Matrix( IsZmodnZMatrixRep, GF(5), [ 1, 2, 3, 4 ] / 5, 2 );
Error, <list>[
1] must be a list of reduced integers or of elements in <basedomain>
gap> M:= Matrix( IsZmodnZMatrixRep, GF(25), [ 1, 2, 3, 4 ] * Z(5)^0, 2 );
Error, <basedomain> must be Integers mod <n> for some <n>
gap> M:= Matrix( IsZmodnZMatrixRep, GF(5), [ 1, 2, 3, 4 ] * Z(25), 2 );
Error, <list>[
1] must be a list of reduced integers or of elements in <basedomain>
gap> Matrix( IsZmodnZMatrixRep, R, [ [ 1, 2 ], [ 3, 4 ] ], 3 );
Error, the entries of <list> must have length <ncols>
gap> Matrix( IsZmodnZMatrixRep, R, [ 1 .. 4 ], 3 );
Error, NewMatrix: Length of <list> is not a multiple of <ncols>
gap> Matrix( GF(2), [ [ 1 ] ], 1 );
Error, cannot convert <m> to 'IsGF2MatrixRep'
gap> Matrix( GF(5), [ [ 1 ] ] );
Error, cannot convert <m> to 'Is8BitMatrixRep'
gap> Matrix( GF(257), [ [ 1 ] ], 1 );
Error, the elements in <list> must lie in <basedomain>
gap> IsZmodnZMatrixRep( Matrix( GF( NextPrimeInt( 2^16 ) ), [ [] ] ) );
true
gap> IsZmodnZMatrixRep( Matrix( GF( NextPrimeInt( 2^16 ) ), [ [ 1 ] ] ) );
true

# matrices over a residue class ring that is not a field
gap> TestZeroMatrix( IsZmodnZMatrixRep, R, 0, 0 );;
gap> TestZeroMatrix( IsZmodnZMatrixRep, R, 3, 4 );;
gap> TestIdentityMatrix( IsZmodnZMatrixRep, R, 3 );;
gap> pol:= X(R)^3 + 1;;
gap> TestCompanionMatrix( IsZmodnZMatrixRep, pol, R );;
gap> M:= Matrix( IsZmodnZMatrixRep, R, [ 1, 2, 3, 4 ], 2 );;
gap> TestElementaryTransforms( M, 3*One(R) );
gap> TestWholeMatrixTransforms( M, 3*One(R) );
gap> TestPositionNonZeroInRow( M );
gap> M:= Matrix( IsZmodnZMatrixRep, R, [ 1, 2, 3, 4 ] / 2, 2 );
Error, <list>[
1] must be a list of reduced integers or of elements in <basedomain>
gap> M:= Matrix( IsZmodnZMatrixRep, R, [ One( Integers mod 4 ) ], 1 );
Error, <list>[
1] must be a list of reduced integers or of elements in <basedomain>
gap> M:= Matrix( IsZmodnZMatrixRep, Integers, [ 1, 2, 3, 4 ], 2 );
Error, <basedomain> must be Integers mod <n> for some <n>
gap> Matrix( IsZmodnZMatrixRep, R, [ [ 1, 2 ], [ 3, 4 ] ], 3 );
Error, the entries of <list> must have length <ncols>
gap> Matrix( IsZmodnZMatrixRep, R, [ 1 .. 4 ], 3 );
Error, NewMatrix: Length of <list> is not a multiple of <ncols>

# construct/view/print/display/string of vectors
gap> R:= Integers mod 6;;
gap> z:= NewZeroVector( IsZmodnZVectorRep, R, 3 );;
gap> v:= Vector( [ 1, 2, 3 ], z );
<vector mod 6: [ 1, 2, 3 ]>
gap> Print( v, "\n" );
NewVector(IsZmodnZVectorRep,(Integers mod 6),[ 1, 2, 3 ])
gap> Display( v );
<a zmodnz vector over (Integers mod 6):
[ 1, 2, 3 ]
>
gap> String( v );
"NewVector(IsZmodnZVectorRep,(Integers mod 6),[ 1, 2, 3 ])"
gap> v:= Vector( List( [ 1 .. 10 ], x -> x mod 6 ), z );
<vector mod 6 of length 10>
gap> Print( v, "\n" );
NewVector(IsZmodnZVectorRep,(Integers mod 6),[ 1, 2, 3, 4, 5, 0, 1, 2, 3, 4 ])
gap> Display( v );
<a zmodnz vector over (Integers mod 6):
[ 1, 2, 3, 4, 5, 0, 1, 2, 3, 4 ]
>
gap> String( v );
"NewVector(IsZmodnZVectorRep,(Integers mod 6),[ 1, 2, 3, 4, 5, 0, 1, 2, 3, 4 ]\
)"

# construct/view/print/display/string of matrices
gap> R:= Integers mod 6;;
gap> z:= NewZeroMatrix( IsZmodnZMatrixRep, R, 3, 4 );;
gap> M:= Matrix( [ [ 1, 2 ], [ 3, 4 ] ], z );
<matrix mod 6: [ [ 1, 2 ], [ 3, 4 ] ]>
gap> Print( M, "\n" );
NewMatrix(IsZmodnZMatrixRep,(Integers mod 6),2,[ [ 1, 2 ], [ 3, 4 ] ])
gap> Display( M );
<2x2-matrix over (Integers mod 6):
[ [  1,  2 ],
  [  3,  4 ] ]
]>
gap> String( M );
"NewMatrix(IsZmodnZMatrixRep,(Integers mod 6),2,[ [ 1, 2 ], [ 3, 4 ] ])"
gap> Matrix( [ [ 7 ] ], z );
Error, <list>[
1] must be a list of reduced integers or of elements in <basedomain>
gap> M:= Matrix( IsZmodnZMatrixRep, R, [ 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4 ], 2 );
<6x2-matrix mod 6>
gap> Print( M, "\n" );
NewMatrix(IsZmodnZMatrixRep,(Integers mod 6),2,
[ [ 1, 2 ], [ 3, 4 ], [ 1, 2 ], [ 3, 4 ], [ 1, 2 ], [ 3, 4 ] ])
gap> Display( M );
<6x2-matrix over (Integers mod 6):
[ [  1,  2 ],
  [  3,  4 ],
  [  1,  2 ],
  [  3,  4 ],
  [  1,  2 ],
  [  3,  4 ] ]
]>
gap> String( M );
"NewMatrix(IsZmodnZMatrixRep,(Integers mod 6),2,[ [ 1, 2 ], [ 3, 4 ], [ 1, 2 ]\
, [ 3, 4 ], [ 1, 2 ], [ 3, 4 ] ])"

# vectors: access, arithmetics
gap> R:= Integers mod 6;;
gap> v:= Vector( R, [ 1, 2, 3 ] );
<vector mod 6: [ 1, 2, 3 ]>
gap> v[1];
ZmodnZObj( 1, 6 )
gap> v[1]:= 0;;
gap> v;
<vector mod 6: [ 0, 2, 3 ]>
gap> v[1];
ZmodnZObj( 0, 6 )
gap> v[1]:= One( R );;
gap> v[1]:= Z(2);
Error, <ob> must be an integer or lie in the base domain of <v>
gap> v[4]:= 0;
Error, <p> is out of bounds
gap> Unpack( v );
[ ZmodnZObj( 1, 6 ), ZmodnZObj( 2, 6 ), ZmodnZObj( 3, 6 ) ]
gap> v{ [ 2, 3 ] };
<vector mod 6: [ 2, 3 ]>
gap> w:= ShallowCopy( v );
<vector mod 6: [ 1, 2, 3 ]>
gap> w = v;
true
gap> s:= v + w;
<vector mod 6: [ 2, 4, 0 ]>
gap> IsMutable( s );
true
gap> MakeImmutable( v );
<immutable vector mod 6: [ 1, 2, 3 ]>
gap> v + v;
<immutable vector mod 6: [ 2, 4, 0 ]>
gap> v + ZeroVector( Integers mod 4, 3 );
Error, <a> and <b> are not compatible
gap> s:= v - w;
<vector mod 6: [ 0, 0, 0 ]>
gap> IsMutable( s );
true
gap> v - v;
<immutable vector mod 6: [ 0, 0, 0 ]>
gap> v - ZeroVector( Integers mod 4, 3 );
Error, <a> and <b> are not compatible
gap> AdditiveInverseMutable( v );
<vector mod 6: [ 5, 4, 3 ]>
gap> z:= ZeroMutable( v );
<vector mod 6: [ 0, 0, 0 ]>
gap> z = ZeroVector( 3, v );
true
gap> v * 2;
<immutable vector mod 6: [ 2, 4, 0 ]>
gap> c:= 2 * One( R );;
gap> v * c;
<immutable vector mod 6: [ 2, 4, 0 ]>
gap> 2 * v;
<immutable vector mod 6: [ 2, 4, 0 ]>
gap> c * v;
<immutable vector mod 6: [ 2, 4, 0 ]>
gap> v / 5;
<immutable vector mod 6: [ 5, 4, 3 ]>
gap> v / 3;
Error, ModRat: for <r>/<s> mod <n>, <s>/gcd(<r>,<s>) and <n> must be coprime
gap> PositionNonZero( v );                                            
1
gap> PositionNonZero( v, 1 );
2
gap> PositionLastNonZero( v );
3
gap> List( v );
[ ZmodnZObj( 1, 6 ), ZmodnZObj( 2, 6 ), ZmodnZObj( 3, 6 ) ]
gap> List( v, Zero );
[ ZmodnZObj( 0, 6 ), ZmodnZObj( 0, 6 ), ZmodnZObj( 0, 6 ) ]
gap> v < 2 * v;
true
gap> v:= ShallowCopy( v );;
gap> AddRowVector( v, ZeroVector( Integers mod 4, 3 ) );
Error, <a> and <b> are not compatible
gap> AddRowVector( v, v );
gap> v;
<vector mod 6: [ 2, 4, 0 ]>
gap> v:= Vector( R, [ 1, 2, 3 ] );;
gap> AddRowVector( v, v, 2 );
gap> v;
<vector mod 6: [ 3, 0, 3 ]>
gap> v:= Vector( R, [ 0 .. 5 ] );
<vector mod 6: [ 0, 1, 2, 3, 4, 5 ]>
gap> AddRowVector( v, v, 2, 3, 4 );
gap> v;
<vector mod 6: [ 0, 1, 0, 3, 4, 5 ]>
gap> v:= Vector( R, [ 1, 2, 3 ] );;
gap> MultVector( v, 2 );
gap> v;
<vector mod 6: [ 2, 4, 0 ]>
gap> v:= Vector( R, [ 0 .. 5 ] );
<vector mod 6: [ 0, 1, 2, 3, 4, 5 ]>
gap> MultVector( v, 2, 3, 4 );
gap> v;
<vector mod 6: [ 0, 1, 4, 0, 4, 5 ]>
gap> CopySubVector( v, v, [ 1 .. 3 ], [ 4 .. 6 ] );
gap> v;
<vector mod 6: [ 0, 1, 4, 0, 1, 4 ]>

# matrices: access, arithmetics
gap> R:= Integers mod 6;;
gap> M:= Matrix( IsZmodnZMatrixRep, R, [ 1, 2, 3, 4 ], 2 );;
gap> M[1];
Error, row access unsupported; use M[i,j] or RowsOfMatrix(M)
gap> M[1,1];
ZmodnZObj( 1, 6 )
gap> M[1,3];
Error, List Element: <list>[3] must have an assigned value
gap> M[3,1];
Error, List Element: <list>[3] must have an assigned value
gap> M[1,1]:= 0;;
gap> M[1,1];
ZmodnZObj( 0, 6 )
gap> M[1,1]:= One( R );;
gap> M[1,1];
ZmodnZObj( 1, 6 )
gap> M[1,3]:= 0;;
Error, <col> is out of bounds
gap> M[3,1]:= 0;;
Error, <row> is out of bounds
gap> M[1,1]:= Z(2);;
Error, <ob> must be an integer or lie in the base domain of <M>
gap> RowsOfMatrix( M );
[ <immutable vector mod 6: [ 1, 2 ]>, <immutable vector mod 6: [ 3, 4 ]> ]
gap> Unpack( M );
[ [ ZmodnZObj( 1, 6 ), ZmodnZObj( 2, 6 ) ], 
  [ ZmodnZObj( 3, 6 ), ZmodnZObj( 4, 6 ) ] ]
gap> MM:= ShallowCopy( M );
<matrix mod 6: [ [ 1, 2 ], [ 3, 4 ] ]>
gap> MM = M;
true
gap> MM:= MutableCopyMatrix( Immutable( M ) );
<matrix mod 6: [ [ 1, 2 ], [ 3, 4 ] ]>
gap> IsMutable( MM ) and MM = M;
true
gap> ExtractSubMatrix( M, [ 1 ], [ 2 ] );
<matrix mod 6: [ [ 2 ] ]>
gap> CopySubMatrix( MM, M, [ 1 ], [ 2 ], [ 1 ], [ 2 ] );
gap> M;
<matrix mod 6: [ [ 1, 2 ], [ 3, 1 ] ]>
gap> TransposedMatMutable( M );
<matrix mod 6: [ [ 1, 3 ], [ 2, 1 ] ]>
gap> S:= M + MM;
<matrix mod 6: [ [ 2, 4 ], [ 0, 5 ] ]>
gap> IsMutable( S );
true
gap> MakeImmutable( M );
<immutable matrix mod 6: [ [ 1, 2 ], [ 3, 1 ] ]>
gap> M + M;
<immutable matrix mod 6: [ [ 2, 4 ], [ 0, 2 ] ]>
gap> M + ZeroMatrix( R, 3, 3 );
Error, <a> and <b> are not compatible
gap> M - M;
<immutable matrix mod 6: [ [ 0, 0 ], [ 0, 0 ] ]>
gap> M - ZeroMatrix( R, 3, 3 );
Error, <a> and <b> are not compatible
gap> AdditiveInverseMutable( M );
<matrix mod 6: [ [ 5, 4 ], [ 3, 5 ] ]>
gap> z:= ZeroMutable( M );
<matrix mod 6: [ [ 0, 0 ], [ 0, 0 ] ]>
gap> z = ZeroMatrix( R, 2, 2 );
true
gap> z < M;
true
gap> InverseMutable( M );
<matrix mod 6: [ [ 1, 4 ], [ 3, 1 ] ]>
gap> InverseMutable( ZeroMatrix( R, 2, 2 ) );
fail
gap> M * M;
<immutable matrix mod 6: [ [ 1, 4 ], [ 0, 1 ] ]>
gap> M * ZeroMatrix( R, 1, 1 );
Error, \*: Matrices do not fit together
gap> M * ZeroMatrix( IsZmodnZMatrixRep, GF(2), 2, 2 );
Error, \*: Matrices not over same base domain
gap> M * CompatibleVector( M );
<vector mod 6: [ 0, 0 ]>
gap> CompatibleVector( M ) * M;
<vector mod 6: [ 0, 0 ]>
gap> CompatibleVector( M ) ^ M;
<vector mod 6: [ 0, 0 ]>
gap> M * ZeroVector( 3, M );
Error, <M> and <v> are not compatible
gap> ZeroVector( 3, M ) * M;
Error, <v> and <M> are not compatible
gap> M:= Matrix( IsZmodnZMatrixRep, R, [[], []], 0 );    
<2x0-matrix mod 6>
gap> v:= CompatibleVector( M );
<vector mod 6: [ 0, 0 ]>
gap> v * M;
<vector mod 6 of length 0>
gap> M:= Matrix( IsZmodnZMatrixRep, R, [], 3 );
<0x3-matrix mod 6>
gap> v:= CompatibleVector( M );
<vector mod 6 of length 0>
gap> v * M;
<vector mod 6: [ 0, 0, 0 ]>
gap> M:= Matrix( IsZmodnZMatrixRep, R, [ 1, 2, 3, 4 ], 2 );;
gap> MultMatrixRowLeft( M, 1, 4 );
gap> M;
<matrix mod 6: [ [ 4, 2 ], [ 3, 4 ] ]>
gap> MultMatrixRowRight( M, 2, 4 );
gap> M;
<matrix mod 6: [ [ 4, 2 ], [ 0, 4 ] ]>
gap> PositionNonZeroInRow( M, 1 );
1
gap> PositionNonZeroInRow( M, 1, 1 );
2
gap> PositionNonZeroInRow( ZeroMatrix( R, 2, 3 ), 1 );
4
gap> SwapMatrixRows( M, 1, 2 );
gap> M;
<matrix mod 6: [ [ 0, 4 ], [ 4, 2 ] ]>
gap> SwapMatrixColumns( M, 1, 2 );
gap> M;
<matrix mod 6: [ [ 4, 0 ], [ 2, 4 ] ]>
gap> IsZero( M );
false
gap> IsZero( 6 * M );
true
gap> IsOne( M );
false
gap> IsOne( M^0 );
true
gap> RankMat( M );
fail
gap> RankMat( IdentityMatrix( 3, M ) );                               
3
gap> R:= Integers mod NextPrimeInt( 2^16 );;
gap> One( R );
ZmodpZObj( 1, 65537 )
gap> M:= Matrix( IsZmodnZMatrixRep, R, [ 1, 2, 3, 4 ], 2 );;
gap> DeterminantMat( M );
ZmodpZObj( 65535, 65537 )

# miscellaneous
gap> MinimalPolynomial( R, M, 1 ) = MinimalPolynomial( R, Unpack( M ), 1 );
true
gap> CharacteristicPolynomialMatrixNC( R, M, 1 ) =
>    CharacteristicPolynomialMatrixNC( R, Unpack( M ), 1 );
true
gap> R:= Integers mod 6;;
gap> v:= Vector( R, [ 1, 2, 3 ] );;
gap> ProductCoeffs( v, v ) = ProductCoeffs( Unpack( v ), Unpack( v ) );
true

# an issue with the type in earlier code
gap> R:= Integers mod 6;;
gap> z:= NewZeroVector( IsZmodnZVectorRep, R, 3 );;
gap> MakeImmutable( z );;
gap> IsZero(z);
true
gap> HasIsZero(z);
true
gap> v:= Vector( [ 1, 2, 3 ], z );;
gap> IsZero( v );
false

# default 'Vector' methods
gap> z:= NewZeroVector( IsZmodnZVectorRep, GF(2), 3 );;
gap> w:= [ 1, 0 ] * Z(2);;
gap> ConvertToVectorRep( w );;
gap> Vector( w, z );
<vector mod 2: [ 1, 0 ]>
gap> z:= NewZeroVector( IsZmodnZVectorRep, GF(3), 3 );;
gap> w:= [ 1, 0 ] * Z(3)^0;;
gap> ConvertToVectorRep( w );;
gap> Vector( w, z );
<vector mod 3: [ 1, 0 ]>
gap> w:= [ 1, 0 ];;
gap> Vector( w, z );
<vector mod 3: [ 1, 0 ]>
gap> Vector( w * Z(3)^0, z );
<vector mod 3: [ 1, 0 ]>

#
gap> z:= NewZeroVector( IsZmodnZVectorRep, GF(2), 3 );;
gap> MakeImmutable( z );;
gap> IsMutable( z![ELSPOS] );
false

# matrix multiplication
gap> M:= Matrix( IsZmodnZMatrixRep, Integers mod 6, [ [], [] ], 0 );
<2x0-matrix mod 6>
gap> T:= TransposedMat( M );
<immutable 0x2-matrix mod 6>
gap> M * T;
<matrix mod 6: [ [ 0, 0 ], [ 0, 0 ] ]>
gap> T * M;
<0x0-matrix mod 6>

#
gap> M:= Matrix( IsZmodnZMatrixRep, Integers mod 6, [ 1, 2 ], 2 );;
gap> OneMutable( M );
Error, <M> must be square (not 1 by 2)

#
gap> STOP_TEST( "matobjnz.tst" );
