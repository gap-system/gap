# ProjLowIndex:
# Usage: ReadPackage("recog","tst/ProjLowIndex.g");
LoadPackage("recog");
ReadPackage("recog","tst/products.g");
gens := [[[Z(7)]],[[Z(7)^0]]];
g := GroupWithGenerators(gens);
g := WreathProductOfMatrixGroup(g,SymmetricGroup(5));
Print("Testing ProjLowIndex:\n");
RECOG.TestGroup(g,true,155520);
Print("\n");
