#############################################################################
##
#W perlist.gi                                               Laurent Bartholdi
##
#H   @(#)$Id: perlist.gi,v 1.9 2011/05/01 14:31:29 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  This file implements periodic lists
##
#############################################################################
##
BindGlobal("EXTENDPERIODICLIST@", function(l,i)
    local x;
    if l![2]=[] then return fail; fi;
    while Length(l![1])<i-Length(l![2]) do
        Append(l![1],l![2]);
    od;
    if Length(l![1])<i then
        x := l![2]{[1..i-Length(l![1])]};
        Append(l![1],x);
        l![2] := l![2]{[Length(x)+1..Length(l![2])]};
        Append(l![2],x);
    fi;
    return true;
end);

InstallMethod(PeriodicList, "for a list",
        [IsList],
        l->Objectify(TYPE_LIST_PERIODIC,[l,[]]));

InstallMethod(PeriodicList, "for a periodic list",
        [IsPeriodicList],
        l->l);

InstallMethod(PeriodicList, "for two lists",
        [IsList, IsList],
        function (l,m)
    return Objectify(TYPE_LIST_PERIODIC,[l,m]);
end);

InstallMethod(PeriodicList, "for a list and a position",
        [IsList,IsPosInt],
        function(l,i)
    return PeriodicList(l{[1..i-1]},l{[i..Length(l)]});
end);

InstallMethod(PeriodicList, "for a list and a function",
        [IsList,IsFunction],
        function(l,f)
    return PeriodicList(List(l,f),[]);
end);

InstallMethod(PeriodicList, "for a periodic list and a function",
        [IsPeriodicList,IsFunction],
        function(l,f)
    return PeriodicList(List(l![1],f),List(l![2],f));
end);

InstallMethod(PrePeriod, "for a periodic list",
        [IsPeriodicList],
        l->l![1]);

InstallMethod(Period, "for a periodic list",
        [IsPeriodicList],
        l->l![2]);

InstallOtherMethod(ListOp, "for a periodic list",
        [IsPeriodicList],
        function(l)
    if l![2]=[] then
        return l![1];
    else
        return fail;
    fi;
end);

InstallMethod(CompressPeriodicList, "for a periodic list",
        [IsPeriodicList],
        function(l)
    local brk, d, divs, i, j, n, q;

    if l![2]=[] then return; fi;
    n := Length(l![2]);
    divs := FactorsInt(n);
    while Length(divs)>0 do
        d := Remove(divs,1); q := n/d;
        brk := false;
        for i in [1..q] do
            for j in [i,q+i..q*(d-2)+i] do
                if l![2][j]<>l![2][j+q] then brk := true; break; fi;
            od;
            if brk then break; fi;
        od;
        if brk then
            while Length(divs)>0 and divs[1]=d do Remove(divs,1); od;
        else
            n := q;
        fi;
    od;
    q := n;
    d := Length(l![1]);
    while d>0 and l![1][d]=l![2][q] do
        Remove(l![1]);
        d := d-1;
        q := q-1; if q=0 then q := n; fi;
    od;
    if q<>n or n<>Length(l![2]) then
        l![2] := Concatenation(l![2]{[q+1..n]},l![2]{[1..q]});
    fi;
end);

InstallGlobalFunction(CompressedPeriodicList,
        function(arg)
    local l;
    l := CallFuncList(ApplicableMethod(PeriodicList,arg),arg);
    CompressPeriodicList(l);
    return l;
end);

InstallMethod(String, "for a periodic list",
        [IsPeriodicList],
        function(l)
    local s;
    s := CONCAT@("PeriodicList(",l![1]);
    if l![2]<>[] then APPEND@(s,",",l![2]); fi;
    Append(s,")");
    return s;
end);

InstallMethod(ViewString, "for a periodic list",
        [IsPeriodicList],
        function(l)
    local s, comma;
    if l![2]=[] then
        return ViewString(l![1]);
    else
        s := "[";
        if l![1]<>[] then
            Append(s," ");
            Append(s,JoinStringsWithSeparator(List(l![1],ViewString),", "));
            Append(s,", ");
        fi;
        Append(s,"/ ");
        Append(s,JoinStringsWithSeparator(List(l![2],ViewString),", "));
        Append(s," ]");
        return s;
    fi;
end);

