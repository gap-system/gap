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
##
##  This file contains some generic methods for the vector/matrix object
##  interface defined in 'matobj1.gd' and 'matobj2.gd'.
##


#############################################################################
##
##  <#GAPDoc Label="MatrixObjCompare">
##  <ManSection>
##  <Heading>Comparison of Vector and Matrix Objects</Heading>
##  <Oper Name="\=" Arg='v1, v2' Label="for two vector objects"/>
##  <Oper Name="\=" Arg='M1, M2' Label="for two matrix objects"/>
##  <Oper Name="\&lt;" Arg='v1, v2' Label="for two vector objects"/>
##  <Oper Name="\&lt;" Arg='M1, M2' Label="for two matrix objects"/>
##
##  <Description>
##  Two vector objects in <Ref Filt="IsList"/> are equal if they are equal as
##  lists.
##  Two matrix objects in <Ref Filt="IsList"/> are equal if they are equal as
##  lists.
##  <P/>
##  Two vector objects of which at least one is not in <Ref Filt="IsList"/>
##  are equal with respect to <Ref Oper="\="/> if they have the same
##  <Ref Attr="ConstructingFilter" Label="for a vector object"/> value,
##  the same <Ref Attr="BaseDomain" Label="for a vector object"/> value,
##  the same length,
##  and the same entries.
##  <P/>
##  Two matrix objects of which at least one is not in <Ref Filt="IsList"/>
##  are equal with respect to <Ref Oper="\="/> if they have the same
##  <Ref Attr="ConstructingFilter" Label="for a matrix object"/> value,
##  the same <Ref Attr="BaseDomain" Label="for a matrix object"/> value,
##  the same dimensions,
##  and the same entries.
##  <P/>
##  We do <E>not</E> state a general rule how vector and matrix objects
##  shall behave w.r.t. the comparison by <Ref Oper="\&lt;"/>.
##  Note that a <Q>row lexicographic order</Q> would be quite unnatural
##  for matrices that are internally represented via a list of columns.
##  <P/>
##  Note that the operations <Ref Oper="\="/> and <Ref Oper="\&lt;"/>
##  are used to form sorted lists and sets of objects,
##  see for example <Ref Oper="Sort"/> and <Ref Oper="Set"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InstallMethod( \=,
    "for two vector objects",
    [ IsVectorObj, IsVectorObj ],
    function( v1, v2 )
    if IsList( v1 ) and IsList( v2 ) then
      TryNextMethod();
    fi;
    return ConstructingFilter( v1 ) = ConstructingFilter( v2 ) and
           BaseDomain( v1 ) = BaseDomain( v2 ) and
           Length( v1 ) = Length( v2 ) and
           ForAll( [ 1 .. Length( v1 ) ], i -> v1[i] = v2[i] );
    end );

InstallMethod( \=,
    "for two matrix objects",
    [ IsMatrixObj, IsMatrixObj ],
    function( M1, M2 )
    return ConstructingFilter( M1 ) = ConstructingFilter( M2 ) and
           BaseDomain( M1 ) = BaseDomain( M2 ) and
           NumberRows( M1 ) = NumberRows( M2 ) and
           NumberColumns( M1 ) = NumberColumns( M2 ) and
           ForAll( [ 1 .. NumberRows( M1 ) ],
                   i -> ForAll( [ 1 .. NumberColumns( M1 ) ],
                                j -> M1[i,j] = M2[i,j] ) );
    end );

InstallMethod( Unpack,
    "generic method for matrix objects",
    [ IsMatrixObj ],
    function(M)
      return List([1..NrRows(M)], row -> List([1..NrCols(M)], col -> M[row,col]));
    end );

InstallMethod( OneOfBaseDomain,
    "generic method for IsVectorObj",
    [ IsVectorObj ],
    v -> One( BaseDomain( v ) ) );

InstallMethod( ZeroOfBaseDomain,
    "generic method for IsVectorObj",
    [ IsVectorObj ],
    v -> Zero( BaseDomain( v ) ) );

InstallMethod( OneOfBaseDomain,
    "generic method for IsMatrixOrMatrixObj",
    [ IsMatrixOrMatrixObj ],
    M -> One( BaseDomain( M ) ) );

InstallMethod( ZeroOfBaseDomain,
    "generic method for IsMatrixOrMatrixObj",
    [ IsMatrixOrMatrixObj ],
    M -> Zero( BaseDomain( M ) ) );


InstallMethod( WeightOfVector,
    "generic method for vector objects",
    [ IsVectorObj ],
  function(v)
    local i,n;
    n := 0;
    for i in [1..Length(v)] do
        if not IsZero(v[i]) then
            n := n + 1;
        fi;
    od;
    return n;
  end );

InstallMethod( DistanceOfVectors,
    "generic method for two vector objects",
  [IsVectorObj, IsVectorObj],
  function( v, w)
    local i,n;
    if Length(v) <> Length(w) then
        Error("vectors must have same length");
        return fail;
    fi;
    n := 0;
    for i in [1..Length(v)] do
        if v[i] <> w[i] then
            n := n + 1;
        fi;
    od;
    return n;
  end );

#
# TODO: possibly rename the following
#
InstallGlobalFunction( DefaultVectorRepForBaseDomain,
function( basedomain )
    if IsFinite(basedomain) and IsField(basedomain) and Size(basedomain) = 2 then
        return IsGF2VectorRep;
    elif IsFinite(basedomain) and IsField(basedomain) and Size(basedomain) <= 256 then
        return Is8BitVectorRep;
##  This should be enabled when the code for
##       IsZmodnZVectorRep/IsZmodnZMatrixRep
##  is finished and tested:
##      elif IsFinite(basedomain) and IsZmodnZObj(Zero(basedomain)) then
##        return IsZmodnZVectorRep;
    fi;
    return IsPlistVectorRep;
end);
InstallGlobalFunction( DefaultMatrixRepForBaseDomain,
function( basedomain )
    if IsFinite(basedomain) and IsField(basedomain) and Size(basedomain) = 2 then
        return IsGF2MatrixRep;
    elif IsFinite(basedomain) and IsField(basedomain) and Size(basedomain) <= 256 and IsFFECollection(basedomain) then
        return Is8BitMatrixRep;
##  This should be enabled when the code for
##       IsZmodnZVectorRep/IsZmodnZMatrixRep
##  is finished and tested:
##      elif IsFinite(basedomain) and IsZmodnZObj(Zero(basedomain)) then
##        return IsZmodnZMatrixRep;
    fi;
    return IsPlistMatrixRep;
end);



# methods to create vector objects

#############################################################################
##
#O  Vector( <filt>, <R>, <list> )
#O  Vector( <filt>, <R>, <vec> )
#O  Vector( <R>, <list> )
#O  Vector( <R>, <vec> )
#O  Vector( <list>, <vec> )
#O  Vector( <vec1>, <vec2> )
##
##  Compute the missing arguments for 'NewVector' and then call it.
##
InstallMethod( Vector,
    [ IsOperation, IsSemiring, IsList ],
    NewVector );

InstallMethod( Vector,
    [ IsOperation, IsSemiring, IsVectorObj ],
    function( rep, R, v )
    if IsPlistRep( v ) then
      TryNextMethod();
    fi;
    return NewVector( rep, R, Unpack( v ) );
    end );

InstallMethod( Vector,
    [ IsSemiring, IsList ],
    { R, l } -> NewVector( DefaultVectorRepForBaseDomain( R ), R, l ) );

InstallMethod( Vector,
    [ IsSemiring, IsVectorObj ],
    function( R, v )
    if IsPlistRep( v ) then
      TryNextMethod();
    fi;
    return NewVector( DefaultVectorRepForBaseDomain( R ),
                          R, Unpack( v ) );
    end );

InstallMethod( Vector,
    [ IsList, IsVectorObj ],
    { l, example } -> NewVector( ConstructingFilter( example ),
                                 BaseDomain( example ), l ) );

