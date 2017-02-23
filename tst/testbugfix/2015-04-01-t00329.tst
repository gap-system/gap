# 2015/04/01 (SL)
gap> p := 227;; x := X(GF(p), "x");; f := x^(7^2) - x;;
gap> PowerMod(x, p, f);
x^35
