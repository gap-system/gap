Read("demo/bench.g");

DeclareGlobalFunction("MatrixMultiplyRow");
ParInstallGlobalFunction("MatrixMultiplyRow", function(row, m2)
  local result, j, k, n, s;
  result := [];
  #Print(MPI_Comm_rank(), " I am ", ThreadID(CurrentThread()), " and regions are: row=", RegionOf(row), ", m2=", RegionOf(m2), "\n");
  n := Length(row);
  atomic readonly m2 do
    for j in [1..n] do
      s := 0;
      for k in [1..n] do
        s := s + row[k] * m2[k][j];
      od;
      result[j] := s;
    od;
  od;
  return result;
end);


DistMatrixMultiply := function(m1, m2)
  local i, j, n, nodeId, tasks, result, chunkSize, handles, r;  
  
  handles := []; tasks := []; result := [];
  n := NoProcs();
  chunkSize := Int(Length(m1)/n);
  
  for i in [1..n] do 
    nodeId := i-1; # processes in MPI are enumerated from 0..n-1
    if nodeId<>MyId() then
      handles[i] := RemoteCopyObj (m2, nodeId);
    fi;
    for j in [(i-1)*chunkSize+1..i*chunkSize] do
      if nodeId<>MyId() then
        tasks[i] := Tasks.CreateTask([MatrixMultiplyRow, m1[j], handles[i]]);
        SendTask (tasks[i], i-1);
      else
        tasks[i] := RunTask(MatrixMultiplyRow, m1[j], m2);
      fi;
    od;
  od;
  for i in [1..n] do
    result[i] := TaskResult(tasks[i]);
  od;
  return result;
end;

SeqMatrixMultiply := function(m1, m2)
  local result;
  result :=
    List([1..Length(m1)], i -> MatrixMultiplyRow(m1[i], m2));
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
m := DistMatrixMultiply(m1, m2);
Display(m);
m := SeqMatrixMultiply(m1, m2);
Display(m);
m1 := ConstantMatrix(N, 1);
m2 := ConstantMatrix(N, 1);
m := fail;
t := Bench(do m := DistMatrixMultiply(m1, m2); od);
Display(t);
t := Bench(do m := SeqMatrixMultiply(m1, m2); od);
Display(t);
ParFinish();
