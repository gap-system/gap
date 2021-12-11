# see https://github.com/gap-system/gap/issues/4717
gap> g := SL(2,3);;
gap> ForAll(ConjugacyClassesSubgroups(g),x->IsSubgroup(g,Representative(x)));
true
