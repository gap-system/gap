# ProjLowIndex2:
# Usage: ReadPackage("recog","tst/ProjLowIndex2.g");
LoadPackage("recog");
ReadPackage("recog","tst/products.g");
gens := AtlasGenerators("HS",10).generators;
g := GroupWithGenerators(gens);
Print("Testing ProjLowIndex2:\n");
RECOG.TestGroup(g,true,44352000);
Print("\n");
