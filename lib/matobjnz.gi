#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##

# represent vectors/matrices over Z/nZ by nonnegative integer lists
# in the range [0..n-1], but reduce after
# arithmetic. This way avoid always wrapping all entries separately

BindGlobal("ZNZVECREDUCE",function(v,l,m)
local i;
  for i in [1..l] do
    if v[i]<0 or v[i]>=m then v[i]:=v[i] mod m;fi;
  od;
end);

InstallMethod( ConstructingFilter, "for a zmodnz vector",
  [ IsZmodnZVectorRep ],
  function( v )
    return IsZmodnZVectorRep;
  end );

InstallOtherMethod( ConstructingFilter, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    return IsZmodnZMatrixRep;
  end );

InstallMethod( CompatibleVectorFilter, "zmodnz",
  [ IsZmodnZMatrixRep ],
  M -> IsZmodnZVectorRep );

############################################################################
# Vectors
############################################################################

InstallTagBasedMethod( NewVector,
  IsZmodnZVectorRep,
  function( filter, basedomain, l )
    local check, typ, v;
    check:= ValueOption( "check" ) <> false;
    if check and not ( IsZmodnZObjNonprimeCollection( basedomain ) or
        ( IsFinite( basedomain ) and IsPrimeField( basedomain ) ) ) then
      Error( "<basedomain> must be Integers mod <n> for some <n>" );
    fi;
    typ:=NewType(FamilyObj(basedomain),IsZmodnZVectorRep and IsMutable and
      CanEasilyCompareElements);
    # force list of integers
    if FamilyObj(basedomain)=FamilyObj(l) then
      l:=List(l,Int);
    elif check and not ForAll( l, IsInt ) then
      Error( "<l> must be a list of integers or of elements in <basedomain>" );
    else
      l:=ShallowCopy(l);
    fi;
    v := [basedomain,l];
    Objectify(typ,v);
    return v;
  end );

InstallTagBasedMethod( NewZeroVector,
  IsZmodnZVectorRep,
  function( filter, basedomain, l )
    local check, typ, v;
    check:= ValueOption( "check" ) <> false;
    if check and not ( IsZmodnZObjNonprimeCollection( basedomain ) or
        ( IsFinite( basedomain ) and IsPrimeField( basedomain ) ) ) then
      Error( "<basedomain> must be Integers mod <n> for some <n>" );
    fi;
    typ:=NewType(FamilyObj(basedomain),IsZmodnZVectorRep and IsMutable and
      CanEasilyCompareElements);
    # represent list as integers
    v := [basedomain,0*[1..l]];
    Objectify(typ,v);
    return v;
  end );

InstallMethod( ViewObj, "for a zmodnz vector", [ IsZmodnZVectorRep ],
function( v )
local l;
    if not IsMutable(v) then
        Print("<immutable ");
    else
        Print("<");
    fi;
    Print("vector mod ",Size(v![BDPOS]));
    l:=Length(v![ELSPOS]);
    if 0<l and l<=8 then
      Print(": ",v![ELSPOS],">");
    else
      Print(" of length ",Length(v![ELSPOS]),">");
    fi;
  end );

InstallMethod( PrintObj, "for a zmodnz vector", [ IsZmodnZVectorRep ],
  function( v )
    Print("NewVector(IsZmodnZVectorRep");
    if IsField(v![BDPOS]) then
        Print(",GF(",Size(v![BDPOS]),"),",v![ELSPOS],")");
    else
        Print(",",String(v![BDPOS]),",",v![ELSPOS],")");
    fi;
  end );

InstallMethod( String, "for a zmodnz vector", [ IsZmodnZVectorRep ],
  function( v )
    local st;
    st := "NewVector(IsZmodnZVectorRep";
    if IsField(v![BDPOS]) then
        Append(st,Concatenation( ",GF(",String(Size(v![BDPOS])),"),",
                                 String(v![ELSPOS]),")" ));
    else
        Append(st,Concatenation( ",",String(v![BDPOS]),",",
                                 String(v![ELSPOS]),")" ));
    fi;
    return st;
  end );

InstallMethod( Display, "for a zmodnz vector", [ IsZmodnZVectorRep ],
  function( v )
    Print( "<a " );
    Print( "zmodnz vector over ",BaseDomain(v),":\n");
    Print(v![ELSPOS],"\n>\n");
  end );

InstallMethod( BaseDomain, "for a zmodnz vector", [ IsZmodnZVectorRep ],
  function( v )
    return v![BDPOS];
  end );

InstallMethod( Length, "for a zmodnz vector", [ IsZmodnZVectorRep ],
  function( v )
    return Length(v![ELSPOS]);
  end );

InstallMethod( ShallowCopy, "for a zmodnz vector", [ IsZmodnZVectorRep ],
  function( v )
    local res;
    res := Objectify(TypeObj(v),[v![BDPOS],ShallowCopy(v![ELSPOS])]);
    if not IsMutable(v) then SetFilterObj(res,IsMutable); fi;
    return res;
  end );

# StructuralCopy works automatically

InstallMethod( PostMakeImmutable, "for a zmodnz vector", [ IsZmodnZVectorRep ],
  function( v )
    MakeImmutable( v![ELSPOS] );
  end );

############################################################################
# Representation preserving constructors:
############################################################################

# not needed according to MH
# InstallMethod( ZeroVector, "for an integer and a zmodnz vector",
#   [ IsInt, IsZmodnZVectorRep ],
#   function( l, t )
#     local v;
#     v := Objectify(TypeObj(t),
#                    [t![BDPOS],ListWithIdenticalEntries(l,0)]);
#     if not IsMutable(v) then SetFilterObj(v,IsMutable); fi;
#     return v;
#   end );
#
# InstallMethod( ZeroVector, "for an integer and a zmodnz matrix",
#   [ IsInt, IsZmodnZMatrixRep ],
#   function( l, m )
#     local v;
#     v := Objectify(TypeObj(m![EMPOS]),
#                    [m![BDPOS],ListWithIdenticalEntries(l,0)]);
#     if not IsMutable(v) then SetFilterObj(v,IsMutable); fi;
#     return v;
#   end );

InstallMethod( Vector, "for a plain list and a zmodnz vector",IsIdenticalObj,
  [ IsList and IsPlistRep, IsZmodnZVectorRep ],
  function( l, t )
    local v;
    # force list of integers
    if FamilyObj(t![BDPOS])=FamilyObj(l) then l:=List(l,Int); fi;
    v := Objectify(TypeObj(t),[t![BDPOS],l]);
    if not IsMutable(v) then SetFilterObj(v,IsMutable); fi;
    return v;
  end );

