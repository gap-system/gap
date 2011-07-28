#############################################################################
##
#W  other.tst                 GAP4 Package `RCWA'                 Stefan Kohl
##
##  This file contains automated tests of RCWA's functionality which is not
##  directly related to rcwa groups.
##
#############################################################################

gap> START_TEST("other.tst");
gap> RCWADoThingsToBeDoneBeforeTest();
gap> R := PolynomialRing(GF(4),1);; x := Z(4) * One(R);;
gap> x in DefaultRing(x);
true
gap> 2*infinity;
infinity
gap> infinity*2;
infinity
gap> infinity*infinity;
infinity
gap> DifferencesList(List([1..16],n->n^3));
[ 7, 19, 37, 61, 91, 127, 169, 217, 271, 331, 397, 469, 547, 631, 721 ]
gap> DifferencesList(last);                
[ 12, 18, 24, 30, 36, 42, 48, 54, 60, 66, 72, 78, 84, 90 ]
gap> DifferencesList(last);
[ 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6 ]
gap> QuotientsList(List([1..10],n->n^2));
[ 4, 9/4, 16/9, 25/16, 36/25, 49/36, 64/49, 81/64, 100/81 ]
gap> FloatQuotientsList(List([1..10],n->n^2));
[ 4., 2.25, 1.77778, 1.5625, 1.44, 1.36111, 1.30612, 1.26562, 1.23457 ]
gap> SearchCycle([1,4,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3]);    
[ 2, 3, 1 ]
gap> EquivalenceClasses([1..100],n->Phi(n));
[ [ 1, 2 ], [ 3, 4, 6 ], [ 5, 8, 10, 12 ], [ 7, 9, 14, 18 ], 
  [ 15, 16, 20, 24, 30 ], [ 11, 22 ], [ 13, 21, 26, 28, 36, 42 ], 
  [ 17, 32, 34, 40, 48, 60 ], [ 19, 27, 38, 54 ], [ 25, 33, 44, 50, 66 ], 
  [ 23, 46 ], [ 35, 39, 45, 52, 56, 70, 72, 78, 84, 90 ], [ 29, 58 ], 
  [ 31, 62 ], [ 51, 64, 68, 80, 96 ], [ 37, 57, 63, 74, 76 ], 
  [ 41, 55, 75, 82, 88, 100 ], [ 43, 49, 86, 98 ], [ 69, 92 ], [ 47, 94 ], 
  [ 65 ], [ 53 ], [ 81 ], [ 87 ], [ 59 ], [ 61, 77, 93, 99 ], [ 85 ], [ 67 ], 
  [ 71 ], [ 73, 91, 95 ], [ 79 ], [ 83 ], [ 89 ], [ 97 ] ]
gap> S4 := SymmetricGroup(4);; elms := AsList(S4);;
gap> EquivalenceClasses(elms,function(g,h) return IsConjugate(S4,g,h); end);
[ [ (2,3,4), (2,4,3), (1,2,3), (1,2,4), (1,3,2), (1,3,4), (1,4,2), (1,4,3) ], 
  [ (3,4), (2,3), (2,4), (1,2), (1,3), (1,4) ], 
  [ (1,2,3,4), (1,2,4,3), (1,3,4,2), (1,3,2,4), (1,4,3,2), (1,4,2,3) ], 
  [ (1,2)(3,4), (1,3)(2,4), (1,4)(2,3) ], [ () ] ]
gap> EquivalenceClasses([3,5,2,6,8,7,12,14,15,16,6,3,6],n->Phi(n));
[ [ 2 ], [ 3, 6, 6, 3, 6 ], [ 5, 8, 12 ], [ 7, 14 ], [ 15, 16 ] ]
gap> EquivalenceClasses([(1,2),(1,2),(1,2,3)],
>                       function(g,h) return IsConjugate(S4,g,h); end);
[ [ (1,2), (1,2) ], [ (1,2,3) ] ]
gap> Set(AllProducts([1..10],2));
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 24, 25, 27, 28, 
  30, 32, 35, 36, 40, 42, 45, 48, 49, 50, 54, 56, 60, 63, 64, 70, 72, 80, 81, 
  90, 100 ]
gap> RestrictedPartitionsWithoutRepetitions(10,[1..10]);
[ [ 10 ], [ 9, 1 ], [ 8, 2 ], [ 7, 3 ], [ 7, 2, 1 ], [ 6, 4 ], [ 6, 3, 1 ], 
  [ 5, 4, 1 ], [ 5, 3, 2 ], [ 4, 3, 2, 1 ] ]
gap> RestrictedPartitionsWithoutRepetitions(24,DivisorsInt(24));
[ [ 24 ], [ 12, 8, 4 ], [ 12, 8, 3, 1 ], [ 12, 6, 4, 2 ], [ 12, 6, 3, 2, 1 ], 
  [ 8, 6, 4, 3, 2, 1 ] ]
gap> ListOfPowers(10,8); 
[ 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000 ]
gap> GeneratorsAndInverses(SymmetricGroup(4));
[ (1,2,3,4), (1,2), (1,4,3,2), (1,2) ]
gap> RCWADoThingsToBeDoneAfterTest();
gap> STOP_TEST( "other.tst", 4000000 );

#############################################################################
##
#E  other.tst . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here