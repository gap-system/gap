Read("demo/bench.g");

ParMatrixMultiplyRow := function(m1, m2, i)
  local result, j, k, n, s;
  result := [];
  atomic readonly m1, readonly m2 do
    n := Length(m1);
    for j in [1..n] do
      s := 0;
      for k in [1..n] do
	s := s + m1[i][k] * m2[k][j];
      od;
      result[j] := s;
    od;
  od;
  return result;
end;

SeqMatrixMultiplyRow := function(m1, m2, i)
  local result, j, k, n, s;
  result := [];
  n := Length(m1);
  for j in [1..n] do
    s := 0;
    for k in [1..n] do
      s := s + m1[i][k] * m2[k][j];
    od;
    result[j] := s;
  od;
  return result;
end;


ParMatrixMultiply := function(m1, m2)
  local tasks, result;
  ShareObj([m1, m2]);
  atomic readonly m1, readonly m2 do
    tasks :=
      List([1..Length(m1)], i -> RunTask(ParMatrixMultiplyRow, m1, m2, i));
    result := List(tasks, TaskResult);
  od;
  atomic m1, m2 do
    AdoptObj(m1);
    AdoptObj(m2);
  od;
  return result;
end;

SeqMatrixMultiply := function(m1, m2)
  local result;
  result :=
    List([1..Length(m1)], i -> SeqMatrixMultiplyRow(m1, m2, i));
  return result;
end;

ConstantMatrix := function(n, c)
  return List([1..n], x -> List([1..n], x->c));
end;

if not IsBound(R) then
  R := PolynomialRing(GF(7), ["x"]);
  # R := PolynomialRing(GF(7), ["x", "y", "z"]);
  I := IndeterminatesOfPolynomialRing(R);
  x := I[1];
fi;

RandomPolynomial := function(s, r, ind, n, m)
  local p, q, i, j, k;
  p := Zero(R);
  for i in [1..Random(s, [0..n])] do
    q := One(R);
    for j in [1..m] do
      k := Random(s, [0..Length(ind)]);
      if k > 0 then
	q := q * ind[k];
      fi;
    od;
    p := p + q;
  od;
  return p;
end;

PopulateMatrix := function(n, f)
  return List([1..n], x -> List([1..n], x->f()));
end;

# First, see if it works
#m1 := [ [ 0, 1 ], [ 1, 0 ] ];
#m2 := [ [ 1, 2 ], [ 3, 4 ] ];
#m := ParMatrixMultiply(m1, m2);
#Display(m);
#m := SeqMatrixMultiply(m1, m2);
#Display(m);

#p := x * x + x + 1;
#m1 := ConstantMatrix(N, p);
#m2 := ConstantMatrix(N, p);

N := 70;
MT := RandomSource(IsMersenneTwister, 1);

m1 := PopulateMatrix(N, -> RandomPolynomial(MT, R, I, 5, 3));
m2 := PopulateMatrix(N, -> RandomPolynomial(MT, R, I, 5, 3));

m := fail;
t := Bench(do m := SeqMatrixMultiply(m1, m2); od);
Print("Sequential:  ", t, " seconds\n");
t := Bench(do m := ParMatrixMultiply(m1, m2); od);
Print("Parallel:    ", t, " seconds\n");
#Display(m = m1 * m2);
