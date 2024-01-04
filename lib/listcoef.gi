#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  The  '<Something>RowVector' functions operate  on row vectors, that is to
##  say (where it  makes sense) that the vectors  must have the  same length,
##  for example 'AddRowVector'  requires that  the  two involved row  vectors
##  have the same length.
##
##  The '<DoSomething>Coeffs' functions  operate  on row vectors  which might
##  have different lengths.  They will return the new length without counting
##  trailing zeros, however they will *not*  necessarily remove this trailing
##  zeros.  The  only  exception to this  rule  is 'RemoveOuterCoeffs'  which
##  returns the number of elements removed at the beginning.
##
##  The '<Something>Coeffs' functions operate on row vectors which might have
##  different lengths, the returned result will have trailing zeros removed.
##


#############################################################################
##
#M  AddRowVector( <list1>, <list2>, <mult>, <from>, <to> )
##
InstallMethod( AddRowVector,
        "kernel method for plain lists of cyclotomics",
        IsCollsCollsElmsXX,
        [ IsSmallList and IsDenseList and IsMutable and
          IsCyclotomicCollection and IsPlistRep,
      IsDenseList and IsCyclotomicCollection and IsPlistRep,
      IsCyclotomic,
      IsPosInt,
      IsPosInt ],
    0,
        ADD_ROW_VECTOR_5_FAST
        );

InstallMethod( AddRowVector,
        "kernel method for small lists",
        IsCollsCollsElmsXX,

    [ IsSmallList and IsDenseList and IsMutable,
      IsDenseList,
      IsMultiplicativeElement,
      IsPosInt,
      IsPosInt ],
    0,
        ADD_ROW_VECTOR_5
        );

InstallMethod( AddRowVector,
        "generic method",
    IsCollsCollsElmsXX,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsMultiplicativeElement,
      IsPosInt,
      IsPosInt ],
    0,
        function( l1, l2, m, f, t )
    local   i;

    for i  in [ f .. t ]  do
        l1[i] := l1[i] + m * l2[i];
    od;
end
  );

BindGlobal( "L1_IMMUTABLE_ERROR", function(arg)
  if IsMutable(arg[1]) then
    TryNextMethod();
  else
    Error("arg[1] must be mutable");
  fi;
end );

InstallOtherMethod( AddRowVector,"error if immutable",true,
    [ IsList,IsObject,IsObject,IsPosInt,IsPosInt],0,
L1_IMMUTABLE_ERROR);

#############################################################################
##
#M  AddRowVector( <list1>, <list2>, <mult> )
##
InstallOtherMethod( AddRowVector,
        "kernel method for plain lists of cyclotomics(3 args)",
        IsCollsCollsElms,
        [ IsSmallList and IsDenseList and IsMutable and IsCyclotomicCollection
          and IsPlistRep,
      IsDenseList and IsPlistRep and IsCyclotomicCollection,
      IsCyclotomic ],
    0,
        ADD_ROW_VECTOR_3_FAST );

InstallOtherMethod( AddRowVector,
        "kernel method for small lists (3 args)",
        IsCollsCollsElms,
    [ IsSmallList and IsDenseList and IsMutable,
      IsDenseList,
      IsMultiplicativeElement ],
    0,
        ADD_ROW_VECTOR_3 );

InstallOtherMethod( AddRowVector,
        "kernel method for GF2 (5 args, last 2 ignored)",
        IsCollsCollsElmsXX,
    [ IsGF2VectorRep and IsMutable,
      IsGF2VectorRep,
      IS_FFE, IsPosInt, IsPosInt ],0,
        function(sum, vec, mult, from, to)
    AddRowVector( sum, vec, mult);
end);

InstallOtherMethod( AddRowVector,
        "kernel method for GF2 (3 args)",
        IsCollsCollsElms,
    [ IsGF2VectorRep and IsMutable,
      IsGF2VectorRep,
      IS_FFE and IsInternalRep ],0,
        ADDCOEFFS_GF2VEC_GF2VEC_MULT );

InstallOtherMethod( AddRowVector,
        "kernel method for vecffe (5 args -- ignores last 2)",
        IsCollsCollsElmsXX,
    [ IsRowVector and IsMutable and IsPlistRep and IsFFECollection,
      IsRowVector and IsPlistRep and IsFFECollection,
      IS_FFE and IsInternalRep, IsPosInt, IsPosInt ],0,
        function( sum, vec, mult, from, to)
    AddRowVector(sum,vec,mult);
end);

InstallOtherMethod( AddRowVector,
        "kernel method for vecffe (3 args)",
        IsCollsCollsElms,
    [ IsRowVector and IsMutable and IsPlistRep and IsFFECollection,
      IsRowVector and IsPlistRep and IsFFECollection,
      IS_FFE and IsInternalRep ],0,
        ADD_ROWVECTOR_VECFFES_3 );

InstallOtherMethod( AddRowVector, "generic method 3 args",
    IsCollsCollsElms,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsMultiplicativeElement ],
    0,
function( l1, l2, m )
local   i;
    for i  in [ 1 .. Length(l1) ]  do
        l1[i] := l1[i] + m * l2[i];
    od;
end );

InstallOtherMethod( AddRowVector,"error if immutable",true,
    [ IsList,IsObject,IsObject],0,L1_IMMUTABLE_ERROR);

InstallOtherMethod( AddRowVector, "do nothing if mult is zero",
        IsCollsCollsElms,
        [ IsList, IsObject, IsObject and IsZero],
        SUM_FLAGS, #can't do better
        ReturnTrue);

#############################################################################
##
#M  AddRowVector( <list1>, <list2> )
##
InstallOtherMethod( AddRowVector,
        "kernel method for plain lists of cyclotomics (2 args)",
    IsIdenticalObj,
        [ IsSmallList and IsDenseList and IsMutable and
          IsCyclotomicCollection and IsPlistRep,
      IsDenseList and IsCyclotomicCollection and IsPlistRep ],
    0,
        ADD_ROW_VECTOR_2_FAST
        );

