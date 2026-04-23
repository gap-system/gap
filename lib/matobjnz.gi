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
##
##  Dense vector objects over rings 'Integers mod n',
##  backed by plain lists of integers.
##
## - Use the default 'ZeroVector( len, vec )' and `ZeroVector( len, mat )'
##   methods that delegate to 'NewZeroVector'.
## - Use the default 'Vector( list, example )' method.
## - Use the default 'ZeroSameMutability' and `ZeroImmutable'
##   methods that delegate to 'Vector'.


############################################################################
##
#F  MakeIsZmodnZVectorRep( <basedomain>, <list>, <check> )
##
##  Construct a new vector in the filter 'IsZmodnZVectorRep' with base domain
##  <basedomain> and entries in the list <list> (without copying).
##
##  If <check> is set to 'true' *and* 'ValueOption( "check" )' is 'true',
##  then it is checked that the entries of <list> are either all in
##  <basedomain> or integers in the range '[ 0 .. n-1 ]'.
##  So whenever you know that the input is guaranteed to satisfy this,
##  pass 'false' for <check> to omit these (potentially costly) consistency
##  checks.
##
BindGlobal( "MakeIsZmodnZVectorRep",
  function( basedomain, list, check )
    local fam, filter, typ;

    fam:= FamilyObj(basedomain);
    if not IsBound(fam!.ZmodnZVectorRepTypes) then
      # initialize type cache
      # TODO: make this thread safe for HPC-GAP
      filter:= IsZmodnZVectorRep and CanEasilyCompareElements;
      fam!.ZmodnZVectorRepTypes := [
          NewType( fam, filter ),
          NewType( fam, filter and IsMutable ),
      ];
    fi;
    if IsMutable(list) then
      typ:= fam!.ZmodnZVectorRepTypes[2];
    else
      typ:= fam!.ZmodnZVectorRepTypes[1];
    fi;

    if FamilyObj( basedomain ) = FamilyObj( list ) then
      if check and ValueOption( "check" ) <> false then
        if not ( IsZmodnZObjNonprimeCollection( basedomain ) or
           ( IsFinite( basedomain ) and IsPrimeField( basedomain ) ) ) then
          Error( "<basedomain> must be Integers mod <n> for some <n>" );
        elif not IsPlistRep( list ) then
          # Some kernel functions really need 'IsPlistRep'.
          Error( "<list> must be a plain list" );
        elif not IsSubset( basedomain, list ) then
          Error( "<list> must be a list of reduced integers ",
                 "or of elements in <basedomain>" );
        fi;
      fi;
      # Here we have to copy.
      list:= List( list, Int );
    elif check and ValueOption( "check" ) <> false then
      # Here we have to check that the entries are reduced integers.
      if not IsPlistRep( list ) then
        # Some kernel functions really need 'IsPlistRep'.
        Error( "<list> must be a plain list" );
      elif not ( ( IsCyclotomicCollection( list ) or IsEmpty( list ) ) and
                 IsSubset( [ 0 .. Size( basedomain ) - 1 ], list ) ) then
        Error( "<list> must be a list of reduced integers ",
               "or of elements in <basedomain>" );
      fi;
    fi;

    return Objectify(typ, [ basedomain, list ]);
  end );


# Reduce 'v' of length 'l' over 'Integers mod m'.
# If 'v' is mutable then work in place.
BindGlobal( "ZNZVECREDUCE", function( v, l, m )
  local res, i;
  if IsMutable( v ) then
    res:= v;
  else
    res:= ShallowCopy( v );
  fi;
  for i in [ 1 .. l ] do
    if res[i] < 0 or res[i] >= m then
      res[i]:= res[i] mod m;
    fi;
  od;
  if not IsMutable( v ) then
    MakeImmutable( res );
  fi;
  return res;
  end );


InstallTagBasedMethod( NewVector,
  IsZmodnZVectorRep,
  function( filter, basedomain, list )
    return MakeIsZmodnZVectorRep(basedomain, PlainListCopy( list ), true);
  end );


InstallTagBasedMethod( NewZeroVector,
  IsZmodnZVectorRep,
  function( filter, basedomain, len )
    local list;
    list := ListWithIdenticalEntries(len, 0);
    return MakeIsZmodnZVectorRep(basedomain, list, false);
  end );


InstallMethod( ConstructingFilter,
  [ "IsZmodnZVectorRep" ],
  v -> IsZmodnZVectorRep );


InstallMethod( BaseDomain,
  [ "IsZmodnZVectorRep" ],
  v -> v![ZBDPOS] );

InstallMethod( Length,
  [ "IsZmodnZVectorRep" ],
  v -> Length(v![ZELSPOS]) );

InstallMethod( \[\],
  [ "IsZmodnZVectorRep", "IsPosInt" ],
  { v, p } -> ZmodnZObj(ElementsFamily(FamilyObj(v)),v![ZELSPOS][p]) );

InstallMethod( \[\]\:\=,
  [ "IsZmodnZVectorRep", "IsPosInt", "IsObject" ],
  function( v, p, ob )

    if ValueOption( "check" ) <> false then
      if not ( IsInt( ob ) or ob in BaseDomain( v ) ) then
        Error( "<ob> must be an integer or lie in the base domain of <v>" );
      elif Length( v![ZELSPOS] ) < p then
        Error( "<p> is out of bounds" );
      fi;
    fi;
    if IsInt( ob ) then
      v![ZELSPOS][p]:= ob mod Size( v![ZBDPOS] );
    else
      v![ZELSPOS][p]:= Int( ob );
    fi;
  end );

InstallMethod( \{\},
  [ "IsZmodnZVectorRep", "IsList" ],
  { v, list } -> MakeIsZmodnZVectorRep( v![ZBDPOS], v![ZELSPOS]{ list }, false ) );


InstallMethod( Unpack,
  [ "IsZmodnZVectorRep" ],
  function( v )
    local fam;
    fam:= ElementsFamily( FamilyObj( v ) );
    return List( v![ZELSPOS], x -> ZmodnZObj( fam, x ) );
  end );

InstallMethod( ShallowCopy, [ "IsZmodnZVectorRep" ],
  v -> MakeIsZmodnZVectorRep( v![ZBDPOS], ShallowCopy( v![ZELSPOS] ), false ) );

InstallMethod( \+,
  [ "IsZmodnZVectorRep", "IsZmodnZVectorRep" ],
  function( a, b )
    local R, mu, n, i;
    R:= a![ZBDPOS];
    if ValueOption( "check" ) <> false and
       not IsIdenticalObj( R, b![ZBDPOS] ) then
      Error( "<a> and <b> are not compatible" );
    fi;
    b:= SUM_LIST_LIST_DEFAULT(a![ZELSPOS],b![ZELSPOS]);
    if not IsMutable( b ) then
      mu:= true;
      b:= ShallowCopy( b );
    else
      mu:= false;
    fi;
    n:= Size( R );
    for i in [ 1 .. Length( b ) ] do
      if b[i] >= n then
        b[i]:= b[i] mod n;
      fi;
    od;
    if mu then
      MakeImmutable( b );
    fi;
    return MakeIsZmodnZVectorRep( R, b, false );
  end );

InstallOtherMethod( \+,
  IsIdenticalObj,
  [ "IsZmodnZVectorRep", "IsList" ],
  { a, b } -> a + Vector( BaseDomain( a ), b ) );
#TODO: Do we want this? If yes then it should be documented.

