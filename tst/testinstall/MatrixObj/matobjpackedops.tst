#@local F, M, N, M5, M7, v, w, u, x, l, rs, A, B, P, L, R, z, t
gap> START_TEST( "matobjpackedops.tst" );
gap> ReadGapRoot( "tst/testinstall/MatrixObj/testpacked.g" );
gap> ReadGapRoot( "tst/testinstall/MatrixObj/testpackedops.g" );

#
# Arithmetic, rows, columns, sub-matrices and products against
# IsGenericMatrixRep, IsPlistVectorRep and plain lists
#
gap> PackedOpsRing( GF(2), 1 );
true
gap> PackedOpsRing( GF(3), 1 );
true
gap> PackedOpsRing( GF(7), 1 );
true
gap> PackedOpsRing( GF(7), 2 : uniform );
true
gap> PackedOpsRing( GF(257), 1 );
true
gap> PackedOpsRing( GF(65521), 1 );
true
gap> PackedOpsRing( GF(NextPrimeInt(2^61)), 1 );
true
gap> PackedOpsRing( GF(NextPrimeInt(2^63)), 1 );
true
gap> PackedOpsRing( Integers mod 6, 1 );
true
gap> PackedOpsRing( Integers mod (2^64 - 1), 1 );
true

#
# Results are immutable iff all operands are
#
gap> F := GF(7);;
gap> M := Matrix( IsPackedMatrixRep, F, [ [ 1, 2 ], [ 3, 4 ] ] * Z(7)^0 );;
gap> v := Vector( IsPackedVectorRep, F, [ 1, 2 ] * Z(7)^0 );;
gap> List( [ M + M, M + Immutable( M ), Immutable( M ) * Immutable( M ),
>            Z(7) * Immutable( M ), -Immutable( M ), Immutable( v ) * M,
>            Immutable( M ) * Immutable( v ), 2 * Immutable( v ),
>            KroneckerProduct( Immutable( M ), Immutable( M ) ) ],
>      IsMutable );
[ true, true, false, false, false, true, false, false, false ]
gap> List( [ ExtractSubMatrix( Immutable( M ), [ 1 ], [ 1 ] ),
>            Immutable( v ){ [ 1 ] }, TransposedMatMutable( Immutable( M ) ),
>            ShallowCopy( Immutable( v ) ), ZeroMutable( Immutable( M ) ),
>            PACKMAT_ROW( Immutable( M ), 1 ) ], IsMutable );
[ true, true, true, true, true, true ]
gap> List( [ TransposedMat( M ), RowsOfMatrix( M ), RowsOfMatrix( M )[1] ],
>      IsMutable );
[ false, false, false ]

