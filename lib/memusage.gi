#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##


#############################################################################
##
#M  MemoryUsage( <obj> )
##
InstallGlobalFunction( MemoryUsage, function( o )
    local isImmediateObj, visit, mem, cache, todo, i, sub;

    isImmediateObj := x -> TNUM_OBJ(x) in [T_INT, T_FFE];
    visit := function(sub)
        if not isImmediateObj(sub) and not FIND_OBJ_SET(cache, sub) then
            ADD_OBJ_SET(cache, sub);
            Add(todo, sub);
        fi;
    end;

    if isImmediateObj(o) then
        return MU_MemPointer;
    fi;

    mem := 0;
    todo := [ o ];
    cache := OBJ_SET(todo);
    while Length(todo) > 0 do
        o := Remove(todo);

        if IsFamily(o) or IsType(o) then
            # Intentionally ignore families and types
            continue;
        fi;

        mem := mem + SIZE_OBJ(o) + MU_MemBagHeader + MU_MemPointer;
        if IsRat(o) then
            visit(NumeratorRat(o));
            visit(DenominatorRat(o));
        elif IsFunction(o) then
            if FUNC_BODY_SIZE(o) > 0 then
                # count the body (T_BODY)
                mem := mem + MU_MemBagHeader + MU_MemPointer + FUNC_BODY_SIZE(o);
            fi;
        elif IsPlistRep(o) then
            for sub in o do
                visit(sub);
            od;
        elif IsRecord(o) then
            for i in RecNames(o) do
                visit(o.(i));
            od;
        elif IS_POSOBJ(o) then
            for i in [1..LEN_POSOBJ(o)] do
                if IsBound(o![i]) then
                    visit(o![i]);
                fi;
            od;
        elif IS_DATOBJ(o) then
            # a DATOBJ cannot reference any subobjects (other than its type,
            # which we ignore for all kinds of objects)
        elif IS_COMOBJ(o) then
            for i in NamesOfComponents(o) do
                visit(o!.(i));
            od;
        elif TNUM_OBJ(o) <= LAST_LIST_TNUM then
            # o is another constant TNUM, or a blist, range, string...
            # so we don't need to visit subobjects, nor is there anything extra.
        else
            # Use method dispatch to deal with other kinds of objects. Mostly
            # intended to allow kernel extensions to add MemoryUsage support
            # for their custom TNUMs.
            mem := mem + MemoryUsageOp(o, visit);
        fi;
    od;

    return mem;
end);


InstallMethod( MemoryUsageOp,
    [ IsObjSet, IsFunction ],
function(o, visit)
    local sub;
    for sub in OBJ_SET_VALUES(o) do
        visit(sub);
    od;
    return 0;
end);

InstallMethod( MemoryUsageOp,
    [ IsObjMap, IsFunction ],
function(o, visit)
    local sub;
    for sub in OBJ_MAP_KEYS(o) do
        visit(sub);
    od;
    for sub in OBJ_MAP_VALUES(o) do
        visit(sub);
    od;
    return 0;
end);

InstallMethod( MemoryUsageOp,
    [ IsObject, IsFunction ],
function(o, visit)
    Info(InfoWarning, 1, "No MemoryUsage method installed for ",
                         TNAM_OBJ(o),
                         ", reported usage may be too low" );
    return 0;
end);
