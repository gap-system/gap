#@local l, mats, M, v
gap> START_TEST( "RowOfMatrix.tst" );

#
gap> l := Z(5)^0 * [ [ 1, 2, 0 ], [ 3, 4, 1 ] ];;
gap> mats := [ l, ImmutableMatrix( GF(5), l ), MutableCopyMat( l ),
>     ImmutableMatrix( GF(2), Z(2) * [ [ 1, 0, 1 ], [ 0, 1, 1 ] ] ),
>     Matrix( IsPlistMatrixRep, GF(5), l ),
>     Matrix( IsGenericMatrixRep, GF(5), l ),
>     Immutable( Matrix( IsGenericMatrixRep, GF(5), l ) ),
>     Matrix( IsZmodnZMatrixRep, Integers mod 6, [ [ 1, 2, 0 ], [ 3, 4, 1 ] ] ),
>     Matrix( Integers, [ [ 1, 2, 0 ], [ 3, 4, 1 ] ] ) ];;

# a mutable copy of the row, fitting to M; changing it leaves M alone
gap> ForAll( mats, function( M )
>      local v, i, old;
>      for i in [ 1 .. NrRows( M ) ] do
>        v := RowOfMatrix( M, i );
>        if not ( CompatibleVectorFilter( M )( v ) and IsMutable( v ) and
>                 Unpack( v ) = Unpack( M )[i] ) then
>          return false;
>        fi;
>        old := Unpack( M );
>        v[1] := v[1] + OneOfBaseDomain( M );
>        if Unpack( M ) <> old then
>          return false;
>        fi;
>      od;
>      return true;
>    end );
true

# no row access needed
gap> M := mats[6];;
gap> M[1];
Error, row access unsupported; use M[i,j], RowOfMatrix(M,i) or RowsOfMatrix(M)
gap> RowOfMatrix( M, 2 );
<plist vector over GF(5) of length 3>

# empty rows
gap> RowOfMatrix( Matrix( IsGenericMatrixRep, GF(5), [ [], [] ], 0 ), 2 );
<plist vector over GF(5) of length 0>

# row number out of range
gap> RowOfMatrix( M, 3 );
Error, RowOfMatrix: <i> must be at most NrRows( <M> ) = 2
gap> RowOfMatrix( l, 3 );
Error, RowOfMatrix: <i> must be at most NrRows( <M> ) = 2

#
gap> STOP_TEST( "RowOfMatrix.tst" );
