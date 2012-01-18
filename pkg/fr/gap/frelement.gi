#############################################################################
##
#W frelement.gi                                             Laurent Bartholdi
##
#H   @(#)$Id: frelement.gi,v 1.60 2011/08/13 00:06:36 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  This file implements the category of functionally recursive elements.
##
#############################################################################

#############################################################################
##
#O FRMachine
#O InitialState
##
InstallMethod(UnderlyingFRMachine, "(FR) for an FR element",
        [IsFRElement and IsFRElementStdRep],
        E->E![1]);

InstallMethod(InitialState, "(FR) for an FR element",
        [IsFRElement and IsFRElementStdRep],
        E->E![2]);

InstallMethod(SetUnderlyingMealyElement, "(FR) for two FR elements",
        [IsFRElement and IsFRElementStdRep,IsFRElement],
        function(E,M)
    E![3] := M;
    SetFilterObj(E,HasUnderlyingMealyElement);
end);    

InstallMethod(UnderlyingMealyElement, "(FR) for an FR element",
        [IsFRElement and IsFRElementStdRep],
        function(E)
    E![3] := AsMealyElement(E);
    SetFilterObj(E,HasUnderlyingMealyElement);
    return E![3];
end);

InstallMethod(UnderlyingMealyElement, "(FR) for a Mealy-FR element",
        [IsFRElement and IsFRElementStdRep and HasUnderlyingMealyElement],
        function(E)
    return E![3];
end);

InstallMethod(FREFamily, "(FR) for an alphabet",
        [IsListOrCollection],
        d -> FREFamily(FRMFamily(d)));

InstallMethod(FREFamily, "(FR) for an FR machine family",
        [IsFamily],
        function(fam)
    local i, f;
    for i in FR_FAMILIES do
        if fam in i{[2..Length(i)]} then
            if IsBound(i[3]) then return i[3]; fi;
            f := NewFamily(Concatenation("FRElement(",String(i[1]),")"), IsFRElement and IsAssociativeElement);
            f!.alphabet := i[1];
	    if IsVectorSpace(i[1]) then # so LieObject works
		SetCharacteristic(f,Characteristic(i[1]));
	    fi;
            f!.standard := Size(i[1])<2^28 and i[1]=[1..Size(i[1])];
            if not f!.standard then
                f!.a2n := x->Position(Enumerator(i[1]),x);
                f!.n2a := x->Enumerator(i[1])[x];
            fi;
            Add(i,f);
            return f;
        fi;
    od;
    return fail;
end);

InstallMethod(FRMFamily, "(FR) for an FRE family",
        [IsFamily],
        function(f)
    local i;
    for i in FR_FAMILIES do
        if f in i{[3..Length(i)]} then return i[2]; fi;
    od;
    return fail;
end);

InstallMethod(FRMFamily, "(FR) for an FR machine",
        [IsFRMachine],
        FamilyObj);

InstallMethod(FRMFamily, "(FR) for an FR element",
        [IsFRElement],
        E->FRMFamily(FamilyObj(E)));

InstallMethod(FREFamily, "(FR) for a FR machine",
        [IsFRMachine],
        M->FREFamily(FamilyObj(M)));

InstallMethod(FREFamily, "(FR) for a FR element",
        [IsFRElement],
        FamilyObj);
#############################################################################

#############################################################################
##
#O FRElement(Transitions, Output, Init)
#O FRElement(Names, Transitions, Output, Init)
#O FRElement(Group, Transitions, Output, Init)
#O FRElement(FRMachine, Init)
##
BindGlobal("FRETYPE@", function(f)
    if IsFreeGroup(f) then
        return IsGroupFRElement and IsFRElementStdRep;
    elif HasIsFreeMonoid(f) and IsFreeMonoid(f) then
        return IsMonoidFRElement and IsFRElementStdRep;
    elif HasIsFreeSemigroup(f) and IsFreeSemigroup(f) then
        return IsSemigroupFRElement and IsFRElementStdRep;
    else
        Error("Unknown stateset ",f,"\n");
    fi;
end);

InstallOtherMethod(FRElementNC, "(FR) for a family, a free semigroup, a list of transitions, a list of outputs and an initial state",
        [IsFamily, IsSemigroup, IsList, IsList, IsAssocWord],
        function(fam,free,transitions,output,init)
    return Objectify(NewType(fam, FRETYPE@(free)),
                   [FRMachineNC(FRMFamily(fam),free,transitions,output),Immutable(init)]);
end);

InstallMethod(FRElementNC, "(FR) for a FR machine and an initial word",
        [IsFamily, IsFRMachine and IsFRMachineStdRep, IsAssocWord],
        function(fam,M,init)
    return Objectify(NewType(fam, FRETYPE@(M!.free)),
                   [M,Immutable(init)]);
end);

InstallMethod(FRElement, "(FR) for a list of transitions, a list of outputs and an initial list of states",
        [IsList, IsList, IsList],
        function(transitions,output,init)
    local M;
    M := FRMachine(transitions,output);
    return FRElementNC(FREFamily(M),M,M!.pack(init));
end);

InstallMethod(FRElement, "(FR) for a list of transitions, a list of outputs and an initial state",
        [IsList, IsList, IsInt],
        function(transitions,output,init)
    local M;
    M := FRMachine(transitions,output);
    return FRElementNC(FREFamily(M),M,M!.pack([init]));
end);

