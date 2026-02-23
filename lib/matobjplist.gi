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
# This file is a sample implementation for new style vectors and matrices.
# It stores matrices as dense lists of lists with wrapping.
#

############################################################################
# Constructors:
############################################################################


############################################################################
##
#F  MakeIsPlistVectorRep( <basedomain>, <list>, <check> )
##
##  Construct a new vector in the filter 'IsPlistVectorRep' with base domain
##  <basedomain> and entries in the list <list> (without copying).
##
##  If <check> is set to 'true' *and* 'ValueOption( "check" )' is 'true',
##  then it is checked that the entries of <list> are in <basedomain>.
##  So whenever you know that the input is guaranteed to be in <basedomain>,
##  pass 'false' for <check> to omit these (potentially costly) consistency
##  checks.
##
BindGlobal( "MakeIsPlistVectorRep",
  function( basedomain, list, check )
    local fam, types, typ;
    fam := FamilyObj(basedomain);
    #types := _PlistVectorRepTypeCache(basedomain);

    # special case: integers
    if IsIntegers(basedomain) then
        if not IsBound(basedomain!.PlistVectorRepTypes) then
            # initialize type cache
            # TODO: make this thread safe for HPC-GAP
            basedomain!.PlistVectorRepTypes := [
                NewType(fam, IsPlistVectorRep and IsIntVector and CanEasilyCompareElements),
                NewType(fam, IsPlistVectorRep and IsIntVector and CanEasilyCompareElements and IsMutable),
            ];
        fi;
        types := basedomain!.PlistVectorRepTypes;
    elif IsFFECollection(basedomain) then
        if not IsBound(basedomain!.PlistVectorRepTypes) then
            # initialize type cache
            # TODO: make this thread safe for HPC-GAP
            basedomain!.PlistVectorRepTypes := [
                NewType(fam, IsPlistVectorRep and IsFFEVector and CanEasilyCompareElements),
                NewType(fam, IsPlistVectorRep and IsFFEVector and CanEasilyCompareElements and IsMutable),
            ];
        fi;
        types := basedomain!.PlistVectorRepTypes;
    else
        if not IsBound(fam!.PlistVectorRepTypes) then
            # initialize type cache
            # TODO: make this thread safe for HPC-GAP
            fam!.PlistVectorRepTypes := [
                NewType(fam, IsPlistVectorRep),
                NewType(fam, IsPlistVectorRep and IsMutable),
            ];
            fam!.PlistVectorRepTypesEasyCompare := [
                NewType(fam, IsPlistVectorRep and CanEasilyCompareElements),
                NewType(fam, IsPlistVectorRep and CanEasilyCompareElements and IsMutable),
            ];
        fi;
        if HasCanEasilyCompareElements(Representative(basedomain)) and
           CanEasilyCompareElements(Representative(basedomain)) then
            types := fam!.PlistVectorRepTypesEasyCompare;
        else
            types := fam!.PlistVectorRepTypes;
        fi;
    fi;
    if IsMutable(list) then
        typ := types[2];
    else
        typ := types[1];
    fi;

    if check and ValueOption( "check" ) <> false then
      if not IsSubset( basedomain, list ) then
        Error( "the elements in <list> must lie in <basedomain>" );
      fi;
    fi;

    return Objectify(typ, [ basedomain, list ]);
  end );


############################################################################
##
#F  MakeIsRowPlistMatrixRep( <basedomain>, <emptyvector>, <ncols>, <list>,
#F                        <check> )
##
##  Construct a new matrix in the filter 'IsRowPlistMatrixRep' with base domain
##  <basedomain> and rows given by the list <list>, whose entries must be
##  'IsPlistVectorObj' vectors with base domain <basedomain> and length <ncols>.
##  <emptyvector> must be an 'IsPlistVectorObj' vector of length zero and with
##  base domain <basedomain>.
##
##  If <check> is set to 'true' *and* 'ValueOption( "check" )' is 'true',
##  then it is checked that the entries of <list> are 'IsPlistVectorObj'
##  vectors with base domain identical with <basedomain> and length equal to
##  <ncols>.
##  So whenever you know that the input satisfies these conditions,
##  pass 'false' for <check> to omit these (potentially costly) consistency
##  checks.
##
##  (It is *not* checked whether for each of the vectors in <list>,
##  the entries lie in <basedomain>; this check is assumed to belong to the
##  creation of the vectors.)
##
BindGlobal( "MakeIsRowPlistMatrixRep",
  function( basedomain, emptyvector, ncols, list, check )
    local fam, types, typ, row;
    fam:= CollectionsFamily( FamilyObj( basedomain ) );

    # Currently there is no special handling depending on 'basedomain',
    # the types are always cached in 'fam'.
    if not IsBound( fam!.PlistMatrixRepTypes ) then
      # initialize type cache
      # TODO: make this thread safe for HPC-GAP
      fam!.PlistMatrixRepTypes:= [
          NewType( fam, IsRowPlistMatrixRep ),
          NewType( fam, IsRowPlistMatrixRep and IsMutable ),
      ];
      fam!.PlistMatrixRepTypesEasyCompare:= [
          NewType( fam, IsRowPlistMatrixRep and CanEasilyCompareElements ),
          NewType( fam, IsRowPlistMatrixRep and CanEasilyCompareElements and IsMutable ),
      ];
    fi;
    if HasCanEasilyCompareElements( Representative( basedomain ) ) and
       CanEasilyCompareElements( Representative( basedomain ) ) then
      types:= fam!.PlistMatrixRepTypesEasyCompare;
    else
      types:= fam!.PlistMatrixRepTypes;
    fi;
    if IsMutable( list ) then
      typ:= types[2];
    else
      typ:= types[1];
    fi;

    if check and ValueOption( "check" ) <> false then
      if not IsPlistVectorRep( emptyvector ) then
        Error( "<emptyvector> must be in 'IsPlistVectorRep'" );
      elif not IsIdenticalObj( basedomain, emptyvector![BDPOS] ) then
        Error( "<emptyvector> must have the given base domain" );
      fi;
      for row in list do
        if not IsPlistVectorRep( row ) then
          Error( "the entries of <list> must be in 'IsPlistVectorRep'" );
        elif not IsIdenticalObj( basedomain, row![BDPOS] ) then
          Error( "the entries of <list> must have the given base domain" );
        elif Length( row![ELSPOS] ) <> ncols then
          Error( "the entries of <list> must have length <ncols>" );
        fi;
      od;
    fi;

    return Objectify( typ, [ basedomain, emptyvector, ncols, list ] );
  end );


