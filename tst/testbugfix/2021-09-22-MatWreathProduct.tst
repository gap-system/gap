# Generators of Matrix Wreath Product with Intransitive Top Group # 4663
gap> K := GL(3,2);;
gap> H := Group((1,2,3)(4,5));;
gap> G := WreathProduct(K, H);;
gap> Size(Group(GeneratorsOfGroup(G))) = 802966929408;
true
