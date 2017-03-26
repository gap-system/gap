#############################################################################
##
#W  eigen.tst                   GAP library		       Gene Cooperman
#W							     and Scott Murray
##
##
#Y  Copyright (C)  1998,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
gap> START_TEST("eigen.tst");
gap> A := GL(4,3).1;
[ [ Z(3), 0*Z(3), 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0, 0*Z(3), 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), Z(3)^0, 0*Z(3) ], [ 0*Z(3), 0*Z(3), 0*Z(3), Z(3)^0 ] ]
gap> CharacteristicPolynomial( A );
x_1^4+x_1^3-x_1-Z(3)^0
gap> GeneralisedEigenvalues(GF(3), A );
[ x_1+Z(3)^0, x_1-Z(3)^0 ]
gap> GeneralisedEigenspaces(GF(3),A);
[ <vector space over GF(3), with 1 generators>, 
  <vector space over GF(3), with 3 generators> ]
gap> STOP_TEST( "eigen.tst", 1);

#############################################################################
##
#E  