#
# Scalars are integers or elements of the base domain. Other factors of *
# go to the next method.
#
gap> Unpack( 9 * v ) = Unpack( 2 * v ) and Unpack( v * -1 ) = -Unpack( v );
true
gap> Unpack( ( 2^70 + 1 ) * v ) = ( 2^70 + 1 ) * Unpack( v );
true
gap> Unpack( Z(7^2)^8 * v ) = Z(7) * Unpack( v );
true
gap> M5 := Matrix( IsPackedMatrixRep, GF(5), [ [ 1, 2 ], [ 3, 4 ] ] * Z(5)^0 );;
gap> Z(5) * M;
Error, <x> and <y> have different characteristic
gap> M * (1/2);
<2x2 packed matrix over GF(7)>
gap> AddMatrix( ShallowCopy( M ), M, Z(5) );
Error, AddMatrix: <s> must be an integer or lie in the base domain
gap> MultMatrixRow( ShallowCopy( M ), 1, Z(49) );
Error, MultMatrixRow: <s> must be an integer or lie in the base domain
gap> MultVector( ShallowCopy( v ), [ 1 ] );
Error, MultVector: <s> must be an integer or lie in the base domain
gap> MultVector( ShallowCopy( v ), IdentityMatrix( IsGenericMatrixRep, F, 1 ) );
Error, MultVector: <s> must be an integer or lie in the base domain
gap> M * IdentityMatrix( IsGenericMatrixRep, F, 2 );
Error, <matobj> * <mat> is not defined
gap> M * IdentityMat( 2, F );
Error, <matobj> * <mat> is not defined
gap> R := Integers mod 6;;
gap> u := Vector( IsPackedVectorRep, R, [ 1, 2, 3 ] * One( R ) );;
gap> Unpack( u * ZmodnZObj( 5, 6 ) ) = Unpack( u ) * 5;
true
gap> u * ZmodnZObj( 1, 4 );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `*' on 2 arguments

#
# Dimensions, base domains and indices are checked
#
gap> N := Matrix( IsPackedMatrixRep, F, [ [ 1, 2, 3 ] ] * Z(7)^0 );;
gap> M7 := Matrix( IsPackedMatrixRep, Integers mod 7, [ [ 1, 2 ], [ 3, 4 ] ]
>                  * ZmodnZObj( 1, 7 ) );;
gap> w := Vector( IsPackedVectorRep, F, [ 1, 2, 3 ] * Z(7)^0 );;
gap> M + N;
Error, +: <a> and <b> must have the same dimensions
gap> M + M5;
Error, +: the arguments must have the same base domain
gap> M + M7;
Error, +: the arguments must have the same base domain
gap> M - v;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `+' on 2 arguments
gap> PACKMAT_SUM( M, v );
Error, +: <a> and <b> must both be matrices or both vectors
gap> PACKMAT_SUM( 1, v );
Error, +: <a> must be a packed matrix or vector (not the integer 1)
gap> v + w;
Error, +: <a> and <b> must have the same length
gap> M * N;
Error, *: <a> must have as many columns as <b> has rows
gap> N * M;
Error, *: <a> must have as many columns as <b> has rows
gap> v * N;
Error, *: the length of <v> must be the number of rows of <M>
gap> M * w;
Error, *: the length of <v> must be the number of columns of <M>
gap> M * M5;
Error, *: the arguments must have the same base domain
gap> M * Vector( IsPackedVectorRep, GF(5), [ 1, 1 ] * Z(5) );
Error, *: the arguments must have the same base domain
gap> KroneckerProduct( M, M5 );
Error, KroneckerProduct: the arguments must have the same base domain
gap> z := ZeroMatrix( IsPackedMatrixRep, GF(2), 2^16, 1 );;
gap> KroneckerProduct( z, z );
Error, KroneckerProduct: the result has too many rows or columns
gap> KroneckerProduct( TransposedMat( z ), TransposedMat( z ) );
Error, KroneckerProduct: the result has too many rows or columns
#@if GAPInfo.BytesPerVariable = 4
gap> z := ZeroMatrix( IsPackedMatrixRep, GF(2), 2^14, 1 );;
gap> KroneckerProduct( z, z );
Error, KroneckerProduct: the result has too many rows or columns
#@fi
gap> AddMatrix( ShallowCopy( M ), N );
Error, AddMatrix: <a> and <b> must have the same dimensions
gap> AddMatrix( ShallowCopy( M ), M5 );
Error, AddMatrix: the arguments must have the same base domain
gap> AddMatrix( Immutable( M ), M );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `AddMatrix' on 2 arguments
gap> AddVector( v, w );
Error, AddVector: <dst> and <src> must have the same length
gap> AddVector( v, Vector( IsPackedVectorRep, GF(5), [ 1, 1 ] * Z(5) ) );
Error, AddVector: the arguments must have the same base domain
gap> AddVector( v, v, 1, 1, 3 );
Error, AddVector: [<from>..<to>] must lie in [1..Length(<v>)]
gap> AddVector( v, v, 1, 0, 1 );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `AddVector' on 5 arguments
gap> AddVector( v, v, 1, 3, 2 );
gap> MultVector( v, Z(7), 0, 2 );
Error, MultVector: [<from>..<to>] must lie in [1..Length(<v>)]
gap> MultVector( v, Z(7), 3, 2 );
gap> ScalarProduct( v, w );
Error, ScalarProduct: <a> and <b> must have the same length
gap> DistanceOfVectors( v, w );
Error, DistanceOfVectors: <a> and <b> must have the same length
gap> PACKMAT_ADD_VECTOR( Immutable( v ), v );
Error, AddVector: <dst> must be a mutable vector (not a data object)
gap> PACKMAT_MULT_VECTOR( Immutable( v ), 1 );
Error, MultVector: <v> must be a mutable vector (not a data object)
gap> SwapMatrixRows( M, 1, 3 );
Error, SwapMatrixRows: <j> must be in [1..NrRows(<M>)] (not the integer 3)
gap> SwapMatrixColumns( M, 0, 1 );
Error, SwapMatrixColumns: <i> must be in [1..NrCols(<M>)] (not the integer 0)
gap> PACKMAT_SWAP_ROWS( Immutable( M ), 1, 2 );
Error, SwapMatrixRows: <M> must be a mutable matrix (not a data object)
gap> MultMatrixRow( M, 3, 2 );
Error, MultMatrixRow: <i> must be in [1..NrRows(<M>)] (not the integer 3)
gap> MultMatrixColumn( M, 1, Z(5) );
Error, MultMatrixColumn: <s> must be an integer or lie in the base domain
gap> AddMatrixRows( M, 1, 3, 2 );
Error, AddMatrixRows: <j> must be in [1..NrRows(<M>)] (not the integer 3)
gap> AddMatrixColumns( M, 1, 3, 2 );
Error, AddMatrixColumns: <j> must be in [1..NrCols(<M>)] (not the integer 3)
gap> PositionNonZeroInRow( M, 3 );
Error, PositionNonZeroInRow: <i> must be in [1..NrRows(<M>)] (not the integer \
3)
gap> PositionNonZeroInRow( M, 1, "a" );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `PositionNonZeroInRow' on 3 arguments
gap> PositionNonZero( v, "a" );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `PositionNonZero' on 2 arguments
gap> ExtractSubMatrix( M, [ 1, 3 ], [ 1 ] );
Error, ExtractSubMatrix: <rows> must be a list of positions of rows (not a pla\
in list of cyclotomics)
gap> ExtractSubMatrix( M, [ 1 ], [ 0 ] );
Error, ExtractSubMatrix: <cols> must be a list of positions of columns (not a \
strictly-sorted plain list of cyclotomics)
gap> ExtractSubMatrix( M, [ 1 ], [ 2 .. 3 ] );
Error, ExtractSubMatrix: <cols> must be a list of positions of columns (not a \
list (range,ssort))
gap> ExtractSubMatrix( M, [ 1 ], 1 );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ExtractSubMatrix' on 3 arguments
gap> CopySubMatrix( M, M5, [ 1 ], [ 1 ], [ 1 ], [ 1 ] );
Error, CopySubMatrix: <src> and <dst> must have the same base domain
gap> CopySubMatrix( M, ShallowCopy( M ), [ 1 ], [ 1, 2 ], [ 1 ], [ 1 ] );
Error, source and destination row lists must be of equal length
gap> CopySubMatrix( M, ShallowCopy( M ), [ 1 ], [ 1 ], [ 1, 2 ], [ 1 ] );
Error, source and destination column lists must be of equal length
gap> CopySubMatrix( M, ShallowCopy( M ), [ 1 ], [ 3 ], [ 1 ], [ 1 ] );
Error, CopySubMatrix: <drows> must be a list of positions of rows (not a stric\
tly-sorted plain list of cyclotomics)
gap> CopySubVector( v, w, [ 1, 2 ], [ 1 ] );
Error, CopySubVector: <scols> and <dcols> must have the same length
gap> CopySubVector( v, w, [ 3 ], [ 1 ] );
Error, CopySubVector: <scols> must be a list of positions in [1..Length] (not \
a strictly-sorted plain list of cyclotomics)
gap> CopySubVector( v, Vector( IsPackedVectorRep, GF(5), [ 1 ] * Z(5) ), [ 1 ], [ 1 ] );
Error, CopySubVector: <src> and <dst> must have the same base domain
gap> v{ [ 1, 3 ] };
Error, ExtractSubVector: <l> must be a list of positions in [1..Length] (not a\
 plain list of cyclotomics)
