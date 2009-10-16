# ProjTrivial:
# Usage: ReadPackage("recog","tst/ProjTrivial.g");
LoadPackage("recog");
g := GroupWithGenerators([One(GL(7,5))]);
gens := ShallowCopy(GeneratorsOfGroup(g));
repeat r := Random(GF(5)); until not(IsZero(r));
Add(gens,gens[1]*r);
g := GroupWithGenerators(gens);
Print("Testing ProjTrivial:\n");
RECOG.TestGroup(g,true,1);
Print("\n");