InstallMethod( Vector,
    [ IsVectorObj, IsVectorObj ],
    function( v, example )
    if IsPlistRep( v ) then
      TryNextMethod();
    fi;
    return NewVector( ConstructingFilter( example ),
                      BaseDomain( example ), Unpack( v ) );
    end );

InstallMethod( Vector,
    [ IsList ],
function(l)
  local dom;
  dom := DefaultScalarDomainOfMatrixList([[l]]);
  return NewVector(DefaultVectorRepForBaseDomain(dom), dom, l);
end);

# The following method is used for example
# in code dealing with elements of 'AlgebraicExtension's.
# (Note that we want to return a vector with the same mutability status
# as the given vector, and we need not copy it if it is mutable.)
InstallOtherMethod( Vector,
    [ IsList and IsCyclotomicCollection, IsList and IsCyclotomicCollection ],
    { v, example } -> v );


#############################################################################
##
#M  ZeroVector( <filt>, <R>, <len> )
#M  ZeroVector( <R>, <len> )
##
InstallMethod( ZeroVector,
  [ IsOperation, IsSemiring, IsInt ],
  function( rep, basedomain, len )
    if len < 0 then Error("ZeroVector: length must be non-negative"); fi;
    return NewZeroVector( rep, basedomain, len );
  end );

InstallMethod( ZeroVector,
  [ IsSemiring, IsInt ],
  function( basedomain, len )
    if len < 0 then Error("ZeroVector: length must be non-negative"); fi;
    return NewZeroVector( DefaultVectorRepForBaseDomain(basedomain), basedomain, len );
  end );


#############################################################################
##
#M  NewZeroVector( <filt>, <R>, <n> )
##
##  The default method is based on 'NewVector'.
##  Note that 'NewVector' checks for consistency of <filt> and <R>.
##  The drawback of the default method is that 'NewVector' will make a
##  shallow copy of the list.
##
InstallTagBasedMethod( NewZeroVector,
  function( filter, R, n )
    return NewVector( filter, R, ListWithIdenticalEntries( n, Zero( R ) ) );
  end );


#############################################################################
##
#M  ZeroVector( <len>, <v> )
#M  ZeroVector( <len>, <M> )
##
InstallMethod( ZeroVector,
    "for length and vector object",
    [ IsInt, IsVectorObj ],
    { len, v } -> NewZeroVector( ConstructingFilter( v ),
                                 BaseDomain( v ), len ) );

InstallMethod( ZeroVector,
    "for length and matrix or matrix object",
    [ IsInt, IsMatrixOrMatrixObj ],
    { len, M } -> NewZeroVector( CompatibleVectorFilter( M ),
                                 BaseDomain( M ), len ) );

InstallMethod( CompatibleVectorFilter,
    "for IsMatrix",
    [ IsMatrix ],
    {} -> -RankFilter(IsMatrix),
    M -> IsPlistRep );

# compatibility method for representations as list of elements
# (covers the cases of the second argument in `IsRowVector` or `IsMatrix`)
InstallOtherMethod( ZeroVector, "for an integer and a plain list",
  [ IsInt, IsPlistRep ],
  -1, # rank lower than default as only fallback
  function( l, t )
    return ListWithIdenticalEntries( l, ZeroOfBaseDomain( t ) );
  end);


#############################################################################
##
#M  Matrix( <filt>, <R>, <list>, <ncols> )
#M  Matrix( <filt>, <R>, <list> )
#M  Matrix( <filt>, <R>, <M> )
#M  Matrix( <R>, <list>, <ncols> )
#M  Matrix( <R>, <list> )
#M  Matrix( <R>, <M> )
#M  Matrix( <list>, <ncols>, <M> )
#M  Matrix( <list>, <M> )
#M  Matrix( <M1>, <M2> )
#M  Matrix( <list>, <ncols> )
#M  Matrix( <list> )
##
##  Compute the missing arguments for 'NewMatrix' and then call it.
##
InstallMethod( Matrix,
  [ IsOperation, IsSemiring, IsList, IsInt ],
  { filt, R, list, nrCols } -> NewMatrix( filt, R, nrCols, list ) );

InstallMethod( Matrix,
    [ IsOperation, IsSemiring, IsList ],
    function( filt, R, list )
    if Length( list ) = 0 then
      Error( "<list> must be not empty; ",
             "to create empty matrices, please specify nrCols");
    fi;
    return NewMatrix( filt, R, Length( list[1] ), list );
  end );

InstallMethod( Matrix,
    [ IsOperation, IsSemiring, IsMatrixObj ],
    { filt, R, mat } -> NewMatrix( filt, R, NrCols( mat ), Unpack( mat ) ) );
# TODO: can we do better? encourage MatrixObj implementors to overload this?

InstallMethod( Matrix,
    [ IsSemiring, IsList, IsInt ],
    { R, list, nrCols } -> NewMatrix( DefaultMatrixRepForBaseDomain( R ),
                                      R, nrCols, list ) );

InstallMethod( Matrix,
    [ IsSemiring, IsList ],
# rank higher than a method in the semigroups package, which otherwise jumps
# in and causes an error when testing
# line 318 of semigroups-3.4.0/gap/elements/semiringmat.gi
20,
function( R, list )
local l;
    if Length(list) = 0 then
      TryNextMethod();
    fi;
    l:=Length(list[1]);
    if ForAny([2..Length(list)],x->Length(list[x])<>l) then
      TryNextMethod();
    fi;
    return NewMatrix( DefaultMatrixRepForBaseDomain( R ),
                      R, l, list );
end );

InstallMethod( Matrix,
    [ IsSemiring, IsMatrixObj ],
    { R, M } -> NewMatrix( DefaultMatrixRepForBaseDomain( R ),
                           R, NrCols( M ), Unpack( M ) ) );
# TODO: can we do better? encourage MatrixObj implementors to overload this?

#
#
#
InstallMethod( Matrix,
  [IsList, IsInt],
  function( list, nrCols )
    local basedomain, rep;
    if Length(list) = 0 then Error("list must be not empty"); fi;
    if Length(list[1]) = 0 then Error("list[1] must be not empty, please specify base domain explicitly"); fi;
    basedomain := DefaultScalarDomainOfMatrixList([list]);
    rep := DefaultMatrixRepForBaseDomain(basedomain);
    return NewMatrix( rep, basedomain, nrCols, list );
  end );

InstallMethod( Matrix,
  [IsList],
  function( list )
    local rep, R;
    if Length( list ) = 0 then
      Error( "<list> must be not empty" );
    elif Length( list[1] ) = 0 then
      Error( "<list>[1] must be not empty, ",
             "please specify base domain explicitly" );
    fi;
    R:= DefaultScalarDomainOfMatrixList( [ list ] );
    rep := DefaultMatrixRepForBaseDomain( R );
    return NewMatrix( rep, R , Length( list[1] ), list );
  end );

#
# matrix constructors using example objects (as last argument)
#
InstallMethod( Matrix,
  [IsList, IsInt, IsMatrixOrMatrixObj],
  function( list, nrCols, example )
    return NewMatrix( ConstructingFilter(example), BaseDomain(example), nrCols, list );
  end );

InstallMethod( Matrix, "generic convenience method with 2 args",
  [IsList, IsMatrixOrMatrixObj],
  function( list, example )
    if Length(list) = 0 then
        ErrorNoReturn("Matrix: two-argument version not allowed with empty first arg");
    fi;
    if not (IsList(list[1]) or IsVectorObj(list[1])) then
        ErrorNoReturn("Matrix: flat data not supported in two-argument version");
    fi;
    return NewMatrix( ConstructingFilter(example), BaseDomain(example), Length(list[1]), list );
  end );

InstallMethod( Matrix,
  [IsMatrixObj, IsMatrixOrMatrixObj],
    function( mat, example )
    # TODO: can we avoid using Unpack? resp. make this more efficient
    # perhaps adjust NewMatrix to take an IsMatrixOrMatrixObj?
    return NewMatrix( ConstructingFilter(example), BaseDomain(example), NrCols(mat), Unpack(mat) );
  end );


