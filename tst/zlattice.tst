#############################################################################
##
#W  zlattice.tst                GAP library                     Thomas Breuer
##
#H  @(#)$Id: zlattice.tst,v 1.7 2010/10/10 21:59:40 alexk Exp $
##
#Y  Copyright (C)  1999,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  To be listed in testinstall.g
##

gap> START_TEST("$Id: zlattice.tst,v 1.7 2010/10/10 21:59:40 alexk Exp $");


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

