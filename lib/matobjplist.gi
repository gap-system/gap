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

BindGlobal( "MakeIsPlistMatrixRep",
  function( basedomain, emptyvector, rowlength, list, check )
    local fam, types, typ, row;
    fam:= CollectionsFamily( FamilyObj( basedomain ) );

    # Currently there is no special handling depending on 'basedomain',
    # the types are always cached in 'fam'.
    if not IsBound( fam!.PlistMatrixRepTypes ) then
      # initialize type cache
      # TODO: make this thread safe for HPC-GAP
      fam!.PlistMatrixRepTypes:= [
          NewType( fam, IsPlistMatrixRep ),
          NewType( fam, IsPlistMatrixRep and IsMutable ),
      ];
      fam!.PlistMatrixRepTypesEasyCompare:= [
          NewType( fam, IsPlistMatrixRep and CanEasilyCompareElements ),
          NewType( fam, IsPlistMatrixRep and CanEasilyCompareElements and IsMutable ),
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
      for row in list do
        if not IsPlistVectorRep( row ) then
          Error( "the entries of <list> must be in 'IsPlistVectorRep'" );
        elif not IsIdenticalObj( basedomain, row![BDPOS] ) then
          Error( "the entries of <list> must have the given base domain" );
        elif not IsSubset( basedomain, row![ELSPOS] ) then
          Error( "the elements in <row> must lie in <basedomain>" );
        elif Length( row![ELSPOS] ) <> rowlength then
          Error( "the entries of <list> must have length <rowlength>" );
        fi;
      od;
    fi;

    return Objectify( typ, [ basedomain, emptyvector, rowlength, list ] );
  end );

InstallMethod( NewVector,
  [ "IsPlistVectorRep", "IsRing", "IsDenseList" ],
  function( filter, basedomain, l )
    return MakeIsPlistVectorRep(basedomain, ShallowCopy(l), true);
  end );

InstallMethod( NewZeroVector,
  [ "IsPlistVectorRep", "IsRing", "IsInt" ],
  function( filter, basedomain, len )
    local list;
    list := ListWithIdenticalEntries(len, Zero(basedomain));
    return MakeIsPlistVectorRep(basedomain, list, false);
  end );

InstallMethod( NewMatrix,
  [ "IsPlistMatrixRep", "IsRing", "IsInt", "IsList" ],
  function( filter, basedomain, rl, l )
    local nd, filterVectors, m, e, i;

    # If applicable then replace a flat list 'l' by a nested list
    # of lists of length 'rl'.
    if Length(l) > 0 and not IsVectorObj(l[1]) then
      nd := NestingDepthA(l);
      if nd < 2 or nd mod 2 = 1 then
        if Length(l) mod rl <> 0 then
          Error( "NewMatrix: Length of l is not a multiple of rl" );
        fi;
        l := List([0,rl..Length(l)-rl], i -> l{[i+1..i+rl]});
      fi;
    fi;

    filterVectors := IsPlistVectorRep;
    m := 0*[1..Length(l)];
    for i in [1..Length(l)] do
        if IsVectorObj(l[i]) and filterVectors(l[i]) then
            m[i] := ShallowCopy(l[i]);
        else
            m[i] := NewVector( filterVectors, basedomain, l[i] );
        fi;
    od;
    e := NewVector(filterVectors, basedomain, []);
    return MakeIsPlistMatrixRep( basedomain, e, rl, m, true );
  end );

InstallMethod( NewZeroMatrix,
  [ "IsPlistMatrixRep", "IsRing", "IsInt", "IsInt" ],
  function( filter, basedomain, rows, cols )
    local m,i,e,filter2;
    filter2 := IsPlistVectorRep;
    m := 0*[1..rows];
    e := NewVector(filter2, basedomain, []);
    for i in [1..rows] do
        m[i] := ZeroVector( cols, e );
    od;
    return MakeIsPlistMatrixRep( basedomain, e, cols, m, false );
  end );

InstallMethod( NewIdentityMatrix,
  [ "IsPlistMatrixRep", "IsRing", "IsInt" ],
  function( filter, basedomain, dim )
    local mat, one, i;
    mat := NewZeroMatrix(filter, basedomain, dim, dim);
    one := One(basedomain);
    for i in [1..dim] do
        mat[i,i] := one;
    od;
    return mat;
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

InstallMethod( CompatibleVectorFilter, ["IsPlistMatrixRep"],
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
  function( v )
    return v![BDPOS];
  end );

InstallMethod( Length, [ "IsPlistVectorRep" ],
  function( v )
    return Length(v![ELSPOS]);
  end );


############################################################################
# Representation preserving constructors:
############################################################################

InstallMethod( ZeroVector,
  [ "IsInt", "IsPlistVectorRep" ],
  function( l, v )
    return NewZeroVector(IsPlistVectorRep, v![BDPOS], l);
  end );

InstallMethod( ZeroVector,
  [ "IsInt", "IsPlistMatrixRep" ],
  function( l, m )
    return NewZeroVector(IsPlistVectorRep, m![BDPOS], l);
  end );

InstallMethod( Vector,
  [ "IsList and IsPlistRep", "IsPlistVectorRep" ],
  function( l, v )
    # wrap the given list without copying it (this is documented behavior)
    return MakeIsPlistVectorRep( v![BDPOS], l, true );
  end );

InstallMethod( Vector,
  [ "IsList", "IsPlistVectorRep" ],
  function( l, v )
    local m;
    m := IsMutable(l);
    l := PlainListCopy(l);
    if not m then
        MakeImmutable(l);
    fi;
    return MakeIsPlistVectorRep( v![BDPOS], l, true );
  end );


############################################################################
# A selection of list operations:
############################################################################

InstallMethod( \[\],
  [ "IsPlistVectorRep", "IsPosInt" ],
  function( v, p )
    return v![ELSPOS][p];
  end );

InstallMethod( \[\]\:\=,
  [ "IsPlistVectorRep", "IsPosInt", "IsObject" ],
  function( v, p, ob )
    v![ELSPOS][p] := ob;
  end );

InstallMethod( \{\},
  [ "IsPlistVectorRep", "IsList" ],
  function( v, l )
    return MakeIsPlistVectorRep(v![BDPOS], v![ELSPOS]{l}, false);
  end );

InstallMethod( PositionNonZero, [ "IsPlistVectorRep" ],
  function( v )
    return PositionNonZero( v![ELSPOS] );
  end );

InstallOtherMethod( PositionNonZero,
  [ "IsPlistVectorRep", "IsInt" ],
  function( v,s )
    return PositionNonZero( v![ELSPOS],s );
  end );

InstallMethod( PositionLastNonZero, [ "IsPlistVectorRep" ],
  function( v )
    local els,i;
    els := v![ELSPOS];
    i := Length(els);
    while i > 0 and IsZero(els[i]) do i := i - 1; od;
    return i;
  end );

InstallMethod( ListOp, [ "IsPlistVectorRep" ],
  function( v )
    return v![ELSPOS]{[1..Length(v![ELSPOS])]};
  end );

InstallMethod( ListOp,
  [ "IsPlistVectorRep", "IsFunction" ],
  function( v, f )
    return List(v![ELSPOS],f);
  end );

InstallMethod( Unpack,
  [ "IsPlistVectorRep" ],
  function( v )
    return ShallowCopy(v![ELSPOS]);
  end );


############################################################################
# Standard operations for all objects:
############################################################################

InstallMethod( ShallowCopy, [ "IsPlistVectorRep" ],
  function( v )
    return MakeIsPlistVectorRep(v![BDPOS], ShallowCopy(v![ELSPOS]), false);
  end );

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
  function( a, b )
    return EQ_LIST_LIST_DEFAULT(a![ELSPOS],b![ELSPOS]);
  end );

InstallMethod( \<,
  [ "IsPlistVectorRep", "IsPlistVectorRep" ],
  function( a, b )
    return LT_LIST_LIST_DEFAULT(a![ELSPOS],b![ELSPOS]);
  end );

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
  function( v, s )
    return MakeIsPlistVectorRep(v![BDPOS], PROD_LIST_SCL_DEFAULT(v![ELSPOS],s), true);
  end );

