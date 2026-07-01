#@local G, U, nice, gens
gap> START_TEST( "ggmbi.tst" );

# Test the situations where the global option 'Run_In_GGMBI' occurs.
# - Print warnings when the deprecated global variable is used.
#   (Do not use groups that are larger than their natural modules,
#   since they could be cached.)
gap> G:= Group( [ [ 0, -1 ], [ 1, 0 ] ] );;
gap> nice:= NiceMonomorphism( G );;
gap> RUN_IN_GGMBI:= true;;
gap> AsGroupGeneralMappingByImages( nice );;
#I  use the global option 'Run_In_GGMBI' not the global variable 'RUN_IN_GGMBI', see '?Run_In_GGMBI'
#I  use the global option 'Run_In_GGMBI' not the global variable 'RUN_IN_GGMBI', see '?Run_In_GGMBI'
gap> G:= Group( [ [ 0, -1 ], [ 1, 0 ] ] );;
gap> gens:= GeneratorsOfGroup( G );;
gap> IsHandledByNiceMonomorphism( G );
true
gap> GroupGeneralMappingByImagesNC( G, G, gens, gens );;
#I  use the global option 'Run_In_GGMBI' not the global variable 'RUN_IN_GGMBI', see '?Run_In_GGMBI'
gap> RUN_IN_GGMBI:= fail;;
`Run_In_GGMBI` (#6442))

# - Run some examples where the option gets set,
#   and where no other tests were available.
gap> G:= GL( IsPermGroup, 2, 5 );;
gap> U:= SL( IsPermGroup, 2, 5 );;
gap> Size( FittingFreeSubgroupSetup( G, U ).ker );
2

#
gap> G:= Image( IsomorphismPermGroup( SchurCover( AlternatingGroup( 6 ) ) ) );;
gap> Size( SylowViaRadical( G, 3 ) );
27

#
gap> G:= GL( IsPermGroup, 2, 5 );;
gap> Length( HallViaRadical( G, [ 2 ] ) );
1
gap> Length( HallViaRadical( G, [ 3 ] ) );
1

#
gap> G:= SymmetricGroup( 5 );;
gap> Size( Source( EpimorphismSchurCover( G ) ) );
240
gap> G:= AlternatingGroup( 5 );;
gap> Size( Source( EpimorphismSchurCover( G ) ) );
120

#
gap> G:= Group( Z(3) * [ [ [ 1, 1 ], [ 0, 1 ] ] ] );;
gap> Size( Image( SparseActionHomomorphism( G,
>                   Elements( GF(3)^2 ), [ Z(3) * [ 1, 0 ] ], OnRight ) ) );
6

#
gap> STOP_TEST( "ggmbi.tst" );
