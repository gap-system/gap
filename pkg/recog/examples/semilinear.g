gens := ShallowCopy(AtlasGenerators("HS",9).generators);
c := CanonicalBasis(GF(GF(2),3));
Add(gens,Z(8)*gens[1]^0);
gens8 := List(gens,x->BlownUpMat(c,x));
for m in gens8 do ConvertToMatrixRep(m,2); od;
x := RandomUnimodularMat(60)*Z(2);
ConvertToMatrixRep(x,2);
xi := x^-1;
genssemi := List(gens8,y->x*y*xi);
m := GModuleByMats(genssemi,GF(2));