InstallMethod(FRElement, "(FR) for a list of names, a list of transitions, a list of outputs and an initial list of states",
        [IsList, IsList, IsList, IsList],
        function(names, transitions,output,init)
    local M;
    M := FRMachine(names, transitions,output);
    return FRElementNC(FREFamily(M),M,M!.pack(init));
end);

InstallMethod(FRElement, "(FR) for a list of names, a list of transitions, a list of outputs and an initial state",
        [IsList, IsList, IsList, IsInt],
        function(names, transitions,output,init)
    local M;
    M := FRMachine(names, transitions,output);
    return FRElementNC(FREFamily(M),M,M!.pack([init]));
end);

InstallMethod(FRElement, "(FR) for a free group/semigroup/monoid, a list of transitions, a list of outputs and an initial word",
        [IsSemigroup, IsList, IsList, IsAssocWord],
        function(free,transitions,output,init)
    local M;
    if not init in free then
        Error(init, " must be an element of ", free,"\n");
    fi;
    M := FRMachine(free,transitions,output);
    return FRElementNC(FREFamily(M),M,init);
end);

InstallMethod(FRElement, "(FR) for a free group/semigroup/monoid, a list of transitions, a list of outputs and an initial word (as list of states)",
        [IsSemigroup, IsList, IsList, IsList],
        function(free,transitions,output,init)
    local M;
    M := FRMachine(free,transitions,output);
    return FRElementNC(FREFamily(M),M,M!.pack(init));
end);

InstallMethod(FRElement, "(FR) for a free group/semigroup/monoid, a list of transitions, a list of outputs and an initial word (as state)",
        [IsSemigroup, IsList, IsList, IsInt],
        function(free,transitions,output,init)
    local M;
    M := FRMachine(free,transitions,output);
    return FRElement(FREFamily(M),M,M!.pack([init]));
end);

InstallMethod(FRElement, "(FR) for a FR element and an initial word",
        [IsFRElement and IsFRElementStdRep, IsAssocWord],
        function(E,init)
    if not init in E![1]!.free then
        init := E![1]!.pack(LetterRepAssocWord(init));
#       Error("FRElement: ",init, " must be an element of ", E![1]!.free,"\n");
    fi;
    return FRElementNC(FamilyObj(E),E![1],init);
end);

InstallMethod(FRElement, "(FR) for a FR machine and an initial word",
        [IsFRMachine and IsFRMachineStdRep, IsAssocWord],
        function(M,init)
    local t;
    if not init in M!.free then
        Error(init, " must be an element of ", M!.free,"\n");
    fi;
    return FRElementNC(FREFamily(M),M,init);
end);

InstallMethod(FRElement, "(FR) for a FR element and an initial list",
        [IsFRElement and IsFRElementStdRep, IsList],
        function(E,init)
    return FRElementNC(FamilyObj(E),E![1],E![1]!.pack(init));
end);

InstallMethod(FRElement, "(FR) for a FR machine and an initial list",
        [IsFRMachine and IsFRMachineStdRep, IsList],
        function(M,init)
    return FRElementNC(FREFamily(M),M,M!.pack(init));
end);

InstallMethod(FRElement, "(FR) for a FR element and an initial letter",
        [IsFRElement and IsFRElementStdRep, IsPosInt],
        function(E,init)
    return FRElementNC(FamilyObj(E),E![1],E![1]!.pack([init]));
end);

InstallMethod(FRElement, "(FR) for a FR machine and an initial letter",
        [IsFRMachine and IsFRMachineStdRep, IsPosInt],
        function(M,init)
    return FRElementNC(FREFamily(M),M,M!.pack([init]));
end);

InstallMethod(VertexElement, "(FR) for a vertex index and an FR element",
        [IsPosInt, IsFRElement],
        function(v,e)
    local m;
    m := List(AlphabetOfFRObject(e),x->[]);
    m[v] := [e];
    return FRElement([m],[()],[1]);
end);

InstallMethod(VertexElement, "(FR) for a vertex and an FR element",
        [IsList, IsFRElement],
        function(v,e)
    local i;
    for i in [Length(v),Length(v)-1..1] do e := VertexElement(v[i],e); od;
    return e;
end);

InstallMethod(DiagonalElement, "(FR) for a power and an FR element",
        [IsInt, IsFRElement and IsFRElementStdRep],
        function(n,e)
    local f;
    f := VertexElement(1,e);
    f![1]!.transitions := ShallowCopy(f![1]!.transitions);
    f![1]!.transitions[1] := List([0..Size(AlphabetOfFRObject(e))-1],i->f![1]!.transitions[1][1]^((-1)^i*Binomial(n,i)));
    MakeImmutable(f![1]!.transitions);
    return f;
end);

InstallMethod(DiagonalElement, "(FR) for a list and an FR element",
        [IsList, IsFRElement],
        function(v,e)
    local i;
    for i in [Length(v),Length(v)-1..1] do e := DiagonalElement(v[i],e); od;
    return e;
end);

InstallOtherMethod(\[\], "(FR) for an FR machine and an index",
        [IsFRMachine, IsPosInt],
        function(M,s)
    return FRElement(M,s);
end);

InstallOtherMethod(\{\}, "(FR) for an FR machine and a list",
        [IsFRMachine, IsList],
        function(M,x)
    return List(x,s->FRElement(M,s));
end);
#############################################################################

