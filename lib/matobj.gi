############################################################################
#
# matobj.gi
#                                                        by Max Neunhöffer
#
##  Copyright (C) 2007  Max Neunhöffer, University of St Andrews
##  This file is free software, see license information at the end.
#
# This file contains some generic methods for the vector/matrix interface
# defined in matobj1.gd and matobj2.gd.
#
############################################################################


InstallMethod( WeightOfVector, "generic method",
  [IsRowVectorObj],
  function(v)
    local i,n;
    n := 0;
    for i in [1..Length(v)] do
        if not(IsZero(v[i])) then
            n := n + 1;
        fi;
    od;
    return n;
  end );

InstallMethod( DistanceOfVectors, "generic method",
  [IsRowVectorObj, IsRowVectorObj],
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

InstallMethod( Matrix, "generic convenience method with 2 args",
  [IsList,IsMatrixObj],
  function( l, m )
    if Length(l) = 0 then
        Error("Matrix: two-argument version not allowed with empty first arg");
        return;
    fi;
    if not(IsList(l[1]) or IsRowVectorObj(l[1])) then
        Error("Matrix: flat data not supported in two-argument version");
        return;
    fi;
    return Matrix(l,Length(l[1]),m);
  end );

InstallMethod( Unfold, "for a matrix object, and a vector object",
  [ IsMatrixObj, IsRowVectorObj ],
  function( m, w )
    local v,i,l;
    if Length(m) = 0 then
        return ZeroVector(0,w);
    else
        l := RowLength(m);
        v := ZeroVector(Length(m)*l,w);
        for i in [1..Length(m)] do
            CopySubVector( m[i], v, [1..l], [(i-1)*l+1..i*l] );
        od;
        return v;
    fi;
  end );

InstallMethod( Fold, "for a vector, a positive int, and a matrix",
  [ IsRowVectorObj, IsPosInt, IsMatrixObj ],
  function( v, rl, t )
    local rows,i,tt,m;
    m := Matrix([],rl,t);
    tt := ZeroVector(rl,v);
    for i in [1..Length(v)/rl] do
        CopySubVector(v,tt,[(i-1)*rl+1..i*rl],[1..rl]);
        Add(m,ShallowCopy(tt));
    od;
    return m;
  end );

InstallMethod( CompanionMatrix, "for a polynomial and a matrix",
  [ IsUnivariatePolynomial, IsMatrixObj ],
  function( po, m )
    local l, n, q, ll, i, bd, one;
    bd := BaseDomain(m);
    one := One(bd);
    l := CoefficientsOfUnivariatePolynomial(po);
    n := Length(l)-1;
    if not(IsOne(l[n+1])) then
        Error("CompanionMatrix: polynomial is not monic");
        return fail;
    fi;
    l := Vector(-l{[1..n]},CompatibleVector(m));
    ll := 0*[1..n];
    ll[n] := l;
    for i in [1..n-1] do
        ll[i] := ZeroMutable(l);
        ll[i][i+1] := one;
    od;
    return Matrix(ll,n,m);
  end );

InstallMethod( KroneckerProduct, "for two matrices",
  [ IsMatrixObj, IsMatrixObj ],
  function( A, B )
    local rowsA, rowsB, colsA, colsB, newclass, AxB, i, j;

    if not(IsIdenticalObj(BaseDomain(A),BaseDomain(B))) then
        Error("KroneckerProduct: Matrices not over same base domain");
        return;
    fi;

    rowsA := Length(A);
    colsA := RowLength(A);
    rowsB := Length(B);
    colsB := RowLength(B);

    AxB := ZeroMatrix( rowsA * rowsB, colsA * colsB, A );

    # Cache matrices
    # not implemented yet

    for i in [1..rowsA] do
      for j in [1..colsA] do
        CopySubMatrix( A[i][j] * B, AxB,
                [ 1 .. rowsB ], [ rowsB * (i-1) + 1 .. rowsB * i ],
                [ 1 .. colsB ], [ (j-1) * colsB + 1 .. j * colsB ] );
      od;
    od;

    if not(IsMutable(A)) and not(IsMutable(B)) then
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

InstallGlobalFunction( MakeVector,
  function( arg )
    local bd,l,ty;
    if Length(arg) = 1 then
        l := arg[1];
        bd := DefaultField(l);
    elif Length(arg) <> 2 then
        Error("usage: MakeVector( <list> [,<basedomain>] )");
        return fail;
    else
        l := arg[1];
        bd := arg[2];
    fi;
    if IsFinite(bd) and IsField(bd) and Size(bd) = 2 then
        ty := IsGF2VectorRep;
    elif IsFinite(bd) and IsField(bd) and Size(bd) <= 256 then
        ty := Is8BitVectorRep;
    else
        ty := IsPlistVectorRep;
    fi;
    return NewRowVector(ty,bd,l);
  end );

InstallGlobalFunction( MakeMatrix,
  function( arg )
    local bd,l,len,rowlen,ty;
    if Length(arg) = 1 then
        l := arg[1];
        bd := DefaultFieldOfMatrix(l);
    elif Length(arg) <> 2 then
        Error("usage: MakeVector( <list> [,<basedomain>] )");
        return fail;
    else
        l := arg[1];
        bd := arg[2];
    fi;
    len := Length(l);
    if len = 0 then
        Error("does not work for matrices with zero rows");
        return fail;
    fi;
    rowlen := Length(l[1]);
    if IsFinite(bd) and IsField(bd) and Size(bd) = 2 then
        ty := IsGF2MatrixRep;
    elif IsFinite(bd) and IsField(bd) and Size(bd) <= 256 then
        ty := Is8BitMatrixRep;
    else
        ty := IsPlistMatrixRep;
    fi;
    return NewMatrix(ty,bd,rowlen,l);
  end );

InstallMethod( ExtractSubVector, "generic method",
  [ IsRowVectorObj, IsList ],
  function( v, l )
    return v{l};
  end );

InstallOtherMethod( ScalarProduct, "generic method",
  [ IsRowVectorObj, IsRowVectorObj ],
  function( v, w )
    local bd,i,s;
    bd := BaseDomain(v);
    s := Zero(bd);
    if Length(v) <> Length(w) then
        Error("vectors must have equal length");
        return fail;
    fi;
    for i in [1..Length(v)] do
        s := s + v[i]*w[i];
    od;
    return s;
  end );

InstallMethod( TraceMat, "generic method",
  [ IsMatrixObj ],
  function( m )
    local bd,i,s;
    bd := BaseDomain(m);
    s := Zero(bd);
    if Length(m) <> RowLength(m) then
        Error("matrix must be square");
        return fail;
    fi;
    for i in [1..Length(m)] do
        s := s + MatElm(m,i,i);
    od;
    return s;
  end );

