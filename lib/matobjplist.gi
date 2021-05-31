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
  function( basedomain, list )
    local filter, typ;
    filter := IsPlistVectorRep and IsMutable;
    if HasCanEasilyCompareElements(Representative(basedomain)) and
       CanEasilyCompareElements(Representative(basedomain)) then
        filter := filter and CanEasilyCompareElements;
    fi;
    if IsIdenticalObj(basedomain, Integers) then
        filter := filter and IsIntVector;
    elif IsFinite(basedomain) and IsField(basedomain) then
        filter := filter and IsFFEVector;
    fi;
    typ := NewType(FamilyObj(basedomain), filter);
    return Objectify(typ, [ basedomain, list ]);
  end );


InstallMethod( NewVector, "for IsPlistVectorRep, a semiring, and a list",
  [ IsPlistVectorRep, IsSemiring, IsList ],
  function( filter, basedomain, list )
    list := ShallowCopy( list );
    return MakeIsPlistVectorRep( basedomain, list );
  end );

InstallMethod( NewZeroVector, "for IsPlistVectorRep, a semiring, and an int",
  [ IsPlistVectorRep, IsSemiring, IsInt ],
  function( filter, basedomain, len )
    local list;
    list := ListWithIdenticalEntries(len, Zero(basedomain));
    return MakeIsPlistVectorRep( basedomain, list );
  end );

InstallMethod( NewMatrix,
  "for IsPlistMatrixRep, a semiring, an int, and a list",
  [ IsPlistMatrixRep, IsSemiring, IsInt, IsList ],
  function( filter, basedomain, ncols, l )
    local m;
    # If applicable then replace a flat list 'l' by a nested list
    # of lists of length 'ncols'.
    if Length(l) = 0 then
      # empty matrix
      m := [];
    elif IsVectorObj(l[1]) then
      # list of vectors
      # TODO: convert each IsVectorObj to a plist
      m := List(l, PlainListCopy);
    else
      if NestingDepthA(l) mod 2 = 1 then
        if Length(l) mod ncols <> 0 then
          Error( "NewMatrix: Length of <l> is not a multiple of <ncols>" );
        fi;
        m := List([0,ncols..Length(l)-ncols], i -> l{[i+1..i+ncols]});
      else
        m := List(l, ShallowCopy);
      fi;
    fi;

    # FIXME/TODO: should the following test be always performed
    # or only at a higher assertion level?
    Assert(0, ForAll(m, row -> Length(row) = ncols));
    Assert(0, ForAll(m, row -> ForAll(row, x -> x in basedomain)));

    m := [basedomain, Length(m), ncols, m];
    filter := IsPlistMatrixRep and IsMutable;
    if HasCanEasilyCompareElements(Representative(basedomain)) and
       CanEasilyCompareElements(Representative(basedomain)) then
        filter := filter and CanEasilyCompareElements;
    fi;
    Objectify( NewType(CollectionsFamily(FamilyObj(basedomain)),
                       filter), m );
    return m;
  end );

InstallMethod( NewZeroMatrix,
  "for IsPlistMatrixRep, a semiring, and two ints",
  [ IsPlistMatrixRep, IsSemiring, IsInt, IsInt ],
  function( filter, basedomain, rows, cols )
    local m;
    m := NullMat(rows, cols, basedomain);
    m := [basedomain, rows, cols, m];
    Objectify( NewType(CollectionsFamily(FamilyObj(basedomain)),
                       filter and IsMutable), m );
    return m;
  end );

