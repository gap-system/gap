co3 := CharacterTable("Co3");
gens := AtlasGenerators("Co3",1).generators;
g := Group(gens);

ct1 := CharacterTable("McL.2");
s := AtlasStraightLineProgram("Co3",1).program;
gens1 := ResultOfStraightLineProgram(s,gens);
g1 := Group(gens1);
Print("Got g1\n");

ct2 := CharacterTable(Maxes(ct1)[2]);  # this is U4(3).2_3
s := StraightLineProgram( [ [1,1,2,1], [[1,2,2,1,1,1],[3,3,2,1,1,2]] ], 2);
gens2 := ResultOfStraightLineProgram(s,gens1);
g2 := Group(gens2);
Print("Got g2\n");

s := StraightLineProgram( [ [1,1,2,2], [[2,3,3,1],[3,1,2,1,3,1,1,1],
                                        [1,1,2,1,1,2,2,1,1,2,2,1,1,1]] ], 2);
gens3 := ResultOfStraightLineProgram(s,gens2);
g3 := Group(gens3);
Print("Got g3\n");
ct3 := CharacterTable(g3);
GenSift.MakeFus(ct3,ct2);

s := StraightLineProgram( [ [[2,3,3,1,2,1], [1,1,3,1,2,2,1,2]] ], 3);
gens4 := ResultOfStraightLineProgram(s,gens3);
g4 := Group(gens4);
Print("Got g4\n");
ct4 := CharacterTable(g4);
GenSift.MakeFus(ct4,ct3);

s := StraightLineProgram( [ [1,1,2,1], [[3,2],[2,1,1,1,2,4]] ], 2);
gens5 := ResultOfStraightLineProgram(s,gens4);
g5 := Group(gens5);
Print("Got g5\n");
ct5 := CharacterTable(g5);
GenSift.MakeFus(ct5,ct4);

s := StraightLineProgram( [ [[2,1,1,1],[1,1,2,2]] ], 2);
gens6 := ResultOfStraightLineProgram(s,gens5);
g6 := Group(gens6);
Print("Got g6\n");
ct6 := CharacterTable(g6);
GenSift.MakeFus(ct6,ct5);

s := StraightLineProgram( [ [[1,3]] ], 2);
a := ResultOfStraightLineProgram(s,gens6)[1];
g7 := Group(a);
Print("Got g7\n");
ct7 := CharacterTable(g7);
GenSift.MakeFus(ct7,ct6);

s := StraightLineProgram( [ [1,1,2,1],[3,1,2,2,1,2,2,2,3,1,1,2],
       [2,2,3,3,2,1,3,1,2,2,3,1],[3,2,2,2,3,2,2,1,1,2,2,3,1,2,2,2],
       [[4,1,6,1,4,1],[6,1,4,1,5,1,4,1]] ], 2);
cgens := ResultOfStraightLineProgram(s,gens);
c := Group(cgens);
s := StraightLineProgram( [ [1,1,2,1],
   [ [3,3,2,3],[1,2,2,3,1,1,3,2],[2,1,1,2,2,4,3,1,2,1] ] ], 2);
ngens := ResultOfStraightLineProgram(s,cgens);
n := Group(ngens);
aa := ngens[3]^3;   # an element from class 4h in c
s := StraightLineProgram( [ [1,1,2,1],
   [ [3,1,1,2,2,2,1,2,2,1,1,2], [3,1,1,2,2,2,3,2,2,1],
     [3,1,2,2,3,1,2,2,3,1,2,2] ] ], 2);
ccgens := ResultOfStraightLineProgram(s,cgens);
cc := Group(ccgens);   # The centralizer of aa
s := StraightLineProgram( [ [[1,2,3,1],[1,1,2,1,1,1,2,1]] ],3 );
cegens := ResultOfStraightLineProgram(s,ccgens);
ce := Group(cegens);   # its centre


