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
