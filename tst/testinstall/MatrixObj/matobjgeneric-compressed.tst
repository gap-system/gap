#@local F, M, N, cm, l, z, rows
gap> START_TEST( "matobjgeneric-compressed.tst" );
gap> ReadGapRoot( "tst/testinstall/MatrixObj/testmatobj.g" );

# Compare all methods with the arithmetic of lists of lists.
# Matrices over GF(257) and over the rationals have plain rows.
gap> for F in [ GF(2), GF(3), GF(4), GF(9), GF(251), GF(256), GF(257),
>               Rationals ] do
>   Print( F, ": ", TestGenericMatrixRep( F ), "\n" );
> od;
GF(2): [  ]
GF(3): [  ]
GF(2^2): [  ]
GF(3^2): [  ]
GF(251): [  ]
GF(2^8): [  ]
GF(257): [  ]
Rationals: [  ]

#
# which base domains get compressed rows
#
gap> List( [ GF(2), GF(3), GF(4), GF(9), GF(251), GF(256), GF( GF(4), 2 ) ],
>          GEN_MAT_COMPRESSED_FIELD_SIZE );
[ 2, 3, 4, 9, 251, 256, 16 ]
gap> List( [ GF(257), GF(2^9), Integers, Rationals, Integers mod 4,
>            RingByGenerators( [ 0*Z(2) ] ) ],
>          GEN_MAT_COMPRESSED_FIELD_SIZE );
[ fail, fail, fail, fail, fail, fail ]
gap> GEN_MAT_COMPRESSED_FIELD_SIZE( AlgebraicExtension( GF(3),
>                                       X( GF(3) )^2 + 1 ) );
fail
gap> rows:= [ [ Z(9), Z(3) ], [ Z(3)^0, 0*Z(3) ] ];;
gap> M:= Matrix( IsGenericMatrixRep, GF(9), rows );;
gap> Is8BitMatrixRep( M![GEN_MAT_REP_ROWS_POS] );
true
gap> ForAll( M![GEN_MAT_REP_ROWS_POS], IsLockedRepresentationVector );
true
gap> M:= Matrix( IsGenericMatrixRep, GF(2), [ [ Z(2), 0*Z(2) ] ] );;
gap> IsGF2MatrixRep( M![GEN_MAT_REP_ROWS_POS] );
true
gap> M:= Matrix( IsGenericMatrixRep, GF( GF(4), 2 ), [ [ Z(2), Z(16) ] ] );;
gap> Q_VEC8BIT( M![GEN_MAT_REP_ROWS_POS][1] );
16
gap> M:= Matrix( IsGenericMatrixRep, GF(257), [ [ Z(257) ] ] );;
gap> IsPlistRep( M![GEN_MAT_REP_ROWS_POS] );
true

# the storage is not visible: no list, no row access
gap> M:= Matrix( IsGenericMatrixRep, GF(9), rows );;
gap> IsList( M ) or IsMatrix( M ) or IsRowListMatrix( M );
false
gap> M[1];
Error, row access unsupported; use M[i,j] or RowsOfMatrix(M)
gap> M;
<2x2-matrix over GF(3^2)>
gap> Print( M, "\n" );
NewMatrix(IsGenericMatrixRep,GF(9),2,[ [ Z(3^2), Z(3) ], [ Z(3)^0, 0*Z(3) ] ])
gap> String( M );
"NewMatrix(IsGenericMatrixRep,GF(9),2,[ [ Z(3^2), Z(3) ], [ Z(3)^0, 0*Z(3) ] ]\
)"
gap> Display( M );
<2x2-matrix over GF(3^2):
[[ Z(3^2), Z(3) ]
 [ Z(3)^0, 0*Z(3) ]
]>
gap> Display( MakeImmutable( Matrix( IsGenericMatrixRep, GF(2),
>                                    [ [ Z(2), 0*Z(2) ], [ Z(2), Z(2) ] ] ) ) );
<immutable 2x2-matrix over GF(2):
[[ Z(2)^0, 0*Z(2) ]
 [ Z(2)^0, Z(2)^0 ]
]>

#
# the constructor normalises the rows
#
gap> cm:= List( rows, ShallowCopy );;  ConvertToMatrixRep( cm, 9 );;
gap> M:= MakeIsGenericMatrixRep( GF(9), 2, cm, false );;
gap> IsIdenticalObj( M![GEN_MAT_REP_ROWS_POS], cm );
true