INSTALLPRINTERS@(IsPeriodicList);

InstallMethod(ViewObj, "for a periodic list",
        [IsPeriodicList],
        function(l)
    local x, s, comma;
    if l![2]=[] then
        ViewObj(l![1]);
    else
        Print("[");
        if l![1]<>[] then
            Print(" ");
            for x in l![1] do ViewObj(x); Print(", "); od;
        fi;
        Print("/ ");
        comma := false;
        for x in l![2] do
            if comma then Print(", "); fi;
            ViewObj(x);
            comma := true;
        od;
        Print(" ]");
    fi;
end);

InstallMethod(\[\], "for a periodic list and a position",
        [IsPeriodicList,IsPosInt],
        function(l,i)
    if i<=Length(l![1]) then
        return l![1][i];
    elif l![2]=[] then
        Error("Periodic List Element: <list>[",i,"] must have an assigned value\n");
    else
        return l![2][(i-Length(l![1])-1) mod Length(l![2]) + 1];
    fi;
end);

InstallMethod(\{\}, "for a periodic list and positions",
        [IsPeriodicList,IsList],
        function(l,p)
    local x, i;
    x := [];
    for i in p do
        if i<=Length(l![1]) then
            Add(x,l![1][i]);
        elif l![2]=[] then
            Error("Periodic List Element: <list>[",i,"] must have an assigned value\n");
        else
            Add(x,l![2][(i-Length(l![1])-1) mod Length(l![2]) + 1]);
        fi;
    od;
    return x;
end);

InstallMethod(Iterator, "for a periodic list",
        [IsPeriodicList],
        function(l)
    if l![2]=[] then
        return Iterator(l![1]);
    else
        return IteratorByFunctions(rec(i := 0,
                       p := 1,
                       l := l,
                       NextIterator := function(iter)
            iter!.i := iter!.i+1;
            if iter!.i>Length(iter!.l![iter!.p]) then
                iter!.p := 2;
                iter!.i := 1;
            fi;
            return iter!.l![iter!.p][iter!.i];
        end,
          IsDoneIterator := ReturnFalse,
                            ShallowCopy := function(iter)
            return rec(i := iter!.i,
                       p := iter!.p,
                       l := iter!.l,
                       NextIterator := iter!.NextIterator,
                       IsDoneIterator := iter!.IsDoneIterator,
                       ShallowCopy := iter!.ShallowCopy);
            end));
    fi;
end);

InstallOtherMethod(IsFinite, "for a periodic list",
        [IsPeriodicList],
        l->l![2]=[]);

InstallMethod(Length, "for a periodic list",
        [IsPeriodicList],
        function(l)
    if l![2]=[] then
        return Length(l![1]);
    else
        return infinity;
    fi;
end);

InstallMethod(ShallowCopy, "for a periodic list",
        [IsPeriodicList],
        l->PeriodicList(ShallowCopy(l![1]),ShallowCopy(l![2])));

InstallOtherMethod(\[\]\:\=, "for a periodic list, a position and an object",
        [IsPeriodicList,IsPosInt,IsObject],
        function(l,i,x)
    EXTENDPERIODICLIST@(l,i);
    l![1][i] := x;
end);

InstallOtherMethod(\{\}\:\=, "for a periodic list, positions and objects",
        [IsPeriodicList,IsList,IsList],
        function(l,p,x)
    local i;
    for i in [1..Length(p)] do
        EXTENDPERIODICLIST@(l,p[i]);
        l![1][p[i]] := x[i];
    od;
end);

InstallMethod(ISB_LIST, "for a periodic list and position",
        [IsPeriodicList, IsPosInt],
        function(l,i)
    if l![2]=[] or i<=Length(l![1]) then
        return ISB_LIST(l![1],i);
    else
        return ISB_LIST(l![2],(i-Length(l![1])-1) mod Length(l![2]) + 1);
    fi;
end);

InstallOtherMethod(UNB_LIST, "for a periodic list and position",
        [IsPeriodicList, IsPosInt],
        function(l,i)
    EXTENDPERIODICLIST@(l,i+1);
    UNB_LIST(l![1],i);
end);

InstallOtherMethod(Add, "for a periodic list and an element",
        [IsPeriodicList, IsObject],
        function(l,x)
    if l![2]=[] then
        Add(l![1],x);
    else
        Error("Cannot add at end of infinite list ",l,"\n");
    fi;
end);