InstallOtherMethod( \+,
  IsIdenticalObj,
  [ "IsList", "IsZmodnZVectorRep" ],
  { a, b } -> Vector( BaseDomain( b ), a ) + b );
#TODO: Do we want this? If yes then it should be documented.

InstallMethod( \-,
  [ "IsZmodnZVectorRep", "IsZmodnZVectorRep" ],
  function( a, b )
    local R, mu, n, i;
    R:= a![ZBDPOS];
    if ValueOption( "check" ) <> false and
       not IsIdenticalObj( a![ZBDPOS], b![ZBDPOS] ) then
      Error( "<a> and <b> are not compatible" );
    fi;
    b:= DIFF_LIST_LIST_DEFAULT( a![ZELSPOS], b![ZELSPOS]);
    if not IsMutable( b ) then
      mu:= true;
      b:= ShallowCopy( b );
    else
      mu:= false;
    fi;
    n:= Size( R );
    for i in [ 1 .. Length( b ) ] do
      if b[i] < 0 then
        b[i]:= b[i] mod n;
      fi;
    od;
    if mu then
      MakeImmutable( b );
    fi;
    return MakeIsZmodnZVectorRep( R, b, false );
  end );

InstallOtherMethod( \-,
  IsIdenticalObj,
  [ "IsZmodnZVectorRep", "IsList" ],
  { a, b } -> a-Vector(BaseDomain(a),b) );
#TODO: Do we want this? If yes then it should be documented.

InstallOtherMethod( \-,
  IsIdenticalObj,
  [ "IsList", "IsZmodnZVectorRep" ],
  { a, b } -> Vector(BaseDomain(b),a)-b );
#TODO: Do we want this? If yes then it should be documented.

BindGlobal( "ZMODNZVECADDINVCLEANUP", function( m, l )
  local i;
  if IsMutable( l ) then
    for i in [ 1 .. Length( l ) ] do
      if l[i] < 0 then
        l[i]:= l[i] mod m;
      fi;
    od;
  else
    l:= ShallowCopy( l );
    for i in [ 1 .. Length( l ) ] do
      if l[i] < 0 then
        l[i]:= l[i] mod m;
      fi;
    od;
    MakeImmutable( l );
  fi;
  return l;
  end );

# Avoid 'Unpack'.
InstallMethod( AdditiveInverseMutable,
  [ "IsZmodnZVectorRep" ],
  function( v )
    local res;
    res:= MakeIsZmodnZVectorRep( v![ZBDPOS],
            ZMODNZVECADDINVCLEANUP(Size(v![ZBDPOS]),
              AdditiveInverseMutable(v![ZELSPOS])), true );
    return res;
  end );

InstallMethod( ZeroMutable, [ "IsZmodnZVectorRep" ],
  v -> MakeIsZmodnZVectorRep( v![ZBDPOS], ZeroMutable(v![ZELSPOS]), false ) );

BindGlobal( "ZMODNZVECSCAMULT",
  function( w, s )
    local i,m,b,v;
    b:= w![ZBDPOS];
    m:= Size( b );
    if not IsInt( s ) then
      if IsRat( s ) then
        s:= s mod m;
      elif s in b then
        s:= Int( s );
      else
        Error( "multiplication with <s> is not supported" );
      fi;
    fi;
    v:= PROD_LIST_SCL_DEFAULT( w![ZELSPOS], s );
    if not IsMutable( v ) then
      v:= ShallowCopy( v );
    fi;
    if s >= 0 then
      for i in [ 1 .. Length( v ) ] do
        if v[i] >= m then
          v[i]:= v[i] mod m;
        fi;
      od;
    else
      for i in [ 1 .. Length( v ) ] do
        if v[i] < 0 then
          v[i]:= v[i] mod m;
        fi;
      od;
    fi;
    if not IsMutable( w![ZELSPOS] ) then
      MakeImmutable( v );
    fi;
    return MakeIsZmodnZVectorRep( w![ZBDPOS], v, true );
  end );

# Requiring 'IsScalar' for scalar multiplication/division is dangerous
# without prescribed family relation if matrix objects are scalars.
# Here the situation is easier than in general
# because we want to restrict the scalars to 'IsRat' or
# elements of the base domain of the vector.
# (We need the 'IsScalar' to get a rank that is higher than the one
# for the generic method that is based on 'Unpack'.)
InstallOtherMethod( \*,
  [ "IsZmodnZVectorRep", "IsRat" ],
  ZMODNZVECSCAMULT );

InstallOtherMethod( \*,
  IsCollsElms,
  [ "IsZmodnZVectorRep", "IsScalar" ],
  ZMODNZVECSCAMULT );

InstallOtherMethod( \*,
  [ "IsRat", "IsZmodnZVectorRep" ],
  { s, v } -> ZMODNZVECSCAMULT( v, s ) );

InstallOtherMethod( \*,
  IsElmsColls,
  [ "IsScalar", "IsZmodnZVectorRep" ],
  { s, v } -> ZMODNZVECSCAMULT( v, s ) );

InstallOtherMethod( \/,
  [ "IsZmodnZVectorRep", "IsRat" ],
  { v, s } -> ZMODNZVECSCAMULT( v, s^-1 ) );

InstallOtherMethod( \/,
  IsCollsElms,
  [ "IsZmodnZVectorRep", "IsScalar" ],
  { v, s } -> ZMODNZVECSCAMULT( v, s^-1 ) );


InstallMethod( PostMakeImmutable,
  [ "IsZmodnZVectorRep" ],
  v -> MakeImmutable( v![ZELSPOS] ) );


InstallMethod( ViewObj,
  [ "IsZmodnZVectorRep" ],
  function( v )
    local l;
    Print( "<" );
    if not IsMutable( v ) then
      Print( "immutable " );
    fi;
    Print( "vector mod ", Size( v![ZBDPOS] ) );
    l:= Length( v![ZELSPOS] );
    if 0 < l and l <= 8 then
      Print( ": ", v![ZELSPOS], ">" );
    else
      Print( " of length ", Length( v![ZELSPOS] ), ">" );
    fi;
  end );

InstallMethod( PrintObj,
  [ "IsZmodnZVectorRep" ],
  function( v )
    Print( "NewVector(IsZmodnZVectorRep" );
    if IsField( v![ZBDPOS] ) then
      Print( ",GF(", Size( v![ZBDPOS] ), "),", v![ZELSPOS], ")" );
    else
      Print( ",", String( v![ZBDPOS] ), ",", v![ZELSPOS], ")" );
    fi;
  end );

InstallMethod( Display,
  [ "IsZmodnZVectorRep" ],
  function( v )
    Print( "<a " );
    if not IsMutable( v ) then
      Print( "immutable " );
    fi;
    Print( "zmodnz vector over ", BaseDomain(v), ":\n" );
    Print( v![ZELSPOS], "\n>\n" );
  end );

InstallMethod( String,
  [ "IsZmodnZVectorRep" ],
  function( v )
    local st;
    st := "NewVector(IsZmodnZVectorRep,";
    if IsField( v![ZBDPOS] ) then
      Append( st, "GF(" );
      Append( st, String( Size( v![ZBDPOS] ) ) );
      Append( st, ")," );
    else
      Append( st, String( v![ZBDPOS] ) );
      Append( st, "," );
    fi;
    Append( st, String( v![ZELSPOS] ) );
    Add( st, ')' );
    return st;
  end );