InstallMethod( \*,
  [ "IsScalar", "IsPlistVectorRep" ],
  function( s, v )
    return MakeIsPlistVectorRep(v![BDPOS], PROD_SCL_LIST_DEFAULT(s,v![ELSPOS]), true);
  end );

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
  function( v )
    return MakeIsPlistVectorRep(v![BDPOS],
               AdditiveInverseSameMutability(v![ELSPOS]), false);
  end );

InstallMethod( AdditiveInverseImmutable,
  [ "IsPlistVectorRep" ],
  function( v )
    return MakeIsPlistVectorRep(v![BDPOS],
               AdditiveInverseImmutable(v![ELSPOS]), false);
  end );

InstallMethod( AdditiveInverseMutable,
  [ "IsPlistVectorRep" ],
  function( v )
    return MakeIsPlistVectorRep(v![BDPOS],
               AdditiveInverseMutable(v![ELSPOS]), false);
  end );

InstallMethod( ZeroSameMutability, [ "IsPlistVectorRep" ],
  function( v )
    return MakeIsPlistVectorRep(v![BDPOS],
               ZeroSameMutability(v![ELSPOS]), false);
  end );

InstallMethod( ZeroImmutable, [ "IsPlistVectorRep" ],
  function( v )
    return MakeIsPlistVectorRep(v![BDPOS],
               ZeroImmutable(v![ELSPOS]), false);
  end );