#############################################################################
##
#M  ViewObj(FRElement)
#M  String(FRElement)
#M  Display(FRElement)
##
InstallMethod(ViewString, "(FR) for a FR element",
        [IsFRElement and IsFRElementStdRep],
        function(E)
    local s;
    s := "";
    APPEND@(s,"<", Size(AlphabetOfFRObject(E)), "|");
    if HasOne(UnderlyingFRMachine(E)!.free) and IsOne(InitialState(E)) then
        APPEND@(s,"identity ...");
    else
        APPEND@(s,InitialState(E));
    fi;
    if HasUnderlyingMealyElement(E) then
        APPEND@(s,"|",Length(StateSet(UnderlyingMealyElement(E))));
    fi;
    APPEND@(s,">");
    return s;
end);

InstallMethod(String, "(FR) for a FR element",
        [IsFRElement and IsFRElementStdRep],
        function(E)
    return CONCAT@("FRElement(...,",InitialState(E),")");
end);

InstallMethod(DisplayString, "(FR) for a FR element",
        [IsFRElement and IsFRElementStdRep],
        function(E)
    return CONCAT@(DisplayString(UnderlyingFRMachine(E)),"Initial state: ",InitialState(E),"\n");
end);

INSTALLPRINTERS@(IsFRElement);
#############################################################################

#############################################################################
##
#M One(FRElement)
##
BindGlobal("ONE@", function(E)
    local e;
    e := FRElement(E![1],One(E![2]));
    if HasUnderlyingMealyElement(E) then
        SetUnderlyingMealyElement(e,One(UnderlyingMealyElement(E)));
    fi;
    return e;
end);
    
InstallMethod(OneOp, "(FR) for a FR element",
        [IsGroupFRElement],
        ONE@);

InstallMethod(OneOp, "(FR) for a FR element",
        [IsMonoidFRElement],
        ONE@);

InstallMethod(OneOp, "(FR) for a FR element",
        [IsSemigroupFRElement],
        function(E)
    local s, g, e;
    s := FreeSemigroup(1); g := GeneratorsOfSemigroup(s)[1];
    e := FRElementNC(FamilyObj(E),s,[List(AlphabetOfFRObject(E),x->g)],[AlphabetOfFRObject(E)],g);
    if HasUnderlyingMealyElement(E) then
        SetUnderlyingMealyElement(e,One(UnderlyingMealyElement(E)));
    fi;
    return e;
end);
#############################################################################

#############################################################################
##
#M InverseOp(FRElement)
##
BindGlobal("INVOLVEDGENERATORS@", function(E)
    local s, olds;
    s := Set(List(LetterRepAssocWord(E![2]),AbsInt));
    repeat
        olds := s;
        UniteSet(s,Set(List(Flat(List(E![1]!.transitions{s},r->List(r,LetterRepAssocWord))),AbsInt)));
    until olds=s;
    return s;
end);

BindGlobal("REVERSEDWORD@", function(w)
    return AssocWordByLetterRep(FamilyObj(w),Reversed(LetterRepAssocWord(w)));
end);

InstallMethod(InverseOp, "(FR) for a group FR element",
        [IsFRElement and IsFRElementStdRep],
        function(E)
    local s, trans, out, i, rws, e;
    if HasIsGroupFRMachine(E![1]) and IsGroupFRMachine(E![1]) then
        rws := NewFRMachineRWS(E![1]);
        e := FRElement(E![1], rws.letterunrep(rws.reduce(rws.letterrep(E![2]^-1))));
    else
        s := INVOLVEDGENERATORS@(E);
        trans := [];
        out := [];
        for i in [1..Length(E![1]!.transitions)] do
            if i in s then
                if ISINVERTIBLE@(E![1]!.output[i]) then
                    Add(out,INVERSE@(E![1]!.output[i]));
                else
                    return fail;
                fi;
                Add(trans,List(E![1]!.transitions[i]{out[Length(out)]},REVERSEDWORD@));
            else
                Add(trans,E![1]!.transitions[i]);
                Add(out,E![1]!.output[i]);
            fi;
        od;
        e := FRElementNC(FamilyObj(E),E![1]!.free,trans,out,REVERSEDWORD@(E![2]));
    fi;
    if HasUnderlyingMealyElement(E) then
        SetUnderlyingMealyElement(e,InverseOp(UnderlyingMealyElement(E)));
    fi;
    return e;
end);

InstallMethod(IsInvertible, "(FR) for an FR element",
        [IsFRElement and IsFRElementStdRep],
        function(E)
    return (HasIsGroupFRMachine(E![1]) and IsGroupFRMachine(E![1])) or
           ForAll(INVOLVEDGENERATORS@(E),s->ISINVERTIBLE@(E![1]!.output[s]));
end);
#############################################################################

#############################################################################
##
#M \*(FRElement, FRElement)
##
InstallMethod(\*, "(FR) for two FR elements",
        IsIdenticalObj,
        [IsFRElement and IsFRElementStdRep, IsFRElement and IsFRElementStdRep],
        function(left, right)
    local M, N, rws, e;
    if IsIdenticalObj(left![1],right![1]) then
        rws := NewFRMachineRWS(left![1]);
        e := FRElement(left![1], rws.letterunrep(rws.reduce(rws.letterrep(left![2]*right![2]))));
    else    
        N := SubFRMachine(left![1],right![1]);
        if N <> fail then
            return FRElement(left![1],left![2]*right![2]^N);
        fi;
        N := SubFRMachine(right![1],left![1]);
        if N <> fail then
            return FRElement(right![1],left![2]^N*right![2]);
        fi;
        M := left![1] * right![1];
        e := FRElement(M,left![2]^Correspondence(M)[1]*right![2]^Correspondence(M)[2]);
    fi;
    if HasUnderlyingMealyElement(left) and HasUnderlyingMealyElement(right) then
        SetUnderlyingMealyElement(e,UnderlyingMealyElement(left)*UnderlyingMealyElement(right));
    fi;
    return e;
end);
#############################################################################

