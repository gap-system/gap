# Fix #5987 ExtRepOfPolynomial_String for zero polynomial
gap> x1 := Indeterminate(Rationals, "x1");; x2 := Indeterminate(Rationals, "x2");; x3 := Indeterminate(Rationals, "x3");;
gap> a := (x1*x2)/(x1*x3) - x2/x3;
0/x1
gap> String(a);
"0/x1"