InstallMethod( ZeroMutable, [ "IsPlistVectorRep" ],
  function( v )
    return MakeIsPlistVectorRep(v![BDPOS], ZeroMutable(v![ELSPOS]), false);
  end );

InstallMethod( IsZero, [ "IsPlistVectorRep" ],
  function( v )
    return IsZero( v![ELSPOS] );
  end );

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
  [ "IsPlistMatrixRep" ],
  function( m )
    return m![BDPOS];
  end );

InstallMethod( NumberRows,
  [ "IsPlistMatrixRep" ],
  function( m )
    return Length(m![ROWSPOS]);
  end );

InstallMethod( NumberColumns,
  [ "IsPlistMatrixRep" ],
  function( m )
    return m![RLPOS];
  end );

InstallMethod( DimensionsMat,
  [ "IsPlistMatrixRep" ],
  function( m )
    return [Length(m![ROWSPOS]),m![RLPOS]];
  end );


############################################################################
# Representation preserving constructors:
############################################################################

InstallMethod( ZeroMatrix,
  [ "IsInt", "IsInt", "IsPlistMatrixRep" ],
  function( rows,cols,m )
    local t, l;
    t := m![EMPOS];
    l := List([1..rows],i->ZeroVector(cols,t));
    return MakeIsPlistMatrixRep( m![BDPOS], t, cols, l, false );
  end );

InstallMethod( IdentityMatrix,
  [ "IsInt", "IsPlistMatrixRep" ],
  function( rows,m )
    local t,l,o,i;
    t := m![EMPOS];
    l := List([1..rows],i->ZeroVector(rows,t));
    o := One(m![BDPOS]);
#T can 'o = fail' happen?
    for i in [1..rows] do
        l[i][i] := o;
    od;
    return MakeIsPlistMatrixRep( m![BDPOS], t, rows, l, false );
  end );

InstallMethod( Matrix,
  [ "IsList", "IsInt", "IsPlistMatrixRep" ],
  function( rows,rowlen,m )
    local basedomain, check, i,l,nrrows,t;
    t := m![EMPOS];
    basedomain:= m![BDPOS];
    check:= ValueOption( "check" ) <> false;
    if Length(rows) > 0 then
        if IsVectorObj(rows[1]) and IsPlistVectorRep(rows[1]) then
            if check then
              for i in rows do
                if not IsIdenticalObj( basedomain, BaseDomain( i ) ) then
                  Error( "not the same <basedomain>" );
                elif Length( i ) <> rowlen then
                  Error( "incompatible lengths of vectors" );
                fi;
              od;
            fi;
            l := rows;
        elif IsList(rows[1]) then
            l := ListWithIdenticalEntries(Length(rows),0);
            for i in [1..Length(rows)] do
                l[i] := Vector(rows[i],t);
                if check and Length( rows[i] ) <> rowlen then
                  Error( "incompatible lengths of vectors" );
                fi;
            od;
        else  # a flat initializer:
            nrrows := Length(rows)/rowlen;
            l := ListWithIdenticalEntries(nrrows,0);
            for i in [1..nrrows] do
                l[i] := Vector(rows{[(i-1)*rowlen+1..i*rowlen]},t);
            od;
        fi;
    else
        l := [];
    fi;
    # The result shall be mutable iff 'rows' is mutable.
    if not IsMutable( rows ) then
      MakeImmutable( l );
    fi;
    return MakeIsPlistMatrixRep( basedomain, t, rowlen, l, false );
  end );


