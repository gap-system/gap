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
  Assert(0, IsZero(mat));
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

TestStandardBasisVector := function(filt, ring, len, k)
  local i, vec, vec2;
  vec := StandardBasisVector(filt, ring, len, k);
  Assert(0, filt(vec) = true);
  Assert(0, BaseDomain(vec) = ring);
  Assert(0, Length(vec) = len);
  for i in [1..len] do
    if i = k then
      if not IsOne(vec[i]) then
        Error("entry ", i," is ", vec[i], " and not one");
      fi;
    elif not IsZero(vec[i]) then
      Error("entry ", i," is ", vec[i], " and not zero");
    fi;
  od;
  vec2 := StandardBasisVector(len, vec, k);
  if vec <> vec2 then Error("StandardBasisVector(len, vec) differs"); fi;
  return vec;
end;

TestIdentityMatrix := function(filt, ring, degree)
  local i, j, mat, mat2;
  mat := IdentityMatrix(filt, ring, degree);
  Assert(0, filt(mat) = true);
  Assert(0, BaseDomain(mat) = ring);
  Assert(0, NrRows(mat) = degree);
  Assert(0, NrCols(mat) = degree);
  Assert(0, IsOne(mat));
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

TestCompanionMatrix := function(filt, pol, ring)
  local degree, mat, i, j, mat2;

  degree:= Degree(pol);
  mat:= CompanionMatrix(filt, pol, ring);
  Assert(0, filt(mat) = true);
  Assert(0, BaseDomain(mat) = ring);
  Assert(0, NrRows(mat) = degree);
  Assert(0, NrCols(mat) = degree);
  for i in [1..degree] do
    for j in [1..degree-1] do
      if i <> j+1 and not IsZero(mat[i,j]) then
        Error("entry ", i,",",j," is not zero");
      elif i = j+1 and not IsOne(mat[i,j]) then
        Error("entry ", i,",",j," is not one");
      fi;
    od;
  od;
  mat2 := CompanionMatrix(pol, mat);
  if mat <> mat2 then Error("CompanionMatrix(pol, mat) differs"); fi;
  mat2 := NewCompanionMatrix(filt, pol, ring);
  if mat <> mat2 then Error("NewCompanionMatrix(filt, pol, ring) differs"); fi;
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

TestWholeMatrixTransforms := function(mat, scalar)
    local i, j, src, srcbefore, copy, srccopy, basedomain, same_entries;
    Assert(0, NrRows(mat) >= 1);
    Assert(0, NrCols(mat) >= 1);

    copy := [];
    src := [];
    for i in [1..NrRows(mat)] do
        copy[i] := [];
        src[i] := [];
        for j in [1..NrCols(mat)] do
            copy[i,j] := mat[i,j];
            src[i,j] := mat[(i mod NrRows(mat)) + 1, (j mod NrCols(mat)) + 1];
        od;
    od;
    basedomain := BaseDomain(mat);
    if IsPlistMatrixRep(mat) then
        src := NewMatrix(IsPlistMatrixRep, basedomain, NrCols(mat), src);
    elif IsGenericMatrixRep(mat) then
        src := NewMatrix(IsGenericMatrixRep, basedomain, NrCols(mat), src);
    elif Is8BitMatrixRep(mat) then
        ConvertToMatrixRep(src, basedomain);
    fi;
    srcbefore := StructuralCopy(src);
    srccopy := StructuralCopy(src);

    # Compare entrywise because these tests mix plain list snapshots with
    # matrix objects in specialized representations.
    same_entries := function(a, b)
        local i, j;
        for i in [1..NrRows(a)] do
            for j in [1..NrCols(a)] do
                if a[i,j] <> b[i,j] then
                    return false;
                fi;
            od;
        od;
        return true;
    end;

    AddMatrix(mat, src);
    AddMatrix(copy, srccopy);
    if not same_entries(mat, copy) then Error("AddMatrix(_,_) failure"); fi;
    if not same_entries(src, srcbefore) then Error("AddMatrix(_,_) source modified"); fi;

    AddMatrix(mat, src, scalar);
    AddMatrix(copy, srccopy, scalar);
    if not same_entries(mat, copy) then Error("AddMatrix(_,_,", scalar, ") failure"); fi;
    if not same_entries(src, srcbefore) then Error("AddMatrix(_,_,scalar) source modified"); fi;

    MultMatrixLeft(mat, scalar);
    MultMatrixLeft(copy, scalar);
    if not same_entries(mat, copy) then Error("MultMatrixLeft(", scalar, ") failure"); fi;

    MultMatrixRight(mat, scalar);
    MultMatrixRight(copy, scalar);
    if not same_entries(mat, copy) then Error("MultMatrixRight(", scalar, ") failure"); fi;

    MultMatrix(mat, scalar);
    MultMatrix(copy, scalar);
    if not same_entries(mat, copy) then Error("MultMatrix(", scalar, ") failure"); fi;
