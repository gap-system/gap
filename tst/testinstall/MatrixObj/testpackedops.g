# Differential tests of the arithmetic, row, column and product methods of
# IsPackedMatrixRep and IsPackedVectorRep against IsGenericMatrixRep,
# IsPlistVectorRep and plain lists; see matobjpackedops.tst. Needs
# testpacked.g. Each test returns true, or prints what failed and returns
# false.

# The packed object P has the same words as a new one with its entries, so
# no garbage in padding or in words that rows share
PackedOpsClean := function( P )
  if IsPackedMatrixRep( P ) then
    return P = NewMatrix( IsPackedMatrixRep, BaseDomain( P ), NrCols( P ),
                          Unpack( P ) );
  fi;
  return P = Vector( IsPackedVectorRep, BaseDomain( P ), Unpack( P ) );
end;

# P packed, G generic or plist (or a plain list): same entries and shape
PackedOpsSame := function( P, G )
  local R;
  if IsList( G ) then
    return IsPackedVectorRep( P ) and Unpack( P ) = G and PackedOpsClean( P );
  fi;
  R := BaseDomain( G );
  if IsMatrixObj( G ) then
    return IsPackedMatrixRep( P ) and IsIdenticalObj( BaseDomain( P ), R )
           and NrRows( P ) = NrRows( G ) and NrCols( P ) = NrCols( G )
           and Unpack( P ) = Unpack( G ) and PackedOpsClean( P );
  fi;
  return IsPackedVectorRep( P ) and IsIdenticalObj( BaseDomain( P ), R )
         and Unpack( P ) = Unpack( G ) and PackedOpsClean( P );
end;

# X has the shape of the packed object P and the entries L; for results
# where the generic methods fail, such as s * M for 0 x n matrices
PackedOpsShaped := function( X, P, L )
  if IsPackedMatrixRep( P ) then
    return IsPackedMatrixRep( X ) and NrRows( X ) = NrRows( P ) and
           NrCols( X ) = NrCols( P ) and Unpack( X ) = L and
           PackedOpsClean( X );
  fi;
  return IsPackedVectorRep( X ) and Unpack( X ) = L and PackedOpsClean( X );
end;

# Scalars: entries of R, and integers including large ones
PackedOpsScalars := function( rs, R )
  local n;
  n := Size( R );
  return [ Zero( R ), One( R ), -One( R ), PackedTestEntry( rs, R ),
           PackedTestEntry( rs, R : uniform ), 0, 1, -1, 2, n, -n - 1,
           2^70 + 5, -2^70 - 3 ];
end;

# Index lists for positions 1..n: ranges with step 1 or other steps, lists,
# repeats, empty
PackedOpsIndexLists := function( rs, n )
  local res, a, b;
  res := [ [], [ 1 .. n ] ];
  if n = 0 then
    return res;
  fi;
  a := Random( rs, [ 1 .. n ] );
  b := Random( rs, [ a .. n ] );
  Append( res, [ [ a .. b ], [ n, n - 1 .. 1 ], [ 1, 3 .. 2 * QuoInt( n - 1, 2 ) + 1 ],
                 [ a ], [ b, a ], List( [ 1 .. 3 ], i -> Random( rs, [ 1 .. n ] ) ),
                 [ a, a ] ] );
  return res;
end;

# Expected position of the first nonzero entry of the list l after from
PackedOpsPosNonZero := function( l, from )
  local j;
  for j in [ Minimum( Maximum( from, 0 ), Length( l ) ) + 1 .. Length( l ) ] do
    if not IsZero( l[j] ) then
      return j;
    fi;
  od;
  return Length( l ) + 1;
end;