############################################################################
# Constructor methods:
############################################################################

InstallTagBasedMethod( NewVector,
  IsPlistVectorRep,
  function( filter, basedomain, list )
    return MakeIsPlistVectorRep(basedomain, ShallowCopy(list), true);
  end );

InstallTagBasedMethod( NewZeroVector,
  IsPlistVectorRep,
  function( filter, basedomain, len )
    local list;
    list := ListWithIdenticalEntries(len, Zero(basedomain));
    return MakeIsPlistVectorRep(basedomain, list, false);
  end );

InstallTagBasedMethod( NewMatrix,
  IsRowPlistMatrixRep,
  function( filter, basedomain, ncols, list )
    local nd, filterVectors, m, e, i;

    # If applicable then replace a flat list 'list' by a nested list
    # of lists of length 'ncols'.
    if Length( list ) > 0 and not IsVectorObj( list[1] ) then
      nd := NestingDepthA( list );
      if nd < 2 or nd mod 2 = 1 then
        if Length( list ) mod ncols <> 0 then
          Error( "NewMatrix: Length of <list> is not a multiple of <ncols>" );
        fi;
        list := List([0, ncols .. Length( list )-ncols],
                     i -> list{[i+1..i+ncols]});
      fi;
    fi;

    filterVectors := IsPlistVectorRep;
    m := 0*[1..Length( list )];
    for i in [1..Length( list )] do
        if IsVectorObj( list[i] ) and filterVectors( list[i] ) then
            m[i] := ShallowCopy( list[i] );
        else
            m[i] := NewVector( filterVectors, basedomain, list[i] );
        fi;
    od;
    e := NewVector(filterVectors, basedomain, []);
    return MakeIsRowPlistMatrixRep( basedomain, e, ncols, m, true );
  end );

# This is faster than the default method.
InstallTagBasedMethod( NewZeroMatrix,
  IsRowPlistMatrixRep,
  function( filter, basedomain, rows, cols )
    local m,i,e,filter2;
    filter2 := IsPlistVectorRep;
    m := 0*[1..rows];
    e := NewVector(filter2, basedomain, []);
    for i in [1..rows] do
        m[i] := ZeroVector( cols, e );
    od;
    return MakeIsRowPlistMatrixRep( basedomain, e, cols, m, false );
  end );


############################################################################
# Printing and viewing methods:
############################################################################

InstallMethod( ViewObj, [ "IsPlistVectorRep" ],
  function( v )
    if not IsMutable(v) then
        Print("<immutable ");
    else
        Print("<");
    fi;
    Print("plist vector over ",v![BDPOS]," of length ",Length(v![ELSPOS]),">");
  end );

InstallMethod( PrintObj, [ "IsPlistVectorRep" ],
  function( v )
    Print("NewVector(IsPlistVectorRep");
    if IsFinite(v![BDPOS]) and IsField(v![BDPOS]) then
        Print(",GF(",Size(v![BDPOS]),"),",v![ELSPOS],")");
    else
        Print(",",String(v![BDPOS]),",",v![ELSPOS],")");
    fi;
  end );

InstallMethod( String, [ "IsPlistVectorRep" ],
  function( v )
    local st;
    st := "NewVector(IsPlistVectorRep";
    if IsFinite(v![BDPOS]) and IsField(v![BDPOS]) then
        Append(st,Concatenation( ",GF(",String(Size(v![BDPOS])),"),",
                                 String(v![ELSPOS]),")" ));
    else
        Append(st,Concatenation( ",",String(v![BDPOS]),",",
                                 String(v![ELSPOS]),")" ));
    fi;
    return st;
  end );

InstallMethod( Display, [ "IsPlistVectorRep" ],
  function( v )
    Print( "<a " );
    Print( "plist vector over ",BaseDomain(v),":\n");
    Print(v![ELSPOS],"\n>\n");
  end );

InstallMethod( CompatibleVectorFilter, ["IsRowPlistMatrixRep"],
  M -> IsPlistVectorRep );

############################################################################
############################################################################
# Vectors:
############################################################################
############################################################################


############################################################################
# The basic attributes:
############################################################################

InstallMethod( BaseDomain, [ "IsPlistVectorRep" ],
  v -> v![BDPOS] );

InstallMethod( Length, [ "IsPlistVectorRep" ],
  v -> Length( v![ELSPOS] ) );


############################################################################
# Representation preserving constructors:
############################################################################

InstallMethod( ZeroVector,
  [ "IsInt", "IsPlistVectorRep" ],
  { len, v } -> NewZeroVector( IsPlistVectorRep, v![BDPOS], len ) );

InstallMethod( ZeroVector,
  [ "IsInt", "IsRowPlistMatrixRep" ],
  { len, M } -> NewZeroVector( IsPlistVectorRep, M![BDPOS], len ) );

InstallMethod( Vector,
  [ "IsList and IsPlistRep", "IsPlistVectorRep" ],
  function( list, v )
    # wrap the given list without copying it (this is documented behavior)
    return MakeIsPlistVectorRep( v![BDPOS], list, true );
  end );

InstallMethod( Vector,
  [ "IsList", "IsPlistVectorRep" ],
  function( list, v )
    local m;
    m := IsMutable(list);
    list := PlainListCopy(list);
    if not m then
        MakeImmutable(list);
    fi;
    return MakeIsPlistVectorRep( v![BDPOS], list, true );
  end );


############################################################################
# A selection of list operations:
############################################################################

InstallMethod( \[\],
  [ "IsPlistVectorRep", "IsPosInt" ],
  { v, p } -> v![ELSPOS][p] );

InstallMethod( \[\]\:\=,
  [ "IsPlistVectorRep", "IsPosInt", "IsObject" ],
  function( v, p, ob )
    v![ELSPOS][p] := ob;
  end );

InstallMethod( \{\},
  [ "IsPlistVectorRep", "IsList" ],
  { v, list } -> MakeIsPlistVectorRep( v![BDPOS], v![ELSPOS]{ list }, false ) );

