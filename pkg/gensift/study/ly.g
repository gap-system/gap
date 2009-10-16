ct := CharacterTable("Ly");
ct1s := CharacterTable("3.McL.2");
ct1 := CharacterTable("3.McL");
StoreFusion(ct1,
   CompositionMaps(GetFusionMap(ct1s,ct),GetFusionMap(ct1,ct1s)),ct);
gens := AtlasGenerators("Ly",3);
g := Group(gens.generators);
#
s := CompositionOfStraightLinePrograms(
         AtlasStraightLineProgram("McL.2",1).program,
         AtlasStraightLineProgram("Ly",2).program);
gensc := ResultOfStraightLineProgram(s,gens.generators);
c := Group(gensc);
# c is now 3.McL with standard generators
a := (c.1*c.2)^11;   # generates center, c = C_G(a)
#
# We now conjugate a (and C) to a' \in C but a \notin {a,a^-1} (and C') 
# using (g.1*g.2^2)^3*(g.1*g.2)^2 :
x := (g.1*g.2^2)^3*(g.1*g.2)^2;
gens1 := gensc;
l1 := Group(gens1);
#
gens1p := AtlasGenerators("3.McL",1).generators;
l1p := Group(gens1p);
#
s := AtlasStraightLineProgram("McL",8);
gens2 := ResultOfStraightLineProgram(s.program,gens1);
gens2p := ResultOfStraightLineProgram(s.program,gens1p);
l2 := Group(gens2);
l2p := Group(gens2p);
ct1s := CharacterTable("3x2.A8");
ct2 := CharacterTable("2.A8");
GenSift.MakeFus(ct2,ct1s);
StoreFusion(ct2,CompositionMaps(GetFusionMap(ct1s,ct1),GetFusionMap(ct2,ct1s)),
            ct1);
#
s := StraightLineProgram([[[2,2,1,1,2,1,1,1,2,2],[1,1,2,2,1,2,2,2,1,1]]],2);
gens3 := ResultOfStraightLineProgram(s,gens2);
gens3p := ResultOfStraightLineProgram(s,gens2p);
l3 := Group(gens3);
l3p := Group(gens3p);
d := l3.1^20;
dp := l3p.1^20;   #  ==> (checked) l3 = C_l2(d)
ct3 := CharacterTable(l3p);
GenSift.MakeFus(ct3,ct2);
#
e := l3.1^6*l3.2;
ep := l3p.1^6*l3p.2;
s := StraightLineProgram( [ [ [ 1,1,2,1 ],[ 1,3,2,1,1,3,2,1,1,1 ] ] ],2 );
# this goes down to N_l3(e) with 36 elements
gens4 := ResultOfStraightLineProgram(s,gens3);
gens4p := ResultOfStraightLineProgram(s,gens3p);
l4 := Group(gens4);
l4p := Group(gens4p);
ct4 := CharacterTable(l4p);
FusionConjugacyClasses(ct4,ct3);
#
s := StraightLineProgram( [ [ [ 1,1 ],[ 2,2 ] ] ],2 );
# this goes down to C_l3(e) with 18 elements
gens5 := ResultOfStraightLineProgram(s,gens4);
gens5p := ResultOfStraightLineProgram(s,gens4p);
l5 := Group(gens5);
l5p := Group(gens5p);
ct5 := CharacterTable(l5p);
FusionConjugacyClasses(ct5,ct4);
GenSift.MakeFus(ct5,ct4);  # why necessary???
