# verify fix for bug #2586 on GitHub

gap> g:=TransitiveGroup(6,14);;
gap> cl:=ConjugacyClassesSubgroups(g);;
gap> ForAll(cl,x->IsSubset(g,Representative(x)));
true
gap> Length(ConjugacyClassesSubgroups(SmallGroup(120,5)));
12
gap> Length(ConjugacyClassesSubgroups(SmallGroup(120,5)));
12
gap> Length(ConjugacyClassesSubgroups(SmallGroup(120,5)));
12
