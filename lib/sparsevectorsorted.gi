#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains a constructor specifically for sparse vectors
##  in the sorted list representation and associated arithmetic methods
##
##



#############################################################################
##
#F  SparseVectorBySortedListNC( <poss>, <vals>, <length>[, <zero>] )
##
##

InstallGlobalFunction(SparseVectorBySortedListNC,
        function(arg)
    local poss, vals, length, z,l;
    poss := arg[1];
    vals := arg[2];
    length := arg[3];
    if Length(arg) = 3 then
        if Length(vals) = 0 then
            Error("SparseVectorBySortedListNC: No exceptions",
                  " and no zero given -- can't tell the family");
        fi;
        z := Zero(vals[1]);
    else
        z := arg[4];
    fi;
    l := SparseListBySortedListNC( poss, vals, length, z);
    SetIsSparseRowVector(l,true);
    return l;
end);

#############################################################################
##
#F  SparseVectorBySortedList( <poss>, <vals>, <length>[, <zero> ])
##
##  This is the checking version of the constructor
##


InstallGlobalFunction(SparseVectorBySortedList, function(arg)
    local poss, vals, len, z, l;
    if Length(arg) < 3 or Length(arg) > 4 then
        Error("usage: SparseVectorBySortedList( <poss>, <vals>, <length>[, <zero> ])");
    fi;
    poss := arg[1];
    vals := arg[2];
    len := arg[3];
    if Length(arg) = 3 then
        if Length(vals) = 0 then
            Error("SparseVectorBySortedList: No exceptions",
                  " and no zero given -- can't tell the family");
        fi;
        z := Zero(vals[1]);
    else
        z := arg[4];
    fi;
    if not ForAll(vals, x-> z = Zero(x)) then
        Error("SparseVectorBySortedList: no common zero, or given zero",
              "not common");
    fi;
    l := SparseListBySortedList(poss, vals, len, z);
    SetIsSparseRowVector(l,true);
    return l;
end);

## AddRowVector, MultVector
## products with scalars, scalar product, AddCoeffs, MultCoeffs,
##  more coeffs functions
## maybe product with matrices

#############################################################################
##
#M  ZeroOp
##

InstallMethod(ZeroMutable, [IsSparseRowVector and IsSparseListBySortedListRep and IsAdditiveElement],
        s-> SparseVectorBySortedListNC([],[],s![SL_LENGTH], s![SL_DEFAULT]));

InstallMethod(ZeroSameMutability, [IsSparseRowVector and IsSparseListBySortedListRep and IsAdditiveElement],
        function(s)
    local v;
    v := SparseVectorBySortedListNC([],[],s![SL_LENGTH], s![SL_DEFAULT]);
    if not IsMutable(s) then
        MakeImmutable(v);
    fi;
    return v;
end);



InstallMethod(AdditiveInverseOp, [IsSparseRowVector and IsSparseListBySortedListRep],
        s-> SparseVectorBySortedListNC(s![SL_POSS], AdditiveInverseOp(s![SL_VALS]),
                s![SL_LENGTH], s![SL_DEFAULT]));

InstallMethod(AdditiveInverseSameMutability, [IsSparseRowVector and IsSparseListBySortedListRep and IsAdditiveElement],
        function(s)
    local v;
    v := SparseVectorBySortedListNC(s![SL_POSS], AdditiveInverseOp(s![SL_VALS]),
                s![SL_LENGTH], s![SL_DEFAULT]);
    if not IsMutable(s) then
        MakeImmutable(v);
    fi;
    return v;
end);

