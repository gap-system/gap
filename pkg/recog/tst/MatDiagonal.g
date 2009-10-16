# MatDiagonal:
# Usage: ReadPackage("recog","tst/MatDiagonal.g");
LoadPackage("recog");
m := IdentityMat(7,GF(5));
gens := [];
l := ShallowCopy(Elements(GF(5)));
RemoveSet(l,0*Z(5));
for i in [1..5] do
    n := MutableCopyMat(m);
    for j in [1..7] do
        n[j][j] := Random(l);
    od;
    Add(gens,n);
od;
g := GroupWithGenerators(gens);
Print("Testing MatDiagonal:\n");
RECOG.TestGroup(g,false,Size(g));
Print("\n");