InstallMethod( Vector, "for a list and a zmodnz vector",
  [ IsList, IsZmodnZVectorRep ],
  function( l, t )
    local v;
    v := ShallowCopy(l);
    if IsGF2VectorRep(l) then
        PLAIN_GF2VEC(v);
    elif Is8BitVectorRep(l) then
        PLAIN_VEC8BIT(v);
    fi;
    v := Objectify(TypeObj(t),[t![BDPOS],v]);
    if not IsMutable(v) then SetFilterObj(v,IsMutable); fi;
    return v;
  end );


############################################################################
# A selection of list operations:
############################################################################

InstallMethod( \[\], "for a zmodnz vector and a positive integer",
  [ IsZmodnZVectorRep, IsPosInt ],
  function( v, p )
    return ZmodnZObj(ElementsFamily(FamilyObj(v)),v![ELSPOS][p]);
  end );

InstallMethod( \[\]\:\=, "for a zmodnz vector, a positive integer, and an obj",
  [ IsZmodnZVectorRep, IsPosInt, IsObject ],
  function( v, p, ob )
    v![ELSPOS][p] := Int(ob);
  end );

InstallMethod( \{\}, "for a zmodnz vector and a list",
  [ IsZmodnZVectorRep, IsList ],
  function( v, l )
    return Objectify(TypeObj(v),[v![BDPOS],v![ELSPOS]{l}]);
  end );

InstallMethod( PositionNonZero, "for a zmodnz vector", [ IsZmodnZVectorRep ],
  function( v )
    return PositionNonZero( v![ELSPOS] );
  end );

InstallMethod( PositionNonZero, "for a zmodnz vector", [ IsZmodnZVectorRep ],
  function( v )
    return PositionNonZero( v![ELSPOS] );
  end );

InstallOtherMethod( PositionNonZero, "for a zmodnz vector and start",
  [ IsZmodnZVectorRep,IsInt ],
  function( v,s )
    return PositionNonZero( v![ELSPOS],s );
  end );

InstallMethod( PositionLastNonZero, "for a zmodnz vector", [ IsZmodnZVectorRep ],
  function( v )
    local els,i;
    els := v![ELSPOS];
    i := Length(els);
    while i > 0 and IsZero(els[i]) do i := i - 1; od;
    return i;
  end );

InstallMethod( ListOp, "for a zmodnz vector", [ IsZmodnZVectorRep ],
function( v )
local fam;
  fam:=ElementsFamily(FamilyObj(v));
  return List([1..Length(v![ELSPOS])],x->ZmodnZObj(fam,v![ELSPOS][x]));
end );

InstallMethod( ListOp, "for a zmodnz vector and a function",
  [ IsZmodnZVectorRep, IsFunction ],
function( v, f )
local fam;
  fam:=ElementsFamily(FamilyObj(v));
  return List(List([1..Length(v![ELSPOS])],x->ZmodnZObj(fam,v![ELSPOS][x])),f);
end );

InstallMethod( Unpack, "for a zmodnz vector",
  [ IsZmodnZVectorRep ],
function( v )
local fam;
  fam:=ElementsFamily(FamilyObj(v));
  return List([1..Length(v![ELSPOS])],x->ZmodnZObj(fam,v![ELSPOS][x]));
end );

############################################################################
# Arithmetical operations:
############################################################################

InstallMethod( \+, "for two zmodnz vectors",IsIdenticalObj,
  [ IsZmodnZVectorRep, IsZmodnZVectorRep ],
function( a, b )
local ty,i,m,mu;
  if not IsMutable(a) and IsMutable(b) then
      ty := TypeObj(b);
  else
      ty := TypeObj(a);
  fi;
  m:=Size(a![BDPOS]);
  b:=SUM_LIST_LIST_DEFAULT(a![ELSPOS],b![ELSPOS]);
  if not IsMutable(b) then mu:=true;b:=ShallowCopy(b);
  else mu:=false;fi;
  for i in [1..Length(b)] do if b[i]>=m then b[i]:=b[i] mod m;fi;od;
  if mu then MakeImmutable(b);fi;
  return Objectify(ty,[a![BDPOS],b]);
end );

InstallOtherMethod( \+, "for zmodnz vector and plist",IsIdenticalObj,
  [ IsZmodnZVectorRep, IsList ],
function( a, b )
  return a+Vector(BaseDomain(a),b);
end );

InstallOtherMethod( \+, "for plist and zmodnz vector",IsIdenticalObj,
  [ IsList,IsZmodnZVectorRep ],
function( a, b )
  return Vector(BaseDomain(b),a)+b;
end );

InstallMethod( \-, "for two zmodnz vectors",IsIdenticalObj,
  [ IsZmodnZVectorRep, IsZmodnZVectorRep ],
function( a, b )
local ty,i,m,mu;
  if not IsMutable(a) and IsMutable(b) then
      ty := TypeObj(b);
  else
      ty := TypeObj(a);
  fi;
  m:=Size(a![BDPOS]);
  b:=a![ELSPOS] - b![ELSPOS];
  if not IsMutable(b) then mu:=true;b:=ShallowCopy(b);
  else mu:=false;fi;
  for i in [1..Length(b)] do if b[i]<0 then b[i]:=b[i] mod m;fi;od;
  if mu then MakeImmutable(b);fi;
  return Objectify(ty,[a![BDPOS],b]);
end );

InstallOtherMethod( \-, "for zmodnz vector and plist",IsIdenticalObj,
  [ IsZmodnZVectorRep, IsList ],
function( a, b )
  return a-Vector(BaseDomain(a),b);
end );

InstallOtherMethod( \-, "for plist and zmodnz vector",IsIdenticalObj,
  [ IsList,IsZmodnZVectorRep ],
function( a, b )
  return Vector(BaseDomain(b),a)-b;
end );

InstallMethod( \=, "for two zmodnz vectors",IsIdenticalObj,
  [ IsZmodnZVectorRep, IsZmodnZVectorRep ],
  function( a, b )
    return EQ_LIST_LIST_DEFAULT(a![ELSPOS],b![ELSPOS]);
  end );

InstallMethod( \=, "for zmodnz vector and plist",IsIdenticalObj,
  [ IsZmodnZVectorRep, IsPlistRep ],
function( a, b )
  return a![ELSPOS]=List(b,x->x![1]);
end );

