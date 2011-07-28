#############################################################################
##
#W trans.gi                                                 Laurent Bartholdi
##
#H   @(#)$Id: trans.gi,v 1.19 2011/06/13 22:54:35 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  This file implements transformations with no fixed acting domain
##
#############################################################################

InstallGlobalFunction(Trans,
        function(arg)
    local i, copy, img;
    if Length(arg)=0 then
        return OneTrans;
    elif Length(arg)=1 then
        if arg[1]=[] then
            return OneTrans;
        fi;
        copy := true;
        img := arg[1];
        for i in [1..Maximum(Length(img),Maximum(img))] do
            if not IsBound(img[i]) then
                if copy then img := ShallowCopy(img); copy := false; fi;
                img[i] := i;
            fi;
        od;
    else
        if IsFunction(arg[2]) then
            copy := List(arg[1],arg[2]);
        elif IsPerm(arg[2]) or IsTrans(arg[2]) then
            copy := List(arg[1], x->x^arg[2]);
        else
            copy := arg[2];
            while Length(arg[1])<>Length(copy) do
                Error("Source and range lists must have the same length");
            od;
        fi;
        img := [1..Maximum(Length(arg[1]),Maximum(arg[1]),Maximum(copy))];
        for i in [1..Length(arg[1])] do
            img[arg[1][i]] := copy[i];
        od;
    fi;
    return TransNC(img);
end);

InstallGlobalFunction(TransNC,
        function(img)
#!    if Set(img)=[1..Length(img)] then
#!        return PermList(img);
#!    else
        return Objectify(TYPE_TRANS, [Immutable(img)]);
#!    fi;
end);

InstallValue(OneTrans,
        TransNC([]));

InstallMethod(RandomTrans, [IsPosInt],
        n->Trans(List([1..n], i->Random([1..n]))));

InstallMethod(LargestMovedPoint, [IsTrans],
        function(t)
    local n;
    if t![1]=[] then
        return 0;
    fi;
    n := Length(t![1]);
    while n>0 and t![1][n]=n do n := n-1; od;
    return n;
end);

InstallMethod(SmallestMovedPoint, [IsTrans],
        function(t)
    local n;
    if t![1]=[] then
        return infinity;
    fi;
    n := 1;
    while n<=Length(t![1]) and t![1][n]=n do n := n+1; od;
    if n>Length(t![1]) then
        return infinity;
    else
        return n;
    fi;
end);

InstallMethod(MovedPoints, [IsTrans],
        t->Filtered([1..Length(t![1])],i->t![1][i]<>i));

InstallMethod(NrMovedPoints, [IsTrans],
        t->Number([1..Length(t![1])],i->t![1][i]<>i));

InstallOtherMethod(LargestMovedPoint, [IsTransSemigroup],
        g->Maximum(Concatenation(List(GeneratorsOfSemigroup(g),LargestMovedPoint),[0])));

InstallMethod(RankOfTrans, [IsTrans, IsList],
        function(t,a)
    return Size(Set(a,i->i^t));
end);

InstallMethod(RankOfTrans, [IsTrans],
        function(t)
    local k;
    k := KernelOfTrans(t);
    return Length(k)-Sum(k,Length);
end);

InstallMethod(KernelOfTrans, [IsTrans],
        function(t)
    local ker, i;

    ker:= [];
    for i in t![1] do
        ker[i]:= [];
    od;

    for i in [1..Length(t![1])] do
        Add(ker[i^t], i);
    od;

    return Set(Filtered(ker, l->Length(l)>1));
end);

InstallMethod(ImageSetOfTrans, [IsTrans,IsList],
        function(t,a)
    return Set(a,i->i^t);
end);

InstallMethod(PreImagesOfTrans, [IsTrans, IsPosInt],
        function(t,i)
    local l;
    l := Filtered([1..Length(t![1])],j->t![1][j]=i);
    if i>Length(t![1]) then
        Add(l,i);
    fi;
    return l;
end);