# Whole-object arithmetic of two packed objects P, Q of equal shape against
# their generic copies G, H, for all mutabilities
PackedOpsArith := function( rs, R, P, Q, G, H )
  local a, b, ga, gb, mut, s, X, Y, f;
  for mut in Tuples( [ true, false ], 2 ) do
    a := P; b := Q; ga := G; gb := H;
    if not mut[1] then a := Immutable( P ); ga := Immutable( G ); fi;
    if not mut[2] then b := Immutable( Q ); gb := Immutable( H ); fi;
    for f in [ \+, \- ] do
      X := f( a, b );
      if not PackedOpsSame( X, f( ga, gb ) ) or
         IsMutable( X ) <> ( mut[1] or mut[2] ) then
        return PackedTestFail( NameFunction( f ), " of ", Unpack( G ), " ",
                               Unpack( H ), " ", mut );
      fi;
    od;
    for f in [ AdditiveInverseMutable, AdditiveInverseImmutable,
               AdditiveInverseSameMutability, ZeroMutable, ZeroImmutable,
               ZeroSameMutability ] do
      X := f( a );
      Y := f( ga );
      if not PackedOpsSame( X, Y ) or IsMutable( X ) <> IsMutable( Y ) then
        return PackedTestFail( NameFunction( f ), " of ", Unpack( G ) );
      fi;
    od;
    if not PackedOpsSame( -a, -ga ) or IsMutable( -a ) <> mut[1] then
      return PackedTestFail( "unary minus of ", Unpack( G ) );
    fi;
    for s in PackedOpsScalars( rs, R ) do
      X := s * a;
      Y := a * s;
      if not ( PackedOpsShaped( X, a, s * Unpack( a ) ) and
               PackedOpsShaped( Y, a, Unpack( a ) * s ) )
         or IsMutable( X ) <> mut[1] or IsMutable( Y ) <> mut[1] then
        return PackedTestFail( "scalar ", s, " times ", Unpack( G ) );
      fi;
    od;
  od;
  return true;
end;

# Row and column operations, AddMatrix and MultMatrix on a copy of P, the
# same on a copy of G
PackedOpsRowCol := function( rs, R, P, G, Q, H )
  local m, n, A, B, s, i, j, step, ops, from;
  m := NrRows( P );
  n := NrCols( P );
  A := MutableCopyMatrix( P );
  B := MutableCopyMatrix( G );
  for step in [ 1 .. 12 ] do
    s := Random( rs, PackedOpsScalars( rs, R ) );
    ops := [];
    if m > 0 then
      i := Random( rs, [ 1 .. m ] );
      j := Random( rs, [ 1 .. m ] );
      Append( ops, [ [ SwapMatrixRows, i, j ], [ MultMatrixRowLeft, i, s ],
                     [ MultMatrixRowRight, i, s ],
                     [ AddMatrixRowsLeft, i, j, s ],
                     [ AddMatrixRowsRight, i, j, s ],
                     [ AddMatrixRowsLeft, i, i, s ] ] );
    fi;
    if n > 0 then
      i := Random( rs, [ 1 .. n ] );
      j := Random( rs, [ 1 .. n ] );
      Append( ops, [ [ SwapMatrixColumns, i, j ],
                     [ MultMatrixColumnLeft, i, s ],
                     [ MultMatrixColumnRight, i, s ],
                     [ AddMatrixColumnsLeft, i, j, s ],
                     [ AddMatrixColumnsRight, i, j, s ],
                     [ AddMatrixColumnsRight, j, j, s ] ] );
    fi;
    Append( ops, [ [ AddMatrix, Q ], [ AddMatrix, Q, s ], [ AddMatrix, A ],
                   [ MultMatrixLeft, s ], [ MultMatrixRight, s ] ] );
    for i in ops do
      if IsIdenticalObj( i[2], Q ) then
        CallFuncList( i[1], Concatenation( [ A ], i{ [ 2 .. Length( i ) ] } ) );
        CallFuncList( i[1], Concatenation( [ B, H ], i{ [ 3 .. Length( i ) ] } ) );
      elif IsIdenticalObj( i[2], A ) then
        # AddMatrix( A, A ): the source is the destination
        AddMatrix( A, A );
        AddMatrix( B, B );
      else
        CallFuncList( i[1], Concatenation( [ A ], i{ [ 2 .. Length( i ) ] } ) );
        CallFuncList( i[1], Concatenation( [ B ], i{ [ 2 .. Length( i ) ] } ) );
      fi;
      if not PackedOpsSame( A, B ) then
        return PackedTestFail( NameFunction( i[1] ), " ", i{ [ 2 .. Length( i ) ] },
                               " on ", Unpack( G ) );
      fi;
    od;
  od;

  # pivot search, against the rows of Unpack
  for i in [ 1 .. m ] do
    for from in [ -1, 0, 1, Random( rs, [ 0 .. n ] ), n - 1, n, n + 1, 2^70,
                  -2^70 ] do
      if PositionNonZeroInRow( A, i, from ) <>
         PackedOpsPosNonZero( Unpack( A )[i], from ) then
        return PackedTestFail( "PositionNonZeroInRow ", [ i, from ], " of ",
                               Unpack( A ) );
      fi;
    od;
    if PositionNonZeroInRow( A, i ) <> PackedOpsPosNonZero( Unpack( A )[i], 0 )
    then
      return PackedTestFail( "PositionNonZeroInRow ", i, " of ", Unpack( A ) );
    fi;
  od;
  return true;