InstallMethod( \=, "for plist an zmodnz vector",IsIdenticalObj,
  [ IsPlistRep,IsZmodnZVectorRep],
function(b,a)
  return a![ELSPOS]=List(b,x->x![1]);
end );

InstallMethod( \<, "for two zmodnz vectors",IsIdenticalObj,
  [ IsZmodnZVectorRep, IsZmodnZVectorRep ],
  function( a, b )
    return LT_LIST_LIST_DEFAULT(a![ELSPOS],b![ELSPOS]);
  end );

InstallMethod( AddRowVector, "for two zmodnz vectors",
  [ IsZmodnZVectorRep and IsMutable, IsZmodnZVectorRep ],
function( a, b )
local i,m;
  a:=a![ELSPOS];
  ADD_ROW_VECTOR_2_FAST( a, b![ELSPOS] );
  m:=Size(b![BDPOS]);
  for i in [1..Length(a)] do if a[i]>=m then a[i]:=a[i] mod m;fi;od;
end );

InstallMethod( AddRowVector, "for two zmodnz vectors, and a scalar",
  [ IsZmodnZVectorRep and IsMutable, IsZmodnZVectorRep, IsObject ],
function( a, b, s )
local i,m;
  if IsZmodnZObj(s) then s:=Int(s);fi;
  a:=a![ELSPOS];
  if IsSmallIntRep(s) then
      ADD_ROW_VECTOR_3_FAST( a, b![ELSPOS], s );
  else
      ADD_ROW_VECTOR_3( a, b![ELSPOS], s );
  fi;
  m:=Size(b![BDPOS]);
  if s>=0 then
    for i in [1..Length(a)] do if a[i]>=m then a[i]:=a[i] mod m;fi;od;
  else
    for i in [1..Length(a)] do if a[i]<0 then a[i]:=a[i] mod m;fi;od;
  fi;
end );

InstallOtherMethod( AddRowVector, "for zmodnz vector, plist, and a scalar",
  [ IsZmodnZVectorRep and IsMutable, IsPlistRep, IsObject ],
function( a, b, s )
local i,m;
  if not ForAll(b,IsModulusRep) then TryNextMethod();fi;
  if IsZmodnZObj(s) then s:=Int(s);fi;
  m:=Size(a![BDPOS]);
  a:=a![ELSPOS];
  b:=List(b,x->x![1]);

  if IsSmallIntRep(s) then
      ADD_ROW_VECTOR_3_FAST( a, b, s );
  else
      ADD_ROW_VECTOR_3( a, b, s );
  fi;
  if s>=0 then
    for i in [1..Length(a)] do if a[i]>=m then a[i]:=a[i] mod m;fi;od;
  else
    for i in [1..Length(a)] do if a[i]<0 then a[i]:=a[i] mod m;fi;od;
  fi;
end );

InstallOtherMethod( AddRowVector, "for plist, zmodnz vector, and a scalar",
  [ IsPlistRep and IsMutable, IsZmodnZVectorRep, IsObject ],
function( a, b, s )
local i;
  if not ForAll(a,IsModulusRep) then TryNextMethod();fi;
  for i in [1..Length(a)] do
    a[i]:=a[i]+b[i]*s;
  od;
end);

InstallOtherMethod( AddRowVector, "for plist, plist vector, and a scalar",
  [ IsPlistRep and IsMutable, IsPlistVectorRep, IsObject ],
function( a, b, s )
local i;
  for i in [1..Length(a)] do
    a[i]:=a[i]+b[i]*s;
  od;
end);

InstallMethod( AddRowVector,
  "for two zmodnz vectors, a scalar, and two positions",
  [ IsZmodnZVectorRep and IsMutable, IsZmodnZVectorRep,
    IsObject, IsPosInt, IsPosInt ],
function( a, b, s, from, to )
local i,m;
  if IsZmodnZObj(s) then s:=Int(s);fi;
  a:=a![ELSPOS];
  if IsSmallIntRep(s) then
      ADD_ROW_VECTOR_5_FAST( a, b![ELSPOS], s, from, to );
  else
      ADD_ROW_VECTOR_5( a, b![ELSPOS], s, from, to );
  fi;
  m:=Size(b![BDPOS]);
  if s>=0 then
    for i in [1..Length(a)] do if a[i]>=m then a[i]:=a[i] mod m;fi;od;
  else
    for i in [1..Length(a)] do if a[i]<0 then a[i]:=a[i] mod m;fi;od;
  fi;
end );

InstallMethod( MultVectorLeft,
  "for a zmodnz vector, and an object",
  [ IsZmodnZVectorRep and IsMutable, IsObject ],
function( v, s )
local i,m;
  m:=Size(v![BDPOS]);
  if IsZmodnZObj(s) then s:=Int(s);fi;
  v:=v![ELSPOS];
  MULT_VECTOR_2_FAST(v,s);
  if s>=0 then
    for i in [1..Length(v)] do if v[i]>=m then v[i]:=v[i] mod m;fi;od;
  else
    for i in [1..Length(v)] do if v[i]<0 then v[i]:=v[i] mod m;fi;od;
  fi;
end );

# The four argument version of MultVectorLeft / ..Right uses the generic
# implementation in matobj.gi

BindGlobal("ZMODNZVECSCAMULT",
function( w, s )
local i,m,t,b,v;
  t:=TypeObj(w);
  b:=w![BDPOS];
  m:=Size(b);
  if IsZmodnZObj(s) then s:=Int(s);fi;
  v:=PROD_LIST_SCL_DEFAULT(w![ELSPOS],s);
  if not IsMutable(v) then
    v:=ShallowCopy(v);
  fi;
  if s>=0 then
    for i in [1..Length(v)] do if v[i]>=m then v[i]:=v[i] mod m;fi;od;
  else
    for i in [1..Length(v)] do if v[i]<0 then v[i]:=v[i] mod m;fi;od;
  fi;
  if not IsMutable(w![ELSPOS]) then MakeImmutable(v);fi;
  return Objectify(t,[b,v]);
end );

InstallMethod( \*, "for a zmodnz vector and a scalar",
  [ IsZmodnZVectorRep, IsScalar ],ZMODNZVECSCAMULT);

InstallMethod( \*, "for a scalar and a zmodnz vector",
  [ IsScalar, IsZmodnZVectorRep ],
function( s, v )
  return ZMODNZVECSCAMULT(v,s);
end );

InstallMethod( \/, "for a zmodnz vector and a scalar",
  [ IsZmodnZVectorRep, IsScalar ],
function( v, s )
  return ZMODNZVECSCAMULT(v,s^-1);
end );