InstallMethod(\+, IsIdenticalObj, [IsSparseRowVector and IsSparseListBySortedListRep, IsSparseRowVector and IsSparseListBySortedListRep],
        function(s1,s2)
    local i1,i2, rposs, rvals,poss1,poss2,vals1,vals2, len1,len2,s;
    i1 := 1;
    i2 := 1;
    rposs := [];
    rvals := [];
    poss1 := s1![SL_POSS];
    poss2 := s2![SL_POSS];
    vals1 := s1![SL_VALS];
    vals2 := s2![SL_VALS];
    len1 := Length(vals1);
    len2 := Length(vals2);
    while i1 <= len1 and i2 <= len2 do
        if poss1[i1] < poss2[i2] then
            Add(rposs,poss1[i1]);
            Add(rvals,vals1[i1]);
            i1 := i1+1;
        elif poss1[i1] > poss2[i2] then
            Add(rposs,poss2[i2]);
            Add(rvals,vals2[i2]);
            i2 := i2+1;
        else
            s := vals1[i1]+vals2[i2];
            if s <> s1![SL_DEFAULT] then
                Add(rposs,poss1[i1]);
                Add(rvals,s );
            fi;
            i1 := i1+1;
            i2 := i2+1;
        fi;
    od;
    while i1 <= len1 do
        Add(rposs,poss1[i1]);
        Add(rvals,vals1[i1]);
        i1 := i1+1;
    od;
    while i2 <= len2 do
        Add(rposs,poss2[i2]);
        Add(rvals,vals2[i2]);
        i2 := i2+1;
    od;
    return SparseVectorBySortedListNC( rposs, rvals,
                   Maximum(s1![SL_LENGTH], s2![SL_LENGTH]),
                   s1![SL_DEFAULT]);
end);

InstallOtherMethod(AddRowVector, IsIdenticalObj, [IsSparseRowVector and IsSparseListBySortedListRep and IsMutable,
        IsSparseRowVector and IsSparseListBySortedListRep],
        function(s1,s2)
    local i1,i2, rposs, rvals,poss1,poss2,vals1,vals2, len1,len2,s;
    if s1![SL_LENGTH] <> s2![SL_LENGTH] then
        Error("AddRowVector(2 args): lists must be the same length");
    fi;
    i1 := 1;
    i2 := 1;
    rposs := [];
    rvals := [];
    poss1 := s1![SL_POSS];
    poss2 := s2![SL_POSS];
    vals1 := s1![SL_VALS];
    vals2 := s2![SL_VALS];
    len1 := Length(vals1);
    len2 := Length(vals2);
    while i1 <= len1 and i2 <= len2 do
        if poss1[i1] < poss2[i2] then
            Add(rposs,poss1[i1]);
            Add(rvals,vals1[i1]);
            i1 := i1+1;
        elif poss1[i1] > poss2[i2] then
            Add(rposs,poss2[i2]);
            Add(rvals,vals2[i2]);
            i2 := i2+1;
        else
            s := vals1[i1]+vals2[i2];
            if s <> s1![SL_DEFAULT] then
                Add(rposs,poss1[i1]);
                Add(rvals,s );
            fi;
            i1 := i1+1;
            i2 := i2+1;
        fi;
    od;
    while i1 <= len1 do
        Add(rposs,poss1[i1]);
        Add(rvals,vals1[i1]);
        i1 := i1+1;
    od;
    while i2 <= len2 do
        Add(rposs,poss2[i2]);
        Add(rvals,vals2[i2]);
        i2 := i2+1;
    od;
    s1![SL_POSS] := rposs;
    s1![SL_VALS] := rvals;
    return;
end);

InstallOtherMethod(AddRowVector, IsFamFamX, [IsSparseRowVector and IsSparseListBySortedListRep and IsMutable,
        IsSparseRowVector and IsSparseListBySortedListRep, IsMultiplicativeElement],
        function(s1,s2,x)
    local i1,i2, rposs, rvals,poss1,poss2,vals1,vals2, len1,len2,s;
    if s1![SL_LENGTH] <> s2![SL_LENGTH] then
        Error("AddRowVector(3 args): lists must be the same length");
    fi;
    i1 := 1;
    i2 := 1;
    rposs := [];
    rvals := [];
    poss1 := s1![SL_POSS];
    poss2 := s2![SL_POSS];
    vals1 := s1![SL_VALS];
    vals2 := s2![SL_VALS];
    len1 := Length(vals1);
    len2 := Length(vals2);
    while i1 <= len1 and i2 <= len2 do
        if poss1[i1] < poss2[i2] then
            Add(rposs,poss1[i1]);
            Add(rvals,vals1[i1]);
            i1 := i1+1;
        elif poss1[i1] > poss2[i2] then
            Add(rposs,poss2[i2]);
            Add(rvals,vals2[i2]*x);
            i2 := i2+1;
        else
            s := vals1[i1]+vals2[i2]*x;
            if s <> s1![SL_DEFAULT] then
                Add(rposs,poss1[i1]);
                Add(rvals,s );
            fi;
            i1 := i1+1;
            i2 := i2+1;
        fi;
    od;
    while i1 <= len1 do
        Add(rposs,poss1[i1]);
        Add(rvals,vals1[i1]);
        i1 := i1+1;
    od;
    while i2 <= len2 do
        Add(rposs,poss2[i2]);
        Add(rvals,vals2[i2]*x);
        i2 := i2+1;
    od;
    s1![SL_POSS] := rposs;
    s1![SL_VALS] := rvals;
    return;
end);