############################################################################
##
#O \^(Integer, FRElement)
#O \^(Sequence, FRElement)
#O FRElement[Integer]
#O FRElement{Sequence}
##
InstallOtherMethod(\^, "(FR) for an integer and an FR element",
        [IsPosInt, IsFRElement and IsFRElementStdRep],
        function(x,E)
    return Output(E![1],E![2],x);
end);

InstallOtherMethod(\^, "(FR) for a vertex and an FR element",
        [IsList, IsFRElement],
        function(l,E)
    local t, i, s, M;
    t := [];
    M := UnderlyingFRMachine(E);
    s := InitialState(E);
    for i in l do
        Add(t,Output(M,s,i));
        s := Transition(M,s,i);
    od;
    return t;
end);

InstallOtherMethod(\^, "(FR) for a periodic vertex and an FR element",
        [IsPeriodicList, IsFRElement],
        function(l,E)
    local t, i, s, states, M;
    t := [];
    M := UnderlyingFRMachine(E);
    s := InitialState(E);
    for i in l![1] do
        Add(t,Output(M,s,i));
        s := Transition(M,s,i);
    od;
    if l![2]<>[] then
        states := NewDictionary(s,true);
        while not KnowsDictionary(states,s) do
            AddDictionary(states,s,Length(t));
            for i in l![2] do
                Add(t,Output(M,s,i));
                s := Transition(M,s,i);
            od;
        od;
        t := CompressedPeriodicList(t,LookupDictionary(states,s)+1);
    fi;
    return t;
end);

InstallOtherMethod(State, "(FR) for an FR element and an integer",
        [IsFRElement and IsFRElementStdRep, IsInt],
        function(E,x)
    local e;
    e := FRElement(E![1], Transition(E![1],E![2],x));
    if HasUnderlyingMealyElement(E) then
        SetUnderlyingMealyElement(e,State(UnderlyingMealyElement(E),x));
    fi;
    return e;
end);

InstallOtherMethod(State, "(FR) for an FR element and a list",
        [IsFRElement and IsFRElementStdRep, IsList],
        function(E,x)
    local pi, i, v, e;
    pi := WreathRecursion(E![1]);
    v := E![2];
    for i in [1..Length(x)] do
        v := pi(v)[1][x[i]];
    od;
    e := FRElement(E![1], v);
    if HasUnderlyingMealyElement(E) then
        SetUnderlyingMealyElement(e,State(UnderlyingMealyElement(E),x));
    fi;
    return e;    
end);
#############################################################################

############################################################################
##
#O Output(FRElement)
#O Activity(FRElement, Level)
#O Portrait
##
InstallMethod(Output, "(FR) for an FR element",
        [IsFRElement and IsFRElementStdRep],
        E->Output(E![1],E![2]));

InstallMethod(Output, "(FR) for an FR element",
        [IsFRElement and IsFRElementStdRep, IsObject, IsObject],
        function(E,s,a)
    return Output(E![1],s,a);
end);

InstallMethod(Transition, "(FR) for an FR element and a [list of] letters",
        [IsFRElement and IsFRElementStdRep, IsObject],
        function(E,i)
    return Transition(E![1],E![2],i);
end);

InstallMethod(Transition, "(FR) for an FR element and a list",
        [IsFRElement, IsList],
        function(E,l)
    local i, s, M;
    s := InitialState(E);
    M := UnderlyingFRMachine(E);
    for i in l do
        s := Transition(M,s,i);
    od;
    return s;
end);

InstallMethod(Transitions, "(FR) for an FR element",
        [IsFRElement and IsFRElementStdRep],
        E->Transitions(E![1],E![2]));

InstallMethod(Transitions, "(FR) for an FR element and a state",
        [IsFRElement and IsFRElementStdRep, IsAssocWord],
        function(E,w)
    return Transitions(E![1],w);
end);

InstallMethod(Transitions, "(FR) for an FR element and a state",
        [IsFRElement and IsFRElementStdRep, IsList],
        function(E,s)
    return Transitions(E![1],s);
end);

BindGlobal("MAKEPERMS@", function(M,l)
    local d, i, j, k, s, p, q, perms, oldperms, S, SR;
    d := Size(AlphabetOfFRObject(M));
    S := GeneratorsOfFRMachine(M);
    SR := List(S,WreathRecursion(M));
    perms := List(S,s->[1]);
    for i in [1..l] do
        oldperms := perms;
        perms := [];
        for s in SR do
            p := [];
            for j in [1..d] do
                q := [1..d^(i-1)];
                for k in LetterRepAssocWord(s[1][j]) do
                    if k>0 then
                        q := oldperms[k]{q};
                    else
                        q := INVERSE@(oldperms[-k]){q};
                    fi;
                od;
                Append(p,q+d^(i-1)*(s[2][j]-1));
            od;
            Add(perms,p);
        od;
    od;
    return perms;
end);

InstallMethod(Activity, "(FR) for an FR element",
        [IsFRElement],
        E->Trans(Output(E)));

