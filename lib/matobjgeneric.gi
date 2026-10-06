#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##

#############################################################################
#
# Dense matrix objects backed by a list of rows: a compressed matrix over
# small finite fields, a plain list of plain row lists otherwise.
#

# The size of the field over which matrices over <basedomain> store their rows
# as a compressed matrix, or 'fail' if they store plain lists.
BindGlobal( "GEN_MAT_COMPRESSED_FIELD_SIZE",
  function( basedomain )
    local q;

    # excludes e.g. the fields created by 'AlgebraicExtension'
    if not IsFFECollection( basedomain ) then
      return fail;
    fi;

    # Compressed matrices exist over the fields with at most 256 elements,
    # and a semiring of 2 to 256 FFEs is such a field.
    q := Size( basedomain );
    if q = 1 or q > 256 then
      return fail;
    fi;
    return q;
  end );

# Return <list> in the storage of a matrix over <basedomain> with <ncols>
# columns: a compressed matrix over GF(q) if 'GEN_MAT_COMPRESSED_FIELD_SIZE'
# returns q and the matrix is not empty (compressed matrices cannot be empty),
# and a plain list of plain lists otherwise.
# <list> is converted in place where possible.
BindGlobal( "GEN_MAT_CANONICAL_ROWS",
  function( basedomain, ncols, list )
    local q, mut;

    q := GEN_MAT_COMPRESSED_FIELD_SIZE( basedomain );
    if q = fail then
      # nothing compresses the rows of a plain list over such a domain
      if IsPlistRep( list ) then
        return list;
      fi;
    elif ncols > 0 and ( ( q = 2 and IsGF2MatrixRep( list ) )
           or ( Is8BitMatrixRep( list ) and Q_VEC8BIT( list[1] ) = q ) ) then
      return list;
    elif ncols = 0 or Length( list ) = 0 then
      if IsPlistRep( list ) and ForAll( list, IsPlistRep ) then
        return list;
      fi;
      q := fail;
    fi;

    # The rows of a compressed matrix are locked, so unpack copies of them.
    mut := IsMutable( list );
    if q = fail or not IsPlistRep( list ) then
      list := List( list, PlainListCopy );
    fi;
    if q <> fail and ( ForAny( list, row -> Length( row ) <> ncols )
                       or ConvertToMatrixRepNC( list, q ) <> q ) then
      Error( "the rows of <list> must have length <ncols> and entries in ",
             "<basedomain>" );
    fi;
    if not mut then
      MakeImmutable( list );
    fi;
    return list;
  end );

# The rows of the zero matrix with <nrows> rows and <ncols> columns,
# compressed over GF(<q>).
BindGlobal( "GEN_MAT_COMPRESSED_ZERO_ROWS",
  function( q, nrows, ncols )
    local list, i;

    list := EmptyPlist( nrows );
    if q = 2 then
      for i in [ 1 .. nrows ] do
        list[i] := ZERO_GF2VEC_2( ncols );
      od;
      CONV_GF2MAT( list );
    else
      for i in [ 1 .. nrows ] do
        list[i] := ZERO_VEC8BIT_2( q, ncols );
      od;
      CONV_MAT8BIT( list, q );
    fi;
    return list;
  end );

# Whether the rows of <M> are stored as 'GEN_MAT_CANONICAL_ROWS' returns
# them, and are as mutable as <M>.  The methods below rely on this.
BindGlobal( "GEN_MAT_HAS_CANONICAL_ROWS",
  function( M )
    local rows, ncols, mut, q;

    rows := M![GEN_MAT_REP_ROWS_POS];
    ncols := M![GEN_MAT_REP_NCOLS_POS];
    mut := IsMutable( M );
    if IsMutable( rows ) <> mut or ForAny( rows, r -> IsMutable( r ) <> mut )
       or ForAny( rows, r -> Length( r ) <> ncols ) then
      return false;
    fi;

    q := GEN_MAT_COMPRESSED_FIELD_SIZE( M![GEN_MAT_REP_BASEDOMAIN_POS] );
    if q = fail or ncols = 0 or Length( rows ) = 0 then
      return IsPlistRep( rows ) and ForAll( rows, IsPlistRep );
    elif q = 2 then
      return IsGF2MatrixRep( rows );
    fi;
    return Is8BitMatrixRep( rows ) and Q_VEC8BIT( rows[1] ) = q;
  end );

