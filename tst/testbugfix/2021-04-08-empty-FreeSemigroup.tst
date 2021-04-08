# See https://github.com/gap-system/gap/issues/1385
gap> FreeSemigroup();
Error, free semigroups of rank zero are not supported
gap> FreeSemigroup([]);
Error, free semigroups of rank zero are not supported
gap> FreeSemigroup("");
Error, free semigroups of rank zero are not supported
gap> FreeSemigroup(0);
Error, free semigroups of rank zero are not supported
gap> FreeSemigroup(0, "name");
Error, free semigroups of rank zero are not supported
