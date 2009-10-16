#WARNING:  Read this with Read(), _not_ ParRead()

#Environment: m1, m2t, result (three matrices)
#TaskInput:   i (row index of result matrix)
#TaskOutput:  result[i] (row of result matrix)
#Task:        Compute result[i] from i, m1, and m2
#UpdateEnvironment:  Given result[i] and i, modify result on all processes.

#===========================================================================
# Version 1:

ParInstallTOPCGlobalFunction( "ParMultMat", function(m1, m2)
  local i, n, m2t, result, DoTask, GetTaskOutput, UpdateEnvironment;
  n := Length(m1);
  result := [];
  m2t := TransposedMat(m2);

  DoTask := function(i) # i is task input
    local j, k, sum;
    result[i] := [];
    for j in [1..n] do
      sum := 0;
      for k in [1..n] do
        sum := sum + m1[i][k]*m2t[j][k];
      od;
      result[i][j] := sum;
    od;
    return result[i]; # return task output, row_i
  end;
  # GetTaskOutput executes only on the master
  GetTaskOutput := function(i, row_i) # task output is row_i
    return UPDATE_ACTION; # Pass on output and input to UpdateEnvironment
  end;
  # UpdateEnvironment executes on the master and on all slaves
  UpdateEnvironment := function(i, row_i) # task output is row_i
    result[i] := row_i;
  end;
  # We're done defining the task.  Let's do it now.
  MasterSlave( TaskInputIterator([1..n]), DoTask, GetTaskOutput,
               UpdateEnvironment );
  # result is defined on all processes;  return local copy of result
  return result;
end );

#===========================================================================
# Version 2:

#Environment: m1, m2t, result (three matrices)
#TaskInput:   [i,j] (indices of entry in result matrix)
#TaskOutput:  result[i][j] (value of entry in result matrix)
#Task:        Compute inner produce of row i of m1 by colum j of m1
#             ( Note that column j of m1 is also row j of m2t, the transpose )
#UpdateEnvironment:  Given result[i][j] and [i,j], modify result everywhere

ParInstallTOPCGlobalFunction( "ParRawMultMat", function(m1, m2)
  local i, j, k, n, m2t, sum, result, DoTask, GetTaskOutput, UpdateEnvironment;
  n := Length(m1);
  m2t := TransposedMat(m2);
  result := ListWithIdenticalEntries( Length(m2t), [] );

  DoTask := function( input )
    local i,j,k,sum;
    i:=input[1]; j:=input[2];
    sum := 0;
    for k in [1..n] do
      sum := sum + m1[i][k]*m2t[j][k];
    od;
    return sum;
  end;

  GetTaskOutput := function( input, output )
    return UPDATE_ACTION;
  end;

  UpdateEnvironment := function( input, output )
    local i, j;
    i := input[1]; j := input[2];
    result[i][j] := output;
    # result[i,j] := sum;
  end;

  BeginRawMasterSlave( DoTask, GetTaskOutput, UpdateEnvironment );
  for i in [1..n] do
    result[i] := [];
    for j in [1..n] do
      RawSetTaskInput( [i,j] );
      # sum := 0;
      # for k in [1..n] do
      #   sum := sum + m1[i][k]*m2t[j][k];
      # od;
      # result[i][j] := sum;
    od;
  od;
  EndRawMasterSlave();

  return result;
end );
