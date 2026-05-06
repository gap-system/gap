#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##

############################################################################
#
# Dense matrix objects backed by plain lists of plain row lists.
#

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
    if IsMutable( list ) then
      typ := fam!.GenericMatrixRepTypes[2];
    else
      typ := fam!.GenericMatrixRepTypes[1];
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
    local list, row, i, z;
    list := EmptyPlist( rows );
    z := Zero( basedomain );
    for i in [ 1 .. rows ] do
      row := ListWithIdenticalEntries( cols, z );
      list[i] := row;
    od;
    return MakeIsGenericMatrixRep( basedomain, cols, list, false );
  end );


InstallMethod( ConstructingFilter,
  [ "IsGenericMatrixRep" ],
  M -> IsGenericMatrixRep );

InstallMethod( CompatibleVectorFilter,
  [ "IsGenericMatrixRep" ],
  M -> IsPlistVectorRep );


InstallMethod( BaseDomain,
  [ "IsGenericMatrixRep" ],
  M -> M![FBDPOS] );

InstallMethod( NumberRows,
  [ "IsGenericMatrixRep" ],
  M -> Length( M![FROWSPOS] ) );

InstallMethod( NumberColumns,
  [ "IsGenericMatrixRep" ],
  M -> M![FCOLSPOS] );

InstallMethod( \[\],
  [ "IsGenericMatrixRep", "IsPosInt" ],
  function( M, pos )
    ErrorNoReturn( "row access unsupported; use M[i,j] or RowsOfMatrix(M)" );
  end );

InstallMethod( MatElm,
  [ "IsGenericMatrixRep", "IsPosInt", "IsPosInt" ],
  { M, row, col } -> M![FROWSPOS][row,col] );

InstallMethod( SetMatElm,
  [ "IsGenericMatrixRep and IsMutable", "IsPosInt", "IsPosInt", "IsObject" ],
  function( M, row, col, val )
    if ValueOption( "check" ) <> false then
      if not val in BaseDomain( M ) then
        Error( "<val> must lie in the base domain of <M>" );
      elif not row in [1..NrRows(M)] then
        Error( "<row> is out of bounds" );
      elif not col in [1..NrCols(M)] then
        Error( "<col> is out of bounds" );
      fi;
    fi;
    M![FROWSPOS][row,col] := val;
  end );


InstallMethod( Unpack,
  [ "IsGenericMatrixRep" ],
  M -> List( M![FROWSPOS], ShallowCopy ) );

InstallMethod( ShallowCopy,
  [ "IsGenericMatrixRep" ],
  M -> MakeIsGenericMatrixRep( BaseDomain(M), NrCols(M),
           List( M![FROWSPOS], ShallowCopy ), false ) );

InstallMethod( MutableCopyMatrix,
  [ "IsGenericMatrixRep" ],
  M -> MakeIsGenericMatrixRep( BaseDomain(M), NrCols(M),
           List( M![FROWSPOS], ShallowCopy ), false ) );

InstallMethod( ExtractSubMatrix,
  [ "IsGenericMatrixRep", "IsList", "IsList" ],
  function( M, rowspos, colspos )
    local list;
    list := M![FROWSPOS]{ rowspos }{ colspos };
    return MakeIsGenericMatrixRep( BaseDomain(M), Length( colspos ), list, false );
  end );

InstallMethod( CopySubMatrix,
  [ "IsGenericMatrixRep", "IsGenericMatrixRep and IsMutable",
    "IsList", "IsList", "IsList", "IsList" ],
  function( M, N, srcrows, dstrows, srccols, dstcols )
    if ValueOption( "check" ) <> false and
       not IsIdenticalObj( BaseDomain(M), BaseDomain(N) ) then
      Error( "<M> and <N> are not compatible" );
    fi;
    N![FROWSPOS]{dstrows}{dstcols} := M![FROWSPOS]{srcrows}{srccols};
  end );

InstallMethod( TransposedMatMutable,
  [ "IsGenericMatrixRep" ],
  function( M )
    local list;
    list := TransposedMatMutable(M![FROWSPOS]);
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
               a![FROWSPOS] + b![FROWSPOS], false );
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
               a![FROWSPOS] - b![FROWSPOS], false );
  end );

InstallMethod( AdditiveInverseMutable,
  [ "IsGenericMatrixRep" ],
  M -> MakeIsGenericMatrixRep( BaseDomain( M ), NrCols( M ),
           AdditiveInverseMutable( M![FROWSPOS] ), false ) );

InstallMethod( ZeroMutable,
  [ "IsGenericMatrixRep" ],
  function( M )
    local z;
    z := MakeIsGenericMatrixRep( BaseDomain( M ), NrCols( M ),
             ZeroMutable( M![FROWSPOS] ), false );
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
    elif IsFinite( bd ) and IsField( bd ) then
      rows := INV_MAT_DEFAULT_MUTABLE( M![FROWSPOS] );
    else
      rows := INV_MATRIX_MUTABLE( M![FROWSPOS] );
    fi;
    if rows = fail then
      return fail;
    fi;
    return MakeIsGenericMatrixRep( bd, NrCols( M ), rows, false );
  end );

