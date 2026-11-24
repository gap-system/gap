# Differential tests of IsPackedMatrixRep and IsPackedVectorRep against
# Unpack, plain lists and IsGenericMatrixRep; see matobjpacked.tst.
# Each test returns true, or prints what failed and returns false.

PackedTestFail := function( arg )
  CallFuncList( Print, Concatenation( [ "FAIL: " ], arg, [ "\n" ] ) );
  return false;
end;

# Entries are zero, one, -1 or random, so that equal prefixes are common;
# with the option uniform, random, so that the order of FFEs by log, not
# by residue, decides most comparisons
PackedTestEntry := function( rs, R )
  local n;
  n := Size( R );
  if ValueOption( "uniform" ) = true then
    return Random( rs, 0, n - 1 ) * One( R );
  fi;
  return Random( rs, [ 0, 0, 1, n - 1, Random( rs, 0, n - 1 ) ] )
         * One( R );
end;

PackedTestList := function( rs, R, len )
  return List( [ 1 .. len ], j -> PackedTestEntry( rs, R ) );
end;

PackedTestDims := function( R )
  local dims;
  dims := [ [ 0, 0 ], [ 0, 3 ], [ 3, 0 ], [ 1, 1 ], [ 2, 3 ], [ 3, 2 ],
            [ 5, 5 ], [ 4, 7 ] ];
  if Size( R ) = 2 then
    # rows per word: 64/ncols up to 32 columns, one row from 33 on
    Append( dims, [ [ 70, 1 ], [ 9, 21 ], [ 3, 32 ], [ 3, 33 ], [ 2, 63 ],
                    [ 2, 64 ], [ 2, 65 ], [ 2, 130 ] ] );
  fi;
  return dims;
end;

# Compressed copy of a matrix or vector over GF(q), q <= 256, or fail
PackedTestCompressed := function( R, L )
  local C;
  if not ( IsField( R ) and Size( R ) <= 256 ) or Length( L ) = 0 then
    return fail;
  fi;
  if IsList( L[1] ) then
    if Length( L[1] ) = 0 then
      return fail;
    fi;
    C := List( L, ShallowCopy );
    ConvertToMatrixRep( C, Size( R ) );
    if not ( IsGF2MatrixRep( C ) or Is8BitMatrixRep( C ) ) then
      return PackedTestFail( "not compressed: ", L );
    fi;
  else
    C := ShallowCopy( L );
    ConvertToVectorRep( C, Size( R ) );
    if not ( IsGF2VectorRep( C ) or Is8BitVectorRep( C ) ) then
      return PackedTestFail( "not compressed: ", L );
    fi;
  fi;
  return C;
end;

# Construction, entries and round trips of one matrix
PackedTestMatrix := function( rs, R, L, nc )
  local P, G, C, i, j, x, L2;
  P := NewMatrix( IsPackedMatrixRep, R, nc, L );
  if not ( IsPackedMatrixRep( P ) and IsMutable( P )
           and IsIdenticalObj( BaseDomain( P ), R )
           and NrRows( P ) = Length( L ) and NrCols( P ) = nc ) then
    return PackedTestFail( "attributes of ", L );
  fi;
  if Unpack( P ) <> L or
     ForAny( [ 1 .. Length( L ) ], i ->
             ForAny( [ 1 .. nc ], j -> P[i,j] <> L[i][j] ) ) then
    return PackedTestFail( "entries of ", L );
  fi;
  if IsZero( P ) <> ForAll( L, r -> ForAll( r, IsZero ) ) or
     IsOne( P ) <> ( Length( L ) = nc and
                     L = IdentityMat( nc, R ) ) then
    return PackedTestFail( "IsZero or IsOne of ", L );
  fi;

  # round trips
  G := NewMatrix( IsGenericMatrixRep, R, nc, L );
  if Unpack( G ) <> Unpack( P )
     or Matrix( IsPackedMatrixRep, R, G ) <> P
     or Matrix( G, P ) <> P
     or Matrix( P, G ) <> G
     or Matrix( IsPackedMatrixRep, R, P ) <> P
     or NewMatrix( IsPackedMatrixRep, R, nc, Unpack( P ) ) <> P
     or NewMatrix( IsPackedMatrixRep, R, nc,
            List( L, r -> Vector( IsPackedVectorRep, R, r ) ) ) <> P
     or NewMatrix( IsPackedMatrixRep, R, nc,
            List( L, r -> Vector( IsPlistVectorRep, R, r ) ) ) <> P
     or ( nc > 0 and
          NewMatrix( IsPackedMatrixRep, R, nc, Concatenation( L ) ) <> P )
     or ( Length( L ) > 0 and Matrix( L, P ) <> P ) then
    return PackedTestFail( "round trip of ", L );
  fi;
  C := PackedTestCompressed( R, L );
  if C = false or
     ( C <> fail and ( NewMatrix( IsPackedMatrixRep, R, nc, C ) <> P or
                       Matrix( IsPackedMatrixRep, R, C ) <> P or
                       Matrix( C, P ) <> P ) ) then
    return PackedTestFail( "compressed round trip of ", L );
  fi;

  # copies
  if ShallowCopy( P ) <> P or IsIdenticalObj( ShallowCopy( P ), P ) or
     not IsMutable( ShallowCopy( Immutable( P ) ) ) or
     MutableCopyMatrix( Immutable( P ) ) <> P or
     IsMutable( Immutable( P ) ) or Immutable( P ) <> P then
    return PackedTestFail( "copies of ", L );
  fi;

  # assignments
  L2 := List( L, ShallowCopy );
  for x in [ 1 .. Minimum( 10, Length( L ) * nc ) ] do
    i := Random( rs, [ 1 .. Length( L ) ] );
    j := Random( rs, [ 1 .. nc ] );
    L2[i][j] := PackedTestEntry( rs, R );
    P[i,j] := L2[i][j];
    if Unpack( P ) <> L2 then
      return PackedTestFail( "assignment to ", L, " at ", [ i, j ] );
    fi;
  od;
  return true;
