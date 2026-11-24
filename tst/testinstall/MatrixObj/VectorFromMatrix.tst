#@local mats, M, l, v, w
gap> START_TEST( "VectorFromMatrix.tst" );

#
gap> l := Z(5)^0 * [ [ 1, 2, 0 ], [ 3, 4, 1 ] ];;
gap> mats := [ l, ImmutableMatrix( GF(5), l ),
>     ImmutableMatrix( GF(2), Z(2) * [ [ 1, 0, 1 ], [ 0, 1, 1 ] ] ),
>     ImmutableMatrix( GF(4), Z(4) * [ [ 1, 0, 1 ], [ 0, 1, 1 ] ] ),
>     Matrix( IsPlistMatrixRep, GF(5), l ),
>     Matrix( IsGenericMatrixRep, GF(5), l ),
>     Matrix( IsZmodnZMatrixRep, Integers mod 6, [ [ 1, 2, 0 ], [ 3, 4, 1 ] ] ),
>     Matrix( Integers, [ [ 1, 2, 0 ], [ 3, 4, 1 ] ] ) ];;

# 'Vector( list, M )' has the given entries, fits to M, and can be
# multiplied with M
gap> ForAll( mats, function( M )
>      local c, v;
>      c := [ 1, 0 ] * OneOfBaseDomain( M );
>      v := Vector( c, M );
>      return CompatibleVectorFilter( M )( v ) and
>             Unpack( v ) = c and IsMutable( v ) and
>             Unpack( v * M ) = Unpack( M )[1];
>    end );
true

# the result is immutable iff the list is
gap> ForAll( mats, M -> not IsMutable( Vector(
>      Immutable( [ 1, 1 ] * OneOfBaseDomain( M ) ), M ) ) );
true

# compressed input
gap> M := mats[2];;
gap> w := ImmutableVector( GF(5), Z(5)^0 * [ 1, 2 ] );;
gap> v := Vector( w, M );;
gap> Is8BitVectorRep( v ) and v = w and not IsMutable( v );
true
gap> v := Vector( ShallowCopy( w ), M );;
gap> IsMutable( v );
true

# a vector object as input
gap> w := Vector( IsPlistVectorRep, GF(5), Z(5)^0 * [ 1, 2 ] );;
gap> v := Vector( w, mats[2] );;
gap> Is8BitVectorRep( v ) and Unpack( v ) = Unpack( w ) and IsMutable( v );
true
gap> v := Vector( Immutable( w ), mats[6] );;
gap> IsPlistVectorRep( v ) and not IsMutable( v );
true

#
gap> STOP_TEST( "VectorFromMatrix.tst" );