InstallMethod( PositionNonZero, [ "IsPlistVectorRep" ],
  v -> PositionNonZero( v![ELSPOS] ) );

InstallOtherMethod( PositionNonZero,
  [ "IsPlistVectorRep", "IsInt" ],
  { v, s } -> PositionNonZero( v![ELSPOS], s ) );

InstallMethod( PositionLastNonZero, [ "IsPlistVectorRep" ],
  function( v )
    local els,i;
    els := v![ELSPOS];
    i := Length(els);
    while i > 0 and IsZero(els[i]) do i := i - 1; od;
    return i;
  end );

InstallMethod( ListOp, [ "IsPlistVectorRep" ],
  v -> v![ELSPOS]{ [ 1 .. Length( v![ELSPOS] ) ] } );

InstallMethod( ListOp,
  [ "IsPlistVectorRep", "IsFunction" ],
  { v, f } -> List( v![ELSPOS], f ) );

InstallMethod( Unpack,
  [ "IsPlistVectorRep" ],
  v -> ShallowCopy( v![ELSPOS] ) );

############################################################################
# Standard operations for all objects:
############################################################################

InstallMethod( ShallowCopy, [ "IsPlistVectorRep" ],
  v -> MakeIsPlistVectorRep( v![BDPOS], ShallowCopy( v![ELSPOS] ), false ) );

# StructuralCopy works automatically

InstallMethod( PostMakeImmutable, [ "IsPlistVectorRep" ],
  function( v )
    MakeImmutable( v![ELSPOS] );
  end );


############################################################################
# Arithmetical operations:
############################################################################

InstallMethod( \+,
  [ "IsPlistVectorRep", "IsPlistVectorRep" ],
  function( a, b )
    if ValueOption( "check" ) <> false and
       not IsIdenticalObj( a![BDPOS], b![BDPOS] ) then
      Error( "<a> and <b> are not compatible" );
    fi;
    return MakeIsPlistVectorRep(a![BDPOS],
               SUM_LIST_LIST_DEFAULT(a![ELSPOS],b![ELSPOS]), false);
  end );

InstallMethod( \-,
  [ "IsPlistVectorRep", "IsPlistVectorRep" ],
  function( a, b )
    if ValueOption( "check" ) <> false and
       not IsIdenticalObj( a![BDPOS], b![BDPOS] ) then
      Error( "<a> and <b> are not compatible" );
    fi;
    return MakeIsPlistVectorRep(a![BDPOS],
               DIFF_LIST_LIST_DEFAULT(a![ELSPOS],b![ELSPOS]), false);
  end );

InstallMethod( \=,
  [ "IsPlistVectorRep", "IsPlistVectorRep" ],
  { a, b } -> EQ_LIST_LIST_DEFAULT( a![ELSPOS], b![ELSPOS] ) );

InstallMethod( \<,
  [ "IsPlistVectorRep", "IsPlistVectorRep" ],
  { a, b } -> LT_LIST_LIST_DEFAULT( a![ELSPOS], b![ELSPOS] ) );

InstallMethod( AddRowVector,
  [ "IsPlistVectorRep and IsMutable", "IsPlistVectorRep" ],
  function( a, b )
    if ValueOption( "check" ) <> false and
       not IsIdenticalObj( a![BDPOS], b![BDPOS] ) then
      Error( "<a> and <b> are not compatible" );
    fi;
    ADD_ROW_VECTOR_2( a![ELSPOS], b![ELSPOS] );
  end );

# Better method for integer vectors:
InstallMethod( AddRowVector,
  [ "IsPlistVectorRep and IsMutable and IsIntVector",
    "IsPlistVectorRep and IsIntVector" ],
  function( a, b )
    if ValueOption( "check" ) <> false and
       not IsIdenticalObj( a![BDPOS], b![BDPOS] ) then
      Error( "<a> and <b> are not compatible" );
    fi;
    ADD_ROW_VECTOR_2_FAST( a![ELSPOS], b![ELSPOS] );
  end );

InstallMethod( AddRowVector,
  [ "IsPlistVectorRep and IsMutable", "IsPlistVectorRep", "IsObject" ],
  function( a, b, s )
    ADD_ROW_VECTOR_3( a![ELSPOS], b![ELSPOS], s );
    if ValueOption( "check" ) <> false then
      if not IsIdenticalObj( a![BDPOS], b![BDPOS] ) then
        Error( "<a> and <b> are not compatible" );
      elif not IsSubset( a![BDPOS], a![ELSPOS] ) then
        Error( "<a> is not defined over its base domain" );
      fi;
    fi;
  end );

# Better method for integer vectors:
InstallMethod( AddRowVector,
  [ "IsPlistVectorRep and IsIntVector and IsMutable",
    "IsPlistVectorRep and IsIntVector", "IsInt" ],
  function( a, b, s )
    if ValueOption( "check" ) <> false then
      if not IsIdenticalObj( a![BDPOS], b![BDPOS] ) then
        Error( "<a> and <b> are not compatible" );
      fi;
    fi;
    if IsSmallIntRep(s) then
        ADD_ROW_VECTOR_3_FAST( a![ELSPOS], b![ELSPOS], s );
    else
        ADD_ROW_VECTOR_3( a![ELSPOS], b![ELSPOS], s );
    fi;
  end );

InstallMethod( AddRowVector,
  [ "IsPlistVectorRep and IsMutable", "IsPlistVectorRep",
    "IsObject", "IsPosInt", "IsPosInt" ],
  function( a, b, s, from, to )
    ADD_ROW_VECTOR_5( a![ELSPOS], b![ELSPOS], s, from, to );
    if ValueOption( "check" ) <> false then
      if not IsIdenticalObj( a![BDPOS], b![BDPOS] ) then
        Error( "<a> and <b> are not compatible" );
      elif not IsSubset( a![BDPOS], a![ELSPOS] ) then
        Error( "<a> is not defined over its base domain" );
      fi;
    fi;
  end );