############################################################################
# A selection of list operations:
############################################################################

InstallOtherMethod( \[\],
#T Once the declaration of '\[\]' for 'IsMatrixObj' disappears,
#T we can use 'InstallMethod'.
  [ "IsPlistMatrixRep", "IsPosInt" ],
  function( m, p )
    return m![ROWSPOS][p];
  end );

InstallMethod( \[\]\:\=,
  [ "IsPlistMatrixRep and IsMutable", "IsPosInt", "IsPlistVectorRep" ],
  function( m, p, v )
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( m![BDPOS], v![BDPOS] ) or
         Length( v ) <> m![RLPOS] ) then
      Error( "<m> and <v> are not compatible" );
    fi;
    m![ROWSPOS][p] := v;
  end );

InstallMethod( \{\},
  [ "IsPlistMatrixRep", "IsList" ],
  function( m, p )
    return MakeIsPlistMatrixRep( m![BDPOS], m![EMPOS], m![RLPOS], m![ROWSPOS]{p}, false );
  end );

InstallMethod( Add,
  [ "IsPlistMatrixRep and IsMutable", "IsPlistVectorRep" ],
  function( m, v )
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( m![BDPOS], v![BDPOS] ) or
         Length( v ) <> m![RLPOS] ) then
      Error( "<m> and <v> are not compatible" );
    fi;
    Add(m![ROWSPOS],v);
  end );

InstallMethod( Add,
  [ "IsPlistMatrixRep and IsMutable", "IsPlistVectorRep", "IsPosInt" ],
  function( m, v, p )
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( m![BDPOS], v![BDPOS] ) or
         Length( v ) <> m![RLPOS] ) then
      Error( "<m> and <v> are not compatible" );
    fi;
    Add(m![ROWSPOS],v,p);
  end );

InstallMethod( Remove,
  [ "IsPlistMatrixRep and IsMutable" ],
  m -> Remove( m![ROWSPOS] ) );

InstallMethod( Remove,
  [ "IsPlistMatrixRep and IsMutable", "IsPosInt" ],
  function( m, p )
    if p <= Length( m![ROWSPOS] ) then
      return Remove( m![ROWSPOS], p );
    fi;
  end );

InstallMethod( IsBound\[\],
  [ "IsPlistMatrixRep", "IsPosInt" ],
  function( m, p )
    return p <= Length(m![ROWSPOS]);
  end );

InstallMethod( Unbind\[\],
  [ "IsPlistMatrixRep and IsMutable", "IsPosInt" ],
  function( m, p )
    if p <> Length(m![ROWSPOS]) then
        ErrorNoReturn("Unbind\\[\\]: Matrices must stay dense, you cannot Unbind here");
    fi;
    Unbind( m![ROWSPOS][p] );
  end );

InstallMethod( \{\}\:\=,
  [ "IsPlistMatrixRep and IsMutable", "IsList",
    "IsPlistMatrixRep" ],
  function( m, pp, n )
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( m![BDPOS], n![BDPOS] ) or
         m![RLPOS] <> n![RLPOS] ) then
      Error( "<m> and <n> are not compatible" );
    fi;
    m![ROWSPOS]{pp} := n![ROWSPOS];
  end );

InstallMethod( Append,
  [ "IsPlistMatrixRep and IsMutable", "IsPlistMatrixRep" ],
  function( m, n )
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( m![BDPOS], n![BDPOS] ) or
         m![RLPOS] <> n![RLPOS] ) then
      Error( "<m> and <n> are not compatible" );
    fi;
    Append(m![ROWSPOS],n![ROWSPOS]);
  end );

InstallMethod( ShallowCopy,
  [ "IsPlistMatrixRep" ],
  function( m )
    return MakeIsPlistMatrixRep( m![BDPOS], m![EMPOS], m![RLPOS],
                                 ShallowCopy( m![ROWSPOS] ), false );
  end );

InstallMethod( PostMakeImmutable,
  [ "IsPlistMatrixRep" ],
  function( m )
    MakeImmutable( m![ROWSPOS] );
  end );

InstallMethod( ListOp,
  [ "IsPlistMatrixRep" ],
  function( m )
    return List(m![ROWSPOS]);
  end );

