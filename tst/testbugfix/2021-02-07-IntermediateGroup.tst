# IntermediateGroup in large index, reported in Forum (Breuer/Anvita) on 2/7/21
gap> L:=PSL(2,7^3);;
gap> S:=SylowSubgroup(L,2);;
gap> u:=IntermediateGroup(L,S);;
gap> IsGroup(u) and Size(u)>Size(S);
true
