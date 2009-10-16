#############################################################################
##
#W  zlattice.tst                GAP library                     Thomas Breuer
##
#H  @(#)$Id: zlattice.tst,v 1.4 2009/09/23 22:22:46 alexk Exp $
##
#Y  Copyright (C)  1999,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  To be listed in testall.g
##

gap> START_TEST("$Id: zlattice.tst,v 1.4 2009/09/23 22:22:46 alexk Exp $");


# trivial cases of `LLLReducedBasis'
gap> LLLReducedBasis( [ ] );
rec( B := [  ], basis := [  ], mue := [  ] )
gap> LLLReducedBasis( [ [ 0, 0 ], [ 0, 0 ] ], "linearcomb" );
rec( B := [  ], relations := [ [ 1, 0 ], [ 0, 1 ] ], basis := [  ],
  mue := [  ], transformation := [  ] )

gap> STOP_TEST( "zlattice.tst", 136000 );


#############################################################################
##
#E

