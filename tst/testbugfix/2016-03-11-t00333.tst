#2016/3/11 (AH, reported by CJ)
gap> g := Group([ (1,2,3), (2,3,4) ]);;
gap> IsAlternatingGroup(g);
true
gap> Size(Stabilizer(g, [ [1,2], [3,4] ], OnSetsSets));
4
