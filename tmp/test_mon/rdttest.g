

########################
## Recursion Depth Trap
##

s:= Semigroup(Transformation([2, 2, 3, 4]),
	Transformation([2, 3, 4, 1]));
i:= SemigroupIdealByGenerators(s, [Transformation([2, 2, 2, 2])]);
r:= RightMagmaIdealByGenerators(i, [Transformation([2, 2, 2, 2])]);
Elements(r);

