# verify fix for bug #2586 on GitHub

gap> g := Group([ (1,2,3,4,6), (1,2)(3,4)(5,6) ]);;
gap> # g = TransitiveGroup(6,14) = PGL(2,5)
gap> cl:=ConjugacyClassesSubgroups(g);;
gap> ForAll(cl,x->IsSubset(g,Representative(x)));
true
gap> Length(ConjugacyClassesSubgroups(SmallGroup(120,5)));
12
gap> Length(ConjugacyClassesSubgroups(SmallGroup(120,5)));
12
gap> Length(ConjugacyClassesSubgroups(SmallGroup(120,5)));
12