BindGlobal( "MakeIsGenericMatrixRep",
  function( basedomain, ncols, list, check )
    local efam, fam, filter, typ, row;
    efam := ElementsFamily( FamilyObj( basedomain ) );
    fam := CollectionsFamily( FamilyObj( basedomain ) );

    # Currently there is no special handling depending on 'basedomain',
    # the types are always cached in 'fam'.
    if not IsBound( fam!.GenericMatrixRepTypes ) then
      # initialize type cache
      # TODO: make this thread safe for HPC-GAP
      filter := IsGenericMatrixRep;
      if CanEasilyCompareElementsFamily( efam ) then
        filter := filter and CanEasilyCompareElements;
      fi;
      fam!.GenericMatrixRepTypes := [
          NewType( fam, filter ),
          NewType( fam, filter and IsMutable ),
      ];
    fi;

    if check and ValueOption( "check" ) <> false then
      Assert( 0, IsPlistRep( list ) );
      for row in list do
        if not IsPlistRep( row ) then
          Error( "the entries of <list> must be plain lists" );
        elif Length( row ) <> ncols then
          Error( "the entries of <list> must have length <ncols>" );
        elif not IsSubset( basedomain, row ) then
          Error( "the elements in <list> must lie in <basedomain>" );
        fi;
      od;
    fi;

    # A plain list over a domain without FFEs is stored as it is.
    if IsFFECollection( basedomain ) or not IsPlistRep( list ) then
      list := GEN_MAT_CANONICAL_ROWS( basedomain, ncols, list );
    fi;
    if IsMutable( list ) then
      typ := fam!.GenericMatrixRepTypes[2];
    else
      typ := fam!.GenericMatrixRepTypes[1];
    fi;

    return Objectify( typ, [ basedomain, ncols, list ] );
  end );


InstallTagBasedMethod( NewMatrix,
  IsGenericMatrixRep,
  function( filter, basedomain, ncols, list )
    local nd, rows, i, row;

    if Length( list ) > 0 and not IsVectorObj( list[1] ) then
      nd := NestingDepthA( list );
      if nd < 2 or nd mod 2 = 1 then
        if Length( list ) mod ncols <> 0 then
          Error( "NewMatrix: Length of <list> is not a multiple of <ncols>" );
        fi;
        list := List( [ 0, ncols .. Length( list ) - ncols ],
                      i -> list{ [ i + 1 .. i + ncols ] } );
      fi;
    fi;

    rows := EmptyPlist( Length( list ) );
    for i in [ 1 .. Length( list ) ] do
      row := list[i];
      if IsVectorObj( row ) then
        rows[i] := Unpack( row );
      else
        rows[i] := PlainListCopy( row );
      fi;
    od;
    return MakeIsGenericMatrixRep( basedomain, ncols, rows, true );
  end );


InstallTagBasedMethod( NewZeroMatrix,
  IsGenericMatrixRep,
  function( filter, basedomain, rows, cols )
    local list, row, i, z, q;
    q := GEN_MAT_COMPRESSED_FIELD_SIZE( basedomain );
    if q <> fail and rows > 0 and cols > 0 then
      list := GEN_MAT_COMPRESSED_ZERO_ROWS( q, rows, cols );
    else
      list := EmptyPlist( rows );
      z := Zero( basedomain );
      for i in [ 1 .. rows ] do
        row := ListWithIdenticalEntries( cols, z );
        list[i] := row;
      od;
    fi;
    return MakeIsGenericMatrixRep( basedomain, cols, list, false );
  end );


# The default method checks each assignment of a diagonal entry.
InstallTagBasedMethod( NewIdentityMatrix,
  IsGenericMatrixRep,
  function( filter, basedomain, dim )
    local mat, rows, one, i;
    mat := NewZeroMatrix( filter, basedomain, dim, dim );
    rows := mat![GEN_MAT_REP_ROWS_POS];
    one := One( basedomain );
    for i in [ 1 .. dim ] do
      rows[i,i] := one;
    od;
    return mat;
  end );


InstallMethod( ConstructingFilter,
  [ "IsGenericMatrixRep" ],
  M -> IsGenericMatrixRep );

InstallMethod( CompatibleVectorFilter,
  [ "IsGenericMatrixRep" ],
  M -> IsPlistVectorRep );


