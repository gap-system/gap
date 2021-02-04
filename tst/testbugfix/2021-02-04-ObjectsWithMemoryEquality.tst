# Equality operation for x with objects with memory, Pull Request #4239
gap> G := GroupWithMemory(GroupByGenerators([ (1,2,3,4,5), (1,2) ]));;
gap> x := GeneratorsOfGroup(G)[1];
<(1,2,3,4,5) with mem>
gap> y := StripMemory(x);
(1,2,3,4,5)
gap> x = y;
true

# This equality check was not implemented and resulted in an error
gap> y = x;
true
