#############################################################################
##
#W  fixedrep.tst            GAP4 Package `ResClasses'             Stefan Kohl
##
##  This file contains automated tests of ResClasses' functionality for
##  computing with unions of residue classes with distinguished ("fixed")
##  representatives.
##
#############################################################################

gap> START_TEST( "fixedrep.tst" );
gap> ResClassesDoThingsToBeDoneBeforeTest();
gap> cl1 := ResidueClassWithFixedRepresentative(Integers,3,2);
[2/3]
gap> cl2 := ResidueClassWithFixedRepresentative(Integers,2,1);
[1/2]
gap> U := UnionOfResidueClassesWithFixedReps(Integers,[[2,1],[7,4]]);
[1/2] U [4/7]
gap> AllResidueClassesWithFixedRepresentativesModulo(Z_pi(2),4);
[ [0/4], [1/4], [2/4], [3/4] ]
gap> AllResidueClassesWithFixedRepsModulo(9);
[ [0/9], [1/9], [2/9], [3/9], [4/9], [5/9], [6/9], [7/9], [8/9] ]
gap> Modulus(U);
14
gap> Classes(U);
[ [ 2, 1 ], [ 7, 4 ] ]
gap> String(cl1);
"ResidueClassWithFixedRepresentative( Integers, 3, 2 )"
gap> Print(cl1,"\n");
ResidueClassWithFixedRepresentative( Integers, 3, 2 )
gap> Print(U,"\n");
UnionOfResidueClassesWithFixedRepresentatives( Integers, [ [ 2, 1 ], [ 7, 4 ] 
 ] )
gap> p := List([1..25],i->[Primes[i],i]);;
gap> P := UnionOfResidueClassesWithFixedRepresentatives(Integers,p);
<union of 25 residue classes of Z with fixed representatives>
gap> Display(P);
[1/2] U [2/3] U [3/5] U [4/7] U [5/11] U [6/13] U [7/17] U [8/19] U [9/23] U [
10/29] U [11/31] U [12/37] U [13/41] U [14/43] U [15/47] U [16/53] U [17/
59] U [18/61] U [19/67] U [20/71] U [21/73] U [22/79] U [23/83] U [24/89] U [
25/97]
gap> Multiplicity(1,U);
1
gap> Multiplicity(2,U);
0
gap> Multiplicity(11,U);
2
gap> IsOverlappingFree(cl1);
true
gap> IsOverlappingFree(U);
false
gap> List([cl1,cl2,U],AsOrdinaryUnionOfResidueClasses);
[ The residue class 2(3) of Z, The residue class 1(2) of Z, 
  Union of the residue classes 1(2) and 4(14) of Z ]
gap> cl1 in U;
false
gap> cl2 in U;
true
gap> AsListOfClasses(U);
[ [1/2], [4/7] ]
gap> IsSubset(U,cl1);
false
gap> IsSubset(U,cl2);
true
gap> Density(U);
9/14
gap> Union(U,cl1);
[1/2] U [2/3] U [4/7]
gap> Union(cl1,cl1);
[2/3] U [2/3]
gap> Intersection(cl1,cl2);
Empty union of residue classes of Z with fixed representatives
gap> Intersection(List([cl1,cl2],AsOrdinaryUnionOfResidueClasses));
The residue class 5(6) of Z
gap> Intersection(cl2,U);
[1/2]
gap> Intersection(U,cl1);
Empty union of residue classes of Z with fixed representatives
gap> Difference(U,cl1);
[1/2] U [1/3] U [4/7]
gap> Difference(U,cl2);
[4/7]
gap> Difference(U,U);
Empty union of residue classes of Z with fixed representatives
gap> cl1 + 1;
[3/3]
gap> U+23;
[24/2] U [27/7]
gap> cl2 - 1;
[0/2]
gap> U - 17;
[-16/2] U [-13/7]
gap> 3*cl1;
[6/9]
gap> 7*U;
[7/14] U [28/49]
gap> (2*cl1+2)/3;
[2/2]
gap> RepresentativeStabilizingRefinement(cl1,2);
[2/6] U [5/6]
gap> V := RepresentativeStabilizingRefinement(U,3);
[1/6] U [3/6] U [5/6] U [4/21] U [11/21] U [18/21]
gap> Delta(U);
1/14
gap> (1/2-1/2)+(4/7-1/2);
1/14
gap> Delta(V);
1/14
gap> (1/6-1/2)+(3/6-1/2)+(5/6-1/2)+(4/21-1/2)+(11/21-1/2)+(18/21-1/2);
1/14
gap> Delta(P);
-3706053977906326692602106591985470034/1152783981972759212376551073665878035
gap> Factors(DenominatorRat(last));
[ 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 
  73, 79, 83, 89, 97 ]