InstallMethod( NewIdentityMatrix,
  "for IsPlistMatrixRep, a semiring, and an int",
  [ IsPlistMatrixRep, IsSemiring, IsInt ],
  function( filter, basedomain, dim )
    local mat, one, i;
    # TODO use ONE_MATRIX_MUTABLE
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

InstallMethod( ViewObj, "for a plist vector", [ IsPlistVectorRep ],
  function( v )
    if not IsMutable(v) then
        Print("<immutable ");
    else
        Print("<");
    fi;
    Print("plist vector over ",BaseDomain(v)," of length ",Length(v![ELSPOS]),">");
  end );

InstallMethod( PrintObj, "for a plist vector", [ IsPlistVectorRep ],
  function( v )
    local bd;
    bd := BaseDomain(v);
    Print("NewVector(IsPlistVectorRep");
    if IsFinite(bd) and IsField(bd) then
        Print(",GF(",Size(bd),"),",v![ELSPOS],")");
    else
        Print(",",String(bd),",",v![ELSPOS],")");
    fi;
  end );

InstallMethod( String, "for a plist vector", [ IsPlistVectorRep ],
  function( v )
    local bd, st;
    bd := BaseDomain(v);
    st := "NewVector(IsPlistVectorRep";
    if IsFinite(bd) and IsField(bd) then
        Append(st,Concatenation( ",GF(",String(Size(bd)),"),",
                                 String(v![ELSPOS]),")" ));
    else
        Append(st,Concatenation( ",",String(bd),",",
                                 String(v![ELSPOS]),")" ));
    fi;
    return st;
  end );

InstallMethod( Display, "for a plist vector", [ IsPlistVectorRep ],
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
    return NewZeroVector(IsPlistVectorRep, t![BDPOS], l);
  end );

InstallMethod( ZeroVector, "for an integer and a plist matrix",
  [ IsInt, IsPlistMatrixRep ],
  function( l, m )
    return NewZeroVector(IsPlistVectorRep, m![BDPOS], l);
  end );

InstallMethod( Vector, "for a list and a plist vector",
  [ IsList, IsPlistVectorRep ],
  function( l, t )
    local v;
    v := PlainListCopy(l);
    v := Objectify(TypeObj(t),[t![BDPOS],v]);
    if not IsMutable(v) then SetFilterObj(v,IsMutable); fi;
    return v;
  end );

# compatibility method for older representations as list of elements
InstallOtherMethod( ZeroVector, "for an integer and a plist vector/mat",
  [ IsInt, IsPlistRep ],
  -1, # rank lower than default as only fallback
function( l, t )
  return ListWithIdenticalEntries(l,ZeroOfBaseDomain(t));
end);

############################################################################
# A selection of list operations:
############################################################################

InstallMethod( \[\], "for a plist vector and a positive integer",
  [ IsPlistVectorRep, IsPosInt ],
  function( v, p )
    return v![ELSPOS][p];
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

InstallOtherMethod( PositionNonZero, "for a plist vector and start", 
  [ IsPlistVectorRep,IsInt ],
  function( v,s )
    return PositionNonZero( v![ELSPOS],s );
  end );

InstallMethod( PositionLastNonZero, "for a plist vector", [ IsPlistVectorRep ],
  function( v )
    local els,i;
    els := v![ELSPOS];
    i := Length(els);
    while i > 0 and IsZero(els[i]) do i := i - 1; od;
    return i;
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
    return Objectify(ty, [a![BDPOS],a![ELSPOS]+b![ELSPOS]]);
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
    return Objectify(ty, [a![BDPOS],a![ELSPOS]-b![ELSPOS]]);
  end );

InstallMethod( \=, "for two plist vectors",
  [ IsPlistVectorRep, IsPlistVectorRep ],
  function( a, b )
    return a![ELSPOS] = b![ELSPOS];
  end );

InstallMethod( \<, "for two plist vectors",
  [ IsPlistVectorRep, IsPlistVectorRep ],
  function( a, b )
    return a![ELSPOS] < b![ELSPOS];
  end );

InstallMethod( AddRowVector, "for two plist vectors",
  [ IsPlistVectorRep and IsMutable, IsPlistVectorRep ],
  function( a, b )
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

InstallMethod( MultVectorLeft,
  "for a plist vector, and an object",
  [ IsPlistVectorRep and IsMutable, IsObject ],
  function( v, s )
    MULT_VECTOR_LEFT_2(v![ELSPOS],s);
  end );

InstallMethod( MultVectorRight,
  "for a plist vector, and an object",
  [ IsPlistVectorRep and IsMutable, IsObject ],
  function( v, s )
    MULT_VECTOR_RIGHT_2(v![ELSPOS],s);
  end );

InstallOtherMethod( MultVectorLeft, "for an integer vector, and a small integer",
  [ IsPlistVectorRep and IsIntVector and IsMutable, IsSmallIntRep ],
  function( v, s )
    MULT_VECTOR_2_FAST(v![ELSPOS],s);
  end );

# The four argument version of MultVectorLeft / ..Right uses the generic
# implementation in matobj.gi

InstallMethod( \*, "for a plist vector and a scalar",
  [ IsPlistVectorRep, IsScalar ],
  function( v, s )
    return Objectify( TypeObj(v), [v![BDPOS],v![ELSPOS]*s] );
  end );

InstallMethod( \*, "for a scalar and a plist vector",
  [ IsScalar, IsPlistVectorRep ],
  function( s, v )
    return Objectify( TypeObj(v), [v![BDPOS],s*v![ELSPOS]] );
  end );

InstallMethod( \/, "for a plist vector and a scalar",
  [ IsPlistVectorRep, IsScalar ],
  function( v, s )
    return Objectify( TypeObj(v), [v![BDPOS],v![ELSPOS]/s] );
  end );

InstallMethod(LeftQuotient, "for a scalar and a plist vector",
  [ IsScalar, IsPlistVectorRep ],
  function( s, v )
    return Objectify( TypeObj(v),
             [v![BDPOS],LeftQuotient(s,v![ELSPOS])] );
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

InstallMethodWithRandomSource( Randomize,
  "for a random source and a mutable plist vector",
  [ IsRandomSource, IsPlistVectorRep and IsMutable ],
  function( rs, v )
    local bd,i;
    bd := BaseDomain(v);
    for i in [1..Length(v![ELSPOS])] do
        v![ELSPOS][i] := Random( rs, bd );
    od;
    return v;
  end );

InstallMethod( CopySubVector, "for two plist vectors and two lists",
  [ IsPlistVectorRep, IsPlistVectorRep and IsMutable, IsList, IsList ],
  function( a,b,pa,pb )
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

InstallMethod( BaseDomain, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    return m![BDPOS];
  end );

InstallMethod( NumberRows, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    return m![NUM_ROWS_POS];
  end );

InstallMethod( NumberColumns, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    return m![NUM_COLS_POS];
  end );

############################################################################
# Representation preserving constructors:
############################################################################

InstallMethod( ZeroMatrix, "for two integers and a plist matrix",
  [ IsInt, IsInt, IsPlistMatrixRep ],
  function( rows,cols,m )
    local l,res;
    l := NullMat(rows, cols, m![BDPOS]);
    res := Objectify( TypeObj(m), [m![BDPOS],rows,cols,l] );
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
    return res;
  end );

InstallMethod( IdentityMatrix, "for an integer and a plist matrix",
  [ IsInt, IsPlistMatrixRep ],
  function( rows, m )
    local i,l,o,res;
    l := List([1..rows],i->ListWithIdenticalEntries(rows, Zero(m![BDPOS])));
    o := One(m![BDPOS]);
    for i in [1..rows] do
        l[i,i] := o;
    od;
    res := Objectify( TypeObj(m), [m![BDPOS],rows,rows,l] );
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
    return res;
  end );


############################################################################
# A selection of list operations:
############################################################################

InstallOtherMethod( \[\], "for a plist matrix and a positive integer",
#T Once the declaration of '\[\]' for 'IsMatrixObj' disappears,
#T we can use 'InstallMethod'.
  [ IsRowPlistMatrixRep, IsPosInt ],
  function( m, i )
    Info(InfoPerformance, 1, "for best performance avoid m[i]; e.g. use m[i,j] instead of m[i][j]");
    # TODO: should we cache these row vectors?
    return MakeIsPlistVectorRep( m![BDPOS], m![ROWSPOS][i] );
  end );

InstallMethod( \[\]\:\=,
  "for a plist matrix, a positive integer, and a plist vector",
  [ IsRowPlistMatrixRep and IsMutable, IsPosInt, IsPlistVectorRep ],
  function( m, i, v )
    # TODO: verify that basedomain matches and that Length(v) = NrCols(m) ?
    m![ROWSPOS][i] := v![ELSPOS];
    # FIXME: really just assign the content, so that from now on any change to
    # the vector object <v> will modify the i-th row of <m>??? yes, this
    # emulates the old way of things, but it's also dangerous, and often leads to
    # bugs; perhaps we should instead make a copy / copy over the data only?
  end );

InstallMethod( \{\}, "for a plist matrix and a list",
  [ IsRowPlistMatrixRep, IsList ],
  function( m, p )
    local l;
    l := m![ROWSPOS]{p};
    return Objectify(TypeObj(m),[m![BDPOS],m![NUM_ROWS_POS],m![NUM_COLS_POS],l]);
  end );

InstallMethod( Add, "for a plist matrix and a plist vector",
  [ IsRowPlistMatrixRep and IsMutable, IsPlistVectorRep ],
  function( m, v )
    Add(m![ROWSPOS],v);
  end );

InstallMethod( Add, "for a plist matrix, a plist vector, and a pos. int",
  [ IsRowPlistMatrixRep and IsMutable, IsPlistVectorRep, IsPosInt ],
  function( m, v, p )
    Add(m![ROWSPOS],v,p);
  end );

InstallMethod( Remove, "for a plist matrix",
  [ IsRowPlistMatrixRep and IsMutable ],
  m -> Remove( m![ROWSPOS] ) );

InstallMethod( Remove, "for a plist matrix, and a position",
  [ IsRowPlistMatrixRep and IsMutable, IsPosInt ],
  function( m, p )
    Remove( m![ROWSPOS],p );
  end );
#T must return the removed row if it was bound

InstallMethod( IsBound\[\], "for a plist matrix, and a position",
  [ IsRowPlistMatrixRep, IsPosInt ],
  function( m, p )
    # TODO: move this to the generic IsRowListMatrix interface?
    return p <= NrRows(m);
  end );

InstallMethod( Unbind\[\], "for a plist matrix, and a position",
  [ IsRowPlistMatrixRep and IsMutable, IsPosInt ],
  function( m, p )
    # TODO: move this to the generic IsRowListMatrix interface?
    if p <> NrRows(m) then
        ErrorNoReturn("Unbind\\[\\]: Matrices must stay dense, you cannot Unbind here");
    fi;
    Remove(m);
  end );

InstallMethod( \{\}\:\=, "for a plist matrix, a list, and a plist matrix",
  [ IsRowPlistMatrixRep and IsMutable, IsList,
    IsRowPlistMatrixRep ],
  function( m, pp, n )
    # TODO: verify that basedomain matches and that Length(v) = NrCols(m) ?
    m![ROWSPOS]{pp} := n![ROWSPOS];
  end );

InstallMethod( Append, "for two plist matrices",
  [ IsRowPlistMatrixRep and IsMutable, IsRowPlistMatrixRep ],
  function( m, n )
    Append(m![ROWSPOS],n![ROWSPOS]);
  end );

InstallMethod( ShallowCopy, "for a plist matrix",
  [ IsRowPlistMatrixRep ],
  function( m )
    local res;
    res := Objectify(TypeObj(m),[m![BDPOS],m![NUM_ROWS_POS],m![NUM_COLS_POS],
                                 ShallowCopy(m![ROWSPOS])]);
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
#T 'ShallowCopy' MUST return a mutable object
#T if such an object exists at all!
    return res;
  end );

InstallMethod( PostMakeImmutable, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    MakeImmutable( m![ROWSPOS] );
  end );

InstallMethod( MutableCopyMat, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local l,res;
    l := MutableCopyMat(m![ROWSPOS]);
    res := Objectify(TypeObj(m),[m![BDPOS],NrRows(m),NrCols(m),l]);
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
    return res;
  end);

InstallMethod( ExtractSubMatrix, "for a plist matrix, and two lists",
  [ IsPlistMatrixRep, IsList, IsList ],
  function( m, p, q )
    local i,l;
    l := m![ROWSPOS]{p}{q};
    return Objectify(TypeObj(m),[m![BDPOS],Length(p),Length(q),l]);
  end );

InstallMethod( CopySubMatrix, "for two plist matrices and four lists",
  [ IsPlistMatrixRep, IsPlistMatrixRep and IsMutable,
    IsList, IsList, IsList, IsList ],
  function( m, n, srcrows, dstrows, srccols, dstcols )
    local i;
    # TODO: this eventually should go into the kernel without creating
    # any intermediate objects:
    for i in [1..Length(srcrows)] do
        n![ROWSPOS][dstrows[i]]{dstcols} :=
                  m![ROWSPOS][srcrows[i]]{srccols};
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

InstallMethod( MatElm, "for a plist matrix and two positions",
  [ IsPlistMatrixRep, IsPosInt, IsPosInt ],
  function( m, row, col )
    return m![ROWSPOS][row,col];
  end );

InstallMethod( SetMatElm, "for a plist matrix, two positions, and an object",
  [ IsPlistMatrixRep and IsMutable, IsPosInt, IsPosInt, IsObject ],
  function( m, row, col, ob )
    m![ROWSPOS][row,col] := ob;
  end );


############################################################################
# Printing and viewing methods:
############################################################################

InstallMethod( ViewObj, "for a plist matrix", [ IsPlistMatrixRep ],
  function( m )
    Print("<");
    if not IsMutable(m) then Print("immutable "); fi;
    Print(NrRows(m),"x",NrCols(m),"-matrix over ",m![BDPOS],">");
  end );

InstallMethod( PrintObj, "for a plist matrix", [ IsPlistMatrixRep ],
  function( m )
    local bd;
    bd := BaseDomain(m);
    Print("NewMatrix(IsPlistMatrixRep");
    if IsFinite(bd) and IsField(bd) then
        Print(",GF(",Size(bd),"),");
    else
        Print(",",String(bd),",");
    fi;
    Print(NumberColumns(m),",",Unpack(m),")");
  end );

InstallMethod( Display, "for a plist matrix", [ IsPlistMatrixRep ],
  function( m )
    local i;
    Print("<");
    if not IsMutable(m) then Print("immutable "); fi;
    Print(NrRows(m),"x",NrCols(m),"-matrix over ",m![BDPOS],":\n");
    for i in [1..NrRows(m)] do
        if i = 1 then
            Print("[");
        else
            Print(" ");
        fi;
        Print(m![ROWSPOS][i],"\n");
    od;
    Print("]>\n");
  end );

InstallMethod( String, "for plist matrix", [ IsPlistMatrixRep ],
  function( m )
    local bd, st;
    bd := BaseDomain(m);
    st := "NewMatrix(IsPlistMatrixRep";
    Add(st,',');
    if IsFinite(bd) and IsField(bd) then
        Append(st,"GF(");
        Append(st,String(Size(bd)));
        Append(st,"),");
    else
        Append(st,String(bd));
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

InstallMethod( \+, "for two plist matrices",
  [ IsPlistMatrixRep, IsPlistMatrixRep ],
  function( a, b )
    local ty;
    # TODO: check that dimensions match?
    if not IsMutable(a) and IsMutable(b) then
        ty := TypeObj(b);
    else
        ty := TypeObj(a);
    fi;
    # TODO: why do we blindly copy the number of columns from the first argument?
    # Either need to verify dimensions match, or, if we want to allow adding
    # arbitrary matrices, then we must use the maximum of the number of columns
    # here, no?
    # TODO: should we check and enforce the the basedomains are identical?
    return Objectify(ty,[a![BDPOS],a![NUM_ROWS_POS],a![NUM_COLS_POS],
                         a![ROWSPOS]+b![ROWSPOS]]);
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
    return Objectify(ty,[a![BDPOS],a![NUM_ROWS_POS],a![NUM_COLS_POS],
                         a![ROWSPOS]+b![ROWSPOS]]);
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
    if NrCols(a) <> NrRows(b) then
        ErrorNoReturn("\\*: Matrices do not fit together");
    fi;
    if not IsIdenticalObj(a![BDPOS],b![BDPOS]) then
        ErrorNoReturn("\\*: Matrices not over same base domain");
    fi;
    l := a![ROWSPOS]*b![ROWSPOS];
    if not IsMutable(a) and not IsMutable(b) then
        MakeImmutable(l);
    fi;
    return Objectify( ty, [a![BDPOS],a![NUM_ROWS_POS],b![NUM_COLS_POS],l] );
  end );

InstallMethod( \=, "for two plist matrices",
  [ IsPlistMatrixRep, IsPlistMatrixRep ],
  function( a, b )
    return a![ROWSPOS] = b![ROWSPOS];
  end );

InstallMethod( \<, "for two plist matrices",
  [ IsPlistMatrixRep, IsPlistMatrixRep ],
  function( a, b )
    return a![ROWSPOS] < b![ROWSPOS];
  end );

InstallMethod( AdditiveInverseMutable, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local l,res;
    l := AdditiveInverseMutable(m![ROWSPOS]);
    res := Objectify( TypeObj(m), [m![BDPOS],m![NUM_ROWS_POS],m![NUM_COLS_POS],l] );
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
    return res;
  end );

InstallMethod( ZeroMutable, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local l,res;
    l := ZeroMutable(m![ROWSPOS]);
    res := Objectify( TypeObj(m), [m![BDPOS],m![NUM_ROWS_POS],m![NUM_COLS_POS],l] );
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
    return res;
  end );

InstallMethod( IsZero, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    return IsZero(m![ROWSPOS]); # TODO: check that this results in "optimal" code
  end );

InstallMethod( IsOne, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    return IsOne(m![ROWSPOS]); # TODO: check that this results in "optimal" code
  end );

InstallMethod( OneMutable, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    if NrCols(m) <> NrRows(m) then
        #Error("OneMutable: Matrix is not square");
        #return;
        return fail;
    fi;
    return NewIdentityMatrix(IsPlistMatrixRep,NrCols(m));
  end );

InstallMethod( InverseMutable, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local n;
    if NrCols(m) <> NrRows(m) then
        return fail;
    fi;
    # Make a plain list of lists:
    n := InverseMutable(m![ROWSPOS]);
    if n = fail then return fail; fi;
    # FIXME: if the base domain is not a field, e.g. Integers,
    # then the inverse we just computed may not be defined over
    # that base domain. Should we detect this here? Or how else
    # will we deal with this in general?
    return NewMatrix(IsPlistMatrixRep, BaseDomain(m), NrCols(m), n);
  end );

InstallMethod( RankMat, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local n;

    n := List(m![ROWSPOS],x->x![ELSPOS]);
    return RankMat(n);
  end);


InstallMethodWithRandomSource( Randomize,
  "for a random source and a mutable plist matrix",
  [ IsRandomSource, IsPlistMatrixRep and IsMutable ],
  function( rs, m )
    local v;
    for v in m![ROWSPOS] do
        Randomize( rs, v );
    od;
    return m;
  end );

InstallMethod( TransposedMatMutable, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local trans, res;
    # FIXME/TODO: implement this generic, or optimized for IsPlistMatrixRep?
    # Right now, we do the latter:
    trans := TransposedMatMutable(m![ROWSPOS]);

    res := Objectify(TypeObj(m),[m![BDPOS],NrCols(m),NrRows(m),trans]);
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
    return res;
  end );

InstallMethod( TransposedMatImmutable, "for a plist matrix",
  [ IsPlistMatrixRep ],
  function( m )
    local n;
    # TODO: this could be a generic implementation
    n := TransposedMatMutable(m);
    MakeImmutable(n);
    return n;
  end );

InstallMethod( \*, "for a plist vector and a plist matrix",
  [ IsPlistVectorRep, IsPlistMatrixRep ],
  function( v, m )
    local i,res,s;
    # TODO: should we verify that Length(v) = NrRows(m)?
    res := ZeroVector(NrCols(m),v);
    res![ELSPOS] := v![ELSPOS] * m![ROWSPOS];
    if not IsMutable(v) and not IsMutable(m) then
        MakeImmutable(res);
    fi;
    return res;
  end );

# TODO: what about  \* for a matrix and a vector?


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

InstallMethod( ChangedBaseDomain, "for a plist vector, and a semiring",
  [ IsPlistVectorRep, IsSemiring ],
  function( v, r )
    return NewVector( IsPlistVectorRep, r, v![ELSPOS] );
  end );

InstallMethod( ChangedBaseDomain, "for a plist matrix, and a semiring",
  [ IsPlistMatrixRep, IsSemiring ],
  function( m, r )
    return NewMatrix(IsPlistMatrixRep, r, NumberColumns(m),
                     List(m![ROWSPOS], x-> x![ELSPOS]));
  end );

InstallMethod( CompatibleVectorFilter, "for a plist matrix",
  [ IsPlistMatrixRep ],
  M -> IsPlistVectorRep );

InstallMethod( NewCompanionMatrix,
  "for IsPlistMatrixRep, a polynomial and a ring",
  [ IsPlistMatrixRep, IsUnivariatePolynomial, IsRing ],
  function( filter, po, bd )
    local i,l,ll,n,one;
    one := One(bd);
    l := CoefficientsOfUnivariatePolynomial(po);
    n := Length(l)-1;
    if not IsOne(l[n+1]) then
        Error("CompanionMatrix: polynomial is not monic");
        return fail;
    fi;
    ll := NewZeroMatrix(IsPlistMatrixRep,bd,n,n);
    l := Vector(-l{[1..n]},CompatibleVector(ll));
    for i in [1..n-1] do
        ll[i,i+1] := one;
    od;
    ll![ROWSPOS][n] := l; # FIXME: we need a function to copy a vector into a row?
    return ll;
  end );

