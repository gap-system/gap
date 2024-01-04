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
##  This file contains a specific representation of sparse lists and
##  associated methods
##


#############################################################################
##
#R  IsSparseListBySortedListRep( <sl> )
##
##  This is a positional representation with 4 components, the length,
##  the default value a sorted list of positions with non-default values
##  and the values for those positions, in the corresponding order
##
##  The lists must be homogeneous, and will only tolerate assignment of
##  elements in the proper family. The user must ensure that mutable elements
##  do not change family
##

DeclareRepresentation( "IsSparseListBySortedListRep", IsPositionalObjectRep, 4);

SL_LENGTH := 1;
SL_DEFAULT := 2;
SL_POSS := 3;
SL_VALS := 4;


#############################################################################
##
#M  Length( <sl> )
##

InstallMethod(Length, "for sparse list by sorted list", [IsSparseListBySortedListRep and IsList],
        v->v![SL_LENGTH]);

#############################################################################
##
#M  SparseStructureOfList( <sl> )
##

InstallMethod( SparseStructureOfList, "sparse list by sorted list",
        [IsSparseListBySortedListRep and IsList],
        sl -> [ sl![SL_DEFAULT], sl![SL_POSS], sl![SL_VALS]]);


#############################################################################
##
#M  <sl> [ <pos> ]  -- list element access, bypassing the generic function
##

InstallMethod(\[\], "access to SLbySL (shortcut)",
        [IsSparseListBySortedListRep and IsList, IsPosInt],
        function(v,i)
    local   p;
    if i > v![SL_LENGTH] then
        Error("Position ",i," must have a bound value");
    else
        p := PositionSet(v![SL_POSS],i);
        if p = fail then
            return v![SL_DEFAULT];
        else
            return v![SL_VALS][p];
        fi;
    fi;
end);

#############################################################################
##
#F  SparseListBySortedListNC( <poss>, <vals>, <length>, <default> )
##
##  This is the main constructor, responsible for assembling the data structure
##  (easy) and assigning the appropriate type (harder)
##
##  All lists in this representation know their length, of course, and
##  so know if they are finite and/or small. Otherwise, we just need
##  to sort out  whether we are a table
##

InstallGlobalFunction(SparseListBySortedListNC, function(poss, vals, length, default)
    local   filt,  fam,  type,  l;
    filt := IsMutable and IsList and IsDenseList and IsSparseList and
            IsListDefault
            and IsSparseListBySortedListRep and HasLength and
            HasIsSmallList and HasIsFinite and IsHomogeneousList and IsCollection;
    if length = 0 then
        Error("Don't like empty sparse lists");
    fi;
    if length <= MAX_SIZE_LIST_INTERNAL then
        filt := filt and IsSmallList;
    fi;
    if length < infinity then
        filt := filt and IsFinite;
    fi;
    if IsList(default) then
        filt := filt and IsTable;
    fi;
    fam := CollectionsFamily(FamilyObj(default));
    type :=  NewType( fam, filt);
    l := [];
    l[SL_LENGTH]  := length;
    l[SL_DEFAULT] := default;
    l[SL_POSS] := poss;
    l[SL_VALS] := vals;
    Objectify( type, l );
    Assert(1,Length(poss) = Length(vals));
    Assert(1,IsEmpty(poss) or IsSSortedList(poss));
    Assert(1,IsEmpty(poss) or IsPositionsList(poss));
    Assert(1,IsEmpty(poss) or poss[Length(poss)] <= length);
    Assert(1,IsEmpty(vals) or (IsHomogeneousList(vals) and FamilyObj(vals) = fam));
    return l;
end);

#############################################################################
##
#F  SparseListBySortedList( <poss>, <vals>, <length>, <default> )
##
##  This is the checking version of the constructor
##


InstallGlobalFunction(SparseListBySortedList, function(poss, vals, length, default)
    local   p;
    if length <> infinity and (not IsInt(length) or length < 0) then
        Error("SparseListBySortedList: Impossible list length");
    fi;
    if Length(poss) <> Length(vals) then
        Error("SparseListBySortedList: Unequal numbers of positions and values");
    fi;
    if Length(poss) > 0 then
        if not IsPositionsList(poss) or not IsSSortedList(poss) or
           poss[Length(poss)] > length then
            Error("SparseListBySortedList: bad list of exception positions");
        fi;
        if not IsDenseList(vals) then
            Error("SparseListBySortedList: hole in list of exception values");
        fi;
        if not IsHomogeneousList(vals) or FamilyObj(default) <>
           FamilyObj(vals[1]) then
            Error("SparseListBySortedList: list must be homogeneous");
        fi;
        poss := ShallowCopy(poss);
        vals := ShallowCopy(vals);
        p := Position(vals, default);
        while p <> fail do
            Unbind(vals[p]);
            Unbind(poss[p]);
            p := Position(vals, default, p);
        od;
    fi;

    #
    # This cleans up after removal of defaults
    #

    poss := Compacted(poss);
    vals := Compacted(vals);

    return SparseListBySortedListNC( poss, vals, length, default);
end);

