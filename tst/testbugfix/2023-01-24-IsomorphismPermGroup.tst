# see <https://github.com/gap-system/gap/issues/3601>
gap> G:=SL(2,3);;Order(G);
24
gap> P:=Image(IsomorphismPermGroup(G));;Order(P);
24
