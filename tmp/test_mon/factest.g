###############################
##
##  testing generic factoring methods in semigrp.gd
##
##

f := FreeSemigroup(["a","b","c"]);;
gens := GeneratorsOfSemigroup(f);;
rels:= [[gens[1],gens[2]]];;
cong := SemigroupCongruenceByGeneratingPairs(f, rels);;
g1 := HomomorphismFactorSemigroup(f, cong);;
g2 := HomomorphismFactorSemigroupByClosure(f, rels);;
g3 := FactorSemigroup(f, cong);;
g4 := FactorSemigroupByClosure(f, rels);;
# quotient of an fp semigroup
gens3 := GeneratorsOfSemigroup(g3);;
rels3 := [[gens3[1],gens3[2]]];;
cong3 := SemigroupCongruenceByGeneratingPairs(g3, rels3);;
q3 := FactorSemigroup(g3, cong3);;
# quotient of a transformation semigroup
a := Transformation([2,3,1,2]);;
s := Semigroup([a]);;
rels := [[a,a^2]];;
cong := SemigroupCongruenceByGeneratingPairs(s,rels);;
s/rels;;
s/cong;;

