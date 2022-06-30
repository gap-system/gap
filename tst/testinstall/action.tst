gap> START_TEST( "action.tst" );

# The following session documents what happens currently
# if one specifies "group actions" that are in fact not actions.
# (When some of these tests fail then parts of the documentation
# may have to be changed.)

# Define an intransitive group.
gap> G:= Group( (1,2), (3,4,5) );;

#
gap> RankAction( G ); # error, good
Error, RankAction: action must be transitive
gap> RankAction( G, [ 2 .. 5 ] ); # error, good
Error, RankAction: action must be transitive
gap> RankAction( G, [ 1 .. 6 ] ); # error, good
Error, RankAction: action must be transitive
gap> RankAction( G, [ 1 .. 5 ] ); # error, good
Error, RankAction: action must be transitive
gap> RankAction( G, [ 2 .. 6 ] ); # error, good
Error, RankAction: action must be transitive

#
gap> Blocks( G, [ 2 .. 5 ] ); # error, good
Error, <G> must operate transitively on <D>
gap> Blocks( G, [ 1 .. 6 ] ); # error, good
Error, <G> must operate transitively on <D>
gap> Blocks( G, [ 1 .. 5 ] );; # works although not transitive
gap> bl:= Blocks( G, [ 2 .. 6 ] );; # works although no action
gap> Action( G, bl, OnSets ); # error, good (but late)
Error, List Element: <list>[1] must have an assigned value

#
gap> MaximalBlocks( G, [ 2 .. 5 ] ); # error, good
Error, <G> must operate transitively on <D>
gap> MaximalBlocks( G, [ 1 .. 6 ] ); # error, good
Error, <G> must operate transitively on <D>
gap> MaximalBlocks( G, [ 1 .. 5 ] );; # works although not transitive
gap> bl:= MaximalBlocks( G, [ 2 .. 6 ] );; # works although no action
gap> Action( G, bl, OnSets ); # error, good (but late)
Error, List Element: <list>[1] must have an assigned value

#
gap> bl:= RepresentativesMinimalBlocks( G, [ 2 .. 5 ] ); # error, good
Error, <G> must act transitively on <D>
gap> bl:= RepresentativesMinimalBlocks( G, [ 1 .. 6 ] ); # error, good
Error, <G> must act transitively on <D>
gap> RepresentativesMinimalBlocks( G, [ 1 .. 5 ] );; # works although not transitive
gap> bl:= RepresentativesMinimalBlocks( G, [ 2 .. 6 ] );; # works although no action
gap> Action( G, bl, OnSets );
Error, List Element: <list>[1] must have an assigned value

#
gap> xset:= ExternalSet( G, [ 2 .. 5 ] );; # works although no action
gap> Elements( xset );; # works
gap> Action( xset );; # error, good (but late)
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `GroupByGenerators' on 2 arguments

#
gap> xset:= ExternalOrbit( G, [ 2 .. 5 ], 2 );; # works although no action
gap> Elements( xset ); # error, good (but late)
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `[]' on 2 arguments
The 2nd argument is 'fail' which might point to an earlier problem


#
gap> xset:= ExternalSubset( G, [ 2 .. 5 ], [ 2 ] );; # works (although no action)
gap> Elements( xset );; # error, good (but late)
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `[]' on 2 arguments
The 2nd argument is 'fail' which might point to an earlier problem


#
gap> hom:= ActionHomomorphism( G, [ 2 .. 5 ] );; # works (although no action)
gap> Image( hom ); # error, good (but late)
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `GroupByGenerators' on 2 arguments

#
gap> STOP_TEST( "action.tst" );