InstallMethod( ListOp,
  [ "IsPlistMatrixRep", "IsFunction" ],
  function( m, f )
    return List(m![ROWSPOS],f);
  end );

InstallMethod( Unpack,
  [ "IsPlistMatrixRep" ],
  function( m )
    return List(m![ROWSPOS],v->ShallowCopy(v![ELSPOS]));
  end );

InstallMethod( MutableCopyMat,
  [ "IsPlistMatrixRep" ],
  function( m )
    return MakeIsPlistMatrixRep( m![BDPOS], m![EMPOS], m![RLPOS],
                                 List( m![ROWSPOS], ShallowCopy ), false );
  end);

InstallMethod( ExtractSubMatrix,
  [ "IsPlistMatrixRep", "IsList", "IsList" ],
  function( m, p, q )
    local i,l;
    l := m![ROWSPOS]{p};
    for i in [1..Length(l)] do
      l[i]:= MakeIsPlistVectorRep( l[i]![BDPOS], l[i]![ELSPOS]{q}, false );
    od;
    return MakeIsPlistMatrixRep( m![BDPOS], m![EMPOS], Length(q), l, false );
  end );

InstallMethod( CopySubMatrix,
  [ "IsPlistMatrixRep", "IsPlistMatrixRep and IsMutable",
    "IsList", "IsList", "IsList", "IsList" ],
  function( m, n, srcrows, dstrows, srccols, dstcols )
    local i;
    if ValueOption( "check" ) <> false and
       not IsIdenticalObj( m![BDPOS], n![BDPOS] ) then
      Error( "<m> and <n> are not compatible" );
    fi;
    # This eventually should go into the kernel without creating
    # intermediate objects:
    for i in [1..Length(srcrows)] do
        n![ROWSPOS][dstrows[i]]![ELSPOS]{dstcols} :=
                  m![ROWSPOS][srcrows[i]]![ELSPOS]{srccols};
    od;
  end );

InstallOtherMethod( CopySubMatrix,
  "for two plists -- fallback in case of bad rep.",
  [ "IsPlistRep", "IsPlistRep and IsMutable",
    "IsList", "IsList", "IsList", "IsList" ],
  function( m, n, srcrows, dstrows, srccols, dstcols )
    local i;
    # in this representation all access probably has to go through the
    # generic method selection, so it is not clear whether there is an
    # improvement in moving this into the kernel.
    for i in [1..Length(srcrows)] do
        n[dstrows[i]]{dstcols}:=m[srcrows[i]]{srccols};
    od;
  end );
#T move to another file?

InstallMethod( MatElm,
  [ "IsPlistMatrixRep", "IsPosInt", "IsPosInt" ],
  function( m, row, col )
    return m![ROWSPOS][row]![ELSPOS][col];
  end );

InstallMethod( SetMatElm,
  [ "IsPlistMatrixRep and IsMutable", "IsPosInt", "IsPosInt", "IsObject" ],
  function( m, row, col, ob )
    if ValueOption( "check" ) <> false then
      if not ob in BaseDomain( m ) then
        Error( "<ob> must lie in the base domain of <m>" );
      elif col > m![RLPOS] then
        Error( "<col> must be at most <m>![RLPOS]" );
      fi;
    fi;
    m![ROWSPOS][row]![ELSPOS][col] := ob;
  end );


############################################################################
# Printing and viewing methods:
############################################################################

InstallMethod( ViewObj, [ "IsPlistMatrixRep" ],
  function( m )
    Print("<");
    if not IsMutable(m) then Print("immutable "); fi;
    Print(Length(m![ROWSPOS]),"x",m![RLPOS],"-matrix over ",m![BDPOS],">");
  end );

InstallMethod( PrintObj, [ "IsPlistMatrixRep" ],
  function( m )
    Print("NewMatrix(IsPlistMatrixRep");
    if IsFinite(m![BDPOS]) and IsField(m![BDPOS]) then
        Print(",GF(",Size(m![BDPOS]),"),");
    else
        Print(",",String(m![BDPOS]),",");
    fi;
    Print(NumberColumns(m),",",Unpack(m),")");
  end );

