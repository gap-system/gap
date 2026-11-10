# Factors over the rationals must not stop at the one factor bound after a
# search restricted to factors of at most half the degree
gap> x := Indeterminate(Rationals, "x");;
gap> f := (x^4+x^3+x^2+x+1)*(x^2-10*x+26);;
gap> Factors(f);
[ x^2-10*x+26, x^4+x^3+x^2+x+1 ]
gap> Factors((x^5-1)*(x^2-10*x+26)^2);
[ x-1, x^2-10*x+26, x^2-10*x+26, x^4+x^3+x^2+x+1 ]