InstallMethod(RestrictedTrans, [IsTrans, IsListOrCollection],
        function(t,a)
    local u, i;
    u := [1..Maximum(a)];
    for i in a do
        if IsBound(t![1][i]) then u[i] := t![1][i]; fi;
    od;
    return TransNC(u);
end);

InstallMethod(ListTrans, [IsTrans],
        function(t)
    local n, l;
    n := Length(t![1]);
    if n=0 or t![1][n]<>n then
        return t![1];
    fi;
    l := ShallowCopy(t![1]);
    while n>0 and l[n]=n do
        Remove(l);
        n := n-1;
    od;
    return l;
end);

InstallMethod(ListTrans, [IsTrans, IsInt],
        function(t,n)
    local i;
    if Length(t![1])=n then
        return t![1];
    elif Length(t![1])>n then
        return t![1]{[1..n]};
    else
        t := ShallowCopy(t![1]);
        Append(t,[Length(t)+1..n]);
        return t;
    fi;
end);

InstallMethod(ListTrans, [IsPerm, IsInt], ListPerm);
InstallMethod(ListTrans, [IsPerm], ListPerm);
InstallMethod(ListTrans, [IsTransformation, IsInt],
        function(t,n) return ListTrans(AsTrans(t),n); end);
InstallMethod(ListTrans, [IsTransformation], ImageListOfTransformation);

InstallMethod(TransList, [IsList], Trans);

InstallMethod(AsTrans, [IsTransformation],
        t->TransNC(ImageListOfTransformation(t)));

InstallMethod(AsTrans, [IsTrans], t->t);

InstallMethod(AsTrans, [IsPerm], p->TransNC(ListPerm(p)));

InstallMethod(AsTransformation, [IsTrans, IsPosInt],
        function(t,n)
    return Transformation(ListTrans(t,n));
end);

InstallMethod(LeftQuotient, [IsTrans, IsTrans],
        function(t,u)
    local p, i;

    if KernelOfTrans(t)<>KernelOfTrans(u) then
        return fail;
    fi;

    p := [1..Maximum(Length(t![1]),Length(u![1]))];

    for i in [1..Length(p)] do
        p[i^t] := i^u;
    od;
    return PermList(p);
end);

InstallOtherMethod(\^, "int ^ trans",
        [IsPosInt, IsTrans],
        function(i,t)
    if IsBound(t![1][i]) then
        return t![1][i];
    else
        return i;
    fi;
end);

############################################################################
##
#O  Print(<trans>)
##
##  Just print the list of images.
##
InstallMethod(String, [IsTrans],
        function(t)
    return Concatenation("Trans([",JoinStringsWithSeparator(List(ListTrans(t),String),","),"])");
end);

InstallMethod(ViewString, [IsTrans],
        function(t)
    return Concatenation("<",JoinStringsWithSeparator(List(ListTrans(t),String),","),">");
end);

INSTALLPRINTERS@(IsTrans);

###########################################################################
##
#M  Permuted(<list>,<trans>)
##
##  If the transformtation is a permutation then permute the
##  list as indicated otherwise return fail
##
##
InstallOtherMethod(Permuted, "for a list and a trans",
        [IsList, IsTrans],
        function(l,t)
    t := AsPermutation(t);
    if t = fail then
        return fail;
    else
        return Permuted(l,t);
    fi;
end);

InstallMethod(\*, "trans * trans", IsIdenticalObj,
        [IsTrans, IsTrans],
        function(t,u)
    local i, v;
    v := [];
    for i in [1..Maximum(Length(t![1]),Length(u![1]))] do
        v[i] := (i^t)^u;
    od;
    return TransNC(v);
end);
InstallMethod(\*, "trans * perm",
	[IsTrans, IsPerm],
        function(t,p)
    local i, v;
    v := [];
    for i in [1..Maximum(Length(t![1]),LargestMovedPoint(p))] do
        v[i] := (i^t)^p;
    od;
    return TransNC(v);
end);
InstallMethod(\*, "perm * trans",
	[IsPerm, IsTrans],
        function(p,t)
    local i, v;
    v := [];
    for i in [1..Maximum(LargestMovedPoint(p),Length(t![1]))] do
        v[i] := (i^p)^t;
    od;
    return TransNC(v);
end);

