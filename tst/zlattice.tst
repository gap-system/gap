#############################################################################
##
#W  zlattice.tst                GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1999,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  To be listed in testinstall.g
##

gap> START_TEST("$Id$");


# trivial cases of `LLLReducedBasis'
gap> LLLReducedBasis( [ ] );
rec( B := [  ], basis := [  ], mue := [  ] )
gap> LLLReducedBasis( [ [ 0, 0 ], [ 0, 0 ] ], "linearcomb" );
rec( B := [  ], basis := [  ], mue := [  ], 
  relations := [ [ 1, 0 ], [ 0, 1 ] ], transformation := [  ] )

gap> STOP_TEST( "zlattice.tst", 136000 );


#############################################################################
##
#E

