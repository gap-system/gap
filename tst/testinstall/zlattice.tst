#@local A
gap> START_TEST("zlattice.tst");

# 'Decomposition'
gap> A:= [ [ 82, 1 ], [ -1, 1 ] ];;
gap> SetInfoLevel( InfoZLattice, 0 );
gap> Decomposition( A, [ [ 82, 1 ] ], 1 );
[ [ 1, 0 ] ]
gap> SetInfoLevel( InfoZLattice, 1 );
gap> Decomposition( A, [ [ 82, 1 ] ], 1 );
#I  DecompositionInt: choosing new prime 89
[ [ 1, 0 ] ]
gap> SetInfoLevel( InfoZLattice, 0 );

# trivial cases of `LLLReducedBasis'
gap> LLLReducedBasis( [ ] );
rec( B := [  ], basis := [  ], mue := [  ] )
gap> LLLReducedBasis( [ [ 0, 0 ], [ 0, 0 ] ], "linearcomb" );
rec( B := [  ], basis := [  ], mue := [  ], 
  relations := [ [ 1, 0 ], [ 0, 1 ] ], transformation := [  ] )
gap> STOP_TEST( "zlattice.tst" );
