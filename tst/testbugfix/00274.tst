# 2012/11/20 (BH)
gap> G := WreathProduct (CyclicGroup (IsPermGroup, 7), SymmetricGroup (5));
<permutation group of size 2016840 with 7 generators>
gap> IsPSolvable (G, 2);
false
gap> IsPSolvable (G, 3);
false
gap> IsPSolvable (G, 5);
false
gap> IsPSolvable (G, 7);
true
gap> IsPNilpotent(GL(3,2),2);
false