#############################################################################
##
#M  NewZeroMatrix( <filt>, <R>, <m>, <n> )
##
##  The default method is based on 'NewMatrix'.
##  Note that 'NewMatrix' checks for consistency of <filt> and <R>.
##  The drawback of the default method is that 'NewMatrix' will make a
##  shallow copy of the lists.
##
InstallTagBasedMethod( NewZeroMatrix,
  function( filter, basedomain, rows, cols )
    local z, v, m;

    z:= Zero( basedomain );
    v:= ListWithIdenticalEntries( cols, z );
    m:= List( [ 1 .. rows ], i -> ShallowCopy( v ) );
    return NewMatrix( filter, basedomain, cols, m );
  end );

#
#
#
InstallMethod( ZeroMatrix,
  [IsInt, IsInt, IsMatrixOrMatrixObj],
  function( rows, cols, example )
    if rows < 0 or cols < 0 then Error("ZeroMatrix: the number of rows and cols must be non-negative"); fi;
    return NewZeroMatrix( ConstructingFilter(example), BaseDomain(example), rows, cols );
  end );

InstallMethod( ZeroMatrix,
  [IsSemiring, IsInt, IsInt],
  function( basedomain, rows, cols )
    if rows < 0 or cols < 0 then Error("ZeroMatrix: the number of rows and cols must be non-negative"); fi;
    return NewZeroMatrix( DefaultMatrixRepForBaseDomain(basedomain), basedomain, rows, cols );
  end );

InstallMethod( ZeroMatrix,
  [IsOperation, IsSemiring, IsInt, IsInt],
  function( rep, basedomain, rows, cols )
    if rows < 0 or cols < 0 then Error("ZeroMatrix: the number of rows and cols must be non-negative"); fi;
    return NewZeroMatrix( rep, basedomain, rows, cols );
  end );


#############################################################################
##
#M  NewIdentityMatrix( <filt>, <R>, <n> )
##
##  The default method is based on 'NewZeroMatrix'.
##  Note that 'NewZeroMatrix' checks for consistency of <filt> and <R>.
##
InstallTagBasedMethod( NewIdentityMatrix,
  function( filter, basedomain, dim )
    local mat, one, i;

    mat:= NewZeroMatrix( filter, basedomain, dim, dim );
    one:= One( basedomain );
    for i in [ 1 .. dim ] do
      mat[i,i]:= one;
    od;
    return mat;
  end );

#
#
#
InstallMethod( IdentityMatrix,
  [IsInt, IsMatrixOrMatrixObj],
  function( dim, example )
    if dim < 0 then Error("IdentityMatrix: the dimension must be non-negative"); fi;
    return NewIdentityMatrix( ConstructingFilter(example), BaseDomain(example), dim );
  end );

InstallMethod( IdentityMatrix,
  [IsSemiring, IsInt],
  function( basedomain, dim )
    if dim < 0 then Error("IdentityMatrix: the dimension must be non-negative"); fi;
    return NewIdentityMatrix( DefaultMatrixRepForBaseDomain(basedomain), basedomain, dim );
  end );

InstallMethod( IdentityMatrix,
  [IsOperation, IsSemiring, IsInt],
  function( rep, basedomain, dim )
    if dim < 0 then Error("IdentityMatrix: the dimension must be non-negative"); fi;
    return NewIdentityMatrix( rep, basedomain, dim );
  end );


#############################################################################
##
#M  NewCompanionMatrix( <filt>, <pol>, <R> )
##
##  The default method is based on 'NewZeroMatrix'.
##  Note that 'NewZeroMatrix' checks for consistency of <filt> and <R>,
##  and 'SetMatElm' checks for consistency of the matrix and the coefficients
##  of <pol>.
##
InstallTagBasedMethod( NewCompanionMatrix,
  function( filter, pol, basedomain )
    local one, l, n, mat, i;

    one:= One( basedomain );
    l:= CoefficientsOfUnivariatePolynomial( pol );
    n:= Length( l ) - 1;
    if n <= 0 then
      Error( "NewCompanionMatrix: degree of <pol> must be at least 1" );
    elif not IsOne( l[n+1] ) then
      Error( "NewCompanionMatrix: polynomial <pol> is not monic" );
    fi;
    mat:= NewZeroMatrix( filter, basedomain, n, n );
    for i in [ 1 .. n-1 ] do
      mat[i+1,i]:= one;
    od;
    for i in [ 1 .. n ] do
      mat[i,n]:= - l[i];
    od;

    return mat;
  end );

#
#
#
InstallMethod( CompanionMatrix,
    "for a polynomial and a matrix or matrix object",
    [ IsUnivariatePolynomial, IsMatrixOrMatrixObj ],
    function( pol, M )
    return NewCompanionMatrix( ConstructingFilter( M ), pol, BaseDomain( M ) );
    end );

InstallMethod( CompanionMatrix,
    "for a filter, a polynomial, and a semiring",
    [ IsOperation, IsUnivariatePolynomial, IsSemiring ],
    function( filt, pol, R )
    return NewCompanionMatrix( filt, pol, R );
    end );

InstallMethod( CompanionMatrix,
    "for a polynomial and a semiring",
    [ IsUnivariatePolynomial, IsSemiring ],
    function( pol, R )
    return NewCompanionMatrix( DefaultMatrixRepForBaseDomain( R ), pol, R );
    end );

#
#
#
InstallMethod( KroneckerProduct, "for two matrices",
  [ IsMatrixOrMatrixObj, IsMatrixOrMatrixObj ],
  function( A, B )
    local rowsA, rowsB, colsA, colsB, AxB, i, j;

    if not IsIdenticalObj(BaseDomain(A),BaseDomain(B)) then
        ErrorNoReturn("KroneckerProduct: Matrices not over same base domain");
    fi;

    rowsA := NumberRows(A);
    colsA := NumberColumns(A);
    rowsB := NumberRows(B);
    colsB := NumberColumns(B);

    AxB := ZeroMatrix( rowsA * rowsB, colsA * colsB, A );

    # Cache matrices
    # not implemented yet

    for i in [1..rowsA] do
      for j in [1..colsA] do
        CopySubMatrix( A[i,j] * B, AxB,
                [ 1 .. rowsB ], [ rowsB * (i-1) + 1 .. rowsB * i ],
                [ 1 .. colsB ], [ (j-1) * colsB + 1 .. j * colsB ] );
      od;
    od;

    if not IsMutable(A) and not IsMutable(B) then
        MakeImmutable(AxB);
    fi;

    return AxB;
  end );

InstallGlobalFunction( ConcatenationOfVectors,
  function( arg )
    local i,len,pos,res,total;
    if Length( arg ) = 1 and IsList( arg[1] ) then
        arg := arg[1];
    fi;
    if Length(arg) = 0 then
        Error("must have at least one vector to concatenate");
    fi;
    total := Sum(arg,Length);
    res := ZeroVector(total,arg[1]);
    pos := 1;
    for i in [1..Length(arg)] do
        len := Length(arg[i]);
        CopySubVector(arg[i],res,[1..len],[pos..pos+len-1]);
        pos := pos + len;
    od;
    return res;
  end );

InstallMethod( TraceMat,
    "for a matrix or matrix object",
    [ IsMatrixOrMatrixObj ],
    function( M )
    local s, i;

    if NumberRows( M ) <> NumberColumns( M ) then
      Error( "matrix <M> must be square" );
    fi;
    s:= ZeroOfBaseDomain( M );
    for i in [ 1 .. NumberRows( M ) ] do
      s:= s + M[ i, i ];
    od;

    return s;
  end );

InstallMethod( PositionNonZero,
    "generic method for a vector object",
    [ IsVectorObj ],
    function( v )
    local i;

    for i in [ 1 .. Length( v ) ] do
      if not IsZero( v[i] ) then
        return i;
      fi;
    od;
    return i+1;
    end );