InstallOtherMethod(Add, "for a periodic list, an element and a position",
        [IsPeriodicList, IsObject, IsPosInt],
        function(l,x,i)
    EXTENDPERIODICLIST@(l,i-1);
    Add(l![1],x,i);
end);

InstallOtherMethod(Remove, "for a periodic list",
        [IsPeriodicList],
        function(l)
    if l![2]=[] then
        return Remove(l![1]);
    else
        Error("Cannot remove from end of infinite list ",l,"\n");
    fi;
end);

InstallOtherMethod(Remove, "for a periodic list and a position",
        [IsPeriodicList, IsPosInt],
        function(l,i)
    EXTENDPERIODICLIST@(l,i);
    return Remove(l![1],i);
end);

InstallMethod(IsConfinal, "for two periodic lists",
        [IsPeriodicList, IsPeriodicList],
        function(l,m)
    local i, il, im, ll, lm;
    if l![2]=[] or m![2]=[] then return fail; fi;
    il := Length(l![1]); ll := Length(l![2]);
    im := Length(m![1]); lm := Length(m![2]);
    if il>im then
        il := 0; im := RemInt(il-im,lm);
    else
        il := RemInt(im-il,ll); im := 0;
    fi;
    for i in [1..LcmInt(ll,lm)] do
        il := il+1; if il>ll then il := 1; fi;
        im := im+1; if im>lm then im := 1; fi;
        if l![2][il]<>m![2][im] then return false; fi;
    od;
    return true;
end);

InstallMethod(ConfinalityClass, "for a periodic list",
        [IsPeriodicList],
        function(l)
    local i, n;
    if l![2]=[] then
        return [];
    else
        n := Length(l![2]);
        i := Length(l![1]) mod n;
        return CompressedPeriodicList([],
                       Concatenation(l![2]{[n-i+1..n]},l![2]{[1..n-i]}));
    fi;
end);

InstallMethod(LargestCommonPrefix, "for a list of lists",
        [IsList],
        function(L)
    local p, i;
    L := Set(L);
    if Size(L)=1 then return L[1]; fi;
    p := [];
    i := 1;
    while ForAll(L,x->x[i]=L[1][i]) do
        Add(p,L[1][i]);
        i := i+1;
    od;
    return p;
end);

InstallMethod(\=, "for two periodic lists",
        [IsPeriodicList, IsPeriodicList],
        function(l,m)
    local il, im, pl, pm, dol, dom;
    if l![2]=[] then
        return m![2]=[] and l![1]=m![1];
    elif m![2]=[] then return false; fi;
    il := 0; pl := 1; dol := true;
    im := 0; pm := 1; dom := true;
    while dol or dom do
        il := il+1;
        if il>Length(l![pl]) then
            if pl=2 then dol := false; fi;
            pl := 2; il := 1;
        fi;
        im := im+1;
        if im>Length(m![pm]) then
            if pm=2 then dom := false; fi;
            pm := 2; im := 1;
        fi;
        if l![pl][il]<>m![pm][im] then return false; fi;
    od;
    return true;
end);

InstallMethod(\=, "for a list and a periodic list",
        [IsPeriodicList, IsList],
        function(l,m)
    return l![2]=[] and l![1]=m;
end);

InstallMethod(\=, "for a periodic list and a list",
        [IsList, IsPeriodicList],
        function(l,m)
    return m![2]=[] and l=m![1];
end);

InstallMethod(\in, "for a periodic list",
        [IsObject, IsPeriodicList],
        function(x,l)
    return x in l![1] or x in l![2];
end);

InstallMethod(\<, "for two periodic lists",
        [IsPeriodicList, IsPeriodicList],
        function(l,m)
    local il, im, pl, pm, dol, dom;
    if l![2]=[] and m![2]=[] then
        return l![1]<m![1];
    fi;
    il := 0; pl := 1; dol := true;
    im := 0; pm := 1; dom := true;
    while dol or dom do
        il := il+1;
        if il>Length(l![pl]) then
            if l![2]=[] then return true; fi; # lex ordering
            if pl=2 then dol := false; fi;
            pl := 2; il := 1;
        fi;
        im := im+1;
        if im>Length(m![pm]) then
            if m![2]=[] then return false; fi; # lex ordering
            if pm=2 then dom := false; fi;
            pm := 2; im := 1;
        fi;
        if l![pl][il]<>m![pm][im] then
            return l![pl][il]<m![pm][im];
        fi;
    od;
    return false; # they're equal
end);

