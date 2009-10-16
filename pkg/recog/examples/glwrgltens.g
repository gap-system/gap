f := function( l, d )
  local res,j;
  res := l[1];
  for j in [2..Length(l)] do
      res := res * d + l[j];
  od;
  return res;
end;

MakeBigRepresentation := function( gens, r )
  local a,b,bb,c,c2,cr,cyc,d,i,id,j,k,l,m,n,newgens,o;
  newgens := [];
  l := Length(gens);
  id := gens[1]^0;
  for i in [1..l] do
      m := KroneckerProduct( id, gens[i] );
      for j in [3..r] do
          m := KroneckerProduct( id,m );
      od;
      ConvertToMatrixRep(m);
      Add(newgens,m);
  od;
  m := 0*m;
  n := 0*m;
  d := Length(gens[1]);
  l := List([1..r],i->[0..d-1]);
  c := Cartesian(l);
  c2 := List(c,x->Permuted(x,(1,2)));
  cyc := PermList(Concatenation([2..r],[1]));
  cr := List(c,x->Permuted(x,cyc));
  o := One(gens[1][1][1]);
  for i in [1..Length(c)] do
      a := f(c[i],d)+1;
      b := f(c2[i],d)+1;
      bb := f(cr[i],d)+1;
      m[a][b] := o;
      n[a][bb] := o;
  od;
  Add(newgens,m);
  Add(newgens,n);
  return newgens;
end;

MakeAnotherBigRepresentation := function( gens, r )
  local a,b,bb,c,c2,cr,cyc,d,i,id,j,k,l,m,n,newgens,o;
  newgens := [];
  l := Length(gens);
  id := gens[1]^0;
  for i in [1..l] do
      m := KroneckerProduct( gens[i], gens[i] );
      for j in [3..r] do
          m := KroneckerProduct( gens[i],m );
      od;
      ConvertToMatrixRep(m);
      Add(newgens,m);
  od;
  m := 0*m;
  n := 0*m;
  d := Length(gens[1]);
  l := List([1..r],i->[0..d-1]);
  c := Cartesian(l);
  c2 := List(c,x->Permuted(x,(1,2)));
  cyc := PermList(Concatenation([2..r],[1]));
  cr := List(c,x->Permuted(x,cyc));
  o := One(gens[1][1][1]);
  for i in [1..Length(c)] do
      a := f(c[i],d)+1;
      b := f(c2[i],d)+1;
      bb := f(cr[i],d)+1;
      m[a][b] := o;
      n[a][bb] := o;
  od;
  Add(newgens,m);
  Add(newgens,n);
  return newgens;
end;
