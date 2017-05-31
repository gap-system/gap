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


# TEMPORARY HACK
InstallOtherMethod( \[\], [ IsMatrix, IsList ], {m,l} -> m[l[1]][l[2]] );
InstallOtherMethod( \[\]\:\=, [ IsMatrix and IsMutable, IsList, IsObject ], function(m,l,o) m[l[1]][l[2]] := o; end);

InstallOtherMethod( \[\], [ IsMatrixObj, IsList ], {m,l} -> MatElm(m,l[1],l[2]));
InstallOtherMethod( \[\]\:\=, [ IsMatrixObj, IsList, IsObject ], function(m,l,o) SetMatElm(m, l[1], l[2], o); end);



InstallMethod( WeightOfVector, "generic method",
  [IsVectorObj],
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

InstallMethod( DistanceOfVectors, "generic method",
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
BindGlobal( "DefaultMatrixRepForBaseDomain",
function( basedomain )
    if IsFinite(basedomain) and IsField(basedomain) and Size(basedomain) = 2 then
        return IsGF2MatrixRep;
    elif IsFinite(basedomain) and IsField(basedomain) and Size(basedomain) <= 256 then
        return Is8BitMatrixRep;
    fi;
    return IsPlistMatrixRep;
end);

#
#
#
InstallMethod( Matrix,
  [IsOperation, IsSemiring, IsList, IsInt],
  function( rep, basedomain, list, nrCols )
    # TODO: adjust NewMatrix to use same arg order as Matrix (or vice-versa)
    return NewMatrix( rep, basedomain, nrCols, list );
  end );

InstallMethod( Matrix,
  [IsOperation, IsSemiring, IsList],
  function( rep, basedomain, list )
    if Length(list) = 0 then Error("list must be not empty; to create empty matrices, please specify nrCols"); fi;
    return NewMatrix( rep, basedomain, Length(list[1]), list );
  end );

InstallMethod( Matrix,
  [IsOperation, IsSemiring, IsMatrixObj],
  function( rep, basedomain, mat )
    # TODO: can we do better? encourage MatrixObj implementors to overload this?
    return NewMatrix( rep, basedomain, NrCols(mat), Unpack(mat) );
  end );

#
#
#
InstallMethod( Matrix,
  [IsSemiring, IsList, IsInt],
  function( basedomain, list, nrCols )
    local rep;
    rep := DefaultMatrixRepForBaseDomain(basedomain);
    return NewMatrix( rep, basedomain, nrCols, list );
  end );

InstallMethod( Matrix,
  [IsSemiring, IsList],
  function( basedomain, list )
    local rep;
    if Length(list) = 0 then Error("list must be not empty"); fi;
    rep := DefaultMatrixRepForBaseDomain(basedomain);
    return NewMatrix( rep, basedomain, Length(list[1]), list );
  end );

InstallMethod( Matrix,
  [IsSemiring, IsMatrixObj],
  function( basedomain, mat )
    # TODO: can we do better? encourage MatrixObj implementors to overload this?
    return NewMatrix( DefaultMatrixRepForBaseDomain(basedomain), basedomain, NrCols(mat), Unpack(mat) );
  end );

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
    local rep, basedomain;
    if Length(list) = 0 then Error("list must be not empty"); fi;
    if Length(list[1]) = 0 then Error("list[1] must be not empty, please specify base domain explicitly"); fi;
    basedomain := DefaultScalarDomainOfMatrixList([list]);
    rep := DefaultMatrixRepForBaseDomain(basedomain);
    return NewMatrix( rep, basedomain, Length(list[1]), list );
  end );

#
# matrix constructors using example objects (as last argument)
#
InstallMethod( Matrix,
  [IsList, IsInt, IsMatrixObj],
  function( list, nrCols, example )
    return NewMatrix( ConstructingFilter(example), BaseDomain(example), nrCols, list );
  end );

InstallMethod( Matrix, "generic convenience method with 2 args",
  [IsList, IsMatrixObj],
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
  [IsMatrixObj, IsMatrixObj],
  function( mat, example )
    # TODO: can we avoid using Unpack? resp. make this more efficient
    # perhaps adjust NewMatrix to take an IsMatrixObj?
    return NewMatrix( ConstructingFilter(example), BaseDomain(example), NrCols(mat), Unpack(mat) );
  end );

#
#
#
InstallMethod( ZeroMatrix,
  [IsInt, IsInt, IsMatrixObj],
  function( rows, cols, example )
    return ZeroMatrix( ConstructingFilter(example), BaseDomain(example), rows, cols );
  end );

InstallMethod( ZeroMatrix,
  [IsSemiring, IsInt, IsInt],
  function( basedomain, rows, cols )
    return ZeroMatrix( DefaultMatrixRepForBaseDomain(basedomain), basedomain, rows, cols );
  end );

InstallMethod( ZeroMatrix,
  [IsOperation, IsSemiring, IsInt, IsInt],
  function( rep, basedomain, rows, cols )
    # TODO: urge matrixobj implementors to overload this
    return NewMatrix( rep, basedomain, cols, ListWithIdenticalEntries( rows * cols, Zero(basedomain) ) );
  end );

#
#
#
InstallMethod( IdentityMatrix,
  [IsInt, IsMatrixObj],
  function( dim, example )
    return IdentityMatrix( ConstructingFilter(example), BaseDomain(example), dim );
  end );

InstallMethod( IdentityMatrix,
  [IsSemiring, IsInt],
  function( basedomain, dim )
    return IdentityMatrix( DefaultMatrixRepForBaseDomain(basedomain), basedomain, dim );
  end );

InstallMethod( IdentityMatrix,
  [IsOperation, IsSemiring, IsInt],
  function( rep, basedomain, dim )
    # TODO: avoid using IdentityMat eventually
    return NewMatrix( rep, basedomain, dim, IdentityMat( dim, basedomain ) );
  end );



InstallMethod( Unfold, "for a matrix object, and a vector object",
  [ IsMatrixObj, IsVectorObj ],
  function( m, w )
    local v,i,l;
    if Length(m) = 0 then
        return ZeroVector(0,w);
    else
        l := NumberColumns(m);
        v := ZeroVector(Length(m)*l,w);
        for i in [1..Length(m)] do
            CopySubVector( m[i], v, [1..l], [(i-1)*l+1..i*l] );
        od;
        return v;
    fi;
  end );

InstallMethod( Fold, "for a vector, a positive int, and a matrix",
  [ IsVectorObj, IsPosInt, IsMatrixObj ],
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
    if not IsOne(l[n+1]) then
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
        CopySubMatrix( A[i][j] * B, AxB,
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
    return NewVector(ty,bd,l);
  end );

InstallMethod( ExtractSubVector, "generic method",
  [ IsVectorObj, IsList ],
  function( v, l )
    return v{l};
  end );

InstallOtherMethod( ScalarProduct, "generic method",
  [ IsVectorObj, IsVectorObj ],
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
    if NumberRows(m) <> NumberColumns(m) then
        Error("matrix must be square");
        return fail;
    fi;
    for i in [1..NumberRows(m)] do
        s := s + MatElm(m,i,i);
    od;
    return s;
  end );

#
# Compatibility code: Install MatrixObj methods for IsMatrix.
#
InstallOtherMethod( NumberRows, "for a plist matrix",
  [ IsMatrix ], Length);
InstallOtherMethod( NumberColumns, "for a plist matrix",
  [ IsMatrix ], m -> Length(m[1]) );
