#############################################################################
#
# matobjplist.gi
#                                                        by Max Neunhöffer
#
# Copyright (C) 2006 by Lehrstuhl D für Mathematik, RWTH Aachen
#
# This file is a sample implementation for new style vectors and matrices.
# It stores matrices as dense lists of lists with wrapping.
#
############################################################################

############################################################################
# Constructors:
############################################################################

InstallGlobalFunction( MakePlistVectorType,
  function( basedomain, filter )
    local T, filter2;
    if HasCanEasilyCompareElements(Representative(basedomain)) and
       CanEasilyCompareElements(Representative(basedomain)) then
        filter2 := filter and IsMutable and CanEasilyCompareElements;
    fi;
    if IsIdenticalObj(basedomain,Integers) then
        T := NewType(FamilyObj(basedomain),
                       filter2 and IsIntVector);
    elif IsFinite(basedomain) and IsField(basedomain) then
        T := NewType(FamilyObj(basedomain),
                       filter2 and IsFFEVector);
    else
        T := NewType(FamilyObj(basedomain),
                       filter2);
    fi;
    return T;
  end);

InstallMethod( NewVector, "for IsPlistVectorRep, a ring, and a list",
  [ IsPlistVectorRep and IsCheckingVector, IsRing, IsList ],
  function( filter, basedomain, l )
    local typ, v;
    typ := MakePlistVectorType(basedomain,filter);
    v := [basedomain,ShallowCopy(l)];
    Objectify(typ,v);
    return v;
  end );

InstallMethod( NewZeroVector, "for IsPlistVectorRep, a ring, and an int",
  [ IsPlistVectorRep and IsCheckingVector, IsRing, IsInt ],
  function( filter, basedomain, l )
    local typ, v;
    typ := MakePlistVectorType(basedomain,filter);
    v := [basedomain,Zero(basedomain)*[1..l]];
    Objectify(typ,v);
    return v;
  end );

InstallMethod( NewMatrix,
  "for IsPlistMatrixRep, a ring, an int, and a list",
  [ IsPlistMatrixRep and IsCheckingMatrix, IsRing, IsInt, IsList ],
  function( filter, basedomain, rl, l )
    local m,i,e,filter2, nd;

# TODO: verify that rl actually matches the data in l, if not, show an error
    # check if l is flat list
    if Length(l) > 0 and not IsVectorObj(l[1]) then
      nd := NestingDepthA(l);
      if nd < 2 or nd mod 2 = 1 then
        l := FoldList(l, rl);
      fi;
    fi;
    if IsIdenticalObj(IsPlistMatrixRep,filter) then
        filter2 := IsPlistVectorRep;
    else
        filter2 := IsPlistVectorRep and IsCheckingVector;
    fi;
    m := 0*[1..Length(l)];
    e := NewVector(filter2, basedomain, []);
    for i in [1..Length(l)] do
        if IsVectorObj(l[i]) and IsPlistVectorRep(l[i]) then
            m[i] := ShallowCopy(l[i]);
        else
            m[i] := Vector( l[i], e );
        fi;
    od;
    m := [basedomain,e,rl,m];
    filter2 := filter and IsMutable;
    if HasCanEasilyCompareElements(Representative(basedomain)) and
       CanEasilyCompareElements(Representative(basedomain)) then
        filter2 := filter2 and CanEasilyCompareElements;
    fi;
    Objectify( NewType(CollectionsFamily(FamilyObj(basedomain)),
                       filter2), m );
    return m;
  end );