InstallMethod(ActivityTransformation, "(FR) for an FR element",
        [IsFRElement],
        E->Transformation(Output(E)));

InstallMethod(ActivityPerm, "(FR) for an FR element",
        [IsFRElement],
        E->PermList(Output(E)));

InstallMethod(ActivityInt, "(FR) for an FR element",
        [IsFRElement],
        function(E)
    local p, delta;
    p := Output(E);
    delta := p[1]-1;
    if p=Concatenation([1+delta..Size(AlphabetOfFRObject(E))],[1..delta]) then
        return delta;
    else
        return fail;
    fi;
end);

InstallMethod(Activity, "(FR) for a group FR element and a level",
        [IsGroupFRElement and IsFRElementStdRep, IsInt],
        function(E,l)
    return MAPPEDWORD@(E![2],List(MAKEPERMS@(E![1],l),PermList),());
end);

InstallMethod(Activity, "(FR) for an FR element and a level",
        [IsFRElement and IsFRElementStdRep, IsInt],
        function(E,l)
    return MAPPEDWORD@(E![2],List(MAKEPERMS@(E![1],l),Trans),());
end);

InstallMethod(ActivityTransformation, "(FR) for an FR element and a level",
        [IsFRElement and IsFRElementStdRep, IsInt],
        function(E,l)
    return MAPPEDWORD@(E![2],List(MAKEPERMS@(E![1],l),Transformation),Transformation([1..Length(AlphabetOfFRObject(E))^l]));
end);

InstallMethod(ActivityPerm, "(FR) for an FR element and a level",
        [IsFRElement and IsFRElementStdRep, IsInt],
        function(E,l)
    return MAPPEDWORD@(E![2],List(MAKEPERMS@(E![1],l),PermList),());
end);

BindGlobal("INT2SEQ@", function(x,l,n)
    local s, i;
    s := [];
    x := x-1;
    for i in [1..l] do
        Add(s,1+RemInt(x,n));
        x := QuoInt(x,n);
    od;
    return s;
end);

BindGlobal("SEQ2INT@", function(s,l,n)
    return 1+Sum([1..l],i->(s[i]-1)*n^(i-1));
end);

InstallMethod(ActivityInt, "(FR) for an FR machine and a state",
        [IsFRElement, IsInt],
        function(E,l)
    local p, n, i, delta, x;
    n := Size(AlphabetOfFRObject(E));
    p := ListPerm(Activity(E,l),n^l);
    if p=fail then return fail; fi;
    x := List([1..n^l],i->SEQ2INT@(Reversed(INT2SEQ@(i,l,n)),l,n));
    delta := Position(x,p[1])-1;
    if p{x}=Concatenation(x{[1+delta..n^l]},x{[1..delta]}) then
        return delta;
    else
        return fail;
    fi;
end);

PORTRAIT@ := fail; # shut up warning
PORTRAIT@ := function(g,n,act)
    if n=0 then
        return act(g,1);
    else
        return List(AlphabetOfFRObject(g),a->PORTRAIT@(State(g,a),n-1,act));
    fi;
end;
MAKE_READ_ONLY_GLOBAL("PORTRAIT@");

InstallMethod(Portrait, "(FR) for an FR element an a maximal level",
        [IsFRElement, IsInt],
        function(E,l)
    return List([0..l],i->PORTRAIT@(E,i,Activity));
end);

InstallMethod(PortraitPerm, "(FR) for an FR element an a maximal level",
        [IsFRElement, IsInt],
        function(E,l)
    return List([0..l],i->PORTRAIT@(E,i,ActivityPerm));
end);

InstallMethod(PortraitInt, "(FR) for an FR element an a maximal level",
        [IsFRElement, IsInt],
        function(E,l)
    return List([0..l],i->PORTRAIT@(E,i,ActivityInt));
end);

InstallMethod(DecompositionOfFRElement, "(FR) for an FR element",
        [IsFRElement and IsFRElementStdRep],
        function(E)
    local d, e, i;
    d := WreathRecursion(E![1])(E![2]);
    e := List(d[1],x->FRElement(E![1],x));
    if HasUnderlyingMealyElement(E) then
        for i in [1..Length(e)] do
            SetUnderlyingMealyElement(e[i],State(UnderlyingMealyElement(E),i));
        od;
    fi;
    return [e,d[2]];
end);

InstallMethod(DecompositionOfFRElement, "(FR) for an FR element and a level",
        [IsFRElement, IsPosInt],
        function(E,n)
    local d, s, t, i, l, m;
    E := DecompositionOfFRElement(E);
    if n=1 then return E; fi;
    d := Length(E[1]);
    l := [];
    for s in [1..d] do
        Append(l,ListWithIdenticalEntries(d^(n-1),d^(n-1)*(E[2][s]-1)));
    od;
    s := []; m := [];
    for E in E[1] do
        t := DecompositionOfFRElement(E,n-1);
        Append(s,t[1]);
        Append(m,t[2]);
    od;
    return [s,l+m];
end);
#############################################################################

#############################################################################
##
#M \=(FRElement, FRElement)
##
BindGlobal("GROUPISONE@", function(m,w)
    local rws, todo, d, t, u;

    rws := NewFRMachineRWS(m);
    todo := NewFIFO([rws.letterrep(w)]);
    for t in todo do
        u := rws.reduce(rws.cyclicallyreduce(t));
        if u<>[] then
            d := rws.pi(u);
            if not ISONE@(d[2]) then return false; fi;
            rws.addgprule(u,true);
            Append(todo,d[1]);
        fi;
    od;
    rws.commit();
    return true;
end);