gap> v{ [ 1,, 2 ] };
Error, List Elements: <poss> must be a dense list of positive integers
gap> v{ [ 2, 4 .. 6 ] };
Error, ExtractSubVector: <l> must be a list of positions in [1..Length] (not a\
 list (range,ssort))
gap> v{ [ 2, 4 .. 2 * 10^8 ] };
Error, ExtractSubVector: <l> must be a list of positions in [1..Length] (not a\
 list (range,ssort))
gap> ExtractSubVector( v, [ 3, 1 .. -1 ] );
Error, ExtractSubVector: <l> must be a list of positions in [1..Length] (not a\
 list (range,nsort))
gap> PACKMAT_ROW( M, 3 );
Error, RowOfMatrix: <i> must be in [1..NrRows(<M>)] (not the integer 3)
gap> NormedRowVector( Vector( IsPackedVectorRep, R, [ 0, 2, 1 ] * One( R ) ) );
Error, NormedRowVector: the first nonzero entry of <v> must be invertible
gap> Unpack( NormedRowVector( Vector( IsPackedVectorRep, R, [ 0, 5, 1 ] * One( R ) ) ) );
[ ZmodnZObj( 0, 6 ), ZmodnZObj( 1, 6 ), ZmodnZObj( 5, 6 ) ]
gap> Randomize( Immutable( M ) );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Randomize' on 1 arguments
gap> PACKMAT_SET_RANDOM( ShallowCopy( M ), [ 7^4 ], 4 );
Error, PACKMAT_SET_RANDOM: <list> must contain integers in [0..n^<k>-1]
gap> PACKMAT_SET_RANDOM( ShallowCopy( M ), [ 1, 2 ], 4 );
Error, PACKMAT_SET_RANDOM: <list> has the wrong length

