## Rees Matrix bug fix 4
gap> s := Semigroup(Transformation([2,3,1]));;
gap> IsSimpleSemigroup(s);;
gap> irms := IsomorphismReesMatrixSemigroup(s);;
gap> Size(Source(irms));
3