InstallMethod( PositionLastNonZero,
    "generic method for a vector object",
    [ IsVectorObj ],
    function( v )
    local i;

    i:= Length( v );
    while i > 0 and IsZero( v[i] ) do
      i:= i-1;
    od;
    return i;
    end );

InstallMethod( ListOp,
  "generic method for a vector object",
  [ IsVectorObj ],
  function(vec)
  local result, i, len;
  len := Length(vec);
  result := [];
  if 0 < len then
    result[len] := vec[len];
    for i in [ 1 .. len - 1 ] do
      result[i] := vec[i];
    od;
  fi;
  return result;
end );
#T delegation question -- use {}? or Unpack?

InstallMethod( ListOp,
  "generic method for a vector object and a function",
  [ IsVectorObj, IsFunction ],
  function(vec,func)
  local result, i, len;
  len := Length(vec);
  result := [];
  if 0 < len then
    result[len] := func(vec[len]);
    for i in [ 1 .. len - 1 ] do
      result[i] := func(vec[i]);
    od;
  fi;
  return result;
end );

InstallMethod( Unpack,
  "generic method for a vector object",
  [ IsVectorObj ],
  ListOp ); ## Potentially slower than a direct implementation,
            ## but avoids code duplication.

InstallOtherMethod( Unpack,
  "generic method for plain lists",
  [ IsRowVector and IsPlistRep ],
  ShallowCopy );

InstallMethod( \{\},
  "generic method for a vector object and a list",
  [ IsVectorObj, IsList ],
    function( v, poss )
    if IsPlistRep( v ) then
      TryNextMethod();
    fi;
    return Vector( Unpack( v ){ poss }, v );
    end );

InstallMethod( ExtractSubVector,
    "generic method for a vector object and a list",
    [ IsVectorObj, IsList ],
    { v, l } -> v{ l } );

InstallMethod( ExtractSubMatrix,
    "generic method for a matrix object and two lists",
    [ IsMatrixObj, IsList, IsList ],
    { M, rowpos, colpos } -> Matrix( Unpack( M ){ rowpos }{ colpos }, M ) );

# Hack from recog package
InstallOtherMethod( ExtractSubMatrix, "hack: for lists of compressed vectors",
[ IsList, IsList, IsList ],
function( m, poss1, poss2 )
  local i,n;
  n := [];
  for i in poss1 do
      Add(n,ShallowCopy(m[i]{poss2}));
  od;
  if IsFFE(m[1,1]) then
      ConvertToMatrixRep(n);
  fi;
  return n;
end );

InstallMethod( CopySubVector,
    "generic method for vector objects",
  [ IsVectorObj, IsVectorObj and IsMutable, IsList, IsList ],
  function(src, dst, scols, dcols)
    local i;
    if not Length( dcols ) = Length( scols ) then
      Error( "source and destination index lists must be of equal length" );
      return;
    fi;
    for i in [ 1 .. Length( dcols ) ] do
      dst[dcols[i]] := src[scols[i]];
    od;
end );


#############################################################################
##
#M  ChangedBaseDomain( <v>, <R> )
#M  ChangedBaseDomain( <M>, <R> )
##
InstallMethod( ChangedBaseDomain,
    "for a vector object and a semiring",
    [ IsVectorObj, IsSemiring ],
    { v, R } -> Vector( R, v ) );

InstallMethod( ChangedBaseDomain,
    "for a matrix or matrix object and a semiring",
    [ IsMatrixOrMatrixObj, IsSemiring ],
    { M, R } -> Matrix( R, M ) );


############################################################################
##
#M  Randomize( [Rs, ]v )
#M  Randomize( [Rs, ]M )
##
InstallMethodWithRandomSource( Randomize,
  "for a random source and a vector object",
  [ IsRandomSource, IsVectorObj and IsMutable ],
  function( rs, vec )
    local basedomain, i;
    basedomain := BaseDomain( vec );
    for i in [ 1 .. Length( vec ) ] do
        vec[ i ] := Random( rs, basedomain );
    od;
    return vec;
end );

InstallMethodWithRandomSource( Randomize,
  "for a random source and a mutable matrix or matrix object",
  [ IsRandomSource, IsMatrixOrMatrixObj and IsMutable ],
  function( rs, mat )
    local basedomain, i, j;
    basedomain := BaseDomain( mat );
    for i in [ 1 .. NrRows( mat ) ] do
      for j in [ 1 .. NrCols( mat ) ] do
        mat[i,j]:= Random( rs, basedomain );
      od;
    od;
    return mat;
end );


#############################################################################
##
##  Arithmetical operations for vector objects
##


#############################################################################
##
#M  <v1> + <v2>
#M  <v1> - <v2>
#M  <s> * <v>
#M  <v> * <s>
#M  <v1> * <v2>
#M  <v> / <s>
##
##  <#GAPDoc Label="VectorObj_BinaryArithmetics">
##  <ManSection>
##  <Heading>Binary Arithmetical Operations for Vector Objects</Heading>
##  <Meth Name="\+" Arg="v1, v2" Label="for two vector objects"/>
##  <Meth Name="\-" Arg="v1, v2" Label="for two vector objects"/>
##  <Meth Name="\*" Arg="s, v" Label="for scalar and vector object"/>
##  <Meth Name="\*" Arg="v, s" Label="for vector object and scalar"/>
##  <Meth Name="\*" Arg="v1, v2" Label="for two vector objects"/>
##  <Meth Name="ScalarProduct" Arg="v1, v2" Label="for two vector objects"/>
##  <Meth Name="\/" Arg="v, s" Label="for vector object and scalar"/>
##
##  <Description>
##  The sum and the difference, respectively,
##  of two vector objects <A>v1</A> and <A>v2</A>
##  is a new mutable vector object whose entries are the sums and the
##  differences of the entries of the arguments.
##  <P/>
##  The product of a scalar <A>s</A> and a vector object <A>v</A> (from the
##  left or from the right) is a new mutable vector object whose entries
##  are the corresponding products.
##  <P/>
##  The quotient of a vector object <A>v</A> and a scalar <A>s</A>
##  is a new mutable vector object whose entries are the corresponding
##  quotients.
##  <P/>
##  The product of two vector objects <A>v1</A> and <A>v2</A> as well as the
##  result of <Ref Meth="ScalarProduct" Label="for two vector objects"/> is
##  the standard scalar product of the two arguments
##  (an element of the base domain of the vector objects).
##  <P/>
##  All this is defined only if the vector objects have the same length and
##  are defined over the same base domain and have the same representation,
##  and if the products with the given scalar belong to the base domain;
##  otherwise it is not specified what happens.
##  If the result is a vector object then it has the same representation and
##  the same base domain as the given vector object(s).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InstallMethod( \+,
    "for two vector objects",
    [ IsVectorObj, IsVectorObj ],
    function( v1, v2 )
    if IsPlistRep( v1 ) then
      TryNextMethod();
    fi;
    return Vector( Unpack( v1 ) + Unpack( v2 ), v1 );
    end );

InstallMethod( \-,
    "for two vector objects",
    [ IsVectorObj, IsVectorObj ],
    function( v1, v2 )
    if IsPlistRep( v1 ) then
      TryNextMethod();
    fi;
    return Vector( Unpack( v1 ) - Unpack( v2 ), v1 );
    end );

InstallMethod( \*,
    "for two vector objects (standard scalar product)",
    [ IsVectorObj, IsVectorObj ],
    { v1, v2 } -> Sum( [ 1 .. Length( v1 ) ],
                       i -> v1[i] * v2[i],
                       ZeroOfBaseDomain( v1 ) ) );

InstallMethod( \*,
    "for vector object and scalar",
    [ IsVectorObj, IsScalar ],
    function( v, s )
    if IsList( v ) then
      TryNextMethod();
    fi;
    return Vector( Unpack( v ) * s, v );
    end );