end;

# Sub-matrices, rows, transposition of P (generic G); Q, H of the same shape
PackedOpsSub := function( rs, R, P, G, Q, H )
  local m, n, rows, cols, X, L, A, B, srows, drows, scols, dcols, i, k;
  m := NrRows( P );
  n := NrCols( P );
  for rows in PackedOpsIndexLists( rs, m ) do
    for cols in PackedOpsIndexLists( rs, n ) do
      X := ExtractSubMatrix( P, rows, cols );
      if not PackedOpsSame( X, ExtractSubMatrix( G, rows, cols ) ) or
         not IsMutable( X ) or
         not IsMutable( ExtractSubMatrix( Immutable( P ), rows, cols ) ) then
        return PackedTestFail( "ExtractSubMatrix ", rows, cols, " of ",
                               Unpack( G ) );
      fi;
    od;
  od;

  # CopySubMatrix: from Q into P, and from P into itself, with overlapping
  # rows and columns; the reference is list assignment, which reads first
  for k in [ 1 .. 8 ] do
    if m = 0 or n = 0 then
      break;
    fi;
    srows := Random( rs, PackedOpsIndexLists( rs, m ) );
    scols := Random( rs, PackedOpsIndexLists( rs, n ) );
    drows := List( srows, i -> Random( rs, [ 1 .. m ] ) );
    dcols := List( scols, i -> Random( rs, [ 1 .. n ] ) );
    if k mod 2 = 0 and IsRange( srows ) and IsRange( scols ) and
       Length( srows ) > 0 and Length( scols ) > 0 then
      # shifted ranges, which overlap their sources
      drows := [ 1 .. Length( srows ) ] + ( m - Length( srows ) );
      dcols := [ 1 .. Length( scols ) ];
    fi;
    for i in [ 1, 2 ] do
      A := MutableCopyMatrix( P );
      L := Unpack( P );
      if i = 1 then
        CopySubMatrix( Q, A, srows, drows, scols, dcols );
        L{ drows }{ dcols } := Unpack( Q ){ srows }{ scols };
      else
        CopySubMatrix( A, A, srows, drows, scols, dcols );
        L{ drows }{ dcols } := Unpack( P ){ srows }{ scols };
      fi;
      if Unpack( A ) <> L then
        return PackedTestFail( "CopySubMatrix ", [ i, srows, drows, scols,
                               dcols ], " of ", Unpack( P ) );
      fi;
    od;
  od;

  # rows and transposition
  X := RowsOfMatrix( P );
  if List( X, Unpack ) <> Unpack( G ) or IsMutable( X ) or
     ForAny( X, IsMutable ) or not ForAll( X, IsPackedVectorRep ) then
    return PackedTestFail( "RowsOfMatrix of ", Unpack( G ) );
  fi;
  for i in [ 1 .. m ] do
    X := PACKMAT_ROW( Immutable( P ), i );
    if not IsPackedVectorRep( X ) or not IsMutable( X ) or
       Unpack( X ) <> Unpack( G )[i] then
      return PackedTestFail( "PACKMAT_ROW ", i, " of ", Unpack( G ) );
    fi;
  od;
  if not PackedOpsSame( TransposedMatMutable( P ), TransposedMatMutable( G ) )
     or not IsMutable( TransposedMatMutable( Immutable( P ) ) )
     or not PackedOpsSame( TransposedMat( P ), TransposedMatMutable( G ) )
     or IsMutable( TransposedMat( P ) ) then
    return PackedTestFail( "transposition of ", Unpack( G ) );
  fi;
  return true;
