#@local G, H, g, h, tmp, stabChain, s1, s2
gap> G := GroupWithMemory(GroupByGenerators([ (1,2,3,4,5), (1,2) ]));;
gap> H := GroupWithMemory(GL(IsMatrixGroup, 3, 3));;
gap> g := H.1 ^ 2;; h := H.2 ^ 2;;
gap> StripMemory(g);
[ [ Z(3)^0, 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0, 0*Z(3) ], 
  [ 0*Z(3), 0*Z(3), Z(3)^0 ] ]
gap> StripMemory([g, h]);
[ [ [ Z(3)^0, 0*Z(3), 0*Z(3) ], [ 0*Z(3), Z(3)^0, 0*Z(3) ], 
      [ 0*Z(3), 0*Z(3), Z(3)^0 ] ], 
  [ [ Z(3)^0, Z(3), Z(3) ], [ Z(3)^0, 0*Z(3), Z(3) ], 
      [ Z(3)^0, 0*Z(3), 0*Z(3) ] ] ]
gap> ForgetMemory(1);
Error, This object does not allow forgetting memory.
gap> ForgetMemory(H.1 ^ 2);
Error, You probably mean "StripMemory" instead of "ForgetMemory".
gap> ForgetMemory([g, h]);
gap> tmp := GroupWithMemory(GroupByGenerators([ (1,2,3,4,5), (1,2) ]));;
gap> stabChain := StabChainMutable(tmp);;
gap> stabChain.labels[1];
<() with mem>
gap> StripStabChain(stabChain);;
gap> stabChain.labels[1];
()
gap> s1 := SLPOfElm(g);;
gap> g = ResultOfStraightLineProgram(s1, GeneratorsOfGroup(H));
true
gap> s2 := SLPOfElms([g, h]);;
gap> [g, h] = ResultOfStraightLineProgram(s2, GeneratorsOfGroup(H));
true
gap> SLPOfElms([G.1, H.1]);
Error, SLPOfElms: the slp components of all elements must be identical
gap> g * h;
<[ [ Z(3)^0, Z(3), Z(3) ], [ Z(3)^0, 0*Z(3), Z(3) ], 
  [ Z(3)^0, 0*Z(3), 0*Z(3) ] ] with mem>
gap> g * G.1;
Error, \* for objects with memory: a!.slp and b!.slp must be identical
