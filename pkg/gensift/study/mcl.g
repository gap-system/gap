gens := AtlasGenerators("McL",1);
g := Group(gens.generators);
s := AtlasStraightLineProgram("McL",1);
gens1 := ResultOfStraightLineProgram(s.program,gens.generators);
l1 := Group(gens1);
s := StraightLineProgram(
[ [ [ 1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 2, 2, 1, 1, 2, 1 ],
      [ 1, 1, 2, 2, 1, 1, 2, 1, 1, 1, 2, 2, 1, 1, 2, 4 ] ] ], 2 );
gens2 := ResultOfStraightLineProgram(s,gens1);
l2 := Group(gens2);
s := StraightLineProgram( [ [ [ 2,1,1,1,2,1 ],[ 1,1,2,1,1,3 ] ] ],2 );
gens3 := ResultOfStraightLineProgram(s,gens2);
l3 := Group(gens3);
s := StraightLineProgram( [ [ [ 1,1,2,1,1,2 ],[ 1,1,2,3 ] ] ],2 );
gens4 := ResultOfStraightLineProgram(s,gens3);
l4 := Group(gens4);
s := StraightLineProgram( [ [ [ 1,1 ],[ 2,2 ],[ 2,1,1,2,2,1 ] ] ],2 );
gens5 := ResultOfStraightLineProgram(s,gens4);
l5 := Group(gens5);
s := StraightLineProgram( [ [ [ 1,2 ],[ 2,1,1,1 ] ] ],3 );
gens6 := ResultOfStraightLineProgram(s,gens5);
l6 := Group(gens6);
s := StraightLineProgram(
    [ [ [ 2,4,1,1,2,1,1,1,2,1,1,1,2,4,1,1,2,4,1,1,2,1 ],
        [ 2,2,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,2,1,
          1,2,1,1,1,2,1,1,1,2,1,1,1,2,4 ] ] ],2 );
cgens := ResultOfStraightLineProgram( s, gens.generators );
c := Group(cgens);
ct := CharacterTable("McL");
ct1 := CharacterTable("U4(3)");
ct2 := CharacterTable("3^4:A6");
ct3 := CharacterTable(l3);
ct4 := CharacterTable(l4);
ct5 := CharacterTable(l5);
ct6 := CharacterTable(l6);
GenSift.MakeFus(ct3,ct2);
FusionConjugacyClasses(ct4,ct3);
FusionConjugacyClasses(ct5,ct4);
FusionConjugacyClasses(ct6,ct5);