InstallOtherMethod( AddRowVector,
        "kernel method for GF2 (2 args)",
        IsIdenticalObj,
    [ IsGF2VectorRep and IsMutable and IsRowVector,
      IsGF2VectorRep and IsRowVector],0,
        ADDCOEFFS_GF2VEC_GF2VEC );

InstallOtherMethod( AddRowVector,
        "kernel method for vecffe (2 args)",
        IsIdenticalObj,
    [ IsRowVector and IsMutable and IsPlistRep and IsFFECollection,
      IsRowVector and IsPlistRep and IsFFECollection],0,
        ADD_ROWVECTOR_VECFFES_2 );

InstallOtherMethod( AddRowVector, "generic method (2 args)",
    IsIdenticalObj, [ IsDenseList and IsMutable, IsDenseList ], 0,
function( l1, l2 )
local   i;
    for i  in [ 1 .. Length(l1) ]  do
        l1[i] := l1[i] + l2[i];
    od;
end );

InstallOtherMethod( AddRowVector,
        "kernel method for small lists (2 args)",
    IsIdenticalObj,
    [ IsSmallList and IsDenseList and IsMutable,
      IsDenseList ],
    0,
        ADD_ROW_VECTOR_2);

InstallOtherMethod( AddRowVector,
        "kernel method for GF2 (2 args)",
        IsIdenticalObj,
    [ IsGF2VectorRep and IsMutable,
      IsGF2VectorRep],0,
        ADDCOEFFS_GF2VEC_GF2VEC );