gap> cl := UnionOfResidueClassesWithFixedReps(Integers,[[2,1]]);
[1/2]
gap> S := RepresentativeStabilizingRefinement(cl,3);
[1/6] U [3/6] U [5/6]
gap> cls := AsListOfClasses(S);
[ [1/6], [3/6], [5/6] ]
gap> cls := List([1..3],i->RepresentativeStabilizingRefinement(cls[i],i+1));
[ [1/12] U [7/12], [3/18] U [9/18] U [15/18], 
  [5/24] U [11/24] U [17/24] U [23/24] ]
gap> S := Union(cls);
<union of 9 residue classes of Z with fixed representatives>
gap> RepresentativeStabilizingRefinement(S,0);
[1/2]
gap> cl := ResidueClassWithFixedRep(3,1);
[1/3]
gap> U := Union(cl,cl);
[1/3] U [1/3]
gap> U := RepresentativeStabilizingRefinement(U,2);
[1/6] U [1/6] U [4/6] U [4/6]
gap> U := RepresentativeStabilizingRefinement(U,3);
<union of 12 residue classes of Z with fixed representatives>
gap> RepresentativeStabilizingRefinement(U,0);
[1/3] U [1/3]
gap> U := UnionOfResidueClassesWithFixedReps([[-1,3],[1,3],[3,3]]);;
gap> U = RepresentativeStabilizingRefinement(U,0);
true
gap> R := PolynomialRing(GF(2),1);;
gap> x := IndeterminatesOfPolynomialRing(R)[1];; SetName(x,"x");;
gap> cl := ResidueClassWithFixedRepresentative(R,x^2+One(R),One(R));
[Z(2)^0/x^2+Z(2)^0]
gap> cl*x;
[x/x^3+x]
gap> cl+x;
[x+Z(2)^0/x^2+Z(2)^0]
gap> -cl;
[Z(2)^0/x^2+Z(2)^0]
gap> Print(cl,"\n");
ResidueClassWithFixedRepresentative( PolynomialRing( GF(
2), ["x"] ), x^2+Z(2)^0, Z(2)^0 )
gap> U := UnionOfResidueClassesWithFixedReps(Integers,[[2,0],[3,0]]);
[0/2] U [0/3]
gap> 0 in U;
true
gap> cl := ResidueClassWithFixedRep(2,0);
[0/2]
gap> Multiplicity(cl,U);
1
gap> cl := ResidueClassWithFixedRep(-4,37);
[37/-4]
gap> IsResidueClassWithFixedRep(cl);
true
gap> Modulus(cl);
-4
gap> Residue(cl);
37
gap> cl := ResidueClassWithFixedRep(-4,23);
[23/-4]
gap> Rho(cl);
E(8)
gap> U := RepresentativeStabilizingRefinement(cl,3);
[15/-12] U [19/-12] U [23/-12]
gap> Rho(U);
E(8)
gap> RepresentativeStabilizingRefinement(U,0);
[23/-4]
gap> cl := ResidueClassWithFixedRep(4,23);
[23/4]
gap> Rho(cl);
-E(8)
gap> U := RepresentativeStabilizingRefinement(cl,3);
[23/12] U [27/12] U [31/12]
gap> Rho(U);
-E(8)
gap> RepresentativeStabilizingRefinement(U,0);
[23/4]
gap> ResClassesDoThingsToBeDoneAfterTest();
gap> STOP_TEST( "fixedrep.tst", 5000000 );

#############################################################################
##
#E  fixedrep.tst . . . . . . . . . . . . . . . . . . . . . . . . .  ends here