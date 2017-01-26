## Semigroup/Monoid rewriting system bug for fix 4
gap> f := FreeSemigroup("a","b");;
gap> a := f.1;; b := f.2;;
gap> s := f/[[a*b,b],[b*a,a]];;
gap> rws := KnuthBendixRewritingSystem(s);
Knuth Bendix Rewriting System for Semigroup( [ a, b ] ) with rules 
[ [ a*b, b ], [ b*a, a ] ]
gap> MakeConfluent(rws);
gap> rws;
Knuth Bendix Rewriting System for Semigroup( [ a, b ] ) with rules 
[ [ a*b, b ], [ b*a, a ], [ a^2, a ], [ b^2, b ] ]
gap> HasReducedConfluentRewritingSystem(s);
true
gap> x:= Indeterminate( Rationals );;
gap> a:= 1/(1+x);;
gap> b:= 1/(x+x^2);;
gap> a=b;
false
