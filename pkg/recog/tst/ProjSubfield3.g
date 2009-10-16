# ProjSubfield3:
# Usage: ReadPackage("recog","tst/ProjSubfield3.g");
LoadPackage("recog");
h := GL(3,3^2);
x := PseudoRandom(GL(3,3^4));
gens := List(GeneratorsOfGroup(h),y->y^x);
gens[1] := gens[1] * Z(3^4);
gens[2] := gens[2] * Z(3^4)^17;
g := GroupWithGenerators(gens);
Print("Testing ProjSubfield3:\n");
RECOG.TestGroup(g,true,Size(PGL(3,3^2)));
# Remark: The *4 comes from the fact that by blowing up we lose a factor
#         of 4 in scalars, they are now in the projective group.
Print("\n");