InstallMethod( BaseDomain,
  [ "IsGenericMatrixRep" ],
  M -> M![GEN_MAT_REP_BASEDOMAIN_POS] );

InstallMethod( NumberRows,
  [ "IsGenericMatrixRep" ],
  M -> Length( M![GEN_MAT_REP_ROWS_POS] ) );

InstallMethod( NumberColumns,
  [ "IsGenericMatrixRep" ],
  M -> M![GEN_MAT_REP_NCOLS_POS] );

InstallMethod( \[\],
  [ "IsGenericMatrixRep", "IsPosInt" ],
  function( M, pos )
    ErrorNoReturn( "row access unsupported; use M[i,j] or RowsOfMatrix(M)" );
  end );

InstallMethod( MatElm,
  [ "IsGenericMatrixRep", "IsPosInt", "IsPosInt" ],
  { M, row, col } -> M![GEN_MAT_REP_ROWS_POS][row,col] );

InstallMethod( SetMatElm,
  [ "IsGenericMatrixRep and IsMutable", "IsPosInt", "IsPosInt", "IsObject" ],
  function( M, row, col, val )
    if ValueOption( "check" ) <> false then
      if not val in BaseDomain( M ) then
        Error( "<val> must lie in the base domain of <M>" );
      elif not row in [ 1 .. NrRows( M ) ] then
        Error( "<row> is out of bounds" );
      elif not col in [ 1 .. NrCols( M ) ] then
        Error( "<col> is out of bounds" );
      fi;
    fi;
    M![GEN_MAT_REP_ROWS_POS][row,col] := val;
  end );


InstallMethod( Unpack,
  [ "IsGenericMatrixRep" ],
  function( M )
    local rows;
    rows := M![GEN_MAT_REP_ROWS_POS];
    if IsPlistRep( rows ) then
      return List( rows, ShallowCopy );
    fi;
    return Unpack( rows );
  end );

# A mutable copy of <rows> with mutable rows, in the same storage.
# For compressed matrices, 'MutableCopyMatrix' is slower because it
# inspects the copied rows.
BindGlobal( "GEN_MAT_COPY_ROWS",
  function( rows )
    local copy;
    copy := List( rows, ShallowCopy );
    if IsPlistRep( rows ) then
      return copy;
    elif IsGF2MatrixRep( rows ) then
      CONV_GF2MAT( copy );
    else
      CONV_MAT8BIT( copy, Q_VEC8BIT( rows[1] ) );
    fi;
    return copy;
  end );

InstallMethod( ShallowCopy,
  [ "IsGenericMatrixRep" ],
  M -> MakeIsGenericMatrixRep( BaseDomain(M), NrCols(M),
           GEN_MAT_COPY_ROWS( M![GEN_MAT_REP_ROWS_POS] ), false ) );

InstallMethod( MutableCopyMatrix,
  [ "IsGenericMatrixRep" ],
  M -> MakeIsGenericMatrixRep( BaseDomain(M), NrCols(M),
           GEN_MAT_COPY_ROWS( M![GEN_MAT_REP_ROWS_POS] ), false ) );

InstallMethod( ExtractSubMatrix,
  [ "IsGenericMatrixRep", "IsList", "IsList" ],
  function( M, rowspos, colspos )
    local list;
    list := M![GEN_MAT_REP_ROWS_POS];
    if IsPlistRep( list ) then
      list := list{ rowspos }{ colspos };
    else
      list := ExtractSubMatrix( list, rowspos, colspos );
    fi;
    return MakeIsGenericMatrixRep( BaseDomain(M), Length( colspos ), list, false );
  end );

InstallMethod( CopySubMatrix,
  [ "IsGenericMatrixRep", "IsGenericMatrixRep and IsMutable",
    "IsList", "IsList", "IsList", "IsList" ],
  function( M, N, srcrows, dstrows, srccols, dstcols )
    local src, dst;
    if ValueOption( "check" ) <> false and
       not IsIdenticalObj( BaseDomain(M), BaseDomain(N) ) then
      Error( "<M> and <N> are not compatible" );
    fi;
    src := M![GEN_MAT_REP_ROWS_POS];
    dst := N![GEN_MAT_REP_ROWS_POS];
    if IsPlistRep( src ) or IsPlistRep( dst ) then
      dst{dstrows}{dstcols} := src{srcrows}{srccols};
    elif Length( srcrows ) > 0 and Length( srccols ) > 0 then
      # the methods for compressed matrices copy ranges of columns faster
      CopySubMatrix( src, dst, srcrows, dstrows, srccols, dstcols );
    fi;
  end );