#############################################################################
##
#M ShallowCopy( <sl> )
##

InstallMethod(ShallowCopy, "sparse list by sorted list",
        [IsSparseListBySortedListRep and IsDenseList],
        function(sl)
    return SparseListBySortedListNC(  ShallowCopy(sl![SL_POSS]),
                   ShallowCopy(sl![SL_VALS]),sl![SL_LENGTH],
                   sl![SL_DEFAULT]);
end);

#############################################################################
##
#M  <sl>[<pos>] := <obj>
##
##  This is a little complicated because of the various cases, and
##  the possible need to adjust the type
##

InstallMethod( \[\]\:\=, "sparse list by sorted list", IsCollsXElms,
        [ IsSparseListBySortedListRep and IsList and IsMutable,
        IsPosInt, IsObject ],
        function(sl, pos, obj)
    local   poss,  vals,  p,  l;
    #
    # If the resulting list will have a hole then we have to make it a
    # plain list
    #
    if sl![SL_LENGTH] <> infinity and pos > sl![SL_LENGTH] + 1 then
        PLAIN_SL( sl );
        sl[pos] := obj;
        return;
    fi;

    #
    # Otherwise we stay sparse. There are four cases according to
    # whether the list currently has a non-default entry in that position
    # and whether the value to be assigned is the default. In one case
    # there is nothing to do.
    #

    #
    # First adjust the length
    #

    if sl![SL_LENGTH] <> infinity and pos = sl![SL_LENGTH] + 1 then
        sl![SL_LENGTH] := pos;
        if pos > MAX_SIZE_LIST_INTERNAL then
            ResetFilterObj( sl, IsSmallList );
            SetFilterObj(sl, HasIsSmallList);
        fi;
    fi;

    #
    # Now actually change the list
    #

    poss := sl![SL_POSS];
    vals := sl![SL_VALS];
    p := PositionSorted( poss, pos);
    if p <= Length (poss) and poss[p] = pos then
        if obj = sl![SL_DEFAULT] then

            #
            # Case 1 default replacing a non-default
            #

            l := Length(vals);
            RemoveSet(poss, pos);
            vals{[p..l-1]} := vals{[p+1..l]};
            Unbind(poss[l]);
            Unbind(vals[l]);
        else
            #
            # Case 2 non-default replacing non-default
            #
            vals[p] := obj;
        fi;
    else

        if obj <> sl![SL_DEFAULT] then
            #
            # Case 3: non-default replacing default
            #
            AddSet(poss, pos);
            l := Length(vals);
            vals{[l+1,l..p+1]} := vals{[l,l-1..p]};
            vals[p] := obj;
        fi;
    fi;
    return;
end);

#############################################################################
##
#M  Unbind( <sl> [ <pos> ] )
##
##  Note that this is NOT the way to set an entry back to the default
##  unless you are unbinding the last entry, this will always make
##  a plain list.
##

InstallMethod( Unbind\[\], "sparse list by sorted list",
        [IsSparseListBySortedListRep and IsMutable and IsList, IsPosInt],
        function( sl, pos)
    local   poss;
    if pos > sl![SL_LENGTH] then
        return;
    fi;
    if pos < sl![SL_LENGTH] then
        PLAIN_SL(sl);
        Unbind(sl[pos]);
        return;
    fi;
    poss := sl![SL_POSS];
    if Length(poss) > 0 and poss[Length(poss)] = pos then
        Unbind(sl![SL_VALS][Length(poss)]);
        Remove(poss);
    fi;
    sl![SL_LENGTH] := pos-1;
    if pos -1 <= MAX_SIZE_LIST_INTERNAL then
        SetFilterObj( sl, IsSmallList );
    fi;
    return;
end);


InstallMethod( ListOp, "sparse list by sorted list",
        [ IsSparseListBySortedListRep and IsList, IsFunction],
        function(sl,func)
    return SparseListBySortedListNC( sl![SL_POSS],
                   List(sl![SL_VALS], func),
                   sl![SL_LENGTH],
                   func(sl![SL_DEFAULT]));
end);

