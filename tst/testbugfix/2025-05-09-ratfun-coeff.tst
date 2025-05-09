# Fix #5988 CoefficientsOfUnivariateRationalFunction
gap> x1 := X(Integers, 1);; fam := FamilyObj(x1);;
gap> f := RationalFunctionByExtRep(fam, [], [ [ 1, 2 ], 3 ]);; # = 0/(3*x_1^2)
gap> CoefficientsOfUnivariateRationalFunction(f);
[ [  ], [ 1 ], 0 ]
gap> g := RationalFunctionByExtRep(fam, [ [ 1, 1 ], 1 ], [ [  ], 1, [ 1, 1 ], 1 ]);; # x1/(1+x1)
gap> SetIsUnivariateRationalFunction(g, true);
gap> CoefficientsOfUnivariateRationalFunction(g);
[ [ 1 ], [ 1, 1 ], 1 ]
gap> h := (1 + 2*x1^2 + 3*x1^4) / (x1^5);;
gap> CoefficientsOfUnivariateRationalFunction(h);
[ [ 1, 0, 2, 0, 3 ], [ 1 ], -5 ]