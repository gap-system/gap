gens := AtlasGenerators("Co2",11).generators;
x := PseudoRandom(GL(23,125));
xi := x^-1;
gens := List(gens,a->x*a*xi);
sfex1 := Group(gens);

gens2 := ShallowCopy(gens);
for i in [1..Length(gens2)] do
    gens2[i] := gens2[i] * Random(GF(5,3));
od;

sfex2 := Group(gens2);

Print("Two examples in sfex1 and sfex2.\n");
    
