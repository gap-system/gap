s := Transformation([1,1,3]);
c := Transformation([2,3,1]);

op3 := Semigroup(s,c);

dcl := GreensDClasses(op3);

d2 := dcl[1];
d1 := dcl[3];

i2 := SemigroupIdealByGenerators(op3, [Representative(d2)]);
i1 := SemigroupIdealByGenerators(op3, [Representative(d1)]);

c1 := ReesCongruenceOfSemigroupIdeal(i1);