InstallMethod(\<, "for a list and a periodic list",
        [IsList, IsPeriodicList],
        function(l,m)
    local il, im, pm;
    if m![2]=[] then
        return l<m![1];
    fi;
    il := 0;
    im := 0; pm := 1;
    while true do
        il := il+1;
        if il>Length(l) then return true; fi; # lex ordering
        im := im+1;
        if im>Length(m![pm]) then
            pm := 2; im := 1;
        fi;
        if l[il]<>m![pm][im] then
            return l[il]<m![pm][im];
        fi;
    od;
    return false; # they're equal
end);

InstallMethod(\<, "for a periodic list and a list",
        [IsPeriodicList, IsList],
        function(l,m)
    local il, pl, im;
    if l![2]=[] then
        return l![1]<m;
    fi;
    il := 0; pl := 1;
    im := 0;
    while true do
        il := il+1;
        if il>Length(l![pl]) then
            pl := 2; il := 1;
        fi;
        im := im+1;
        if im>Length(m) then return false; fi; # lex ordering
        if l![pl][il]<>m[im] then
            return l![pl][il]<m[im];
        fi;
    od;
    return false; # they're equal
end);

InstallMethod(MaximumList, "for a periodic list",
        [IsPeriodicList],
        function(l)
    if l![2]=[] then
        return MaximumList(l![1]);
    elif l![1]=[] then
        return MaximumList(l![2]);
    else
        return Maximum(MaximumList(l![1]),MaximumList(l![2]));
    fi;
end);

InstallMethod(MinimumList, "for a periodic list",
        [IsPeriodicList],
        function(l)
    if l![2]=[] then
        return MinimumList(l![1]);
    elif l![1]=[] then
        return MinimumList(l![2]);
    else
        return Minimum(MinimumList(l![1]),MinimumList(l![2]));
    fi;
end);

InstallMethod(FilteredOp, "for a periodic list",
        [IsPeriodicList, IsFunction],
        function(l,p)
    return PeriodicList(Filtered(l![1],p),Filtered(l![2],p));
end);

InstallMethod(ListOp, "for a periodic list",
        [IsPeriodicList], ShallowCopy);

InstallMethod(ListOp, "for a periodic list",
        [IsPeriodicList, IsFunction],
        function(l,f)
    return PeriodicList(List(l![1],f),List(l![2],f));
end);

InstallOtherMethod(Append, "for periodic lists",
        [IsPeriodicList, IsPeriodicList],
        function(l,m)
    if l![2]=[] then
        Append(l![1],m![1]);
        l![2] := m![2];
    else
        Error("Append: first list must be finite\n");
    fi;
end);

InstallMethod(Compacted, "for a periodic list",
        [IsPeriodicList],
        function(l)
    return PeriodicList(Compacted(l![1]),Compacted(l![2]));
end);

InstallMethod(Collected, "for a periodic list",
        [IsPeriodicList],
        function(l)
    local x, i, p;
    x := Collected(l![1]);
    for i in l![2] do
        p := PositionFirstComponent(x,i);
        if p>Length(x) then
            AddSet(x,[i,infinity]);
        else
            x[p][2] := infinity;
        fi;
    od;
    return x;
end);

InstallMethod(Flat, "for a periodic list",
        [IsPeriodicList],
        function(l)
    return PeriodicList(Flat(l![1]),Flat(l![2]));
end);

InstallMethod(Permuted, "for a periodic list",
        [IsPeriodicList,IsPerm],
        function(l,p)
    EXTENDPERIODICLIST@(l,LargestMovedPoint(p));
    return PeriodicList(Permuted(l![1],p),l![2]);
end);

InstallMethod(Set, "for a periodic list",
        [IsPeriodicList],
        l->Set(Concatenation(l![1],l![2])));

InstallMethod(Unique, "for a periodic list",
        [IsPeriodicList],
        l->Unique(Concatenation(l![1],l![2])));

