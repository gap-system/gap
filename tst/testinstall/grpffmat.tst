#@local intA, intB, intMats, gf2Mats, gf8Mats, gf8MatsNonCompressed, G
gap> intA := [[0, 1], [-1, 0]];; intB := [[1,1], [0,1]];;
gap> intMats := [intA, intB];;

# DefaultScalarDomainOfMatrixList
gap> gf2Mats := List(intMats, x -> ImmutableMatrix(GF(2), Z(2) * x));;
gap> GF(2) = DefaultScalarDomainOfMatrixList(gf2Mats);
true
gap> gf8Mats := List(intMats, x -> ImmutableMatrix(GF(8), Z(8) * x));;
gap> GF(8) = DefaultScalarDomainOfMatrixList(gf8Mats);
true
gap> gf8MatsNonCompressed := List(intMats, x -> Z(8) * x);;
gap> GF(8) = DefaultScalarDomainOfMatrixList(gf8MatsNonCompressed);
true

# NonemptyGeneratorsOfGroup
gap> not IsEmpty(NonemptyGeneratorsOfGroup(Group(gf2Mats)));
true
gap> G := GroupWithGenerators([], ImmutableMatrix(GF(2),
>                                                 IdentityMatrix(GF(2), 2)));;
gap> not IsEmpty(NonemptyGeneratorsOfGroup(G));
true