end;

# Construction, entries and round trips of one vector
PackedTestVector := function( rs, R, l )
  local v, C, i, x, l2;
  v := NewVector( IsPackedVectorRep, R, l );
  if not ( IsPackedVectorRep( v ) and IsMutable( v )
           and IsIdenticalObj( BaseDomain( v ), R )
           and Length( v ) = Length( l ) and Unpack( v ) = l
           and ForAll( [ 1 .. Length( l ) ], i -> v[i] = l[i] )
           and IsZero( v ) = ForAll( l, IsZero ) ) then
    return PackedTestFail( "vector ", l );
  fi;
  if Vector( IsPackedVectorRep, R, v ) <> v
     or Vector( v, v ) <> v
     or Vector( l, v ) <> v
     or Vector( IsPackedVectorRep, R, Vector( IsPlistVectorRep, R, l ) ) <> v
     or Vector( Vector( IsPlistVectorRep, R, l ), v ) <> v
     or Unpack( Vector( v, Vector( IsPlistVectorRep, R, l ) ) ) <> l
     or ShallowCopy( v ) <> v or not IsMutable( ShallowCopy( Immutable( v ) ) )
     or IsMutable( Immutable( v ) ) then
    return PackedTestFail( "vector round trip of ", l );
  fi;
  C := PackedTestCompressed( R, l );
  if C = false or
     ( C <> fail and ( NewVector( IsPackedVectorRep, R, C ) <> v or
                       Vector( IsPackedVectorRep, R, C ) <> v or
                       Vector( C, v ) <> v ) ) then
    return PackedTestFail( "compressed vector round trip of ", l );
  fi;
  l2 := ShallowCopy( l );
  for x in [ 1 .. Minimum( 10, Length( l ) ) ] do
    i := Random( rs, [ 1 .. Length( l ) ] );
    l2[i] := PackedTestEntry( rs, R );
    v[i] := l2[i];
    if Unpack( v ) <> l2 then
      return PackedTestFail( "assignment to ", l, " at ", i );
    fi;
  od;
  return true;
end;

# Variants of a list of lists or a list: entries changed in the last row,
# in any row, or in two rows, and prefixes (as for matrices: fewer rows,
# fewer columns); most pairs then share leading entries
PackedTestVariants := function( rs, R, L )
  local res, M, i, j, rows;
  res := [ L ];
  if Length( L ) = 0 then
    return res;
  fi;
  if IsList( L[1] ) then
    for rows in [ [ Length( L ) ], [ Length( L ) ],
                  [ Random( rs, [ 1 .. Length( L ) ] ) ],
                  [ Random( rs, [ 1 .. Length( L ) ] ),
                    Random( rs, [ 1 .. Length( L ) ] ) ] ] do
      M := List( L, ShallowCopy );
      if Length( M[1] ) > 0 then
        for i in rows do
          j := Random( rs, [ 1 .. Length( M[1] ) ] );
          M[i][j] := PackedTestEntry( rs, R );
        od;
      fi;
      Add( res, M );
    od;
    Add( res, L{ [ 1 .. Length( L ) - 1 ] } );
    Add( res, List( L, r -> r{ [ 1 .. QuoInt( Length( r ), 2 ) ] } ) );
    Add( res, List( L,
                    r -> Concatenation( r, [ PackedTestEntry( rs, R ) ] ) ) );
  else
    for i in [ 1 .. 3 ] do
      M := ShallowCopy( L );
      M[Random( rs, [ 1 .. Length( M ) ] )] := PackedTestEntry( rs, R );
      Add( res, M );
    od;
    Add( res, L{ [ 1 .. QuoInt( Length( L ), 2 ) ] } );
    Add( res, Concatenation( L, [ PackedTestEntry( rs, R ) ] ) );
  fi;
  return res;
end;