InstallMethod(Position, "for a periodic list",
        [IsPeriodicList,IsObject,IsInt],
        function(l,x,from)
    local p, i, len;
    p := Position(l![1],x,from);
    if p<>fail then return p; fi;
    from := Maximum(from,Length(l![1]));
    len := Length(l![2]);
    if len=0 then return fail; fi;
    i := RemInt(from-Length(l![1]),len);
    p := Position(l![2],x,i);
    if p<>fail then return from+p-i; fi;
    p := Position(l![2],x,0);
    if p<>fail then return from+p-i+len; fi;
    return fail;
end);

InstallMethod(NumberOp, "for a periodic list",
        [IsPeriodicList,IsFunction],
        function(l,p)
    local n;
    n := Number(l![2],p);
    if n>0 then
        return infinity;
    else
        return NumberOp(l![1],p);
    fi;
end);

InstallMethod(PositionNthOccurrence, "for a periodic list",
        [IsPeriodicList,IsObject,IsPosInt],
        function(l,x,n)
    local p, i, len;
    p := 0;
    while n>0 and p<>fail do
        p := Position(l![1],x,p);
        n := n-1;
    od;
    if p<>fail then return p; fi;
    len := Number(l![2],y->y=x);
    if len=0 then return fail; fi;
    return Length(l![1])+Length(l![2])*QuoInt(n,len)+
           PositionNthOccurrence(l![2],x,1+RemInt(n,len));
end);

InstallMethod(FirstOp, "for a periodic list",
        [IsPeriodicList,IsFunction],
        function(l,p)
    local x;
    x := FirstOp(l![1],p);
    if x=fail then
        return FirstOp(l![2],p);
    else
        return x;
    fi;
end);

InstallOtherMethod(PositionProperty, "for a periodic list",
        [IsPeriodicList,IsFunction],
        function(l,p)
    local x;
    x := PositionProperty(l![1],p);
    if x=fail then
        x := PositionProperty(l![2],p);
        if x<>fail then x := x+Length(l![1]); fi;
    fi;
    return x;
end);

InstallMethod(ForAllOp, "for a periodic list",
        [IsPeriodicList,IsFunction],
        function(l,p)
    return ForAllOp(l![1],p) and ForAllOp(l![2],p);
end);

InstallMethod(ForAnyOp, "for a periodic list",
        [IsPeriodicList,IsFunction],
        function(l,p)
    return ForAnyOp(l![1],p) or ForAnyOp(l![2],p);
end);
#############################################################################

#############################################################################
##
#H FIFOs
##
InstallMethod(NewFIFO, "(FR) for a list",
        [IsList],
        function(L)
    local iter;
    iter := rec(out := ShallowCopy(L),
                index := 1,
                inp := [],
                NextIterator := function(iter)
        local x;
        if iter!.index > Length(iter!.out) then
            iter!.index := 1;
            iter!.out := iter!.inp;
            iter!.inp := [];
        fi;
        while iter!.index > Length(iter!.out) do
            Error("FIFO is empty");
        od;
        x := iter!.out[iter!.index];
        Unbind(iter!.out[iter!.index]);
        iter!.index := iter!.index+1;
        return x;
    end,
      IsDoneIterator := function(iter)
        return iter!.index > Length(iter!.out) and iter!.inp=[];
    end,
      ShallowCopy := function(iter)
        return rec(out := ShallowCopy(iter!.out),
                   index := iter!.index,
                   inp:= ShallowCopy(iter!.inp),
                   NextIterator := iter!.NextIterator,
                   IsDoneIterator := iter!.IsDoneIterator,
                   ShallowCopy := iter!.ShallowCopy);
    end);

    return Objectify( NewType(IteratorsFamily, IsIteratorByFunctions and IsMutable and IsFIFO), iter);
end);

InstallMethod(NewFIFO, "(FR) for no arguments",
        [],
        function()
    return NewFIFO([]);
end);

InstallMethod(Add, "(FR) for a FIFO and an object",
        [IsFIFO, IsObject],
        function(iter,x)
    Add(iter!.inp,x);
end);

InstallOtherMethod(Add, "(FR) for a FIFO, an object and an index",
        [IsFIFO,IsObject,IsPosInt], 1,
        function(iter,x,i)
    local l;
    l := i+iter!.index-1;
    if l<=Length(iter!.out)+1 then
        Add(iter!.out,x,l);
    else
        Add(iter!.inp,x,l-Length(iter!.out));
    fi;
end);

