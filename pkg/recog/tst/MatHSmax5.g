# MatReducible:
# Usage: ReadPackage("recog","tst/MatHSmax5.g");
LoadPackage("recog");
gens := AtlasGenerators("HS",11).generators;
s := AtlasStraightLineProgram("HS",5).program;
gens := ResultOfStraightLineProgram(s,gens);
g := GroupWithGenerators(gens);
Print("Testing MatReducible:\n");
RECOG.TestGroup(g,false,40320);
Print("\n");