InstallMethod( Display, [ "IsPlistMatrixRep" ],
  function( m )
    local i;
    Print("<");
    if not IsMutable(m) then Print("immutable "); fi;
    Print(Length(m![ROWSPOS]),"x",m![RLPOS],"-matrix over ",m![BDPOS],":\n");
    for i in [1..Length(m![ROWSPOS])] do
        if i = 1 then
            Print("[");
        else
            Print(" ");
        fi;
        Print(m![ROWSPOS][i]![ELSPOS],"\n");
    od;
    Print("]>\n");
  end );

InstallMethod( String, [ "IsPlistMatrixRep" ],
  function( m )
    local st;
    st := "NewMatrix(IsPlistMatrixRep";
    Add(st,',');
    if IsFinite(m![BDPOS]) and IsField(m![BDPOS]) then
        Append(st,"GF(");
        Append(st,String(Size(m![BDPOS])));
        Append(st,"),");
    else
        Append(st,String(m![BDPOS]));
        Append(st,",");
    fi;
    Append(st,String(NumberColumns(m)));
    Add(st,',');
    Append(st,String(Unpack(m)));
    Add(st,')');
    return st;
  end );

############################################################################
# Arithmetical operations:
############################################################################

InstallMethod( \+,
  [ "IsPlistMatrixRep", "IsPlistMatrixRep" ],
  function( a, b )
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( a![BDPOS], b![BDPOS] ) or
         a![RLPOS] <> b![RLPOS] ) then
      Error( "<a> and <b> are not compatible" );
    fi;
    return MakeIsPlistMatrixRep( a![BDPOS], a![EMPOS], a![RLPOS],
               SUM_LIST_LIST_DEFAULT( a![ROWSPOS], b![ROWSPOS] ), false );
  end );

InstallMethod( \-,
  [ "IsPlistMatrixRep", "IsPlistMatrixRep" ],
  function( a, b )
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( a![BDPOS], b![BDPOS] ) or
         a![RLPOS] <> b![RLPOS] ) then
      Error( "<a> and <b> are not compatible" );
    fi;
    return MakeIsPlistMatrixRep( a![BDPOS], a![EMPOS], a![RLPOS],
               DIFF_LIST_LIST_DEFAULT( a![ROWSPOS], b![ROWSPOS] ), false );
  end );

InstallMethod( \*,
  [ "IsPlistMatrixRep", "IsPlistMatrixRep" ],
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
    return MakeIsPlistMatrixRep( a![BDPOS], a![EMPOS], b![RLPOS], l, false );
  end );

InstallMethod( \=,
  [ "IsPlistMatrixRep", "IsPlistMatrixRep" ],
  function( a, b )
    return EQ_LIST_LIST_DEFAULT(a![ROWSPOS],b![ROWSPOS]);
  end );

InstallMethod( \<,
  [ "IsPlistMatrixRep", "IsPlistMatrixRep" ],
  function( a, b )
    return LT_LIST_LIST_DEFAULT(a![ROWSPOS],b![ROWSPOS]);
  end );

InstallMethod( AdditiveInverseSameMutability,
  [ "IsPlistMatrixRep" ],
  function( m )
    local l;
    l := List(m![ROWSPOS],AdditiveInverseSameMutability);
    if not IsMutable(m) then
        MakeImmutable(l);
    fi;
    return MakeIsPlistMatrixRep( m![BDPOS], m![EMPOS], m![RLPOS], l, false );
  end );

InstallMethod( AdditiveInverseImmutable,
  [ "IsPlistMatrixRep" ],
  function( m )
    local l;
    l := List(m![ROWSPOS],AdditiveInverseImmutable);
    MakeImmutable( l );
    return MakeIsPlistMatrixRep( m![BDPOS], m![EMPOS], m![RLPOS], l, false );
  end );

InstallMethod( AdditiveInverseMutable,
  [ "IsPlistMatrixRep" ],
  function( m )
    local l;
    l := List(m![ROWSPOS],AdditiveInverseMutable);
    return MakeIsPlistMatrixRep( m![BDPOS], m![EMPOS], m![RLPOS], l, false );
  end );

InstallMethod( ZeroSameMutability,
  [ "IsPlistMatrixRep" ],
  function( m )
    local l;
    l := List(m![ROWSPOS],ZeroSameMutability);
    if not IsMutable(m) then
        MakeImmutable(l);
    fi;
    return MakeIsPlistMatrixRep( m![BDPOS], m![EMPOS], m![RLPOS], l, false );
  end );