BindGlobal("MONOIDCOMPARE@", function(m,v,w)
    # returns 0 if v=w in machine m,
    # returns -1 if v<w, and returns 1 if v>w
    local rws, todo, d, t;

    rws := NewFRMachineRWS(m);
    todo := NewFIFO([[rws.letterrep(v),rws.letterrep(w)]]);
    
    for t in todo do
        t := List(t,rws.reduce);
        if t[1]<>t[2] then
            d := List(t,rws.pi);
            if d[1][2]<>d[2][2] then
                if d[1][2]<d[2][2] then return -1; else return 1; fi;
            fi;
            rws.addsgrule(t[1],t[2],false);
            Append(todo,TransposedMat(List(d,x->x[1])));
        fi;
    od;
    rws.commit(); # add these rules, since we now know we have equality
    return 0;
end);

InstallMethod(\=, "(FR) for two group FR-Mealy elements",
        IsIdenticalObj,
        [IsFRMealyElement and IsFRElementStdRep, IsFRMealyElement and IsFRElementStdRep], 2, # better than other methods
        function(left, right)
    return UnderlyingMealyElement(left)=UnderlyingMealyElement(right);
end);

InstallMethod(\=, "(FR) for two group FR elements",
        IsIdenticalObj,
        [IsGroupFRElement and IsFRElementStdRep, IsGroupFRElement and IsFRElementStdRep],
        function(left, right)
    local m;
    
    if IsIdenticalObj(left![1], right![1]) then
        if left![2]=right![2] then
            return true;
        else
            return GROUPISONE@(left![1],left![2]/right![2]);
        fi;
    fi;
    m := FRMMINSUM@(left![1],right![1]);
    left := left![2]^Correspondence(m)[1]/right![2]^Correspondence(m)[2];
    return GROUPISONE@(m,left);
end);

InstallMethod(\=, "(FR) for two FR elements",
        IsIdenticalObj,
        [IsFRElement and IsFRElementStdRep, IsFRElement and IsFRElementStdRep],
        function(left, right)
    local m;
    
    if IsIdenticalObj(left![1], right![1]) then
        if left![2]=right![2] then
            return true;
        else
            return MONOIDCOMPARE@(left![1],left![2],right![2])=0;
        fi;
    fi;
    m := FRMMINSUM@(left![1],right![1]);
    return MONOIDCOMPARE@(m,left![2]^Correspondence(m)[1],right![2]^Correspondence(m)[2])=0;
end);

InstallMethod(IsOne, "(FR) for a group FR element",
        [IsFRMealyElement and IsFRElementStdRep], 1, # better than next
        function(E)
    return IsOne(UnderlyingMealyElement(E));
end);

InstallMethod(IsOne, "(FR) for a group FR element",
        [IsGroupFRElement and IsFRElementStdRep],
        function(E)
    if IsOne(E![2]) then
        return true;
    fi;
    return GROUPISONE@(E![1],E![2]);
end);

InstallMethod(IsOne, "(FR) for a FR element",
        [IsFRElement and IsFRElementStdRep],
        function(E)
    if HasOne(E![1]!.free) and IsOne(E![2]) then
        return true;
    else
        return MONOIDCOMPARE@(E![1],E![2],
                       AssocWordByLetterRep(FamilyObj(E![2]),[]))=0;
    fi;
end);

InstallMethod(Minimized, "(FR) for an FR element",
        [IsFRElement and IsFRElementStdRep],
        function(E)
    local M;
    M := Minimized(E![1]);
    return FRElement(M,E![2]^Correspondence(M));
end);
#############################################################################

#############################################################################
##
#M \<(FRElement, FRElement)
##
InstallMethod(\<, "(FR) for two FR elements",
        IsIdenticalObj,
        [IsFRMealyElement and IsFRElementStdRep, IsFRMealyElement and IsFRElementStdRep],
        function(left, right)
    return UnderlyingMealyElement(left)<UnderlyingMealyElement(right);
end);

InstallMethod(\<, "(FR) for two FR elements",
        IsIdenticalObj,
        [IsFRElement and IsFRElementStdRep, IsFRElement and IsFRElementStdRep],
        function(left, right)
    local m;
    if IsIdenticalObj(left![1],right![1]) then
        return MONOIDCOMPARE@(left![1],left![2],right![2])<0;
    else
        m := FRMMINSUM@(left![1],right![1]);
        return MONOIDCOMPARE@(m,left![2]^Correspondence(m)[1],right![2]^Correspondence(m)[2])<0;
    fi;
end);
#############################################################################

#############################################################################
##
#M AsGroupFRElement
#M AsMonoidFRElement
#M AsSemigroupFRElement
##
InstallMethod(AsGroupFRElement, "(FR) for a group FR element",
        [IsGroupFRElement],
        E->FRElement(E![1],E![2]));

InstallMethod(AsGroupFRElement, "(FR) for a monoid FR element",
        [IsMonoidFRElement],
        function(E)
    local M;
    M := AsGroupFRMachine(E![1]);
    if M=fail then
        return fail;
    else
        return FRElement(M,E![2]^Correspondence(M));
    fi;
end);

