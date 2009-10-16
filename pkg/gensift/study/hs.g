ct := CharacterTable("HS");
m := List(Maxes(ct),CharacterTable);
gens := AtlasGenerators("HS",1);
g := Group(gens.generators);
s := AtlasStraightLineProgram("HS",1);
gens1 := ResultOfStraightLineProgram(s.program,gens.generators);
g1 := Group(gens1);
# Plan fuer Kette:
# C = C_HS(2a)=7680
# HS      -> C*M22
# C*M22   -> C*L3(4)
# C*L3(4) -> C*A6
# C*A6    -> C*A5
# C*A5    -> C*12      where 2^2 < 12 < A5 and 
# C*12    -> C*4 = 4
# 
# Plan fuer Involutionszentralisator C(2z)=7680:
# 3840 ist C(4x)
# 256 ist N(8y^2) in 3840
# 128 ist C(8y^2) in 3840
# 16 ist C(8y) in 3840