BindGlobal("ZMODNZVECADDINVCLEANUP",function(m,l)
local i;
  if IsMutable(l) then
    for i in [1..Length(l)] do if l[i]<0 then l[i]:=l[i] mod m;fi;od;
  else
    l:=ShallowCopy(l);
    for i in [1..Length(l)] do if l[i]<0 then l[i]:=l[i] mod m;fi;od;
    MakeImmutable(l);
  fi;
  return l;
end);

InstallMethod( AdditiveInverseSameMutability, "for a zmodnz vector",
  [ IsZmodnZVectorRep ],
  function( v )
    return Objectify( TypeObj(v),
       [v![BDPOS],ZMODNZVECADDINVCLEANUP(Size(v![BDPOS]),
        AdditiveInverseSameMutability(v![ELSPOS]))] );
  end );

InstallMethod( AdditiveInverseImmutable, "for a zmodnz vector",
  [ IsZmodnZVectorRep ],
  function( v )
    local res;
    res := Objectify( TypeObj(v),
       [v![BDPOS],ZMODNZVECADDINVCLEANUP(Size(v![BDPOS]),
       AdditiveInverseSameMutability(v![ELSPOS]))] );
    MakeImmutable(res);
    return res;
  end );

InstallMethod( AdditiveInverseMutable, "for a zmodnz vector",
  [ IsZmodnZVectorRep ],
  function( v )
    local res;
    res := Objectify(TypeObj(v),
        [v![BDPOS],ZMODNZVECADDINVCLEANUP(Size(v![BDPOS]),
          AdditiveInverseMutable(v![ELSPOS]))]);
    if not IsMutable(v) then SetFilterObj(res,IsMutable); fi;
    return res;
  end );

# redundant according to MH
# InstallMethod( ZeroSameMutability, "for a zmodnz vector", [ IsZmodnZVectorRep ],
#   function( v )
#     return Objectify(TypeObj(v),[v![BDPOS],ZeroSameMutability(v![ELSPOS])]);
#   end );
#
# InstallMethod( ZeroImmutable, "for a zmodnz vector", [ IsZmodnZVectorRep ],
#   function( v )
#     local res;
#     res := Objectify(TypeObj(v),[v![BDPOS],ZeroImmutable(v![ELSPOS])]);
#     MakeImmutable(res);
#     return res;
#   end );

InstallMethod( ZeroMutable, "for a zmodnz vector", [ IsZmodnZVectorRep ],
  function( v )
    local res;
    res := Objectify(TypeObj(v),
                     [v![BDPOS],ZeroMutable(v![ELSPOS])]);
    if not IsMutable(v) then SetFilterObj(res,IsMutable); fi;
    return res;
  end );

InstallMethod( IsZero, "for a zmodnz vector", [ IsZmodnZVectorRep ],
  function( v )
    return IsZero( v![ELSPOS] );
  end );

#InstallMethodWithRandomSource( Randomize,
#  "for a random source and a mutable zmodnz vector",
#  [ IsRandomSource, IsZmodnZVectorRep and IsMutable ],
#  function( rs, v )
#    local bd,i;
#    bd := v![BDPOS];
#    for i in [1..Length(v![ELSPOS])] do
#        v![ELSPOS][i] := Random( rs, bd );
#    od;
#    return v;
#  end );

InstallMethod( CopySubVector, "for two zmodnz vectors and two lists",
  [ IsZmodnZVectorRep, IsZmodnZVectorRep and IsMutable, IsList, IsList ],
  function( a,b,pa,pb )
    # The following should eventually go into the kernel:
    if ValueOption( "check" ) <> false and a![BDPOS] <> b![BDPOS] then
      Error( "<a> and <b> have different base domains" );
    fi;
    b![ELSPOS]{pb} := a![ELSPOS]{pa};
  end );

InstallOtherMethod( ProductCoeffs,
  "zmodmat: call PRODUCT_COEFFS_GENERIC_LISTS with lengths",
    true, [ IsZmodnZVectorRep, IsZmodnZVectorRep], 0,
function( l1, l2 )
  return PRODUCT_COEFFS_GENERIC_LISTS(l1,Length(l1),l2,Length(l2));
end);

############################################################################
# Matrices
############################################################################

InstallTagBasedMethod( NewMatrix,
  IsZmodnZMatrixRep,
  function( filter, basedomain, rl, l )
    local check, nd, filterVectors, m, e, filter2, i;

    check:= ValueOption( "check" ) <> false;
    if check and not ( IsZmodnZObjNonprimeCollection( basedomain ) or
        ( IsFinite( basedomain ) and IsPrimeField( basedomain ) ) ) then
      Error( "<basedomain> must be Integers mod <n> for some <n>" );
    fi;

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

    filterVectors := IsZmodnZVectorRep;
    m := 0*[1..Length(l)];
    for i in [1..Length(l)] do
        if IsVectorObj(l[i]) and IsZmodnZVectorRep(l[i]) then
            m[i] := ShallowCopy(l[i]);
        else
            m[i] := NewVector( filterVectors, basedomain, l[i] );
        fi;
    od;
    e := NewVector(filterVectors, basedomain, []);
    m := [basedomain,e,rl,m];
    filter2 := IsZmodnZMatrixRep and IsMutable;
    if HasCanEasilyCompareElements(Representative(basedomain)) and
       CanEasilyCompareElements(Representative(basedomain)) then
        filter2 := filter2 and CanEasilyCompareElements;
    fi;
    Objectify( NewType(CollectionsFamily(FamilyObj(basedomain)),
                       filter2), m );
    return m;
  end );

# This is faster than the default method.
InstallTagBasedMethod( NewZeroMatrix,
  IsZmodnZMatrixRep,
  function( filter, basedomain, rows, cols )
    local check, m,i,e,filter2;

    check:= ValueOption( "check" ) <> false;
    if check and not ( IsZmodnZObjNonprimeCollection( basedomain ) or
        ( IsFinite( basedomain ) and IsPrimeField( basedomain ) ) ) then
      Error( "<basedomain> must be Integers mod <n> for some <n>" );
    fi;

    filter2 := IsZmodnZVectorRep;
    m := 0*[1..rows];
    e := NewVector(filter2, basedomain, []);
    for i in [1..rows] do
        m[i] := ZeroVector( cols, e );
    od;
    m := [basedomain,e,cols,m];
    Objectify( NewType(CollectionsFamily(FamilyObj(basedomain)),
                       filter and IsMutable), m );
    return m;
  end );

