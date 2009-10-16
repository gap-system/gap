LoadPackage("atlasrep");
Read("sift.g");
Read("sifttools.g");
ctco2 := CharacterTable("co2");
m := Maxes(ctco2);
m := List(m,CharacterTable);
gens := AtlasGenerators("Co2",1);
s := StraightLineProgram( [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],
      [ [ 3,1,4,1 ],5 ],[ [ 3,1,5,1 ],6 ],[ [ 6,1,3,1 ],7 ],
      [ [ 7,1,4,1 ],8 ],[ [ 3,1,8,1 ],9 ],[ [ 9,1,4,1 ],10 ],
      [ [ 10,1,10,1 ],11 ],[ [ 11,1,11,1 ],9 ],[ [ 10,1,11,1 ],8 ],
      [ [ 9,1,8,1 ],1 ],[ [ 3,1,3,1 ],10 ],[ [ 5,1,5,1 ],11 ],
      [ [ 11,1,11,1 ],8 ],[ [ 10,1,8,1 ],9 ],[ [ 6,1,6,1 ],10 ],
      [ [ 10,1,10,1 ],11 ],[ [ 10,1,11,1 ],6 ],[ [ 9,-1 ],8 ],
      [ [ 8,1,6,1 ],10 ],[ [ 10,1,9,1 ],2 ],[ [ 1,1 ],12 ],
      [ [ 2,1 ],13 ],[ [ 12,1 ],1 ],[ [ 13,1 ],2 ],[ [ 1,1,2,1 ],3 ],
      [ [ 3,3,2,1 ],4 ],[ [ 1,1 ],14 ],[ [ 2,1 ],15 ],[ [ 4,3 ],16 ],
      [ [ 14,1 ],1 ],[ [ 15,1 ],2 ],[ [ 16,1 ],3 ],[ [ 1,1,2,1 ],4 ],
      [ [ 1,1,1,1 ],5 ],[ [ 4,1,2,1 ],6 ],[ [ 6,1,3,1 ],7 ],
      [ [ 3,1,5,1 ],8 ],[ [ 3,1,7,1 ],9 ],[ [ 2,1,3,1 ],10 ],
      [ [ 2,1,4,1 ],11 ],[ [ 8,1,9,1 ],12 ],[ [ 3,1,11,1 ],13 ],
      [ [ 2,1,10,1 ],14 ],[ [ 13,1,12,1 ],15 ],[ [ 2,1,15,1 ],16 ],
      [ [ 2,1,3,1 ],17 ],[ [ 17,1,5,1 ],18 ],[ [ 18,1,16,1 ],19 ],
      [ [ 14,1,5,1 ],20 ],[ [ 19,1,20,1 ],21 ],[ [ 21,-1 ],22 ],
      [ [ 22,1,1,1 ],23 ],[ [ 23,1,21,1 ],24 ],[ [ 16,1,14,1 ],25 ],
      [ [ 25,-1 ],26 ],[ [ 26,1,3,1 ],27 ],[ [ 27,1,25,1 ],28 ],
      [ [ 24,1 ],[ 28,1 ] ] ],2 );
g := Group(gens.generators);
l1gens := ResultOfStraightLineProgram(s,gens.generators);
l1 := Group(l1gens);
cycsslp := AtlasStraightLineProgram("Co2","cyclic");
cycs := ResultOfStraightLineProgram(cycsslp.program,gens.generators);
ct1 := m[3];
mm := List(Maxes(ct1),CharacterTable);
s := AtlasStraightLineProgram("McL",2);
l2gens := ResultOfStraightLineProgram(s.program,l1gens);
l2 := Group(l2gens);
ct2 := CharacterTable("M22");
s := StraightLineProgram( [ [2,1,1,1], 
        [[2,1,3,2,2,1,3,3,2,1], [2,1,3,1,2,1,3,2,2,1,3,1,2,2]] ],2 );
l3gens := ResultOfStraightLineProgram(s,l2gens);
l3 := Group(l3gens);
ct3 := CharacterTable(l3);
GenSift.MakeFus(ct3,ct2);
s := StraightLineProgram( [ [1,1,2,1], 
        [[1,2,2,1,1,3],[1,4,2,2,1,1],[3,2,1,2,2,1,1,1]] ],2 );
