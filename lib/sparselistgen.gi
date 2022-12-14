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
##  This file contains generic implementations for sparse lists
##


#############################################################################
##
#M <sl>[<pos>] list element access
##

InstallMethod(\[\], [IsSparseList, IsPosInt],
        function( sl, pos )
    local   ss,  p;
    if pos <= Length(sl) then
        ss := SparseStructureOfList(sl);
        p := Position(ss[2], pos);
        if p <> fail  then
            if IsBound(ss[3][p]) then
                return ss[3][p];
            else
                Error("Entry of sparse list is not bound");
            fi;
        else
            if IsBound(ss[1]) then
                return ss[1];
            else
                Error("Entry of sparse list is not bound");
            fi;
        fi;
    else
        Error("Entry of sparse list is not bound");
    fi;
end);

#############################################################################
##
#M IsBound(<sl>[<pos>]) list element test
##

InstallMethod(IsBound\[\], [IsSparseList, IsPosInt],
        function(sl, pos)
    local   ss,  p;
    if pos <= Length(sl) then
        ss := SparseStructureOfList(sl);
        p := Position(ss[2], pos);
        if p <> fail  then
            return IsBound(ss[3][p]);
        else
            return IsBound(ss[1]);
        fi;
    else
        return false;
    fi;
end);


#############################################################################
##
#M ViewObj( <sl> )
##

InstallMethod(ViewObj,  "sparse lists", [IsSparseList and IsDenseList],
        function(sl)
    local   ss, poss,  vals,  i;
    ss := SparseStructureOfList( sl );
    Print("<< sparse list length ", Length(sl),
          " default ");
    if IsBound(ss[1]) then
        ViewObj( ss[1]);
    else
        Print( "unbound");
    fi;
    Print(" exceptions" );
    poss := ss[2];
    vals := ss[3];
    for i in [1..Length(poss)] do
        Print(" ");
        Print(poss[i],":");
        if IsBound(vals[i]) then
            ViewObj(vals[i]);
        else
            Print("unbound");
        fi;
    od;
    Print(" >>");
end);

#############################################################################
##
#F PLAIN_SL ( <sl> ) convert a sparse list in place to a plain list
##
##

BindGlobal("PLAIN_SL", function(sl)
    if not IsPlistRep(sl) then
        CLONE_OBJ(sl, PlainListCopy(sl));
    fi;
end);

#############################################################################
##
#M MaxmimumList ( <sl> )
##
##  This is a little more complicated than you might think, because the
##  default value may not actually appear anywhere in the list
##

InstallMethod(MaximumList, "sparse list", [IsSparseList and IsList],
        function(sl)
    local   ss,  max;
    ss := SparseStructureOfList(sl);
    max := MaximumList(ss[3]);
    if IsBound(ss[1]) and Length(ss[2]) < Length(sl) then
        max := Maximum( max, ss[1] );
    fi;
    return max;
end);

#############################################################################
##
#M MinimumList( <sl> )
##
##  This is a little more complicated than you might think, because the
##  default value may not actually appear anywhere in the list
##

InstallMethod(MinimumList, "sparse list", [IsSparseList and IsList],
        function(sl)
    local   ss,  min;
    ss := SparseStructureOfList(sl);
    min := MinimumList(ss[3]);
    if Length(ss[2]) < Length(sl) and IsBound(ss[1]) then
        min := Minimum( min, ss[1] );
    fi;
    return min;
end);

#############################################################################
##
#M  <sl1>{<poss>} := <sl2>     multiple assignment
##
##  This method only handles the case where the two sparse lists have
##  the same default
##

InstallMethod(ASSS_LIST, "two compatible sparse lists",
        [IsSparseList and IsMutable, IsPositionsList, IsSparseList],
        function(sl1, poss, sl2 )
    local   ss1,  ss2,  i;
    ss1 := SparseStructureOfList(sl1);
    ss2 := SparseStructureOfList(sl2);
    if not IsBound(ss1[1]) or not IsBound(ss2[1])  then
        TryNextMethod();
    fi;
    if ss1[1] <> ss2[1] then
        TryNextMethod();
    fi;
    for i in [1..Length(ss2[2])] do
        if IsBound(ss2[3][i]) then
            sl1[poss[ss2[2][i]]] := ss2[3][i];
        else
            Error("multiple assignment trying to assign a hole");
        fi;
    od;
end);

#############################################################################
##
#M  NumberOp( <sl>, <func> )
##


InstallMethod(NumberOp, "sparse list", [IsSparseList, IsFunction],
        function(sl, func)
    local   ss,  n;
    ss := SparseStructureOfList(sl);
    if IsBound(ss[1]) and func(ss[1]) then
        n := Length(sl) - Length(ss[2]);
    else
        n := 0;
    fi;
    return n + Number(ss[3],func);
end);



#############################################################################
##
#M  ForAllOp( <sl>, <func> )
##
##  This is a little more complicated than you might think, because the
##  default value may not actually appear anywhere in the list
##


InstallMethod(ForAllOp,
        "sparse list", [IsSparseList, IsFunction],
        function(sl, func)
    local   ss;
    ss := SparseStructureOfList(sl);
    return ForAll(ss[3], func) and (Length(ss[2]) = Length(sl) or not
                   IsBound(ss[1]) or func(ss[1]));
end);

#############################################################################
##
#M  ForAnyOp( <sl>, <func> )
##
##  This is a little more complicated than you might think, because the
##  default value may not actually appear anywhere in the list
##

InstallMethod(ForAnyOp,
        "sparse list", [IsSparseList, IsFunction],
        function(sl, func)
    local   ss;
    ss := SparseStructureOfList(sl);
    return ForAny(ss[3], func) or (Length(ss[2]) <> Length(sl) and
                   IsBound(ss[1]) and func(ss[1]));
end);

#############################################################################
##
#M  IsSparseRowVector( <sl> )
##

InstallMethod( IsSparseRowVector,
        "sparse list", [IsSparseList],
        function( sl )
    local ss;
    ss := SparseStructureOfList(sl);
    return IsBound(ss[1]) and IsDenseList(ss[3]) and
           ForAll(ss[3], x->ss[1] = ZeroOp(x));
end);

#############################################################################
##
#M  SparseStructureOfList( <list> ) default method
#M  SparseStructureOfList( <list>, <prescribed-default> )
##

InstallMethod(SparseStructureOfList,
        "find a sparse structure for any finite list",
        [IsList and IsFinite],
        function(l)
    if IsSparseList(l) then
        TryNextMethod();
    else
        return   [,[1..Length(l)], l];
    fi;
end);

InstallOtherMethod(SparseStructureOfList,
        "any list, with prescribed default",
        [IsList and IsFinite, IsObject],
        function (l, def)
    local   poss,  vals,  j,  i;
    poss := []; vals := []; j := 1;
    for i in [1..Length(l)] do
        if not IsBound(l[i]) then
            poss[j] := i;
            j := j+1;
        elif l[i] <> def then
            poss[j] := i;
            vals[j] := l[i];
            j := j+1;
        fi;
    od;
    return [def, poss, vals];
end);
