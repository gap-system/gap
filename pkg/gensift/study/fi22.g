gens := AtlasGenerators("Fi22",1);   
g := Group(gens.generators);         
ct0 := CharacterTable("Fi22");       
m := List(Maxes(ct0),CharacterTable);
s := StraightLineProgram( [ [[2,9,1,1,2,4],[2,10,1,1,2,3],
                             [1,1,2,2,1,1,2,1,1,1,2,8,1,1,2,2]] ], 2);
gens1 := ResultOfStraightLineProgram(s,gens.generators);
ct1 := m[1];
g1 := Group(gens1);
s := AtlasStraightLineProgram("Fi22","cyclic");
el6e := ResultOfStraightLineProgram(s.program,gens.generators)[1];
c1 := el6e^3;       # element of class 2a, g1 being its centralizer
a := g1.1 * g1.2;   # element of class 3a in g, lying in g1


PreSiftFi22 := [];
PreSiftFi22[1] := rec(
  # this does G=Fi22 -> C * T * C   with C = C_G(2a) = 2.U6(2) and T = {1,t2}
  # it is extremely unlikely that we land in C * {1} * C = C, but it can happen
  # otherwise we are in class 2c of C and can easily go down to C_C(3a)<C
  subgroupSLP := StraightLineProgram( [ [[2,9,1,1,2,4],[2,10,1,1,2,3],
      [1,1,2,2,1,1,2,1,1,1,2,8,1,1,2,2]] ], 2),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 347/1755 ),
  T := StraightLineProgram( [ [[1,0],[2,1]] ], 2 ),  # used further down
  ismember := rec(
    method := IsMemberConjugates,
    a := StraightLineProgram(
         [ [[ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],5 ],[ [ 5,1,2,1 ],6 ],
           [[ 3,1,6,1 ],7 ],[ [ 3,1,7,1 ],8 ],[ [ 8,1,6,1 ],9 ],
           [[ 2,1,8,1 ],11 ],[ [ 8,1,9,1 ],13 ],[ [ 5,1,9,1 ],15 ],
           [[ 13,1,15,1 ],17 ],[ [ 13,1,7,1 ],18 ],[ [ 7,1,18,1 ],23 ],
           [[ 23,1,11,1 ],24 ],[ [ 7,1,17,1 ],25 ],[ [ 1,1,25,1 ],31 ],
           [[ 17,1,24,1 ],32 ],[ [ 31,1,32,1 ],33 ],[ [ 33,3 ] ] ], 2),
    ismember := rec(
      method := IsMemberCentralizer,
      centof := StraightLineProgram(
         [ [[ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],5 ],[ [ 5,1,2,1 ],6 ],
           [[ 3,1,6,1 ],7 ],[ [ 3,1,7,1 ],8 ],[ [ 8,1,6,1 ],9 ],
           [[ 2,1,8,1 ],11 ],[ [ 8,1,9,1 ],13 ],[ [ 5,1,9,1 ],15 ],
           [[ 13,1,15,1 ],17 ],[ [ 13,1,7,1 ],18 ],[ [ 7,1,18,1 ],23 ],
           [[ 23,1,11,1 ],24 ],[ [ 7,1,17,1 ],25 ],[ [ 1,1,25,1 ],31 ],
           [[ 17,1,24,1 ],32 ],[ [ 31,1,32,1 ],33 ],[ [ 33,3 ] ] ], 2),
    ),
  ),
);
PreSiftFi22[2] := rec(
  # ...
  subgroupSLP := StraightLineProgram( [[1,0]],3 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 5/77 ),
  ismember := rec(
    method := IsMemberConjugates,
    a := "fromUp",
    ismember := rec(
      method := IsMemberCentralizer,
      centof := StraightLineProgram( [[[1,1,2,1]]], 3 ),
    ),
  ),
);