InstallOtherMethod(\^, "trans ^ perm",
        [IsTrans, IsPerm],
        function(t,p)
    return p^-1*t*p;
end);

InstallMethod(One, "trans",
        [IsTrans],
        t->OneTrans);

InstallMethod(OneMutable, "trans",
        [IsTrans],
        t->OneTrans);

InstallMethod(InverseOp, "trans", [IsTrans],
#!ReturnFail
        function(t)
    local s, i;
    s := [];
    s{t![1]} := [1..Length(t![1])];
    for i in [1..Length(t![1])] do
        if not IsBound(s[i]) then return fail; fi;
    od;
    return TransNC(s);
end);

InstallOtherMethod(IsInvertible, "trans",
        [IsTrans],
        t->InverseOp(t)<>fail);

InstallMethod(AsPermutation, "trans", [IsTrans],
        function(t)
    return PermList(t![1]);
end);

############################################################################
##
#M  <trans> = <trans>
#M  <trans> < <trans>
##
##  Lexicographic ordering on image lists.
##
InstallMethod(\=, "trans = trans",
        [IsTrans, IsTrans],
        function(t,u)
    local lt, lu, i;
    lt := Length(t![1]);
    lu := Length(u![1]);
    if lt=lu then
        return t![1]=u![1];
    elif lt<lu then
        for i in [1..lt] do
            if t![1][i]<>u![1][i] then return false; fi;
        od;
        for i in [lt+1..lu] do if u![1][i]<>i then return false; fi; od;
    else
        for i in [1..lu] do
            if t![1][i]<>u![1][i] then return false; fi;
        od;
        for i in [lu+1..lt] do if t![1][i]<>i then return false; fi; od;
    fi;
    return true;
end);

InstallMethod(IsOne, "trans",
        [IsTrans],
        t->t![1]=[1..Length(t![1])]);

InstallMethod(\=, "trans = perm", true,
        [IsTrans, IsPerm],
#!        ReturnFalse
        function(t,p)
    return LargestMovedPoint(p)<=Length(t![1]) and t![1]=ListPerm(p,Length(t![1]));
end);

InstallMethod(\=, "perm = trans",
        [IsPerm, IsTrans],
#!        ReturnFalse
        function(p,t)
    return LargestMovedPoint(p)<=Length(t![1]) and t![1]=ListPerm(p,Length(t![1]));
end);

InstallMethod(\in, "trans in perm group",
        [IsTrans, IsPermGroup],
        SUM_FLAGS, # otherwise the "wrong family" method wins
#!        ReturnFalse
        function(t,g)
    return AsPermutation(t) in g;
end);

InstallMethod(\in, "perm in trans semigroup",
        [IsPerm, IsTransSemigroup],
        SUM_FLAGS, # otherwise the "wrong family" method wins
#!        ReturnFalse
        function(p,s)
    return AsTrans(p) in s;
end);

InstallMethod(\<, "trans < trans",
        [IsTrans, IsTrans],
        function(t,u)
    local i;
    for i in [1..Maximum(Length(t![1]),Length(u![1]))] do
        if i^t<>i^u then return i^t < i^u; fi;
    od;
    return false; # they're equal
end);

InstallMethod(\<, "trans < perm",
        [IsTrans, IsPerm],
        function(t,p)
    local i;
    for i in [1..Maximum(Length(t![1]),LargestMovedPoint(p))] do
        if i^t<>i^p then return i^t < i^p; fi;
    od;
    return false; # they're equal
end);

