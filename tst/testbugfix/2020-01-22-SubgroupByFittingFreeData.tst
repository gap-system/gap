# Induced FFLS, Issue #3864
gap> g:= Group( (1,2,3)(7,8)(12,13), (1,3)(2,4,5)(6,7,9,12,11,8,10,13),
>               (1,4,3)(6,7)(8,11)(9,13)(10,12) );;
gap> max:=MaximalSubgroupClassReps(g);;
gap> Length(ConjugacyClasses(max[1]));
26