# This is faster than the default method.
InstallTagBasedMethod( NewIdentityMatrix,
  IsZmodnZMatrixRep,
  function( filter, basedomain, dim )
    local mat, i;
    mat := NewZeroMatrix(filter, basedomain, dim, dim);
    for i in [1..dim] do
        mat[i,i] := 1;
    od;
    return mat;
  end );

InstallOtherMethod( BaseDomain, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    return m![BDPOS];
  end );

InstallMethod( NumberRows, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    return Length(m![ROWSPOS]);
  end );

InstallMethod( NumberColumns, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    return m![RLPOS];
  end );

# InstallMethod( DimensionsMat, "for a zmodnz matrix",
#   [ IsZmodnZMatrixRep ],
#   function( m )
#     return [Length(m![ROWSPOS]),m![RLPOS]];
#   end );


############################################################################
# Representation preserving constructors:
############################################################################

# redundant according to MH
# InstallMethod( ZeroMatrix, "for two integers and a zmodnz matrix",
#   [ IsInt, IsInt, IsZmodnZMatrixRep ],
#   function( rows,cols,m )
#     local l,t,res;
#     t := m![EMPOS];
#     l := List([1..rows],i->ZeroVector(cols,t));
#     res := Objectify( TypeObj(m), [m![BDPOS],t,cols,l] );
#     if not IsMutable(m) then
#         SetFilterObj(res,IsMutable);
#     fi;
#     return res;
#   end );

InstallMethod( IdentityMatrix, "for an integer and a zmodnz matrix",
  [ IsInt, IsZmodnZMatrixRep ],
  function( rows,m )
    local i,l,o,t,res;
    t := m![EMPOS];
    l := List([1..rows],i->ZeroVector(rows,t));
    o := One(m![BDPOS]);
    for i in [1..rows] do
        l[i][i] := o;
    od;
    res := Objectify( TypeObj(m), [m![BDPOS],t,rows,l] );
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
    return res;
  end );

InstallMethod( Matrix, "for a list and a zmodnz matrix",
  [ IsList, IsInt, IsZmodnZMatrixRep ],
  function( rows,rowlen,m )
    local i,l,nrrows,res,t;
    t := m![EMPOS];
    if Length(rows) > 0 then
        if IsVectorObj(rows[1]) and IsZmodnZVectorRep(rows[1]) then
            nrrows := Length(rows);
            l := rows;
        elif IsList(rows[1]) then
            nrrows := Length(rows);
            l := ListWithIdenticalEntries(Length(rows),0);
            for i in [1..Length(rows)] do
                l[i] := Vector(rows[i],t);
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
        nrrows := 0;
    fi;
    res := Objectify( TypeObj(m), [m![BDPOS],t,rowlen,l] );
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
    return res;
  end );

############################################################################
# Printing and viewing methods:
############################################################################

InstallMethod( ViewObj, "for a zmodnz matrix", [ IsZmodnZMatrixRep ],
  function( m )
  local l;
    Print("<");
    if not IsMutable(m) then Print("immutable "); fi;
    l:=[Length(m![ROWSPOS]),m![RLPOS]];
    if Product(l)<=9 and Product(l)<>0 then
      Print("matrix mod ",Size(m![BDPOS]),": ",
        List(m![ROWSPOS],x->x![ELSPOS]),">");
    else
      Print(l[1],"x",l[2],"-matrix mod ",Size(m![BDPOS]),">");
    fi;
  end );

InstallMethod( PrintObj, "for a zmodnz matrix", [ IsZmodnZMatrixRep ],
  function( m )
    Print("NewMatrix(IsZmodnZMatrixRep");
    if IsFinite(m![BDPOS]) and IsField(m![BDPOS]) then
        Print(",GF(",Size(m![BDPOS]),"),");
    else
        Print(",",String(m![BDPOS]),",");
    fi;
    Print(NumberColumns(m),",",Unpack(m),")");
  end );

InstallMethod( Display, "for a zmodnz matrix", [ IsZmodnZMatrixRep ],
  function( m )
    Print("<");
    if not IsMutable(m) then Print("immutable "); fi;
    Print(Length(m![ROWSPOS]),"x",m![RLPOS],"-matrix over ",m![BDPOS],":\n");
    Display(List(m![ROWSPOS],x->x![ELSPOS]));
#    for i in [1..Length(m![ROWSPOS])] do
#        if i = 1 then
#            Print("[");
#        else
#            Print(" ");
#        fi;
#        Print(m![ROWSPOS][i]![ELSPOS],"\n");
#    od;
    Print("]>\n");
  end );

InstallMethod( String, "for zmodnz matrix", [ IsZmodnZMatrixRep ],
  function( m )
    local st;
    st := "NewMatrix(IsZmodnZMatrixRep";
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
# A selection of list operations:
############################################################################

InstallOtherMethod( \[\], "for a zmodnz matrix and a positive integer",
#T Once the declaration of '\[\]' for 'IsMatrixObj' disappears,
#T we can use 'InstallMethod'.
  [ IsZmodnZMatrixRep, IsPosInt ],
  function( m, p )
    return m![ROWSPOS][p];
  end );

InstallOtherMethod( \[\]\:\=,
  "for a zmodnz matrix, a positive integer, and a zmodnz vector",
  [ IsZmodnZMatrixRep and IsMutable, IsPosInt, IsZmodnZVectorRep ],
  function( m, p, v )
    m![ROWSPOS][p] := v;
  end );

InstallOtherMethod( \{\}, "for a zmodnz matrix and a list",
  [ IsZmodnZMatrixRep, IsList ],
  function( m, p )
    local l;
    l := m![ROWSPOS]{p};
    return Objectify(TypeObj(m),[m![BDPOS],m![EMPOS],m![RLPOS],l]);
  end );

InstallMethod( Add, "for a zmodnz matrix and a zmodnz vector",
  [ IsZmodnZMatrixRep and IsMutable, IsZmodnZVectorRep ],
  function( m, v )
    Add(m![ROWSPOS],v);
  end );

InstallMethod( Add, "for a zmodnz matrix, a zmodnz vector, and a pos. int",
  [ IsZmodnZMatrixRep and IsMutable, IsZmodnZVectorRep, IsPosInt ],
  function( m, v, p )
    Add(m![ROWSPOS],v,p);
  end );

InstallMethod( Remove, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep and IsMutable ],
  m -> Remove( m![ROWSPOS] ) );