InstallMethod( TransposedMatMutable,
  [ "IsGenericMatrixRep" ],
  function( M )
    local list;

    # a list of rows does not know the number of columns of a 0 x n matrix
    if NrRows( M ) = 0 or NrCols( M ) = 0 then
      return ZeroMatrix( NrCols( M ), NrRows( M ), M );
    fi;
    list := TransposedMatMutable(M![GEN_MAT_REP_ROWS_POS]);
    return MakeIsGenericMatrixRep( BaseDomain(M), NrRows(M), list, false );
  end );

InstallMethod( \+,
  [ "IsGenericMatrixRep", "IsGenericMatrixRep" ],
  function( a, b )
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( BaseDomain( a ), BaseDomain( b ) ) or
         NrRows( a ) <> NrRows( b ) or
         NrCols( a ) <> NrCols( b ) ) then
      Error( "<a> and <b> are not compatible" );
    fi;
    return MakeIsGenericMatrixRep( BaseDomain( a ), NrCols( a ),
               a![GEN_MAT_REP_ROWS_POS] + b![GEN_MAT_REP_ROWS_POS], false );
  end );

InstallMethod( \-,
  [ "IsGenericMatrixRep", "IsGenericMatrixRep" ],
  function( a, b )
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( BaseDomain( a ), BaseDomain( b ) ) or
         NrRows( a ) <> NrRows( b ) or
         NrCols( a ) <> NrCols( b ) ) then
      Error( "<a> and <b> are not compatible" );
    fi;
    return MakeIsGenericMatrixRep( BaseDomain( a ), NrCols( a ),
               a![GEN_MAT_REP_ROWS_POS] - b![GEN_MAT_REP_ROWS_POS], false );
  end );

InstallMethod( AdditiveInverseMutable,
  [ "IsGenericMatrixRep" ],
  M -> MakeIsGenericMatrixRep( BaseDomain( M ), NrCols( M ),
           AdditiveInverseMutable( M![GEN_MAT_REP_ROWS_POS] ), false ) );

InstallMethod( ZeroMutable,
  [ "IsGenericMatrixRep" ],
  function( M )
    local z;
    z := MakeIsGenericMatrixRep( BaseDomain( M ), NrCols( M ),
             ZeroMutable( M![GEN_MAT_REP_ROWS_POS] ), false );
    return z;
  end );

InstallMethod( InverseMutable,
  [ "IsGenericMatrixRep" ],
  function( M )
    local bd, rows;

    bd := BaseDomain( M );
    if NrRows( M ) <> NrCols( M ) then
      ErrorNoReturn( "InverseMutable: matrix must be square" );
    elif NrRows( M ) = 0 then
      rows := [];
    elif not IsPlistRep( M![GEN_MAT_REP_ROWS_POS] ) then
      rows := InverseMutable( M![GEN_MAT_REP_ROWS_POS] );
    elif IsFinite( bd ) and IsField( bd ) then
      rows := INV_MAT_DEFAULT_MUTABLE( M![GEN_MAT_REP_ROWS_POS] );
    else
      rows := INV_MATRIX_MUTABLE( M![GEN_MAT_REP_ROWS_POS] );
    fi;
    if rows = fail then
      return fail;
    fi;
    return MakeIsGenericMatrixRep( bd, NrCols( M ), rows, false );
  end );

InstallMethod( \*,
  [ "IsGenericMatrixRep", "IsGenericMatrixRep" ],
  function( a, b )
    local rowsA, colsA, rowsB, colsB, bd, list;

    rowsA := NumberRows( a );
    colsA := NumberColumns( a );
    rowsB := NumberRows( b );
    colsB := NumberColumns( b );
    bd := BaseDomain( a );

    if ValueOption( "check" ) <> false then
      if colsA <> rowsB then
        ErrorNoReturn( "\\*: Matrices do not fit together" );
      elif not IsIdenticalObj( bd, BaseDomain( b ) ) then
        ErrorNoReturn( "\\*: Matrices not over same base domain" );
      fi;
    fi;

    if rowsA = 0 or colsA = 0 or colsB = 0 then  # colsA = rowsB
      return ZeroMatrix( rowsA, colsB, a );
    fi;
    list := a![GEN_MAT_REP_ROWS_POS] * b![GEN_MAT_REP_ROWS_POS];
    return MakeIsGenericMatrixRep( bd, colsB, list, false );
  end );

