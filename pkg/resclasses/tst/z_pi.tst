#############################################################################
##
#W  z_pi.tst              GAP4 Package `ResClasses'               Stefan Kohl
##
##  This file contains automated tests of ResClasses' functionality for
##  computing with semilocalizations Z_(pi) of the ring of integers.
##
#############################################################################

gap> START_TEST( "z_pi.tst" );
gap> ResClassesDoThingsToBeDoneBeforeTest();
gap> R := Z_pi([2]);
Z_( 2 )
gap> R = Z_pi(2);
true
gap> S := Z_pi([2,5,7]);
Z_( 2, 5, 7 )
gap> T := Z_pi([3,11]);
Z_( 3, 11 )
gap> 4 in R;
true
gap> 4/7 in R;
true
gap> 3/2 in R;
false
gap> 17/35 in T;
true
gap> 17/35 in S;
false
gap> 3/17 in S;
true
gap> R = S;
false
gap> U := Intersection(R,S,T);
Z_( 2, 3, 5, 7, 11 )
gap> Representative(U);
1/13
gap> One(U);
1
gap> Zero(U);
0
gap> Size(U);
infinity
gap> IsFinite(U);
false
gap> IsSubset(Rationals,R);
true
gap> IsSubset(U,Integers);
true
gap> IsRing(R);
true
gap> IsField(R);
false
gap> Intersection(Rationals,T);
Z_( 3, 11 )
gap> IsSubset(R,U);
true
gap> IsSubset(T,R);
false
gap> IsAssociative(U);
true
gap> IsCommutative(U);
true
gap> StandardAssociate(R,0);
0
gap> StandardAssociate(R,-1);
1
gap> StandardAssociate(R,-2);
2
gap> StandardAssociate(R,-6/7);
2
gap> StandardAssociate(R,-12/7);
4
gap> StandardAssociate(R,36/5);
4
gap> StandardAssociate(U,36/5);
fail
gap> StandardAssociate(U,37/13);
1
gap> StandardAssociate(U,36/13);
36
gap> V := Z_pi([2,3,7]);
Z_( 2, 3, 7 )
gap> Gcd(V,2/5,6);
2
gap> Gcd(V,20/13,77/19);
1
gap> Gcd(V,21/13,77/19);
7
gap> Lcm(V,20,77);
28
gap> Lcm(V,2/5,77);
14
gap> Lcm(V,20/13,77/19);
28
gap> Factors(U,840);
[ 2, 2, 2, 3, 5, 7 ]
gap> Factors(R,840);
[ 105, 2, 2, 2 ]
gap> Factors(S,840);
[ 3, 2, 2, 2, 5, 7 ]
gap> Factors(T,840);
[ 280, 3 ]
gap> Factors(T,-840);
[ -280, 3 ]
gap> Factors(U,-840);
[ -1, 2, 2, 2, 3, 5, 7 ]
gap> Factors(U,-2/3);
fail
gap> Factors(R,-2/3);
[ -1/3, 2 ]
gap> Factors(S,-2/3);
[ -1/3, 2 ]
gap> Factors(S,-2/10);
fail
gap> Factors(S,-6/17);
[ -3/17, 2 ]
gap> Factors(S,60/17);
[ 3/17, 2, 2, 5 ]
gap> IsUnit(S,2);
false
gap> IsUnit(S,3/11);
true
gap> IsUnit(S,-3);
true
gap> IsUnit(S,10);
false
gap> IsUnit(T,-2);
true
gap> IsUnit(T,0);
false
gap> IsUnit(T,3);
false
gap> IsUnit(T,3/11);
fail
gap> IsIrreducibleRingElement(U,0);
false
gap> IsIrreducibleRingElement(R,2);
true
gap> IsIrreducibleRingElement(R,-13);
false
gap> IsIrreducibleRingElement(U,-7);
true
gap> IsIrreducibleRingElement(U,9);
false
gap> IsIrreducibleRingElement(R,-4);
false
gap> IsIrreducibleRingElement(T,-3);
true
gap> ResClassesDoThingsToBeDoneAfterTest();
gap> STOP_TEST( "z_pi.tst", 2000000 );

#############################################################################
##
#E  z_pi.tst . . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here