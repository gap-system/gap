#@local G, pair, mth, all, rks, tbl
gap> START_TEST("ctblsolv.tst");

##
gap> CharacterDegrees( SmallGroup( 256, 529 ) );
[ [ 1, 8 ], [ 2, 30 ], [ 4, 8 ] ]
gap> for pair in [ [ 18, 3 ], [ 27, 3 ], [ 36, 7 ], [ 50, 3 ], [ 54, 4 ] ] do
>      G:= SmallGroup( pair[1], pair[2] );
>      if CharacterDegrees( G, 0 )
>         <> Collected( List( Irr( G ), x -> x[1] ) ) then
>        Error( IdGroup( G ) );
>      fi;
>    od;

##
gap> mth:= [];;
gap> G:= AbelianGroup( [ 2, 3, 5 ] );;
gap> Add( mth, ApplicableMethod( CharacterDegrees, [ G ] ) );
gap> CharacterDegrees( G ) = [ [ 1, 30 ] ];
true
gap> G:= SmallGroup( 24, 12 );;  Irr( G );;
gap> Add( mth, ApplicableMethod( CharacterDegrees, [ G ] ) );
gap> CharacterDegrees( G ) = [ [ 1, 2 ], [ 2, 1 ], [ 3, 2 ] ];
true
gap> G:= SmallGroup( 24, 12 );;  CharacterTable( G );;
gap> Add( mth, ApplicableMethod( CharacterDegrees, [ G ] ) );
gap> CharacterDegrees( G ) = [ [ 1, 2 ], [ 2, 1 ], [ 3, 2 ] ];
true
gap> G:= GL( 2, 3 );;
gap> Add( mth, ApplicableMethod( CharacterDegrees, [ G ] ) );
gap> CharacterDegrees( G ) = [ [ 1, 2 ], [ 2, 3 ], [ 3, 2 ], [ 4, 1 ] ];
true
gap> G:= Group( [ [ E(3) ] ], [ [ E(4) ] ] );;
gap> Add( mth, ApplicableMethod( CharacterDegrees, [ G ] ) );
gap> CharacterDegrees( G ) = [ [ 1, 12 ] ];
true
gap> G:= SmallGroup( 24, 12 );;  # hier: auch überaufl.!!!
gap> Add( mth, ApplicableMethod( CharacterDegrees, [ G ] ) );
gap> CharacterDegrees( G ) = [ [ 1, 2 ], [ 2, 1 ], [ 3, 2 ] ];
true
gap> all:= MethodsOperation( CharacterDegrees, 1 );;
gap> rks:= Reversed( List( mth, f -> First( all, r -> r.func = f ).rank ) );;
gap> IsSSortedList( rks );
true
gap> G:= Group( (1,2), (3,4) );;
gap> ApplicableMethod( CharacterDegrees, [ G ] ) = Last( mth );
true
gap> CharacterDegrees( G ) = [ [ 1, 4 ] ];
true
gap> G:= Group( (1,2,3), (1,2) );;
gap> ApplicableMethod( CharacterDegrees, [ G ] ) = Last( mth );
true
gap> CharacterDegrees( G ) = [ [ 1, 2 ], [ 2, 1 ] ];
true
gap> G:= Group( (1,2,3,4), (1,2) );;
gap> ApplicableMethod( CharacterDegrees, [ G ] ) = Last( mth );
true
gap> CharacterDegrees( G ) = [ [ 1, 2 ], [ 2, 1 ], [ 3, 2 ] ];
true
gap> G:= Group( (1,2,3,4,5), (1,2) );;
gap> ApplicableMethod( CharacterDegrees, [ G ] ) = Last( mth );
true
gap> CharacterDegrees( G ) = [ [ 1, 2 ], [ 4, 2 ], [ 5, 2 ], [ 6, 1 ] ];
true

##
gap> G:= Group( (1,2,3,4,5), (1,2) );;
gap> CharacterDegrees( G, 0 ) = [ [ 1, 2 ], [ 4, 2 ], [ 5, 2 ], [ 6, 1 ] ];
true
gap> HasCharacterDegrees( G );
true
gap> G:= Group( (1,2,3,4,5), (1,2) );;
gap> CharacterDegrees( G, 7 ) = [ [ 1, 2 ], [ 4, 2 ], [ 5, 2 ], [ 6, 1 ] ];
true
gap> HasCharacterDegrees( G );
true
gap> CharacterDegrees( G, 4 );
Error, Assertion failure
gap> G:= Group( (1,2,3), (4,5) );;
gap> CharacterDegrees( G, 3 ) = [ [ 1, 2 ] ];
true
gap> G:= SymmetricGroup( 5 );;  CharacterTable( G ) mod 3;;
gap> CharacterDegrees( G, 3 ) = [ [ 1, 2 ], [ 4, 2 ], [ 6, 1 ] ];
true
gap> G:= SymmetricGroup( 4 );;
gap> CharacterDegrees( G, 3 ) = [ [ 1, 2 ], [ 3, 2 ] ];
true
gap> G:= SymmetricGroup( 5 );;
gap> CharacterDegrees( G, 3 ) = [ [ 1, 2 ], [ 4, 2 ], [ 6, 1 ] ];
true

##
gap> tbl:= CharacterTable( SymmetricGroup( 5 ) );;
gap> CharacterDegrees( tbl ) = [ [ 1, 2 ], [ 4, 2 ], [ 5, 2 ], [ 6, 1 ] ];
true
gap> CharacterDegrees( tbl mod 3 ) = [ [ 1, 2 ], [ 4, 2 ], [ 6, 1 ] ];
true

##
gap> STOP_TEST("ctblsolv.tst");
