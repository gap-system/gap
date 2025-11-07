# 6157, missing subgroups when finding perfect subgroups
gap> G:=WreathProduct(Group((1,2)), SymmetricGroup(6));;
gap> Size(ConjugacyClassesPerfectSubgroups(G));
8
