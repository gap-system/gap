#####################################################################
##
##  test.cong
##  Creation and enumeration of ideals and congruences
##
#####################################################################

########################
#
# Ideals
#
########################


# Basic test
a := Transformation([2,3,1]);
b := Transformation([2,2,1]);
M := Monoid([a,b]);
# The following does not work because those functions are now missing
# IsTransformationSemigroup(M);
# IsTransformationMonoid(M);
I := MagmaIdealByGenerators(M, [b]);
J := SemigroupIdealByGenerators(M,[b]);
I = J;
Elements(I);
GeneratorsOfSemigroup(I);
GeneratorsOfMagmaIdeal(I);

########################
#
# Congruences
#
########################
# O_4 test
a := Transformation([1,1,3,4]);
b := Transformation([2,2,3,4]);
c := Transformation([1,2,2,4]);
d := Transformation([1,3,3,4]);
e := Transformation([1,2,3,3]);
f := Transformation([1,2,4,4]);
O4 := Monoid([a,b,c,d,e,f]);

I := MagmaIdealByGenerators(O4, [a*f]);
C := SemigroupCongruenceByGeneratingPairs(O4, [[a*f, a*e]]);
P := EquivalenceRelationPartition(C);
I = P[1];													# false
Elements(I) = Elements(P[1]);			# true
IsReesCongruence(C);							# true




#############################
i := SemigroupIdealByGenerators(O4, [b*c]);
ei := Enumerator(i);
rc := LR2MagmaCongruenceByPartitionNCCAT(O4, [ei], IsMagmaCongruence);
IsSemigroupCongruence(rc);
Q4 := O4/rc;

i := SemigroupIdealByGenerators(O4, [b*c]);
rc := ReesCongruenceOfSemigroupIdeal(i);
Q4 := O4/rc;


cc1 := EquivalenceClassOfElement(rc, Transformation([1,2,3,4]));  
Elements(cc1);

cc2 := EquivalenceClassOfElement(rc, Transformation([1,1,1,4]));  
Elements(cc2);


cc3 := EquivalenceClassOfElement(rc, Transformation([1,1,3,4]));  
Elements(cc3);