InstallMethod(\<, "perm < trans",
        [IsPerm, IsTrans],
        function(p,t)
    local i;
    for i in [1..Maximum(LargestMovedPoint(p),Length(t![1]))] do
        if i^p<>i^t then return i^p < i^t; fi;
    od;
    return false; # they're equal
end);
#############################################################################

InstallOtherMethod(Order, "for a transformation",
        [IsTrans],
        function(t)
    local p, u;
    p := AsPermutation(t);
    if p=fail then
        p := [t]; u := t^2;
        repeat Add(p,u); u := u*t; until u in p;
        return Length(p);
    else return Order(p); fi;
end);

InstallOtherMethod(CycleOp, "for a transformation and a point",
        [IsTrans, IsPosInt, IsFunction],
        function(t,p,f)
    local c;
    c := [];
    repeat
        Add(c,p); p := f(p,t);
    until p in c;
    return c{[Position(c,p)..Length(c)]};
end);

InstallOtherMethod(CyclesOp, "for a transformation and a point",
        [IsTrans, IsCollection, IsFunction],
        function ( g, D, act )
    local blist, orbs, next, pnt, pos, orb;
    IsSSortedList( D );
    blist := BlistList( [ 1 .. Length( D ) ], [  ] );
    orbs := [  ];
    next := 1;
    while next <> fail  do
        pnt := D[next];
        orb := CycleOp( g, D[next], act );
        if not ForAny(orbs,o->orb[1] in o) then Add( orbs, orb ); fi;
        for pnt  in orb  do
            pos := PositionCanonical( D, pnt );
            if pos <> fail  then
                blist[pos] := true;
            fi;
        od;
        next := Position( blist, false, next );
    od;
    return Immutable( orbs );
end);

############################################################################

InstallMethod(FullTransMonoid, "int",
        [IsInt],
        n->FullTransMonoid([1..n]));

InstallMethod(FullTransMonoid, "list",
        [IsList],
        function(l)
    local n, m;
    n := Length(l);
    if n=1 then
        return Monoid(OneTrans);
    elif n=2 then
        m := Monoid(Trans(l,l{[2,1]}),Trans(l,l{[1,1]}),Trans(l{[2,2]}));
    else
        m := Monoid(Trans(l,l{Concatenation([2..n],[1])}),
                    Trans(l{[1,2]},l{[2,1]}),
                    Trans(l{[n]},l{[1]}));
    fi;
    SetSize(m, n^n);
    SetRepresentative(m,GeneratorsOfMonoid(m)[3]);
    SetIsFullTransMonoid(m, true);
    return m;
end);

InstallMethod(\in, "trans",
        [IsObject,IsFullTransMonoid],
        function(x,m)
    return IsTrans(x) and LargestMovedPoint(x) <= LargestMovedPoint(m);
end);

InstallMethod(\=, "for magmas",
        [IsMagma, IsMagma],
        function(x,y)
    local i;
    if not (HasGeneratorsOfMagma(x) or HasGeneratorsOfSemigroup(x) or HasGeneratorsOfMonoid(x) or HasGeneratorsOfGroup(x)) then
        TryNextMethod();
    fi;
    if not (HasGeneratorsOfMagma(y) or HasGeneratorsOfSemigroup(y) or HasGeneratorsOfMonoid(y) or HasGeneratorsOfGroup(y)) then
        TryNextMethod();
    fi;
    for i in GeneratorsOfMagma(x) do
        if not i in y then return false; fi;
    od;
    for i in GeneratorsOfMagma(y) do
        if not i in x then return false; fi;
    od;
    return true;
end);

InstallMethod(IsGeneratorsOfMagmaWithInverses, "(FR) for a list of Trans",
        [IsTransCollection],
        function(l)
    local i;
    for i in l do
        if not IsInvertible(i) then
            return false;
        fi;
    od;
    return true;
end);

#E trans.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