InstallMethod( ZeroImmutable,
  [ "IsPlistMatrixRep" ],
  function( m )
    local l;
    l := List(m![ROWSPOS],ZeroImmutable);
    MakeImmutable( l );
    return MakeIsPlistMatrixRep( m![BDPOS], m![EMPOS], m![RLPOS], l, false );
  end );

InstallMethod( ZeroMutable,
  [ "IsPlistMatrixRep" ],
  function( m )
    local l;
    l := List(m![ROWSPOS],ZeroMutable);
    return MakeIsPlistMatrixRep( m![BDPOS], m![EMPOS], m![RLPOS], l, false );
  end );

InstallMethod( IsZero,
  [ "IsPlistMatrixRep" ],
  function( m )
    local i;
    for i in [1..Length(m![ROWSPOS])] do
        if not IsZero(m![ROWSPOS][i]) then
            return false;
        fi;
    od;
    return true;
  end );

InstallMethod( IsOne,
  [ "IsPlistMatrixRep" ],
  function( m )
    local i,j,n;
    if Length(m![ROWSPOS]) <> m![RLPOS] then
        #Error("IsOne: Matrix must be square");
        return false;
    fi;
    n := m![RLPOS];
    for i in [1..n] do
        if not IsOne(m![ROWSPOS][i]![ELSPOS][i]) then return false; fi;
        for j in [1..i-1] do
            if not IsZero(m![ROWSPOS][i]![ELSPOS][j]) then return false; fi;
        od;
        for j in [i+1..n] do
            if not IsZero(m![ROWSPOS][i]![ELSPOS][j]) then return false; fi;
        od;
    od;
    return true;
  end );

InstallMethod( OneSameMutability,
  [ "IsPlistMatrixRep" ],
  function( m )
    local o;
    if m![RLPOS] <> Length(m![ROWSPOS]) then
        #Error("OneSameMutability: Matrix is not square");
        #return;
        return fail;
    fi;
    o := IdentityMatrix(m![RLPOS],m);
    if not IsMutable(m) then
        MakeImmutable(o);
    fi;
    return o;
  end );

InstallMethod( OneMutable,
  [ "IsPlistMatrixRep" ],
  function( m )
    if m![RLPOS] <> Length(m![ROWSPOS]) then
        #Error("OneMutable: Matrix is not square");
        #return;
        return fail;
    fi;
    return IdentityMatrix(m![RLPOS],m);
  end );

InstallMethod( OneImmutable,
  [ "IsPlistMatrixRep" ],
  function( m )
    local o;
    if m![RLPOS] <> Length(m![ROWSPOS]) then
        #Error("OneImmutable: Matrix is not square");
        #return;
        return fail;
    fi;
    o := IdentityMatrix(m![RLPOS],m);
    MakeImmutable(o);
    return o;
  end );

# For the moment we delegate to the fast kernel arithmetic for plain
# lists of plain lists:

InstallMethod( InverseMutable,
  [ "IsPlistMatrixRep" ],
  function( m )
    local n;
    if m![RLPOS] <> Length(m![ROWSPOS]) then
        #Error("InverseMutable: Matrix is not square");
        #return;
        return fail;
    fi;
    # Make a plain list of lists:
    n := List(m![ROWSPOS],x->x![ELSPOS]);
    n := InverseMutable(n);  # Invert!
    if n = fail then return fail; fi;
    return Matrix(n,Length(n),m);
  end );

InstallMethod( InverseImmutable,
  [ "IsPlistMatrixRep" ],
  function( m )
    local n;
    if m![RLPOS] <> Length(m![ROWSPOS]) then
        #Error("InverseMutable: Matrix is not square");
        #return;
        return fail;
    fi;
    # Make a plain list of lists:
    n := List(m![ROWSPOS],x->x![ELSPOS]);
    n := InverseImmutable(n);  # Invert!
    if n = fail then return fail; fi;
    return Matrix(n,Length(n),m);
  end );

InstallMethod( InverseSameMutability,
  [ "IsPlistMatrixRep" ],
  function( m )
    local n;
    if m![RLPOS] <> Length(m![ROWSPOS]) then
        #Error("InverseMutable: Matrix is not square");
        #return;
        return fail;
    fi;
    # Make a plain list of lists:
    n := List(m![ROWSPOS],x->x![ELSPOS]);
    if not IsMutable(m) then
        MakeImmutable(n);
    fi;
    n := InverseSameMutability(n);  # Invert!
    if n = fail then return fail; fi;
    return Matrix(n,Length(n),m);
  end );