# Avoid element access.
InstallMethod( PositionNonZero,
  [ "IsZmodnZVectorRep" ],
  v -> PositionNonZero( v![ZELSPOS] ) );

InstallOtherMethod( PositionNonZero,
  [ "IsZmodnZVectorRep", "IsInt" ],
  { v, s } -> PositionNonZero( v![ZELSPOS], s ) );

InstallMethod( PositionLastNonZero,
  [ "IsZmodnZVectorRep" ],
  function( v )
    local els,i;
    els:= v![ZELSPOS];
    i:= Length( els );
    while i > 0 and els[i] = 0 do
      i:= i - 1;
    od;
    return i;
  end );

InstallMethod( ListOp,
  [ "IsZmodnZVectorRep" ],
  function( v )
    local fam;
    fam:= ElementsFamily( FamilyObj( v ) );
    return List( v![ZELSPOS], x -> ZmodnZObj( fam, x ) );
  end );

InstallMethod( ListOp,
  [ "IsZmodnZVectorRep", "IsFunction" ],
  function( v, f )
    local fam;
    fam:= ElementsFamily( FamilyObj( v ) );
    return List( v![ZELSPOS], x -> f( ZmodnZObj( fam, x ) ) );
  end );


# Avoid accessing vector entries.
InstallMethod( \=,
  IsIdenticalObj,
  [ "IsZmodnZVectorRep", "IsZmodnZVectorRep" ],
  { a, b } -> EQ_LIST_LIST_DEFAULT( a![ZELSPOS], b![ZELSPOS] ) );

InstallMethod( \=,
  IsIdenticalObj,
  [ "IsZmodnZVectorRep", "IsPlistRep" ],
  { a, b } -> a![ZELSPOS]=List(b,x->x![1]) );
#TODO: Do we want this? If yes then it should be documented.
#TODO: Fix that this assumes 'b' is a list of 'IsZmodnZObj's.

InstallMethod( \=,
  IsIdenticalObj,
  [ "IsPlistRep", "IsZmodnZVectorRep" ],
  { b, a } -> a![ZELSPOS]=List(b,x->x![1]) );
#TODO: Do we want this? If yes then it should be documented.
#TODO: Fix that this assumes 'b' is a list of 'IsZmodnZObj's.

# Avoid accessing vector entries.
InstallMethod( \<,
  IsIdenticalObj,
  [ "IsZmodnZVectorRep", "IsZmodnZVectorRep" ],
  { a, b } -> LT_LIST_LIST_DEFAULT( a![ZELSPOS], b![ZELSPOS] ) );

InstallMethod( AddRowVector,
  [ "IsZmodnZVectorRep and IsMutable", "IsZmodnZVectorRep" ],
  function( a, b )
    local R, m, i;
    R:= a![ZBDPOS];
    if ValueOption( "check" ) <> false and
       not IsIdenticalObj( R, b![ZBDPOS] ) then
      Error( "<a> and <b> are not compatible" );
    fi;
    a:= a![ZELSPOS];
    ADD_ROW_VECTOR_2_FAST( a, b![ZELSPOS] );
    m:= Size( R );
    for i in [ 1 .. Length( a ) ] do
      if a[i] >= m then
        a[i]:= a[i] mod m;
      fi;
    od;
  end );

InstallMethod( AddRowVector,
  [ "IsZmodnZVectorRep and IsMutable", "IsZmodnZVectorRep", "IsObject" ],
  function( a, b, s )
    local bd, i, m;
    bd:= a![ZBDPOS];
    if ValueOption( "check" ) <> false then
      if not IsIdenticalObj( bd, b![ZBDPOS] ) then
        Error( "<a> and <b> are not compatible" );
      fi;
    fi;
    if not IsInt( s ) then
      if IsRat( s ) then
        s:= s mod m;
      elif s in bd then
        s:= Int( s );
      else
        Error( "multiplication with <s> is not supported" );
      fi;
    fi;
    a:= a![ZELSPOS];
    if IsSmallIntRep( s ) then
      ADD_ROW_VECTOR_3_FAST( a, b![ZELSPOS], s );
    else
      ADD_ROW_VECTOR_3( a, b![ZELSPOS], s );
    fi;
    m:= Size( b![ZBDPOS] );
    if s >= 0 then
      for i in [ 1 .. Length( a ) ] do
        if a[i] >= m then
          a[i]:= a[i] mod m;
        fi;
      od;
    else
      for i in [ 1 .. Length( a ) ] do
        if a[i] < 0 then
          a[i]:= a[i] mod m;
        fi;
      od;
    fi;
  end );

InstallOtherMethod( AddRowVector,
  [ "IsZmodnZVectorRep and IsMutable", "IsPlistRep", "IsObject" ],
  function( a, b, s )
    local bd, i, m;
    if not ForAll( b, IsModulusRep ) then
      TryNextMethod();
    fi;
    bd:= a![ZBDPOS];
    if not IsInt( s ) then
      if IsRat( s ) then
        s:= s mod m;
      elif s in bd then
        s:= Int( s );
      else
        Error( "multiplication with <s> is not supported" );
      fi;
    fi;
    m:= Size( a![ZBDPOS] );
    a:= a![ZELSPOS];
    b:= List( b, x -> x![1] );

    if IsSmallIntRep( s ) then
      ADD_ROW_VECTOR_3_FAST( a, b, s );
    else
      ADD_ROW_VECTOR_3( a, b, s );
    fi;
    if s >= 0 then
      for i in [ 1 .. Length( a ) ] do
        if a[i] >= m then
          a[i]:= a[i] mod m;
        fi;
      od;
    else
      for i in [ 1 .. Length( a ) ] do
        if a[i] < 0 then
          a[i]:= a[i] mod m;
        fi;
      od;
    fi;
  end );
#TODO: Do we want this? If yes then it should be documented.

InstallOtherMethod( AddRowVector,
  [ "IsPlistRep and IsMutable", "IsZmodnZVectorRep", "IsObject" ],
  function( a, b, s )
    local i;
    if not ForAll( a, IsModulusRep ) then
      TryNextMethod();
    fi;
    for i in [ 1 .. Length( a ) ] do
      a[i]:= a[i] + b[i] * s;
    od;
  end );
#TODO: Do we want this? If yes then it should be documented.

InstallMethod( AddRowVector,
  [ "IsZmodnZVectorRep and IsMutable", "IsZmodnZVectorRep",
    "IsObject", "IsPosInt", "IsPosInt" ],
  function( a, b, s, from, to )
    local bd, i, m;
    bd:= a![ZBDPOS];
    if ValueOption( "check" ) <> false and
       not IsIdenticalObj( bd, b![ZBDPOS] ) then
      Error( "<a> and <b> are not compatible" );
    fi;
    if not IsInt( s ) then
      if IsRat( s ) then
        s:= s mod m;
      elif s in bd then
        s:= Int( s );
      else
        Error( "multiplication with <s> is not supported" );
      fi;
    fi;
    a:= a![ZELSPOS];
    if IsSmallIntRep( s ) then
      ADD_ROW_VECTOR_5_FAST( a, b![ZELSPOS], s, from, to );
    else
      ADD_ROW_VECTOR_5( a, b![ZELSPOS], s, from, to );
    fi;
    m:= Size( b![ZBDPOS] );
    if s>=0 then
      for i in [ 1 .. Length( a ) ] do
        if a[i] >= m then
          a[i]:= a[i] mod m;
        fi;
      od;
    else
      for i in [ 1 .. Length( a ) ] do
        if a[i] < 0 then
          a[i]:= a[i] mod m;
        fi;
      od;
    fi;
  end );

