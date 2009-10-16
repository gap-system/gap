# MatTrivial:
# Usage: ReadPackage("recog","tst/MatTrivial.g");
LoadPackage("recog");
g := GroupWithGenerators([One(GL(7,5))]);
Print("Testing MatTrivial:\n");
RECOG.TestGroup(g,false,1);
Print("\n");