InstallMethod( \*,
  [ "IsGenericMatrixRep", "IsGenericMatrixRep" ],
  function( a, b )
    local rowsA, colsA, rowsB, colsB, bd, list, i;

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

    if rowsA = 0 or colsB = 0 then
      list := [];
    elif colsA = 0 then  # colsA = rowsB
      list := EmptyPlist( rowsA );
      for i in [ 1 .. rowsA ] do
        list[i] := ListWithIdenticalEntries( colsB, Zero( bd ) );
      od;
    else
      list := a![FROWSPOS] * b![FROWSPOS];
    fi;
    return MakeIsGenericMatrixRep( bd, colsB, list, false );
  end );

InstallOtherMethod( \*,
  [ "IsGenericMatrixRep", "IsRowVectorOrVectorObj" ],
  {} -> RankFilter(IsPlistVectorRep),  # rank above method for [IsScalar, IsPlistVectorRep]
  function( M, v )
    local rows, cols, bd, res;

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
      res := v![ELSPOS];
    elif IsList(v) then
      res := v;
    else
      res := Unpack(v);
    fi;
    res := M![FROWSPOS] * res;
    return Vector( res, v );
  end );

InstallOtherMethod( \*,
  [ "IsRowVectorOrVectorObj", "IsGenericMatrixRep" ],
  {} -> RankFilter(IsPlistVectorRep),  # rank above method for [IsPlistVectorRep, IsScalar]
  function( v, M )
    local rows, cols, bd, res;

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
      res := v![ELSPOS];
    elif IsList(v) then
      res := v;
    else
      res := Unpack(v);
    fi;
    res := res * M![FROWSPOS];
    return Vector( res, v );
  end );

InstallMethod( ChangedBaseDomain,
  [ "IsGenericMatrixRep", "IsRing" ],
  function( M, r )
    local A;
    A := NewMatrix( IsGenericMatrixRep, r, NrCols(M), M![FROWSPOS] );
    if not IsMutable( M ) then
      MakeImmutable(A);
    fi;
    return A;
  end );


InstallMethod( MultMatrixRowLeft,
  [ "IsGenericMatrixRep and IsMutable", "IsInt", "IsObject" ],
  function( mat, row, scalar )
    MultMatrixRowLeft(mat![FROWSPOS], row, scalar);
  end );

InstallMethod( MultMatrixRowRight,
  [ "IsGenericMatrixRep and IsMutable", "IsInt", "IsObject" ],
  function( mat, row, scalar )
    MultMatrixRowRight(mat![FROWSPOS], row, scalar);
  end );

InstallMethod( AddMatrixRowsLeft,
  [ "IsGenericMatrixRep and IsMutable", "IsInt", "IsInt", "IsObject" ],
  function( mat, row1, row2, scalar )
    AddMatrixRowsLeft( mat![FROWSPOS], row1, row2, scalar );
  end );

InstallMethod( AddMatrixRowsRight,
  [ "IsGenericMatrixRep and IsMutable", "IsInt", "IsInt", "IsObject" ],
  function( mat, row1, row2, scalar )
    AddMatrixRowsRight( mat![FROWSPOS], row1, row2, scalar );
  end );

InstallMethod( PositionNonZeroInRow,
  [ "IsGenericMatrixRep", "IsPosInt" ],
  function( mat, row )
    return PositionNonZero( mat![FROWSPOS][row] );
  end );

InstallMethod( PositionNonZeroInRow,
  [ "IsGenericMatrixRep", "IsPosInt", "IsInt" ],
  function( mat, row, from )
    return PositionNonZero( mat![FROWSPOS][row], from );
  end );

InstallMethod( SwapMatrixRows,
  [ "IsGenericMatrixRep and IsMutable", "IsInt", "IsInt" ],
  function( mat, row1, row2 )
    SwapMatrixRows(mat![FROWSPOS], row1, row2);
  end );

InstallMethod( SwapMatrixColumns,
  [ "IsGenericMatrixRep and IsMutable", "IsInt", "IsInt" ],
  function( mat, col1, col2 )
    SwapMatrixColumns(mat![FROWSPOS], col1, col2);
  end );


InstallMethod( PostMakeImmutable,
  [ "IsGenericMatrixRep" ],
  function( M )
    MakeImmutable( M![FROWSPOS] );
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
    local i;
    Print( "<" );
    if not IsMutable( M ) then
      Print( "immutable " );
    fi;
    Print( NrRows(M), "x", NrCols(M),
           "-matrix over ", BaseDomain(M), ":\n" );
    for i in [ 1 .. NrRows(M) ] do
      if i = 1 then
        Print( "[" );
      else
        Print( " " );
      fi;
      Print( M![FROWSPOS][i], "\n" );
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