# The kernel multiplies a compressed matrix quickly only with a compressed
# vector.  So compress the plain list <list> over GF(<q>), multiply it with
# <rows> (from the left if <left> is 'true'), and unpack the product.
# Return 'fail' if <list> cannot be compressed.
BindGlobal( "GEN_MAT_PROD_COMPRESSED",
  function( rows, list, q, left )
    local res, mut;

    list := CopyToVectorRep( list, q );
    if list = fail then
      return fail;
    elif left then
      res := list * rows;
    else
      res := rows * list;
    fi;
    mut := IsMutable( res );
    res := Unpack( res );
    if not mut then
      MakeImmutable( res );
    fi;
    return res;
  end );

# Wrap the plain list <res>, a product of <v> with a matrix over the base
# domain of <v>, like <v>.
BindGlobal( "GEN_MAT_VECTOR_LIKE",
  function( res, v )
    if IsPlistVectorRep( v ) then
      # 'Vector' would test again that the entries lie in the base domain
      return MakeIsPlistVectorRep( BaseDomain( v ), res, false );
    fi;
    return Vector( res, v );
  end );

InstallOtherMethod( \*,
  [ "IsGenericMatrixRep", "IsRowVectorOrVectorObj" ],
  {} -> RankFilter(IsPlistVectorRep),  # rank above method for [IsScalar, IsPlistVectorRep]
  function( M, v )
    local rows, cols, bd, res, list;

    rows := NumberRows( M );
    cols := NumberColumns( M );
    bd := BaseDomain( M );

    if ValueOption( "check" ) <> false then
      if cols <> Length( v ) then
        Error( "<M> and <v> are not compatible" );
      elif not IsIdenticalObj( bd, BaseDomain( v ) ) then
        Error( "<M> and <v> are not compatible" );
      fi;
    fi;

    # special case for empty matrices
    if rows = 0 or cols = 0 then
      return ZeroVector( rows, v );
    fi;

    # "unpack" cheaply and then delegate to kernel implementation
    if IsPlistVectorRep(v) then
      list := v![ELSPOS];
    elif IsList(v) then
      list := v;
    else
      list := Unpack(v);
    fi;
    if IsPlistRep( list ) and not IsPlistRep( M![GEN_MAT_REP_ROWS_POS] ) then
      res := GEN_MAT_PROD_COMPRESSED( M![GEN_MAT_REP_ROWS_POS], list,
                                      Size( bd ), false );
      if res <> fail then
        return GEN_MAT_VECTOR_LIKE( res, v );
      fi;
    fi;
    res := M![GEN_MAT_REP_ROWS_POS] * list;
    return Vector( res, v );
  end );

InstallOtherMethod( \*,
  [ "IsRowVectorOrVectorObj", "IsGenericMatrixRep" ],
  {} -> RankFilter(IsPlistVectorRep),  # rank above method for [IsPlistVectorRep, IsScalar]
  function( v, M )
    local rows, cols, bd, res, list;

    rows := NumberRows( M );
    cols := NumberColumns( M );
    bd := BaseDomain( M );

    if ValueOption( "check" ) <> false then
      if Length( v ) <> rows then
        Error( "<v> and <M> are not compatible" );
      elif not IsIdenticalObj( BaseDomain( v ), bd ) then
        Error( "<v> and <M> are not compatible" );
      fi;
    fi;

    # special case for empty matrices
    if rows = 0 or cols = 0 then
      return ZeroVector( cols, v );
    fi;

    # "unpack" cheaply and then delegate to kernel implementation
    if IsPlistVectorRep(v) then
      list := v![ELSPOS];
    elif IsList(v) then
      list := v;
    else
      list := Unpack(v);
    fi;
    if IsPlistRep( list ) and not IsPlistRep( M![GEN_MAT_REP_ROWS_POS] ) then
      res := GEN_MAT_PROD_COMPRESSED( M![GEN_MAT_REP_ROWS_POS], list,
                                      Size( bd ), true );
      if res <> fail then
        return GEN_MAT_VECTOR_LIKE( res, v );
      fi;
    fi;
    res := list * M![GEN_MAT_REP_ROWS_POS];
    return Vector( res, v );
  end );

