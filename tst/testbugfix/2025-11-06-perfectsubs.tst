# missing subgroups when finding perfect subgroups
# See <https://github.com/gap-system/gap/issues/6157>.
gap> G:=WreathProduct(Group((1,2)), SymmetricGroup(6));;
gap> Size(ConjugacyClassesPerfectSubgroups(G));
8
