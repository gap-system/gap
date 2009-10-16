# ProjC6:
# Usage: ReadPackage("recog","tst/ProjC6.g");
LoadPackage("recog");
h := RECOG.MakeC6Group(Sp(4,5),Sp(4,5),3);
x := PseudoRandom(GL(25,3^4));
gens := List(GeneratorsOfGroup(h[1]),y->y^x);
g := GroupWithGenerators(gens);
Print("Testing ProjC6:\n");
RECOG.TestGroup(g,true,5850000000);
Print("\n");
