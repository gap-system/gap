ct := CharacterTable("M12");
m := List(Maxes(ct),CharacterTable);
gens := AtlasGenerators("M12",1);
g := Group(gens.generators);
s := AtlasStraightLineProgram("M12",9);
gens1 := ResultOfStraightLineProgram(s.program,gens.generators);
g1 := Group(gens1);
ct1 := m[9];