end;

# Products: P (m x n) * Q (n x k), vectors, Kronecker, powers
PackedOpsProducts := function( rs, R, P, G, Q, H )
  local mut, a, b, X, v, w, gv, gw, s;
  for mut in Tuples( [ true, false ], 2 ) do
    a := P; b := Q;
    if not mut[1] then a := Immutable( P ); fi;
    if not mut[2] then b := Immutable( Q ); fi;
    X := a * b;
    if not PackedOpsSame( X, G * H ) or IsMutable( X ) <> ( mut[1] or mut[2] )
    then
      return PackedTestFail( "product of ", Unpack( G ), " ", Unpack( H ) );
    fi;
    # the generic Kronecker product is slow
    if NrRows( P ) * NrCols( P ) * NrRows( Q ) * NrCols( Q ) <= 40000 then
      X := KroneckerProduct( a, b );
      if not PackedOpsSame( X, KroneckerProduct( G, H ) ) or
         IsMutable( X ) <> ( mut[1] or mut[2] ) then
        return PackedTestFail( "Kronecker of ", Unpack( G ), " ", Unpack( H ) );
      fi;
    fi;

    # v * P, P * w
    v := Vector( IsPackedVectorRep, R, PackedTestList( rs, R, NrRows( P ) ) );
    w := Vector( IsPackedVectorRep, R, PackedTestList( rs, R, NrCols( P ) ) );
    gv := Vector( IsPlistVectorRep, R, Unpack( v ) );
    gw := Vector( IsPlistVectorRep, R, Unpack( w ) );
    if not mut[2] then
      v := Immutable( v ); w := Immutable( w );
    fi;
    X := v * a;
    if not PackedOpsSame( X, gv * G ) or IsMutable( X ) <> ( mut[1] or mut[2] )
       or not PackedOpsSame( v ^ a, gv * G ) then
      return PackedTestFail( "v * M for ", Unpack( v ), " ", Unpack( G ) );
    fi;
    X := a * w;
    if not PackedOpsSame( X, G * gw ) or IsMutable( X ) <> ( mut[1] or mut[2] )
    then
      return PackedTestFail( "M * v for ", Unpack( G ), " ", Unpack( w ) );
    fi;
  od;

  if NrRows( P ) = NrCols( P ) and NrRows( P ) > 0 then
    for s in [ 0, 1, 2, 5 ] do
      X := P ^ s;
      if Unpack( X ) <> Unpack( G ) ^ s or not PackedOpsClean( X ) then
        return PackedTestFail( "power ", s, " of ", Unpack( G ) );
      fi;
    od;
    if IsField( R ) then
      v := Vector( IsPackedVectorRep, R, PackedTestList( rs, R, NrRows( P ) ) );
      if Unpack( OnLines( v, P ) ) <> OnLines( Unpack( v ), Unpack( G ) ) then
        return PackedTestFail( "OnLines of ", Unpack( v ), " ", Unpack( G ) );
      fi;
    fi;
  fi;
  return true;
end;