InstallMethod( MultVectorLeft,
  [ "IsZmodnZVectorRep and IsMutable", "IsObject" ],
  function( v, s )
    local b, m, i;
    b:= v![ZBDPOS];
    m:= Size( b );
    if not IsInt( s ) then
      if IsRat( s ) then
        s:= s mod m;
      elif s in b then
        s:= Int( s );
      else
        Error( "multiplication with <s> is not supported" );
      fi;
    fi;
    v:= v![ZELSPOS];
    MULT_VECTOR_2_FAST( v, s );
    if s >= 0 then
      for i in [ 1 .. Length( v ) ] do
        if v[i] >= m then
          v[i]:= v[i] mod m;
        fi;
      od;
    else
      for i in [ 1 .. Length( v ) ] do
        if v[i] < 0 then
          v[i]:= v[i] mod m;
        fi;
      od;
    fi;
  end );

InstallMethod( MultVectorRight,
  [ "IsZmodnZVectorRep and IsMutable", "IsObject" ],
  MultVectorLeft );

InstallMethod( MultVectorLeft,
  [ "IsZmodnZVectorRep and IsMutable", "IsObject", "IsInt", "IsInt" ],
  function( v, s, from, to )
    local b, m, i;
    b:= v![ZBDPOS];
    m:= Size( b );
    if not IsInt( s ) then
      if IsRat( s ) then
        s:= s mod m;
      elif s in b then
        s:= Int( s );
      else
        Error( "multiplication with <s> is not supported" );
      fi;
    fi;
    v:= v![ZELSPOS];
    for i in [ from .. to ] do
      v[i]:= s * v[i];
    od;
    if s >= 0 then
      for i in [ from .. to ] do
        if v[i] >= m then
          v[i]:= v[i] mod m;
        fi;
      od;
    else
      for i in [ from .. to ] do
        if v[i] < 0 then
          v[i]:= v[i] mod m;
        fi;
      od;
    fi;
  end );

InstallMethod( MultVectorRight,
  [ "IsZmodnZVectorRep and IsMutable", "IsObject", "IsInt", "IsInt" ],
  MultVectorLeft );

InstallMethod( IsZero, [ "IsZmodnZVectorRep" ],
  v -> IsZero( v![ZELSPOS] ) );

InstallMethod( CopySubVector,
  [ "IsZmodnZVectorRep", "IsZmodnZVectorRep and IsMutable", "IsList", "IsList" ],
  function( a, b, pa, pb )
    if ValueOption( "check" ) <> false and
       not IsIdenticalObj( a![ZBDPOS], b![ZBDPOS] ) then
      Error( "<a> and <b> have different base domains" );
    fi;
    # The following should eventually go into the kernel:
    b![ZELSPOS]{pb}:= a![ZELSPOS]{pa};
  end );

# This is used in the 'MinimalPolynomial' method below.
InstallOtherMethod( ProductCoeffs,
  [ "IsZmodnZVectorRep", "IsZmodnZVectorRep" ],
  { l1, l2 } -> PRODUCT_COEFFS_GENERIC_LISTS( l1, Length( l1 ), l2, Length( l2 ) ) );


############################################################################
##
##  Dense matrix objects over rings 'Integers mod n',
##  backed by plain lists of plain lists of integers.
##
## - Use the default 'Matrix' methods that delegate to 'NewMatrix'.
## - Use the default 'ZeroMatrix( rows, cols, mat )' method
##   that delegates to 'NewZeroMatrix'.
## - Use the default 'IdentityMatrix' methods that delegate to
##   'NewIdentityMatrix'.
## - Use the default 'OneMutable', 'OneImmutable', 'OneSameMutability'
##   methods, which call 'IdentityMatrix'.
## - Use the default 'InverseImmutable', 'InverseSameMutability' methods.


############################################################################
##
#F  MakeIsZmodnZMatrixRep( <basedomain>, <ncols>, <list>, <check> )
##
##  Construct a new matrix in the filter 'IsZmodnZMatrixRep' with base domain
##  <basedomain> and in the list of lists <list>.
##  Each entry of <list> must have length <ncols>.
##
##  If <check> is set to 'true' *and* 'ValueOption( "check" )' is 'true',
##  then it is checked that the entries of <list> are plain lists of length
##  <ncols> and with entries either all in <basedomain> or integers
##  in the range '[ 0 .. n-1 ]'.
##  So whenever you know that the input satisfies these conditions,
##  pass 'false' for <check> to omit these (potentially costly) consistency
##  checks.
##
BindGlobal( "MakeIsZmodnZMatrixRep",
  function( basedomain, ncols, list, check )
    local fam, filter, typ, row, copied, i;

    # The types are always cached in 'fam'.
    fam:= CollectionsFamily( FamilyObj( basedomain ) );
    if not IsBound( fam!.ZmodnZMatrixRepTypes ) then
      # initialize type cache
      # TODO: make this thread safe for HPC-GAP
      filter:= IsZmodnZMatrixRep and CanEasilyCompareElements;
      fam!.ZmodnZMatrixRepTypes:= [
          NewType( fam, filter ),
          NewType( fam, filter and IsMutable ),
      ];
    fi;
    if IsMutable( list ) then
      typ:= fam!.ZmodnZMatrixRepTypes[2];
    else
      typ:= fam!.ZmodnZMatrixRepTypes[1];
    fi;

    check:= check and ValueOption( "check" ) <> false;

    if check then
      Assert( 0, IsPlistRep( list ) );
      for row in list do
        if not IsPlistRep( row ) then
          # Some kernel functions really need 'IsPlistRep'.
          Error( "the entries of <list> must be plain lists" );
        elif Length( row ) <> ncols then
          Error( "the entries of <list> must have length <ncols>" );
        fi;
      od;
    fi;

    copied:= false;
    for i in [ 1 .. Length( list ) ] do
      if FamilyObj( basedomain ) = FamilyObj( list[i] ) then
        if check then
          if not ( IsZmodnZObjNonprimeCollection( basedomain ) or
             ( IsFinite( basedomain ) and IsPrimeField( basedomain ) ) ) then
            Error( "<basedomain> must be Integers mod <n> for some <n>" );
          elif not IsSubset( basedomain, list[i] ) then
            Error( "<list>[", i, "] must be a list of reduced integers ",
                   "or of elements in <basedomain>" );
          fi;
        fi;
        # Here we have to copy.
        if not copied then
          copied:= true;
          list:= ShallowCopy( list );
        fi;
        list[i]:= List( list[i], Int );
      elif check then
        # Here we have to check that the entries are reduced integers.
        if not ( ( IsCyclotomicCollection( list[i] ) or IsEmpty( list[i] ) )
                 and
                 IsSubset( [ 0 .. Size( basedomain ) - 1 ], list[i] ) ) then
          Error( "<list>[", i, "] must be a list of reduced integers ",
                 "or of elements in <basedomain>" );
        fi;
      fi;
    od;

    return Objectify( typ, [ basedomain, ncols, list ] );
  end );


