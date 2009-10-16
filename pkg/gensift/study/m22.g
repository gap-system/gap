# This I need to study a certain subgroup chain in M22:
# M22 > L3(4) > 2^4.A5 > A5 > S3 > C3
# g   > g1    > g2     > g3 > g4 > unnamed
# Then we are in the centralizer g5 (36 elements), there we can make:
# C_M22(2a) > C2xC2
# g5        > g6
gens := AtlasGenerators("M22",1).generators;
g := Group(gens);
ct := CharacterTable("M22");
ct1 := CharacterTable(Maxes(ct)[1]);
s := AtlasStraightLineProgram("M22",1);
gens1 := ResultOfStraightLineProgram(s.program,gens);
g1 := Group(gens1);
s := AtlasStraightLineProgram("L3(4)",1);
gens2 := ResultOfStraightLineProgram(s.program,gens1);
g2 := Group(gens2);
ct2 := CharacterTable(g2);
GenSift.MakeFus(ct2,ct1);
s := StraightLineProgram([ [ [1,1,2,2,1,1],[1,1,2,1,1,1,2,2] ] ],2);
gens3 := ResultOfStraightLineProgram(s,gens2);
g3 := Group(gens3);
ct3 := CharacterTable(g3);
GenSift.MakeFus(ct3,ct2);
s := StraightLineProgram([ [ [2,1,1,1,2,2],[2,2,1,1,2,1] ] ],2);
gens4 := ResultOfStraightLineProgram(s,gens3);
g4 := Group(gens4);
ct4 := CharacterTable(g4);
GenSift.MakeFus(ct4,ct3);
a := g4.1 * g4.2;  # has order 3
s := StraightLineProgram([ [1,1,2,1], [1,1,2,3],
    [ [3,3,2,1,4,2,3,2,2,1,4,1], [4,2,3,2,2,1,4,1,3,2,4,1,3,1] ] ],2);
gens5 := ResultOfStraightLineProgram(s,gens);
g5 := Group(gens5);   # = Centralizer(g,a)
ct5 := CharacterTable(g5);
s := StraightLineProgram([ [ [1,2,2,1,1,1,2,2],[1,2,2,2,1,1,2,1] ] ],2);
gens6 := ResultOfStraightLineProgram(s,gens5);
g6 := Group(gens6);   # normal Sylow-2-Subgroup in g5
ct6 := CharacterTable(g6);
GenSift.MakeFus(ct6,ct5);
