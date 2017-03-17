TestLinAlg := function()
local p,e,q,f,a,b,c,m,n,x,y,i,j,k;
  p:=Random([1..400]);
  p:=NextPrimeInt(p);
  e:=Random([1..LogInt(65536,p)]);
  q:=p^e;
  f:=GF(q);
  a:=Random([1..200]);
  b:=Random([1..200]);
  c:=Random([1..200]);

  Print(">",a," ",b," ",c,":",f,"\n");
  m:=RandomMat(a,b,f);
  n:=RandomMat(b,c,f);
  x:=m*n;

  if Length(x)<>a then
    Error("rows of product");
  fi;

  if ForAny(x,i->Length(i)<>c) then
    Error("columns of product");
  fi;

  # now compute the product the hard way
  y:=[];
  for i in [1..a] do
    y[i]:=[];
    for j in [1..c] do
      y[i][j]:=Zero(f);
      for k in [1..b] do
        y[i][j]:=y[i][j]+m[i][k]*n[k][j];
      od;
    od;
  od;

  if x<>y then
    Error("arith error",i," ",j);
  fi;

  for i in [1..b] do
    x:=m[1][i]*n[i];
    y:=n[i]*m[1][i];
    if x<>y then
      Error("scalmul1");
    fi;
    for k in [1..c] do
      if x[k]<>m[1][i]*n[i][k] then
	Error("scalmul2");
      fi;
    od;

    x:=m[1][i]+n[i];
    y:=n[i]+m[1][i];
    if x<>y then
      Error("scaladd1");
    fi;
    for k in [1..c] do
      if x[k]<>m[1][i]+n[i][k] then
	Error("scaladd2");
      fi;
    od;

  od;

end;

DWIM:=function()
  repeat
    TestLinAlg();
  until false;
end;