InstallTagBasedMethod( NewMatrix,
  IsZmodnZMatrixRep,
  function( filter, basedomain, ncols, list )
    local len, nd, rows, i, row;

    # If applicable then replace a flat list 'list' by a nested list
    # of lists of length 'ncols'.
    len:= Length( list );
    if len > 0 and not IsVectorObj( list[1] ) then
      nd:= NestingDepthA( list );
      if nd < 2 or nd mod 2 = 1 then
        if len mod ncols <> 0 then
          Error( "NewMatrix: Length of <list> is not a multiple of <ncols>" );
        fi;
        list:= List( [ 0, ncols .. len - ncols ],
                     i -> list{ [ i + 1 .. i + ncols ] } );
      fi;
      len:= Length( list );
    fi;

    rows:= EmptyPlist( len );
    for i in [ 1 .. len ] do
      row:= list[i];
      if IsVectorObj( row ) then
        rows[i]:= Unpack( row );
      else
        rows[i]:= PlainListCopy( row );
      fi;
    od;
    return MakeIsZmodnZMatrixRep( basedomain, ncols, rows, true );
  end );


InstallTagBasedMethod( NewZeroMatrix,
  IsZmodnZMatrixRep,
  function( filter, basedomain, rows, ncols )
    local list, z, i;
    list := EmptyPlist( rows );
    z := Zero( basedomain );
    for i in [ 1 .. rows ] do
      list[i] := ListWithIdenticalEntries( ncols, z );
    od;
    return MakeIsZmodnZMatrixRep( basedomain, ncols, list, false );
  end );


# Avoid dealing with 'One( basedomain )'.
InstallTagBasedMethod( NewIdentityMatrix,
  IsZmodnZMatrixRep,
  function( filter, basedomain, dim )
    local mat, i;
    mat:= NewZeroMatrix( filter, basedomain, dim, dim );
    for i in [ 1 .. dim ] do
      mat[i,i]:= 1;
    od;
    return mat;
  end );


InstallOtherMethod( ConstructingFilter,
  [ "IsZmodnZMatrixRep" ],
  M -> IsZmodnZMatrixRep );

InstallMethod( CompatibleVectorFilter,
  [ "IsZmodnZMatrixRep" ],
  M -> IsZmodnZVectorRep );

InstallMethod( CompatibleVector,
  [ "IsZmodnZMatrixRep" ],
  M -> NewZeroVector( IsZmodnZVectorRep, BaseDomain( M ), NumberRows( M ) ) );


InstallOtherMethod( BaseDomain,
  [ "IsZmodnZMatrixRep" ],
  M -> M![ZBDPOS] );

InstallMethod( NumberRows,
  [ "IsZmodnZMatrixRep" ],
  M -> Length(M![ZROWSPOS]) );

InstallMethod( NumberColumns,
  [ "IsZmodnZMatrixRep" ],
  M -> M![ZCOLSPOS] );

InstallMethod( \[\],
  [ "IsZmodnZMatrixRep", "IsPosInt" ],
  function( M, pos )
    ErrorNoReturn( "row access unsupported; use M[i,j] or RowsOfMatrix(M)" );
  end );

InstallMethod( MatElm,
  [ "IsZmodnZMatrixRep", "IsPosInt", "IsPosInt" ],
  { M, row, col } -> ZmodnZObj( ElementsFamily( FamilyObj( M![ZBDPOS] ) ),
                                M![ZROWSPOS][row, col] ) );

InstallMethod( SetMatElm,
  [ "IsZmodnZMatrixRep and IsMutable", "IsPosInt", "IsPosInt", "IsObject" ],
  function( M, row, col, ob )
    local R;
    if ValueOption( "check" ) <> false then
      R:= BaseDomain( M );
      if row > NrRows( M ) then
        Error( "<row> is out of bounds" );
      elif col > NrCols( M ) then
        Error( "<col> is out of bounds" );
      elif IsInt( ob ) then
        ob:= ob mod Size( R );
      elif ob in R then
        ob:= Int( ob );
      else
        Error( "<ob> must be an integer or lie in the base domain of <M>" );
      fi;
      M![ZROWSPOS][row, col]:= ob;
    else
      M![ZROWSPOS][row, col]:= Int( ob );
    fi;
  end );

# Avoid 'Unpack'.
InstallMethod( RowsOfMatrix,
  [ "IsZmodnZMatrixRep" ],
  function( M )
    local R;

    R:= BaseDomain( M );
    return List( M![ZROWSPOS], row -> MakeIsZmodnZVectorRep( R, row, false ) );
  end );


InstallMethod( Unpack,
  [ "IsZmodnZMatrixRep" ],
  function( M )
    local fam;
    fam:= ElementsFamily( FamilyObj( BaseDomain( M ) ) );
    return List( M![ZROWSPOS],
                 v -> List( v, x -> ZmodnZObj( fam, x ) ) );
    end );

InstallMethod( ShallowCopy,
  [ "IsZmodnZMatrixRep" ],
  M -> MakeIsZmodnZMatrixRep( M![ZBDPOS], M![ZCOLSPOS],
           List( M![ZROWSPOS], ShallowCopy ), false ) );

InstallMethod( MutableCopyMatrix,
  [ "IsZmodnZMatrixRep" ],
  M -> MakeIsZmodnZMatrixRep( M![ZBDPOS], M![ZCOLSPOS],
           List( M![ZROWSPOS], ShallowCopy ), false ) );

InstallMethod( ExtractSubMatrix,
  [ "IsZmodnZMatrixRep", "IsList", "IsList" ],
  { M, rowspos, colspos } -> MakeIsZmodnZMatrixRep( M![ZBDPOS],
                                 Length( colspos ),
                                 M![ZROWSPOS]{ rowspos }{ colspos }, false ) );

InstallMethod( CopySubMatrix,
  [ "IsZmodnZMatrixRep", "IsZmodnZMatrixRep and IsMutable",
    "IsList", "IsList", "IsList", "IsList" ],
  function( M, N, srcrows, dstrows, srccols, dstcols )
    if ValueOption( "check" ) <> false and
       not IsIdenticalObj( M![ZBDPOS], N![ZBDPOS] ) then
      Error( "<M> and <N> are not compatible" );
    fi;
    N![ZROWSPOS]{ dstrows }{ dstcols }:= M![ZROWSPOS]{ srcrows }{ srccols };
  end );

InstallMethod( TransposedMatMutable,
  [ "IsZmodnZMatrixRep" ],
  M -> MakeIsZmodnZMatrixRep( M![ZBDPOS], NrRows( M ),
           TransposedMatMutable( M![ZROWSPOS] ), false ) );

InstallMethod( \+,
  [ "IsZmodnZMatrixRep", "IsZmodnZMatrixRep" ],
  function( a, b )
    local ncols, bd, modulus, res;

    ncols:= a![ZCOLSPOS];
    bd:= a![ZBDPOS];
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( bd, b![ZBDPOS] ) or
         NrRows( a ) <> NrRows( b ) or
         ncols <> b![ZCOLSPOS] ) then
      Error( "<a> and <b> are not compatible" );
    fi;
    modulus:= Size( bd );
    res:= SUM_LIST_LIST_DEFAULT( a![ZROWSPOS], b![ZROWSPOS] );
    if IsMutable( res ) then
      res:= List( res, row -> ZNZVECREDUCE( row, ncols, modulus ) );
    else
      res:= MakeImmutable( List( res,
                                 row -> ZNZVECREDUCE( row, ncols, modulus ) ) );
    fi;
    return MakeIsZmodnZMatrixRep( bd, ncols, res, false );
  end );

