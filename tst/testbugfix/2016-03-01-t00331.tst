#2016/3/1 (AH)
gap> g:=PSL(6,4);;
gap> Sum(ConjugacyClasses(g),Size)=Size(g);
true
gap> h:=Group([(2,4,6,8,12), (2,8)(10,12), (1,12)(2,3)(4,5)(6,7)(8,9)(10,11)]);;
gap> # h = TransitiveGroup(12,269)
gap> Size(AutomorphismGroup(h));
14400