InstallMethod( RankMat,
  [ "IsPlistMatrixRep" ],
  function( m )
    local n;

    n := List(m![ROWSPOS],x->x![ELSPOS]);
    return RankMat(n);
  end);


InstallMethodWithRandomSource( Randomize,
  "for a random source and a mutable plist vector",
  [ IsRandomSource, IsPlistMatrixRep and IsMutable ],
  function( rs, m )
    local v;
    for v in m![ROWSPOS] do
        Randomize( rs, v );
    od;
    return m;
  end );

InstallMethod( TransposedMatMutable,
  [ "IsPlistMatrixRep" ],
  function( m )
    local i,n;
    n := ListWithIdenticalEntries(m![RLPOS],0);
    for i in [1..m![RLPOS]] do
        n[i]:= Vector(List(m![ROWSPOS],v->v![ELSPOS][i]),m![EMPOS]);
    od;
    return MakeIsPlistMatrixRep( m![BDPOS], m![EMPOS], Length(m![ROWSPOS]), n, false );
  end );

InstallMethod( \*,
  [ "IsPlistVectorRep", "IsPlistMatrixRep" ],
  function( v, m )
    local i,res,s;
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( v![BDPOS], m![BDPOS] ) or
         Length( v ) <> NumberRows( m ) ) then
      Error( "<v> and <m> are not compatible" );
    fi;
    res := ZeroVector(m![RLPOS],m![EMPOS]);
    for i in [1..Length(v![ELSPOS])] do
        s := v![ELSPOS][i];
        if not IsZero(s) then
            AddRowVector( res, m![ROWSPOS][i], s );
        fi;
    od;
    if not IsMutable(v) and not IsMutable(m) then
        MakeImmutable(res);
    fi;
    return res;
  end );

#InstallMethod( \^,
#  [ "IsPlistMatrixRep", "IsInt" ],
#  function( m, i )
#    local mi;
#    if m![RLPOS] <> Length(m![ROWSPOS]) then
#        #Error("\\^: Matrix must be square");
#        #return;
#        return fail;
#    fi;
#    if i = 0 then return OneSameMutability(m);
#    elif i > 0 then return POW_OBJ_INT(m,i);
#    else
#        mi := InverseSameMutability(m);
#        if mi = fail then return fail; fi;
#        return POW_OBJ_INT( mi, -i );
#    fi;
#  end );

InstallMethod( ConstructingFilter,
  [ "IsPlistVectorRep" ],
  function( v )
    return IsPlistVectorRep;
  end );

InstallMethod( ConstructingFilter,
  [ "IsPlistMatrixRep" ],
  function( m )
    return IsPlistMatrixRep;
  end );

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
  [ "IsPlistMatrixRep", "IsRing" ],
  function( m, r )
    r:= NewMatrix( IsPlistMatrixRep, r, m![RLPOS],
                   List( m![ROWSPOS], x-> x![ELSPOS] ) );
    if not IsMutable( m ) then
      MakeImmutable( r );
    fi;
    return r;
  end );

InstallMethod( CompatibleVector,
  [ "IsPlistMatrixRep" ],
  function( M )
    # We know that 'CompatibleVectorFilter( M )' is 'IsPlistVectorRep'.
    return NewZeroVector(IsPlistVectorRep,BaseDomain(M),NumberRows(M));
  end );

InstallMethod( NewCompanionMatrix,
  [ "IsPlistMatrixRep", "IsUnivariatePolynomial", "IsRing" ],
  function( filter, po, bd )
    local i,l,ll,n,one;
    one := One(bd);
    l := CoefficientsOfUnivariatePolynomial(po);
    n := Length(l)-1;
    if not IsOne(l[n+1]) then
        Error("CompanionMatrix: polynomial is not monic");
        return fail;
    fi;
    ll := NewMatrix(IsPlistMatrixRep,bd,n,[]);
    l := Vector(-l{[1..n]},CompatibleVector(ll));
    for i in [1..n-1] do
        Add(ll,ZeroMutable(l));
        ll[i][i+1] := one;
    od;
    Add(ll,l);
    return ll;
  end );
#T deprecated, see matobj2.gd -> remove this and other existing methods?