# For compressed rows and a scalar in the base domain, the kernel computes
# 'op( rows, s )'.  Return the resulting matrix, or 'fail' in all other cases,
# which are left to the generic methods.
# (Integers do not lie in such a base domain; their multiples are sums of
# matrices, formed by a default method.)
BindGlobal( "GEN_MAT_COMPRESSED_SCALAR_OP",
  function( M, s, op )
    local bd, rows;

    bd := M![GEN_MAT_REP_BASEDOMAIN_POS];
    rows := M![GEN_MAT_REP_ROWS_POS];
    if IsPlistRep( rows ) or not s in bd then
      return fail;
    fi;

    # The result is mutable also if <M> is not, unlike in list arithmetic.
    rows := op( rows, s );
    if not IsMutable( rows ) then
      rows := GEN_MAT_COPY_ROWS( rows );
    fi;
    return MakeIsGenericMatrixRep( bd, M![GEN_MAT_REP_NCOLS_POS], rows, false );
  end );

InstallMethod( \*,
  [ "IsGenericMatrixRep", "IsScalar" ],
  function( M, s )
    local res;
    res := GEN_MAT_COMPRESSED_SCALAR_OP( M, s, \* );
    if res = fail then
      TryNextMethod();
    fi;
    return res;
  end );

InstallMethod( \*,
  [ "IsScalar", "IsGenericMatrixRep" ],
  function( s, M )
    local res;
    res := GEN_MAT_COMPRESSED_SCALAR_OP( M, s, { rows, s } -> s * rows );
    if res = fail then
      TryNextMethod();
    fi;
    return res;
  end );

InstallMethod( \/,
  [ "IsGenericMatrixRep", "IsScalar" ],
  function( M, s )
    local res;

    # no default method divides by integers
    if IsInt( s ) and not IsPlistRep( M![GEN_MAT_REP_ROWS_POS] ) then
      s := s * OneOfBaseDomain( M );
      if IsZero( s ) then
        TryNextMethod();
      fi;
    fi;
    res := GEN_MAT_COMPRESSED_SCALAR_OP( M, s, \/ );
    if res = fail then
      TryNextMethod();
    fi;
    return res;
  end );

InstallMethod( \=,
  [ "IsGenericMatrixRep", "IsGenericMatrixRep" ],
  { a, b } -> a![GEN_MAT_REP_BASEDOMAIN_POS] = b![GEN_MAT_REP_BASEDOMAIN_POS]
              and a![GEN_MAT_REP_NCOLS_POS] = b![GEN_MAT_REP_NCOLS_POS]
              and a![GEN_MAT_REP_ROWS_POS] = b![GEN_MAT_REP_ROWS_POS] );

InstallMethod( \<,
  [ "IsGenericMatrixRep", "IsGenericMatrixRep" ],
  function( a, b )
    a := a![GEN_MAT_REP_ROWS_POS];
    b := b![GEN_MAT_REP_ROWS_POS];
    if IsPlistRep( a ) or IsPlistRep( b ) then
      return LT_LIST_LIST_DEFAULT( a, b );
    fi;

    # the kernel compares two compressed matrices
    return a < b;
  end );

InstallMethod( ChangedBaseDomain,
  [ "IsGenericMatrixRep", "IsRing" ],
  function( M, r )
    local A;
    A := NewMatrix( IsGenericMatrixRep, r, NrCols(M), M![GEN_MAT_REP_ROWS_POS] );
    if not IsMutable( M ) then
      MakeImmutable(A);
    fi;
    return A;
  end );

InstallMethod( KroneckerProduct,
  [ "IsGenericMatrixRep", "IsGenericMatrixRep" ],
  function( A, B )
    local bd, rows;

    bd := BaseDomain( A );
    if not IsIdenticalObj( bd, BaseDomain( B ) )
       or IsPlistRep( A![GEN_MAT_REP_ROWS_POS] )
       or IsPlistRep( B![GEN_MAT_REP_ROWS_POS] ) then
      TryNextMethod();
    fi;

    # as for the generic method, the result is immutable only if both are
    rows := KroneckerProduct( A![GEN_MAT_REP_ROWS_POS],
                              B![GEN_MAT_REP_ROWS_POS] );
    if IsMutable( A ) or IsMutable( B ) then
      if not IsMutable( rows ) then
        rows := GEN_MAT_COPY_ROWS( rows );
      fi;
    else
      MakeImmutable( rows );
    fi;
    return MakeIsGenericMatrixRep( bd, NrCols( A ) * NrCols( B ), rows, false );
  end );

