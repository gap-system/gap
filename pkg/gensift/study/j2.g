ct := CharacterTable("J2");
ct1 := CharacterTable(Maxes(ct)[2]);
gens := AtlasGenerators("J2",1);
g := Group(gens.generators);
sr := PrepareSiftRecords(PreSift.J2,g);
ct2 := CharacterTable(sr[3].group);
ct3 := CharacterTable(sr[4].group);
GenSift.MakeFus(ct2,ct1);
GenSift.MakeFus(ct3,ct2);