InstallMethod( \-,
  [ "IsZmodnZMatrixRep", "IsZmodnZMatrixRep" ],
  function( a, b )
    local ncols, bd, modulus, res;

    ncols:= a![ZCOLSPOS];
    bd:= a![ZBDPOS];
    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( bd, b![ZBDPOS] ) or
         NrRows( a ) <> NrRows( b ) or
         ncols <> b![ZCOLSPOS] ) then
      Error( "<a> and <b> are not compatible" );
    fi;
    modulus:= Size( bd );
    res:= DIFF_LIST_LIST_DEFAULT( a![ZROWSPOS], b![ZROWSPOS] );
    if IsMutable( res ) then
      res:= List( res, row -> ZNZVECREDUCE( row, ncols, modulus ) );
    else
      res:= MakeImmutable( List( res,
                                 row -> ZNZVECREDUCE( row, ncols, modulus ) ) );
    fi;
    return MakeIsZmodnZMatrixRep( bd, ncols, res, false );
  end );

InstallMethod( AdditiveInverseMutable,
  [ "IsZmodnZMatrixRep" ],
  function( M )
    local ncols, bd, modulus, res;

    ncols:= M![ZCOLSPOS];
    bd:= M![ZBDPOS];
    modulus:= Size( bd );
    res:= AdditiveInverseMutable( M![ZROWSPOS] );
    res:= List( res, row -> ZMODNZVECADDINVCLEANUP( modulus, row ) );
    return MakeIsZmodnZMatrixRep( bd, ncols, res, false );
  end );

InstallMethod( ZeroMutable,
  [ "IsZmodnZMatrixRep" ],
  function( M )
    local z;
    z := MakeIsZmodnZMatrixRep( M![ZBDPOS], M![ZCOLSPOS],
             ZeroMutable( M![ZROWSPOS] ), false );
    SetIsZero( z, true );
    return z;
  end );

# Avoid 'Unpack'.
InstallMethod( InverseMutable,
  [ "IsZmodnZMatrixRep" ],
  function( M )
    local nrows, rows, modulus;

    nrows:= NrRows( M );
    if nrows <> NrCols( M ) then
      return fail;
    elif nrows = 0 then
      rows:= [];
    else
      rows:= INV_MATRIX_MUTABLE( M![ZROWSPOS] );
    fi;
    if rows = fail then
      return fail;
    fi;
    modulus:= Size( M![ZBDPOS] );
    # Here the entries can be non-integral rationals,
    # so 'ZNZVECREDUCE' is not enough.
    rows:= List( rows, v -> MOD_LIST_SCL_DEFAULT( v, modulus ) );

    return MakeIsZmodnZMatrixRep( M![ZBDPOS], M![ZCOLSPOS], rows, false );
  end );

InstallMethod( \*,
  [ "IsZmodnZMatrixRep", "IsZmodnZMatrixRep" ],
  function( a, b )
    local rowsA, colsA, rowsB, colsB, bd, list, res, m;

    rowsA := NumberRows( a );
    colsA := NumberColumns( a );
    rowsB := NumberRows( b );
    colsB := NumberColumns( b );
    bd := BaseDomain( a );

    if ValueOption( "check" ) <> false then
      if colsA <> rowsB then
        ErrorNoReturn( "\\*: Matrices do not fit together" );
      elif not IsIdenticalObj( bd, b![ZBDPOS] ) then
        ErrorNoReturn( "\\*: Matrices not over same base domain" );
      fi;
    fi;

    if rowsA = 0 or colsB = 0 then
      list := [];
    elif colsA = 0 then  # colsA = rowsB
      if IsMutable( a ) or IsMutable( b ) then
        return ZeroMatrix( rowsA, colsB, a );
      else
        return MakeImmutable( ZeroMatrix( rowsA, colsB, a ) );
      fi;
    else
      res:= a![ZROWSPOS] * b![ZROWSPOS];
      m:= Size( bd );
      list:= List( res, row -> ZNZVECREDUCE( row, colsB, m ) );
      if not IsMutable( res ) then
        MakeImmutable( list );
      fi;
    fi;
    return MakeIsZmodnZMatrixRep( a![ZBDPOS], b![ZCOLSPOS], list, false );
  end );

InstallMethod(\*,
  IsIdenticalObj,
  [ "IsZmodnZMatrixRep", "IsMatrix" ],
function(a,b)
  return Matrix(BaseDomain(a),List(RowsOfMatrix(a),x->x*b));
end);
#TODO: Do we want this? If yes then it should be documented.

BindGlobal( "ZMZMATVEC", function( M, v )
    local rows, cols, bd, res;

    rows := NumberRows( M );
    cols := NumberColumns( M );
    bd := BaseDomain( M );

    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( bd, v![ZBDPOS] ) or
         cols <> Length( v ) ) then
      Error( "<M> and <v> are not compatible" );
    fi;

    # special case for empty matrices
    if rows = 0 or cols = 0 then
      return ZeroVector( rows, v );
    fi;

    res:= M![ZROWSPOS] * v![ZELSPOS];
    res:= ZNZVECREDUCE( res, cols, Size( bd ) );
    return Vector( res, v );
end );

InstallMethod( \*,
  [ "IsZmodnZMatrixRep", "IsZmodnZVectorRep" ],
  ZMZMATVEC );

BindGlobal( "ZMZVECMAT", function( v, M )
    local rows, cols, bd, res;

    rows := NumberRows( M );
    cols := NumberColumns( M );
    bd := BaseDomain( M );

    if ValueOption( "check" ) <> false and
       ( not IsIdenticalObj( v![ZBDPOS], bd ) or
         Length( v ) <> rows ) then
      Error( "<v> and <M> are not compatible" );
    fi;

    # special case for empty matrices
    if rows = 0 or cols = 0 then
      return ZeroVector( cols, v );
    fi;

    res:= v![ZELSPOS] * M![ZROWSPOS];
    res:= ZNZVECREDUCE( res, rows, Size( bd ) );
    return Vector( res, v );
end );

InstallMethod( \*,
  [ "IsZmodnZVectorRep", "IsZmodnZMatrixRep" ],
  ZMZVECMAT );

InstallOtherMethod( \^,
  [ "IsZmodnZVectorRep", "IsZmodnZMatrixRep" ],
  ZMZVECMAT );

InstallMethod( MultMatrixRowLeft,
  [ "IsZmodnZMatrixRep and IsMutable", "IsInt", "IsObject" ],
  function( mat, row, scalar )
    MultMatrixRowLeft( mat![ZROWSPOS], row, Int( scalar ) );
    ZNZVECREDUCE( mat![ZROWSPOS][row], mat![ZCOLSPOS], Size( mat![ZBDPOS] ) );
  end );

InstallMethod( MultMatrixRowRight,
  [ "IsZmodnZMatrixRep and IsMutable", "IsInt", "IsObject" ],
  function( mat, row, scalar )
    MultMatrixRowRight( mat![ZROWSPOS], row, Int( scalar ) );
    ZNZVECREDUCE( mat![ZROWSPOS][row], mat![ZCOLSPOS], Size( mat![ZBDPOS] ) );
  end );

InstallMethod( AddMatrixRowsLeft,
  [ "IsZmodnZMatrixRep and IsMutable", "IsInt", "IsInt", "IsObject" ],
  function( mat, row1, row2, scalar )
    AddMatrixRowsLeft( mat![ZROWSPOS], row1, row2, Int( scalar ) );
    ZNZVECREDUCE( mat![ZROWSPOS][row1], mat![ZCOLSPOS], Size( mat![ZBDPOS] ) );
  end );