InstallMethod( Remove, "for a zmodnz matrix, and a position",
  [ IsZmodnZMatrixRep and IsMutable, IsPosInt ],
  function( m, p )
    Remove( m![ROWSPOS],p );
  end );
#T must return the removed row if it was bound

InstallMethod( IsBound\[\], "for a zmodnz matrix, and a position",
  [ IsZmodnZMatrixRep, IsPosInt ],
  function( m, p )
    return p <= Length(m![ROWSPOS]);
  end );

InstallMethod( Unbind\[\], "for a zmodnz matrix, and a position",
  [ IsZmodnZMatrixRep and IsMutable, IsPosInt ],
  function( m, p )
    if p <> Length(m![ROWSPOS]) then
        ErrorNoReturn("Unbind\\[\\]: Matrices must stay dense, you cannot Unbind here");
    fi;
    Unbind( m![ROWSPOS][p] );
  end );

InstallMethod( \{\}\:\=, "for a zmodnz matrix, a list, and a zmodnz matrix",
  [ IsZmodnZMatrixRep and IsMutable, IsList,
    IsZmodnZMatrixRep ],
  function( m, pp, n )
    m![ROWSPOS]{pp} := n![ROWSPOS];
  end );

InstallMethod( Append, "for two zmodnz matrices",
  [ IsZmodnZMatrixRep and IsMutable, IsZmodnZMatrixRep ],
  function( m, n )
    Append(m![ROWSPOS],n![ROWSPOS]);
  end );

InstallMethod( ShallowCopy, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    local res;
    res := Objectify(TypeObj(m),[m![BDPOS],m![EMPOS],m![RLPOS],
                                 ShallowCopy(m![ROWSPOS])]);
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
#T 'ShallowCopy' MUST return a mutable object
#T if such an object exists at all!
    return res;
  end );

InstallMethod( PostMakeImmutable, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    MakeImmutable( m![ROWSPOS] );
  end );

InstallOtherMethod( ListOp, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    return List(m![ROWSPOS]);
  end );

InstallOtherMethod( ListOp, "for a zmodnz matrix and a function",
  [ IsZmodnZMatrixRep, IsFunction ],
  function( m, f )
    return List(m![ROWSPOS],f);
  end );

InstallOtherMethod( Unpack, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
function( m )
local fam;
  fam:=ElementsFamily(FamilyObj(BaseDomain(m)));
    return List(m![ROWSPOS],v->
      List([1..Length(v![ELSPOS])],x->ZmodnZObj(fam,v![ELSPOS][x])));
  end );


InstallMethod( MutableCopyMatrix, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    local l,res;
    l := List(m![ROWSPOS],ShallowCopy);
    res := Objectify(TypeObj(m),[m![BDPOS],m![EMPOS],m![RLPOS],l]);
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
    return res;
  end);

InstallMethod( ExtractSubMatrix, "for a zmodnz matrix, and two lists",
  [ IsZmodnZMatrixRep, IsList, IsList ],
  function( m, p, q )
    local i,l;
    l := m![ROWSPOS]{p};
    for i in [1..Length(l)] do
        l[i] := Objectify(TypeObj(l[i]),[l[i]![BDPOS],l[i]![ELSPOS]{q}]);
    od;
    return Objectify(TypeObj(m),[m![BDPOS],m![EMPOS],Length(q),l]);
  end );

InstallMethod( CopySubMatrix, "for two zmodnz matrices and four lists",
  [ IsZmodnZMatrixRep, IsZmodnZMatrixRep and IsMutable,
    IsList, IsList, IsList, IsList ],
  function( m, n, srcrows, dstrows, srccols, dstcols )
    local i;
    if ValueOption( "check" ) <> false and m![BDPOS] <> n![BDPOS] then
      Error( "<m> and <n> have different base domains" );
    fi;
    # This eventually should go into the kernel without creating
    # a intermediate objects:
    for i in [1..Length(srcrows)] do
        n![ROWSPOS][dstrows[i]]![ELSPOS]{dstcols} :=
                  m![ROWSPOS][srcrows[i]]![ELSPOS]{srccols};
    od;
  end );

# InstallOtherMethod( CopySubMatrix,
#   "for two zmodnzs -- fallback in case of bad rep.",
#   [ IsZmodnZRep, IsZmodnZRep and IsMutable,
#     IsList, IsList, IsList, IsList ],
#   function( m, n, srcrows, dstrows, srccols, dstcols )
#     local i;
#     # in this representation all access probably has to go through the
#     # generic method selection, so it is not clear whether there is an
#     # improvement in moving this into the kernel.
#     for i in [1..Length(srcrows)] do
#         n[dstrows[i]]{dstcols}:=m[srcrows[i]]{srccols};
#     od;
#   end );

InstallMethod( MatElm, "for a zmodnz matrix and two positions",
  [ IsZmodnZMatrixRep, IsPosInt, IsPosInt ],
  function( m, row, col )
    return ZmodnZObj(ElementsFamily(FamilyObj(m![BDPOS])),
     m![ROWSPOS][row]![ELSPOS][col]);
  end );

InstallMethod( SetMatElm, "for a zmodnz matrix, two positions, and an object",
  [ IsZmodnZMatrixRep and IsMutable, IsPosInt, IsPosInt, IsObject ],
  function( m, row, col, ob )
    if ValueOption( "check" ) <> false and
       not ( IsInt( ob ) or ob in BaseDomain( m ) ) then
      Error( "<ob> must be an integer or in the base domain of <m>" );
    fi;
    m![ROWSPOS][row]![ELSPOS][col] := Int(ob);
  end );


############################################################################
# Arithmetical operations:
############################################################################

InstallMethod( \+, "for two zmodnz matrices",
  [ IsZmodnZMatrixRep, IsZmodnZMatrixRep ],
  function( a, b )
    local ty;
    if not IsMutable(a) and IsMutable(b) then
        ty := TypeObj(b);
    else
        ty := TypeObj(a);
    fi;
    return Objectify(ty,[a![BDPOS],a![EMPOS],a![RLPOS],
                         SUM_LIST_LIST_DEFAULT(a![ROWSPOS],b![ROWSPOS])]);
  end );

InstallMethod( \-, "for two zmodnz matrices",
  [ IsZmodnZMatrixRep, IsZmodnZMatrixRep ],
  function( a, b )
    local ty;
    if not IsMutable(a) and IsMutable(b) then
        ty := TypeObj(b);
    else
        ty := TypeObj(a);
    fi;
    return Objectify(ty,[a![BDPOS],a![EMPOS],a![RLPOS],
                         DIFF_LIST_LIST_DEFAULT(a![ROWSPOS],b![ROWSPOS])]);
  end );

