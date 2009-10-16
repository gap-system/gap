DirectProductOfMatrixGroup := function(G,H)
  local gens,g,h,dG,dH,M,i,j;
  gens := [];
  dG:=DimensionOfMatrixGroup(G);
  dH:=DimensionOfMatrixGroup(H);
  for g in GeneratorsOfGroup(G) do
    M:=One(MatrixAlgebra(FieldOfMatrixGroup(G),dG+dH));
    M:=MutableCopyMat(M);
    for i in [1..dG] do
      for j in [1..dG] do
        M[i][j]:=g[i][j];
      od;
    od;
    Add(gens,M);
  od;
  for h in GeneratorsOfGroup(H) do
    M:=One(MatrixAlgebra(FieldOfMatrixGroup(G),dG+dH));
    M:=MutableCopyMat(M);
    for i in [1..dH] do  
      for j in [1..dH] do
        M[dG+i][dG+j]:=h[i][j];
      od;                      
    od;  
    Add(gens,M);
  od;
  return GroupWithGenerators(gens);
end;

TensorProductOfMatrixGroup := function(G,H)
 local gens,g,h;

 gens := [];
 for g in GeneratorsOfGroup(G) do
   for h in GeneratorsOfGroup(H) do
     Add(gens,KroneckerProduct(g,h));
   od;
 od;

 return GroupWithGenerators(gens);
end;