l4gens := ResultOfStraightLineProgram(s,l3gens);
l4 := Group(l4gens);
ct4 := CharacterTable(l4);
FusionConjugacyClasses(ct4,ct3);
a := l4.1 * l4.2;
# Now to the centralizer of a in g:
s := StraightLineProgram( [ [ 1, 1, 2, 1 ], [ 2, 1, 1, 1 ], [ 2, 1, 2, 1 ],
  [ 3, 1, 1, 1 ], [ 3, 1, 2, 1 ], [ 4, 1, 2, 1 ], [ 5, 1, 1, 1 ],
  [ 6, 1, 2, 1 ], [ 7, 1, 1, 1 ], [ 8, 1, 2, 1 ], [ 9, 1, 2, 1 ],
  [ 10, 1, 1, 1 ], [ 11, 1, 2, 1 ], [ 12, 1, 2, 1 ], [ 13, 1, 1, 1 ],
  [ 13, -1 ], [ 17, 1, 18, 1 ], [ 13, 1, 2, 1 ], [ 14, 1, 2, 1 ],
  [ 15, 1, 2, 1 ], [ 16, 1, 1, 1 ], [ 16, 1, 2, 1 ], [ 20, 1, 2, 1 ],
  [ 21, 1, 2, 1 ], [ 22, 1, 1, 1 ], [ 23, 1, 2, 1 ], [ 24, 1, 1, 1 ],
  [ 25, 1, 1, 1 ], [ 26, 1, 2, 1 ], [ 27, 1, 2, 1 ], [ 28, 1, 1, 1 ],
  [ 29, 1, 2, 1 ], [ 30, 1, 2, 1 ], [ 31, 1, 1, 1 ], [ 32, 1, 2, 1 ],
  [ 33, 1, 2, 1 ], [ 34, 1, 1, 1 ], [ 35, 1, 1, 1 ], [ 36, 1, 2, 1 ],
  [ 37, 1, 2, 1 ], [ 38, 1, 1, 1 ], [ 39, 1, 2, 1 ], [ 40, 1, 2, 1 ],
  [ 41, 1, 1, 1 ], [ 42, 1, 2, 1 ], [ 43, 1, 2, 1 ], [ 44, 1, 1, 1 ],
  [ 45, 1, 1, 1 ], [ 46, 1, 2, 1 ], [ 47, 1, 1, 1 ], [ 47, -1 ],
  [ 52, 1, 53, 1 ], [ 48, 1, 1, 1 ], [ 48, -1 ], [ 55, 1, 56, 1 ],
  [ 49, 1, 2, 1 ], [ 50, 1, 2, 1 ], [ 51, 1, 2, 1 ], [ 58, 1, 1, 1 ],
  [ 58, -1 ], [ 61, 1, 62, 1 ], [ 59, 1, 1, 1 ], [ 60, 1, 1, 1 ], [ 60, -1 ],
  [ 65, 1, 66, 1 ], [ 64, 1, 2, 1 ], [ 68, 1, 1, 1 ], [ 68, -1 ],
  [ 69, 1, 70, 1 ],
  [ [ 19, 1 ], [ 54, 1 ], [ 57, 1 ], [ 63, 1 ], [ 67, 1 ], [ 71, 1 ] ] ], 2 );
cgens := ResultOfStraightLineProgram(s,gens.generators);
c := Group(cgens);
l5 := c;
#ct5 := CharacterTable(Maxes(ctco2)[6]);
#l := List(ConjugacyClasses(c),Representative);
#p := Position(List(l,Order),24);
#x := l[p];
#h := SmallerDegreePermutationRepresentation(l5);
#ll5 := Image(h);
#xx := Image(h,x);
#ll6 := Centralizer(ll5,xx^6);
#ll7 := Centralizer(ll5,xx^3);
#ll8 := Centralizer(ll5,xx);
ct5 := CharacterTable(Maxes(ctco2)[6]);
ss6 := StraightLineProgram(
  [ [3,1,4,1],[[7,2],[3,1,6,1,2,1,6,1],[1,1,4,1,3,1,6,1,1,1]] ],6);
l6 := Group(ResultOfStraightLineProgram(ss6,GeneratorsOfGroup(l5)));
ct6 := CharacterTable(l6);
GenSift.MakeFus(ct6,ct5);
ss7 := StraightLineProgram(
  [ [ [3,1,1,1,2,1],[3,2,1,1,3,1],[1,1,3,1,2,1,3,1,1,1,2,1,1,1,3,1] ] ],3);
l7 := Group(ResultOfStraightLineProgram(ss7,GeneratorsOfGroup(l6)));
ct7 := CharacterTable(l7);
FusionConjugacyClasses(ct7,ct6);
ss8 := StraightLineProgram(
  [ [ 3,1,1,1,3,1 ] ], 3);
l8 := Group(ResultOfStraightLineProgram(ss8,GeneratorsOfGroup(l7)));
ct8 := CharacterTable(l8);
FusionConjugacyClasses(ct8,ct7);
# dies liefert xx mit l5,6,7,8 = C_l5(xx^12,xx^6,xx^3,xx)
xx := GeneratorsOfGroup(l8)[1];
# in ll7 = Centralizer(ll7,xx);
el2eslp := StraightLineProgram( [[1,2,3,1,2,1,3,2]], 3 );
el2e := ResultOfStraightLineProgram(el2eslp,GeneratorsOfGroup(l7));
# Das benutzen wir, um in C_l5(el2e) = 49152 zu kommen:
s := StraightLineProgram( [[ [2,1,6,1,2,1],[1,1,2,1,5,1,2,1],[1,1,5,1,1,1,6,1],
    [2,1,3,1,4,1,3,1,2,1] ]],6);
# macht C_l5(el2e) aus l5
cc := Group(ResultOfStraightLineProgram(s,GeneratorsOfGroup(l5)));
fus := CompositionMaps(GetFusionMap(ct6,ct5),GetFusionMap(ct7,ct6));
StoreFusion(ct7,fus,ct5);