InstallMethod( \*, "for two zmodnz matrices",IsIdenticalObj,
  [ IsZmodnZMatrixRep, IsZmodnZMatrixRep ],
  function( a, b )
    # Here we do full checking since it is rather cheap!
    local i,j,l,ty,v,w,m,r;
    if not IsMutable(a) and IsMutable(b) then
        ty := TypeObj(b);
    else
        ty := TypeObj(a);
    fi;
    if not a![RLPOS] = Length(b![ROWSPOS]) then
        ErrorNoReturn("\\*: Matrices do not fit together");
    fi;
    if not IsIdenticalObj(a![BDPOS],b![BDPOS]) then
        ErrorNoReturn("\\*: Matrices not over same base domain");
    fi;
    r:=BaseDomain(a);
    m:=Size(r);
    l := ListWithIdenticalEntries(Length(a![ROWSPOS]),0);
    for i in [1..Length(l)] do
        if b![RLPOS] = 0 then
            l[i] := b![EMPOS];
        else
            v := a![ROWSPOS][i];

            # do arithmetic over Z first and reduce afterwards
            w:=ListWithIdenticalEntries(b![RLPOS],0);
            v:=v![ELSPOS];
            for j in [1..a![RLPOS]] do
              AddRowVector(w,b![ROWSPOS][j]![ELSPOS],v[j]);
              #if (j mod 1000=0) and not ForAll(w,IsSmallIntRep) then
              #  ZNZVECREDUCE(w,b![RLPOS],m);
              #fi;
            od;
            ZNZVECREDUCE(w,b![RLPOS],m);
            w:=Vector(r,w);

            l[i] := w;
        fi;
    od;
    if not IsMutable(a) and not IsMutable(b) then
        MakeImmutable(l);
    fi;
    return Objectify( ty, [a![BDPOS],a![EMPOS],b![RLPOS],l] );
  end );

InstallMethod(\*,"for zmodnz matrix and ordinary matrix",IsIdenticalObj,
  [IsZmodnZMatrixRep,IsMatrix],
function(a,b)
  return Matrix(BaseDomain(a),List(RowsOfMatrix(a),x->x*b));
end);


InstallMethod( \=, "for two zmodnz matrices",IsIdenticalObj,
  [ IsZmodnZMatrixRep, IsZmodnZMatrixRep ],
  function( a, b )
    return EQ_LIST_LIST_DEFAULT(a![ROWSPOS],b![ROWSPOS]);
  end );

InstallMethod( \=, "for zmodnz matrix and matrix",IsIdenticalObj,
  [ IsZmodnZMatrixRep, IsMatrix ],
  function( a, b )
    return Unpack(a)=b;
  end );

InstallMethod( \=, "for matrix and zmodnz matrix",IsIdenticalObj,
  [ IsMatrix, IsZmodnZMatrixRep ],
  function( a, b )
    return a=Unpack(b);
  end );


InstallMethod( \<, "for two zmodnz matrices",IsIdenticalObj,
  [ IsZmodnZMatrixRep, IsZmodnZMatrixRep ],
  function( a, b )
    return LT_LIST_LIST_DEFAULT(a![ROWSPOS],b![ROWSPOS]);
  end );

InstallMethod( AdditiveInverseSameMutability, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    local l;
    l := List(m![ROWSPOS],AdditiveInverseSameMutability);
    if not IsMutable(m) then
        MakeImmutable(l);
    fi;
    return Objectify( TypeObj(m), [m![BDPOS],m![EMPOS],m![RLPOS],l] );
  end );

InstallMethod( AdditiveInverseImmutable, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    local l,res;
    l := List(m![ROWSPOS],AdditiveInverseImmutable);
    res := Objectify( TypeObj(m), [m![BDPOS],m![EMPOS],m![RLPOS],l] );
    MakeImmutable(res);
    return res;
  end );

InstallMethod( AdditiveInverseMutable, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    local l,res;
    l := List(m![ROWSPOS],AdditiveInverseMutable);
    res := Objectify( TypeObj(m), [m![BDPOS],m![EMPOS],m![RLPOS],l] );
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
    return res;
  end );

InstallMethod( ZeroSameMutability, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    local l;
    l := List(m![ROWSPOS],ZeroSameMutability);
    if not IsMutable(m) then
        MakeImmutable(l);
    fi;
    return Objectify( TypeObj(m), [m![BDPOS],m![EMPOS],m![RLPOS],l] );
  end );

InstallMethod( ZeroImmutable, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    local l,res;
    l := List(m![ROWSPOS],ZeroImmutable);
    res := Objectify( TypeObj(m), [m![BDPOS],m![EMPOS],m![RLPOS],l] );
    MakeImmutable(res);
    return res;
  end );

InstallMethod( ZeroMutable, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    local l,res;
    l := List(m![ROWSPOS],ZeroMutable);
    res := Objectify( TypeObj(m), [m![BDPOS],m![EMPOS],m![RLPOS],l] );
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
    return res;
  end );

InstallMethod( IsZero, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    local i;
    for i in [1..Length(m![ROWSPOS])] do
        if not IsZero(m![ROWSPOS][i]) then
            return false;
        fi;
    od;
    return true;
  end );