# Vector operations on packed v, w of length len, against IsPlistVectorRep
# and lists
PackedOpsVectors := function( rs, R, len )
  local v, w, gv, gw, l, m, s, a, b, X, from, to, cols, dcols, f, i, c, j;
  l := PackedTestList( rs, R, len );
  m := PackedTestList( rs, R, len );
  v := Vector( IsPackedVectorRep, R, l );
  w := Vector( IsPackedVectorRep, R, m );
  gv := Vector( IsPlistVectorRep, R, l );
  gw := Vector( IsPlistVectorRep, R, m );
  if PackedOpsArith( rs, R, v, w, gv, gw ) <> true then
    return false;
  fi;
  s := Sum( [ 1 .. len ], i -> l[i] * m[i], Zero( R ) );
  if ScalarProduct( v, w ) <> s or v * w <> s or
     WeightOfVector( v ) <> WeightOfVector( gv ) or
     DistanceOfVectors( v, w ) <> DistanceOfVectors( gv, gw ) or
     PositionNonZero( v ) <> PositionNonZero( gv ) or
     PositionLastNonZero( v ) <> PositionLastNonZero( gv ) then
    return PackedTestFail( "vector functions of ", l, " ", m );
  fi;
  for from in [ -1, 0, 1, Random( rs, [ 0 .. len ] ), len - 1, len, len + 1,
                2^70, -2^70 ] do
    if PositionNonZero( v, from ) <> PackedOpsPosNonZero( l, from ) then
      return PackedTestFail( "PositionNonZero ", from, " of ", l );
    fi;
  od;

  # AddVector and MultVector, with and without ranges
  for i in [ 1 .. 10 ] do
    s := Random( rs, PackedOpsScalars( rs, R ) );
    from := Random( rs, [ 1 .. len + 1 ] );
    to := Random( rs, [ from - 1 .. len ] );
    if to = 0 then
      to := 1; from := 2;
    fi;
    a := ShallowCopy( v );
    b := ShallowCopy( gv );
    j := i mod 5;
    if j = 0 then
      AddVector( a, w ); AddVector( b, gw );
    elif j = 1 then
      AddVector( a, w, s ); AddVector( b, gw, s );
    elif j = 2 then
      AddVector( a, s, w ); AddVector( b, s, gw );
    elif from > to then
      # nothing, by the documentation; IsPlistVectorRep checks <to> anyway
      AddVector( a, w, s, from, to ); AddVector( a, s, a, from, to );
    elif j = 3 then
      AddVector( a, w, s, from, to ); AddVector( b, gw, s, from, to );
    else
      AddVector( a, s, a, from, to ); AddVector( b, s, b, from, to );
    fi;
    if not PackedOpsSame( a, b ) then
      return PackedTestFail( "AddVector ", [ j, s, from, to ], " of ", l, m );
    fi;
    for f in [ MultVectorLeft, MultVectorRight ] do
      a := ShallowCopy( v );
      b := ShallowCopy( gv );
      f( a, s );
      f( b, s );
      if not PackedOpsSame( a, b ) then
        return PackedTestFail( NameFunction( f ), " ", s, " of ", l );
      fi;
      f( a, s, from, to );
      if from <= to then
        f( b, s, from, to );
      fi;
      if not PackedOpsSame( a, b ) then
        return PackedTestFail( NameFunction( f ), " ", [ s, from, to ], " of ",
                               l );
      fi;
    od;
  od;

  # sub-vectors, copies into another vector and into the same
  for cols in PackedOpsIndexLists( rs, len ) do
    X := v{ cols };
    if not PackedOpsSame( X, l{ cols } ) or not IsMutable( X ) or
       not PackedOpsSame( ExtractSubVector( Immutable( v ), cols ), l{ cols } )
       or not IsMutable( ExtractSubVector( Immutable( v ), cols ) ) then
      return PackedTestFail( "sub-vector ", cols, " of ", l );
    fi;
    dcols := List( cols, i -> Random( rs, [ 1 .. len ] ) );
    for c in [ dcols, Reversed( dcols ) ] do
      a := ShallowCopy( v );
      b := ShallowCopy( l );
      CopySubVector( w, a, cols, c );
      b{ c } := m{ cols };
      if not PackedOpsSame( a, b ) then
        return PackedTestFail( "CopySubVector ", [ cols, c ], " of ", l, m );
      fi;
      a := ShallowCopy( v );
      b := ShallowCopy( l );
      CopySubVector( a, a, cols, c );
      b{ c } := l{ cols };
      if not PackedOpsSame( a, b ) then
        return PackedTestFail( "CopySubVector into itself ", [ cols, c ],
                               " of ", l );
      fi;
    od;
  od;
  if len > 1 then
    # overlapping ranges, both directions
    a := ShallowCopy( v );
    CopySubVector( a, a, [ 1 .. len - 1 ], [ 2 .. len ] );
    b := ShallowCopy( a );
    CopySubVector( b, b, [ 2 .. len ], [ 1 .. len - 1 ] );
    if Unpack( a ) <> Concatenation( [ l[1] ], l{ [ 1 .. len - 1 ] } ) or
       Unpack( b ) <> Concatenation( l{ [ 1 .. len - 1 ] }, [ l[len - 1] ] )
    then
      return PackedTestFail( "CopySubVector shift of ", l );
    fi;
  fi;

  # normed vectors, and OnLines
  c := PositionNonZero( l );
  if c > len then
    X := NormedRowVector( v );
    if X <> v then
      return PackedTestFail( "NormedRowVector of ", l );
    fi;
  elif IsUnit( R, l[c] ) then
    X := NormedRowVector( v );
    if Unpack( X ) <> Inverse( l[c] ) * l then
      return PackedTestFail( "NormedRowVector of ", l );
    fi;
  fi;
  return true;