InstallMethod( DeterminantMatrix,
  [ "IsGenericMatrixRep" ],
  function( M )
    local rows;

    rows := M![GEN_MAT_REP_ROWS_POS];
    if IsPlistRep( rows ) or NrRows( M ) <> NrCols( M ) then
      TryNextMethod();
    fi;

    # 'Unpack' would decompress the rows; the kernel computes the
    # determinant of a plain list of compressed rows
    return DeterminantMatDestructive( List( rows, ShallowCopy ) );
  end );


# The elementary operations work in place on the row lists, which are never
# shared with other objects.  Plain rows accept any scalar, so check it
# before changing anything.
BindGlobal( "GEN_MAT_SCALAR",
  function( mat, scalar )
    if IsInt( scalar ) then
      return scalar * One( mat![GEN_MAT_REP_BASEDOMAIN_POS] );
    elif ValueOption( "check" ) <> false and
         not scalar in mat![GEN_MAT_REP_BASEDOMAIN_POS] then
      Error( "<scalar> must lie in the base domain of <mat>" );
    fi;
    return scalar;
  end );

InstallMethod( MultMatrixRowLeft,
  [ "IsGenericMatrixRep and IsMutable", "IsInt", "IsObject" ],
  function( mat, row, scalar )
    MultVectorLeft( mat![GEN_MAT_REP_ROWS_POS][row],
                    GEN_MAT_SCALAR( mat, scalar ) );
  end );

InstallMethod( MultMatrixRowRight,
  [ "IsGenericMatrixRep and IsMutable", "IsInt", "IsObject" ],
  function( mat, row, scalar )
    MultVectorRight( mat![GEN_MAT_REP_ROWS_POS][row],
                     GEN_MAT_SCALAR( mat, scalar ) );
  end );

# The list methods for 'AddRowVector' multiply from the left, and they
# require <scalar> to lie in the family of the entries.
InstallMethod( AddMatrixRowsLeft,
  [ "IsGenericMatrixRep and IsMutable", "IsInt", "IsInt", "IsObject" ],
  function( mat, row1, row2, scalar )
    local dst, src, efam;
    scalar := GEN_MAT_SCALAR( mat, scalar );
    dst := mat![GEN_MAT_REP_ROWS_POS][row1];
    src := mat![GEN_MAT_REP_ROWS_POS][row2];
    efam := ElementsFamily( FamilyObj( mat![GEN_MAT_REP_BASEDOMAIN_POS] ) );
    if Length( dst ) = 0 then
      return;
    elif IsIdenticalObj( FamilyObj( scalar ), efam ) then
      AddRowVector( dst, src, scalar );
    else
      ADD_ROW_VECTOR_3( dst, src, scalar );
    fi;
  end );

InstallMethod( AddMatrixRowsRight,
  [ "IsGenericMatrixRep and IsMutable", "IsInt", "IsInt", "IsObject" ],
  function( mat, row1, row2, scalar )
    local dst, src, bd, efam, i;
    scalar := GEN_MAT_SCALAR( mat, scalar );
    dst := mat![GEN_MAT_REP_ROWS_POS][row1];
    src := mat![GEN_MAT_REP_ROWS_POS][row2];
    bd := mat![GEN_MAT_REP_BASEDOMAIN_POS];
    efam := ElementsFamily( FamilyObj( bd ) );
    if Length( dst ) = 0 then
      return;
    elif IsIdenticalObj( FamilyObj( scalar ), efam ) and IsCommutative( bd ) then
      AddRowVector( dst, src, scalar );
    else
      for i in [ 1 .. Length( dst ) ] do
        dst[i] := dst[i] + src[i] * scalar;
      od;
    fi;
  end );

InstallMethod( MultMatrixColumnLeft,
  [ "IsGenericMatrixRep and IsMutable", "IsInt", "IsObject" ],
  function( mat, col, scalar )
    MultMatrixColumnLeft( mat![GEN_MAT_REP_ROWS_POS], col,
                          GEN_MAT_SCALAR( mat, scalar ) );
  end );

