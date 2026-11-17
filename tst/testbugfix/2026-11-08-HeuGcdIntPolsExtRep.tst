# The heuristic gcd for multivariate rational polynomials used to always
# fail, so that multivariate rational functions were not cancelled
gap> x := Indeterminate(Rationals, "x");;
gap> y := Indeterminate(Rationals, "y");;
gap> z := Indeterminate(Rationals, "z");;
gap> fam := FamilyObj(x);;
gap> heu := function(a, b)
>      local g;
>      g := HeuGcdIntPolsExtRep(fam, ExtRepPolynomialRatFun(a),
>                                    ExtRepPolynomialRatFun(b));
>      if IsList(g) then g := PolynomialByExtRep(fam, g); fi;
>      return g;
>    end;;
gap> heu((x+1)*(x+2), (x+1)*(x+3));
x+1
gap> heu(x*(x+1)*(x+2), x*(x+1)*(x+3));
x^2+x
gap> heu(6*(x+y), 4*(x+y)*(x+1));
2*x+2*y
gap> heu(x+y, x-y);
1
gap> heu((x*y+z+2)*(x^2-3*z), (x*y+z+2)*(y+z+5));
x*y+z+2
gap> ((x+y)*(x-y))/((x+y)^2);
(x-y)/(x+y)
gap> r := ((x+y)*(x+1))/((x+y)*(x+2));
(x+1)/(x+2)
gap> IsUnivariateRationalFunction(r);
true