InstallMethod( NewZeroMatrix,
  "for IsPlistMatrixRep, a ring, and two ints",
  [ IsPlistMatrixRep and IsCheckingMatrix, IsRing, IsInt, IsInt ],
  function( filter, basedomain, rows, cols )
    local m,i,e,filter2;
    if IsIdenticalObj(IsPlistMatrixRep,filter) then
        filter2 := IsPlistVectorRep;
    else
        filter2 := IsPlistVectorRep and IsCheckingVector;
    fi;
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

InstallMethod( NewIdentityMatrix,
  "for IsPlistMatrixRep, a ring, and an int",
  [ IsPlistMatrixRep and IsCheckingMatrix, IsRing, IsInt ],
  function( filter, basedomain, rows )
    local m,i,e,filter2;
    if IsIdenticalObj(IsPlistMatrixRep,filter) then
        filter2 := IsPlistVectorRep;
    else
        filter2 := IsPlistVectorRep and IsCheckingVector;
    fi;
    m := 0*[1..rows];
    e := NewVector(IsPlistVectorRep, basedomain, []);
    for i in [1..rows] do
        m[i] := ZeroVector( rows, e );
        m[i][i] := One(basedomain);
    od;
    m := [basedomain,e,rows,m];
    Objectify( NewType(CollectionsFamily(FamilyObj(basedomain)),
                       filter and IsMutable), m );
    return m;
  end );


############################################################################
# Printing and viewing methods:
############################################################################

InstallMethod( ViewObj, "for a plist vector", [ IsPlistVectorRep ],
  function( v )
    if not IsMutable(v) then
        Print("<immutable ");
    else
        Print("<");
    fi;
    if IsCheckingVector(v) then Print("checking "); fi;
    Print("plist vector over ",v![BDPOS]," of length ",Length(v![ELSPOS]),">");
  end );

InstallMethod( PrintObj, "for a plist vector", [ IsPlistVectorRep ],
  function( v )
    Print("NewVector(IsPlistVectorRep");
    if IsCheckingVector(v) then
        Print(" and IsCheckingVector");
    fi;
    if IsFinite(v![BDPOS]) and IsField(v![BDPOS]) then
        Print(",GF(",Size(v![BDPOS]),"),",v![ELSPOS],")");
    else
        Print(",",String(v![BDPOS]),",",v![ELSPOS],")");
    fi;
  end );

InstallMethod( String, "for a plist vector", [ IsPlistVectorRep ],
  function( v )
    local st;
    st := "NewVector(IsPlistVectorRep";
    if IsCheckingVector(v) then
        Append(st," and IsCheckingVector");
    fi;
    if IsFinite(v![BDPOS]) and IsField(v![BDPOS]) then
        Append(st,Concatenation( ",GF(",String(Size(v![BDPOS])),"),",
                                 String(v![ELSPOS]),")" ));
    else
        Append(st,Concatenation( ",",String(v![BDPOS]),",",
                                 String(v![ELSPOS]),")" ));
    fi;
    return st;
  end );

InstallMethod( Display, "for a plist vector", [ IsPlistVectorRep ],
  function( v )
    Print( "<a " );
    if IsCheckingVector(v) then Print( "checking " ); fi;
    Print( "plist vector over ",BaseDomain(v),":\n");
    Print(v![ELSPOS],"\n>\n");
  end );


############################################################################
############################################################################
# Vectors:
############################################################################
############################################################################


############################################################################
# The basic attributes:
############################################################################

InstallMethod( BaseDomain, "for a plist vector", [ IsPlistVectorRep ],
  function( v )
    return v![BDPOS];
  end );

InstallMethod( Length, "for a plist vector", [ IsPlistVectorRep ],
  function( v )
    return Length(v![ELSPOS]);
  end );


############################################################################
# Representation preserving constructors:
############################################################################

InstallMethod( ZeroVector, "for an integer and a plist vector",
  [ IsInt, IsPlistVectorRep ],
  function( l, t )
    local v;
    v := Objectify(TypeObj(t),
                   [t![BDPOS],ListWithIdenticalEntries(l,Zero(t![BDPOS]))]);
    if not IsMutable(v) then SetFilterObj(v,IsMutable); fi;
    return v;
  end );

InstallMethod( ZeroVector, "for an integer and a plist matrix",
  [ IsInt, IsPlistMatrixRep ],
  function( l, m )
    local v;
    v := Objectify(TypeObj(m![EMPOS]),
                   [m![BDPOS],ListWithIdenticalEntries(l,Zero(m![BDPOS]))]);
    if not IsMutable(v) then SetFilterObj(v,IsMutable); fi;
    return v;
  end );

InstallMethod( Vector, "for a plain list and a plist vector",
  [ IsList and IsPlistRep, IsPlistVectorRep ],
  function( l, t )
    local v;
    v := Objectify(TypeObj(t),[t![BDPOS],l]);
    if not IsMutable(v) then SetFilterObj(v,IsMutable); fi;
    return v;
  end );

InstallMethod( Vector, "for a list and a plist vector",
  [ IsList, IsPlistVectorRep ],
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

InstallMethod( \[\], "for a plist vector and a positive integer",
  [ IsPlistVectorRep, IsPosInt ],
  function( v, p )
    return v![ELSPOS][p];
  end );

InstallMethod( \[\]\:\=,
  "for a checking plist vector, a positive integer, and an obj",
  [ IsPlistVectorRep and IsCheckingVector, IsPosInt, IsObject ],
  function( v, p, ob )
    if p > Length(v![ELSPOS]) then
        Error("\\[\\]\\:\\=: Assignment out of bounds!");
        return;
    fi;
    if not ob in v![BDPOS] then
        Error("\\[\\]\\:\\=: Object to be assigned is not in base domain");
        return;
    fi;
    v![ELSPOS][p] := ob;
  end );

InstallMethod( \[\]\:\=, "for a plist vector, a positive integer, and an obj",
  [ IsPlistVectorRep, IsPosInt, IsObject ],
  function( v, p, ob )
    v![ELSPOS][p] := ob;
  end );

InstallMethod( \{\}, "for a plist vector and a list",
  [ IsPlistVectorRep, IsList ],
  function( v, l )
    return Objectify(TypeObj(v),[v![BDPOS],v![ELSPOS]{l}]);
  end );

InstallMethod( PositionNonZero, "for a plist vector", [ IsPlistVectorRep ],
  function( v )
    return PositionNonZero( v![ELSPOS] );
  end );

InstallMethod( PositionLastNonZero, "for a plist vector", [ IsPlistVectorRep ],
  function( v )
    local els,i;
    els := v![ELSPOS];
    i := Length(els);
    while i > 0 and IsZero(els[i]) do i := i - 1; od;
    if i > 0 then
        return i;
    else
        return fail;
    fi;
  end );

InstallMethod( ListOp, "for a plist vector", [ IsPlistVectorRep ],
  function( v )
    return v![ELSPOS]{[1..Length(v![ELSPOS])]};
  end );

InstallMethod( ListOp, "for a plist vector and a function",
  [ IsPlistVectorRep, IsFunction ],
  function( v, f )
    return List(v![ELSPOS],f);
  end );

InstallMethod( Unpack, "for a plist vector",
  [ IsPlistVectorRep ],
  function( v )
    return ShallowCopy(v![ELSPOS]);
  end );


############################################################################
# Standard operations for all objects:
############################################################################

InstallMethod( ShallowCopy, "for a plist vector", [ IsPlistVectorRep ],
  function( v )
    local res;
    res := Objectify(TypeObj(v),[v![BDPOS],ShallowCopy(v![ELSPOS])]);
    if not IsMutable(v) then SetFilterObj(res,IsMutable); fi;
    return res;
  end );

# StructuralCopy works automatically

InstallMethod( PostMakeImmutable, "for a plist vector", [ IsPlistVectorRep ],
  function( v )
    MakeImmutable( v![ELSPOS] );
  end );


############################################################################
# Arithmetical operations:
############################################################################

InstallMethod( \+, "for two plist vectors",
  [ IsPlistVectorRep, IsPlistVectorRep ],
  function( a, b )
    local ty;
    if not IsMutable(a) and IsMutable(b) then
        ty := TypeObj(b);
    else
        ty := TypeObj(a);
    fi;
    return Objectify(ty,
                     [a![BDPOS],SUM_LIST_LIST_DEFAULT(a![ELSPOS],b![ELSPOS])]);
  end );

InstallMethod( \+, "for two checking plist vectors",
  [ IsPlistVectorRep and IsCheckingVector,
    IsPlistVectorRep and IsCheckingVector],
  function( a, b )
    local ty;
    if Length(a![ELSPOS]) <> Length(b![ELSPOS]) then
        Error("\\+: Cannot add vectors of different length");
        return fail;
    fi;
    if not IsIdenticalObj(a![BDPOS],b![BDPOS]) then
        Error("\\+: Cannot add vectors over different base domains");
        return fail;
    fi;
    if not IsMutable(a) and IsMutable(b) then
        ty := TypeObj(b);
    else
        ty := TypeObj(a);
    fi;
    return Objectify(ty,
                     [a![BDPOS],SUM_LIST_LIST_DEFAULT(a![ELSPOS],b![ELSPOS])]);
  end );

InstallMethod( \-, "for two plist vectors",
  [ IsPlistVectorRep, IsPlistVectorRep ],
  function( a, b )
    local ty;
    if not IsMutable(a) and IsMutable(b) then
        ty := TypeObj(b);
    else
        ty := TypeObj(a);
    fi;
    return Objectify(ty,
                     [a![BDPOS],DIFF_LIST_LIST_DEFAULT(a![ELSPOS],b![ELSPOS])]);
  end );

InstallMethod( \-, "for two checking plist vectors",
  [ IsPlistVectorRep and IsCheckingVector,
    IsPlistVectorRep and IsCheckingVector],
  function( a, b )
    local ty;
    if Length(a![ELSPOS]) <> Length(b![ELSPOS]) then
        Error("\\-: Cannot subtract vectors of different length");
        return fail;
    fi;
    if not IsIdenticalObj(a![BDPOS],b![BDPOS]) then
        Error("\\-: Cannot subtract vectors over different base domains");
        return fail;
    fi;
    if not IsMutable(a) and IsMutable(b) then
        ty := TypeObj(b);
    else
        ty := TypeObj(a);
    fi;
    return Objectify(ty,
                     [a![BDPOS],DIFF_LIST_LIST_DEFAULT(a![ELSPOS],b![ELSPOS])]);
  end );

InstallMethod( \=, "for two plist vectors",
  [ IsPlistVectorRep, IsPlistVectorRep ],
  function( a, b )
    return EQ_LIST_LIST_DEFAULT(a![ELSPOS],b![ELSPOS]);
  end );

InstallMethod( \<, "for two plist vectors",
  [ IsPlistVectorRep, IsPlistVectorRep ],
  function( a, b )
    return LT_LIST_LIST_DEFAULT(a![ELSPOS],b![ELSPOS]);
  end );

InstallMethod( AddRowVector, "for two plist vectors",
  [ IsPlistVectorRep and IsMutable, IsPlistVectorRep ],
  function( a, b )
    ADD_ROW_VECTOR_2( a![ELSPOS], b![ELSPOS] );
  end );

InstallMethod( AddRowVector, "for two checking plist vectors",
  [ IsPlistVectorRep and IsCheckingVector and IsMutable,
    IsPlistVectorRep and IsCheckingVector ],
  function( a, b )
    if Length(a![ELSPOS]) <> Length(b![ELSPOS]) then
        Error("AddRowVector: Cannot add vectors of different length");
        return;
    fi;
    if not IsIdenticalObj(a![BDPOS],b![BDPOS]) then
        Error("AddRowVector: Cannot add vectors over different base domains");
        return;
    fi;
    ADD_ROW_VECTOR_2( a![ELSPOS], b![ELSPOS] );
  end );

# Better method for integer vectors:
InstallMethod( AddRowVector, "for two plist vectors",
  [ IsPlistVectorRep and IsMutable and IsIntVector,
    IsPlistVectorRep and IsIntVector ],
  function( a, b )
    ADD_ROW_VECTOR_2_FAST( a![ELSPOS], b![ELSPOS] );
  end );

InstallMethod( AddRowVector, "for two plist vectors, and a scalar",
  [ IsPlistVectorRep and IsMutable, IsPlistVectorRep, IsObject ],
  function( a, b, s )
    ADD_ROW_VECTOR_3( a![ELSPOS], b![ELSPOS], s );
  end );

InstallMethod( AddRowVector, "for two checking plist vectors, and a scalar",
  [ IsPlistVectorRep and IsCheckingVector and IsMutable,
    IsPlistVectorRep and IsCheckingVector, IsObject ],
  function( a, b, s )
    if Length(a![ELSPOS]) <> Length(b![ELSPOS]) then
        Error("AddRowVector: Cannot subtract vectors of different length");
        return;
    fi;
    if not IsIdenticalObj(a![BDPOS],b![BDPOS]) then
        Error("AddRowVector: Cannot add vectors over different base domains");
        return;
    fi;
    ADD_ROW_VECTOR_3( a![ELSPOS], b![ELSPOS], s );
  end );

# Better method for integer vectors:
InstallMethod( AddRowVector, "for two plist vectors, and a scalar",
  [ IsPlistVectorRep and IsIntVector and IsMutable,
    IsPlistVectorRep and IsIntVector, IsObject ],
  function( a, b, s )
    if IsSmallIntRep(s) then
        ADD_ROW_VECTOR_3_FAST( a![ELSPOS], b![ELSPOS], s );
    else
        ADD_ROW_VECTOR_3( a![ELSPOS], b![ELSPOS], s );
    fi;
  end );

InstallMethod( AddRowVector,
  "for two plist vectors, a scalar, and two positions",
  [ IsPlistVectorRep and IsMutable, IsPlistVectorRep,
    IsObject, IsPosInt, IsPosInt ],
  function( a, b, s, from, to )
    ADD_ROW_VECTOR_5( a![ELSPOS], b![ELSPOS], s, from, to );
  end );

InstallMethod( AddRowVector,
  "for two checking plist vectors, a scalar, and two positions",
  [ IsPlistVectorRep and IsCheckingVector and IsMutable,
    IsPlistVectorRep and IsCheckingVector, IsObject, IsPosInt, IsPosInt ],
  function( a, b, s, from, to )
    if Length(a![ELSPOS]) <> Length(b![ELSPOS]) then
        Error("AddRowVector: Cannot add vectors of different length");
        return;
    fi;
    if not IsIdenticalObj(a![BDPOS],b![BDPOS]) then
        Error("AddRowVector: Cannot add vectors over different base domains");
        return;
    fi;
    ADD_ROW_VECTOR_5( a![ELSPOS], b![ELSPOS], s, from, to );
  end );

# Better method for integer vectors:
InstallMethod( AddRowVector,
  "for two integer plist vectors, a scalar, and two positions",
  [ IsPlistVectorRep and IsIntVector and IsMutable,
    IsPlistVectorRep and IsIntVector, IsObject, IsPosInt, IsPosInt ],
  function( a, b, s, from, to )
    if IsSmallIntRep(s) then
        ADD_ROW_VECTOR_5_FAST( a![ELSPOS], b![ELSPOS], s, from, to );
    else
        ADD_ROW_VECTOR_5( a![ELSPOS], b![ELSPOS], s, from, to );
    fi;
  end );

InstallMethod( MultRowVector, "for a plist vector, and a scalar",
  [ IsPlistVectorRep and IsMutable, IsObject ],
  function( v, s )
    MULT_ROW_VECTOR_2(v![ELSPOS],s);
  end );

InstallMethod( MultRowVector, "for a checking plist vector, and a scalar",
  [ IsPlistVectorRep and IsCheckingVector and IsMutable, IsObject ],
  function( v, s )
    if not s in v![BDPOS] then
        Error("MultRowVector: Scalar is not in base domain");
        return;
    fi;
    MULT_ROW_VECTOR_2(v![ELSPOS],s);
  end );

InstallMethod( MultRowVector, "for a plist vector, and a scalar",
  [ IsPlistVectorRep and IsIntVector and IsMutable, IsObject ],
  function( v, s )
    if IsSmallIntRep(s) then
        MULT_ROW_VECTOR_2_FAST(v![ELSPOS],s);
    else
        MULT_ROW_VECTOR_2(v![ELSPOS],s);
    fi;
  end );

InstallMethod( MultRowVector,
  "for a plist vector, a list, a plist vector, a list, and a scalar",
  [ IsPlistVectorRep and IsMutable, IsList,
    IsPlistVectorRep, IsList, IsObject ],
  function( a, pa, b, pb, s )
    a![ELSPOS]{pa} := b![ELSPOS]{pb} * s;
  end );

InstallMethod( MultRowVector,
  "for a checking plist vector, a list, a ch. plist vector, a list, a scalar",
  [ IsPlistVectorRep and IsCheckingVector and IsMutable, IsList,
    IsPlistVectorRep and IsCheckingVector, IsList, IsObject ],
  function( a, pa, b, pb, s )
    local l;
    l := Length(a![ELSPOS]);
    if not ForAll(pa,x->x >= 1 and x <= l) then
        Error("MultRowVector: Positions pa must lie in first vector");
        return;
    fi;
    if not IsIdenticalObj(a![BDPOS],b![BDPOS]) then
        Error("MultRowVector: Cannot add vectors over different base domains");
        return;
    fi;
    if not s in a![BDPOS] then
        Error("MultRowVector: Scalar not in base domain");
        return;
    fi;
    a![ELSPOS]{pa} := b![ELSPOS]{pb} * s;
  end );

InstallMethod( \*, "for a plist vector and a scalar",
  [ IsPlistVectorRep, IsScalar ],
  function( v, s )
    return Objectify( TypeObj(v),
             [v![BDPOS],PROD_LIST_SCL_DEFAULT(v![ELSPOS],s)] );
  end );

InstallMethod( \*, "for a checking plist vector and a scalar",
  [ IsPlistVectorRep, IsScalar ],
  function( v, s )
    if not s in v![BDPOS] then
        Error("\\*: Scalar not in base domain");
        return;
    fi;
    return Objectify( TypeObj(v),
             [v![BDPOS],PROD_LIST_SCL_DEFAULT(v![ELSPOS],s)] );
  end );

InstallMethod( \*, "for a scalar and a plist vector",
  [ IsScalar, IsPlistVectorRep ],
  function( s, v )
    return Objectify( TypeObj(v),
             [v![BDPOS],PROD_SCL_LIST_DEFAULT(s,v![ELSPOS])] );
  end );

InstallMethod( \*, "for a scalar and a checking plist vector",
  [ IsScalar, IsPlistVectorRep ],
  function( s, v )
    if not s in v![BDPOS] then
        Error("\\*: Scalar not in base domain");
        return;
    fi;
    return Objectify( TypeObj(v),
             [v![BDPOS],PROD_SCL_LIST_DEFAULT(s,v![ELSPOS])] );
  end );

InstallMethod( \/, "for a plist vector and a scalar",
  [ IsPlistVectorRep, IsScalar ],
  function( v, s )
    return Objectify( TypeObj(v),
             [v![BDPOS],PROD_LIST_SCL_DEFAULT(v![ELSPOS],s^-1)] );
  end );

InstallMethod( \/, "for a checking plist vector and a scalar",
  [ IsPlistVectorRep and IsCheckingVector, IsScalar ],
  function( v, s )
    local res;
    if not s in v![BDPOS] then
        Error("\\/: Scalar not in base domain");
        return;
    fi;
    res := Objectify( TypeObj(v),
             [v![BDPOS],PROD_LIST_SCL_DEFAULT(v![ELSPOS],s^-1)] );
    if IsIntVector(v) and not ForAll(res![ELSPOS],IsInt) then
        Error("\\/: Result is not an integer vector");
        return;
    fi;
    return res;
  end );

InstallMethod( AdditiveInverseSameMutability, "for a plist vector",
  [ IsPlistVectorRep ],
  function( v )
    return Objectify( TypeObj(v),
       [v![BDPOS],AdditiveInverseSameMutability(v![ELSPOS])] );
  end );

InstallMethod( AdditiveInverseImmutable, "for a plist vector",
  [ IsPlistVectorRep ],
  function( v )
    local res;
    res := Objectify( TypeObj(v),
       [v![BDPOS],AdditiveInverseSameMutability(v![ELSPOS])] );
    MakeImmutable(res);
    return res;
  end );

InstallMethod( AdditiveInverseMutable, "for a plist vector",
  [ IsPlistVectorRep ],
  function( v )
    local res;
    res := Objectify(TypeObj(v),
                     [v![BDPOS],AdditiveInverseMutable(v![ELSPOS])]);
    if not IsMutable(v) then SetFilterObj(res,IsMutable); fi;
    return res;
  end );

InstallMethod( ZeroSameMutability, "for a plist vector", [ IsPlistVectorRep ],
  function( v )
    return Objectify(TypeObj(v),[v![BDPOS],ZeroSameMutability(v![ELSPOS])]);
  end );

InstallMethod( ZeroImmutable, "for a plist vector", [ IsPlistVectorRep ],
  function( v )
    local res;
    res := Objectify(TypeObj(v),[v![BDPOS],ZeroImmutable(v![ELSPOS])]);
    MakeImmutable(res);
    return res;
  end );

InstallMethod( ZeroMutable, "for a plist vector", [ IsPlistVectorRep ],
  function( v )
    local res;
    res := Objectify(TypeObj(v),
                     [v![BDPOS],ZeroMutable(v![ELSPOS])]);
    if not IsMutable(v) then SetFilterObj(res,IsMutable); fi;
    return res;
  end );

InstallMethod( IsZero, "for a plist vector", [ IsPlistVectorRep ],
  function( v )
    return IsZero( v![ELSPOS] );
  end );

InstallMethod( Randomize, "for a mutable plist vector",
  [ IsPlistVectorRep and IsMutable ],
  function( v )
    local bd,i;
    bd := v![BDPOS];
    for i in [1..Length(v![ELSPOS])] do
        v![ELSPOS][i] := Random(bd);
    od;
  end );

InstallMethod( CopySubVector, "for two plist vectors and two lists",
  [ IsPlistVectorRep, IsPlistVectorRep and IsMutable, IsList, IsList ],
  function( a,b,pa,pb )
    # The following should eventually go into the kernel:
    b![ELSPOS]{pb} := a![ELSPOS]{pa};
  end );

InstallMethod( CopySubVector, "for two plist vectors and two lists",
  [ IsPlistVectorRep, IsPlistVectorRep and IsMutable and IsCheckingVector,
    IsList, IsList ],
  function( a,b,pa,pb )
    if not(ForAll(pb,x->x <= Length(b![ELSPOS]))) then
        Error("CopySubVector: Positions in pb must lie in vector b");
        return;
    fi;
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

InstallMethod( BaseDomain, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    return m![BDPOS];
  end );

InstallMethod( Length, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    return Length(m![ROWSPOS]);
  end );

InstallMethod( RowLength, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    return m![RLPOS];
  end );

InstallMethod( DimensionsMat, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    return [Length(m![ROWSPOS]),m![RLPOS]];
  end );


############################################################################
# Representation preserving constructors:
############################################################################

InstallMethod( ZeroMatrix, "for two integers and a plist matrix",
  [ IsInt, IsInt, IsPlistMatrixRep ],
  function( rows,cols,m )
    local l,t,res;
    t := m![EMPOS];
    l := List([1..rows],i->ZeroVector(cols,t));
    res := Objectify( TypeObj(m), [m![BDPOS],t,cols,l] );
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
    return res;
  end );

InstallMethod( IdentityMatrix, "for an integer and a plist matrix",
  [ IsInt, IsPlistMatrixRep ],
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

InstallMethod( Matrix, "for a list and a plist matrix",
  [ IsList, IsInt, IsPlistMatrixRep ],
  function( rows,rowlen,m )
    local i,l,nrrows,res,t;
    t := m![EMPOS];
    if Length(rows) > 0 then
        if IsVectorObj(rows[1]) and IsPlistVectorRep(rows[1]) then
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
# A selection of list operations:
############################################################################

InstallMethod( \[\], "for a plist matrix and a positive integer",
  [ IsPlistMatrixRep, IsPosInt ],
  function( m, p )
    return m![ROWSPOS][p];
  end );

InstallMethod( \[\]\:\=,
  "for a plist matrix, a positive integer, and a plist vector",
  [ IsPlistMatrixRep and IsMutable, IsPosInt, IsPlistVectorRep ],
  function( m, p, v )
    m![ROWSPOS][p] := v;
  end );

InstallMethod( \[\]\:\=,
  "for a checking plist matrix, a positive integer, and a plist vector",
  [ IsPlistMatrixRep and IsCheckingMatrix and IsMutable,
    IsPosInt, IsPlistVectorRep ],
  function( m, p, v )
    if p > Length(m![ROWSPOS])+1 then
        Error("\\[\\]\\:\\=: Matrices must be dense, you cannot assign here");
        return;
    fi;
    if not IsIdenticalObj(m![BDPOS],v![BDPOS]) then
        Error("\\[\\]\\:\\=: Vector and matrix must be over the same base domain");
        return;
    fi;
    if not m![RLPOS] = Length(v![ELSPOS]) then
        Error("\\[\\]\\:\\=: Vector does not have the right length");
        return;
    fi;
    m![ROWSPOS][p] := v;
  end );

InstallMethod( \{\}, "for a plist matrix and a list",
  [ IsPlistMatrixRep, IsList ],
  function( m, p )
    local l;
    l := m![ROWSPOS]{p};
    return Objectify(TypeObj(m),[m![BDPOS],m![EMPOS],m![RLPOS],l]);
  end );

InstallMethod( Add, "for a plist matrix and a plist vector",
  [ IsPlistMatrixRep and IsMutable, IsPlistVectorRep ],
  function( m, v )
    Add(m![ROWSPOS],v);
  end );

InstallMethod( Add, "for a checking plist matrix and a plist vector",
  [ IsPlistMatrixRep and IsCheckingMatrix and IsMutable,
    IsPlistVectorRep ],
  function( m, v )
    if not IsIdenticalObj(m![BDPOS],v![BDPOS]) then
        Error("Add: Vector and matrix must be over the same base domain");
        return;
    fi;
    if not m![RLPOS] = Length(v![ELSPOS]) then
        Error("Add: Vector does not have the right length");
        return;
    fi;
    Add(m![ROWSPOS],v);
  end );

InstallMethod( Add, "for a plist matrix, a plist vector, and a pos. int",
  [ IsPlistMatrixRep and IsMutable, IsPlistVectorRep, IsPosInt ],
  function( m, v, p )
    Add(m![ROWSPOS],v,p);
  end );

InstallMethod( Add, "for a checking plist matrix, a plist vector, and a pos",
  [ IsPlistMatrixRep and IsMutable and IsCheckingMatrix,
    IsPlistVectorRep, IsPosInt ],
  function( m, v, p )
    if p > Length(m![ROWSPOS])+1 then
        Error("Add: Matrices must be dense, you cannot assign here");
        return;
    fi;
    if not IsIdenticalObj(m![BDPOS],v![BDPOS]) then
        Error("Add: Vector and matrix must be over the same base domain");
        return;
    fi;
    if not m![RLPOS] = Length(v![ELSPOS]) then
        Error("Add: Vector does not have the right length");
        return;
    fi;
    Add(m![ROWSPOS],v,p);
  end );

InstallMethod( Remove, "for a plist matrix",
  [ IsPlistMatrixRep and IsMutable ],
  function( m )
    Remove( m![ROWSPOS] );
  end );

InstallMethod( Remove, "for a plist matrix, and a position",
  [ IsPlistMatrixRep and IsMutable, IsPosInt ],
  function( m, p )
    Remove( m![ROWSPOS],p );
  end );

InstallMethod( IsBound\[\], "for a plist matrix, and a position",
  [ IsPlistMatrixRep, IsPosInt ],
  function( m, p )
    return p <= Length(m![ROWSPOS]);
  end );

InstallMethod( Unbind\[\], "for a plist matrix, and a position",
  [ IsPlistMatrixRep and IsMutable, IsPosInt ],
  function( m, p )
    if p <> Length(m![ROWSPOS]) then
        Error("Unbind\\[\\]: Matrices must stay dense, you cannot Unbind here");
        return;
    fi;
    Unbind( m![ROWSPOS][p] );
  end );

InstallMethod( \{\}\:\=, "for a plist matrix, a list, and a plist matrix",
  [ IsPlistMatrixRep and IsMutable, IsList,
    IsPlistMatrixRep ],
  function( m, pp, n )
    m![ROWSPOS]{pp} := n![ROWSPOS];
  end );

InstallMethod( \{\}\:\=,
  "for a checking plist matrix, a list, and a plist matrix",
  [ IsPlistMatrixRep and IsMutable and IsCheckingMatrix, IsList,
    IsPlistMatrixRep ],
  function( m, pp, n )
    if not(ForAll(pp,x->x >= 1 and x <= Length(m![ROWSPOS])+1)) then
        Error("\\{\\}\\:\\=: Positions must be in the matrix");
        return;
    fi;
    if not IsIdenticalObj(m![BDPOS],n![BDPOS]) then
        Error("\\{\\}\\:\\=: Both matrices must be over the same base domain");
        return;
    fi;
    if not m![RLPOS] = n![RLPOS] then
        Error("\\{\\}\\:\\=: Row lengths are not equal");
        return;
    fi;
    m![ROWSPOS]{pp} := n![ROWSPOS];
  end );

InstallMethod( Append, "for two plist matrices",
  [ IsPlistMatrixRep and IsMutable, IsPlistMatrixRep ],
  function( m, n )
    Append(m![ROWSPOS],n![ROWSPOS]);
  end );

InstallMethod( Append, "for a checking plist matrix, and a plist matrix",
  [ IsPlistMatrixRep and IsMutable and IsCheckingMatrix,
    IsPlistMatrixRep ],
  function( m, n )
    if not IsIdenticalObj(m![BDPOS],n![BDPOS]) then
        Error("Append: Both matrices must be over the same base domain");
        return;
    fi;
    if not m![RLPOS] = n![RLPOS] then
        Error("Append: Row lengths are not equal");
        return;
    fi;
    Append(m![ROWSPOS],n![ROWSPOS]);
  end );

InstallMethod( ShallowCopy, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local res;
    res := Objectify(TypeObj(m),[m![BDPOS],m![EMPOS],m![RLPOS],
                                 ShallowCopy(m![ROWSPOS])]);
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
    return res;
  end );

InstallMethod( PostMakeImmutable, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    MakeImmutable( m![ROWSPOS] );
  end );

InstallMethod( ListOp, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    return List(m![ROWSPOS]);
  end );

InstallMethod( ListOp, "for a plist matrix and a function",
  [ IsPlistMatrixRep, IsFunction ],
  function( m, f )
    return List(m![ROWSPOS],f);
  end );

InstallMethod( Unpack, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    return List(m![ROWSPOS],v->ShallowCopy(v![ELSPOS]));
  end );

# InstallMethod( PositionNonZero, "for a plist matrix",
#   [ IsPlistMatrixRep ],
#   function( m )
#     local i,l,le;
#     l := m![ROWSPOS];
#     le := Length(l);
#     i := 1;
#     while i <= le and IsZero(l[i]) do i := i + 1; od;
#     return i;
#   end );
# 
# InstallMethod( PositionNonZero, "for a plist matrix, and a position",
#   [ IsPlistMatrixRep, IsInt ],
#   function( m, p )
#     local i,l,le;
#     l := m![ROWSPOS];
#     le := Length(l);
#     i := p+1;
#     while i <= le and IsZero(l[i]) do i := i + 1; od;
#     if i > le+1 then
#         return le+1;
#     else
#         return i;
#     fi;
#   end );
# 
# InstallMethod( PositionLastNonZero, "for a plist matrix",
#   [ IsPlistMatrixRep ],
#   function( m )
#     local i,l,le;
#     l := m![ROWSPOS];
#     le := Length(l);
#     i := le;
#     while i >= 1 and IsZero(l[i]) do i := i - 1; od;
#     return i;
#   end );
# 
# InstallMethod( PositionLastNonZero, "for a plist matrix, and a position",
#   [ IsPlistMatrixRep, IsInt ],
#   function( m, p )
#     local i,l,le;
#     l := m![ROWSPOS];
#     le := Length(l);
#     i := p-1;
#     while i >= 1 and IsZero(l[i]) do i := i - 1; od;
#     if i < 0 then
#         return 0;
#     else
#         return i;
#     fi;
#   end );
# 
# InstallMethod( Position, "for a plist matrix, and a plist vector",
#   [ IsPlistMatrixRep, IsPlistVectorRep ],
#   function( m, v )
#     local i,l,le;
#     l := m![ROWSPOS];
#     le := Length(l);
#     i := 1;
#     while i <= le and l[i] <> v do i := i + 1; od;
#     if i > le then
#         return fail;
#     else
#         return i;
#     fi;
#   end );
# 
# InstallMethod( Position, "for a plist matrix, and a plist vector",
#   [ IsPlistMatrixRep, IsPlistVectorRep, IsInt ],
#   function( m, v, p )
#     local i,l,le;
#     l := m![ROWSPOS];
#     le := Length(l);
#     i := p+1;
#     while i <= le and l[i] <> v do i := i + 1; od;
#     if i > le then
#         return fail;
#     else
#         return i;
#     fi;
#   end );
# 
# InstallMethod( PositionSortedOp, "for a plist matrix, and a plist vector",
#   [ IsPlistMatrixRep, IsPlistVectorRep ],
#   function( m, v )
#     return POSITION_SORTED_LIST(m![ROWSPOS],v);
#   end );
# 
# InstallMethod( PositionSortedOp, "for a plist matrix, and a plist vector",
#   [ IsPlistMatrixRep, IsPlistVectorRep, IsFunction ],
#   function( m, v, f )
#     return POSITION_SORTED_LIST_COMP(m![ROWSPOS],v);
#   end );

InstallMethod( MutableCopyMat, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local l,res;
    l := List(m![ROWSPOS],ShallowCopy);
    res := Objectify(TypeObj(m),[m![BDPOS],m![EMPOS],m![RLPOS],l]);
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
    return res;
  end);

InstallMethod( ExtractSubMatrix, "for a plist matrix, and two lists",
  [ IsPlistMatrixRep, IsList, IsList ],
  function( m, p, q )
    local i,l;
    l := m![ROWSPOS]{p};
    for i in [1..Length(l)] do
        l[i] := Objectify(TypeObj(l[i]),[l[i]![BDPOS],l[i]![ELSPOS]{q}]);
    od;
    return Objectify(TypeObj(m),[m![BDPOS],m![EMPOS],Length(q),l]);
  end );

InstallMethod( CopySubMatrix, "for two plist matrices and four lists",
  [ IsPlistMatrixRep, IsPlistMatrixRep and IsMutable,
    IsList, IsList, IsList, IsList ],
  function( m, n, srcrows, dstrows, srccols, dstcols )
    local i;
    # This eventually should go into the kernel without creating
    # a intermediate objects:
    for i in [1..Length(srcrows)] do
        n![ROWSPOS][dstrows[i]]![ELSPOS]{dstcols} :=
                  m![ROWSPOS][srcrows[i]]![ELSPOS]{srccols};
    od;
  end );

InstallOtherMethod( CopySubMatrix,
  "for two plists -- fallback in case of bad rep.",
  [ IsPlistRep, IsPlistRep and IsMutable,
    IsList, IsList, IsList, IsList ],
  function( m, n, srcrows, dstrows, srccols, dstcols )
    local i;
    # in this representation all access probably has to go through the
    # generic method selection, so it is not clear whether there is an
    # improvement in moving this into the kernel.
    for i in [1..Length(srcrows)] do
        n[dstrows[i]]{dstcols}:=m[srcrows[i]]{srccols};
    od;
  end );

InstallMethod( CopySubMatrix,
  "for a plist matrix and a checking plist matrix and four lists",
  [ IsPlistMatrixRep,
    IsPlistMatrixRep and IsCheckingMatrix and IsMutable,
    IsList, IsList, IsList, IsList ],
  function( m, n, srcrows, dstrows, srccols, dstcols )
    local i;
    if not ForAll(dstcols,x->x <= n![RLPOS]) then
        Error("CopySubMatrix: Destination column positions out of range");
        return;
    fi;
    if not(ForAll(dstcols,x->x <= Length(n![ROWSPOS])+1)) then
        Error("CopySubMatrix: Destination row positions out of range");
        return;
    fi;
    for i in [1..Length(srcrows)] do
        n![ROWSPOS][dstrows[i]]![ELSPOS]{dstcols} :=
                  m![ROWSPOS][srcrows[i]]![ELSPOS]{srccols};
    od;
  end );

InstallMethod( MatElm, "for a plist matrix and two positions",
  [ IsPlistMatrixRep, IsPosInt, IsPosInt ],
  function( m, row, col )
    return m![ROWSPOS][row]![ELSPOS][col];
  end );

InstallMethod( SetMatElm, "for a plist matrix, two positions, and an object",
  [ IsPlistMatrixRep and IsMutable, IsPosInt, IsPosInt, IsObject ],
  function( m, row, col, ob )
    m![ROWSPOS][row]![ELSPOS][col] := ob;
  end );

InstallMethod( SetMatElm,
  "for a checking plist matrix, two positions, and an object",
  [ IsPlistMatrixRep and IsCheckingMatrix and IsMutable,
    IsPosInt, IsPosInt, IsObject ],
  function( m, row, col, ob )
    if row > Length( m![ROWSPOS] ) or col > m![RLPOS] then
        Error("SetMatElm: Row or column number out of bounds");
        return;
    fi;
    if not  ob in m![BDPOS]  then
        Error("SetMatElm: Value to be assigned is not in base domain");
        return;
    fi;
    m![ROWSPOS][row]![ELSPOS][col] := ob;
  end );


############################################################################
# Printing and viewing methods:
############################################################################

InstallMethod( ViewObj, "for a plist matrix", [ IsPlistMatrixRep ],
  function( m )
    Print("<");
    if IsCheckingMatrix(m) then Print("checking "); fi;
    if not IsMutable(m) then Print("immutable "); fi;
    Print(Length(m![ROWSPOS]),"x",m![RLPOS],"-matrix over ",m![BDPOS],">");
  end );

InstallMethod( PrintObj, "for a plist matrix", [ IsPlistMatrixRep ],
  function( m )
    Print("NewMatrix(IsPlistMatrixRep");
    if IsCheckingMatrix(m) then
        Print(" and IsCheckingMatrix");
    fi;
    if IsFinite(m![BDPOS]) and IsField(m![BDPOS]) then
        Print(",GF(",Size(m![BDPOS]),"),");
    else
        Print(",",String(m![BDPOS]),",");
    fi;
    Print(RowLength(m),",",Unpack(m),")");
  end );

InstallMethod( Display, "for a plist matrix", [ IsPlistMatrixRep ],
  function( m )
    local i;
    Print("<");
    if IsCheckingMatrix(m) then Print("checking "); fi;
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

InstallMethod( String, "for plist matrix", [ IsPlistMatrixRep ],
  function( m )
    local st;
    st := "NewMatrix(IsPlistMatrixRep";
    if IsCheckingMatrix(m) then
        Append(st," and IsCheckingMatrix");
    fi;
    Add(st,',');
    if IsFinite(m![BDPOS]) and IsField(m![BDPOS]) then
        Append(st,"GF(");
        Append(st,String(Size(m![BDPOS])));
        Append(st,"),");
    else
        Append(st,String(m![BDPOS]));
        Append(st,",");
    fi;
    Append(st,String(RowLength(m)));
    Add(st,',');
    Append(st,String(Unpack(m)));
    Add(st,')');
    return st;
  end );

############################################################################
# Arithmetical operations:
############################################################################

InstallMethod( \+, "for two plist matrices",
  [ IsPlistMatrixRep, IsPlistMatrixRep ],
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

InstallMethod( \+, "for two checking plist matrices",
  [ IsPlistMatrixRep and IsCheckingMatrix,
    IsPlistMatrixRep and IsCheckingMatrix ],
  function( a, b )
    local ty;
    if Length(a![ROWSPOS]) <> Length(b![ROWSPOS]) or
       a![RLPOS] <> b![RLPOS] then
        Error("\\+: Dimensions do not fit together");
        return;
    fi;
    if not IsIdenticalObj(a![BDPOS],b![BDPOS]) then
        Error("\\+: BaseDomains are not the same");
        return;
    fi;
    if not IsMutable(a) and IsMutable(b) then
        ty := TypeObj(b);
    else
        ty := TypeObj(a);
    fi;
    return Objectify(ty,[a![BDPOS],a![EMPOS],a![RLPOS],
                         SUM_LIST_LIST_DEFAULT(a![ROWSPOS],b![ROWSPOS])]);
  end );

InstallMethod( \-, "for two plist matrices",
  [ IsPlistMatrixRep, IsPlistMatrixRep ],
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

InstallMethod( \-, "for two checking plist matrices",
  [ IsPlistMatrixRep and IsCheckingMatrix,
    IsPlistMatrixRep and IsCheckingMatrix ],
  function( a, b )
    local ty;
    if Length(a![ROWSPOS]) <> Length(b![ROWSPOS]) or
       a![RLPOS] <> b![RLPOS] then
        Error("\\-: Dimensions do not fit together");
        return;
    fi;
    if not IsIdenticalObj(a![BDPOS],b![BDPOS]) then
        Error("\\-: BaseDomains are not the same");
        return;
    fi;
    if not IsMutable(a) and IsMutable(b) then
        ty := TypeObj(b);
    else
        ty := TypeObj(a);
    fi;
    return Objectify(ty,[a![BDPOS],a![EMPOS],a![RLPOS],
                         DIFF_LIST_LIST_DEFAULT(a![ROWSPOS],b![ROWSPOS])]);
  end );

InstallMethod( \*, "for two plist matrices",
  [ IsPlistMatrixRep, IsPlistMatrixRep ],
  function( a, b )
    # Here we do full checking since it is rather cheap!
    local i,j,l,ty,v,w;
    if not IsMutable(a) and IsMutable(b) then
        ty := TypeObj(b);
    else
        ty := TypeObj(a);
    fi;
    if not a![RLPOS] = Length(b![ROWSPOS]) then
        Error("\\*: Matrices do not fit together");
        return;
    fi;
    if not IsIdenticalObj(a![BDPOS],b![BDPOS]) then
        Error("\\*: Matrices not over same base domain");
        return;
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
    return Objectify( ty, [a![BDPOS],a![EMPOS],b![RLPOS],l] );
  end );

InstallMethod( \=, "for two plist matrices",
  [ IsPlistMatrixRep, IsPlistMatrixRep ],
  function( a, b )
    return EQ_LIST_LIST_DEFAULT(a![ROWSPOS],b![ROWSPOS]);
  end );

InstallMethod( \<, "for two plist matrices",
  [ IsPlistMatrixRep, IsPlistMatrixRep ],
  function( a, b )
    return LT_LIST_LIST_DEFAULT(a![ROWSPOS],b![ROWSPOS]);
  end );

InstallMethod( AdditiveInverseSameMutability, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local l;
    l := List(m![ROWSPOS],AdditiveInverseSameMutability);
    if not IsMutable(m) then
        MakeImmutable(l);
    fi;
    return Objectify( TypeObj(m), [m![BDPOS],m![EMPOS],m![RLPOS],l] );
  end );

InstallMethod( AdditiveInverseImmutable, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local l,res;
    l := List(m![ROWSPOS],AdditiveInverseImmutable);
    res := Objectify( TypeObj(m), [m![BDPOS],m![EMPOS],m![RLPOS],l] );
    MakeImmutable(res);
    return res;
  end );

InstallMethod( AdditiveInverseMutable, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local l,res;
    l := List(m![ROWSPOS],AdditiveInverseMutable);
    res := Objectify( TypeObj(m), [m![BDPOS],m![EMPOS],m![RLPOS],l] );
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
    return res;
  end );

InstallMethod( ZeroSameMutability, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local l;
    l := List(m![ROWSPOS],ZeroSameMutability);
    if not IsMutable(m) then
        MakeImmutable(l);
    fi;
    return Objectify( TypeObj(m), [m![BDPOS],m![EMPOS],m![RLPOS],l] );
  end );

InstallMethod( ZeroImmutable, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local l,res;
    l := List(m![ROWSPOS],ZeroImmutable);
    res := Objectify( TypeObj(m), [m![BDPOS],m![EMPOS],m![RLPOS],l] );
    MakeImmutable(res);
    return res;
  end );

InstallMethod( ZeroMutable, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local l,res;
    l := List(m![ROWSPOS],ZeroMutable);
    res := Objectify( TypeObj(m), [m![BDPOS],m![EMPOS],m![RLPOS],l] );
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
    return res;
  end );

InstallMethod( IsZero, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local i;
    for i in [1..Length(m![ROWSPOS])] do
        if not IsZero(m![ROWSPOS][i]) then
            return false;
        fi;
    od;
    return true;
  end );

InstallMethod( IsOne, "for a plist matrix",
  [ IsPlistMatrixRep ],
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

InstallMethod( OneSameMutability, "for a plist matrix",
  [ IsPlistMatrixRep ],
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

InstallMethod( OneMutable, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    if m![RLPOS] <> Length(m![ROWSPOS]) then
        #Error("OneMutable: Matrix is not square");
        #return;
        return fail;
    fi;
    return IdentityMatrix(m![RLPOS],m);
  end );

InstallMethod( OneImmutable, "for a plist matrix",
  [ IsPlistMatrixRep ],
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

InstallMethod( InverseMutable, "for a plist matrix",
  [ IsPlistMatrixRep ],
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

InstallMethod( InverseImmutable, "for a plist matrix",
  [ IsPlistMatrixRep ],
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
    n := Matrix(n,Length(n),m);
    MakeImmutable(n);
    return n;
  end );

InstallMethod( InverseSameMutability, "for a plist matrix",
  [ IsPlistMatrixRep ],
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
    n := Matrix(n,Length(n),m);
    if not IsMutable(m) then
        MakeImmutable(n);
    fi;
    return n;
  end );

InstallMethod( RankMat, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local n;

    n := List(m![ROWSPOS],x->x![ELSPOS]);
    return RankMat(n);
  end);


InstallMethod( Randomize, "for a mutable plist matrix",
  [ IsPlistMatrixRep and IsMutable ],
  function( m )
    local v;
    for v in m![ROWSPOS] do
        Randomize(v);
    od;
  end );

InstallMethod( IsDiagonalMat, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local i,j,l,n;
    if m![RLPOS] <> Length(m![ROWSPOS]) then
        Error("IsDiagonalMat: Matrix not square");
        return;
    fi;
    n := m![RLPOS];
    for i in [1..n] do
        l := m![ROWSPOS][i]![ELSPOS];
        for j in [1..i-1] do
            if not IsZero(l[j]) then
                return false;
            fi;
        od;
        for j in [i+1..n] do
            if not IsZero(l[j]) then
                return false;
            fi;
        od;
    od;
    return true;
  end );

InstallMethod( IsLowerTriangularMat, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local i,j,l,n;
    if m![RLPOS] <> Length(m![ROWSPOS]) then
        Error("IsLowerTriangularMat: Matrix not square");
        return;
    fi;
    n := m![RLPOS];
    for i in [1..n] do
        l := m![ROWSPOS][i]![ELSPOS];
        for j in [i+1..n] do
            if not IsZero(l[j]) then
                return false;
            fi;
        od;
    od;
    return true;
  end );

InstallMethod( IsUpperTriangularMat, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local i,j,l,n;
    if m![RLPOS] <> Length(m![ROWSPOS]) then
        Error("IsUpperTriangularMat: Matrix not square");
        return;
    fi;
    n := m![RLPOS];
    for i in [1..n] do
        l := m![ROWSPOS][i]![ELSPOS];
        for j in [1..i-1] do
            if not IsZero(l[j]) then
                return false;
            fi;
        od;
    od;
    return true;
  end );

InstallMethod( TransposedMatMutable, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local i,n,v;
    n := ListWithIdenticalEntries(m![RLPOS],0);
    for i in [1..m![RLPOS]] do
        v := Vector(List(m![ROWSPOS],v->v![ELSPOS][i]),m![EMPOS]);
        n[i] := v;
    od;
    return Objectify(TypeObj(m),[m![BDPOS],m![EMPOS],Length(m![ROWSPOS]),n]);
  end );

InstallMethod( TransposedMatImmutable, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local n;
    n := TransposedMatMutable(m);
    MakeImmutable(n);
    return n;
  end );

InstallMethod( \*, "for a plist vector and a plist matrix",
  [ IsPlistVectorRep, IsPlistMatrixRep ],
  function( v, m )
    local i,res,s;
    res := ZeroVector(m![RLPOS],m![EMPOS]);
    for i in [1..Length(v![ELSPOS])] do
        s := v![ELSPOS][i];
        if not IsZero(s) then
            AddRowVector(res,m![ROWSPOS][i],v![ELSPOS][i]);
        fi;
    od;
    if not IsMutable(v) and not IsMutable(m) then
        MakeImmutable(res);
    fi;
    return res;
  end );

InstallMethod( Unfold, "for a plist matrix",
  [ IsPlistMatrixRep, IsPlistVectorRep ],
  function( m, w )
    local v,i,l;
    if Length(m![ROWSPOS]) = 0 then
        return ShallowCopy(m![EMPOS]);
    else
        l := m![RLPOS];
        v := ZeroVector(Length(m![ROWSPOS])*l,m![EMPOS]);
        for i in [1..Length(m![ROWSPOS])] do
            CopySubVector( m![ROWSPOS][i], v, [1..l], [(i-1)*l+1..i*l] );
        od;
        return v;
    fi;
  end );

InstallMethod( Fold, "for a plist vector, a positive int, and a plist matrix",
  [ IsPlistVectorRep, IsPosInt, IsPlistMatrixRep ],
  function( v, rl, t )
    local rows,i,tt,m;
    m := Matrix([],rl,t);
    tt := ZeroVector(rl,v);
    for i in [1..Length(v![ELSPOS])/rl] do
        Add(m![ROWSPOS],v{[(i-1)*rl+1..i*rl]});
    od;
    return m;
  end );


#InstallMethod( \^, "for a plist vector and an integer",
#  [ IsPlistMatrixRep, IsInt ],
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

InstallMethod( ConstructingFilter, "for a checking plist vector",
  [ IsPlistVectorRep and IsCheckingVector ],
  function( v )
    return IsPlistVectorRep and IsCheckingVector;
  end );

InstallMethod( ConstructingFilter, "for a checking plist matrix",
  [ IsPlistMatrixRep and IsCheckingMatrix ],
  function( m )
    return IsPlistMatrixRep and IsCheckingMatrix;
  end );

InstallMethod( ConstructingFilter, "for a plist vector",
  [ IsPlistVectorRep ],
  function( v )
    return IsPlistVectorRep;
  end );

InstallMethod( ConstructingFilter, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    return IsPlistMatrixRep;
  end );

InstallMethod( ChangedBaseDomain, "for a plist vector, and a domain",
  [ IsPlistVectorRep, IsRing ],
  function( v, r )
    return NewVector( IsPlistVectorRep, r, v![ELSPOS] );
  end );

InstallMethod( ChangedBaseDomain, "for a checking plist vector, and a domain",
  [ IsPlistVectorRep and IsCheckingVector, IsRing ],
  function( v, r )
    return NewVector(IsPlistVectorRep and IsCheckingVector, r, v![ELSPOS]);
  end );

InstallMethod( ChangedBaseDomain, "for a plist matrix, and a domain",
  [ IsPlistMatrixRep, IsRing ],
  function( m, r )
    return NewMatrix(IsPlistMatrixRep, r, RowLength(m),
                     List(m![ROWSPOS], x-> x![ELSPOS]));
  end );

InstallMethod( ChangedBaseDomain, "for a checking plist matrix, and a domain",
  [ IsPlistMatrixRep and IsCheckingMatrix, IsRing ],
  function( m, r )
    return NewMatrix(IsPlistMatrixRep and IsCheckingMatrix, r, RowLength(m),
                     List(m![ROWSPOS], x-> x![ELSPOS]));
  end );

InstallMethod( CompatibleVector, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( v )
    return NewZeroVector(IsPlistVectorRep,BaseDomain(v),NumberRows(v));
  end );

InstallMethod( NewCompanionMatrix,
  "for IsPlistMatrixRep, a polynomial and a ring",
  [ IsPlistMatrixRep, IsUnivariatePolynomial, IsRing ],
  function( ty, po, bd )
    local i,l,ll,n,one;
    one := One(bd);
    l := CoefficientsOfUnivariatePolynomial(po);
    n := Length(l)-1;
    if not IsOne(l[n+1]) then
        Error("CompanionMatrix: polynomial is not monic");
        return fail;
    fi;
    ll := NewMatrix(ty,bd,n,[]);
    l := Vector(-l{[1..n]},CompatibleVector(ll));
    for i in [1..n-1] do
        Add(ll,ZeroMutable(l));
        ll[i][i+1] := one;
    od;
    Add(ll,l);
    return ll;
  end );

InstallMethod( NewCompanionMatrix,
  "for IsPlistMatrixRep and IsCheckingMatrix, a polynomial and a ring",
  [ IsPlistMatrixRep and IsCheckingMatrix, IsUnivariatePolynomial, IsRing ],
  function( ty, po, bd )
    local i,l,ll,n,one;
    one := One(bd);
    l := CoefficientsOfUnivariatePolynomial(po);
    n := Length(l)-1;
    if not IsOne(l[n+1]) then
        Error("CompanionMatrix: polynomial is not monic");
        return fail;
    fi;
    ll := NewMatrix(ty,bd,n,[]);
    l := Vector(-l{[1..n]},CompatibleVector(ll));
    for i in [1..n-1] do
        Add(ll,ZeroMutable(l));
        ll[i][i+1] := one;
    od;
    Add(ll,l);
    return ll;
  end );