InstallMethod( MultMatrixColumnRight,
  [ "IsGenericMatrixRep and IsMutable", "IsInt", "IsObject" ],
  function( mat, col, scalar )
    MultMatrixColumnRight( mat![GEN_MAT_REP_ROWS_POS], col,
                           GEN_MAT_SCALAR( mat, scalar ) );
  end );

InstallMethod( AddMatrixColumnsLeft,
  [ "IsGenericMatrixRep and IsMutable", "IsInt", "IsInt", "IsObject" ],
  function( mat, col1, col2, scalar )
    AddMatrixColumnsLeft( mat![GEN_MAT_REP_ROWS_POS], col1, col2,
                          GEN_MAT_SCALAR( mat, scalar ) );
  end );

InstallMethod( AddMatrixColumnsRight,
  [ "IsGenericMatrixRep and IsMutable", "IsInt", "IsInt", "IsObject" ],
  function( mat, col1, col2, scalar )
    AddMatrixColumnsRight( mat![GEN_MAT_REP_ROWS_POS], col1, col2,
                           GEN_MAT_SCALAR( mat, scalar ) );
  end );

InstallMethod( PositionNonZeroInRow,
  [ "IsGenericMatrixRep", "IsPosInt" ],
  function( mat, row )
    return PositionNonZero( mat![GEN_MAT_REP_ROWS_POS][row] );
  end );

InstallMethod( PositionNonZeroInRow,
  [ "IsGenericMatrixRep", "IsPosInt", "IsInt" ],
  function( mat, row, from )
    return PositionNonZero( mat![GEN_MAT_REP_ROWS_POS][row], from );
  end );

InstallMethod( SwapMatrixRows,
  [ "IsGenericMatrixRep and IsMutable", "IsInt", "IsInt" ],
  function( mat, row1, row2 )
    SwapMatrixRows(mat![GEN_MAT_REP_ROWS_POS], row1, row2);
  end );

InstallMethod( SwapMatrixColumns,
  [ "IsGenericMatrixRep and IsMutable", "IsInt", "IsInt" ],
  function( mat, col1, col2 )
    SwapMatrixColumns(mat![GEN_MAT_REP_ROWS_POS], col1, col2);
  end );


InstallMethod( PostMakeImmutable,
  [ "IsGenericMatrixRep" ],
  function( M )
    MakeImmutable( M![GEN_MAT_REP_ROWS_POS] );
  end );


InstallMethod( ViewObj, [ "IsGenericMatrixRep" ],
  function( M )
    Print( "<" );
    if not IsMutable( M ) then
      Print( "immutable " );
    fi;
    Print( NrRows(M), "x", NrCols(M),
           "-matrix over ", BaseDomain(M), ">" );
  end );

InstallMethod( PrintObj, [ "IsGenericMatrixRep" ],
  function( M )
    Print( "NewMatrix(IsGenericMatrixRep" );
    if IsFinite( BaseDomain(M) ) and IsField( BaseDomain(M) ) then
      Print( ",GF(", Size( BaseDomain(M) ), ")," );
    else
      Print( ",", String( BaseDomain(M) ), "," );
    fi;
    Print( NumberColumns( M ), ",", Unpack( M ), ")" );
  end );

InstallMethod( Display, [ "IsGenericMatrixRep" ],
  function( M )
    local rows, i;
    Print( "<" );
    if not IsMutable( M ) then
      Print( "immutable " );
    fi;
    Print( NrRows(M), "x", NrCols(M),
           "-matrix over ", BaseDomain(M), ":\n" );
    rows := Unpack( M );
    for i in [ 1 .. NrRows(M) ] do
      if i = 1 then
        Print( "[" );
      else
        Print( " " );
      fi;
      Print( rows[i], "\n" );
    od;
    Print( "]>\n" );
  end );

InstallMethod( String, [ "IsGenericMatrixRep" ],
  function( M )
    local st;
    st := "NewMatrix(IsGenericMatrixRep";
    Add( st, ',' );
    if IsFinite( BaseDomain(M) ) and IsField( BaseDomain(M) ) then
      Append( st, "GF(" );
      Append( st, String( Size( BaseDomain(M) ) ) );
      Append( st, ")," );
    else
      Append( st, String( BaseDomain(M) ) );
      Append( st, "," );
    fi;
    Append( st, String( NumberColumns( M ) ) );
    Add( st, ',' );
    Append( st, String( Unpack( M ) ) );
    Add( st, ')' );
    return st;
  end );