# Better method for integer vectors:
InstallMethod( AddRowVector,
  [ "IsPlistVectorRep and IsIntVector and IsMutable",
    "IsPlistVectorRep and IsIntVector", "IsInt", "IsPosInt", "IsPosInt" ],
  function( a, b, s, from, to )
    if ValueOption( "check" ) <> false and
       not IsIdenticalObj( a![BDPOS], b![BDPOS] ) then
      Error( "<a> and <b> are not compatible" );
    fi;
    if IsSmallIntRep(s) then
        ADD_ROW_VECTOR_5_FAST( a![ELSPOS], b![ELSPOS], s, from, to );
    else
        ADD_ROW_VECTOR_5( a![ELSPOS], b![ELSPOS], s, from, to );
    fi;
  end );

InstallMethod( MultVectorLeft,
  [ "IsPlistVectorRep and IsMutable", "IsObject" ],
  function( v, s )
    MULT_VECTOR_LEFT_2(v![ELSPOS],s);
    if ValueOption( "check" ) <> false and not IsSubset( v![BDPOS], v![ELSPOS] ) then
      Error( "<v> is not defined over its base domain" );
    fi;
  end );

InstallMethod( MultVectorRight,
  [ "IsPlistVectorRep and IsMutable", "IsObject" ],
  function( v, s )
    MULT_VECTOR_RIGHT_2(v![ELSPOS],s);
    if ValueOption( "check" ) <> false and not IsSubset( v![BDPOS], v![ELSPOS] ) then
      Error( "<v> is not defined over its base domain" );
    fi;
  end );

InstallOtherMethod( MultVectorLeft,
  [ "IsPlistVectorRep and IsIntVector and IsMutable", "IsSmallIntRep" ],
  function( v, s )
    MULT_VECTOR_2_FAST(v![ELSPOS],s);
  end );

# The four argument version of MultVectorLeft / ..Right uses the generic
# implementation in matobj.gi

InstallMethod( \*,
  [ "IsPlistVectorRep", "IsScalar" ],
  { v, s } -> MakeIsPlistVectorRep( v![BDPOS],
                  PROD_LIST_SCL_DEFAULT( v![ELSPOS], s ), true ) );

InstallMethod( \*,
  [ "IsScalar", "IsPlistVectorRep" ],
  { s, v } -> MakeIsPlistVectorRep( v![BDPOS],
                  PROD_SCL_LIST_DEFAULT( s, v![ELSPOS] ), true ) );

InstallMethod( \/,
  [ "IsPlistVectorRep", "IsScalar" ],
  function( v, s )
    local basedomain, w;

    basedomain:= v![BDPOS];
    w:= PROD_LIST_SCL_DEFAULT( v![ELSPOS], s^-1 );
    return MakeIsPlistVectorRep(basedomain, w, true);
  end );

InstallMethod( AdditiveInverseSameMutability,
  [ "IsPlistVectorRep" ],
  v -> MakeIsPlistVectorRep( v![BDPOS],
           AdditiveInverseSameMutability( v![ELSPOS] ), false ) );

InstallMethod( AdditiveInverseImmutable,
  [ "IsPlistVectorRep" ],
  v -> MakeIsPlistVectorRep( v![BDPOS],
           AdditiveInverseImmutable( v![ELSPOS] ), false ) );

InstallMethod( AdditiveInverseMutable,
  [ "IsPlistVectorRep" ],
  v -> MakeIsPlistVectorRep( v![BDPOS],
           AdditiveInverseMutable( v![ELSPOS] ), false ) );

InstallMethod( ZeroSameMutability, [ "IsPlistVectorRep" ],
  v -> MakeIsPlistVectorRep( v![BDPOS],
           ZeroSameMutability( v![ELSPOS] ), false ) );

InstallMethod( ZeroImmutable, [ "IsPlistVectorRep" ],
  function( v )
    v:= MakeIsPlistVectorRep( v![BDPOS],
            ZeroImmutable( v![ELSPOS] ), false );
    SetIsZero( v, true );
    return v;
  end );

InstallMethod( ZeroMutable, [ "IsPlistVectorRep" ],
  v -> MakeIsPlistVectorRep( v![BDPOS], ZeroMutable( v![ELSPOS] ), false ) );

InstallMethod( IsZero, [ "IsPlistVectorRep" ],
  v -> IsZero( v![ELSPOS] ) );

InstallMethodWithRandomSource( Randomize,
  "for a random source and a mutable plist vector",
  [ IsRandomSource, IsPlistVectorRep and IsMutable ],
  function( rs, v )
    local bd,i;
    bd := v![BDPOS];
    for i in [1..Length(v![ELSPOS])] do
        v![ELSPOS][i] := Random( rs, bd );
    od;
    return v;
  end );

InstallMethod( CopySubVector,
  [ "IsPlistVectorRep", "IsPlistVectorRep and IsMutable", "IsList", "IsList" ],
  function( a,b,pa,pb )
    if ValueOption( "check" ) <> false and
       not IsIdenticalObj( a![BDPOS], b![BDPOS] ) then
      Error( "<a> and <b> are not compatible" );
    fi;
    # The following should eventually go into the kernel:
    b![ELSPOS]{pb} := a![ELSPOS]{pa};
  end );


############################################################################
############################################################################
# Matrices:
############################################################################
############################################################################


############################################################################
# The basic attributes:
############################################################################

InstallMethod( BaseDomain,
  [ "IsRowPlistMatrixRep" ],
  M -> M![BDPOS] );

InstallMethod( NumberRows,
  [ "IsRowPlistMatrixRep" ],
  M -> Length( M![ROWSPOS] ) );

InstallMethod( NumberColumns,
  [ "IsRowPlistMatrixRep" ],
  M -> M![RLPOS] );

InstallMethod( DimensionsMat,
  [ "IsRowPlistMatrixRep" ],
  M -> [ Length( M![ROWSPOS]), M![RLPOS] ] );


############################################################################
# Representation preserving constructors:
############################################################################

InstallMethod( ZeroMatrix,
  [ "IsInt", "IsInt", "IsRowPlistMatrixRep" ],
  function( nrows, ncols, M )
    local t, list;
    t := M![EMPOS];
    list := List([1..nrows],i->ZeroVector(ncols,t));
    return MakeIsRowPlistMatrixRep( M![BDPOS], t, ncols, list, false );
  end );