end;

TestPositionNonZeroInRow := function(mat)
    local ncols;

    # Make a matrix with specific pattern of the same kind as mat
    mat := Matrix([ [ 0, 1, 0, 1 ], [ 0, 0, 0, 0 ], [ 0, 0, 1, 0 ] ]
                  * One( BaseDomain( mat ) ), mat);

    ncols := NrCols(mat);
    if PositionNonZeroInRow(mat, 1) <> 2 then
        Error("PositionNonZeroInRow(_,1) failure");
    fi;
    if PositionNonZeroInRow(mat, 1, 2) <> 4 then
        Error("PositionNonZeroInRow(_,1,2) failure");
    fi;
    if PositionNonZeroInRow(mat, 1, 4) <> ncols + 1 then
        Error("PositionNonZeroInRow(_,1,4) failure");
    fi;
    if PositionNonZeroInRow(mat, 2) <> ncols + 1 then
        Error("PositionNonZeroInRow(_,2) zero-row failure");
    fi;
    if PositionNonZeroInRow(mat, 3) <> 3 then
        Error("PositionNonZeroInRow(_,3) failure");
    fi;
    if PositionNonZeroInRow(mat, 3, 3) <> ncols + 1 then
        Error("PositionNonZeroInRow(_,3,3) failure");
    fi;
end;

