#WARNING:  Read this with Read(), _not_ ParRead()
# Two versions from the manual are provided here.  The first version
#   is less efficient than the second.


#Environment: vectors (basis vectors), heads, nzheads, mat (matrix)
#TaskInput:   i (row index of matrix)
#TaskOutput:  List of (1) j and (2) row i of matrix, mat, reduced by vectors
#               j is the first non-zero element of row i
#Task:        Compute reduced row i from mat, vectors, heads
#UpdateEnvironment:  Given i, j, reduced row i, add new basis vector
#               to vectors and update heads[j] to point to it

#===========================================================================
# Version 1:

ParInstallTOPCGlobalFunction( "ParSemiEchelonMatInefficient", function( mat )
    local zero,      # zero of the field of <mat>
          nrows,     # number of rows in <mat>
          ncols,     # number of columns in <mat>
          vectors,   # list of basis vectors
          heads,     # list of pivot positions in 'vectors'
          i,         # loop over rows
          nzheads,   # list of non-zero heads
          DoTask, UpdateEnvironment;

    mat:= List( mat, ShallowCopy );
    nrows:= Length( mat );
    ncols:= Length( mat[1] );

    zero:= Zero( mat[1][1] );

    heads:= ListWithIdenticalEntries( ncols, 0 );
    nzheads := [];
    vectors := [];

    DoTask := function( i ) # taskInput = i
      local j,         # loop over columns
            x,         # a current element
            row;       # the row of current interest
      row := mat[i];
      # Reduce the row with the known basis vectors.
      for j in [ 1 .. Length(nzheads) ] do
          x := row[nzheads[j]];
          if x <> zero then
              AddRowVector( row, vectors[ j ], - x );
          fi;
      od;
      j := PositionNot( row, zero );
      if j <= ncols then return [j, row]; # return taskOutput
      else return fail; fi;
    end;
    UpdateEnvironment := function( i, taskOutput )
      local j, row;
      j := taskOutput[1];
      row := taskOutput[2];
      # We found a new basis vector.
      MultRowVector(row, Inverse(row[j]));
      Add( vectors, row );
      Add( nzheads, j);
      heads[j]:= Length( vectors );
    end;
    
    MasterSlave( TaskInputIterator( [1..nrows] ), DoTask, DefaultGetTaskOutput,
		 UpdateEnvironment );

    return rec( heads   := heads,
                vectors := vectors );
end );

#===========================================================================
# Version 2:

ParEval("globalTaskOutputs := []");

ParInstallTOPCGlobalFunction( "ParSemiEchelonMat", function( mat )
  local zero,      # zero of the field of <mat>
        nrows,     # number of rows in <mat>
        ncols,     # number of columns in <mat>
        vectors,   # list of basis vectors
        heads,     # list of pivot positions in 'vectors'
        i,         # loop over rows
        nzheads,   # list of non-zero heads
        DoTask, UpdateEnvironmentWithAgglom;

  mat:= List( mat, ShallowCopy );
  nrows:= Length( mat );
  ncols:= Length( mat[1] );

  zero:= Zero( mat[1][1] );

  heads:= ListWithIdenticalEntries( ncols, 0 );
  nzheads := [];
  vectors := [];

  DoTask := function( i )
      local j,         # loop over columns
            x,         # a current element
            row;       # the row of current interest
    if IsBound(globalTaskOutputs[TaskAgglomIndex])
        and i = globalTaskOutputs[TaskAgglomIndex][1] then
      # then this is a REDO_ACTION
      row := globalTaskOutputs[TaskAgglomIndex][2][2]; # recover last row value
    else row := mat[i];
    fi;
    # Reduce the row with the known basis vectors.
    for j in [ 1 .. Length(nzheads) ] do
      x := row[nzheads[j]];
      if x <> zero then
        AddRowVector( row, vectors[ j ], - x );
      fi;
    od;
    j := PositionNot( row, zero );

    # save [input, output] in case of new REDO_ACTION
    globalTaskOutputs[TaskAgglomIndex] := [ i, [j, row] ];

    if j <= ncols then return [j, row]; # return taskOutput
    else return fail; fi;
  end;
  
  # This version of UpdateEnvironment() expects a list of taskOutput's
  UpdateEnvironmentWithAgglom := function( listI, taskOutputs )
    local j, row, idx, tmp;
    for idx in [1..Length( taskOutputs )] do
      j := taskOutputs[idx][1];
      row := taskOutputs[idx][2];
      
      if idx > 1 then
        globalTaskOutputs[1] := [-1, [j, row] ];
        tmp := DoTask( -1 ); # Trick DoTask() into a REDO_ACTION
        if tmp <> fail then
          j := tmp[1];
          row := tmp[2];
        fi;
      fi;

      # We found a new basis vector.
      MultRowVector(row, Inverse(row[j]));
      Add( vectors, row );
      Add( nzheads, j);
      heads[j]:= Length( vectors );
    od;
  end;
    
  MasterSlave( TaskInputIterator( [1..nrows] ), DoTask, DefaultGetTaskOutput,
                UpdateEnvironmentWithAgglom, 5 ); #taskAgglom set to 5 tasks

  return rec( heads   := heads,
              vectors := vectors );
end );