# =, < and the hash against Unpack and plain lists, for all pairs; Set
PackedTestOrder := function( objs, gens )
  local hash, n, i, j, a, b, ua, ub, eq, lt;
  hash := SparseIntKey( false, objs[1] );
  n := Length( objs );
  for i in [ 1 .. n ] do
    for j in [ 1 .. n ] do
      a := objs[i];
      b := objs[j];
      ua := Unpack( a );
      ub := Unpack( b );
      eq := ua = ub;
      if IsPackedMatrixRep( a ) then
        eq := eq and NrCols( a ) = NrCols( b );
      fi;
      if ( a = b ) <> eq then
        return PackedTestFail( "= of ", ua, " and ", ub );
      fi;
      lt := ua < ub;
      if ( a < b ) <> lt then
        return PackedTestFail( "< of ", ua, " and ", ub );
      fi;
      if gens <> fail and ( gens[i] < gens[j] ) <> lt then
        return PackedTestFail( "generic < of ", ua, " and ", ub );
      fi;
      if eq and hash( a ) <> hash( b ) then
        return PackedTestFail( "hash of ", ua );
      fi;
    od;
  od;

  # objects with zero rows are unordered for different numbers of columns
  objs := Filtered( objs, a -> not IsPackedMatrixRep( a ) or NrRows( a ) > 0 );
  if List( Set( objs ), Unpack ) <> Set( List( objs, Unpack ) ) then
    return PackedTestFail( "Set" );
  fi;
  return true;
end;

PackedTestRing := function( R, seed )
  local rs, mats, gens, vecs, d, L, l, V, len;
  rs := RandomSource( IsMersenneTwister, seed );
  mats := [];
  gens := [];
  for d in PackedTestDims( R ) do
    L := List( [ 1 .. d[1] ], i -> PackedTestList( rs, R, d[2] ) );
    if PackedTestMatrix( rs, R, L, d[2] ) <> true then
      return false;
    fi;
    for V in PackedTestVariants( rs, R, L ) do
      if Length( V ) = 0 then
        Add( mats, NewMatrix( IsPackedMatrixRep, R, d[2], V ) );
        Add( gens, NewMatrix( IsGenericMatrixRep, R, d[2], V ) );
      else
        Add( mats, NewMatrix( IsPackedMatrixRep, R, Length( V[1] ), V ) );
        Add( gens, NewMatrix( IsGenericMatrixRep, R, Length( V[1] ), V ) );
      fi;
    od;
  od;
  if PackedTestOrder( mats, gens ) <> true then
    return false;
  fi;

  vecs := [];
  gens := [];
  for len in [ 0, 1, 2, 5, 31, 32, 33, 63, 64, 65, 100 ] do
    l := PackedTestList( rs, R, len );
    if PackedTestVector( rs, R, l ) <> true then
      return false;
    fi;
    for V in PackedTestVariants( rs, R, l ) do
      Add( vecs, NewVector( IsPackedVectorRep, R, V ) );
      Add( gens, NewVector( IsPlistVectorRep, R, V ) );
    od;
  od;
  return PackedTestOrder( vecs, gens );
end;

# A base domain equal to R, but not identical
PackedTestEqualCopy := function( R )
  if IsField( R ) then
    return Field( One( R ) );
  fi;
  return RingWithOne( One( R ) );
end;

# A row whose every entry access collects garbage, so that bags move while
# the kernel converts it
PackedTestGCRow := function( R, l )
  return EnumeratorByFunctions( R, rec(
    ElementNumber := function( e, i )
      local junk;
      junk := List( [ 1 .. 50 ], k -> k * 2^70 );
      GASMAN( "partial" );
      return l[i];
    end,
    NumberElement := { e, x } -> Position( l, x ),
    Length := e -> Length( l ) ) );
end;

# Construction, assignment and conversion while collections move bags
PackedTestGC := function( R, seed )
  local rs, L, M, v, i, j, x, R2;
  rs := RandomSource( IsMersenneTwister, seed );
  L := List( [ 1 .. 2 ], i -> List( [ 1 .. 3 ], j -> Random( rs, R ) ) );
  M := PACKMAT_MATRIX( PackedRepContext( R ).matrix, 3,
                       List( L, r -> PackedTestGCRow( R, r ) ) );
  v := PACKMAT_VECTOR( PackedRepContext( R ).vector,
                       PackedTestGCRow( R, L[1] ) );
  if Unpack( M ) <> L or Unpack( v ) <> L[1] then
    return PackedTestFail( "construction under GC over ", R );
  fi;
  for i in [ 1 .. 2 ] do
    for j in [ 1 .. 3 ] do
      x := Random( rs, R );
      M[i,j] := x;
      L[i][j] := x;
    od;
  od;
  GASMAN( "partial" );
  if Unpack( M ) <> L then
    return PackedTestFail( "assignment under GC over ", R );
  fi;

  # between base domains, entries go through EntryObj and EntryResidue
  R2 := PackedTestEqualCopy( R );
  if Unpack( Matrix( M, ZeroMatrix( IsPackedMatrixRep, R2, 0, 0 ) ) ) <> L
     or Unpack( Vector( v, ZeroVector( IsPackedVectorRep, R2, 0 ) ) )
        <> Unpack( v ) then
    return PackedTestFail( "conversion between copies of ", R );
  fi;
  return true;
end;
