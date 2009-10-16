InstallMethod(\=, [IsRecognitionInfo,IsRecognitionInfo], IsIdenticalObj);


#utility function to check that parents and kernels are working.
SanityCheck:= function(ri)
local nri, i, bool;
nri:= StructuralCopy(ri);
i:= 0;
bool:= true;
while Haskernel(nri) and not kernel(nri) = fail do
  if not parent(factor(nri)) = nri then
    Print("factor error at level", i, "\n");
    bool:= false;
  fi;
  if not parent(kernel(nri)) = nri then
    Print("error: at level", i, "\n");
    bool:= false;
  fi;
  nri:= kernel(nri);
  i:= i+1;
od;
if not parent(factor(nri)) = nri then
  Print("factor error at level", i, "\n");
fi;
return bool;
end;

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


RandomConjugate := function(G)
# returns a random conjugate of G
 local d,F,t;
 d := DimensionOfMatrixGroup(G);
 F := FieldOfMatrixGroup(G);
 t := PseudoRandom(GL(d,F));
 return G^t;
end;

MyActionOnSubspace := function(B,g)
## Given a basis B of a subspace of the natural vector space for G ## return the action of g on B
 local im;
 im := List(B,x->Coefficients(B,x*g));
 return im;
end;

DiGroup := function(grp)
  #produces grp.2 acting as two diagonal blocks with outer aut interchaging them.
  local gens,d,g,M,i,j;
  gens := [];
  d:=DimensionOfMatrixGroup(grp);
  #write each generator as two identical diagonal blocks on twice the dimension.
  for g in GeneratorsOfGroup(grp) do
    M:=One(MatrixAlgebra(FieldOfMatrixGroup(grp),2*d));
    M:=MutableCopyMat(M);
    for i in [1..d] do
      for j in [1..d] do
        M[i][j]:=g[i][j];
        M[d+i][d+j]:=g[i][j];
      od;
    od;
    Add(gens,M);
  od;
  #add outer involution.
  M:=Zero(MatrixAlgebra(FieldOfMatrixGroup(grp),2*d));
  M:=MutableCopyMat(M);
    for i in [1..d] do
        M[i+d][i]:=One(FieldOfMatrixGroup(grp));
        M[i][d+i]:=-One(FieldOfMatrixGroup(grp));
    od;
  Add(gens,M);

  return GroupWithGenerators(gens);

end;
