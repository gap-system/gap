#############################################################################
##
#W  gaussian.tst                GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  To be listed in testinstall.g
##
gap> START_TEST("gaussian.tst");
gap> 257 in GaussianIntegers;
true
gap> 257 + 17*E(4) in GaussianIntegers;
true
gap> 1/2 in GaussianIntegers;
false
gap> 1 + E(3) in GaussianIntegers;
false
gap> 257 in GaussianRationals;
true
gap> 257 + 17*E(4) in GaussianRationals;
true
gap> 1/2 in GaussianRationals;
true
gap> 1 + E(3) in GaussianRationals;
false
gap> IsSubset( GaussianRationals, GaussianIntegers );
true
gap> Quotient( GaussianIntegers, 35, 5 );
7
gap> Quotient( GaussianIntegers, 35, 1+2*E(4) );
7-14*E(4)
gap> Quotient( GaussianIntegers, 35, 1+E(4) );
fail
gap> IsAssociated( GaussianIntegers, 4, -4*E(4) );
true
gap> IsAssociated( GaussianIntegers, 4*E(4), -4 );
true
gap> IsAssociated( GaussianIntegers, 4*E(4), 5 );
false
gap> StandardAssociate( GaussianIntegers,      4 );
4
gap> StandardAssociate( GaussianIntegers,     -4 );
4
gap> StandardAssociate( GaussianIntegers, 1-E(4) );
1+E(4)
gap> StandardAssociate( GaussianIntegers, 1+E(4) );
1+E(4)
gap> EuclideanDegree( GaussianIntegers, 1+E(4) );
2
gap> EuclideanDegree( GaussianIntegers,      2 );
4
gap> EuclideanRemainder( GaussianIntegers, 35, 7 );
0
gap> EuclideanRemainder( GaussianIntegers, 5, 1+2*E(4) );
0
gap> EuclideanRemainder( GaussianIntegers, 5, 1+E(4) );
-1
gap> EuclideanRemainder( GaussianIntegers, 5-2*E(4), 1+E(4) );
-1
gap> EuclideanQuotient( GaussianIntegers, 35, 7 );
5
gap> EuclideanQuotient( GaussianIntegers, 5, 1+2*E(4) );
1-2*E(4)
gap> EuclideanQuotient( GaussianIntegers, 5, 1+E(4) );
3-3*E(4)
gap> EuclideanQuotient( GaussianIntegers, 5-2*E(4), 1+E(4) );
2-4*E(4)
gap> QuotientRemainder( GaussianIntegers, 35, 7 );
[ 5, 0 ]
gap> QuotientRemainder( GaussianIntegers, 5, 1+2*E(4) );
[ 1-2*E(4), 0 ]
gap> QuotientRemainder( GaussianIntegers, 5, 1+E(4) );
[ 3-3*E(4), -1 ]
gap> QuotientRemainder( GaussianIntegers, 5-2*E(4), 1+E(4) );
[ 2-4*E(4), -1 ]
gap> IsPrime( GaussianIntegers, 3 );
true
gap> IsPrime( GaussianIntegers, 5 );
false
gap> IsPrime( GaussianIntegers, 2+E(4) );
true
gap> IsPrime( GaussianIntegers, 1+2*E(4) );
true
gap> IsPrime( GaussianIntegers, 5-E(4) );
false
gap> Factors( GaussianIntegers, 35 );
[ 2-E(4), 2+E(4), 7 ]
gap> Factors( GaussianIntegers, 255 );
[ -3, 1+2*E(4), 2+E(4), 1+4*E(4), 4+E(4) ]
gap> Factors( GaussianIntegers, 2+E(4) );
[ 2+E(4) ]
gap> Factors( GaussianIntegers, 1+2*E(4) );
[ 1+2*E(4) ]
gap> Factors( GaussianIntegers, 5-E(4) );
[ 1-E(4), 3+2*E(4) ]
gap> STOP_TEST( "gaussian.tst", 1);

#############################################################################
##
#E