end;

PackedOpsDims := function( R )
  local dims;
  dims := [ [ 0, 0 ], [ 0, 3 ], [ 3, 0 ], [ 1, 1 ], [ 2, 3 ], [ 3, 3 ],
            [ 4, 5 ] ];
  if Size( R ) = 2 then
    # rows per word: 64/ncols up to 32 columns, one row from 33 on
    Append( dims, [ [ 5, 21 ], [ 3, 32 ], [ 3, 33 ], [ 2, 63 ], [ 2, 64 ],
                    [ 3, 65 ] ] );
  else
    Add( dims, [ 6, 11 ] );
  fi;
  return dims;
end;

# Numbers of columns of the right factor of products
PackedOpsProductCols := function( R )
  if Size( R ) = 2 then
    # one row of the product per word, or rows of 2 or 3 words
    return [ 0, 1, 3, 33, 64, 65, 130 ];
  fi;
  return [ 0, 1, 3, 9 ];
end;

PackedOpsRing := function( R, seed )
  local rs, d, k, L, P, Q, G, H, N, NG, len;
  rs := RandomSource( IsMersenneTwister, seed );
  for d in PackedOpsDims( R ) do
    L := List( [ 1 .. d[1] ], i -> PackedTestList( rs, R, d[2] ) );
    P := NewMatrix( IsPackedMatrixRep, R, d[2], L );
    G := NewMatrix( IsGenericMatrixRep, R, d[2], L );
    L := List( [ 1 .. d[1] ], i -> PackedTestList( rs, R, d[2] ) );
    Q := NewMatrix( IsPackedMatrixRep, R, d[2], L );
    H := NewMatrix( IsGenericMatrixRep, R, d[2], L );
    if PackedOpsArith( rs, R, P, Q, G, H ) <> true or
       PackedOpsRowCol( rs, R, P, G, Q, H ) <> true or
       PackedOpsSub( rs, R, P, G, Q, H ) <> true then
      return false;
    fi;
    for k in PackedOpsProductCols( R ) do
      L := List( [ 1 .. d[2] ], i -> PackedTestList( rs, R, k ) );
      N := NewMatrix( IsPackedMatrixRep, R, k, L );
      NG := NewMatrix( IsGenericMatrixRep, R, k, L );
      if PackedOpsProducts( rs, R, P, G, N, NG ) <> true then
        return false;
      fi;
    od;
  od;
  for len in [ 0, 1, 2, 5, 31, 32, 33, 63, 64, 65, 100 ] do
    if PackedOpsVectors( rs, R, len ) <> true then
      return false;
    fi;
  od;
  return true;
end;