# Compare the methods for 'IsGenericMatrixRep' matrices over the field <F>
# with the arithmetic of plain lists of plain lists, and check that all
# results are stored and mutable as they should be.
# Returns the names of the failed checks.
TestGenericMatrixRep := function( F )
    local bad, rs, els, rnd, n, m, rows, rows2, rect, vl, wl, s, k, bdstr,
          F2, M, N, R, I, v, w, iv, zero, one, Check, CheckMat, CheckVec,
          Elementary, A, L, i, j, a, b, empty, cv;

    bad := [];
    Check := function( name, cond )
      if not cond then
        Add( bad, name );
      fi;
    end;

    # <A> must be a matrix over <bd> with entries <list> and <ncols> columns
    CheckMat := function( name, A, bd, list, ncols, mut )
      local U;
      if not IsGenericMatrixRep( A ) then
        Add( bad, name );
        return;
      fi;
      U := Unpack( A );
      Check( name, not IsList( A )
                   and ConstructingFilter( A ) = IsGenericMatrixRep
                   and IsIdenticalObj( BaseDomain( A ), bd )
                   and NrRows( A ) = Length( list ) and NrCols( A ) = ncols
                   and IsPlistRep( U ) and ForAll( U, IsPlistRep )
                   and U = list
                   and GEN_MAT_HAS_CANONICAL_ROWS( A )
                   and IsMutable( A ) = mut );
    end;

    # <x> must be a plist vector over <F> with entries <list>
    CheckVec := function( name, x, list, mut )
      Check( name, IsPlistVectorRep( x )
                   and IsIdenticalObj( BaseDomain( x ), F )
                   and IsPlistRep( x![ELSPOS] ) and Unpack( x ) = list
                   and IsMutable( x ) = mut );
    end;

    rs := RandomSource( IsMersenneTwister, 42 );
    if IsFinite( F ) then
      els := AsSSortedList( F );
      bdstr := Concatenation( "GF(", String( Size( F ) ), ")" );
      F2 := GF( Size( F )^2 );
    else
      els := [ -3 .. 3 ];
      bdstr := String( F );
      F2 := CF(4);
    fi;
    rnd := { nr, nc } -> List( [ 1 .. nr ],
                               i -> List( [ 1 .. nc ],
                                          j -> Random( rs, els ) ) );
    n := 5;
    m := 3;
    zero := Zero( F );
    one := One( F );
    repeat
      rows := rnd( n, n );
    until RankMat( rows ) = n and not IsOne( rows );
    rows2 := rnd( n, n );
    rect := rnd( m, n );
    vl := rnd( 1, n )[1];
    wl := rnd( 1, m )[1];

    # a scalar that is not an integer, and an invertible integer
    if IsFinite( F ) then
      s := First( Reversed( els ), x -> not IsZero( x ) );
    else
      s := 3/2;
    fi;
    k := 2;
    if Characteristic( F ) = 2 then
      k := 3;
    fi;

    M := Matrix( IsGenericMatrixRep, F, rows );
    N := Matrix( IsGenericMatrixRep, F, rows2 );
    R := Matrix( IsGenericMatrixRep, F, rect );
    I := MakeImmutable( Matrix( IsGenericMatrixRep, F, rows ) );

    # constructors
    CheckMat( "Matrix( filt, F, list )", M, F, rows, n, true );
    CheckMat( "Matrix, rectangular", R, F, rect, n, true );
    CheckMat( "MakeImmutable", I, F, rows, n, false );
    CheckMat( "Matrix( list, M )", Matrix( rows2, M ), F, rows2, n, true );
    CheckMat( "Matrix( list, I )", Matrix( rows2, I ), F, rows2, n, true );
    CheckMat( "Matrix( list, ncols, M )",
              Matrix( Concatenation( rect ), n, M ), F, rect, n, true );
    CheckMat( "Matrix( immutable list, M )",
              Matrix( Immutable( rows2 ), M ), F, rows2, n, true );
    CheckMat( "Matrix( M, N )", Matrix( M, N ), F, rows, n, true );
    CheckMat( "ZeroMatrix( filt, F, m, n )",
              ZeroMatrix( IsGenericMatrixRep, F, m, n ),
              F, NullMat( m, n, F ), n, true );
    CheckMat( "ZeroMatrix( m, n, I )", ZeroMatrix( m, n, I ),
              F, NullMat( m, n, F ), n, true );
    CheckMat( "IdentityMatrix( filt, F, n )",
              IdentityMatrix( IsGenericMatrixRep, F, n ),
              F, IdentityMat( n, F ), n, true );
    CheckMat( "IdentityMatrix( n, I )", IdentityMatrix( m, I ),
              F, IdentityMat( m, F ), m, true );
    CheckMat( "CompanionMatrix",
              CompanionMatrix( X( F )^2 + one, M ),
              F, [ [ zero, -one ], [ one, zero ] ], 2, true );
    Check( "rows of the input", ForAll( rows, IsPlistRep ) );

    # entries
    Check( "MatElm", ForAll( [ 1 .. m ], i -> ForAll( [ 1 .. n ],
                                 j -> R[i,j] = rect[i][j] ) ) );
    A := MutableCopyMatrix( R );
    L := List( rect, ShallowCopy );
    for i in [ 1 .. m ] do
      for j in [ 1 .. n ] do
        A[i,j] := rows[j][i];
        L[i][j] := rows[j][i];
      od;
    od;
    CheckMat( "SetMatElm", A, F, L, n, true );
    CheckMat( "SetMatElm, original", R, F, rect, n, true );

    # copies
    Check( "Unpack is a copy", not IsIdenticalObj( Unpack( M ), Unpack( M ) )
                               and IsMutable( Unpack( I ) )
                               and ForAll( Unpack( I ), IsMutable ) );
    for a in [ ShallowCopy, MutableCopyMatrix ] do
      CheckMat( NameFunction( a ), a( R ), F, rect, n, true );
      A := a( I );
      CheckMat( Concatenation( NameFunction( a ), "( I )" ),
                A, F, rows, n, true );
      MultMatrixRowLeft( A, 1, zero );
      CheckMat( Concatenation( NameFunction( a ), ", original" ),
                I, F, rows, n, false );
    od;
    CheckMat( "Immutable", Immutable( R ), F, rect, n, false );
    CheckMat( "StructuralCopy", StructuralCopy( R ), F, rect, n, true );
    CheckMat( "ExtractSubMatrix", ExtractSubMatrix( M, [ 4, 1 ], [ 2, 5, 3 ] ),
              F, rows{ [ 4, 1 ] }{ [ 2, 5, 3 ] }, 3, true );
    CheckMat( "ExtractSubMatrix( I )", ExtractSubMatrix( I, [ 1 .. 2 ], [ 3 ] ),
              F, rows{ [ 1 .. 2 ] }{ [ 3 ] }, 1, true );
    CheckMat( "ExtractSubMatrix, no rows", ExtractSubMatrix( M, [], [ 2, 5 ] ),
              F, [], 2, true );
    CheckMat( "ExtractSubMatrix, no columns", ExtractSubMatrix( M, [ 2, 5 ], [] ),
              F, [ [], [] ], 0, true );
    for a in [ [ [ 2, 3 ], [ 1, 2 ], [ 2 .. 4 ], [ 3 .. 5 ] ],
               [ [ 3, 1 ], [ 2, 5 ], [ 5, 1, 2 ], [ 1, 4, 2 ] ],
               [ [], [], [ 1 .. 2 ], [ 1 .. 2 ] ],
               [ [ 1 .. 2 ], [ 1 .. 2 ], [], [] ] ] do
      A := MutableCopyMatrix( N );
      L := List( rows2, ShallowCopy );
      CopySubMatrix( M, A, a[1], a[2], a[3], a[4] );
      L{ a[2] }{ a[4] } := rows{ a[1] }{ a[3] };
      CheckMat( "CopySubMatrix", A, F, L, n, true );
    od;
    CheckMat( "TransposedMat", TransposedMat( R ),
              F, TransposedMat( rect ), m, false );
    CheckMat( "TransposedMatMutable", TransposedMatMutable( I ),
              F, TransposedMat( rows ), n, true );
    CheckMat( "ChangedBaseDomain", ChangedBaseDomain( M, F2 ),
              F2, rows, n, true );
    CheckMat( "ChangedBaseDomain( I )", ChangedBaseDomain( I, F2 ),
              F2, rows, n, false );
    CheckMat( "ChangedBaseDomain, back",
              ChangedBaseDomain( ChangedBaseDomain( M, F2 ), F ),
              F, rows, n, true );

    # arithmetic; a result is immutable only if all arguments are
    CheckMat( "M + N", M + N, F, rows + rows2, n, true );
    CheckMat( "I + N", I + N, F, rows + rows2, n, true );
    CheckMat( "I + I", I + I, F, rows + rows, n, false );
    CheckMat( "M - N", M - N, F, rows - rows2, n, true );
    CheckMat( "I - I", I - I, F, rows - rows, n, false );
    CheckMat( "-M", -M, F, -rows, n, true );
    CheckMat( "-I", -I, F, -rows, n, false );
    CheckMat( "AdditiveInverseMutable", AdditiveInverseMutable( I ),
              F, -rows, n, true );
    CheckMat( "M * N", M * N, F, rows * rows2, n, true );
    CheckMat( "R * N", R * N, F, rect * rows2, n, true );
    CheckMat( "N * I", N * I, F, rows2 * rows, n, true );
    CheckMat( "I * I", I * I, F, rows * rows, n, false );
    CheckMat( "M^3", M^3, F, rows^3, n, true );
    CheckMat( "I^3", I^3, F, rows^3, n, false );
    CheckMat( "M^0", M^0, F, IdentityMat( n, F ), n, true );
    CheckMat( "M^-1", M^-1, F, rows^-1, n, true );
    CheckMat( "I^-1", I^-1, F, rows^-1, n, false );
    CheckMat( "M^-2", M^-2, F, rows^-2, n, true );
    CheckMat( "InverseMutable", InverseMutable( I ), F, rows^-1, n, true );
    Check( "InverseMutable, singular",
           InverseMutable( ZeroMatrix( n, n, M ) ) = fail
           and InverseMutable( Matrix( Concatenation( rows{ [ 1 .. n-1 ] },
                                           [ rows[1] ] ), M ) ) = fail );
    CheckMat( "Zero", Zero( M ), F, NullMat( n, n, F ), n, false );
    CheckMat( "ZeroMutable", ZeroMutable( I ), F, NullMat( n, n, F ), n, true );
    CheckMat( "ZeroSameMutability", ZeroSameMutability( I ),
              F, NullMat( n, n, F ), n, false );
    CheckMat( "ZeroMutable, rectangular", ZeroMutable( R ),
              F, NullMat( m, n, F ), n, true );
    CheckMat( "One", One( M ), F, IdentityMat( n, F ), n, false );
    CheckMat( "OneMutable", OneMutable( I ), F, IdentityMat( n, F ), n, true );
    CheckMat( "OneSameMutability", OneSameMutability( I ),
              F, IdentityMat( n, F ), n, false );

    # scalar multiples are mutable, integer multiples are sums
    for A in [ R, MakeImmutable( MutableCopyMatrix( R ) ) ] do
      CheckMat( "s * M", s * A, F, s * rect, n, true );
      CheckMat( "M * s", A * s, F, rect * s, n, true );
      CheckMat( "M / s", A / s, F, rect / s, n, true );
      CheckMat( "M * zero", A * zero, F, NullMat( m, n, F ), n,
                not IsInt( zero ) or IsMutable( A ) );
      CheckMat( "M / k", A / k, F, rect / k, n, true );
      CheckMat( "k * M", k * A, F, k * rect, n, IsMutable( A ) );
      CheckMat( "M * k", A * k, F, rect * k, n, IsMutable( A ) );
      CheckMat( "-7 * M", -7 * A, F, -7 * rect, n, IsMutable( A ) );
    od;

    # products with vectors
    v := Vector( IsPlistVectorRep, F, vl );
    w := Vector( IsPlistVectorRep, F, wl );
    iv := MakeImmutable( Vector( IsPlistVectorRep, F, vl ) );
    CheckVec( "M * v", M * v, rows * vl, true );
    CheckVec( "R * v", R * v, rect * vl, true );
    CheckVec( "I * v", I * v, rows * vl, true );
    CheckVec( "M * iv", M * iv, rows * vl, true );
    CheckVec( "I * iv", I * iv, rows * vl, false );
    CheckVec( "v * M", v * M, vl * rows, true );
    CheckVec( "w * R", w * R, wl * rect, true );
    CheckVec( "v * I", v * I, vl * rows, true );
    CheckVec( "iv * M", iv * M, vl * rows, true );
    CheckVec( "iv * I", iv * I, vl * rows, false );
    CheckVec( "v ^ M", v ^ M, vl * rows, true );
    CheckVec( "v, original", v, vl, true );
    if IsFinite( F ) and Size( F ) <= 256 then
      # compressed vectors are lists, the product is again compressed
      cv := CopyToVectorRep( vl, Size( F ) );
      Check( "M * compressed", M * cv = rows * vl and cv * M = vl * rows
             and ConstructingFilter( M * cv ) = ConstructingFilter( cv )
             and ConstructingFilter( cv * M ) = ConstructingFilter( cv ) );
    fi;
    if IsFinite( F ) and IsPrimeInt( Size( F ) ) then
      # vector objects that are neither lists nor plist vectors
      cv := Vector( IsZmodnZVectorRep, F, List( vl, IntFFE ) );
      Check( "M * zmodnz", IsZmodnZVectorRep( M * cv )
             and IsZmodnZVectorRep( cv * M )
             and Unpack( M * cv ) = rows * vl
             and Unpack( cv * M ) = vl * rows );
    fi;

    # elementary operations, compared with those for lists of lists
    Elementary := function( name, a )
      CallFuncList( ValueGlobal( name ), Concatenation( [ A ], a ) );
      CallFuncList( ValueGlobal( name ), Concatenation( [ L ], a ) );
      CheckMat( name, A, F, L, n, true );
    end;
    A := MutableCopyMatrix( R );
    L := List( rect, ShallowCopy );
    for a in [ s, k, zero ] do
      Elementary( "MultMatrixRowLeft", [ 2, a ] );
      Elementary( "MultMatrixRowRight", [ 3, a ] );
      Elementary( "AddMatrixRowsLeft", [ 1, 3, a ] );
      Elementary( "AddMatrixRowsRight", [ 3, 2, a ] );
      Elementary( "MultMatrixColumnLeft", [ 4, a ] );
      Elementary( "MultMatrixColumnRight", [ 1, a ] );
      Elementary( "AddMatrixColumnsLeft", [ 5, 1, a ] );
      Elementary( "AddMatrixColumnsRight", [ 2, 3, a ] );
      Elementary( "SwapMatrixRows", [ 1, 3 ] );
      Elementary( "SwapMatrixColumns", [ 2, 5 ] );
    od;
    CheckMat( "elementary operations, original", R, F, rect, n, true );
    Check( "PositionNonZeroInRow",
           ForAll( [ 1 .. m ], i ->
             PositionNonZeroInRow( A, i ) = PositionNonZero( L[i] )
             and ForAll( [ 0 .. n ], j -> PositionNonZeroInRow( A, i, j )
                                          = PositionNonZero( L[i], j ) ) ) );

    # properties and attributes
    Check( "IsZero", IsZero( Zero( M ) ) and IsZero( ZeroMatrix( m, n, M ) )
                     and not IsZero( M ) );
    Check( "IsOne", IsOne( One( M ) ) and not IsOne( M )
                    and not IsOne( ZeroMatrix( m, n, M ) ) );
    Check( "=", M = I and M = Matrix( rows, M ) and M <> N and M <> R
                and M <> ChangedBaseDomain( M, F2 )
                and R <> TransposedMat( R ) );
    for i in [ 1 .. 20 ] do
      a := rnd( 2, 2 );
      b := rnd( 2, 2 );
      Check( "<", ( Matrix( a, M ) < Matrix( b, M ) ) = ( a < b )
                  and not Matrix( a, M ) < Matrix( a, M ) );
    od;
    Check( "DeterminantMatrix",
           DeterminantMatrix( M ) = DeterminantMat( rows )
           and DeterminantMatrix( I ) = DeterminantMat( rows )
           and IsZero( DeterminantMatrix( Zero( M ) ) ) );
    Check( "TraceMat", TraceMat( M ) = Sum( [ 1 .. n ], i -> rows[i][i] ) );
    Check( "CharacteristicPolynomial",
           CharacteristicPolynomial( M ) = CharacteristicPolynomial( rows ) );
    Check( "MinimalPolynomial",
           MinimalPolynomial( M ) = MinimalPolynomial( rows ) );
    CheckMat( "KroneckerProduct", KroneckerProduct( R, N ),
              F, KroneckerProduct( rect, rows2 ), n * n, true );
    CheckMat( "KroneckerProduct( I, N )", KroneckerProduct( I, N ),
              F, KroneckerProduct( rows, rows2 ), n * n, true );
    CheckMat( "KroneckerProduct( I, I )", KroneckerProduct( I, I ),
              F, KroneckerProduct( rows, rows ), n * n, false );
    Check( "RowsOfMatrix", ForAll( RowsOfMatrix( R ), IsPlistVectorRep )
                           and List( RowsOfMatrix( R ), Unpack ) = rect );

    # printing is as for plain rows
    Check( "String", String( R ) = Concatenation(
             "NewMatrix(IsGenericMatrixRep,", bdstr, ",", String( n ), ",",
             String( rect ), ")" )
           and EvalString( String( R ) ) = R );
    Check( "PrintString", EvalString( PrintString( R ) ) = R );

    # empty matrices
    empty := { nr, nc } -> ZeroMatrix( IsGenericMatrixRep, F, nr, nc );
    for a in [ [ 0, 0 ], [ 0, n ], [ m, 0 ] ] do
      A := empty( a[1], a[2] );
      L := List( [ 1 .. a[1] ], i -> [] );
      CheckMat( "empty", A, F, L, a[2], true );
      CheckMat( "empty, ZeroMatrix( nr, nc, M )",
                ZeroMatrix( a[1], a[2], M ), F, L, a[2], true );
      CheckMat( "empty, Matrix( list, ncols, M )",
                Matrix( L, a[2], M ), F, L, a[2], true );
      CheckMat( "empty, as example", ZeroMatrix( m, n, A ),
                F, NullMat( m, n, F ), n, true );
      CheckMat( "empty, IdentityMatrix", IdentityMatrix( m, A ),
                F, IdentityMat( m, F ), m, true );
      CheckMat( "empty, A + A", A + A, F, L, a[2], true );
      CheckMat( "empty, A - A", A - A, F, L, a[2], true );
      CheckMat( "empty, -A", -A, F, L, a[2], true );
      CheckMat( "empty, ZeroMutable", ZeroMutable( A ), F, L, a[2], true );
      CheckMat( "empty, ShallowCopy", ShallowCopy( A ), F, L, a[2], true );
      CheckMat( "empty, MutableCopyMatrix", MutableCopyMatrix( A ),
                F, L, a[2], true );
      CheckMat( "empty, MakeImmutable", MakeImmutable( ShallowCopy( A ) ),
                F, L, a[2], false );
      CheckMat( "empty, TransposedMatMutable", TransposedMatMutable( A ),
                F, List( [ 1 .. a[2] ], i -> [] ), a[1], true );
      CheckMat( "empty, ExtractSubMatrix",
                ExtractSubMatrix( A, [ 1 .. a[1] ], [ 1 .. a[2] ] ),
                F, L, a[2], true );
      CheckMat( "empty, ChangedBaseDomain", ChangedBaseDomain( A, F2 ),
                F2, L, a[2], true );
      CheckMat( "empty, KroneckerProduct", KroneckerProduct( A, M ),
                F, List( [ 1 .. a[1] * n ], i -> [] ), a[2] * n, true );
      Check( "empty, properties", A = ShallowCopy( A ) and A <> M
                                  and not A < A and IsZero( A ) );
      CheckVec( "empty, A * v",
                A * Vector( IsPlistVectorRep, F, vl{ [ 1 .. a[2] ] } ),
                ListWithIdenticalEntries( a[1], zero ), true );
      CheckVec( "empty, v * A",
                Vector( IsPlistVectorRep, F, wl{ [ 1 .. a[1] ] } ) * A,
                ListWithIdenticalEntries( a[2], zero ), true );
    od;
    CheckMat( "empty, 0 x 0 inverse", InverseMutable( empty( 0, 0 ) ),
              F, [], 0, true );
    CheckMat( "empty, m x 0 times 0 x n", empty( m, 0 ) * empty( 0, n ),
              F, NullMat( m, n, F ), n, true );
    CheckMat( "empty, 0 x n times n x 0", empty( 0, n ) * empty( n, 0 ),
              F, [], 0, true );
    CheckMat( "empty, m x n times n x 0", R * empty( n, 0 ),
              F, List( [ 1 .. m ], i -> [] ), 0, true );
    CheckMat( "empty, 0 x m times m x n", empty( 0, m ) * R, F, [], n, true );

    return bad;
end;