InstallMethod( AddMatrixRowsRight,
  [ "IsZmodnZMatrixRep and IsMutable", "IsInt", "IsInt", "IsObject" ],
  function( mat, row1, row2, scalar )
    AddMatrixRowsRight( mat![ZROWSPOS], row1, row2, Int( scalar ) );
    ZNZVECREDUCE( mat![ZROWSPOS][row1], mat![ZCOLSPOS], Size( mat![ZBDPOS] ) );
  end );

InstallMethod( PositionNonZeroInRow,
  [ "IsZmodnZMatrixRep", "IsPosInt" ],
  { mat, row } -> PositionNonZero( mat![ZROWSPOS][row] ) );

InstallMethod( PositionNonZeroInRow,
  [ "IsZmodnZMatrixRep", "IsPosInt", "IsInt" ],
  { mat, row, from } -> PositionNonZero( mat![ZROWSPOS][row], from ) );

InstallMethod( SwapMatrixRows,
  [ "IsZmodnZMatrixRep and IsMutable", "IsInt", "IsInt" ],
  function( mat, row1, row2 )
    SwapMatrixRows(mat![ZROWSPOS], row1, row2);
  end );

InstallMethod( SwapMatrixColumns,
  [ "IsZmodnZMatrixRep and IsMutable", "IsInt", "IsInt" ],
  function( mat, col1, col2 )
    SwapMatrixColumns(mat![ZROWSPOS], col1, col2);
  end );


InstallMethod( PostMakeImmutable,
  [ "IsZmodnZMatrixRep" ],
  function( M )
    MakeImmutable( M![ZROWSPOS] );
  end );


InstallMethod( ViewObj,
  [ "IsZmodnZMatrixRep" ],
  function( m )
    local l;
    Print( "<" );
    if not IsMutable( m ) then
      Print( "immutable " );
    fi;
    l:= [ Length( m![ZROWSPOS] ), m![ZCOLSPOS] ];
    if Product( l ) <= 9 and Product( l ) <> 0 then
      Print( "matrix mod ", Size( m![ZBDPOS] ), ": ", m![ZROWSPOS], ">" );
    else
      Print( l[1], "x", l[2], "-matrix mod ", Size( m![ZBDPOS] ), ">" );
    fi;
  end );

InstallMethod( PrintObj,
  [ "IsZmodnZMatrixRep" ],
  function( M )
    Print( "NewMatrix(IsZmodnZMatrixRep" );
    if IsFinite( M![ZBDPOS] ) and IsField( M![ZBDPOS] ) then
      Print( ",GF(", Size( M![ZBDPOS] ), ")," );
    else
      Print( ",", String( M![ZBDPOS] ), "," );
    fi;
    Print( NumberColumns( M ), ",", M![ZROWSPOS], ")" );
  end );

InstallMethod( Display,
  [ "IsZmodnZMatrixRep" ],
  function( m )
    Print( "<" );
    if not IsMutable( m ) then
      Print( "immutable ");
    fi;
    Print( Length( m![ZROWSPOS] ), "x", m![ZCOLSPOS],
           "-matrix over ", m![ZBDPOS], ":\n" );
    Display( m![ZROWSPOS] );
    Print( "]>\n" );
  end );

InstallMethod( String,
  [ "IsZmodnZMatrixRep" ],
  function( M )
    local st;
    st := "NewMatrix(IsZmodnZMatrixRep,";
    if IsFinite( M![ZBDPOS] ) and IsField( M![ZBDPOS] ) then
      Append( st, "GF(" );
      Append( st, String( Size( M![ZBDPOS] ) ) );
      Append( st, ")," );
    else
      Append( st, String( M![ZBDPOS] ) );
      Append( st, "," );
    fi;
    Append( st, String( NumberColumns( M ) ) );
    Add( st, ',' );
    Append( st, String( M![ZROWSPOS] ) );
    Add( st, ')' );
    return st;
  end );


# Avoid 'Unpack'
InstallMethod( \=, IsIdenticalObj,
  [ "IsZmodnZMatrixRep", "IsZmodnZMatrixRep" ],
  { a, b } -> EQ_LIST_LIST_DEFAULT( a![ZROWSPOS], b![ZROWSPOS] ) );

InstallMethod( \=, IsIdenticalObj,
  [ "IsZmodnZMatrixRep", "IsMatrix" ],
  { a, b } -> Unpack( a ) = b );
#TODO: Do we want this? If yes then it should be documented.

InstallMethod( \=, IsIdenticalObj,
  [ "IsMatrix", "IsZmodnZMatrixRep" ],
  { a, b } -> a = Unpack( b ) );
#TODO: Do we want this? If yes then it should be documented.

# No default
InstallMethod( \<, IsIdenticalObj,
  [ "IsZmodnZMatrixRep", "IsZmodnZMatrixRep" ],
  { a, b } -> LT_LIST_LIST_DEFAULT( a![ZROWSPOS], b![ZROWSPOS] ) );

# Avoid 'Unpack'
InstallMethod( IsZero,
  [ "IsZmodnZMatrixRep" ],
  function( M )
    local row;
    for row in M![ZROWSPOS] do
      if not IsZero( row ) then
        return false;
      fi;
    od;
    return true;
  end );

# Avoid element access.
InstallMethod( IsOne,
  [ "IsZmodnZMatrixRep" ],
  function( M )
    local n, rows, i, row;

    n:= M![ZCOLSPOS];
    rows:= M![ZROWSPOS];
    if Length( rows ) <> n then
      return false;
    fi;
    for i in [ 1 .. n ] do
      row:= rows[i];
      if PositionNonZero( row ) <> i or
         not IsOne( row[i] ) or
         PositionNonZero( row, i ) <= n then
        return false;
      fi;
    od;
    return true;
  end );

# no good idea for this method,
# 'SemiEchelonMatDestructive' works only for 'IsRowListMatrix'
InstallMethod( RankMat,
  [ "IsZmodnZMatrixRep" ],
  M -> RankMat( Unpack( M ) ) );

BindGlobal( "PLISTVECZMZMAT", function( v, m )
    local r, res;
    r:= BaseDomain( m );
    # do arithmetic over Z first so that we reduce only once
    res:= List( v, Int ) * m![ZROWSPOS];
    return Vector( IsZmodnZVectorRep, r,
                   ZNZVECREDUCE( res, Length( res ), Size( r ) ) );
  end );

InstallOtherMethod( \*,
  IsElmsColls,
  [ "IsList", "IsZmodnZMatrixRep" ],
  PLISTVECZMZMAT);
#TODO: Do we want this? If yes then it should be documented.

InstallOtherMethod( \^,
  IsElmsColls,
  [ "IsList", "IsZmodnZMatrixRep" ],
  PLISTVECZMZMAT);
#TODO: Do we want this? If yes then it should be documented.

BindGlobal( "ZMZVECTIMESPLISTMAT", function( v, m )
    local i,res,s,r;
    r:=BaseDomain(v);
    # do arithmetic over Z first so that we reduce only once
    res:=ListWithIdenticalEntries(Length(m[1]),Zero(r));
    for i in [1..Length(v)] do
      s := v[i];
      if not IsZero(s) then
        AddRowVector(res,m[i],s);
      fi;
    od;
    res:=Vector(r,res);

    if not IsMutable(v) and not IsMutable(m) then
        MakeImmutable(res);
    fi;
    return res;
end );

