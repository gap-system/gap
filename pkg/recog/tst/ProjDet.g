# ProjDerived:
# Usage: ReadPackage("recog","tst/ProjDet.g");
LoadPackage("recog");
g := Group(AtlasGenerators("HS.2",15).generators);
Print("Testing ProjDet:\n");
RECOG.TestGroup(g,true,Size(CharacterTable("HS.2")));
Print("\n");