InstallMethod( IdentityMatrix,
  [ "IsInt", "IsRowPlistMatrixRep" ],
  function( nrows, M )
    local t, list, o, i;
    t := M![EMPOS];
    list := List([1..nrows],i->ZeroVector(nrows,t));
    o := One(M![BDPOS]);
    for i in [1..nrows] do
        list[i][i] := o;
    od;
    return MakeIsRowPlistMatrixRep( M![BDPOS], t, nrows, list, false );
  end );

InstallMethod( Matrix,
  [ "IsList", "IsInt", "IsRowPlistMatrixRep" ],
  function( list, ncols, M )
    local basedomain, check, i,l,nrrows,t;
    t := M![EMPOS];
    basedomain:= M![BDPOS];
    check:= ValueOption( "check" ) <> false;
    if Length( list ) > 0 then
        if IsVectorObj( list[1] ) and IsPlistVectorRep( list[1] ) then
            if check then
              for i in list do
                if not IsIdenticalObj( basedomain, BaseDomain( i ) ) then
                  Error( "not the same <basedomain>" );
                elif Length( i ) <> ncols then
                  Error( "incompatible lengths of vectors" );
                fi;
              od;
            fi;
            l := list;
        elif IsList( list[1] ) then
            l := ListWithIdenticalEntries( Length( list ), 0 );
            for i in [1..Length( list )] do
                l[i] := Vector( list[i], t );
                if check and Length( list[i] ) <> ncols then
                  Error( "incompatible lengths of vectors" );
                fi;
            od;
        else  # a flat initializer:
            nrrows := Length( list ) / ncols;
            l := ListWithIdenticalEntries(nrrows,0);
            for i in [1..nrrows] do
                l[i] := Vector( list{ [(i-1)*ncols+1..i*ncols] }, t );
            od;
        fi;
    else
        l := [];
    fi;
    # The result shall be mutable iff 'rows' is mutable.
    if not IsMutable( list ) then
      MakeImmutable( l );
    fi;
    return MakeIsRowPlistMatrixRep( basedomain, t, ncols, l, false );
  end );


############################################################################
# A selection of list operations:
############################################################################

InstallOtherMethod( \[\],
#T Once the declaration of '\[\]' for 'IsMatrixObj' disappears,
#T we can use 'InstallMethod'.
  [ "IsRowPlistMatrixRep", "IsPosInt" ],
  { M, p } -> M![ROWSPOS][p] );

InstallMethod( \[\]\:\=,
  [ "IsRowPlistMatrixRep and IsMutable", "IsPosInt", "IsPlistVectorRep" ],
  function( M, p, v )
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( M![BDPOS], v![BDPOS] ) or
         Length( v ) <> M![RLPOS] ) then
      Error( "<M> and <v> are not compatible" );
    fi;
    M![ROWSPOS][p] := v;
  end );

InstallMethod( \{\},
  [ "IsRowPlistMatrixRep", "IsList" ],
  { M, list } -> MakeIsRowPlistMatrixRep( M![BDPOS], M![EMPOS], M![RLPOS],
                     M![ROWSPOS]{ list }, false ) );

InstallMethod( Add,
  [ "IsRowPlistMatrixRep and IsMutable", "IsPlistVectorRep" ],
  function( M, v )
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( M![BDPOS], v![BDPOS] ) or
         Length( v ) <> M![RLPOS] ) then
      Error( "<M> and <v> are not compatible" );
    fi;
    Add( M![ROWSPOS], v );
  end );

InstallMethod( Add,
  [ "IsRowPlistMatrixRep and IsMutable", "IsPlistVectorRep", "IsPosInt" ],
  function( M, v, p )
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( M![BDPOS], v![BDPOS] ) or
         Length( v ) <> M![RLPOS] ) then
      Error( "<M> and <v> are not compatible" );
    fi;
    Add( M![ROWSPOS], v, p );
  end );

InstallMethod( Remove,
  [ "IsRowPlistMatrixRep and IsMutable" ],
  M -> Remove( M![ROWSPOS] ) );

InstallMethod( Remove,
  [ "IsRowPlistMatrixRep and IsMutable", "IsPosInt" ],
  function( M, p )
    if p <= Length( M![ROWSPOS] ) then
      return Remove( M![ROWSPOS], p );
    fi;
  end );

InstallMethod( IsBound\[\],
  [ "IsRowPlistMatrixRep", "IsPosInt" ],
  { M, p } -> p <= Length( M![ROWSPOS] ) );

InstallMethod( Unbind\[\],
  [ "IsRowPlistMatrixRep and IsMutable", "IsPosInt" ],
  function( M, p )
    if p <> Length( M![ROWSPOS] ) then
        ErrorNoReturn("Unbind\\[\\]: Matrices must stay dense, you cannot Unbind here");
    fi;
    Unbind( M![ROWSPOS][p] );
  end );

InstallMethod( \{\}\:\=,
  [ "IsRowPlistMatrixRep and IsMutable", "IsList",
    "IsRowPlistMatrixRep" ],
  function( M, pp, N )
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( M![BDPOS], N![BDPOS] ) or
         M![RLPOS] <> N![RLPOS] ) then
      Error( "<M> and <N> are not compatible" );
    fi;
    M![ROWSPOS]{pp} := N![ROWSPOS];
  end );

InstallMethod( Append,
  [ "IsRowPlistMatrixRep and IsMutable", "IsRowPlistMatrixRep" ],
  function( M, N )
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( M![BDPOS], N![BDPOS] ) or
         M![RLPOS] <> N![RLPOS] ) then
      Error( "<M> and <N> are not compatible" );
    fi;
    Append( M![ROWSPOS], N![ROWSPOS] );
  end );

InstallMethod( ShallowCopy,
  [ "IsRowPlistMatrixRep" ],
  M -> MakeIsRowPlistMatrixRep( M![BDPOS], M![EMPOS], M![RLPOS],
           ShallowCopy( M![ROWSPOS] ), false ) );

InstallMethod( PostMakeImmutable,
  [ "IsRowPlistMatrixRep" ],
  function( M )
    MakeImmutable( M![ROWSPOS] );
  end );

InstallMethod( ListOp,
  [ "IsRowPlistMatrixRep" ],
  M -> List( M![ROWSPOS] ) );

InstallMethod( ListOp,
  [ "IsRowPlistMatrixRep", "IsFunction" ],
  { M, f } -> List( M![ROWSPOS], f ) );