InstallMethod( \*,
    "for scalar and vector object",
    [ IsScalar, IsVectorObj ],
    function( s, v )
    if IsList( v ) then
      TryNextMethod();
    fi;
    return Vector( s * Unpack( v ), v );
    end );

InstallMethod( \/,
    "for vector object and scalar",
    [ IsVectorObj, IsScalar ],
    function( v, s )
    if IsPlistRep( v ) then
      TryNextMethod();
    fi;
    return Vector( Unpack( v ) / s, v );
    end );

InstallOtherMethod( ScalarProduct,
    "for two vector objects",
    [ IsVectorObj, IsVectorObj ],
    \* );


#############################################################################
##
#M  AddVector( <dst>, <src>[, <mul>[, <from>, <to>]] )
#M  AddVector( <dst>, <mul>, <src>[, <from>, <to>] )
##
InstallMethod( AddVector,
    "for two vector objects",
    [ IsVectorObj and IsMutable, IsVectorObj ],
    function( dst, src )
    local i;

    for i in [ 1 .. Length( dst ) ] do
      dst[i]:= dst[i] + src[i];
    od;
    end );

InstallMethod( AddVector,
    "for two vector objects and an object",
    [ IsVectorObj and IsMutable, IsVectorObj, IsObject ],
    function( dst, src, c )
    local i;

    for i in [ 1 .. Length( dst ) ] do
      dst[i]:= dst[i] + src[i] * c;
    od;
    end );

InstallMethod( AddVector,
    "for a vector object, an object, a vector object",
    [ IsVectorObj and IsMutable, IsObject, IsVectorObj ],
    function( dst, c, src )
    local i;

    for i in [ 1 .. Length( dst ) ] do
      dst[i]:= dst[i] + c * src[i];
    od;
    end );

InstallMethod( AddVector,
    "for two vector objects, an object, two pos. integers",
    [ IsVectorObj and IsMutable, IsVectorObj, IsObject, IsPosInt, IsPosInt ],
    function( dst, src, c, from, to )
    local i;

    for i in [ from .. to ] do
      dst[i]:= dst[i] + src[i] * c;
    od;
    end );

InstallMethod( AddVector,
    "for a vector object, an object, a vector object, two pos. integers",
    [ IsVectorObj and IsMutable, IsObject, IsVectorObj, IsPosInt, IsPosInt ],
    function( dst, c, src, from, to )
    local i;

    for i in [ from .. to ] do
      dst[i]:= dst[i] + c * src[i];
    od;
    end );


#############################################################################
##
#M  MultVectorLeft( <vec>, <mul>[, <from>, <to>] )
#M  MultVectorRight( <vec>, <mul>[, <from>, <to>] )
##
##  Note that 'MultVector' is declared as a synonym for 'MultVectorLeft' in
##  'lib/listcoef.gd'.
##
InstallMethod( MultVectorLeft,
  "generic method for a mutable vector object, and an object",
  [ IsVectorObj and IsMutable, IsObject ],
  function( v, s )
    local i;
    for i in [1 .. Length(v)] do
      v[i] := s * v[i];
    od;
  end );

InstallMethod( MultVectorRight,
  "generic method for a mutable vector object, and an object",
  [ IsVectorObj and IsMutable, IsObject ],
  function( v, s )
    local i;
    for i in [1 .. Length(v)] do
      v[i] := v[i] * s;
    od;
  end );

InstallMethod( MultVectorLeft,
  "generic method for a mutable vector object, an object, an int, and an int",
  [ IsVectorObj and IsMutable, IsObject, IsInt, IsInt ],
  function( v, s, from, to )
    local i;
    for i in [from .. to] do
      v[i] := s * v[i];
    od;
  end );

InstallMethod( MultVectorRight,
  "generic method for a mutable vector object, an object, an int, and an int",
  [ IsVectorObj and IsMutable, IsObject, IsInt, IsInt ],
  function( v, s, from, to )
    local i;
    for i in [from .. to] do
      v[i] := v[i] * s;
    od;
  end );


#############################################################################
##
##  Arithmetical operations for matrix objects
##


#############################################################################
##
#M  <M1> + <M2>
#M  <M1> - <M2>
#M  <s> * <M>
#M  <M> * <s>
#M  <M1> * <M2>
#M  <M> / <s>
#M  <M> ^ <n>
##
##  <#GAPDoc Label="MatrixObj_BinaryArithmetics">
##  <ManSection>
##  <Heading>Binary Arithmetical Operations for Matrix Objects</Heading>
##  <Meth Name="\+" Arg="M1, M2" Label="for two matrix objects"/>
##  <Meth Name="\-" Arg="M1, M2" Label="for two matrix objects"/>
##  <Meth Name="\*" Arg="s, M" Label="for scalar and matrix object"/>
##  <Meth Name="\*" Arg="M, s" Label="for Matrix object and scalar"/>
##  <Meth Name="\*" Arg="M1, M2" Label="for two matrix objects"/>
##  <Meth Name="\/" Arg="M, s" Label="for matrix object and scalar"/>
##  <Meth Name="\^" Arg="M, n" Label="for matrix object and integer"/>
##
##  <Description>
##  The sum and the difference, respectively,
##  of two matrix objects <A>M1</A> and <A>M2</A>
##  is a new fully mutable matrix object whose entries are the sums and the
##  differences of the entries of the arguments.
##  <P/>
##  The product of a scalar <A>s</A> and a matrix object <A>M</A> (from the
##  left or from the right) is a new fully mutable matrix object whose entries
##  are the corresponding products.
##  <P/>
##  The product of two matrix objects <A>M1</A> and <A>M2</A> is a new fully
##  mutable matrix object; if both <A>M1</A> and <A>M2</A> are in the filter
##  <Ref Filt="IsOrdinaryMatrix"/> then the entries of the result are those
##  of the ordinary matrix product.
##  <P/>
##  The quotient of a matrix object <A>M</A> and a scalar <A>s</A>
##  is a new fully mutable matrix object whose entries are the corresponding
##  quotients.
##  <P/>
##  For a nonempty square matrix object <A>M</A> over an associative
##  base domain, and a positive integer <A>n</A>,
##  <A>M</A><C>^</C><A>n</A> is a fully mutable matrix object whose entries
##  are those of the <A>n</A>-th power of <A>M</A>.
##  If <A>n</A> is zero then <A>M</A><C>^</C><A>n</A> is an identity matrix,
##  and if <A>n</A> is a negative integer and <A>M</A> is invertible then
##  <A>M</A><C>^</C><A>n</A> is the (<C>-</C><A>n</A>)-th power of the
##  inverse of <A>M</A>.
##  <P/>
##  All this is defined only if the matrix objects have the same dimensions and
##  are defined over the same base domain and have the same representation,
##  and if the products with the given scalar belong to the base domain;
##  otherwise it is not specified what happens.
##  If the result is a matrix object then it has the same representation and
##  the same base domain as the given matrix object(s).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InstallMethod( \+,
    "for two matrix objects",
    [ IsMatrixObj, IsMatrixObj ],
    -SUM_FLAGS,
    { M1, M2 } -> Matrix( Unpack( M1 ) + Unpack( M2 ), M1 ) );

InstallMethod( \-,
    "for two matrix objects",
    [ IsMatrixObj, IsMatrixObj ],
    -SUM_FLAGS,
    { M1, M2 } -> Matrix( Unpack( M1 ) - Unpack( M2 ), M1 ) );

InstallMethod( \*,
    "for two ordinary matrix objects (ordinary matrix product)",
    [ IsMatrixObj and IsOrdinaryMatrix, IsMatrixObj and IsOrdinaryMatrix ],
    -SUM_FLAGS,
    { M1, M2 } -> Matrix( Unpack( M1 ) * Unpack( M2 ), M1 ) );

InstallMethod( \*,
    "for matrix object and scalar",
    [ IsMatrixObj, IsScalar ],
    -SUM_FLAGS,
    { M, s } -> Matrix( Unpack( M ) * s, M ) );

