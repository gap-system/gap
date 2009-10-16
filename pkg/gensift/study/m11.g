# This I need to study m11 with a certain subgroup chain:
# M11 > A_6.2 > (C_3 x C_3).Q_8 > C_4
# g   > g1    > g2              > g3
m11 := CharacterTable("M11");
gens := AtlasGenerators("M11",1).generators;
g := Group(gens);
s := AtlasStraightLineProgram("M11",1);
gens1 := ResultOfStraightLineProgram(s.program,gens);
g1 := Group(gens1);
ct1 := CharacterTable(Maxes(m11)[1]);
s := StraightLineProgram( [[[1,1,2,2,1,1],[2,1,1,1,2,2]]],2);
gens2 := ResultOfStraightLineProgram(s,gens1);
g2 := Group(gens2);
ct2 := CharacterTable(g2);
GenSift.MakeFus(ct2,ct1);
#g3 := Group(g2.1*g3.1);
g3 := Group(g2.1*g2.2,g2.1^3*g2.2*g2.1);
ct3 := CharacterTable(g3);
GenSift.MakeFus(ct3,ct2);