InstallMethod(DIFF, [IsSparseRowVector and IsSparseListBySortedListRep, IsSparseRowVector and IsSparseListBySortedListRep],
        function(v1,v2) return SUM(v1, AINV(v2)); end);


InstallOtherMethod( MultVector, [IsSparseRowVector and IsSparseListBySortedListRep and IsMutable, IsMultiplicativeElement],
        function(v,x)
    MultVector(v![SL_VALS],x);
end);

InstallMethod( \*, [IsSparseRowVector and IsSparseListBySortedListRep, IsMultiplicativeElement],
        function(v,x)
    if IsList(x) then
        TryNextMethod();
    fi;
    if x = v![SL_DEFAULT] then
        return ZeroSameMutability(v);
    fi;
    return SparseVectorBySortedListNC( v![SL_POSS], v![SL_VALS]*x,
                   v![SL_LENGTH], v![SL_DEFAULT]);
end);

InstallMethod( \*, [IsMultiplicativeElement, IsSparseRowVector and IsSparseListBySortedListRep],
        function(x,v)
    if IsList(x) then
        TryNextMethod();
    fi;
    if x = v![SL_DEFAULT] then
        return ZeroSameMutability(v);
    fi;
    return SparseVectorBySortedListNC( v![SL_POSS], x*v![SL_VALS],
                   v![SL_LENGTH], v![SL_DEFAULT]);
end);

InstallMethod( \*, IsIdenticalObj, [IsSparseRowVector and IsSparseListBySortedListRep, IsSparseRowVector and IsSparseListBySortedListRep],
        function(v1,v2)
    local poss1,poss2,vals1,vals2,len1,len2,i1,i2, res;
    if IsList(v1![SL_DEFAULT]) or IsList(v2![SL_DEFAULT]) then
        TryNextMethod();
    fi;
    res := v1![SL_DEFAULT];
    i1 := 1;
    i2 := 1;
    poss1 := v1![SL_POSS];
    poss2 := v2![SL_POSS];
    vals1 := v1![SL_VALS];
    vals2 := v2![SL_VALS];
    len1 := Length(vals1);
    len2 := Length(vals2);
    while i1 <= len1 and i2 <= len2 do
        if poss1[i1]  < poss2[i2] then
            i1 := i1+1;
        elif poss1[i1] > poss2[i2] then
            i2 := i2+1;
        else
            res := res + vals1[i1]*vals2[i2];
            i1 := i1+1;
            i2 := i2+1;
        fi;
    od;
    return res;
end);

InstallMethod( ShallowCopy, [IsSparseRowVector and IsSparseListBySortedListRep],
        v-> SparseVectorBySortedListNC( ShallowCopy(v![SL_POSS]), ShallowCopy(v![SL_VALS]),
                v![SL_LENGTH], v![SL_DEFAULT]));

InstallMethod( DefaultRingByGenerators, [IsSparseRowVector and
        IsSparseListBySortedListRep],
        function(s)
    if Length(s![SL_VALS]) > 0 then
        return DefaultRing(s![SL_VALS]);
    else
        return DefaultRing([s![SL_DEFAULT]]);
    fi;
end );

InstallMethod( DefaultFieldByGenerators, [IsSparseRowVector and
        IsSparseListBySortedListRep],
        function(s)
    if Length(s![SL_VALS]) > 0 then
        return DefaultField(s![SL_VALS]);
    else
        return DefaultField([s![SL_DEFAULT]]);
    fi;
end );