InstallMethod(AsGroupFRElement, "(FR) for a semigroup FR element",
        [IsSemigroupFRElement],
        function(E)
    local M;
    M := AsGroupFRMachine(E![1]);
    if M=fail then
        return fail;
    else
        return FRElement(M,E![2]^Correspondence(M));
    fi;
end);

InstallMethod(AsMonoidFRElement, "(FR) for a group FR element",
        [IsGroupFRElement],
        function(E)
    local M;
    M := AsMonoidFRMachine(E![1]);
    return FRElement(M,E![2]^Correspondence(M));
end);

InstallMethod(AsMonoidFRElement, "(FR) for a monoid FR element",
        [IsMonoidFRElement],
        E->FRElement(E![1],E![2]));

InstallMethod(AsMonoidFRElement, "(FR) for a semigroup FR element",
        [IsSemigroupFRElement],
        function(E)
    local M;
    M := AsMonoidFRMachine(E![1]);
    return FRElement(M,E![2]^Correspondence(M));
end);

InstallMethod(AsSemigroupFRElement, "(FR) for a group FR element",
        [IsGroupFRElement],
        function(E)
    local M;
    M := AsSemigroupFRMachine(E![1]);
    return FRElement(M,E![2]^Correspondence(M));
end);

InstallMethod(AsSemigroupFRElement, "(FR) for a monoid FR element",
        [IsMonoidFRElement],
        function(E)
    local M;
    M := AsSemigroupFRMachine(E![1]);
    return FRElement(M,E![2]^Correspondence(M));
end);

InstallMethod(AsSemigroupFRElement, "(FR) for a semigroup FR element",
        [IsSemigroupFRElement],
        E->FRElement(E![1],E![2]));
############################################################################

############################################################################
##
#O States(FRElement)
##
InstallMethod(StateSet, "(FR) for an FR element",
        [IsFRElement and IsFRElementStdRep],
        E->StateSet(E![1]));

InstallMethod(States, "(FR) for an FR element",
        [IsFRElement],
        E->States([E]));

InstallOtherMethod(States, "(FR) for an empty list",
        [IsListOrCollection and IsEmpty],
        E->E);

InstallMethod(States, "(FR) for a list of FR elements",
        [IsFRElementCollection],
        function(L)
    local states, i, x, stateset;
    states := ShallowCopy(L);
    stateset := Set(states);
    i := 1;
    while i <= Length(states) do
        for x in DecompositionOfFRElement(states[i])[1] do
            if not x in stateset then
                Add(states,x);
                AddSet(stateset,x);
            fi;
        od;
        i := i+1;
        if RemInt(i,100)=0 then
            Info(InfoFR, 2, "The states contain at least ", states);
        fi;
    od;
    return states;
end);

BindGlobal("FRFIXEDSTATES@", function(L)
    local states, i, x, addstates, stateset;
    states := [];
    stateset := [];
    addstates := function(d)
        local i;
        for i in AlphabetOfFRObject(L[1]) do
            if d[2][i]=i and not d[1][i] in stateset then
                Add(states,d[1][i]);
                AddSet(stateset,d[1][i]);
            fi;
        od;
    end;
    for x in L do addstates(DecompositionOfFRElement(x)); od;
    i := 1;
    while i <= Length(states) do
        addstates(DecompositionOfFRElement(states[i]));
        i := i+1;
        if RemInt(i,100)=0 then
            Info(InfoFR, 2, "The fixed states contain at least ", states);
        fi;
    od;
    return states;
end);

InstallMethod(FixedStates, "(FR) for an FR element",
        [IsFRElement],
        E->FRFIXEDSTATES@([E]));

InstallMethod(FixedStates, "(FR) for a list of FR elements",
        [IsFRElementCollection],
        FRFIXEDSTATES@);

InstallMethod(IsFiniteStateFRMachine, "(FR) for an FR machine",
        [IsFRMachine],
        M->ForAll(GeneratorsOfFRMachine(M),x->IsFiniteStateFRElement(FRElement(M,x))));

InstallMethod(IsFiniteStateFRElement, "(FR) for an FR element",
        [IsFRElement],
        e->CategoryCollections(IsFRElement)(States(e)));

BindGlobal("FRLIMITSTATES@", function(L)
    local s, d, S, oldS;
    s := Set(States(L));
    d := List(s,w->BlistList([1..Length(s)],List(DecompositionOfFRElement(w)[1],x->Position(s,x))));
    S := BlistList([1..Length(s)],[1..Length(s)]);
    repeat
        oldS := S;
        S := UnionBlist(ListBlist(d,S));
    until oldS=S;
    return ListBlist(s,S);
end);

InstallMethod(LimitStates, "(FR) for an FR element",
        [IsFRElement],
        E->FRLIMITSTATES@([E]));

InstallMethod(LimitStates, "(FR) for a list of FR elements",
        [IsFRElementCollection],
        FRLIMITSTATES@);