InstallMethod(Append, "(FR) for a FIFO and a list",
        [IsFIFO, IsList],
        function(iter,l)
    Append(iter!.inp,l);
end);

InstallMethod(String, "(FR) for a FIFO",
        [IsFIFO],
        f->"NewFIFO(...)");

InstallMethod(ViewString, "(FR) for a FIFO",
        [IsFIFO],
        f->CONCAT@("<FIFO iterator of size ",Length(f),">"));

INSTALLPRINTERS@(IsFIFO);

InstallMethod(Length, "(FR) for a FIFO",
        [IsFIFO],
        iter->Length(iter!.out)-iter!.index+1+Length(iter!.inp));

InstallOtherMethod(Remove, "(FR) for a FIFO",
        [IsFIFO],
        NextIterator);

InstallOtherMethod(Remove, "(FR) for a FIFO and a position",
        [IsFIFO,IsPosInt], 1,
        function(iter,i)
    local l;
    l := i+iter!.index-1;
    if l <= Length(iter!.out) then
        return Remove(iter!.out,l);
    else
        return Remove(iter!.inp,l-Length(iter!.out));
    fi;
end);

InstallMethod(IsEmpty, "(FR) for a FIFO",
        [IsFIFO],
        IsDoneIterator);

InstallMethod(\[\], "(FR) for a FIFO and an index",
        [IsFIFO,IsInt],
        function(iter,i)
    local l;
    l := i+iter!.index-1;
    if l <= Length(iter!.out) then
        return iter!.out[l];
    else
        return iter!.inp[l-Length(iter!.out)];
    fi;
end);

InstallOtherMethod(\[\]\:\=, "(FR) for a FIFO, an index and an object",
        [IsFIFO,IsInt,IsObject],
        function(iter,i,x)
    local l;
    l := i+iter!.index-1;
    if l <= Length(iter!.out) then
        iter!.out[l] := x;
    else
        iter!.inp[l-Length(iter!.out)] := x;
    fi;
end);

InstallMethod(AsList, "for a FIFO",
        [IsFIFO],
        iter->Compacted(Concatenation(iter!.out,iter!.inp)));

InstallMethod(AsSortedList, "for a FIFO",
        [IsFIFO],
        iter->AsSortedList(Concatenation(iter!.out,iter!.inp)));

InstallMethod(AsSSortedList, "for a FIFO",
        [IsFIFO],
        iter->AsSSortedList(Concatenation(iter!.out,iter!.inp)));

InstallMethod(Position, "(FR) for a FIFO, an object and a starting pos",
        [IsFIFO,IsObject,IsInt],
        function(iter,x,from)
    local l, p;
    l := iter!.index+from-1;
    p := Position(iter!.out,x,l);
    if p=fail then
        p := Position(iter!.inp,x,Maximum(0,l-Length(iter!.out)));
        if p=fail then
            return p;
        else
            return p-iter!.index+1+Length(iter!.out);
        fi;
    fi;
    return p-iter!.index+1;
end);

InstallOtherMethod(PositionProperty, "(FR) for a FIFO, a function and a starting pos",
        [IsFIFO,IsFunction,IsInt],
        function(iter,f,from)
    local p, i;
    for i in [iter!.index+from..Length(iter!.out)] do
        if f(iter!.out[i]) then
            return i-iter!.index+1;
        fi;
    od;
    from := Maximum(0,from-Length(iter!.out)+iter!.index);
    for i in [from+1..Length(iter!.inp)] do
        if f(iter!.inp[i]) then
            return i-iter!.index+Length(iter!.out)+1;
        fi;
    od;
    return fail;
end);

InstallOtherMethod(PositionProperty, "(FR) for a FIFO and a function",
        [IsFIFO,IsFunction],
        function(iter,f)
    return PositionProperty(iter,f,0);
end);
  
InstallMethod(ForAllOp, "for a FIFO",
        [IsFIFO,IsFunction],
        function(l,p)
    return ForAllOp(l!.out,p) and ForAllOp(l!.inp,p);
end);

InstallMethod(ForAnyOp, "for a FIFO",
        [IsFIFO,IsFunction],
        function(l,p)
    return ForAnyOp(l!.out,p) or ForAnyOp(l!.inp,p);
end);
#############################################################################

#E perlist.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
