#2016/3/1 (AH)
gap> g:=PSL(6,4);;
gap> Sum(ConjugacyClasses(g),Size)=Size(g);
true
gap> Size(AutomorphismGroup(TransitiveGroup(12,269)));
14400
