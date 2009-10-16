# ProjNotAbsIrred:
# This currently does not work because of a segfault!
# Usage: ReadPackage("recog","tst/ProjNotAbsIrred.g");
LoadPackage("recog");
h := GL(3,5^2);
b := Basis(VectorSpace(GF(5),Elements(GF(5^2))));
gens := List(GeneratorsOfGroup(h),y->BlownUpMat(b,y));
g := GroupWithGenerators(gens);
Print("Testing ProjNotAbsIrred:\n");
RECOG.TestGroup(g,true,Size(PGL(3,5^2))*6);
# Remark: The *6 comes from the fact that by blowing up we lose a factor
#         of 6 in scalars, they are now in the projective group.
Print("\n");