InstallOtherMethod( AddRowVector,"error if immutable",true,
    [ IsList,IsObject],0,
        L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  LeftShiftRowVector( <list>, <shift> )
##
InstallMethod( LeftShiftRowVector,"generic method",
    true,
    [ IsDenseList and IsMutable,
      IsPosInt ],
    0,

function( l, s )
    local   i;

    for i  in [ 1 .. Length(l)-s ]  do
        l[i] := l[i+s];
    od;
    for i  in [ Maximum(1, Length(l)-s+1) .. Length(l) ]  do
        Unbind(l[i]);
    od;
end );

InstallOtherMethod( LeftShiftRowVector,"error if immutable",true,
    [ IsList,IsObject],0,
    L1_IMMUTABLE_ERROR);

#############################################################################
##
#M  LeftShiftRowVector( <list>, <no-shift> )
##
InstallOtherMethod( LeftShiftRowVector,
    true,
    [ IsDenseList,
      IsInt and IsZeroCyc ],
    SUM_FLAGS, # can't do better

function( l, s )
    return;
end );


#############################################################################
##
#M  MultVectorLeft( <list>, <mul> )
##
InstallMethod( MultVectorLeft,
    "for a mutable dense list, and an object",
    [ IsDenseList and IsMutable,
      IsObject ],
function( l, m )
    local   i;
    for i  in [ 1 .. Length(l) ]  do
        l[i] := m * l[i];
    od;
end );
InstallOtherMethod( MultVectorLeft, "error if immutable",
    [ IsList, IsObject ],
    L1_IMMUTABLE_ERROR);

InstallMethod( MultVectorLeft,
    "kernel method for a mutable dense small list, and an object",
    IsCollsElms,
    [ IsSmallList and IsDenseList and IsMutable,
      IsObject ],
    MULT_VECTOR_LEFT_2
);
InstallMethod( MultVectorLeft,
    "kernel method for a mutable dense plain list of \
cyclotomics, and a cyclotomic",
    IsCollsElms,
    [ IsDenseList and IsMutable and IsPlistRep and IsCyclotomicCollection,
      IsCyclotomic ],
    MULT_VECTOR_2_FAST
);
InstallMethod( MultVectorLeft,
    "kernel method for a mutable row vector of ffes in \
plain list rep, and an ffe",
    IsCollsElms,
    [ IsRowVector and IsMutable and IsPlistRep and IsFFECollection,
      IsFFE],0,
    MULT_VECTOR_VECFFES );


#############################################################################
##
#M  RightShiftRowVector( <list>, <shift>, <fill> )
##
InstallMethod( RightShiftRowVector,"generic method",
    true,
    [ IsList and IsMutable,
      IsPosInt,
      IsObject ],
    0,

function( l, s, f )
    local   i;

    l{s+[1..Length(l)]} := l{[1..Length(l)]};
    for i  in [ 1 .. s ]  do
        l[i] := f;
    od;
end );

InstallOtherMethod( RightShiftRowVector,"error if immutable",true,
    [ IsList,IsObject],0,
    L1_IMMUTABLE_ERROR);

InstallOtherMethod( RightShiftRowVector,"error if immutable",true,
    [ IsList,IsObject, IsObject],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  RightShiftRowVector( <list>, <no-shift>, <fill> )
##
InstallOtherMethod( RightShiftRowVector,
    true,
    [ IsList,
      IsInt and IsZeroCyc,
      IsObject ],
    SUM_FLAGS, # can't do better

function( l, s, f )
    return;
end );


#############################################################################
##
#M  ShrinkRowVector( <list> )
##
InstallMethod( ShrinkRowVector,"generic method",
    true,
    [ IsList and IsMutable ],
    0,

function( l1 )
    local   z;

    if 0 = Length(l1)  then
        return;
    else
        z := l1[1] * 0;
        while 0 < Length(l1) and l1[Length(l1)] = z  do
            Remove(l1);
        od;
    fi;
end );

InstallOtherMethod( ShrinkRowVector,"error if immutable",true,
    [ IsList],0,
    L1_IMMUTABLE_ERROR);

#############################################################################
##
#M  PadCoeffs
##

InstallMethod(PadCoeffs,
        "pad with supplied value",
        IsCollsXElms,
        [IsList and IsMutable, IsPosInt, IsObject],
        function(l,n,x)
    local   len,  i;
    len := Length(l);
    for i in [len+1..n] do
        l[i] := x;
    od;
    return;
end);

InstallMethod(PadCoeffs,
        "pad with zero",
        [IsList and IsMutable and IsAdditiveElementWithZeroCollection,
         IsPosInt],
        function(l,n)
    local   len,  z,  i;
    len := Length(l);
    if len = 0 then
        Error("Don't know what to pad with");
    fi;
    z := Zero(l[1]);
    for i in [len+1..n] do
        l[i] := z;
    od;
    return;
end);



#############################################################################
##
#M  AddCoeffs( <list1>, <poss1>, <list2>, <poss2>, <mul> )
##
InstallMethod( AddCoeffs, "generic method (5 args)", true,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsDenseList,
      IsDenseList,
      IsMultiplicativeElement ],
    0,

function( l1, p1, l2, p2, m )
    local   i,  zero,  n1;

    if Length(p1) <> Length(p2)  then
        Error( "positions lists have different lengths" );
    fi;
    for i  in [ 1 .. Length(p1) ]  do
        if not IsBound(l1[p1[i]])  then
            l1[p1[i]] := m*l2[p2[i]];
        else
            l1[p1[i]] := l1[p1[i]] + m*l2[p2[i]];
        fi;
    od;
    if 0 < Length(l1)  then
        zero := Zero(l1[1]);
        n1   := Length(l1);
        while 0 < n1 and l1[n1] = zero  do
            n1 := n1 - 1;
        od;
    else
        n1 := 0;
    fi;
    return n1;
end );

InstallOtherMethod( AddCoeffs,"error if immutable", true,
    [ IsList,IsObject,IsObject,IsObject,IsObject],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  AddCoeffs( <list1>, <list2>, <mul> )
##
InstallOtherMethod( AddCoeffs,
    "generic method 3args",
    true,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsMultiplicativeElement ],
    0,ADDCOEFFS_GENERIC_3);

InstallOtherMethod( AddCoeffs,"error if immutable", true,
    [ IsList,IsObject,IsObject],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  AddCoeffs( <list1>, <list2> )
##
InstallOtherMethod( AddCoeffs, "generic method (2 args)", true,
    [ IsDenseList and IsMutable, IsDenseList ], 0,
function( l1, l2 )
  return ADDCOEFFS_GENERIC_3( l1, l2, One(l2[1]) );
end );

#############################################################################
##
#M  AddCoeffs( <list1>, <list2> )
##
InstallOtherMethod( AddCoeffs, "generic method (2nd arg empty)", true,
    [ IsDenseList and IsMutable, IsList and IsEmpty], 0,
function( l1, l2 )
local   len,  zero;
  if 0 = Length(l1)  then
      return 0;
  else
      len  := Length(l1);
      zero := Zero(l1[1]);
      while 0 < len and l1[len] = zero  do
          len := len - 1;
      od;
      return len;
  fi;
end );

InstallOtherMethod( AddCoeffs,"error if immutable", true,
    [ IsList,IsObject],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  MultCoeffs( <list1>, <list2>, <len2>, <list3>, <len3> )
##
InstallMethod( MultCoeffs,"generic method",
    true,
    [ IsList and IsMutable,
      IsDenseList,
      IsInt,
      IsDenseList,
      IsInt ],
    0,

function( l1, l2, n2, l3, n3 )
    local   zero,  i,  z,  j,  n1;

    # catch the trivial cases
    if n2 = 0  then
        return 0;
    elif n3 = 0  then
        return 0;
    fi;
    zero := Zero(l2[1]);
    if IsIdenticalObj( l1, l2 )  then
        l2 := ShallowCopy(l2);
    elif IsIdenticalObj( l1, l3 )  then
        l3 := ShallowCopy(l3);
    fi;

    # fold the product
    for i  in [ 1 .. n2+n3-1 ]  do
        z := zero;
        for j  in [ Maximum(i+1-n3,1) .. Minimum(n2,i) ]  do
            z := z + l2[j]*l3[i+1-j];
        od;
        l1[i] := z;
    od;

    # return the length of <l1>
    n1 := n2+n3-1;
    while 0 < n1 and l1[n1] = zero  do
        n1 := n1 - 1;
    od;
    return n1;

end );

InstallOtherMethod( MultCoeffs,"error if immutable", true,
    [ IsList,IsObject,IsInt,IsObject,IsInt],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  ReduceCoeffs( <list1>, <len1>, <list2>, <len2> )
##
InstallMethod( ReduceCoeffs,"generic method",
    true,
    [ IsDenseList and IsMutable,
      IsInt,
      IsDenseList,
      IsInt ],
    0,

function( l1, n1, l2, n2 )
    local   zero,  l,  q,   i;

    # catch trivial cases
    if 0 = n2  then
        Error( "<l2> must be non-zero" );
    elif 0 = n1  then
        return n1;
    fi;
    zero := Zero(l1[1]);
    while 0 < n2 and l2[n2] = zero  do
        n2 := n2 - 1;
    od;
    if 0 = n2  then
        Error( "<l2> must be non-zero" );
    fi;
    while 0 < n1 and l1[n1] = zero  do
        n1 := n1 - 1;
    od;

    # reduce coeffs
    while n1 >= n2  do
        q := -l1[n1]/l2[n2];
        l := n1-n2;
        for i  in [ n1-n2+1 .. n1 ]  do
            l1[i] := l1[i]+q*l2[i-n1+n2];
            if l1[i] <> zero  then
                l := i;
            fi;
        od;
        n1 := l;
    od;
    return n1;
end );

InstallOtherMethod( ReduceCoeffs,"error if immutable", true,
    [ IsList,IsInt,IsObject,IsInt],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  ReduceCoeffs( <list1>, <list2> )
##
InstallOtherMethod( ReduceCoeffs,
    true,
    [ IsDenseList and IsMutable,
      IsDenseList ],
    0,

function( l1, l2 )
    return ReduceCoeffs( l1, Length(l1), l2, Length(l2) );
end );

InstallOtherMethod( ReduceCoeffs,"error if immutable", true,
    [ IsList,IsObject],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  ReduceCoeffsMod( <list1>, <len1>, <list2>, <len2>, <mod> )
##
InstallMethod( ReduceCoeffsMod,"generic method (5 args)", true,
    [ IsDenseList and IsMutable, IsInt, IsDenseList, IsInt, IsInt ], 0,
function( l1, n1, l2, n2, p )
    local   zero,  l,  q,   i;

    # catch trivial cases
    if 0 = n2  then
        Error( "<l2> must be non-zero" );
    elif 0 = n1  then
        return l1;
    fi;
    zero := Zero(l1[1]);
    while 0 < n2 and l2[n2] = zero  do
        n2 := n2 - 1;
    od;
    if 0 = n2  then
        Error( "<l2> must be non-zero" );
    fi;
    while 0 < n2 and l1[n1] = zero  do
        n1 := n1 - 1;
    od;

    # reduce coeffs
    while n1 >= n2  do
        q := -l1[n1]/l2[n2] mod p;
        l := n1-n2;
        for i  in [ n1-n2+1 .. n1 ]  do
            l1[i] := (l1[i]+q*l2[i-n1+n2] mod p) mod p;
            if l1[i] <> zero  then
                l := i;
            fi;
        od;
        n1 := l;
    od;
    return n1;
end );

InstallOtherMethod( ReduceCoeffsMod,"error if immutable", true,
    [ IsList,IsInt,IsObject,IsInt,IsInt],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  ReduceCoeffsMod( <list1>, <list2>, <mod> )
##
InstallOtherMethod( ReduceCoeffsMod,"generic: list,list,int", true,
    [ IsDenseList and IsMutable, IsDenseList, IsInt ], 0,
function( l1, l2, p )
    return ReduceCoeffsMod( l1, Length(l1), l2, Length(l2), p );
end );

InstallOtherMethod( ReduceCoeffsMod,"error if immutable", true,
    [ IsList,IsObject,IsInt],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  ReduceCoeffsMod( <list>, <len>, <mod> )
##
InstallOtherMethod( ReduceCoeffsMod,"generic: list, int,int", true,
    [ IsDenseList and IsMutable, IsInt, IsInt ], 0,
function( l1, n1, p )
    local   zero,  n2,  i;

    # catch trivial cases
    if 0 = n1  then
        return l1;
    fi;
    zero := Zero(l1[1]);

    # reduce coeffs
    n2 := 0;
    for i  in [ 1 .. n1 ]  do
        l1[i] := l1[i] mod p;
        if l1[i] <> zero  then
            n2 := i;
        fi;
    od;
    return n2;

end );

InstallOtherMethod( ReduceCoeffsMod,"error if immutable", true,
    [ IsList,IsInt,IsInt],0,
    L1_IMMUTABLE_ERROR);


#############################################################################
##
#M  ReduceCoeffsMod( <list>, <mod> )
##
InstallOtherMethod( ReduceCoeffsMod,
    true,
    [ IsDenseList and IsMutable,
      IsInt ],
    0,
function( l1, p )
    return ReduceCoeffsMod( l1, Length(l1), p );
end );

InstallOtherMethod( ReduceCoeffsMod,"error if immutable", true,
    [ IsList,IsInt],0,
    L1_IMMUTABLE_ERROR);

#############################################################################
##
#M  QuotRemCoefs( <list>, <len>, <list>, <len> )
##
InstallMethod( QuotRemCoeffs,"generic",
        [IsList, IsInt, IsList, IsInt],
function( l1, n1, l2, n2 )
    local   zero,  rem,  quot,  q,  l,  i;


    # catch trivial cases
    if 0 = n2  then
        Error( "<l2> must be non-zero" );
    elif 0 = n1  then
        return [[],[]];
    fi;
    zero := Zero(l1[1]);
    while 0 < n2 and l2[n2] = zero  do
        n2 := n2 - 1;
    od;
    if 0 = n2  then
        Error( "<l2> must be non-zero" );
    fi;
    while 0 < n1 and l1[n1] = zero  do
        n1 := n1 - 1;
    od;

    rem := l1{[1..n1]};
    quot := ListWithIdenticalEntries(n1-n2+1,zero);
    # reduce coeffs
    while n1 >= n2  do
        q := rem[n1]/l2[n2];
        l := n1-n2;
        quot[l+1] := q;
        for i  in [ n1-n2+1 .. n1 ]  do
            rem[i] := rem[i]-q*l2[i-n1+n2];
            if rem[i] <> zero  then
                l := i;
            fi;
        od;
        n1 := l;
    od;
    return [quot,rem];
end );


#############################################################################
##
#M  QuotRemCoeffs( <list1>, <list2> )
##
InstallOtherMethod( QuotRemCoeffs,"generic, use list lengths",
    true,
    [ IsDenseList,
      IsDenseList ],
    0,

function( l1, l2 )
    return QuotRemCoeffs( l1, Length(l1), l2, Length(l2) );
end );


#############################################################################
##
#M  RemoveOuterCoeffs( <list>, <coef> )
##
InstallMethod( RemoveOuterCoeffs,"generic method", true,
  [ IsDenseList and IsMutable, IsObject ], 0, REMOVE_OUTER_COEFFS_GENERIC);

InstallOtherMethod( RemoveOuterCoeffs,"error if immutable", true,
    [ IsList,IsObject],0,
    L1_IMMUTABLE_ERROR);



#############################################################################
##
#M  CoeffsMod( <list>, <len>, <mod> )
##
InstallMethod( CoeffsMod,"call `ReduceCoeffsMod'",
    true,
    [ IsDenseList,
      IsInt,
      IsInt ],
    0,

function( l1, n1, p )
    l1 := ShallowCopy(l1);
    ReduceCoeffsMod( l1, n1, p );
    ShrinkRowVector(l1);
    return l1;
end );


#############################################################################
##
#M  CoeffsMod( <list>, <mod> )
##
InstallOtherMethod( CoeffsMod,
    true,
    [ IsDenseList,
      IsInt ],
    0,

function( l1, p )
    return CoeffsMod( l1, Length(l1), p );
end );


#############################################################################
##
#M  PowerModCoeffs( <list1>, <len1>, <exp>, <list2>, <len2> )
##
InstallMethod( PowerModCoeffs,
        "default five argt method",
    true,
    [ IsDenseList,
      IsInt,
      IsInt,
      IsDenseList,
      IsInt ],
    0,

function( l1, n1, exp, l2, n2 )
    local   c,  n3;

    if exp <= 0  then
        Error( "power <exp> must be positive" );
    fi;
    l1 := ShallowCopy(l1);
    n1 := ReduceCoeffs( l1, n1, l2, n2 );
    if n1 = 0  then
        return [];
    fi;
    c  := [ One(l1[1]) ];
    n3 := 1;
    while exp <> 0 do
        if exp mod 2 = 1  then
            n3 := MultCoeffs( c, c, n3, l1, n1 );
            n3 := ReduceCoeffs( c, n3, l2, n2 );
        fi;
        exp := QuoInt( exp, 2 );
        if exp <> 0  then
            l1 := ProductCoeffs( l1, n1, l1, n1 );
            n1 := ReduceCoeffs( l1, Length(l1), l2, n2 );
        fi;
    od;
    return c{[1..n3]};
end );


#############################################################################
##
#M  PowerModCoeffs( <list1>, <exp>, <list2> )
##
InstallOtherMethod( PowerModCoeffs,
        "default, 3 argt",
    true,
    [ IsDenseList,
      IsInt,
      IsDenseList ],
    0,

function( l1, exp, l2 )
    return PowerModCoeffs( l1, Length(l1), exp, l2, Length(l2) );
end );


#############################################################################
##
#M  ProductCoeffs( <list1>, <len1>, <list2>, <len2> )
##
InstallMethod( ProductCoeffs,"call PRODUCT_COEFFS_GENERIC_LISTS", true,
    [ IsDenseList, IsInt, IsDenseList, IsInt ], 0,
    PRODUCT_COEFFS_GENERIC_LISTS);


#############################################################################
##
#M  ProductCoeffs( <list1>, <list2> )
##
InstallOtherMethod( ProductCoeffs,
  "call PRODUCT_COEFFS_GENERIC_LISTS with lengths",
    true, [ IsDenseList, IsDenseList ], 0,
function( l1, l2 )
  return PRODUCT_COEFFS_GENERIC_LISTS(l1,Length(l1),l2,Length(l2));
end);


#############################################################################
##
#M  ShiftedCoeffs( <list>, <shift> )
##
InstallMethod( ShiftedCoeffs,"call ShiftRowVektor", true,
    [ IsDenseList, IsInt ], 0,

function( l, shift )
  l := ShallowCopy(l);
  if shift < 0  then
      LeftShiftRowVector( l, -shift );
      ShrinkRowVector(l);
      return l;
  elif shift = 0  then
      ShrinkRowVector(l);
      return l;
  else
      RightShiftRowVector( l, shift, Zero(l[1]) );
      ShrinkRowVector(l);
      return l;
  fi;
end );

InstallMethod( ShiftedCoeffs,"empty list", true,
    [ IsList and IsEmpty, IsInt ], 0,
function( l, shift )
  return [];
end);


#############################################################################
##
#F  ValuePol( <coeffs_f>, <x> ) . . . . . .  evaluate a polynomial at a point
##
InstallMethod( ValuePol,"generic",true,[IsList,IsRingElement],0,
function( f, x )
    local  value, i, id;
    id := x ^ 0;
    value := 0 * id;
    i := Length(f);
    while 0 < i  do
        value := value * x + id * f[i];
        i := i-1;
    od;
    return value;
end );

InstallMethod( ValuePol,"special code for rational values",true,
  [IsList,IsRat],0,
function( f, x )
    local  value, i;
    value := 0 * x;
    i := Length(f);
    while 0 < i  do
        value := value * x + f[i];
        i := i-1;
    od;
    return value;
end );


#############################################################################
##
#F  QuotRemPolList( <f>, <g>)
##
##  Quotient and  Remainder  of polynomials   given as  list,  is  needed for
##  algebraic extensions and fits best here.
##
BindGlobal( "QuotRemPolList", function(f,g)
local q,m,n,i,c,k,z;
  q:=[];
  f:=ShallowCopy(f);
  g:=ShallowCopy(g);
  z:=0*g[1];
  n:=Length(g);
  while n>0 and g[n]=z do
    Unbind(g[n]);
    n:=n-1;
  od;
  n:=Length(g);
  m:=Length(f);
  for i  in [0..(m-n)]  do
    c:=f[m-i]/g[n];
    q[m-n-i+1]:=c;
    for k in [1..n] do
      f[m-i-n+k]:=f[m-i-n+k]-c*g[k];
    od;
  od;
  return [q,f];
end );

#############################################################################
##
#M  WeightVecFFE( <vec> )
##
InstallMethod(WeightVecFFE,"generic",true,[IsList],0,
function(v)
local z,i,n;
  z:=Zero(v[1]);
  n:=0;
  for i in [1..Length(v)] do
    if v[i]<>z then n:=n+1;fi;
  od;
  return n;
end);

InstallMethod(WeightVecFFE,"gf2 vectors",true,[IsGF2VectorRep and IsList],0,
function(a)
  return DIST_GF2VEC_GF2VEC(a,Zero(a));
end);

#############################################################################
##
#M  DistanceVecFFE( <vec1>,<vec2> )
##
InstallMethod(DistanceVecFFE,"generic",IsIdenticalObj,[IsList,IsList],0,
function(v,w)
local i,n;
  n:=0;
  for i in [1..Length(v)] do
    if v[i]<>w[i] then n:=n+1;fi;
  od;
  return n;
end);

InstallMethod(DistanceVecFFE,"gf2 vectors",
  IsIdenticalObj,[IsGF2VectorRep and IsList,IsGF2VectorRep and IsList],
  0, DIST_GF2VEC_GF2VEC);

#############################################################################
##
#M  DistancesDistributionVecFFEsVecFFE( <vecs>,<vec> )
##
InstallMethod(DistancesDistributionVecFFEsVecFFE,"generic",IsCollsElms,
  [IsList, IsList],0,
function(vecs,vec)
local d,i;
  ConvertToMatrixRep(vecs);
  ConvertToVectorRep(vec);
  d:=ListWithIdenticalEntries(Length(vec)+1,0);
  for i in vecs do
    i:=DistanceVecFFE(i,vec);
    d[i+1]:=d[i+1]+1;
  od;
  return d;
end);


#############################################################################
##
#M  DistancesDistributionMatFFEsVecFFE( <vecs>,<vec> )
##
DeclareGlobalName("DistVecClosVecLib");
BindGlobal( "DistVecClosVecLib", function(veclis,vec,d,sum,pos,l,m)
local i,di,vp;
  vp:=veclis[pos];
  for i in [0..m] do
    if pos<l then
      DistVecClosVecLib(veclis,vec,d,sum,pos+1,l,m);
    else
      di:=DistanceVecFFE(sum,vec);
      d[di+1]:=d[di+1]+1;
    fi;
    AddRowVector(sum,vp[i+1]);
  od;
end );

InstallMethod(DistancesDistributionMatFFEVecFFE,"generic",IsCollsElmsElms,
        [IsMatrix,IsFFECollection and IsField, IsList],0,
        function(mat,f,vec)
    local d,fdi,i,j,veclis,mult,mults,fdip,q, ok8;
    ConvertToMatrixRepNC(mat,f);
    ConvertToVectorRepNC(vec,f);
    # build the data structures
    f:=AsSSortedList(f);
    Assert(1,f[1]=Zero(f[1]));

    # get differences between field entries (so we can get the next vector
    # with one addition)
    fdi:=[];
    for j in [2..Length(f)] do
        fdi[j-1]:=f[j]-f[j-1];
    od;
    Add(fdi,-f[Length(f)]); # the subtraction multiple we need at the end.

    fdip := List(fdi, x-> Position(fdi,x));

    # veclis contains for each vector in mat a list of its fdi-multiples.
    # using this list we do not need any scalar arithmetic in the loops below.
    veclis:=[];
    for i in mat do
        mults:=[];
        mults[Length(fdi)+1]:=false; # force plist and not matrix rep.
        for j in [1..Length(fdi)] do
            if fdip[j] < j then
                mult := mults[fdip[j]];
            else
                mult:=fdi[j]*i; # vector times difference
            fi;
            mults[j]:=mult;
        od;
        Add(veclis,mults);
    od;

    d:=ListWithIdenticalEntries(Length(vec)+1,0);

    q := Length(f);
    if q = 2 then
        # gf2 case
        # zero out trailing bits.
        # This is not time relevant and easier to do in
        # the library by calling kernel functions
        # which do it as a side effect.

        for i in veclis do
            for j in i{[1..Length(i)-1]} do
                DIST_GF2VEC_GF2VEC(j,j);
            od;
        od;
        DIST_VEC_CLOS_VEC(veclis,vec,d);
        return d;
    elif q <= 256 then
        #
        # 8 bit case, have to get everything over one field!
        #

        ok8 := true;
        for i in veclis do
            for j in [1..q] do
                if q <> ConvertToVectorRepNC(i[j],q) then
                    i[j] := PlainListCopy(i[j]);
                    MakeImmutable(i[j]);
                    if q <> ConvertToVectorRepNC(i[j],q) then
                        ok8 := false;
                    fi;
                fi;
            od;
        od;
        if q <> ConvertToVectorRepNC(vec,q) then
            vec := PlainListCopy(vec);
            MakeImmutable(vec);
            if q <> ConvertToVectorRepNC(vec,q) then
                ok8 := false;
            fi;
        fi;

        if ok8 then
            DISTANCE_DISTRIB_VEC8BITS( veclis, vec, d);
            return d;
        fi;
    fi;

    # no kernel method available, use library recursion
    DistVecClosVecLib(veclis,vec,d,
            ZeroOp(vec),1,Length(veclis),
            Length(veclis[1])-2 # -2: last entry is `false',
            # entry -1 the negative
            );


    return d;
end);

#############################################################################
##
#M  AClosestVectorCombinationsMatFFEVecFFE( <mat>,<f>,<vec>,<l>,<stop> )
##

DeclareGlobalName("AClosVecLib");
BindGlobal( "AClosVecLib", function(veclis,vec,sum,pos,l,m,cnt,stop,bd,bv,coords,bcoords)
    local i,di,vp;
    if    # if this vector has coeff 0 there must be at least cnt+1 free positions
        # to come up with the right number of vectors
      (l>cnt+pos) then
        bd:=AClosVecLib(veclis,vec,sum,pos+1,l,m,cnt,stop,bd,bv,coords,bcoords);

        if bd<=stop then
            return bd;
        fi;
    fi;

    vp:=veclis[pos];
    for i in [1..m] do
        AddRowVector(sum,vp[i]);
        if coords <> false then
            coords[pos] := i;
        fi;
        if cnt = 0 then
            # test this vector
            di:=DistanceVecFFE(sum,vec);
            if di<bd then
                # store new optimum
                bd:=di;
                bv{[1..Length(sum)]}:=sum;
                if coords <> false then
                    bcoords{[1..Length(veclis)]} := coords;
                fi;
                if bd <= stop then
                    return bd;
                fi;
            fi;
        else
            if pos<l then
                bd:=AClosVecLib(veclis,vec,sum,pos+1,l,m,cnt-1,stop,bd,bv,coords,bcoords);
                if bd<=stop then
                    return bd;
                fi;
            fi;
        fi;
    od;
    # reset component to 0
    AddRowVector(sum,vp[m+1]);
    coords[pos] := 0;
    return bd;
end );

BindGlobal( "AClosestVectorDriver", function(mat,f,vec,cnt,stop,coords)
    local b,fdi,i,j,veclis,mult,mults,fdip, q, ok8,c,bc;

    # special case: combination of 0 vectors
    if cnt=0 then
        if coords then
            return [Zero(vec),ListWithIdenticalEntries(Length(mat),Zero(f))];
        else
            return Zero(vec);
        fi;
    fi;

    if cnt > Length(mat) then
      Error("First list needs at least ", cnt, " vectors . . .\n");
    fi;

    ConvertToMatrixRepNC(mat,Size(f));
    ConvertToVectorRepNC(vec,f);

    # build the data structures
    f:=AsSSortedList(f);
    q := Length(f);
    Assert(1,f[1]=Zero(f[1]));

    # get differences between field entries (so we can get the next vector
    # with one addition)
    fdi:=[];
    for j in [2..q] do
        fdi[j-1]:=f[j]-f[j-1];
    od;
    Add(fdi,-f[Length(f)]); # the subtraction multiple we need at the end.

    fdip := List(fdi, x-> Position(fdi,x));


        # veclis contains for each vector in mat a list of its fdi-multiples.
        # using this list we do not need any scalar arithmetic in the loops below.
    veclis:=[];
    for i in mat do
        mults:=[];
        mults[Length(fdi)+1]:=false;    # force plist and not matrix rep.
        for j in [1..Length(fdi)] do
            if fdip[j] < j then
                mult := mults[fdip[j]]; #reuse
            else
                mult:=fdi[j]*i;       # vector times difference
            fi;
            mults[j]:=mult;
        od;
        Add(veclis,mults);
    od;

    if q = 2 then
        # gf2 case
        # zero out trailing bits. This is not time relevant and easier to do in
        # the library by calling kernel functions which do it as a side effect.
        for i in veclis do
            for j in i{[1..Length(i)-1]} do
                DIST_GF2VEC_GF2VEC(j,j);
            od;
        od;
        if coords then
            b := A_CLOS_VEC_COORDS(veclis,vec,cnt-1,stop);
            ConvertToVectorRepNC(b[1],2);
            b[2] := f{1+b[2]};
        else
            b:=A_CLOS_VEC(veclis,vec,cnt-1,stop);
            ConvertToVectorRepNC(b,2);
        fi;
        return b;
    elif q <= 256 then
        #
        # 8 bit case, have to get everything over one field!
        #

        ok8 := true;
        for i in veclis do
            for j in [1..q] do
                if q <> ConvertToVectorRepNC(i[j],q) then
                    i[j] := PlainListCopy(i[j]);
                    MakeImmutable(i[j]);
                    if q <> ConvertToVectorRepNC(i[j],q) then
                        ok8 := false;
                    fi;
                fi;
            od;
        od;
        if q <> ConvertToVectorRepNC(vec,q) then
            vec := PlainListCopy(vec);
            MakeImmutable(vec);
            if q <> ConvertToVectorRepNC(vec,q) then
                ok8 := false;
            fi;
        fi;

        if ok8 then
            if coords then
                b := A_CLOSEST_VEC8BIT_COORDS(veclis,vec,cnt-1,stop);
                b[2] := f{1+b[2]};
            else
                return A_CLOSEST_VEC8BIT(veclis, vec, cnt-1, stop);
            fi;
        fi;
    fi;
    # no kernel method available, use library recursion
    b:=ListWithIdenticalEntries(Length(vec),0);
    if coords then
        c := ListWithIdenticalEntries(Length(mat),0);
        bc:= ListWithIdenticalEntries(Length(mat),0);
        AClosVecLib(veclis,vec,ZeroOp(vec),1,Length(veclis),
                Length(f)-1,
                cnt-1,        # the routine uses 0 offset
                stop,
                Length(b)+1,  # value 1 larger than worst
                b, c, bc);
        ConvertToVectorRepNC(b);
        return [b,f{1+bc}];
    else
        AClosVecLib(veclis,vec,ZeroOp(vec),1,Length(veclis),
                Length(f)-1,
                cnt-1,        # the routine uses 0 offset
                stop,
                Length(b)+1,  # value 1 larger than worst
                b, false,false);
        ConvertToVectorRepNC(b);
        return b;
    fi;
end );


InstallMethod(AClosestVectorCombinationsMatFFEVecFFE,"generic",
        function(a,b,c,d,e)
    return HasElementsFamily(a) and IsIdenticalObj(b,c)
           and IsIdenticalObj(ElementsFamily(a),b);
end,
  [IsMatrix,IsFFECollection and IsField, IsList, IsInt,IsInt],0,
  function(mat,f,vec,cnt,stop)
    return AClosestVectorDriver(mat,f,vec,cnt,stop,false);
end);

InstallMethod(AClosestVectorCombinationsMatFFEVecFFECoords,"generic",
        function(a,b,c,d,e)
    return HasElementsFamily(a) and IsIdenticalObj(b,c)
           and IsIdenticalObj(ElementsFamily(a),b);
end,
  [IsMatrix,IsFFECollection and IsField, IsList, IsInt,IsInt],0,
  function(mat,f,vec,cnt,stop)
    return AClosestVectorDriver(mat,f,vec,cnt,stop,true);
end);

#############################################################################
##
#M  CosetLeadersMatFFE( <mat>,<f> )
##
##  returns a list of representatives of minimal weight for the cosets of
##  the vector space generated by the rows of <mat> over the finite field
##  <f>. All rows of <mat> must have the same length, and all elements must
##  lie in <f>. The rows of <mat> must be linearly independent.
##

DeclareGlobalName("CosetLeadersInner");
BindGlobal( "CosetLeadersInner", function(vl, v, w, weight, pos, record, felts,q, tofind)
    local found, i, j;

    found := 0;

    # if just one more vector is needed, then shift to a loop
    # to avoid recursion overhead
    if weight = 1 then
        for j in [pos..Length(v)] do
            # add it
            AddRowVector(w, vl[j][1]);
            v[j] := felts[2];
            # deal with the result
            found := found + record(w,v);
            if found = tofind then
                return found;
            fi;
            # and clean it off
            AddRowVector(w, vl[j][q+1]);
            v[j] := felts[1];
        od;
    else

        # option 1, do nothing in position pos
        if Length(v) >= pos + weight then
            found := found + CosetLeadersInner( vl, v, w, weight, pos+1,
                             record, felts,q, tofind);
            if found = tofind then
                return found;
            fi;
        fi;

        # option 2, add each multiple and recurse
        for i in [1..q-1] do
            AddRowVector(w, vl[pos][i]);
            v[pos] := felts[i+1];
            found := found + CosetLeadersInner( vl, v, w, weight -1,
                             pos +1, record, felts, q, tofind - found);
            if found = tofind then
                return found;
            fi;
        od;
        AddRowVector(w, vl[pos][q]);
        v[pos] := felts[1];
    fi;
    return found;
end );

InstallMethod(CosetLeadersMatFFE,"generic",IsCollsElms,
        [IsMatrix,IsFFECollection and IsField],0,
        function(mat,f)
    local q, leaders, tofind, n,m, t, vl, i, felts, fds,
          fdps, v,j,x, w, record, nzfelts, weight, ok8;

    record := function(v,w)
        local sy,x,u;
        sy := NumberFFVector(v,q);
        if not IsBound(leaders[sy+1]) then
            for x in nzfelts do
                sy := NumberFFVector(v*x,q);
                u := w*x;
                MakeImmutable(u);
                leaders[sy+1] := u;
            od;
            return q-1;
        fi;
        return 0;
    end;

    q := Size(f);
    n := Length(mat[1]);
    m := Length(mat);
    tofind := q^m;
    t := TransposedMat(mat);
    vl := [];
    vl[m+1] := false;
    felts := AsSSortedList(f);
    Assert(2, felts[1] = Zero(f));
    nzfelts := felts{[2..q]};
    fds := List([2..q], i->felts[i] - felts[i-1]);
    Add(fds, - Sum(fds));
    Add(fds, - One(f));
    fdps := List(fds, x-> Position(fds,x));
    for i in [1..n] do
        v := t[i];
        vl[i] := [];
        for j in [1..q+1] do
            if fdps[j] < j then
                Add(vl[i], vl[i][fdps[j]]);
            else
                Add(vl[i], v*fds[j]);
            fi;
        od;
        Add(vl[i],false);
    od;
    v := ListWithIdenticalEntries(n, felts[1]);
    w := ZeroOp(t[1]);
    if 2 <= q and q < 256 then

        # 8 bit case, need to get all vectors over the right field
        ok8 := true;
        if q <> ConvertToVectorRepNC(v,q) then
            v := PlainListCopy(v);
            ok8 := ok8 and q = ConvertToVectorRepNC(v,q);
        fi;
        if ok8 and q <> ConvertToVectorRepNC(w,q) then
            w := PlainListCopy(w);
            ok8 := ok8 and q = ConvertToVectorRepNC(w,q);
        fi;
        for x in vl{[1..n]} do
            for i in [1..q+1] do
                if ok8 and q <> ConvertToVectorRepNC(x[i],q) then
                    x[i] := PlainListCopy(x[i]);
                    ok8 := ok8 and q = ConvertToVectorRepNC(x[i],q);
                fi;
            od;
        od;
    else
        ok8 := false;
    fi;
    leaders := [Immutable(v)];

    # this line checks that the required number of coset leaders
    # CAN be stored in a plain list

    leaders[tofind+1] := false;
    tofind := tofind -1;
    weight := 0;
    while  tofind > 0 do
        weight := weight + 1;
        if weight > n then
            Error("not all cosets found");
        fi;
        if q = 2 then
            tofind := tofind - COSET_LEADERS_INNER_GF2( vl, weight,
                              tofind, leaders);
        elif ok8 then
            tofind := tofind - COSET_LEADERS_INNER_8BITS( vl, weight,
                              tofind, leaders, felts);
        else
            tofind := tofind - CosetLeadersInner(vl, v, w, weight, 1,
                              record, felts, q, tofind);
        fi;
    od;

    Unbind(leaders[q^m+1]);
    return leaders;
end);


#############################################################################
##
#M AddToListEntries( <list>, <poss>, <x> )
##
##  modifies <list> in place by adding <x> to each of the entries
##  indexed by <poss>.
##
##  kernel method for plain lists of cyclotomics, plain ranges and integers
##
InstallMethod( AddToListEntries, "fast kernel method", true,
        [IsList and IsPlistRep and IsMutable and IsCyclotomicCollection,
         IsRange and IsRangeRep, IsInt], 0,
        ADD_TO_LIST_ENTRIES_PLIST_RANGE);