InstallMethod( \*,
    "for scalar and matrix object",
    [ IsScalar, IsMatrixObj ],
    -SUM_FLAGS,
    { s, M } -> Matrix( s * Unpack( M ), M ) );

InstallMethod( \/,
    "for matrix object and scalar",
    [ IsMatrixObj, IsScalar ],
    -SUM_FLAGS,
    { M, s } -> Matrix( Unpack( M ) / s, M ) );

#T no default methods should be needed for M^n, n an integer!


############################################################################
##
#M  \*( <vecobj>, <matobj> )
#M  \*( <matobj>, <vecobj> )
#M  \^( <vecobj>, <matobj> )
##
##  One of &GAP;'s strategies to study (small) matrix groups is
##  to compute a faithful permutation representations of the action on
##  orbits of row vectors, via right multiplication,
##  see <Ref Sect="Nice Monomorphisms"/>.
##  The code in question uses <Ref Func="OnPoints"/> as the default action,
##  which means that the operation <Ref Oper="\^"/> gets called.
##  Therefore, we declare this operation for the case that the two arguments
##  are in <Ref Cat="IsVectorObj"/> and <Ref Cat="IsMatrixOrMatrixObj"/>,
##  and install the multiplication as a method for this situation;
##  thus one need not install individual <Ref Oper="\^"/> methods
##  in special cases.
##  <P/>
##  For other code dealing with the multiplication of vectors and matrices,
##  it is recommended to use the multiplication <Ref Oper="\*"/> directly.
##
InstallMethod( \*,
    [ IsVectorObj, IsMatrixObj ],
    { v, M } -> Vector( Unpack( v ) * Unpack( M ), v ) );

InstallMethod( \*,
    [ IsMatrixObj, IsVectorObj ],
    { M, v } -> Vector( Unpack( M ) * Unpack( v ), v ) );

InstallOtherMethod( \^,
    [ IsVectorObj, IsMatrixObj ],
    \* );


############################################################################
##
#M  IsEmptyMatrix( <matobj> )
##
InstallMethod( IsEmptyMatrix,
  [ IsMatrixOrMatrixObj ],
  mat -> NrRows(mat) = 0 or NrCols(mat) = 0
);


#############################################################################
##
#M  ShallowCopy( <vec> )
##
InstallMethod( ShallowCopy,
    [ IsVectorObj ],
    -SUM_FLAGS,
    v -> Vector( Unpack( v ), v ) );


#############################################################################
##
#M  MutableCopyMatrix( <M> )
##
InstallMethod( MutableCopyMatrix,
    [ IsMatrixOrMatrixObj ],
    -SUM_FLAGS,
    M -> Matrix( Unpack( M ), M ) );


#############################################################################
##
#M  CopySubMatrix( <src>, <dst>, <srcrows>, <dstrows>, <srccols>, <dstcols> )
##
InstallMethod( CopySubMatrix,
    [ IsMatrixOrMatrixObj and IsMutable, IsMatrixOrMatrixObj, IsList, IsList, IsList, IsList ],
    function( src, dst, srcrows, dstrows, srccols, dstcols )
    local i, j;

    for i in [ 1 .. Length( srcrows ) ] do
      for j in [ 1 .. Length( srccols ) ] do
        dst[ dstrows[i], dstcols[j] ]:= src[ srcrows[i], srccols[j] ];
      od;
    od;
    end );


#############################################################################
##
#M  TransposedMatImmutable( <M> )
##
InstallMethod( TransposedMatImmutable,
    [ IsMatrixOrMatrixObj ],
    M -> MakeImmutable( TransposedMatMutable( M ) ) );


#############################################################################
##
#M  AdditiveInverseMutable( <v> )
#M  AdditiveInverseSameMutability( <v> )
#M  ZeroMutable( <v> )
#M  ZeroSameMutability( <v> )
#M  IsZero( <v> )
#M  Characteristic( <v> )
##
##  <#GAPDoc Label="VectorObj_UnaryArithmetics">
##  <ManSection>
##  <Heading>Unary Arithmetical Operations for Vector Objects</Heading>
##  <Oper Name="AdditiveInverseMutable" Arg="v"
##   Label="for vector object"/>
##  <Oper Name="AdditiveInverseSameMutability" Arg="v"
##   Label="for vector object"/>
##  <Oper Name="ZeroMutable" Arg="v" Label="for vector object"/>
##  <Oper Name="ZeroSameMutability" Arg="v" Label="for vector object"/>
##  <Prop Name="IsZero" Arg="v" Label="for vector object"/>
##  <Attr Name="Characteristic" Arg="v" Label="for vector object"/>
##
##  <Returns>a vector object</Returns>
##  <Description>
##  For a vector object <A>v</A>,
##  the operations for computing the additive inverse with prescribed
##  mutability return a vector object with the same
##  <Ref Attr="ConstructingFilter" Label="for a vector object"/> and
##  <Ref Attr="BaseDomain" Label="for a vector object"/> values,
##  such that the sum with <A>v</A> is a zero vector.
##  It is not specified what happens if the base domain does not admit
##  the additive inverses of the entries.
##  <P/>
##  Analogously, the operations for computing a zero vector with
##  prescribed mutability return a vector object compatible with <A>v</A>.
##  <P/>
##  <Ref Prop="IsZero" Label="for vector object"/> returns <K>true</K> if
##  all entries in <A>v</A> are zero, and <K>false</K> otherwise.
##  <P/>
##  <Ref Attr="Characteristic" Label="for vector object"/> returns
##  the corresponding value of the
##  <Ref Attr="BaseDomain" Label="for a vector object"/> value of <A>v</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  We do not need default methods for 'AdditiveInverseImmutable' and
##  'ZeroImmutable' for vector objects because these methods
##  (create a mutable version and make it immutable)
##  are already installed more generally.
##
InstallMethod( AdditiveInverseMutable,
    [ IsVectorObj ],
    v -> Vector( AdditiveInverseMutable( Unpack( v ) ), v ) );

InstallMethod( AdditiveInverseSameMutability,
    [ IsVectorObj ],
    function( v )
    if IsMutable( v ) then
      return AdditiveInverseMutable( v );
    else
      return AdditiveInverseImmutable( v );
    fi;
    end );

InstallMethod( ZeroMutable,
    [ IsVectorObj ],
    v -> Vector( ZeroMutable( Unpack( v ) ), v ) );

InstallMethod( ZeroSameMutability,
    [ IsVectorObj ],
    function( v )
    if IsMutable( v ) then
      return ZeroMutable( v );
    else
      return ZeroImmutable( v );
    fi;
    end );

InstallMethod( IsZero,
    [ IsVectorObj ],
    v -> IsZero( Unpack( v ) ) );

InstallMethod( Characteristic,
    [ IsVectorObj ],
    -SUM_FLAGS,
    v -> Characteristic( BaseDomain( v ) ) );