InstallMethod(Append, "two compatible sparse sorted lists",
        [ IsSparseListBySortedListRep and IsList and IsMutable and IsFinite,
          IsSparseList],
        function( sl1, sl2)
    local   len1,  ss,  poss,  poss2,  i;
    ss := SparseStructureOfList( sl2);
    if not IsBound(ss[1]) or sl1![SL_DEFAULT] <> ss[1] then
        TryNextMethod();
    fi;
    len1 := sl1![SL_LENGTH];
    if Length(sl2) = infinity then
        sl1![SL_LENGTH] := infinity;
    else
        sl1![SL_LENGTH] := len1 + Length(sl2);
    fi;
    Append(sl1![SL_VALS], ss[3]);
    poss := sl1![SL_POSS];

    # This ShallowCopy is needed in the case where sl1 and sl2 are identical
    poss2 := ShallowCopy(ss[2]);
    for i in poss2 do
        Add(poss, i + len1);
    od;
    SortParallel( poss, sl1![SL_VALS]);
    if not IsHomogeneousList(sl2) then
        ResetFilterObj(sl1, IsHomogeneousList);
        ResetFilterObj(sl1, IsCollection);
    fi;
    if sl1![SL_LENGTH] > MAX_SIZE_LIST_INTERNAL then
        ResetFilterObj(sl1, IsSmallList);
        SetFilterObj(sl1, HasIsSmallList);
    fi;
end);

InstallMethod(Permuted, "sparse list", [IsSparseListBySortedListRep
        and IsSparseList, IsPerm],
        function( sl, p)
    local   poss,  vals;
    if LargestMovedPointPerm(p) > sl![SL_LENGTH] then
        Error("Permuted: Permutation moves too many points");
    fi;
    poss := OnTuples(sl![SL_POSS], p);
    vals := ShallowCopy(sl![SL_VALS]);
    SortParallel( poss, vals);
    return SparseListBySortedListNC( poss, vals, sl![SL_LENGTH], sl![SL_DEFAULT]);
end);

InstallMethod( FilteredOp, "sparse list", [IsSparseListBySortedListRep
        and IsSparseList, IsFunction],
        function(sl, filt)
    local   skipped,  iposs,  oposs,  ivals,  ovals,  i,  newlen;
    if filt(sl![SL_DEFAULT]) then
        skipped := 0;
        iposs := sl![SL_POSS];
        oposs := [];
        ivals := sl![SL_VALS];
        ovals := [];
        for i in [1..Length(iposs)] do
            if filt(ivals[i]) then
                Add(oposs,iposs[i]-skipped);
                Add(ovals,ivals[i]);
            else
                skipped := skipped+1;
            fi;
        od;
        if sl![SL_LENGTH] = infinity then
            newlen := infinity;
        else
            newlen := sl![SL_LENGTH] - skipped;
        fi;
        return SparseListBySortedListNC( oposs, ovals,
                       sl![SL_DEFAULT], newlen);
    else
        return Filtered(sl![SL_VALS], filt);
    fi;
end);

InstallMethod( ELMS_LIST, "sparse list", [IsSparseListBySortedListRep
        and IsSparseList, IsDenseList],
        function( sl, poss )
    local   iposs,  oposs,  ivals,  ovals,  i,  pos;
    Assert(1,IsPositionsList(poss));
    iposs := sl![SL_POSS];
    oposs := [];
    ivals := sl![SL_VALS];
    ovals := [];
    for i in [1..Length(poss)] do
        pos := PositionSet( iposs, poss[i]);
        if pos <> fail then
            Add(oposs, i);
            Add(ovals, ivals[pos]);
        fi;
    od;
    return SparseListBySortedListNC( oposs, ovals, Length(poss), sl![SL_DEFAULT]);
end);


InstallMethod(PositionNot, [IsSparseListBySortedListRep and
        IsSparseList, IsObject, IsInt],
        function(sl, obj, from)
    local poss,p,l, isdef,vals;
    poss := sl![SL_POSS];
    vals := sl![SL_VALS];
    p := PositionSorted(poss, from + 1);
    l := Length(poss);
    isdef := sl![SL_DEFAULT] = obj;
    if p <= l and poss[p] > from + 1 then
        if not isdef then
            return from+1;
        fi;
    fi;
    while p <= l do
        if vals[p] <> obj then
            return poss[p];
        fi;
        if isdef or p+1 < l and poss[p+1] = poss[p]+1 then
            p := p+1;
        else
            return poss[p]+1;
        fi;
    od;
    if not isdef then
        if l = 0 then
            return 1;
        else
            return poss[l]+1;
        fi;

    else
        return sl![SL_LENGTH]+1;
    fi;
end);