InstallOtherMethod( AddCoeffs, IsIdenticalObj, [IsSparseListBySortedListRep and
        IsSparseRowVector and IsMutable,IsSparseListBySortedListRep and
        IsSparseRowVector],
                function(s1,s2)
    local i1,i2, rposs, rvals,poss1,poss2,vals1,vals2, len1,len2,s,llen;
    i1 := 1;
    i2 := 1;
    rposs := [];
    rvals := [];
    poss1 := s1![SL_POSS];
    poss2 := s2![SL_POSS];
    vals1 := s1![SL_VALS];
    vals2 := s2![SL_VALS];
    len1 := Length(vals1);
    len2 := Length(vals2);
    if len1 > 0 then
        if len2 > 0 then
            llen := Maximum(poss1[len1],poss2[len2]);
        else
            llen := poss1[len1];
        fi;
    elif len2 > 0 then
        llen := poss2[len2];
    else
        llen := 1;
    fi;
    while i1 <= len1 and i2 <= len2 do
        if poss1[i1] < poss2[i2] then
            Add(rposs,poss1[i1]);
            Add(rvals,vals1[i1]);
            i1 := i1+1;
        elif poss1[i1] > poss2[i2] then
            Add(rposs,poss2[i2]);
            Add(rvals,vals2[i2]);
            i2 := i2+1;
        else
            s := vals1[i1]+vals2[i2];
            if s <> s1![SL_DEFAULT] then
                Add(rposs,poss1[i1]);
                Add(rvals,s );
            fi;
            i1 := i1+1;
            i2 := i2+1;
        fi;
    od;
    while i1 <= len1 do
        Add(rposs,poss1[i1]);
        Add(rvals,vals1[i1]);
        i1 := i1+1;
    od;
    while i2 <= len2 do
        Add(rposs,poss2[i2]);
        Add(rvals,vals2[i2]);
        i2 := i2+1;
    od;
    s1![SL_POSS] := rposs;
    s1![SL_VALS] := rvals;
    s1![SL_LENGTH] := llen;
    return;
end);

InstallOtherMethod( AddCoeffs, IsFamFamX, [IsSparseListBySortedListRep and
        IsSparseRowVector and IsMutable,IsSparseListBySortedListRep and
        IsSparseRowVector, IsMultiplicativeElement],
                function(s1,s2, x)
    local i1,i2, rposs, rvals,poss1,poss2,vals1,vals2, len1,len2,s,llen;
    if IsZero(x) then
        return;
    fi;
    i1 := 1;
    i2 := 1;
    rposs := [];
    rvals := [];
    poss1 := s1![SL_POSS];
    poss2 := s2![SL_POSS];
    vals1 := s1![SL_VALS];
    vals2 := s2![SL_VALS];
    len1 := Length(vals1);
    len2 := Length(vals2);
    if len1 > 0 then
        if len2 > 0 then
            llen := Maximum(poss1[len1],poss2[len2]);
        else
            llen := poss1[len1];
        fi;
    elif len2 > 0 then
        llen := poss2[len2];
    else
        llen := 1;
    fi;
    while i1 <= len1 and i2 <= len2 do
        if poss1[i1] < poss2[i2] then
            Add(rposs,poss1[i1]);
            Add(rvals,vals1[i1]);
            i1 := i1+1;
        elif poss1[i1] > poss2[i2] then
            Add(rposs,poss2[i2]);
            Add(rvals,x*vals2[i2]);
            i2 := i2+1;
        else
            s := vals1[i1]+x*vals2[i2];
            if s <> s1![SL_DEFAULT] then
                Add(rposs,poss1[i1]);
                Add(rvals,s );
            fi;
            i1 := i1+1;
            i2 := i2+1;
        fi;
    od;
    while i1 <= len1 do
        Add(rposs,poss1[i1]);
        Add(rvals,vals1[i1]);
        i1 := i1+1;
    od;
    while i2 <= len2 do
        Add(rposs,poss2[i2]);
        Add(rvals,x*vals2[i2]);
        i2 := i2+1;
    od;
    s1![SL_POSS] := rposs;
    s1![SL_VALS] := rvals;
    s1![SL_LENGTH] := llen;
    return;
end);

