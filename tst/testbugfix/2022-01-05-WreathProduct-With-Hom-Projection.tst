# Projection of Perm Wreath Product constructed with optional hom argument #4727
gap> K := SymmetricGroup(3);;
gap> H := SymmetricGroup(5);;
gap> P := SymmetricGroup(7);;
gap> hom := GroupHomomorphismByImages(H, P, [(1,2), (1,2,3,4,5)], [(2,3), (2,3,4,5,6)]);;
gap> G := WreathProduct(K, H, hom);;
gap> g := (4,13,16,10,8)(5,14,17,12,7,6,15,18,11,9)(19,20);;
gap> g ^ Projection(G);
(1,4,5,3,2)
gap> g := (1,3,2)(4,13,9,6,14,7)(5,15,8)(10,18,11,16,12,17);;
gap> g ^ Projection(G);
(1,4,2)(3,5)
gap> g := (1,2,3) ^ Embedding(G, 1) * (1,2) ^ Embedding(G, 4) * (1,2) ^ Embedding(G, 6) * (1,4)(2,3) ^ Embedding(G, 8);
(1,2,3)(4,13)(5,14)(6,15)(7,10,8,11)(9,12)(16,17)
gap> g ^ Projection(G);
(1,4)(2,3)
