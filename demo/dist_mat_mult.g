Read("demo/bench.g");

DeclareGlobalFunction("MatrixMultiplyRow");
ParInstallGlobalFunction("MatrixMultiplyRow", function(row, m2)
  local result, j, k, n, s, mat;
  result := [];
  Print ("Shish Kebab is ", HaveReadAccess(m2), "\n");
  
  atomic readwrite m2 do
    if IsGlobalObjectHandle(m2) then
      Open(m2);
      Print ("fetching object\n");
      mat := GetHandleObj(m2);
    else
      mat :=m2;
    fi;
  od;
  
  Print ("Kamasutra\n");
  
  atomic readonly mat do
    n := Length(mat);
    for j in [1..n] do
      s := 0;
      for k in [1..n] do
        s := s + row[k] * mat[k][j];
      od;
      result[j] := s;
    od;
  od;
  Print ("About to return result ", result, "\n");
  return result;
end);


DistMatrixMultiply := function(m1, m2)
  local i, j, n, nodeId, tasks, result, chunkSize, matHandle, resHandle;  
  
  resHandle := []; tasks := []; result := [];
  n := NoProcs();
  chunkSize := Int(Length(m1)/n);
  
  # create a handle for matrix m2 that will be shipped to 
  # all nodes
  matHandle := CreateHandleFromObj(m2, ACCESS_TYPES.READ_ONLY);
  Open(matHandle);
  
  for i in [1..n] do 
    nodeId := i-1;          # processes in MPI are enumerated from 0..n-1
    if nodeId<>MyId() then
      RemoteCopyObj (matHandle, nodeId);
    fi;
    for j in [(i-1)*chunkSize+1..i*chunkSize] do
      if nodeId<>MyId() then
        tasks[j] := Tasks.CreateTask([MatrixMultiplyRow, m1[j], matHandle]);
        resHandle[j] := SendTask (tasks[j], nodeId);
      else
        tasks[j] := RunTask(MatrixMultiplyRow, m1[j], m2);
      fi;
    od;
  od;
  
  
  for nodeId in [0..n-1] do
    for j in [nodeId*chunkSize+1..(nodeId+1)*chunkSize] do
      if nodeId<>processId then
        Open(resHandle[j]);
        result[j] := GetHandleObj(resHandle[j]);
        Close(resHandle[j]);
      else
        result[j] := TaskResult(tasks[j]);
      fi;
    od;
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
#m1 := ConstantMatrix(N, 1);
#m2 := ConstantMatrix(N, 1);
#m := fail;
#t := Bench(do m := DistMatrixMultiply(m1, m2); od);
#Display(t);
#t := Bench(do m := SeqMatrixMultiply(m1, m2); od);
#Display(t);
ParFinish();