#############################################################################
##
#M  AdditiveInverseMutable( <M> )
#M  AdditiveInverseSameMutability( <M> )
#M  ZeroMutable( <M> )
#M  ZeroSameMutability( <M> )
#M  OneMutable( <M> )
#M  OneSameMutability( <M> )
#M  InverseMutable( <M> )
#M  InverseSameMutability( <M> )
#M  IsZero( <M> )
#M  Characteristic( <M> )
##
##  <#GAPDoc Label="MatrixObj_UnaryArithmetics">
##  <ManSection>
##  <Heading>Unary Arithmetical Operations for Matrix Objects</Heading>
##  <Oper Name="AdditiveInverseMutable" Arg="M"
##   Label="for matrix object"/>
##  <Oper Name="AdditiveInverseSameMutability" Arg="M"
##   Label="for matrix object"/>
##  <Oper Name="ZeroMutable" Arg="M" Label="for matrix object"/>
##  <Oper Name="ZeroSameMutability" Arg="M" Label="for matrix object"/>
##  <Oper Name="OneMutable" Arg="M" Label="for matrix object"/>
##  <Oper Name="OneSameMutability" Arg="M" Label="for matrix object"/>
##  <Oper Name="InverseMutable" Arg="M" Label="for matrix object"/>
##  <Oper Name="InverseSameMutability" Arg="M" Label="for matrix object"/>
##  <Prop Name="IsZero" Arg="M" Label="for matrix object"/>
##  <Prop Name="IsOne" Arg="M" Label="for matrix object"/>
##  <Attr Name="Characteristic" Arg="M" Label="for matrix object"/>
##
##  <Returns>a matrix object</Returns>
##  <Description>
##  For a vector object <A>M</A>,
##  the operations for computing the additive inverse with prescribed
##  mutability return a matrix object with the same
##  <Ref Attr="ConstructingFilter" Label="for a matrix object"/> and
##  <Ref Attr="BaseDomain" Label="for a matrix object"/> values,
##  such that the sum with <A>M</A> is a zero matrix.
##  It is not specified what happens if the base domain does not admit
##  the additive inverses of the entries.
##  <P/>
##  Analogously, the operations for computing a zero matrix with
##  prescribed mutability return a matrix object compatible with <A>M</A>.
##  <P/>
##  The operations for computing an identity matrix with
##  prescribed mutability return a matrix object compatible with <A>M</A>,
##  provided that the base domain admits this and <A>M</A> is square and
##  nonempty.
##  <P/>
##  Analogously, the operations for computing an inverse matrix with
##  prescribed mutability return a matrix object compatible with <A>M</A>,
##  provided that <A>M</A> is invertible.
##  <!-- over its base domain? -->
##  (If <A>M</A> is not invertible then the operations return <K>fail</K>.)
##  <P/>
##  <Ref Prop="IsZero" Label="for matrix object"/> returns <K>true</K> if
##  all entries in <A>M</A> are zero, and <K>false</K> otherwise.
##  <Ref Prop="IsOne" Label="for matrix object"/> returns <K>true</K> if
##  <A>M</A> is nonempty and square and contains the identity of the
##  base domain in the diagonal, and zero in all other places.
##  <P/>
##  <Ref Attr="Characteristic" Label="for matrix object"/> returns
##  the corresponding value of the
##  <Ref Attr="BaseDomain" Label="for a matrix object"/> value of <A>M</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  We do not need default methods for 'AdditiveInverseImmutable',
##  'ZeroImmutable', 'OneImmutable', 'InverseImmutable',
##  for matrix objects because these methods
##  (create a mutable version and make it immutable)
##  are already installed more generally.
##
InstallMethod( AdditiveInverseMutable,
    [ IsMatrixObj ],
    M -> Matrix( AdditiveInverseMutable( Unpack( M ) ), M ) );

InstallMethod( AdditiveInverseSameMutability,
    [ IsMatrixOrMatrixObj ],
    function( M )
    if IsMutable( M ) then
      return AdditiveInverseMutable( M );
    else
      return AdditiveInverseImmutable( M );
    fi;
    end );

InstallMethod( ZeroMutable,
    [ IsMatrixObj ],
    M -> ZeroMatrix( NumberRows( M ), NumberColumns( M ), M ) );

InstallMethod( ZeroSameMutability,
    [ IsMatrixOrMatrixObj ],
    function( M )
    if IsMutable( M ) then
      return ZeroMutable( M );
    else
      return ZeroImmutable( M );
    fi;
    end );

InstallMethod( OneMutable,
    [ IsMatrixObj ],
    M -> IdentityMatrix( NumberRows( M ), M ) );

InstallMethod( OneSameMutability,
    [ IsMatrixOrMatrixObj ],
    function( M )
    if IsMutable( M ) then
      return OneMutable( M );
    else
      return OneImmutable( M );
    fi;
    end );

InstallMethod( InverseMutable,
    [ IsMatrixObj ],
    M -> Matrix( InverseMutable( Unpack( M ) ), M ) );

InstallMethod( InverseSameMutability,
    [ IsMatrixOrMatrixObj ],
    function( M )
    if IsMutable( M ) then
      return InverseMutable( M );
    else
      return InverseImmutable( M );
    fi;
    end );

InstallMethod( IsZero,
    [ IsRowListMatrix and IsMatrixObj ],
    function( mat )
    local ncols, row;

    ncols:= NrCols( mat );
    for row in mat do
      if PositionNonZero( row ) <= ncols then
        return false;
      fi;
    od;
    return true;
    end );

InstallMethod( IsOne,
    [ IsRowListMatrix and IsMatrixObj ],
    function( mat )
    local ncols, i, row;

    ncols:= NrCols( mat );
    for i in [1 .. NrRows( mat )] do
      row := mat[i];
      if PositionNonZero( row ) <> i or not IsOne( row[i] ) then
        return false;
      fi;
      if PositionNonZero( row, i ) <= ncols then
        return false;
      fi;
    od;
    return true;
    end );

InstallMethod( IsZero,
    [ IsMatrixObj ],
    M -> IsZero( Unpack( M ) ) );

InstallMethod( IsOne,
    [ IsMatrixObj ],
    M -> IsOne( Unpack( M ) ) );

InstallMethod( Characteristic,
    [ IsMatrixOrMatrixObj ],
    M -> Characteristic( BaseDomain( M ) ) );

InstallOtherMethod(DefaultFieldOfMatrix,[IsMatrixOrMatrixObj],BaseDomain);


#############################################################################
##
#M  Display( <obj> )
#M  ViewObj( <obj> )
#M  PrintObj( <obj> )
#M  DisplayString( <obj> )
#M  ViewString( <obj> )
#M  PrintString( <obj> )
#M  String( <obj> )
##
##  According to the Section "View and Print" in the GAP Reference Manual,
##  we need methods (only) for
##  'String' (which then covers 'PrintString' and 'PrintObj'),
##  'ViewString' (which then covers 'ViewObj'),
##  and 'DisplayString' (which then covers 'Display').
##
##  By default, we *view* and *display* vector objects and matrix objects as
##  '<vector object of length ... over ...>' and
##  '<matrix object of dimensions ... over ...>', respectively,
##  and to *print* them as 'NewVector( ... )' and 'NewMatrix( ... )',
##  respectively.
##  (Most likely, this will be overloaded for any type of such objects.)
##
BindGlobal( "ViewStringForVectorObj",
    v -> Concatenation( "<vector object of length ", String( Length( v ) ),
             " over ", String( BaseDomain( v ) ), ">" ) );

InstallMethod( ViewString,
    [ IsVectorObj ],
    ViewStringForVectorObj );

InstallMethod( DisplayString,
    [ IsVectorObj ],
    ViewStringForVectorObj );

InstallMethod( String,
    [ IsVectorObj ],
    v -> Concatenation( "NewVector( ",
             NameFunction( ConstructingFilter( v ) ), ", ",
             String( BaseDomain( v ) ), ", ",
             String( Unpack( v ) ), " )" ) );

BindGlobal( "ViewStringForMatrixObj",
    M -> Concatenation( "<matrix object of dimensions ",
             String( NumberRows( M ) ), "x", String( NumberColumns( M ) ),
             " over ", String( BaseDomain( M ) ), ">" ) );

InstallMethod( ViewString,
    [ IsMatrixOrMatrixObj ],
    ViewStringForMatrixObj );

InstallMethod( DisplayString,
    [ IsMatrixOrMatrixObj ],
    ViewStringForMatrixObj );

InstallMethod( String,
    [ IsMatrixObj ],
    M -> Concatenation( "NewMatrix( ",
               NameFunction( ConstructingFilter( M ) ), ", ",
               String( BaseDomain( M ) ), ", ",
               String( NumberColumns( M ) ), ", ",
               String( Unpack( M ) ), " )" ) );


