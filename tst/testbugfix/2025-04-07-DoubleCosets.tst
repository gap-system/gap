# Fix #5969 Double Cosets
gap> G := SymmetricGroup(16);;
gap> H := DirectProduct(SymmetricGroup(4),WreathProduct(SymmetricGroup(3),
>   SymmetricGroup(3)),SymmetricGroup(3));;
gap> K := WreathProduct(SymmetricGroup(2),SymmetricGroup(8));;
gap> Length(DoubleCosetRepsAndSizes(G, H, K));
121