InstallOtherMethod( \*,
  IsElmsColls,
  [ "IsZmodnZVectorRep", "IsMatrix" ],
  ZMZVECTIMESPLISTMAT);
#TODO: Do we want this? If yes then it should be documented.

InstallOtherMethod( \^,
  IsElmsColls,
  [ "IsZmodnZVectorRep", "IsMatrix" ],
  ZMZVECTIMESPLISTMAT);
#TODO: Do we want this? If yes then it should be documented.

InstallMethod( DeterminantMat,
  [ "IsZmodnZMatrixRep" ],
  a -> ZmodnZObj( DeterminantMat( a![ZROWSPOS] ), Size( BaseDomain( a ) ) ) );


#############################################################################
##
##  Minimal/Characteristic Polynomial stuff
##

#############################################################################
##
##  Variant of
#F  Matrix_OrderPolynomialInner( <fld>, <mat>, <vec>, <spannedspace> )
##
BindGlobal( "ZModnZMOPI",function( fld, mat, vec, vecs)
    local d, w, p, one, zero, zeroes, piv,  pols, x, t,i;
    Info(InfoMatrix,3,"Order Polynomial Inner on ",NrRows(mat),
         " x ",NrCols(mat)," matrix over ",fld," with ",
         Number(vecs)," basis vectors already given");
    d := Length(vec);
    pols := [];
    one := One(fld);
    zero := Zero(fld);
    zeroes := [];

    # this loop runs images of <vec> under powers of <mat>
    # trying to reduce them with smaller powers (and tracking the polynomial)
    # or with vectors from <spannedspace> as passed in
    # when we succeed, we know the order polynomial

    repeat
        w := ShallowCopy(vec);
        p := ShallowCopy(zeroes);
        Add(p,one);
        #p:=ZmodnZVec(fam,p);
        p:=Vector(fld,p);
        piv := PositionNonZero(w,0);

        #
        # Strip as far as we can
        #

        while piv <= d and IsBound(vecs[piv]) do
            x := -w[piv];
            if IsBound(pols[piv]) then
                #AddCoeffs(p, pols[piv], x);
                #p:=p+pols[piv]*x;
                t:=pols[piv]*x;
                for i in [1..Length(t)] do
                  p[i]:=p[i]+t[i];
                od;
            fi;
            AddRowVector(w, vecs[piv],  x, piv, d);
            #w:=w+vecs[piv]*x;
            piv := PositionNonZero(w,piv);
        od;

        #
        # if something is left then we don't have the order poly yet
        # update tables etc.
        #

        if piv <=d  then
            x := Inverse(w[piv]);
            MultVector(p, x);
            #p:=p*x;
            #MakeImmutable(p);
            pols[piv] := p;
            MultVector(w, x );
            #w:=w*x;
            #MakeImmutable(w);
            vecs[piv] := w;
            vec := vec*mat;
            Add(zeroes,zero);
        fi;
    until piv > d;
    MakeImmutable(p);
    Info(InfoMatrix,3,"Order Polynomial returns ",p);
    return p;
end );

InstallOtherMethod( MinimalPolynomial, "ZModnZ, spinning over field",
    IsElmsCollsX,
    [ IsField and IsFinite, IsMatrixObj, IsPosInt ],
function( fld, mat, ind )
    local i, n, base, vec, one, fam,
          mp, dim, span,op,w, piv,j;

    Info(InfoMatrix,1,"Minimal Polynomial called on ",
         NrRows(mat)," x ",NrCols(mat)," matrix over ",fld);
    n := NrRows(mat);
    base := [];
    dim := 0; # should be number of bound positions in base
    one := One(fld);
    fam := ElementsFamily(FamilyObj(fld));
    mp:=[one];
    #keep coeffs
    #mp := UnivariatePolynomialByCoefficients( fam, mp,ind);
    while dim < n do
        vec:= ZeroVector( n, mat );
        for i in [1..n] do
          if (not IsBound(base[i])) and Random([0,1])=1 then vec[i]:=one;fi;
        od;
        if IsZero(vec) then
          vec[Random(1,n)] := one; # make sure it's not zero
        fi;
        span := [];
        op := ZModnZMOPI( fld, mat, vec, span);
        op:=List(op);
        mp:=QUOTREM_LAURPOLS_LISTS(ProductCoeffs(mp,op),GcdCoeffs(mp,AsList(op)))[1];
        mp:=mp/Last(mp);
        Info(InfoMatrix,2,"So Far ",dim,", Span=",Length(span));

        for j in [1..Length(span)] do
            if IsBound(span[j]) then
                if dim < n then
                    if not IsBound(base[j]) then
                        base[j] := span[j];
                        dim := dim+1;
                    else
                        w := ShallowCopy(span[j]);
                        piv := j;
                        repeat
                            AddRowVector(w,base[piv],-w[piv], piv, n);
                            piv := PositionNonZero(w, piv);
                        until piv > n or not IsBound(base[piv]);
                        if piv <= n then
                            #MultVector(w,Inverse(w[piv]));
                            w:=w*Inverse(w[piv]);
                            #MakeImmutable(w);
                            base[piv] := w;
                            dim := dim+1;
                        fi;
                    fi;
                fi;
            fi;
        od;
    od;
    mp := UnivariatePolynomialByCoefficients( fam, mp,ind);
    Assert(3, IsZero(Value(mp,mat)));
    Info(InfoMatrix,1,"Minimal Polynomial returns ", mp);
    return mp;
end);


InstallOtherMethod( CharacteristicPolynomialMatrixNC, "zmodnz spinning over field",
    IsElmsCollsX,
    [ IsField, IsMatrixObj, IsPosInt ], function( fld, mat, ind)
local i, n, base, imat, vec, one,cp,op,zero,fam;
    Info(InfoMatrix,1,"Characteristic Polynomial called on ",
    NrRows(mat)," x ",NrCols(mat)," matrix over ",fld);
    imat := ImmutableMatrix(fld,mat);
    n := NrRows(mat);
    base := [];
    vec := CompatibleVector( mat );
    one := One(fld);
    zero := Zero(fld);
    fam := ElementsFamily(FamilyObj(fld));
    cp:=[one];
    cp := UnivariatePolynomialByCoefficients(fam,cp,ind);
    for i in [1..n] do
        if not IsBound(base[i]) then
            vec[i] := one;
            op := Unpack(ZModnZMOPI( fld, imat, vec, base));
            cp := cp *  UnivariatePolynomialByCoefficients( fam,op,ind);
            vec[i] := zero;
        fi;
    od;
    Assert(2, Length(CoefficientsOfUnivariatePolynomial(cp)) = n+1);
    if AssertionLevel()>=3 then
      # cannot use Value(cp,imat), as this uses characteristic polynomial
      n:=Zero(imat);
      one:=One(imat);
      for i in Reversed(CoefficientsOfUnivariatePolynomial(cp)) do
        n:=n*imat+(i*one);
      od;
      Assert(3,IsZero(n));
    fi;
    Info(InfoMatrix,1,"Characteristic Polynomial returns ", cp);
    return cp;
end );


#############################################################################
##
##  Compatibility with vectors/matrices over finite fields:
##

InstallOtherMethod( DegreeFFE,
  [ "IsZmodnZVectorRep" ],
  function(vec)
# TODO: check that modulus is a prime
    return 1;
  end );

InstallOtherMethod( DegreeFFE,
  [ "IsZmodnZMatrixRep" ],
  function(vec)
# TODO: check that modulus is a prime
    return 1;
  end);
