#@local g, gens, acts, xset
gap> START_TEST( "cycles.tst" );

# wrong number of arguments must give a usage message, not a kernel error
gap> Permutation( (1,2,3)(4,5) );
Error, usage: Permutation(<g>,<Omega>[,<gens>,<acts>][,<act>])
gap> Permutation( (1,2,3)(4,5), [1..5], [], [], OnPoints, OnPoints );
Error, usage: Permutation(<g>,<Omega>[,<gens>,<acts>][,<act>])
gap> PermutationCycle( (1,2,3)(4,5) );
Error, usage: PermutationCycle(<g>,<Omega>,<pnt>[,<gens>,<acts>][,<act>])
gap> PermutationCycle( (1,2,3)(4,5), [1..5] );
Error, usage: PermutationCycle(<g>,<Omega>,<pnt>[,<gens>,<acts>][,<act>])
gap> Cycle( (1,2,3)(4,5) );
Error, usage: Cycle(<g>,<Omega>,<pnt>[,<gens>,<acts>][,<act>])
gap> Cycles( (1,2,3)(4,5) );
Error, usage: Cycles(<g>,<Omega>[,<gens>,<acts>][,<act>])
gap> CycleLength( (1,2,3)(4,5) );
Error, usage: CycleLength(<g>,<Omega>,<pnt>[,<gens>,<acts>][,<act>])
gap> CycleLengths( (1,2,3)(4,5) );
Error, usage: CycleLengths(<g>,<Omega>[,<gens>,<acts>][,<act>])
gap> CycleIndex( [1..5] );
Error, usage: CycleIndex(<g>,<Omega>[,<act>])

# the documented argument forms still work
gap> g:= (1,2,3)(4,5)(6,7);;
gap> Permutation( g, [4..7] );
(1,2)(3,4)
gap> PermutationCycle( g, [4..7], 4 );
(1,2)
gap> Cycle( g, [4..7], 4 );
[ 4, 5 ]
gap> Cycles( g, [4..7] );
[ [ 4, 5 ], [ 6, 7 ] ]
gap> CycleLength( g, [4..7], 4 );
2
gap> CycleLengths( g, [4..7] );
[ 2, 2 ]
gap> CycleIndex( g, [4..7] );
x_2^2
gap> CycleIndex( g );
x_2^2*x_3

# the <gens>, <acts> form
gap> gens:= [ (1,2,3) ];; acts:= [ (4,5,6) ];;
gap> Permutation( (1,2,3), [4..6], gens, acts, OnPoints );
(1,2,3)
gap> Cycle( (1,2,3), [4..6], 4, gens, acts, OnPoints );
[ 4, 5, 6 ]
gap> Cycles( (1,2,3), [4..6], gens, acts, OnPoints );
[ [ 4, 5, 6 ] ]
gap> CycleLength( (1,2,3), [4..6], 4, gens, acts, OnPoints );
3
gap> CycleLengths( (1,2,3), [4..6], gens, acts, OnPoints );
[ 3 ]
gap> PermutationCycle( (1,2,3), [4..6], 4, gens, acts, OnPoints );
(1,2,3)

# the external set form
gap> xset:= ExternalSet( Group( (1,2,3)(4,5)(6,7) ), [4..7] );;
gap> Permutation( g, xset );
(1,2)(3,4)
gap> Cycles( g, xset );
[ [ 4, 5 ], [ 6, 7 ] ]
gap> Cycle( g, xset, 4 );
[ 4, 5 ]
gap> CycleLength( g, xset, 4 );
2
gap> CycleLengths( g, xset );
[ 2, 2 ]
gap> PermutationCycle( g, xset, 4 );
(1,2)

#
gap> STOP_TEST( "cycles.tst" );