InstallMethod( IsOne, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
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

InstallMethod( OneSameMutability, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
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

InstallMethod( OneMutable, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    if m![RLPOS] <> Length(m![ROWSPOS]) then
        #Error("OneMutable: Matrix is not square");
        #return;
        return fail;
    fi;
    return IdentityMatrix(m![RLPOS],m);
  end );

InstallMethod( OneImmutable, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
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

InstallMethod( InverseMutable, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    local n,modulus;
    modulus:=Size(BaseDomain(m));
    if m![RLPOS] <> Length(m![ROWSPOS]) then
        #Error("InverseMutable: Matrix is not square");
        #return;
        return fail;
    fi;
    # Make a plain list of lists:
    n := List(m![ROWSPOS],x->x![ELSPOS]);
    n := InverseMutable(n);  # Invert!
    if n = fail then return fail; fi;
    n:=List(n,x->List(x,y->y mod modulus));
    return Matrix(n,Length(n),m);
  end );

InstallMethod( InverseImmutable, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    local n,modulus;
    modulus:=Size(BaseDomain(m));
    if m![RLPOS] <> Length(m![ROWSPOS]) then
        #Error("InverseMutable: Matrix is not square");
        #return;
        return fail;
    fi;
    # Make a plain list of lists:
    n := List(m![ROWSPOS],x->x![ELSPOS]);
    n := InverseMutable(n);  # Invert!
    if n = fail then return fail; fi;
    n:=List(n,x->List(x,y->y mod modulus));
    n := Matrix(n,Length(n),m);
    MakeImmutable(n);
    return n;
  end );

InstallMethod( InverseSameMutability, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    local n,modulus;
    modulus:=Size(BaseDomain(m));
    if m![RLPOS] <> Length(m![ROWSPOS]) then
        #Error("InverseMutable: Matrix is not square");
        #return;
        return fail;
    fi;
    # Make a plain list of lists:
    n := List(m![ROWSPOS],x->x![ELSPOS]);
    n := InverseMutable(n);  # Invert!
    if n = fail then return fail; fi;
    n:=List(n,x->List(x,y->y mod modulus));
    n := Matrix(n,Length(n),m);
    if not IsMutable(m) then
        MakeImmutable(n);
    fi;
    return n;
  end );

InstallMethod( RankMat, "for a zmodnz matrix", [ IsZmodnZMatrixRep ],
function( m )
  m:=MutableCopyMatrix(m);
  m:=SemiEchelonMatDestructive(m);
  if m<>fail then m:=Length(m.vectors);fi;
  return m;
end);


#InstallMethodWithRandomSource( Randomize,
#  "for a random source and a mutable zmodnz matrix",
#  [ IsRandomSource, IsZmodnZMatrixRep and IsMutable ],
#  function( rs, m )
#    local v;
#    for v in m![ROWSPOS] do
#        Randomize( rs, v );
#    od;
#    return m;
#  end );

InstallMethod( TransposedMatMutable, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    local i,n,v;
    n := ListWithIdenticalEntries(m![RLPOS],0);
    for i in [1..m![RLPOS]] do
        v := Vector(List(m![ROWSPOS],v->v![ELSPOS][i]),m![EMPOS]);
        n[i] := v;
    od;
    return Objectify(TypeObj(m),[m![BDPOS],m![EMPOS],Length(m![ROWSPOS]),n]);
  end );

InstallMethod( TransposedMatImmutable, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( m )
    local n;
    n := TransposedMatMutable(m);
    MakeImmutable(n);
    return n;
  end );

BindGlobal( "ZMZVECMAT", function( v, m )
    local i,res,s,r;
    r:=BaseDomain(v);
    # do arithmetic over Z first so that we reduce only once
    res:=ListWithIdenticalEntries(m![RLPOS],0);
    for i in [1..Length(v![ELSPOS])] do
      s := v![ELSPOS][i];
      if not IsZero(s) then
        AddRowVector(res,m![ROWSPOS][i]![ELSPOS],s);
        #if (i mod 100=0) and not ForAll(res,IsSmallIntRep) then
        #  ZNZVECREDUCE(res,Length(res),Size(r));
        #fi;
      fi;
    od;
    ZNZVECREDUCE(res,Length(res),Size(r));
    res:=Vector(r,res);

    if not IsMutable(v) and not IsMutable(m) then
        MakeImmutable(res);
    fi;
    return res;
end );

InstallMethod( \*, "for a zmodnz vector and a zmodnz matrix",
  IsElmsColls, [ IsZmodnZVectorRep, IsZmodnZMatrixRep ],
  ZMZVECMAT);

InstallOtherMethod( \^, "for a zmodnz vector and a zmodnz matrix",
  IsElmsColls, [ IsZmodnZVectorRep, IsZmodnZMatrixRep ],
  ZMZVECMAT);

BindGlobal( "PLISTVECZMZMAT", function( v, m )
    local i,res,s,r;
    r:=BaseDomain(m);
    # do arithmetic over Z first so that we reduce only once
    res:=ListWithIdenticalEntries(m![RLPOS],0);
    for i in [1..Length(v)] do
      s := v[i];
      if not IsZero(s) then
        AddRowVector(res,m![ROWSPOS][i]![ELSPOS],Int(s));
        #if (i mod 100=0) and not ForAll(res,IsSmallIntRep) then
        #  ZNZVECREDUCE(res,Length(res),Size(r));
        #fi;
      fi;
    od;
    ZNZVECREDUCE(res,Length(res),Size(r));
    res:=Vector(r,res);

    if not IsMutable(v) and not IsMutable(m) then
        MakeImmutable(res);
    fi;
    return res;
end );

InstallOtherMethod( \*, "for a plist vector and a zmodnz matrix",
  IsElmsColls, [ IsList, IsZmodnZMatrixRep ],
  PLISTVECZMZMAT);

InstallOtherMethod( \^, "for a plist vector and a zmodnz matrix",
  IsElmsColls, [ IsList, IsZmodnZMatrixRep ],
  PLISTVECZMZMAT);

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

InstallOtherMethod( \*, "for a zmodnz vector and plist matrix",
  IsElmsColls, [ IsZmodnZVectorRep, IsMatrix ],
  ZMZVECTIMESPLISTMAT);

InstallOtherMethod( \^, "for a zmodnz vector and plist matrix",
  IsElmsColls, [ IsZmodnZVectorRep, IsMatrix ],
  ZMZVECTIMESPLISTMAT);

InstallMethod( CompatibleVector, "for a zmodnz matrix",
  [ IsZmodnZMatrixRep ],
  function( v )
    return NewZeroVector(IsZmodnZVectorRep,BaseDomain(v),NumberRows(v));
  end );

InstallMethod( DeterminantMat, "for a zmodnz matrix", [ IsZmodnZMatrixRep ],
function( a )
local m;
  m:=Size(BaseDomain(a));
  a:=List(a![ROWSPOS],x->x![ELSPOS]);
  return ZmodnZObj(DeterminantMat(a),m);
end );


# Minimal/Characteristic  Polynomial stuff
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
        vec:=ZeroVector(n,mat[1]);
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
        mp:=mp/mp[Length(mp)];
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
    vec := ZeroOp(mat[1]);
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


##

InstallOtherMethod( DegreeFFE,
    [ "IsZmodnZVectorRep" ],
function(vec)
    # TODO: check that modulus is a prime
    return 1;
end);

InstallOtherMethod( DegreeFFE,
    [ "IsZmodnZMatrixRep" ],
function(vec)
    # TODO: check that modulus is a prime
    return 1;
end);