InstallMethod( Unpack,
  [ "IsRowPlistMatrixRep" ],
  M -> List( M![ROWSPOS], v -> ShallowCopy( v![ELSPOS] ) ) );

InstallMethod( MutableCopyMatrix,
  [ "IsRowPlistMatrixRep" ],
  M -> MakeIsRowPlistMatrixRep( M![BDPOS], M![EMPOS], M![RLPOS],
           List( M![ROWSPOS], ShallowCopy ), false ) );

InstallMethod( ExtractSubMatrix,
  [ "IsRowPlistMatrixRep", "IsList", "IsList" ],
  function( M, rowspos, colspos )
    local i, list;
    list := M![ROWSPOS]{ rowspos };
    for i in [ 1 .. Length( list ) ] do
      list[i]:= MakeIsPlistVectorRep( list[i]![BDPOS],
                    list[i]![ELSPOS]{ colspos }, false );
    od;
    return MakeIsRowPlistMatrixRep( M![BDPOS], M![EMPOS], Length( colspos ),
               list, false );
  end );

InstallMethod( CopySubMatrix,
  [ "IsRowPlistMatrixRep", "IsRowPlistMatrixRep and IsMutable",
    "IsList", "IsList", "IsList", "IsList" ],
  function( M, N, srcrows, dstrows, srccols, dstcols )
    local i;
    if ValueOption( "check" ) <> false and
       not IsIdenticalObj( M![BDPOS], N![BDPOS] ) then
      Error( "<M> and <N> are not compatible" );
    fi;
    # This eventually should go into the kernel without creating
    # intermediate objects:
    for i in [1..Length(srcrows)] do
        N![ROWSPOS][dstrows[i]]![ELSPOS]{dstcols} :=
                  M![ROWSPOS][srcrows[i]]![ELSPOS]{srccols};
    od;
  end );

InstallOtherMethod( CopySubMatrix,
  "for two plists -- fallback in case of bad rep.",
  [ "IsPlistRep", "IsPlistRep and IsMutable",
    "IsList", "IsList", "IsList", "IsList" ],
  function( M, N, srcrows, dstrows, srccols, dstcols )
    local i;
    # in this representation all access probably has to go through the
    # generic method selection, so it is not clear whether there is an
    # improvement in moving this into the kernel.
    for i in [1..Length(srcrows)] do
        N[dstrows[i]]{dstcols}:= M[srcrows[i]]{srccols};
    od;
  end );
#T move to another file?

InstallMethod( MatElm,
  [ "IsRowPlistMatrixRep", "IsPosInt", "IsPosInt" ],
  { M, row, col } -> M![ROWSPOS][row]![ELSPOS][col] );

InstallMethod( SetMatElm,
  [ "IsRowPlistMatrixRep and IsMutable", "IsPosInt", "IsPosInt", "IsObject" ],
  function( M, row, col, ob )
    if ValueOption( "check" ) <> false then
      if not ob in BaseDomain( M ) then
        Error( "<ob> must lie in the base domain of <M>" );
      elif col > M![RLPOS] then
        Error( "<col> must be at most <M>![RLPOS]" );
      fi;
    fi;
    M![ROWSPOS][row]![ELSPOS][col] := ob;
  end );


############################################################################
# Printing and viewing methods:
############################################################################

InstallMethod( ViewObj, [ "IsRowPlistMatrixRep" ],
  function( M )
    Print("<");
    if not IsMutable(M) then Print("immutable "); fi;
    Print(Length(M![ROWSPOS]),"x",M![RLPOS],"-matrix over ",M![BDPOS],">");
  end );

InstallMethod( PrintObj, [ "IsRowPlistMatrixRep" ],
  function( M )
    Print("NewMatrix(IsRowPlistMatrixRep");
    if IsFinite(M![BDPOS]) and IsField(M![BDPOS]) then
        Print(",GF(",Size(M![BDPOS]),"),");
    else
        Print(",",String(M![BDPOS]),",");
    fi;
    Print(NumberColumns(M),",",Unpack(M),")");
  end );

InstallMethod( Display, [ "IsRowPlistMatrixRep" ],
  function( M )
    local i;
    Print("<");
    if not IsMutable(M) then Print("immutable "); fi;
    Print(Length(M![ROWSPOS]),"x",M![RLPOS],"-matrix over ",M![BDPOS],":\n");
    for i in [1..Length(M![ROWSPOS])] do
        if i = 1 then
            Print("[");
        else
            Print(" ");
        fi;
        Print(M![ROWSPOS][i]![ELSPOS],"\n");
    od;
    Print("]>\n");
  end );

InstallMethod( String, [ "IsRowPlistMatrixRep" ],
  function( M )
    local st;
    st := "NewMatrix(IsRowPlistMatrixRep";
    Add(st,',');
    if IsFinite(M![BDPOS]) and IsField(M![BDPOS]) then
        Append(st,"GF(");
        Append(st,String(Size(M![BDPOS])));
        Append(st,"),");
    else
        Append(st,String(M![BDPOS]));
        Append(st,",");
    fi;
    Append(st,String(NumberColumns(M)));
    Add(st,',');
    Append(st,String(Unpack(M)));
    Add(st,')');
    return st;
  end );

############################################################################
# Arithmetical operations:
############################################################################

InstallMethod( \+,
  [ "IsRowPlistMatrixRep", "IsRowPlistMatrixRep" ],
  function( a, b )
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( a![BDPOS], b![BDPOS] ) or
         a![RLPOS] <> b![RLPOS] ) then
      Error( "<a> and <b> are not compatible" );
    fi;
    return MakeIsRowPlistMatrixRep( a![BDPOS], a![EMPOS], a![RLPOS],
               SUM_LIST_LIST_DEFAULT( a![ROWSPOS], b![ROWSPOS] ), false );
  end );

InstallMethod( \-,
  [ "IsRowPlistMatrixRep", "IsRowPlistMatrixRep" ],
  function( a, b )
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( a![BDPOS], b![BDPOS] ) or
         a![RLPOS] <> b![RLPOS] ) then
      Error( "<a> and <b> are not compatible" );
    fi;
    return MakeIsRowPlistMatrixRep( a![BDPOS], a![EMPOS], a![RLPOS],
               DIFF_LIST_LIST_DEFAULT( a![ROWSPOS], b![ROWSPOS] ), false );
  end );

