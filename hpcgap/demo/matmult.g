Read("demo/bench.g");

ParMatrixMultiplyRow := function(m1, m2, i)
  local result, j, k, n, s;
  result := [];
  atomic readonly m1 do
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
  ShareObj(m1);
  LockAndMigrateObj(m2, m1);
  atomic readonly m1 do
    tasks :=
      List([1..Length(m1)], i -> RunTask(ParMatrixMultiplyRow, m1, m2, i));
    result := List(tasks, TaskResult);
  od;
  atomic m1 do
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

N := 200;

ConstantMatrix := function(n, c)
  local i, row, result;
  row := [];
  result := [];
  for i in [1..n] do
    Add(row, c);
  od;
  for i in [1..n] do
    Add(result, row);
  od;
  return result;
end;

# First, see if it works
m1 := [ [ 0, 1 ], [ 1, 0 ] ];
m2 := [ [ 1, 2 ], [ 3, 4 ] ];
m := ParMatrixMultiply(m1, m2);
Display(m);
m := SeqMatrixMultiply(m1, m2);
Display(m);
m1 := ConstantMatrix(N, 1);
m2 := ConstantMatrix(N, 1);
m := fail;
t := Bench(do m := ParMatrixMultiply(m1, m2); od);
Display(t);
t := Bench(do m := SeqMatrixMultiply(m1, m2); od);
Display(t);