#
# Index lists: ranges with step 1 are core ranges, other lists are
# converted; repeated destinations keep the last write
#
gap> M := Matrix( IsPackedMatrixRep, F, List( [ 1 .. 4 ], i -> List( [ 1 .. 5 ],
>                 j -> ( 5 * i + j ) * Z(7)^0 ) ) );;
gap> Unpack( ExtractSubMatrix( M, [ 4, 2 .. 2 ], [ 5, 3 .. 1 ] ) )
>  = Unpack( M ){ [ 4, 2 ] }{ [ 5, 3, 1 ] };
true
gap> A := ZeroMatrix( 2, 3, M );;
gap> CopySubMatrix( M, A, [ 1, 2 ], [ 1, 1 ], [ 1 .. 3 ], [ 3, 2, 1 ] );
gap> Unpack( A ) = [ Reversed( Unpack( M )[2]{ [ 1 .. 3 ] } ), [ 0, 0, 0 ] * Z(7) ];
true
gap> x := Vector( IsPackedVectorRep, F, [ 1 .. 6 ] * Z(7)^0 );;
gap> Unpack( x{ [ 6, 4 .. 2 ] } ) = [ 6, 4, 2 ] * Z(7)^0;
true

#
# Copies within one object: overlapping cells are read before they change
#
gap> x := Vector( IsPackedVectorRep, GF(2), List( [ 1 .. 70 ], i -> Z(2)^( i mod 3 ) ) );;
gap> l := Unpack( x );;
gap> CopySubVector( x, x, [ 1 .. 69 ], [ 2 .. 70 ] );
gap> Unpack( x ) = Concatenation( [ l[1] ], l{ [ 1 .. 69 ] } );
true
gap> CopySubVector( x, x, [ 70, 69 .. 1 ], [ 1 .. 70 ] );
gap> Unpack( x ) = Reversed( Concatenation( [ l[1] ], l{ [ 1 .. 69 ] } ) );
true
gap> B := Matrix( IsPackedMatrixRep, GF(2), List( [ 1 .. 5 ], i -> List( [ 1 .. 7 ],
>                 j -> Z(2)^( i + j ) * ( ( i * j ) mod 2 ) ) ) );;
gap> L := Unpack( B );;
gap> CopySubMatrix( B, B, [ 1 .. 4 ], [ 2 .. 5 ], [ 1 .. 6 ], [ 2 .. 7 ] );
gap> L{ [ 2 .. 5 ] }{ [ 2 .. 7 ] } := List( L{ [ 1 .. 4 ] }, r -> r{ [ 1 .. 6 ] } );;
gap> Unpack( B ) = L;
true
gap> CopySubMatrix( B, B, [ 1 .. 2 ], [ 4 .. 5 ], [ 1 .. 3 ], [ 5 .. 7 ] );
gap> L{ [ 4 .. 5 ] }{ [ 5 .. 7 ] } := List( L{ [ 1 .. 2 ] }, r -> r{ [ 1 .. 3 ] } );;
gap> Unpack( B ) = L;
true
gap> P := ShallowCopy( B );;
gap> AddMatrix( P, P );
gap> IsZero( P );
true