InstallMethod( \*,
  [ "IsRowPlistMatrixRep", "IsRowPlistMatrixRep" ],
  function( a, b )
    local i,j,l,v,w;
    if ValueOption( "check" ) <> false then
      if not a![RLPOS] = Length(b![ROWSPOS]) then
        ErrorNoReturn("\\*: Matrices do not fit together");
      elif not IsIdenticalObj(a![BDPOS],b![BDPOS]) then
        ErrorNoReturn("\\*: Matrices not over same base domain");
      fi;
    fi;
    l := ListWithIdenticalEntries(Length(a![ROWSPOS]),0);
    for i in [1..Length(l)] do
        if b![RLPOS] = 0 then
            l[i] := b![EMPOS];
        else
            v := a![ROWSPOS][i];
            w := ZeroVector(b![RLPOS],b![EMPOS]);
            for j in [1..a![RLPOS]] do
                AddRowVector(w,b![ROWSPOS][j],v[j]);
            od;
            l[i] := w;
        fi;
    od;
    if not IsMutable(a) and not IsMutable(b) then
        MakeImmutable(l);
    fi;
    return MakeIsRowPlistMatrixRep( a![BDPOS], a![EMPOS], b![RLPOS], l, false );
  end );

InstallMethod( \=,
  [ "IsRowPlistMatrixRep", "IsRowPlistMatrixRep" ],
  { a, b } -> EQ_LIST_LIST_DEFAULT( a![ROWSPOS], b![ROWSPOS] ) );

InstallMethod( \<,
  [ "IsRowPlistMatrixRep", "IsRowPlistMatrixRep" ],
  { a, b } -> LT_LIST_LIST_DEFAULT( a![ROWSPOS], b![ROWSPOS] ) );

# According to "Mutability Status and List Arithmetic":
# If the result is mutable then
# all its rows are mutable if the first row of 'M' is mutable,
# and all its rows are immutable otherwise.
InstallMethod( AdditiveInverseSameMutability,
  [ "IsRowPlistMatrixRep" ],
  function( M )
    local l;

    if not IsMutable( M ) then
      l:= MakeImmutable( List( M![ROWSPOS], AdditiveInverseImmutable ) );
    elif 0 < NumberRows( M ) and IsMutable( M![ROWSPOS][1] ) then
      l:= List( M![ROWSPOS], AdditiveInverseMutable );
    else
      l:= List( M![ROWSPOS], AdditiveInverseImmutable );
    fi;
    return MakeIsRowPlistMatrixRep( M![BDPOS], M![EMPOS], M![RLPOS], l, false );
  end );

InstallMethod( AdditiveInverseImmutable,
  [ "IsRowPlistMatrixRep" ],
  M -> MakeIsRowPlistMatrixRep( M![BDPOS], M![EMPOS], M![RLPOS],
           MakeImmutable( List( M![ROWSPOS], AdditiveInverseImmutable ) ),
           false ) );

# all rows mutable
InstallMethod( AdditiveInverseMutable,
  [ "IsRowPlistMatrixRep" ],
  M -> MakeIsRowPlistMatrixRep( M![BDPOS], M![EMPOS], M![RLPOS],
           List( M![ROWSPOS], AdditiveInverseMutable ), false ) );

InstallMethod( ZeroSameMutability,
  [ "IsRowPlistMatrixRep" ],
  function( M )
    local l;

    if not IsMutable( M ) then
      l:= MakeImmutable( List( M![ROWSPOS], ZeroImmutable ) );
    elif 0 < NumberRows( M ) and IsMutable( M![ROWSPOS][1] ) then
      l:= List( M![ROWSPOS], ZeroMutable );
    else
      l:= List( M![ROWSPOS], ZeroImmutable );
    fi;
    return MakeIsRowPlistMatrixRep( M![BDPOS], M![EMPOS], M![RLPOS], l, false );
  end );

InstallMethod( ZeroImmutable,
  [ "IsRowPlistMatrixRep" ],
  function( M )
    M:= MakeIsRowPlistMatrixRep( M![BDPOS], M![EMPOS], M![RLPOS],
            MakeImmutable( List( M![ROWSPOS], ZeroImmutable ) ), false );
    SetIsZero( M, true );
    return M;
  end );

InstallMethod( ZeroMutable,
  [ "IsRowPlistMatrixRep" ],
  M -> MakeIsRowPlistMatrixRep( M![BDPOS], M![EMPOS], M![RLPOS],
           List( M![ROWSPOS], ZeroMutable ), false ) );

InstallMethod( IsZero,
  [ "IsRowPlistMatrixRep" ],
  function( M )
    local i;
    for i in [1..Length(M![ROWSPOS])] do
        if not IsZero(M![ROWSPOS][i]) then
            return false;
        fi;
    od;
    return true;
  end );

InstallMethod( IsOne,
  [ "IsRowPlistMatrixRep" ],
  function( M )
    local n, i, row;
    if Length(M![ROWSPOS]) <> M![RLPOS] then
        #Error("IsOne: Matrix must be square");
        return false;
    fi;
    n := M![RLPOS];
    for i in [1..n] do
      row:= M![ROWSPOS][i];
      if PositionNonZero( row ) <> i or
         not IsOne( row![ELSPOS][i] ) or
         PositionNonZero( row, i ) <= n then
        return false;
      fi;
    od;
    return true;
  end );

InstallMethod( OneSameMutability,
  [ "IsRowPlistMatrixRep" ],
  function( M )
    local o, i;
    if M![RLPOS] <> Length(M![ROWSPOS]) then
        #Error("OneSameMutability: Matrix is not square");
        #return;
        return fail;
    fi;
    o := IdentityMatrix(M![RLPOS],M);
    if not IsMutable( M ) then
      # result immutable
      MakeImmutable( o );
      SetIsOne( o, true );
    elif 0 < NumberRows( M ) and IsMutable( M![ROWSPOS][1] ) then
      # all rows mutable
    else
      # mutable, all rows immutable
      M:= IdentityMatrix( M![RLPOS], M );
      for i in [ 1 .. NrRows( o ) ] do
        MakeImmutable( o![ROWSPOS][i] );
      od;
    fi;
    return o;
  end );