# a plain list of compressed rows is converted in place
gap> l:= List( cm, ShallowCopy );;
gap> M:= MakeIsGenericMatrixRep( GF(9), 2, l, false );;
gap> IsIdenticalObj( M![GEN_MAT_REP_ROWS_POS], l );
true
gap> GEN_MAT_HAS_CANONICAL_ROWS( M );
true

# a matrix compressed over another field is copied
gap> cm:= [ [ Z(3), 0*Z(3) ], [ Z(3)^0, Z(3) ] ];;  ConvertToMatrixRep( cm, 3 );;
gap> M:= MakeIsGenericMatrixRep( GF(9), 2, cm, false );;
gap> GEN_MAT_HAS_CANONICAL_ROWS( M );
true
gap> Unpack( M ) = cm;
true
gap> Q_VEC8BIT( cm[1] );
3
gap> M:= MakeIsGenericMatrixRep( GF(9), 2, MakeImmutable( cm ), false );;
gap> GEN_MAT_HAS_CANONICAL_ROWS( M );
true
gap> IsMutable( M );
false
gap> cm:= [ [ Z(2), 0*Z(2) ], [ Z(2), Z(2) ] ];;  ConvertToMatrixRep( cm, 2 );;
gap> M:= MakeIsGenericMatrixRep( GF(4), 2, cm, false );;
gap> GEN_MAT_HAS_CANONICAL_ROWS( M ) and Unpack( M ) = cm;
true
gap> cm:= [ [ Z(2), 0*Z(2) ], [ Z(2), Z(2) ] ];;  ConvertToMatrixRep( cm, 4 );;
gap> M:= MakeIsGenericMatrixRep( GF(2), 2, cm, false );;
gap> GEN_MAT_HAS_CANONICAL_ROWS( M ) and Unpack( M ) = cm;
true
gap> cm:= [ [ Z(3), 0*Z(3) ], [ Z(3)^0, Z(3) ] ];;  ConvertToMatrixRep( cm, 3 );;

# compressed rows where plain rows are stored
gap> M:= MakeIsGenericMatrixRep( GF(3^6), 2, cm, false );;
gap> GEN_MAT_HAS_CANONICAL_ROWS( M );
true
gap> Unpack( M ) = cm;
true
gap> M:= MakeIsGenericMatrixRep( GF(3), 0, [ cm[1]{ [] }, cm[2]{ [] } ],
>                                false );
<2x0-matrix over GF(3)>
gap> GEN_MAT_HAS_CANONICAL_ROWS( M );
true

# immutable plain rows
gap> M:= MakeIsGenericMatrixRep( GF(9), 2, Immutable( rows ), false );;
gap> GEN_MAT_HAS_CANONICAL_ROWS( M );
true
gap> IsMutable( M );
false

# rows that cannot be compressed are rejected also without the checks
gap> MakeIsGenericMatrixRep( GF(3), 1, [ [ Z(9) ] ], false );
Error, ConvertToVectorRepNC: Vector cannot be written over GF(3)
gap> MakeIsGenericMatrixRep( GF(3), 1, [ [ 1 ] ], false );
Error, the rows of <list> must have length <ncols> and entries in <basedomain>
gap> MakeIsGenericMatrixRep( GF(3), 2, [ [ Z(3), Z(3) ], [ Z(3) ] ], false );
Error, the rows of <list> must have length <ncols> and entries in <basedomain>

