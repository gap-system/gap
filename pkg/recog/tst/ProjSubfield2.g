# ProjSubfield2:
# This currently does not work because of a segfault!
# Usage: ReadPackage("recog","tst/ProjSubfield2.g");
LoadPackage("recog");
h := GL(3,5^2);
b := Basis(VectorSpace(GF(5),Elements(GF(5^2))));
gens := List(GeneratorsOfGroup(h),y->BlownUpMat(b,y));
x := PseudoRandom(GL(6,5^3));
gens := List(gens,y->y^x);
g := GroupWithGenerators(gens);
Print("Testing ProjSubfield2:\n");
RECOG.TestGroup(g,true,Size(PGL(3,5^2))*6);
# Remark: The *6 comes from the fact that by blowing up we lose a factor
#         of 6 in scalars, they are now in the projective group.
Print("\n");