InstallMethod( OneMutable,
  [ "IsRowPlistMatrixRep" ],
  function( M )
    if M![RLPOS] <> Length(M![ROWSPOS]) then
        #Error("OneMutable: Matrix is not square");
        #return;
        return fail;
    fi;
    return IdentityMatrix(M![RLPOS],M);
  end );

InstallMethod( OneImmutable,
  [ "IsRowPlistMatrixRep" ],
  function( M )
    if M![RLPOS] <> Length(M![ROWSPOS]) then
        #Error("OneImmutable: Matrix is not square");
        #return;
        return fail;
    fi;
    M:= MakeImmutable( IdentityMatrix( M![RLPOS], M ) );
    SetIsOne( M, true );
    return M;
  end );

# For the moment we delegate to the fast kernel arithmetic for plain
# lists of plain lists:

InstallMethod( InverseMutable,
  [ "IsRowPlistMatrixRep" ],
  function( M )
    local n;
    if M![RLPOS] <> Length(M![ROWSPOS]) then
        #Error("InverseMutable: Matrix is not square");
        #return;
        return fail;
    fi;
    # Make a plain list of lists:
    n := List(M![ROWSPOS],x->x![ELSPOS]);
    n := InverseMutable(n);  # Invert!
    if n = fail then return fail; fi;
    return Matrix(n,Length(n),M);
  end );

InstallMethod( InverseImmutable,
  [ "IsRowPlistMatrixRep" ],
  function( M )
    local n;
    if M![RLPOS] <> Length(M![ROWSPOS]) then
        #Error("InverseMutable: Matrix is not square");
        #return;
        return fail;
    fi;
    # Make a plain list of lists:
    n := List(M![ROWSPOS],x->x![ELSPOS]);
    n := InverseImmutable(n);  # Invert!
    if n = fail then return fail; fi;
    return Matrix(n,Length(n),M);
  end );

InstallMethod( InverseSameMutability,
  [ "IsRowPlistMatrixRep" ],
  function( M )
    local n;
    if M![RLPOS] <> Length(M![ROWSPOS]) then
        #Error("InverseMutable: Matrix is not square");
        #return;
        return fail;
    fi;
    # Make a plain list of lists:
    n := List(M![ROWSPOS],x->x![ELSPOS]);
    if not IsMutable(M) then
        MakeImmutable(n);
    fi;
    n := InverseSameMutability(n);  # Invert!
    if n = fail then return fail; fi;
    return Matrix(n,Length(n),M);
#T does 'Matrix' respect the "mixed mutability rules" from "Mutability Status ..."?
  end );

InstallMethod( RankMat,
  [ "IsRowPlistMatrixRep" ],
  M -> RankMat( List( M![ROWSPOS], x -> x![ELSPOS] ) ) );

InstallMethodWithRandomSource( Randomize,
  "for a random source and a mutable plist matrix",
  [ IsRandomSource, IsRowPlistMatrixRep and IsMutable ],
  function( rs, M )
    local v;
    for v in M![ROWSPOS] do
        Randomize( rs, v );
    od;
    return M;
  end );

InstallMethod( TransposedMatMutable,
  [ "IsRowPlistMatrixRep" ],
  function( M )
    local i,n;
    n := ListWithIdenticalEntries(M![RLPOS],0);
    for i in [1..M![RLPOS]] do
        n[i]:= Vector(List(M![ROWSPOS],v->v![ELSPOS][i]),M![EMPOS]);
    od;
    return MakeIsRowPlistMatrixRep( M![BDPOS], M![EMPOS], Length(M![ROWSPOS]), n, false );
  end );

InstallMethod( \*,
  [ "IsPlistVectorRep", "IsRowPlistMatrixRep" ],
  function( v, M )
    local i,res,s;
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( v![BDPOS], M![BDPOS] ) or
         Length( v ) <> NumberRows( M ) ) then
      Error( "<v> and <M> are not compatible" );
    fi;
    res := ZeroVector(M![RLPOS],M![EMPOS]);
    for i in [1..Length(v![ELSPOS])] do
        s := v![ELSPOS][i];
        if not IsZero(s) then
            AddRowVector( res, M![ROWSPOS][i], s );
        fi;
    od;
    if not IsMutable(v) and not IsMutable(M) then
        MakeImmutable(res);
    fi;
    return res;
  end );

#InstallMethod( \^,
#  [ "IsRowPlistMatrixRep", "IsInt" ],
#  function( M, i )
#    local mi;
#    if M![RLPOS] <> Length(M![ROWSPOS]) then
#        #Error("\\^: Matrix must be square");
#        #return;
#        return fail;
#    fi;
#    if i = 0 then return OneSameMutability(M);
#    elif i > 0 then return POW_OBJ_INT(M,i);
#    else
#        mi := InverseSameMutability(M);
#        if mi = fail then return fail; fi;
#        return POW_OBJ_INT( mi, -i );
#    fi;
#  end );

InstallMethod( ConstructingFilter,
  [ "IsPlistVectorRep" ],
  v -> IsPlistVectorRep );

InstallMethod( ConstructingFilter,
  [ "IsRowPlistMatrixRep" ],
  M -> IsRowPlistMatrixRep );

InstallMethod( ChangedBaseDomain,
  [ "IsPlistVectorRep", "IsRing" ],
  function( v, r )
    r:= NewVector( IsPlistVectorRep, r, v![ELSPOS] );
    if not IsMutable( v ) then
      MakeImmutable( r );
    fi;
    return r;
  end );

InstallMethod( ChangedBaseDomain,
  [ "IsRowPlistMatrixRep", "IsRing" ],
  function( M, r )
    r:= NewMatrix( IsRowPlistMatrixRep, r, M![RLPOS],
                   List( M![ROWSPOS], x-> x![ELSPOS] ) );
    if not IsMutable( M ) then
      MakeImmutable( r );
    fi;
    return r;
  end );

# We know that 'CompatibleVectorFilter( M )' is 'IsPlistVectorRep'.
InstallMethod( CompatibleVector,
  [ "IsRowPlistMatrixRep" ],
  M -> NewZeroVector( IsPlistVectorRep, BaseDomain( M ), NumberRows( M ) ) );