############################################################################
##
#M  CompatibleVector( <M> )
##
InstallMethod( CompatibleVector,
    "for a matrix or matrix object",
    [ IsMatrixOrMatrixObj ],
    M -> NewZeroVector( CompatibleVectorFilter( M ), BaseDomain( M ),
                        NumberRows( M ) ) );


############################################################################
##
#M  RowsOfMatrix( <M> )
##
InstallMethod( RowsOfMatrix,
    "for a matrix or matrix object",
    [ IsMatrixOrMatrixObj ],
    function( M )
    local R, f;

    R:= BaseDomain( M );
    f:= CompatibleVectorFilter( M );
    return List( Unpack( M ), row -> Vector( f, R, row ) );
    end );


############################################################################
##
##  Backwards compatibility
##
##  We should remove the methods as soon as they are not used anymore.
##

InstallMethod( DimensionsMat,
    "for a matrix or matrix object",
    [ IsMatrixOrMatrixObj ],
    M -> [ NumberRows( M ), NumberColumns( M ) ] );

InstallOtherMethod( Randomize,
    "for random source as 2nd argument: switch arguments",
    [ IsObject and IsMutable, IsRandomSource ],
    { obj, rs } -> Randomize( rs, obj ) );

InstallMethod( Length,
    "for a matrix or matrix object",
    [ IsMatrixOrMatrixObj ],
    -SUM_FLAGS,
    NumberRows );

# Install fallback methods for m[i,j] which delegate to ASS_LIST / ELM_LIST
# for code using an intermediate version of the MatrixObj specification
# (any package installing methods for MatElm resp. SetMatElm
# should be fine without these). We lower the rank so that these are only
# used as a last resort.
InstallMethod( \[\,\], "for a matrix object and two positions",
  [ IsMatrixOrMatrixObj, IsPosInt, IsPosInt ],
  {} -> -RankFilter(IsMatrixOrMatrixObj),
  ELM_LIST );

InstallMethod( \[\,\]\:\=, "for a matrix object, two positions, and an object",
  [ IsMatrixOrMatrixObj and IsMutable, IsPosInt, IsPosInt, IsObject ],
  {} -> -RankFilter(IsMatrixOrMatrixObj),
  ASS_LIST );

############################################################################
# Elementary matrix operations
############################################################################

InstallMethod( MultMatrixRowLeft, "for a mutable matrix object, a row number, and a scalar",
  [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsObject ],
  function( mat, row, scalar )
    local i;

    for i in [1..NrCols(mat)] do
        mat[row,i] := scalar * mat[row,i];
    od;

  end );

InstallEarlyMethod( MultMatrixRowLeft,
  function( mat, i, scalar )
    if IsPlistRep(mat) then
      mat[i] := scalar * mat[i];
    else
      TryNextMethod();
    fi;
  end );

############################################################################

InstallMethod( MultMatrixColumnRight, "for a mutable matrix object, a column number, and a scalar",
  [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsObject ],
  function( mat, column, scalar )
    local i;

    for i in [1..NrRows(mat)] do
        mat[i,column] := mat[i,column] * scalar;
    od;

  end );

InstallEarlyMethod( MultMatrixColumnRight,
  function( mat, i, scalar )
    local row;
    if IsPlistRep(mat) then
      for row in mat do
          row[i] := row[i] * scalar;
      od;
    else
      TryNextMethod();
    fi;
  end );

############################################################################

InstallMethod( MultMatrixRowRight, "for a mutable matrix object, a row number, and a scalar",
  [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsObject ],
  function( mat, row, scalar )
      local i;

    for i in [1..NrCols(mat)] do
        mat[row,i] := mat[row,i] * scalar;
    od;

  end );

InstallEarlyMethod( MultMatrixRowRight,
  function( mat, i, scalar )
    if IsPlistRep(mat) then
      mat[i] := mat[i] * scalar;
    else
      TryNextMethod();
    fi;
  end );

############################################################################

InstallMethod( MultMatrixColumnLeft, "for a mutable matrix object, a column number, and a scalar",
  [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsObject ],
  function( mat, column, scalar )
    local i;

    for i in [1..NrRows(mat)] do
        mat[i,column] := scalar * mat[i,column];
    od;

  end );

InstallEarlyMethod( MultMatrixColumnLeft,
  function( mat, i, scalar )
    local row;
    if IsPlistRep(mat) then
      for row in mat do
          row[i] := scalar * row[i];
      od;
    else
      TryNextMethod();
    fi;
  end );

############################################################################

InstallMethod( AddMatrixRowsLeft, "for a mutable matrix object, two row numbers, and a scalar",
  [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsInt, IsObject ] ,
  function( mat, row1, row2, scalar )
    local i;

    for i in [1..NrCols(mat)] do
        mat[row1,i] := mat[row1,i] + scalar * mat[row2,i];
    od;

  end );

InstallEarlyMethod( AddMatrixRowsLeft,
  function( mat, i, j, scalar )
    if IsPlistRep(mat) then
      mat[i] := mat[i] + scalar * mat[j];
    else
      TryNextMethod();
    fi;
  end );

 ############################################################################

InstallMethod( AddMatrixRowsRight, "for a mutable matrix object, two row numbers, and a scalar",
  [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsInt, IsObject ] ,
  function( mat, row1, row2, scalar )
    local i;

    for i in [1..NrCols(mat)] do
        mat[row1,i] := mat[row1,i] + mat[row2,i] * scalar;
    od;

  end );

InstallEarlyMethod( AddMatrixRowsRight,
  function( mat, i, j, scalar )
    if IsPlistRep(mat) then
      mat[i] := mat[i] + mat[j] * scalar;
    else
      TryNextMethod();
    fi;
  end );

############################################################################

InstallMethod( AddMatrixColumnsRight, "for a mutable matrix object, two column numbers, and a scalar",
  [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsInt, IsObject ] ,
  function( mat, column1, column2, scalar )
    local i;

    for i in [1..NrRows(mat)] do
        mat[i,column1] := mat[i,column1] + mat[i,column2] * scalar;
    od;

  end );

InstallEarlyMethod( AddMatrixColumnsRight,
  function( mat, i, j, scalar )
    local row;
    if IsPlistRep(mat) then
      for row in mat do
          row[i] := row[i] + row[j] * scalar;
      od;
    else
      TryNextMethod();
    fi;
  end );

############################################################################

InstallMethod( AddMatrixColumnsLeft, "for a mutable matrix object, two column numbers, and a scalar",
  [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsInt, IsObject ] ,
  function( mat, column1, column2, scalar )
    local i;

    for i in [1..NrRows(mat)] do
        mat[i,column1] := mat[i,column1] + scalar * mat[i,column2];
    od;

  end );

InstallEarlyMethod( AddMatrixColumnsLeft,
  function( mat, i, j, scalar )
    local row;
    if IsPlistRep(mat) then
      for row in mat do
          row[i] := row[i] + scalar * row[j];
      od;
    else
      TryNextMethod();
    fi;
  end );

############################################################################

InstallMethod( SwapMatrixRows, "for a mutable matrix object, and two row numbers",
  [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsInt ],
  function( mat, row1, row2 )
    local temp, i;

    if row1 <> row2 then
        for i in [1..NrCols(mat)] do
            temp := mat[row1,i];
            mat[row1,i] := mat[row2,i];
            mat[row2,i] := temp;
        od;
    fi;

  end );

############################################################################

InstallMethod( SwapMatrixColumns, "for a mutable matrix object, and two column numbers",
  [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsInt ],
  function( mat, column1, column2 )
    local temp, i;

    if column1 <> column2 then
        for i in [1..NrRows(mat)] do
            temp := mat[i,column1];
            mat[i,column1] := mat[i,column2];
            mat[i,column2] := temp;
        od;
    fi;

  end );


############################################################################
##  Fallback method for DeterminantMatrix
InstallMethod(DeterminantMatrix, ["IsMatrixObj"],
function( mat )
  return DeterminantMat( Unpack( mat ) );
end);

