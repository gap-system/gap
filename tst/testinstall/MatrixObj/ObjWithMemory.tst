#@local F, gens, groups, mem, queries, H, g, s, v, x, mats, orig
gap> START_TEST( "ObjWithMemory.tst" );

# group elements with memory around plist, generic and compressed matrices
gap> F:= GF(3);;
gap> gens:= GeneratorsOfGroup( GL( 3, F ) );;
gap> groups:= [ Group( List( gens, x -> Matrix( IsPlistMatrixRep, F, x ) ) ),
>               Group( List( gens, x -> Matrix( IsGenericMatrixRep, F, x ) ) ),
>               Group( gens ) ];;
gap> mem:= List( groups, GroupWithMemory );;
gap> ForAll( mem, H -> ForAll( GeneratorsOfGroup( H ), IsObjWithMemory ) );
true
gap> mem:= List( mem, H -> H.1 * H.2 );;
gap> ForAll( mem, IsObjWithMemory );
true

# read-only queries answer like the wrapped matrix, without memory
gap> queries:= [ BaseDomain, NumberRows, NumberColumns, DimensionsMat,
>      ConstructingFilter, CompatibleVectorFilter, Unpack, RowsOfMatrix,
>      MutableCopyMatrix, IsRowListMatrix,
>      M -> M[ 2, 3 ],
>      M -> ExtractSubMatrix( M, [ 1, 3 ], [ 2, 3 ] ),
>      M -> PositionNonZeroInRow( M, 2 ),
>      M -> PositionNonZeroInRow( M, 2, 1 ),
>      M -> ZeroVector( 3, M ),
>      M -> Matrix( [ [ 1, 2, 0 ] ] * One( F ), M ) ];;
gap> List( mem, g -> Filtered( [ 1 .. Length( queries ) ],
>      i -> queries[i]( g ) <> queries[i]( StripMemory( g ) ) or
>           IsObjWithMemory( queries[i]( g ) ) ) );
[ [  ], [  ], [  ] ]
gap> ForAll( mem, g -> IsMutable( MutableCopyMatrix( g ) ) );
true
gap> ForAll( mem, g -> not ForAny( RowsOfMatrix( g ), IsObjWithMemory ) );
true

# the natural action on row vectors
gap> ForAll( mem, function( g )
>      local s, v;
>      s:= StripMemory( g );
>      v:= RowsOfMatrix( s )[1];
>      return v * g = v * s;
>    end );
true

# row access exactly when the wrapped matrix has it
gap> List( mem, IsRowListMatrix );
[ true, false, true ]
gap> queries:= [ M -> M[2], M -> IsBound( M[2] ), M -> IsBound( M[4] ),
>      M -> M{ [ 1, 3 ] }, List, M -> List( M, PositionNonZero ) ];;
gap> List( mem{ [ 1, 3 ] }, g -> Filtered( [ 1 .. Length( queries ) ],
>      i -> queries[i]( g ) <> queries[i]( StripMemory( g ) ) or
>           IsObjWithMemory( queries[i]( g ) ) ) );
[ [  ], [  ] ]

