# ProjSubfield:
# Usage: ReadPackage("recog","tst/ProjSubfield.g");
LoadPackage("recog");
h := GL(4,3^2);
x := PseudoRandom(GL(4,3^4));
gens := List(GeneratorsOfGroup(h),y->y^x);
g := GroupWithGenerators(gens);
Print("Testing ProjSubfield:\n");
RECOG.TestGroup(g,true,Size(PGL(4,3^2)));
Print("\n");