#
# entries and scalars outside the base domain do not change the matrix,
# also without the checks
#
gap> M:= Matrix( IsGenericMatrixRep, GF(9), rows );;
gap> M[1,1]:= Z(81);
Error, <val> must lie in the base domain of <M>
gap> M[1,1]:= 1;
Error, <val> must lie in the base domain of <M>
gap> SetMatElm( M, 1, 1, Z(81) : check:= false );
Error, Cannot convert a locked vector compressed over GF(9) to GF(81)
gap> SetMatElm( M, 1, 1, 1 : check:= false );
Error, Attempt to convert locked compressed vector to plain list
gap> SetMatElm( M, 3, 1, Z(9) : check:= false );
Error, row index 3 exceeds 2, the number of rows
gap> SetMatElm( M, 1, 3, Z(9) : check:= false );
Error, column index 3 exceeds 2, the number of columns
gap> M[3,1];
Error, row index 3 exceeds 2, the number of rows
gap> M[1,3];
Error, column index 3 exceeds 2, the number of columns
gap> MultMatrixRowLeft( M, 1, Z(81) );
Error, <scalar> must lie in the base domain of <mat>
gap> MultMatrixRowLeft( M, 1, Z(81) : check:= false );
Error, Cannot convert a locked vector compressed over GF(9) to GF(81)
gap> AddMatrixRowsRight( M, 1, 2, Z(81) : check:= false );
Error, Cannot convert a locked vector compressed over GF(9) to GF(81)
gap> MultMatrixColumnRight( M, 2, Z(81) : check:= false );
Error, Cannot convert a locked vector compressed over GF(9) to GF(81)
gap> AddMatrixColumnsLeft( M, 1, 2, Z(81) : check:= false );
Error, Cannot convert a locked vector compressed over GF(9) to GF(81)
gap> N:= ZeroMatrix( 2, 2, M );;
gap> CopySubMatrix( M, N, [ 1 ], [ 1 ], [ 1, 2 ], [ 2, 3 ] );
Error, List assignment would increase length of locked compressed vector
gap> CopySubMatrix( Matrix( IsGenericMatrixRep, GF(81), [ [ Z(81) ] ] ), M,
>                   [ 1 ], [ 1 ], [ 1 ], [ 1 ] : check:= false );
Error, Cannot convert a locked vector compressed over GF(9) to GF(81)
gap> Unpack( M ) = rows and GEN_MAT_HAS_CANONICAL_ROWS( M );
true
gap> GEN_MAT_HAS_CANONICAL_ROWS( N );
true
gap> M:= Matrix( IsGenericMatrixRep, GF(2), [ [ Z(2), 0*Z(2) ] ] );;
gap> M[1,1]:= Z(4);
Error, <val> must lie in the base domain of <M>
gap> SetMatElm( M, 1, 1, Z(4) : check:= false );
Error, SET_MAT_ELM_GF2MAT: assigned element must be a GF(2) element (not an ff\
e)
gap> SetMatElm( M, 1, 1, 1 : check:= false );
Error, SET_MAT_ELM_GF2MAT: assigned element must be a GF(2) element (not the i\
nteger 1)
gap> MultMatrixRowLeft( M, 1, Z(4) : check:= false );
Error, Cannot convert a locked vector compressed over GF(2) to GF(4)
gap> AddMatrixColumnsRight( M, 2, 1, Z(4) : check:= false );
Error, SET_MAT_ELM_GF2MAT: assigned element must be a GF(2) element (not an ff\
e)
gap> Unpack( M );
[ [ Z(2)^0, 0*Z(2) ] ]
gap> GEN_MAT_HAS_CANONICAL_ROWS( M );
true

# elements of the base domain need not be internal FFEs
gap> z:= ZmodnZObj( FamilyObj( Z(7) ), 3 );;
gap> IsInternalRep( z );
false
gap> M:= Matrix( IsGenericMatrixRep, GF(7), [ [ z, 0*z ], [ z^0, z ] ] );;
gap> M[1,2]:= z^2;;
gap> MultMatrixRowLeft( M, 2, z );
gap> AddMatrixColumnsRight( M, 1, 2, z );
gap> N:= z * M / z + M * z;;
gap> Unpack( N );
[ [ Z(7)^0, Z(7)^0 ], [ Z(7)^0, Z(7)^0 ] ]
gap> GEN_MAT_HAS_CANONICAL_ROWS( M ) and GEN_MAT_HAS_CANONICAL_ROWS( N );
true

# scalars outside the base domain are left to the generic methods
gap> M:= Matrix( IsGenericMatrixRep, GF(3), [ [ Z(3), 0*Z(3) ] ] );;
gap> Z(9) * M;
Error, the elements in <list> must lie in <basedomain>
gap> M * Z(9);
Error, the elements in <list> must lie in <basedomain>
gap> M / Z(9);
Error, the elements in <list> must lie in <basedomain>
gap> Unpack( Z(9) * Zero( M ) );
[ [ 0*Z(3), 0*Z(3) ] ]
gap> Unpack( M * (1/2) );
[ [ Z(3)^0, 0*Z(3) ] ]

#
# 'MakeImmutable' for a matrix in 'IsGF2MatrixRep' reaches all rows
#
gap> cm:= IdentityMat( 3, GF(2) );;  ConvertToMatrixRep( cm, 2 );;
gap> MakeImmutable( cm );;
gap> ForAny( cm, IsMutable );
false

#
gap> STOP_TEST( "matobjgeneric-compressed.tst" );