#
# Index lists and scalars may run GAP code that collects garbage
#
gap> M := Matrix( IsPackedMatrixRep, GF(NextPrimeInt(2^63)),
>                 [ [ 1, 2, 3 ], [ 4, 5, 6 ] ] * One( GF(NextPrimeInt(2^63)) ) );;
gap> l := EnumeratorByFunctions( Integers, rec(
>      ElementNumber := function( e, i ) GASMAN( "partial" ); return 4 - i; end,
>      NumberElement := { e, x } -> 4 - x,
>      Length := e -> 3 ) );;
gap> Unpack( ExtractSubMatrix( M, [ 2, 1 ], l ) ) = Unpack( M ){ [ 2, 1 ] }{ [ 3, 2, 1 ] };
true
gap> A := ShallowCopy( M );;
gap> CopySubMatrix( M, A, [ 1, 2 ], [ 2, 1 ], l, l );
gap> Unpack( A ) = Unpack( M ){ [ 2, 1 ] };
true

#
# RowOfMatrix (not yet an operation): a mutable copy of one row
#
gap> M := Matrix( IsPackedMatrixRep, GF(2), [ [ 1, 0, 1 ], [ 0, 1, 1 ] ] * Z(2) );;
gap> x := PACKMAT_ROW( M, 2 );;
gap> Unpack( x ) = Unpack( M )[2] and IsMutable( x );
true
gap> x[1] := Z(2);; M[2,1];
0*Z(2)

#
# Randomize draws through the random source
#
gap> rs := RandomSource( IsMersenneTwister, 42 );;
gap> A := ZeroMatrix( IsPackedMatrixRep, GF(2), 3, 70 );;
gap> IsIdenticalObj( Randomize( rs, A ), A ) and not IsZero( A );
true
gap> B := ZeroMatrix( IsPackedMatrixRep, GF(2), 3, 70 );;
gap> Randomize( RandomSource( IsMersenneTwister, 42 ), B ) = A;
true
gap> v := ZeroVector( IsPackedVectorRep, GF(NextPrimeInt(2^63)), 20 );;
gap> Randomize( rs, v );;
gap> ForAll( Unpack( v ), x -> x in GF(NextPrimeInt(2^63)) ) and WeightOfVector( v ) = 20;
true
gap> t := List( [ 1 .. 1000 ], i -> Unpack( Randomize( rs,
>               ZeroVector( IsPackedVectorRep, Integers mod 6, 1 ) ) )[1] );;
gap> Set( t ) = AsSSortedList( Integers mod 6 );
true

#
# Methods are the kernel functions. The elementary row and column
# operations, PositionNonZeroInRow, AddMatrix and MultMatrix* first try an
# early method for plain lists.
#
gap> M := Matrix( IsPackedMatrixRep, GF(7), [ [ 1, 2 ], [ 3, 4 ] ] * Z(7)^0 );;
gap> v := Vector( IsPackedVectorRep, GF(7), [ 1, 2 ] * Z(7)^0 );;
gap> ForAll( [ [ \+, M, M ], [ \*, M, M ], [ \*, v, M ], [ \*, M, v ],
>              [ \*, Z(7), M ], [ \*, M, 2 ], [ \*, v, v ], [ \^, v, M ],
>              [ AdditiveInverseSameMutability, M ], [ PositionNonZero, v ],
>              [ PositionNonZero, v, 1 ], [ AddVector, v, v, Z(7) ],
>              [ AddRowVector, v, v, Z(7) ], [ MultVector, v, 2 ],
>              [ SwapMatrixRows, M, 1, 2 ], [ SwapMatrixColumns, M, 1, 2 ],
>              [ ExtractSubMatrix, M, [ 1 ], [ 1 ] ], [ \{\}, v, [ 1 ] ],
>              [ RowsOfMatrix, M ], [ TransposedMat, M ] ],
>          a -> IsKernelFunction( ApplicableMethod( a[1], a{ [ 2 .. Length( a ) ] } ) ) );
true
gap> IsKernelFunction( ApplicableMethod( AddMatrixRows, [ M, 1, 2, 1 ], 0, 2 ) );
true

#
gap> STOP_TEST( "matobjpackedops.tst" );
