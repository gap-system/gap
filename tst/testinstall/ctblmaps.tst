#@local s, t, maps
gap> START_TEST( "ctblmaps.tst" );

# `ConsiderStructureConstants` can unexpectedly exclude all candidates.
# (Benjamin Sambale found examples for that.)
gap> s:= CharacterTable( "2.A6" );;
gap> t:= CharacterTable( "Co3" );;
gap> maps:= [ [ 1, 2, 8, 4, 11, 4, 13, 18, 18, 9, 22, 9, 22 ],
>             [ 1, 2, 8, 4, 11, 4, 13, 17, 17, 9, 22, 9, 22 ] ];;
gap> Length( ConsiderStructureConstants( s, t, maps, true ) );
0

#
gap> STOP_TEST( "ctblmaps.tst" );
