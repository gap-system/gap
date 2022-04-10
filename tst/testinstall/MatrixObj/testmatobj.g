TestZeroVector := function(filt, ring, len)
  local i, vec, vec2;
  vec := ZeroVector(filt, ring, len);
  Assert(0, filt(vec) = true);
  Assert(0, BaseDomain(vec) = ring);
  Assert(0, Length(vec) = len);
  for i in [1..len] do
    if not IsZero(vec[i]) then Error("entry ", i," is ", vec[i], " and not zero"); fi;
  od;
  vec2 := ZeroVector(len, vec);
  if vec <> vec2 then Error("ZeroVector(len, vec) differs"); fi;
  vec2 := NewZeroVector(filt, ring, len);
  if vec <> vec2 then Error("NewZeroVector(filt, ring, len) differs"); fi;
  return vec;
end;

TestZeroMatrix := function(filt, ring, rows, cols)
  local i, j, mat, mat2;
  mat := ZeroMatrix(filt, ring, rows, cols);
  Assert(0, filt(mat) = true);
  Assert(0, BaseDomain(mat) = ring);
  Assert(0, NrRows(mat) = rows);
  Assert(0, NrCols(mat) = cols);
  for i in [1..rows] do
    for j in [1..cols] do
      if not IsZero(mat[i,j]) then Error("entry ", i,",",j," is ", mat[i,j], " and not zero"); fi;
    od;
  od;
  mat2 := ZeroMatrix(rows, cols, mat);
  if mat <> mat2 then Error("ZeroMatrix(rows, cols, mat) differs"); fi;
  mat2 := NewZeroMatrix(filt, ring, rows, cols);
  if mat <> mat2 then Error("NewZeroMatrix(filt, ring, rows, cols) differs"); fi;
  return mat;
end;

TestIdentityMatrix := function(filt, ring, degree)
  local i, j, mat, mat2;
  mat := IdentityMatrix(filt, ring, degree);
  Assert(0, filt(mat) = true);
  Assert(0, BaseDomain(mat) = ring);
  Assert(0, NrRows(mat) = degree);
  Assert(0, NrCols(mat) = degree);
  for i in [1..degree] do
    for j in [1..degree] do
      if i<>j and not IsZero(mat[i,j]) then
        Error("entry ", i,",",j," is not zero");
      elif i=j and not IsOne(mat[i,j]) then
        Error("diagonal entry ", i,",",j," is not one");
      fi;
    od;
  od;
  mat2 := IdentityMatrix(degree, mat);
  if mat <> mat2 then Error("IdentityMatrix(degree, mat) differs"); fi;
  mat2 := NewIdentityMatrix(filt, ring, degree);
  if mat <> mat2 then Error("NewIdentityMatrix(filt, ring, degree) differs"); fi;
  return mat;
end;

TestElementaryTransforms := function(mat, scalar)
    local i, j, copy, eq;
    Assert(0, NrRows(mat) >= 2);
    Assert(0, NrCols(mat) >= 2);

    # make an old-fashioned entry-wise copy of this matrix so we can compare
    # all changes made there independent of any special properties of the
    # matrix representation
    copy := [];
    for i in [1..NrRows(mat)] do
        copy[i] := [];
        for j in [1..NrCols(mat)] do
            copy[i,j] := mat[i,j];
        od;
    od;

    eq := function()
        local i, j;
        for i in [1..NrRows(mat)] do
            for j in [1..NrCols(mat)] do
                if copy[i,j] <> mat[i,j] then
                    return false;
                fi;
            od;
        od;
        return true;
    end;

    #
    #
    #
    for i in [1..NrRows(mat)] do
        MultMatrixRowLeft(mat,i,scalar);
        MultMatrixRowLeft(copy,i,scalar);
        if not eq() then Error("MultMatrixRowLeft(",i,",",scalar,") failure"); fi;
    od;

    for i in [1..NrRows(mat)] do
        MultMatrixRowRight(mat,i,scalar);
        MultMatrixRowRight(copy,i,scalar);
        if not eq() then Error("MultMatrixRowRight(",i,",",scalar,") failure"); fi;
    od;

    for i in [1..NrCols(mat)] do
        MultMatrixColumnLeft(mat,i,scalar);
        MultMatrixColumnLeft(copy,i,scalar);
        if not eq() then Error("MultMatrixColumnLeft(",i,",",scalar,") failure"); fi;
    od;

    for i in [1..NrCols(mat)] do
        MultMatrixColumnRight(mat,i,scalar);
        MultMatrixColumnRight(copy,i,scalar);
        if not eq() then Error("MultMatrixColumnRight(",i,",",scalar,") failure"); fi;
    od;

    #
    #
    #
    for i in [1..NrRows(mat)] do
        for j in [1..NrRows(mat)] do
            AddMatrixRowsLeft(mat,i,j,scalar);
            AddMatrixRowsLeft(copy,i,j,scalar);
            if not eq() then Error("AddMatrixRowsLeft(",i,",",j,",",scalar,") failure"); fi;
        od;
    od;

    for i in [1..NrRows(mat)] do
        for j in [1..NrRows(mat)] do
            AddMatrixRowsRight(mat,i,j,scalar);
            AddMatrixRowsRight(copy,i,j,scalar);
            if not eq() then Error("AddMatrixRowsRight(",i,",",j,",",scalar,") failure"); fi;
        od;
    od;

    for i in [1..NrCols(mat)] do
        for j in [1..NrCols(mat)] do
            AddMatrixColumnsLeft(mat,i,j,scalar);
            AddMatrixColumnsLeft(copy,i,j,scalar);
            if not eq() then Error("AddMatrixColumnsLeft(",i,",",j,",",scalar,") failure"); fi;
        od;
    od;

    for i in [1..NrCols(mat)] do
        for j in [1..NrCols(mat)] do
            AddMatrixColumnsRight(mat,i,j,scalar);
            AddMatrixColumnsRight(copy,i,j,scalar);
            if not eq() then Error("AddMatrixColumnsRight(",i,",",j,",",scalar,") failure"); fi;
        od;
    od;

    #
    #
    #
    for i in [1..NrRows(mat)] do
        for j in [1..NrRows(mat)] do
            SwapMatrixRows(mat,i,j);
            SwapMatrixRows(copy,i,j);
            if not eq() then Error("SwapMatrixRows(",i,",",j,") failure"); fi;
        od;
    od;

    for i in [1..NrCols(mat)] do
        for j in [1..NrCols(mat)] do
            SwapMatrixColumns(mat,i,j);
            SwapMatrixColumns(copy,i,j);
            if not eq() then Error("SwapMatrixColumns(",i,",",j,") failure"); fi;
        od;
    od;
end;
