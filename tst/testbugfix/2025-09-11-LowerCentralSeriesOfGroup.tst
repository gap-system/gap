#@local D,G
# Fix a bug in LowerCentralSeriesOfGroup for trivial groups
# See https://github.com/gap-system/gap/issues/6108
gap> D:=Group(());;
gap> LowerCentralSeriesOfGroup( D );
[ Group(()) ]
gap> NilpotencyClassOfGroup(D);
0

# See https://github.com/gap-system/gap/issues/6111
gap> G:= TrivialGroup( IsFpGroup );;
gap> LowerCentralSeriesOfGroup( G ) = [ G ];
true
gap> G:= Image( IsomorphismFpGroup( Group( () ) ) );;
gap> LowerCentralSeriesOfGroup( G ) = [ G ];
true
gap> G:= TrivialSubgroup( FreeGroup( 1 ) );;
gap> LowerCentralSeriesOfGroup( G ) = [ G ];
true