BindGlobal("MAYBE_ORDER@", function(e,limit)
    # does the element e have provable infinite order, within raising to power
    # 'limit'?
    local testing, found, recur;
    testing := NewDictionary(e,true); # current order during recursion
    found := NewDictionary(e,true); # elements for which we found the order
    AddDictionary(testing,One(e),infinity);
    AddDictionary(found,One(e),1);
    recur := function(g,mult)
        local d, o, p, h, ho, i, j, c, m;
        if KnowsDictionary(testing,g) then
            if KnowsDictionary(found,g) then
                return LookupDictionary(found,g);
            elif mult>LookupDictionary(testing,g) then
                return infinity;
            else
                return 1;
            fi;
        fi;
        d := DecompositionOfFRElement(g);
        p := PermList(d[2]); # returns fail if d[2] not invertible
        if p=fail or mult*Order(p)>limit then return fail; fi;
        AddDictionary(testing,g,mult);
        o := 1;
        for i in AlphabetOfFRObject(g) do
            c := Cycle(p,i);
            h := d[1][c[1]];
            for j in c{[2..Length(c)]} do h := h*d[1][j]; od;
            if i in c then m := Size(c)*mult; else m := Size(c)*mult+1; fi;
            ho := recur(h,m);
            if ho=infinity or ho=fail then
                return ho;
            else
                o := LcmInt(o,Size(c)*ho);
            fi;
        od;
        AddDictionary(found,g,o);
        return o;
    end;
    return recur(e,1);
end);

BindGlobal("NUCLEUS@", function(L)
    local s, news, olds, gens, i, j, maybeinf;

    gens := Set(L);
    news := gens;
    s := [];
    maybeinf := []; # the part of s that may be of
                    # infinite order and self-recurrent
    while true do
        olds := ShallowCopy(s);
        UniteSet(s,LimitStates(news));
        if Length(s)=Length(olds) then
            return s;
        fi;

        i := 1; while i <= Size(maybeinf) do
            j := MAYBE_ORDER@(maybeinf[i],Size(s));
            if j=infinity then
                return fail;
            elif j=fail then
                i := i+1;
            else
                Remove(maybeinf,i);
            fi;
        od;

        news := [];
        for i in Difference(s,olds) do
            if i in FixedStates(i) then
                Add(maybeinf,i);
            fi;
            for j in gens do AddSet(news,i*j); od;
        od;
        Info(InfoFR, 2, "Nucleus: The nucleus contains at least ",s);
    od;
end);

InstallMethod(NucleusOfFRMachine, "(FR) for an FR machine",
        [IsFRMachine],
        M->NUCLEUS@(List(GeneratorsOfFRMachine(M),x->FRElement(M,x))));
#############################################################################

#############################################################################
##
#M Order(FRElement)
##
## is proved to terminate for bounded elements, by Said Sidki (personal
## communication); otherwise could run forever
##
BindGlobal("ORDER@", function(e)
    local testing, found, recur;
    
    if HasUnderlyingMealyElement(e) then
        e := UnderlyingMealyElement(e);
    fi;
    
    if IsAbelian(VertexTransformationsFRElement(e)) then
        found := NewDictionary(e,false);
        recur := function(e)
            local d, i;
            if KnowsDictionary(found,e) then
                return false;
            elif IsLevelTransitive(e) then
                return true;
            else
                AddDictionary(found,e);
                d := DecompositionOfFRElement(e);
                for i in AlphabetOfFRObject(e) do
                    if d[2][i]=i and recur(d[1][i]) then return true; fi;
                od;
            fi;
            return false;
        end;
        if recur(e) then
            return infinity;
        fi;
    fi;
    
    testing := NewDictionary(e,true); # current order during recursion
    found := NewDictionary(e,true); # elements for which we found the order
    AddDictionary(testing,One(e),infinity);
    AddDictionary(found,One(e),1);
    recur := function(g,mult)
        local d, o, h, ho, i, j;
        if IsGroupFRElement(g) then
            g := FRElement(g,CyclicallyReducedWord(InitialState(g)));
        fi;
        if KnowsDictionary(testing,g) then
            if KnowsDictionary(found,g) then
                return LookupDictionary(found,g);
            elif mult>LookupDictionary(testing,g) then
                return infinity;
            else
                return 1;
            fi;
        else
            AddDictionary(testing,g,mult);
            d := DecompositionOfFRElement(g);
            o := 1;
            for i in Cycles(PermList(d[2]),AlphabetOfFRObject(g)) do
                h := One(g);
                for j in i do h := h*d[1][j]; od;
                ho := recur(h,Length(i)*mult);
                if ho=infinity then
                    return infinity;
                else
                    o := LcmInt(o,Length(i)*ho);
                fi;
            od;
            AddDictionary(found,g,o);
            return o;
        fi;
    end;
    return recur(e,1);
end);

InstallMethod(Order, "(FR) for an FR element; not guaranteed to terminate",
        [IsFRElement and IsFRElementStdRep], ORDER@);
        
InstallMethod(Order, "(FR) for a Mealy element; not guaranteed to terminate",
        [IsMealyElement], ORDER@);
        
InstallMethod(IsLevelTransitive, "(FR) for a group FR element",
        [IsGroupFRMealyElement],
        E->IsLevelTransitive(UnderlyingMealyElement(E)));

InstallMethod(IsLevelTransitive, "(FR) for a group FR element",
        [IsGroupFRElement],
        function(E)
    local seen, d, c, w, x;

    x := CyclicallyReducedWord(E![2]);
    seen := NewDictionary(x,false);
    w := WreathRecursion(E![1]);

    while not KnowsDictionary(seen,x) do
        AddDictionary(seen,x);
        d := w(x);
        c := Cycle(d[2],AlphabetOfFRObject(E),Representative(AlphabetOfFRObject(E)));
        if Set(c)<>AlphabetOfFRObject(E) then
            return false;
        fi;
        x := CyclicallyReducedWord(Product(d[1]{c}));
    od;
    return true;
end);
#############################################################################

#E frelement.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