# mutation is an error
gap> g:= mem[1];; s:= StripMemory( g );; v:= RowsOfMatrix( s )[1];;
gap> x:= MutableCopyMatrix( s );;
gap> g[1]:= v;
Error, objects with memory cannot be changed
gap> g[1,1]:= Z(3);
Error, Matrix Assignment: <mat> must be a mutable matrix (not a component obje\
ct)
gap> g{ [ 1 ] }:= [ v ];
Error, objects with memory cannot be changed
gap> Unbind( g[1] );
Error, objects with memory cannot be changed
gap> Add( g, v );
Error, objects with memory cannot be changed
gap> Add( g, v, 1 );
Error, objects with memory cannot be changed
gap> Remove( g );
Error, objects with memory cannot be changed
gap> Remove( g, 1 );
Error, objects with memory cannot be changed
gap> Append( g, x );
Error, objects with memory cannot be changed
gap> Randomize( g );
Error, objects with memory cannot be changed
gap> Randomize( g, GlobalMersenneTwister );
Error, objects with memory cannot be changed
gap> Randomize( GlobalMersenneTwister, g );
Error, objects with memory cannot be changed
gap> MultMatrixRowLeft( g, 1, Z(3) );
Error, objects with memory cannot be changed
gap> MultMatrixRowRight( g, 1, Z(3) );
Error, objects with memory cannot be changed
gap> MultMatrixColumnLeft( g, 1, Z(3) );
Error, objects with memory cannot be changed
gap> MultMatrixColumnRight( g, 1, Z(3) );
Error, objects with memory cannot be changed
gap> AddMatrixRowsLeft( g, 1, 2, Z(3) );
Error, objects with memory cannot be changed
gap> AddMatrixRowsRight( g, 1, 2, Z(3) );
Error, objects with memory cannot be changed
gap> AddMatrixColumnsLeft( g, 1, 2, Z(3) );
Error, objects with memory cannot be changed
gap> AddMatrixColumnsRight( g, 1, 2, Z(3) );
Error, objects with memory cannot be changed
gap> SwapMatrixRows( g, 1, 2 );
Error, objects with memory cannot be changed
gap> SwapMatrixColumns( g, 1, 2 );
Error, objects with memory cannot be changed
gap> CopySubMatrix( x, g, [ 1 ], [ 1 ], [ 1 ], [ 1 ] );
Error, objects with memory cannot be changed
gap> AddMatrix( g, x );
Error, objects with memory cannot be changed
gap> AddMatrix( g, x, Z(3) );
Error, objects with memory cannot be changed
gap> MultMatrixLeft( g, Z(3) );
Error, objects with memory cannot be changed
gap> MultMatrixRight( g, Z(3) );
Error, objects with memory cannot be changed
gap> SwapMatrixRows( mem[2], 1, 2 );
Error, objects with memory cannot be changed
gap> mem[3][1]:= RowsOfMatrix( StripMemory( mem[3] ) )[1];
Error, objects with memory cannot be changed
gap> SwapMatrixRows( mem[3], 1, 2 );
Error, objects with memory cannot be changed
gap> StripMemory( g ) = x;
true

# mutable wrapped matrix objects cannot be changed through the object with
# memory
gap> mats:= [ Matrix( IsPlistMatrixRep, F, IdentityMat( 3, F ) ),
>             Matrix( IsGenericMatrixRep, F, IdentityMat( 3, F ) ) ];;
gap> ForAll( mats, IsMutable );
true
gap> orig:= List( mats, MutableCopyMatrix );;
gap> mem:= GeneratorsWithMemory( mats );;
gap> g:= mem[1];;
gap> not IsMutable( g[1] ) and not ForAny( List( g{ [ 1 ] } ), IsMutable ) and
>    not ForAny( List( g ), IsMutable );
true
gap> g[1][1]:= 0 * Z(3);
Error, List Assignment: <list> must be a mutable list
gap> for g in mem do
>      Unpack( g )[1][1]:= 0 * Z(3);
>      MutableCopyMatrix( g )[1,1]:= 0 * Z(3);
>      ExtractSubMatrix( g, [ 1 ], [ 1 ] )[1,1]:= 0 * Z(3);
>    od;
gap> List( mem, StripMemory ) = orig;
true

# nor through the wrapped matrix, also for list matrices
gap> Add( mats, IdentityMat( 3, F ) );
gap> Add( mats, ImmutableMatrix( F, IdentityMat( 3, F ) ) );
gap> mats[4]:= MutableCopyMatrix( mats[4] );;
gap> orig:= List( mats, MutableCopyMatrix );;
gap> mem:= GeneratorsWithMemory( mats );;
gap> for x in mats do x[1,1]:= 0 * Z(3); od;
gap> List( mem, StripMemory ) = orig;
true
gap> ForAll( mem, g -> not IsMutable( StripMemory( g ) ) );
true
gap> mem[3][1][1]:= 0 * Z(3);
Error, The list you are trying to assign to is immutable
gap> mem[4][1][1]:= 0 * Z(3);
Error, The list you are trying to assign to is immutable

# groups of elements with memory
gap> H:= GroupWithMemory( groups[1] );;
gap> g:= H.1^2 * H.2;;
gap> s:= SLPOfElm( g );;
gap> ResultOfStraightLineProgram( s, GeneratorsOfGroup( groups[1] ) )
>    = StripMemory( g );
true
gap> IsObjWithMemory( One( H ) ) and IsOne( One( H ) );
true

#
gap> STOP_TEST( "ObjWithMemory.tst" );
