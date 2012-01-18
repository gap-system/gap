#############################################################################
##
#W mealy.gi                                                 Laurent Bartholdi
##
#H   @(#)$Id: mealy.gi,v 1.73 2011/06/29 13:38:35 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  This file implements the category of Mealy machines and elements.
##
#############################################################################

#############################################################################
##
#O InitialState(<MealyMachine>)
##
InstallMethod(InitialState, "(FR) for a Mealy machine",
        [IsMealyElement],
        M->M!.initial);
############################################################################

############################################################################
##
#O Output(<MealyMachine>, <State>)
#O Transition(<MealyMachine>, <State>, <Input>)
#O Activity(<MealyElement>[, <Level>])
#O WreathRecursion(<MealyElement>)
##
BindGlobal("DOMALPHABET@", function(M)
    local a;
    a := AlphabetOfFRObject(M);
    if IsDomain(a) then return a; else return Domain(a); fi;
end);

InstallMethod(Output, "(FR) for a Mealy machine and a state",
        [IsMealyMachine and IsMealyMachineIntRep, IsInt],
        function(M, s)
    return M!.output[s];
end);

InstallMethod(Output, "(FR) for a Mealy machine, a state and a letter",
        [IsMealyMachine and IsMealyMachineIntRep, IsInt, IsInt],
        function(M, s, a)
    return M!.output[s][a];
end);

InstallMethod(Output, "(FR) for a Mealy machine and a state",
        [IsMealyMachine and IsMealyMachineDomainRep, IsObject], 20,
        function(M, s)
    return MappingByFunction(DOMALPHABET@(M), DOMALPHABET@(M),
                   a->M!.output(s,a));
end);

InstallMethod(Output, "(FR) for a Mealy machine, a state and a letter",
        [IsMealyMachine and IsMealyMachineDomainRep, IsObject, IsObject],
        function(M, s, a)
    return M!.output(s,a);
end);

InstallMethod(Output, "(FR) for a Mealy element",
        [IsMealyElement and IsMealyMachineIntRep],
        E->E!.output[E!.initial]);

InstallMethod(Output, "(FR) for a Mealy element, state, and input",
        [IsMealyElement and IsMealyMachineIntRep, IsInt, IsInt],
        function(M, s, i)
    return M!.output[s][i];
end);

InstallMethod(Output, "(FR) for a Mealy element",
        [IsMealyElement and IsMealyMachineDomainRep],
        function(E)
    return MappingByFunction(DOMALPHABET@(E), DOMALPHABET@(E),
                   a->E!.output(E!.initial,a));
end);

InstallMethod(Transition, "(FR) for a Mealy machine, state, and input",
        [IsMealyMachine and IsMealyMachineIntRep, IsInt, IsInt],
        function(M, s, i)
    return M!.transitions[s][i];
end);

InstallMethod(Transition, "(FR) for a Mealy machine, state, and input",
        [IsMealyMachine and IsMealyMachineDomainRep, IsObject, IsObject], 40,
        function(M, s, i)
    return M!.transitions(s,i);
end);

InstallMethod(Transition, "(FR) for a Mealy element, state, and input",
        [IsMealyElement and IsMealyMachineIntRep, IsInt, IsInt],
        function(M, s, i)
    return M!.transitions[s][i];
end);

InstallMethod(Transition, "(FR) for a Mealy element, state, and input",
        [IsMealyElement and IsMealyMachineDomainRep, IsObject, IsObject], 40,
        function(M, s, i)
    return M!.transitions(s,i);
end);

InstallMethod(Transition, "(FR) for a Mealy element and input",
        [IsMealyElement and IsMealyMachineIntRep, IsInt],
        function(M, i)
    return M!.transitions[M!.initial][i];
end);

InstallMethod(Transition, "(FR) for a Mealy element and input",
        [IsMealyElement and IsMealyMachineDomainRep, IsObject], 20,
        function(M, i)
    return M!.transitions(M!.initial,i);
end);

InstallMethod(Transitions, "(FR) for a Mealy machine and state",
        [IsMealyMachine and IsMealyMachineIntRep, IsInt],
        function(M, s)
    return M!.transitions[s];
end);

InstallMethod(Transitions, "(FR) for a Mealy machine and state",
        [IsMealyMachine and IsMealyMachineDomainRep, IsObject], 40,
        function(M, s)
    return i->M!.transitions(s,i);
end);

InstallMethod(Transitions, "(FR) for a Mealy element and state",
        [IsMealyElement and IsMealyMachineIntRep, IsInt],
        function(M, s)
    return M!.transitions[s];
end);

InstallMethod(Transitions, "(FR) for a Mealy element and state",
        [IsMealyElement and IsMealyMachineDomainRep, IsObject], 40,
        function(M, s)
    return i->M!.transitions(s,i);
end);

InstallMethod(Transitions, "(FR) for a Mealy element",
        [IsMealyElement and IsMealyMachineIntRep],
        function(M)
    return M!.transitions[M!.initial];
end);

InstallMethod(Transitions, "(FR) for a Mealy element",
        [IsMealyElement and IsMealyMachineDomainRep], 20,
        function(M)
    return i->M!.transitions(M!.initial,i);
end);

BindGlobal("MMACTIVITY@", function(E,l)
    local d, i, r, s;
    d := Size(AlphabetOfFRObject(E));
    r := List([1..E!.nrstates], i->[1]);
    for i in [1..l] do
        r := List([1..E!.nrstates], s->Concatenation(List(AlphabetOfFRObject(E),
                     x->r[E!.transitions[s][x]]+d^(i-1)*(E!.output[s][x]-1))));
    od;
    return r;
end);

InstallMethod(Activity, "(FR) for a Mealy element and a level",
        [IsMealyElement, IsInt],
        function(E,l)
    return Trans(MMACTIVITY@(E,l)[E!.initial]);
end);

InstallMethod(ActivityTransformation, "(FR) for a Mealy element and a level",
        [IsMealyElement, IsInt],
        function(E,l)
    return Transformation(MMACTIVITY@(E,l)[E!.initial]);
end);

InstallMethod(ActivityPerm, "(FR) for a Mealy element and a level",
        [IsMealyElement, IsInt],
        function(E,l)
    return PermList(MMACTIVITY@(E,l)[E!.initial]);
end);

InstallMethod(\^, "(FR) for an integer and a Mealy element",
        [IsPosInt, IsMealyElement and IsMealyMachineIntRep],
        function(p,E)
    return E!.output[E!.initial][p];
end);

InstallOtherMethod(\^, "(FR) for an integer and a Mealy element",
        [IsObject, IsMealyElement and IsMealyMachineDomainRep],
        function(p,E)
    return E!.output(E!.initial,p);
end);

InstallMethod(DecompositionOfFRElement, "(FR) for a Mealy element",
        [IsMealyElement],
        function(E)
    return [List(AlphabetOfFRObject(E),a->FRElement(E,E!.transitions[E!.initial][a])),Output(E)];
end);

InstallMethod(WreathRecursion, "(FR) for a Mealy machine",
        [IsMealyMachine],
        M->(i->[M!.transitions[i],M!.output[i]]));
############################################################################

############################################################################
##
#O States(MealyMachine[, Initial])
#O States(MealyElement)
##

InstallMethod(StateSet, "(FR) for a Mealy machine",
        [IsMealyMachine and IsMealyMachineIntRep],
        M->[1..M!.nrstates]);

InstallMethod(StateSet, "(FR) for a Mealy machine",
        [IsMealyMachine and IsMealyMachineDomainRep],
        M->M!.states);

InstallMethod(StateSet, "(FR) for a Mealy element",
        [IsMealyElement and IsMealyMachineIntRep],
        E->[1..E!.nrstates]);

InstallMethod(StateSet, "(FR) for a Mealy element",
        [IsMealyElement and IsMealyMachineDomainRep],
        function(E)
    local r, oldr, i;
    oldr := [];
    r := [E!.initial];
    repeat
        i := Difference(r,oldr);
        oldr := r;
        for i in i do
            r := Union(r,List(AlphabetOfFRObject(E),a->E!.transitions(i,a)));
        od;
    until oldr = r;
    return r;
end);

InstallMethod(GeneratorsOfFRMachine, "(FR) for a Mealy machine",
        [IsMealyMachine], StateSet);

BindGlobal("MEALYLIMITSTATES@", function(M)
    local R, oldR, i, a;
    R := BlistList([1..M!.nrstates],[1..M!.nrstates]);
    repeat
        oldR := R;
        R := BlistList([1..M!.nrstates],[]);
        for i in [1..M!.nrstates] do if oldR[i] then
            for a in AlphabetOfFRObject(M) do R[M!.transitions[i][a]] := true; od;
        fi; od;
    until oldR=R;
    return ListBlist([1..M!.nrstates],R);
end);

InstallMethod(LimitStates, "(FR) for a Mealy machine",
        [IsMealyMachine and IsMealyMachineIntRep],
        M->List(MEALYLIMITSTATES@(M),i->FRElement(M,i)));

InstallMethod(LimitStates, "(FR) for a Mealy element",
        [IsMealyElement and IsMealyMachineIntRep],
        E->List(MEALYLIMITSTATES@(E),i->FRElement(E,i)));

InstallOtherMethod(State, "(FR) for a Mealy element and an integer",
        [IsMealyElement, IsInt],
        function(E,a)
    return FRElement(E,Transition(E,a));
end);

InstallOtherMethod(State, "(FR) for a Mealy element and a list",
        [IsMealyElement, IsList],
        function(E,a)
    local s;
    s := InitialState(E);
    for a in a do
        s := Transition(E,s,a);
    od;
    return FRElement(E,s);
end);

InstallMethod(States, "(FR) for a Mealy element",
        [IsMealyElement],
        E->List(StateSet(E),s->FRElement(E,s)));

InstallMethod(FixedRay, "(FR) for a Mealy element",
        [IsMealyElement and IsMealyMachineIntRep],
        function(e)
    local f, recur, state, ray;
    f := List([1..e!.nrstates],s->Reversed(Filtered(AlphabetOfFRObject(e),a->e!.output[s][a]=a)));
    state := [];
    ray := [];
    recur := function(s,e,state,ray)
        local i;
        i := Position(state,s);
        if i<>fail then
            return CompressedPeriodicList(ray,i);
        fi;
        Add(state,s);
        while f[s]<>[] do
            i := Remove(f[s]);
            Add(ray,i);
            i := recur(e!.transitions[s][i],e,state,ray);
            if i<>fail then return i; fi;
            Remove(ray);
        od;
        Remove(state);
        return fail;
    end;
    return recur(e!.initial,e,state,ray);
end);
############################################################################

############################################################################
##
#M  Minimized . . . . . . . . . . . . . . . . . . . . minimize Mealy machine
##
# mode=0 means normal
# mode=1 means all states are known to be accessible
# mode=2 means all states are known to be distinct and accessible
BindGlobal("MMMINIMIZE@", function(fam,alphabet,nrstates,transitions,output,initial,mode)
    local a, sn, snart, part, trap, i, j, x, y, p, ci, todo, states;

    if initial<>fail and mode=0 then
        todo := [initial];
        states := BlistList([1..nrstates],todo);
        for i in todo do
            for a in alphabet do
                x := transitions[i][a];
                if not states[x] then states[x] := true; Add(todo,x); fi;
            od;
        od;
        states := ListBlist([1..nrstates],states);
    else
        states := [1..nrstates];
    fi;

    if mode<=1 then
        a := NewDictionary(output[1],true);
        part := [];
        for i in states do
            x := output[i];
            y := LookupDictionary(a,x);
            if y=fail then
                Add(part,[i]);
                AddDictionary(a,x,Length(part));
            else
                Add(part[y],i);
            fi;
        od;
        Sort(part,function(a,b) return Length(a)<Length(b); end);

        trap := [];
        for i in [1..Length(part)] do for j in part[i] do trap[j] := i; od; od;
        # inverse lookup in part

        snart := [];
        for a in alphabet do
            sn := [];
            for i in states do
                j := transitions[i][a];
                if IsBound(sn[j]) then
                    Add(sn[j],i);
                else
                    sn[j] := [i];
                fi;
            od;
            for i in states do
                if IsBound(sn[i]) then Sort(sn[i]); fi;
            od;
            Add(snart, sn);
        od;
        # reverse lookup in trans, with indices swapped:
        # snart[letter][state] = { i: trans[i][letter] = state }

        todo := [1..Length(part)-1];
        i := 1;
        while i <= Length(todo) do
            for a in alphabet do
                ci := [];
                for j in part[todo[i]] do
                    if IsBound(snart[a][j]) then Append(ci,snart[a][j]); fi;
                od;
                if Length(ci) = 0 or Length(ci) = Length(states) then continue; fi;
                for j in Set(trap{ci}) do
                    p := part[j];
                    if Length(part[j]) > 1 then
                        x := Intersection(p,ci);
                        if Length(x) <> 0 and Length(x) <> Length(p) then
                            y := Difference(p,x);
                            if Length(y) > Length(x) then
                                part[j] := y;
                                Add(part,x);
                                for y in x do trap[y] := Length(part); od;
                            else
                                part[j] := x;
                                Add(part,y);
                                for x in y do trap[x] := Length(part); od;
                            fi;
                            Add(todo,Length(part));
                        fi;
                    fi;
                od;
            od;
            i := i+1;
        od;
    else
        trap := states;
    fi;

    if initial<>fail then
        x := []; y := [];
        todo := [initial];
        for i in todo do
            if not IsBound(x[trap[i]]) then
                Add(y,i);
                x[trap[i]] := Length(y);
                Append(todo,transitions[i]);
            fi;
        od;
        a := MealyElementNC(fam,
                     List(transitions{y},row->List(row,i->x[trap[i]])),
                     output{y},1);
        y := [];
        for i in states do
            if IsBound(x[trap[i]]) then y[i] := x[trap[i]]; fi;
        od;
        SetCorrespondence(a,Trans(y));
    else
        y := List(part,i->i[1]);
        a := MealyMachineNC(fam,
                     List(transitions{y},row->List(row,i->trap[i])),
                     output{y});
        SetCorrespondence(a,Trans(trap));
    fi;
    return a;
end);

InstallMethod(Minimized, "(FR) for a Mealy machine in int rep",
        [IsMealyMachine and IsMealyMachineIntRep],
        function(M)
    if M!.output=[] then
        return M;
    else
        return MMMINIMIZE@(FamilyObj(M),AlphabetOfFRObject(M),
                       M!.nrstates,M!.transitions,M!.output,fail,0);
    fi;
end);

InstallMethod(Minimized, "(FR) for a Mealy element in int rep",
        [IsMealyElement and IsMealyMachineIntRep],
        E->MMMINIMIZE@(FamilyObj(E),AlphabetOfFRObject(E),
                E!.nrstates,E!.transitions,E!.output,E!.initial,0));

InstallMethod(Minimized, "(FR) for a Mealy machine in domain rep",
        [IsMealyMachine and IsMealyMachineDomainRep],
        M->Error("Cannot minimize Mealy machine on domain"));

InstallMethod(Minimized, "(FR) for a Mealy element in domain rep",
        [IsMealyElement and IsMealyMachineDomainRep],
        M->Error("Cannot minimize Mealy element on domain"));

InstallMethod(SubFRMachine, "(FR) for two Mealy machines",
        [IsMealyMachine and IsMealyMachineIntRep,
         IsMealyMachine and IsMealyMachineIntRep],
        function(M,N)
    local s, c;
    if AlphabetOfFRObject(N)<>AlphabetOfFRObject(M) then
        return fail;
    fi;
    s := M+N;
    c := Minimized(s);
    c := ListTrans(Correspondence(c),s!.nrstates);
    s := [ListTrans(Correspondence(s)[1],M!.nrstates),
          ListTrans(Correspondence(s)[2],N!.nrstates)];
    if IsSubset(c{s[1]},c{s[2]}) then
        return Trans(StateSet(N),i->First(StateSet(M),j->c[s[1][j]]=c[s[2][i]]));
    else
        return fail;
    fi;
end);
############################################################################

############################################################################
##
#O  MealyMachine(<Transitions>, <Output> [,<Initial>])
#O  MealyMachine(<Alphabet>, <Transitions>, <Output> [,<Initial])
#O  MealyMachine(<Stateset>, <Alphabet>, <Transitions>, <Output> [,<Initial>])
##
InstallMethod(MealyMachineNC, "(FR) for a family and two matrices",
        [IsFamily, IsMatrix, IsMatrix],
        function(f, transitions, output)
    return Objectify(NewType(f, IsMealyMachine and IsMealyMachineIntRep),
                   rec(nrstates := Length(transitions),
                       transitions := transitions,
                       output := output));
end);

InstallMethod(MealyElementNC, "(FR) for a family, two matrices and an initial state",
        [IsFamily, IsMatrix, IsMatrix, IsInt],
        function(f, transitions, output, initial)
    return Objectify(NewType(f, IsMealyElement and IsMealyMachineIntRep),
                   rec(nrstates := Length(transitions),
                       transitions := transitions,
                       output := output,
                       initial := initial));
end);

BindGlobal("MEALYMACHINEINT@", function(transitions, output, initial)
    local F, nrstates, i, out, inv;
    if Length(transitions)<>Length(output) then
        Error("<Transitions> and <Output> must have the same length\n");
    fi;
    nrstates := Length(transitions);
    if not ForAll(transitions, IsList) or
       ForAny(transitions, r->Length(r)<>Length(transitions[1])) then
        Error("All rows of <Transitions> must be lists of the same length\n");
    fi;
    if initial<>fail then
        F := FREFamily([1..Length(transitions[1])]);
    else
        F := FRMFamily([1..Length(transitions[1])]);
    fi;
    if ForAny(transitions, x->ForAny(x, i->not i in [1..nrstates])) then
        Error("An entry of <Transitions> is not in the state set\n");
    fi;
    out := List(output,x->ANY2OUT@(x,Size(F!.alphabet)));
    inv := ForAll(out,ISINVERTIBLE@);
    if ForAny(out, x->not IsSubset(F!.alphabet, x)) then
        Error("An entry of <Output> is not in the alphabet\n");
    fi;
    ConvertToRangeRep(F!.alphabet);
    #!!! a bug in GAP, range rep is destroyed by IsSubset

    i := rec(nrstates := nrstates,
             transitions := transitions,
             output := out);

    if initial<>fail then
        i.initial := initial;
        i := Objectify(NewType(F, IsMealyElement and IsMealyMachineIntRep), i);
        i := Minimized(i);
    else
        i := Objectify(NewType(F, IsMealyMachine and IsMealyMachineIntRep), i);
    fi;
    SetIsInvertible(i, inv);

    return i;
end);

InstallMethod(MealyMachine, "(FR) for a matrix and a list",
        [IsMatrix, IsList],
        function(t, o) return MEALYMACHINEINT@(t, o, fail); end);

InstallMethod(MealyElement, "(FR) for a matrix, a list and a state",
        [IsMatrix, IsList, IsInt],
        function(t, o, s) return MEALYMACHINEINT@(t, o, s); end);

BindGlobal("MEALYMACHINEDOM@", function(alphabet, transitions, output, has_init, initial)
    local F, out, trans, i, t;
    if has_init then
        F := FREFamily(alphabet);
    else
        F := FRMFamily(alphabet);
    fi;
    if Length(transitions)<>Length(output) then
        Error("<Transitions> and <Output> must have the same length\n");
    fi;
    if ForAny(output,IsList) and
       HasSize(alphabet) and Size(alphabet)<>Length(First(output,IsList)) then
        Error("<Domain> and <Output> must have the same size\n");
    fi;
    if F!.standard then
        trans := [];
        for i in transitions do
            if IsFunction(i) then
                Add(trans, List(alphabet, i));
            elif IsList(i) then
                Add(trans, i);
            else
                Add(trans, List(alphabet, y->y^i));
            fi;
        od;
        out := [];
        for i in output do
            if IsFunction(i) then
                Add(out, MappingByFunction(alphabet, alphabet, i));
            else
                Add(out, ANY2OUT@(i,Size(alphabet)));
            fi;
        od;
        t := IsMealyMachineIntRep;
        i := rec(nrstates := Length(transitions),
                 transitions := trans,
                 output := out);
    else
        trans := function(s,a)
            local newa;
            newa := F!.a2n(a);
            if IsFunction(transitions[s]) then
                return transitions[s](newa);
            elif IsList(transitions[s]) then
                return transitions[s][newa];
            else
                return newa^transitions[s];
            fi;
        end;
        out := function(s,a)
            local newa;
            newa := F!.a2n(a);
            if IsFunction(output[s]) then
                newa := output[s](newa);
            else
                newa := output[s][newa];
            fi;
            return F!.n2a(newa);
        end;
        t := IsMealyMachineDomainRep;
        i := rec(states := [1..Length(transitions)],
                 transitions := trans,
                 output := out);
    fi;
    if has_init then
        i!.initial := initial;
        i := Objectify(NewType(F, IsMealyElement and t), i);
        if t = IsMealyMachineIntRep then
            i := Minimized(i);
        fi;
    else
        i := Objectify(NewType(F, IsMealyMachine and t), i);
    fi;
    return i;
end);

InstallMethod(MealyMachine, "(FR) for an alphabet and two lists",
        [IsDomain, IsList, IsList],
        function(a, t, o) return MEALYMACHINEDOM@(a, t, o, false, 0); end);

InstallMethod(MealyElement, "(FR) for an alphabet, two lists and a state",
        [IsDomain, IsList, IsList, IsInt],
        function(a, t, o, s) return MEALYMACHINEDOM@(a, t, o, true, s); end);

InstallMethod(MealyMachine, "(FR) for alphabet, stateset and two functions",
        [IsDomain, IsDomain, IsFunction, IsFunction],
        function(stateset, alphabet, transitions, output)
    local F;
    F := FRMFamily(alphabet);
    return Objectify(NewType(F, IsMealyMachine and IsMealyMachineDomainRep),
                   rec(states := stateset,
                       transitions := transitions,
                       output := output));
end);

InstallMethod(MealyElement, "(FR) for alphabet, stateset, two functions and a state",
        [IsDomain, IsDomain, IsFunction, IsFunction, IsObject], 20,
        function(stateset, alphabet, transitions, output, s)
    local F;
    F := FREFamily(alphabet);

    return Objectify(NewType(F, IsMealyElement and IsMealyMachineDomainRep),
                   rec(states := stateset,
                       transitions := transitions,
                       output := output,
                       initial := s));
end);

InstallMethod(FRElement, "(FR) for a Mealy machine and a state",
        [IsMealyMachine and IsMealyMachineIntRep, IsInt],
        function(M,s)
    return MMMINIMIZE@(FREFamily(M),AlphabetOfFRObject(M),
                   M!.nrstates,M!.transitions,M!.output,s,0);
end);

InstallMethod(FRElement, "(FR) for a Mealy element and a state",
        [IsMealyElement and IsMealyMachineIntRep, IsInt],
        function(E,s)
    return MMMINIMIZE@(FamilyObj(E),AlphabetOfFRObject(E),
                   E!.nrstates,E!.transitions,E!.output,s,2);
end);

InstallMethod(FRElement, "(FR) for a Mealy machine and a list of states",
        [IsMealyMachine and IsMealyMachineIntRep, IsList],
        function(M,l)
    return Product(List(l,i->FRElement(M,i)));
end);

InstallMethod(FRElement, "(FR) for a Mealy element and a list of states",
        [IsMealyElement and IsMealyMachineIntRep, IsList],
        function(E,l)
    return Product(List(l,i->FRElement(E,i)));
end);

InstallMethod(FRElement, "(FR) for a Mealy machine and a state",
        [IsMealyMachine and IsMealyMachineDomainRep, IsObject],
        function(M,s)
    return Objectify(NewType(FREFamily(M), IsMealyElement and
                       IsMealyMachineDomainRep),
                       rec(states := M!.states,
                           transitions := M!.transitions,
                           output := M!.output,
                           initial := s));
end);

InstallMethod(FRElement, "(FR) for a Mealy element and a state",
        [IsMealyElement and IsMealyMachineDomainRep, IsObject],
        function(E,s)
    return Objectify(NewType(FamilyObj(E), IsMealyElement and
                   IsMealyMachineDomainRep),
                   rec(states := E!.states,
                       transitions := E!.transitions,
                       output := E!.output,
                       initial := s));
end);

BindGlobal("COMPOSEELEMENT@", function(l,p)
    local m, i, init;
    if ForAll(l,IsMealyElement) then
        m := MealyMachineNC(FRMFamily(l[1]),[List(l,x->1)],[p]);
        init := 1;
        for i in [1..Length(l)] do
            m := m+UnderlyingFRMachine(l[i]);
            init := init^Correspondence(m)[1];
            m!.transitions[init][i] := InitialState(l[i])^Correspondence(m)[2];
        od;
        return FRElement(m,init);
    else
        return FRElement([List(l,x->[x])],[p],[1]);
    fi;
end);

InstallMethod(ComposeElement, "(FR) for a list of elements and a permutation",
        [IsFRElementCollection, IsObject],
        function(l,p)
    return COMPOSEELEMENT@(l,ANY2OUT@(p,Size(AlphabetOfFRObject(l[1]))));
end);

InstallMethod(ComposeElement, "(FR) for a list of elements and a list",
        [IsFRElementCollection, IsList],
        COMPOSEELEMENT@);

InstallMethod(VertexElement, "(FR) for a vertex index and a Mealy element",
        [IsPosInt, IsMealyElement],
        function(v,E)
    local m;
    m := MealyMachineNC(FRMFamily(E),[List(AlphabetOfFRObject(E),x->2),List(AlphabetOfFRObject(E),x->2)],[AlphabetOfFRObject(E),AlphabetOfFRObject(E)])+UnderlyingFRMachine(E);
    m!.transitions[1^Correspondence(m)[1]][v] := InitialState(E)^Correspondence(m)[2];
    return FRElement(m,1^Correspondence(m)[1]);
end);

InstallMethod(DiagonalElement, "(FR) for a power and a Mealy element",
        [IsInt, IsMealyElement],
        function(n,E)
    return ComposeElement(List([0..Size(AlphabetOfFRObject(E))-1],i->E^((-1)^i*Binomial(n,i))),AlphabetOfFRObject(E));
end);

InstallMethod(UnderlyingFRMachine, "(FR) for a Mealy element",
        [IsMealyElement and IsMealyMachineIntRep],
        E->MealyMachineNC(FRMFamily(E), E!.transitions, E!.output));
#############################################################################

#############################################################################
##
#M ViewObj
##
InstallMethod(ViewString, "(FR) displays a Mealy machine in compact form",
        [IsMealyMachine and IsMealyMachineIntRep],
        function(M)
    local s;
    s := "<Mealy machine on alphabet ";
    APPEND@(s, AlphabetOfFRObject(M), " with ", M!.nrstates, " state");
    if M!.nrstates<>1 then Append(s,"s"); fi;
    Append(s,">");
    return s;
end);

InstallMethod(ViewString, "(FR) displays a Mealy machine in compact form",
        [IsMealyMachine and IsMealyMachineDomainRep],
        M->CONCAT@("<Mealy machine on alphabet ", AlphabetOfFRObject(M), " with states ", M!.states,">"));

InstallMethod(ViewString, "(FR) displays a Mealy element in compact form",
        [IsMealyElement and IsMealyMachineIntRep],
        function(E)
    local s;
    if IsOne(E) then
        s := CONCAT@("<Trivial Mealy element on alphabet ", AlphabetOfFRObject(E), ">");
    else
        s := CONCAT@("<Mealy element on alphabet ", AlphabetOfFRObject(E),
            " with ", E!.nrstates, " state");
        if E!.nrstates<>1 then Append(s,"s"); fi;
        if E!.initial<>1 then APPEND@(s,", initial state ",E!.initial); fi;
        Append(s,">");
    fi;
    return s;
end);

InstallMethod(ViewString, "(FR) displays a Mealy element in compact form",
        [IsMealyElement and IsMealyMachineDomainRep],
        E->CONCAT@("<Mealy element on alphabet ", AlphabetOfFRObject(E),
        " with states ", E!.states, ", initial state ", InitialState(E), ">"));
#############################################################################

#############################################################################
##
#M  String
##
InstallMethod(String, "(FR) Mealy machine to string",
        [IsMealyMachine and IsMealyMachineIntRep],
        M->CONCAT@("MealyMachine(",M!.transitions,", ", M!.output,")"));

InstallMethod(String, "(FR) Mealy element to string",
        [IsMealyElement and IsMealyMachineIntRep],
        E->CONCAT@("MealyElement(",E!.transitions,", ",
                   E!.output,", ",InitialState(E),")"));

InstallMethod(String, "(FR) Mealy machine to string",
        [IsMealyMachine and IsMealyMachineDomainRep],
        M->CONCAT@("MealyMachine(",M!.states,", ", AlphabetOfFRObject(M),
                ", ",M!.transitions, ", ",M!.output,")"));

InstallMethod(String, "(FR) Mealy element to string",
        [IsMealyElement and IsMealyMachineDomainRep],
        E->CONCAT@("MealyElement(",E!.states,", ", AlphabetOfFRObject(E),
                ", ",E!.transitions,", ",E!.output,", ",InitialState(E),")"));
#############################################################################

#############################################################################
##
#M  Display . . . . . . . . . . . . . . . . . . . .pretty-print Mealy machine
##
BindGlobal("MEALYDISPLAY@", function(M)
    local a, i, j, states, slen, alen, sprint, aprint, sblank, ablank, srule, arule, s;
    a := AlphabetOfFRObject(M);
    states := StateSet(M);
    if IsSubset(Integers,states) then
        slen := LogInt(Maximum(Elements(states)),8)+2;
        sprint := i->String(WordAlp("abcdefgh",i),slen);
    else
        slen := Maximum(List(states,t->Length(String(t))))+1;
        sprint := i->String(i,slen);
    fi;
    sblank := ListWithIdenticalEntries(slen,' ');
    srule := ListWithIdenticalEntries(slen,'-');
    if IsSubset(Integers,a) then
        alen := LogInt(Maximum(Elements(a)),10)+3;
        aprint := i->String(i,-alen);
    else
        alen := Maximum(List(a,t->Length(String(t))))+2;
        aprint := i->String(i,-alen);
    fi;
    ablank := ListWithIdenticalEntries(alen,' ');
    arule := ListWithIdenticalEntries(alen,'-');

    s := Concatenation(sblank," |");
    for i in a do APPEND@(s,sblank,aprint(i)," "); od;
    APPEND@(s,"\n");
    APPEND@(s,srule,"-+"); for i in a do APPEND@(s,srule,arule,"+"); od; APPEND@(s,"\n");
    for i in states do
        APPEND@(s,sprint(i)," |");
        for j in a do
            APPEND@(s,sprint(Transition(M,i,j)),",",aprint(Output(M,i,j)));
        od;
        APPEND@(s,"\n");
    od;
    APPEND@(s,srule,"-+"); for i in a do APPEND@(s,srule,arule,"+"); od; APPEND@(s,"\n");
    if IsMealyElement(M) then
        APPEND@(s,"Initial state:",sprint(InitialState(M)),"\n");
    fi;
    return s;
end);

InstallMethod(DisplayString, "(FR) for a Mealy machine",
        [IsMealyMachine], MEALYDISPLAY@);

InstallMethod(DisplayString, "(FR) for a Mealy element",
        [IsMealyElement], MEALYDISPLAY@);
#############################################################################

############################################################################
##
#M  AsMealyMachine
#M  AsGroupFRMachine
#M  AsMonoidFRMachine
#M  AsSemigroupFRMachine
#M  AsMealyElement
#M  AsGroupFRElement
#M  AsMonoidFRElement
#M  AsSemigroupFRElement
##
BindGlobal("DOMAINTOPERMTRANS@", function(X)
    local a, s, i, t, out, trans;
    a := AsSortedList(AlphabetOfFRObject(X));
    s := AsSortedList(X!.states);
    trans := List(s,x->List(a,y->Position(s,X!.transitions(x,y))));
    out := [];
    for i in s do
        Add(out,List(a,y->Position(a,X!.output(i,y))));
    od;
    i := rec(nrstates := Length(s), transitions := trans, output := out);
    if IsMealyElement(X) then
        i.initial := Position(s,X!.initial);
        i := Objectify(NewType(FREFamily([1..Length(a)]),
                     IsMealyElement and IsMealyMachineIntRep),i);
        i := Minimized(i);
    else
        i := Objectify(NewType(FRMFamily([1..Length(a)]),
                     IsMealyMachine and IsMealyMachineIntRep),i);
    fi;
    return i;
end);

BindGlobal("MAKEMEALYMACHINE@", function(f,l,init)
    local M, d;
    d := List(l,DecompositionOfFRElement);
    M := List(d,x->List(x[1],y->Position(l,y)));
    if ForAny(M,x->fail in x) then
        return fail;
    elif init<>fail then
        return MealyElementNC(f,M,List(d,x->x[2]),Position(l,init));
    else
        return MealyMachineNC(f,M,List(d,x->x[2]));
    fi;
end);

BindGlobal("ASINTREP@", function(M)
    if IsMealyMachineIntRep(M) then
        return M;
    elif IsMealyMachineDomainRep(M) then
        return DOMAINTOPERMTRANS@(M);
    elif IsFRMachine(M) then
        return MAKEMEALYMACHINE@(FamilyObj(M),
            States(List(GeneratorsOfFRMachine(M),x->FRElement(M,x))),fail);
    else
        return MAKEMEALYMACHINE@(FamilyObj(M),States(M),M);
    fi;
end);

InstallMethod(AsMealyMachine, "(FR) for a list of FR elements",
        [IsFRElementCollection],
        function(l)
    local M, d;
    M := MAKEMEALYMACHINE@(FamilyObj(UnderlyingFRMachine(l[1])),l,fail);
    SetCorrespondence(M,l);
    return M;
end);

InstallMethod(AsMealyMachine, "(FR) for a FR machine",
        [IsFRMachine],
        function(M)
    local gens, states, N;
    gens := List(GeneratorsOfFRMachine(M),x->FRElement(M,x));
    states := States(gens);
    N := MAKEMEALYMACHINE@(FamilyObj(M),states,fail);
    SetCorrespondence(N,MappingByFunction(StateSet(M),Integers,g->Position(states,g)));
    return N;
end);

InstallMethod(AsMealyMachine, "(FR) for a Mealy machine",
        [IsMealyMachine],
        function(M)
    SetCorrespondence(M,StateSet(M));
    return M;
end);

InstallMethod(AsMealyElement, "(FR) for a FR element",
        [IsFRElement],
        E->MAKEMEALYMACHINE@(FamilyObj(E),States(E),E));

InstallMethod(AsMealyElement, "(FR) for a Mealy element",
        [IsMealyElement], E->E);

InstallMethod(AsGroupFRMachine, "(FR) for a Mealy machine",
        [IsMealyMachine],
        function(M)
    local G, gen, gens, realm, ntrealm, corr, i, e;
    M := ASINTREP@(M);
    if not IsInvertible(M) then return fail; fi;
    realm := StateSet(M);
    corr := []; ntrealm := []; gens := [];
    for i in realm do
        e := FRElement(M,i);
        if IsOne(e) then
            corr[i] := 0;
        elif IsInvertible(M) and Position(gens,Inverse(e))<>fail then
            corr[i] := -corr[Position(gens,Inverse(e))];
        else
            Add(ntrealm,i);
            corr[i] := Length(ntrealm);
        fi;
        Add(gens,e);
    od;
    G := FreeGroup(Length(ntrealm));
    gens := GeneratorsOfGroup(G);
    gen := function(s) if corr[s]=0 then return One(G); elif corr[s]>0 then return gens[corr[s]]; else return gens[-corr[s]]^-1; fi; end;
    i := FRMachineNC(FamilyObj(M),G,
                 List(ntrealm,i->List(AlphabetOfFRObject(M),j->gen(Transition(M,i,j)))),
                 List(ntrealm,i->Output(M,i)));
    SetCorrespondence(i,MappingByFunction(Domain([1..Length(corr)]),G,gen));
    return i;
end);

InstallMethod(AsMonoidFRMachine, "(FR) for a Mealy machine",
        [IsMealyMachine],
        function(M)
    local G, gen, gens, realm, ntrealm, corr, i, e;
    M := ASINTREP@(M);
    realm := StateSet(M);
    corr := []; ntrealm := []; gens := [];
    for i in realm do
        e := FRElement(M,i);
        if IsOne(e) then
            corr[i] := 0;
        else
            Add(ntrealm,i);
            corr[i] := Length(ntrealm);
        fi;
        Add(gens,e);
    od;
    G := FreeMonoid(Length(ntrealm));
    gens := GeneratorsOfMonoid(G);
    gen := function(s) if corr[s]=0 then return One(G); else return gens[corr[s]]; fi; end;
    i := FRMachineNC(FamilyObj(M),G,
                 List(ntrealm,i->List(AlphabetOfFRObject(M),j->gen(Transition(M,i,j)))),
                 List(ntrealm,i->Output(M,i)));
    SetCorrespondence(i,MappingByFunction(Domain([1..Length(corr)]),G,gen));
    return i;
end);

InstallMethod(AsSemigroupFRMachine, "(FR) for a Mealy machine",
        [IsMealyMachine],
        function(M)
    local G, gen, gens, realm, ntrealm, corr, i, e;
    M := ASINTREP@(M);
    realm := StateSet(M);
    corr := []; ntrealm := []; gens := [];
    for i in realm do
        e := FRElement(M,i);
        Add(ntrealm,i);
        corr[i] := Length(ntrealm);
        Add(gens,e);
    od;
    G := FreeSemigroup(Length(ntrealm));
    gens := GeneratorsOfSemigroup(G);
    gen := function(s) return gens[corr[s]]; end;
    i := FRMachineNC(FamilyObj(M),G,
                 List(ntrealm,i->List(AlphabetOfFRObject(M),j->gen(Transition(M,i,j)))),
                 List(ntrealm,i->Output(M,i)));
    SetCorrespondence(i,MappingByFunction(Domain([1..Length(corr)]),G,gen));
    return i;
end);

InstallMethod(AsGroupFRElement, "(FR) for a Mealy element",
        [IsMealyElement],
        function(E)
    local m;
    m := AsGroupFRMachine(UnderlyingFRMachine(E));
    return FRElement(m,InitialState(E)^Correspondence(m));
end);

InstallMethod(AsMonoidFRElement, "(FR) for a Mealy element",
        [IsMealyElement],
        function(E)
    local m;
    m := AsMonoidFRMachine(UnderlyingFRMachine(E));
    return FRElement(m,InitialState(E)^Correspondence(m));
end);

InstallMethod(AsSemigroupFRElement, "(FR) for a Mealy element",
        [IsMealyElement],
        function(E)
    local m;
    m := AsSemigroupFRMachine(UnderlyingFRMachine(E));
    return FRElement(m,InitialState(E)^Correspondence(m));
end);

InstallMethod(AsIntMealyMachine, "(FR) for a Mealy machine",
        [IsMealyMachine and IsMealyMachineIntRep], AsMealyMachine);
InstallMethod(AsIntMealyMachine, "(FR) for a Mealy machine",
        [IsMealyMachine], DOMAINTOPERMTRANS@);

InstallMethod(AsIntMealyElement, "(FR) for a Mealy machine",
        [IsMealyElement and IsMealyMachineIntRep], AsMealyElement);
InstallMethod(AsIntMealyElement, "(FR) for a Mealy machine",
        [IsMealyElement], DOMAINTOPERMTRANS@);

BindGlobal("TOPELEMENTPERM@", function(l)
    local n;
    n := Length(l);
    if l=[1..n] then
        return MealyElementNC(FREFamily([1..n]),
                       [ListWithIdenticalEntries(n,1)],[[1..n]],1);
    fi;
    return MealyElementNC(FREFamily([1..n]),
                   List([1..2],i->ListWithIdenticalEntries(n,2)),
                   [l,[1..n]],1);
end);
InstallMethod(TopElement, "(FR) for a permutation",
        [IsPerm],
        p->TOPELEMENTPERM@(ListPerm(p)));
InstallMethod(TopElement, "(FR) for a permutation and a degree",
        [IsPerm,IsInt],
        function(p,n)
    return TOPELEMENTPERM@(ListPerm(p,n));
end);
InstallMethod(TopElement, "(FR) for a transformation",
        [IsTransformation],
        t->TOPELEMENTPERM@(ImageListOfTransformation(t)));
InstallMethod(TopElement, "(FR) for a transformation and a degree",
        [IsTransformation,IsInt],
        function(t,n)
    local l;
    l := ImageListOfTransformation(t);
    if Length(l)<n then
        l := Concatenation(l,[Length(l)+1..n]);
    elif Length(l)>n then
        l := l{[1..n]};
    fi;
    return TOPELEMENTPERM@(l);
end);
InstallMethod(TopElement, "(FR) for a trans",
        [IsTrans],
        t->TOPELEMENTPERM@(ListTrans(t)));
InstallMethod(TopElement, "(FR) for a trans and a degree",
        [IsTrans,IsInt],
        function(t,n)
    return TOPELEMENTPERM@(ListTrans(t,n));
end);
#############################################################################

#############################################################################
##
#M  Draw . . . . . . . . . . . . . . . . . .draw Mealy machine using graphviz
##
BindGlobal("MM2DOT@", function(M)
    local names, i, j, S, stateset, alphabet;

    S := "digraph ";
    if HasName(M) and ForAll(Name(M),IsAlphaChar) then
        Append(S, "\""); Append(S, Name(M)); Append(S, "\"");
    else
        Append(S,"MealyMachine");
    fi;
    Append(S," {\n");
    if IsMealyMachineIntRep(M) then
        stateset := [1..M!.nrstates];
    else
        stateset := AsSortedList(M!.states);
    fi;
    alphabet := AsSortedList(AlphabetOfFRObject(M));
    if IsSubset(Integers, alphabet) and IsSubset(Integers, stateset) then
        names := List([1..Length(stateset)], i->WordAlp("abcdefgh", i));
    else
        names := List(stateset, String);
    fi;

    for i in [1..Length(names)] do
        Append(S, names[i]);
        Append(S," [shape=");
        if IsBound(M!.initial) and M!.initial = stateset[i] then
            Append(S,"double");
        fi;
        Append(S,"circle]\n");
    od;
    for i in [1..Length(names)] do
        for j in alphabet do
            Append(S,"  ");
            Append(S,names[i]);
            Append(S," -> ");
            Append(S,names[Position(stateset,Transition(M,stateset[i],j))]);
            Append(S," [label=\"");
            Append(S,String(j));
            Append(S,"/");
            Append(S,String(Output(M,stateset[i],j)));
            Append(S,"\",color=");
            Append(S,COLOURS@(Position(alphabet,j)));
            Append(S,"];\n");
        od;
    od;
    Append(S,"}\n");
    return S;
end);

BindGlobal("DRAWMEALY@", function(M)
    DOT2DISPLAY@(MM2DOT@(M),"dot");
end);

InstallMethod(Draw, "(FR) draws a Mealy machine using graphviz",
        [IsMealyMachine],
        DRAWMEALY@);

InstallMethod(Draw, "(FR) draws a Mealy machine using graphviz",
        [IsMealyMachine, IsString],
        function(M,str)
    AppendTo(str,MM2DOT@(M));
end);

InstallMethod(Draw, "(FR) draws a Mealy element using graphviz",
        [IsMealyElement],
        DRAWMEALY@);

InstallMethod(Draw, "(FR) draws a Mealy element using graphviz",
        [IsMealyElement, IsString],
        function(M,str)
    AppendTo(str,MM2DOT@(M));
end);

BindGlobal("INSTALLMMHANDLER@", function(name,rv)
    InstallOtherMethod(name, "(FR) for a generic Mealy machine",
            [IsFRMachine],
            function(M)
        Info(InfoFR, 2, name, ": converting to Mealy machine");
        if rv then
            return name(ASINTREP@(M));
        else
            name(ASINTREP@(M));
        fi;
    end);
end);
BindGlobal("INSTALLMEHANDLER@", function(name,rv)
    InstallOtherMethod(name, "(FR) for a generic Mealy element",
            [IsFRElement],
            function(E)
        Info(InfoFR, 2, name, ": converting to Mealy element");
        if rv then
            return name(ASINTREP@(E));
        else
            name(ASINTREP@(E));
        fi;
    end);
end);

INSTALLMEHANDLER@(Draw,false);
INSTALLMMHANDLER@(Draw,false);

InstallOtherMethod(Draw, "(FR) for a FR machine and a filename",
        [IsFRMachine,IsString],
        function(M,S)
    Info(InfoFR, 1, "Draw: converting to Mealy machine");
    Draw(ASINTREP@(M),S);
end);

InstallOtherMethod(Draw, "(FR) for a FR element and a filename",
        [IsFRElement,IsString],
        function(E,S)
    Info(InfoFR, 1, "Draw: converting to Mealy element");
    Draw(ASINTREP@(E),S);
end);
############################################################################

############################################################################
##
#M Methods for the comparison operations for Mealy machines
##
InstallMethod(IsOne, "(FR) for a Mealy element",
        [IsMealyElement and IsMealyMachineIntRep],
        function(E)
    return E!.output = [AlphabetOfFRObject(E)];
end);
INSTALLMEHANDLER@(IsOne,true);

InstallMethod(\=, "(FR) for two Mealy elements", IsIdenticalObj,
        [IsMealyElement and IsMealyMachineIntRep, IsMealyElement and IsMealyMachineIntRep],
        function(x,y)
    return x!.output = y!.output and x!.transitions = y!.transitions;
end);

InstallMethod(\<, "(FR) for two Mealy elements", IsIdenticalObj,
        [IsMealyElement and IsMealyMachineIntRep, IsMealyElement and IsMealyMachineIntRep],
        function(x,y)
    local z, ix, iy, i, j, todo;

    if x=y then return false; fi;

    z := UnderlyingFRMachine(x)+UnderlyingFRMachine(y);
    ix := InitialState(x)^Correspondence(z)[1];
    iy := InitialState(y)^Correspondence(z)[2];
    z := Minimized(z);
    ix := ix^Correspondence(z);
    iy := iy^Correspondence(z);
    todo := NewFIFO([[ix,iy]]);
    for i in todo do
        if Output(z,i[1])<>Output(z,i[2]) then
            return Output(z,i[1])<Output(z,i[2]);
        fi;
        for j in AlphabetOfFRObject(z) do
            ix := Transition(z,i[1],j);
            iy := Transition(z,i[2],j);
            if ix<>iy then
                Add(todo,[ix,iy]);
            fi;
        od;
    od;
end);

InstallMethod(IsOne, "(FR) for a Mealy machine",
        [IsMealyMachine],
        function(x)
    local ix;
    if IsFinite(AlphabetOfFRObject(x)) then
        ix := ASINTREP@(x);
        return ix!.output=[AlphabetOfFRObject(x)];
    else
        TryNextMethod();
    fi;
end);

InstallMethod(\=, "(FR) for two Mealy machines in int rep", IsIdenticalObj,
        [IsMealyMachine and IsMealyMachineIntRep, IsMealyMachine and IsMealyMachineIntRep],
        function(x,y)
    return x!.nrstates = y!.nrstates and
               x!.transitions = y!.transitions and
           x!.output = y!.output;
end);

InstallMethod(\=, "(FR) for two Mealy machines in domain rep", IsIdenticalObj,
        [IsMealyMachine and IsMealyMachineDomainRep, IsMealyMachine and IsMealyMachineDomainRep],
        function(x,y)
    if IsFinite(AlphabetOfFRObject(x)) then
        return ASINTREP@(x)=ASINTREP@(y);
    else
        return x!.nrstates = y!.nrstates and
               x!.transitions = y!.transitions and
               x!.output = y!.output;
    fi;
end);

InstallMethod(\=, "(FR) for two Mealy elements", IsIdenticalObj,
        [IsMealyElement, IsMealyElement],
        function(x,y)
    if not IsFinite(AlphabetOfFRObject(x)) then
        Error("Don't know how to compare machines in domain representation");
    fi;
    if IsMealyMachineDomainRep(x) then
        x := ASINTREP@(x);
    fi;
    if IsMealyMachineDomainRep(y) then
        y := ASINTREP@(y);
    fi;
    return x=y;
end);

InstallMethod(\<, "(FR) for two Mealy machines", IsIdenticalObj,
        [IsMealyMachine and IsMealyMachineIntRep, IsMealyMachine and IsMealyMachineDomainRep],
        ReturnTrue);

InstallMethod(\<, "(FR) for two Mealy machines", IsIdenticalObj,
        [IsMealyMachine and IsMealyMachineDomainRep, IsMealyMachine and IsMealyMachineIntRep],
        ReturnFalse);

BindGlobal("MMLTINTREP@", function(x,y)
    local a, s;
    if x!.nrstates <> y!.nrstates then
        return x!.nrstates < y!.nrstates;
    elif x!.transitions <> y!.transitions then
        return x!.transitions < y!.transitions;
    else
        return x!.output < y!.output;
    fi;
end);

InstallMethod(\<, "(FR) for two Mealy machines", IsIdenticalObj,
        [IsMealyMachine and IsMealyMachineIntRep, IsMealyMachine and IsMealyMachineIntRep],
        MMLTINTREP@);

InstallMethod(\<, "(FR) for two Mealy machines", IsIdenticalObj,
        [IsMealyMachine and IsMealyMachineDomainRep, IsMealyMachine and IsMealyMachineDomainRep],
        function(x,y)
    if IsFinite(AlphabetOfFRObject(x)) then
        return MMLTINTREP@(ASINTREP@(x), ASINTREP@(y));
    else
        if x!.nrstates <> y!.nrstates then
            return x!.nrstates < y!.nrstates;
        elif x!.transitions <> y!.transitions then
            return x!.transitions < y!.transitions;
        elif x!.output <> y!.output then
            return x!.output < y!.output;
        fi;
        return false; # they're equal
    fi;
end);

InstallMethod(\<, "(FR) for two Mealy elements", IsIdenticalObj,
        [IsMealyElement, IsMealyElement],
        function(x,y)
    if not IsFinite(AlphabetOfFRObject(x)) then
        Error("Don't know how to compare machines in domain representation");
    fi;
    if IsMealyMachineDomainRep(x) then
        x := ASINTREP@(x);
    fi;
    if IsMealyMachineDomainRep(y) then
        y := ASINTREP@(y);
    fi;
    return x<y;
end);
############################################################################

############################################################################
##
#M Products of Mealy machines
##
############################################################################
InstallMethod(\+, "(FR) for two Mealy machines", IsIdenticalObj,
        [IsMealyMachine and IsMealyMachineDomainRep,
         IsMealyMachine and IsMealyMachineDomainRep], function(arg)
    local q, a, trans, out;
    q := Domain(Cartesian([1..Length(arg)],Union(List(arg,M->M!.states))));
    trans := function(s,a)
        return [s[1],arg[s[1]]!.transitions(s[2],a)];
    end;
    out := function(s,a)
        return arg[s[1]]!.output(s[2],a);
    end;
    a := MealyMachine(q,AlphabetOfFRObject(arg[1]),trans,out);
    if ForAll(arg,HasIsInvertible) then
        SetIsInvertible(a,ForAll(arg,IsInvertible));
    fi;
    SetCorrespondence(a,i->MappingByFunction(arg[i]!.states,q,s->[i,s]));
    SET_NAME@(arg,"+",a);
    return a;
end);

InstallMethod(\+, "(FR) for two Mealy machines", IsIdenticalObj,
        [IsMealyMachine and IsMealyMachineIntRep,
         IsMealyMachine and IsMealyMachineIntRep],
        function(M,N)
    local a;
    a := MealyMachineNC(FamilyObj(M),
                 Concatenation(M!.transitions,N!.transitions+M!.nrstates),
                 Concatenation(M!.output,N!.output));
    if HasIsInvertible(M) and HasIsInvertible(N) then
        SetIsInvertible(a,IsInvertible(M) and IsInvertible(N));
    fi;
    SetCorrespondence(a,[(),Trans(M!.nrstates+[1..N!.nrstates])]);
    SET_NAME@([M,N],"+",a);
    return a;
end);

InstallMethod(\+, "(FR) for generic FR machines", IsIdenticalObj,
        [IsFRMachine,IsFRMachine],
        function(x,y)
    return ASINTREP@(x)+ASINTREP@(y);
end);

InstallMethod(\*, "(FR) for two Mealy machines", IsIdenticalObj,
        [IsMealyMachine and IsMealyMachineDomainRep,
         IsMealyMachine and IsMealyMachineDomainRep],
        function(M,N)
    local q, a, trans, out;
    q := Domain(Cartesian(M!.states,N!.states));
    trans := function(s,a)
        return [M!.transition(s[1],a),N!.transition(s[2],M!.output(s[1],a))];
    end;
    out := function(s,a)
        return N!.output(s[2],M!.output(s[1],a));
    end;
    a := MealyMachine(q,AlphabetOfFRObject(M),trans,out);
    if HasIsInvertible(M) and HasIsInvertible(N) then
        SetIsInvertible(a,IsInvertible(M) and IsInvertible(N));
    fi;
    SET_NAME@([M,N],"*",a);
    return a;
end);

InstallMethod(\*, "(FR) for two Mealy machines", IsIdenticalObj,
        [IsMealyMachine and IsMealyMachineIntRep,
         IsMealyMachine and IsMealyMachineIntRep],
        function(M,N)
    local trans, out, i, j, a, t, o;

    trans := [];
    out := [];
    for i in [1..M!.nrstates] do
        o := M!.output[i];
        t := (M!.transitions[i]-1)*N!.nrstates;
        for j in [1..N!.nrstates] do
            Add(trans,t+N!.transitions[j]{o});
            Add(out,N!.output[j]{o});
        od;
    od;
    a := MealyMachineNC(FamilyObj(M),trans,out);
    if HasIsInvertible(M) and HasIsInvertible(N) then
        SetIsInvertible(a,IsInvertible(M) and IsInvertible(N));
    fi;
    SET_NAME@([M,N],"*",a);
    return a;
end);

InstallMethod(\*, "(FR) for generic FR machines", IsIdenticalObj,
        [IsFRMachine,IsFRMachine],
        function(x,y)
    return ASINTREP@(x)*ASINTREP@(y);
end);

InstallMethod(TensorProductOp, "(FR) for Mealy machines",
        [IsList,IsMealyMachine and IsMealyMachineDomainRep],
        function(M,N)
    local a, d, trans, out;
    while ForAny(M,x->x!.states<>N!.states) do
        Error("All machines should have same stateset");
    od;
    d := Length(M);
    a := Domain(Cartesian(List(M,AlphabetOfFRObject)));
    trans := function(s,a)
        local i;
        for i in [1..d] do s := M[i]!.transitions(s,a[i]); od;
        return s;
    end;
    out := function(s,a)
        local i, b;
        b := [];
        for i in [1..d] do
            Add(b,M[i]!.output(s,a[i]));
            s := M[i]!.transitions(s,a[i]);
        od;
        return b;
    end;
    a := MealyMachine(N!.states,a,trans,out);
    if ForAll(M,HasIsInvertible) then
        SetIsInvertible(a,ForAll(M,IsInvertible));
    fi;
    SET_NAME@(M,"(*)",a);
    return a;
end);

InstallMethod(TensorProductOp, "(FR) for two integer Mealy machines",
        [IsList,IsMealyMachine and IsMealyMachineIntRep],
        function(M,N)
    local a, b, trans, out, t, o, d, i, j, alphabet, s;

    while ForAny(M,x->x!.nrstates<>N!.nrstates) do
        Error("All machines should have same stateset");
    od;

    alphabet := Cartesian(List(M,AlphabetOfFRObject));

    trans := [];
    out := [];
    for i in [1..N!.nrstates] do
        t := [];
        o := [];
        for a in alphabet do
            b := [];
            s := i;
            for j in [1..Length(M)] do
                Add(b,M[j]!.output[s][a[j]]);
                s := M[j]!.transitions[s][a[j]];
            od;
            Add(o,Position(alphabet,b));
            Add(t,s);
        od;
        Add(trans,t);
        Add(out,o);
    od;
    a := MealyMachineNC(FRMFamily([1..Size(alphabet)]),trans,out);
    if ForAll(M,HasIsInvertible) then
        SetIsInvertible(a,ForAll(M,IsInvertible));
    fi;
    SET_NAME@(M,"(*)",a);
    return a;
end);

InstallMethod(TensorProductOp, "(FR) for generic FR machines",
        [IsList,IsFRMachine],
        function(M,N)
    M := List(M,ASINTREP@);
    return TensorProductOp(M,M[1]);
end);

InstallMethod(TensorSumOp, "(FR) for two Mealy machines",
        [IsList,IsMealyMachine and IsMealyMachineDomainRep],
        function(M,N)
    local a, d, trans, out;

    while ForAny(M,x->x!.states<>N!.states) do
        Error("All machines should have same stateset");
    od;
    d := Length(M);
    a := Domain(Union(List([1..d],i->Cartesian(AlphabetOfFRObject(M[i]),[i]))));
    trans := function(s,a)
        return M[a[2]]!.transitions(s,a[1]);
    end;
    out := function(s,a)
        return [M[a[2]]!.output(s,a[1]),a[2]];
    end;
    a := MealyMachine(N!.states,a,trans,out);
    if ForAll(M,HasIsInvertible) then
        SetIsInvertible(a,ForAll(M,IsInvertible));
    fi;
    SET_NAME@(M,"(+)",a);
    return a;
end);

InstallMethod(TensorSumOp, "(FR) for two integer Mealy machines",
        [IsList,IsMealyMachine and IsMealyMachineIntRep],
        function(M,N)
    local trans, out, t, o, a, d, i, j;

    while ForAny(M,x->x!.nrstates<>N!.nrstates) do
        Error("All machines should have same stateset");
    od;

    trans := [];
    out := [];
    for i in [1..N!.nrstates] do
        t := [];
        o := [];
        d := 0;
        for j in [1..Length(M)] do
            Append(t,M[j]!.transitions[i]);
            Append(o,M[j]!.output[i]+d);
            d := d+Size(AlphabetOfFRObject(M[j]));
        od;
        Add(trans,t);
        Add(out,o);
    od;
    a := MealyMachineNC(FRMFamily([1..d]),trans,out);
    if ForAll(M,HasIsInvertible) then
        SetIsInvertible(a,ForAll(M,IsInvertible));
    fi;
    SET_NAME@(M,"(+)",a);
    return a;
end);

InstallMethod(TensorSumOp, "(FR) for generic FR machines",
        [IsList,IsFRMachine],
        function(M,N)
    M := List(M,ASINTREP@);
    return TensorSumOp(M,M[1]);
end);

InstallMethod(DirectSumOp, "(FR) for two Mealy machines",
        [IsList,IsMealyMachine and IsMealyMachineDomainRep],
        function(M,N)
    local a, s, d, trans, out;

    d := Length(M);
    a := Domain(Union(List([1..d],i->Cartesian(AlphabetOfFRObject(M[i]),[i]))));
    s := Domain(Union(List([1..d],i->Cartesian(M[i]!.states,[i]))));
    trans := function(s,a)
        if s[2]=a[2] then
            return [M[s[2]]!.transitions(s[1],a[1]),s[2]];
        else
            return s;
        fi;
    end;
    out := function(s,a)
        if s[2]=a[2] then
            return [M[s[2]]!.output(s[1],a[1]),s[2]];
        else
            return a;
        fi;
    end;
    a := MealyMachine(s,a,trans,out);
    if ForAll(M,HasIsInvertible) then
        SetIsInvertible(a,ForAll(M,IsInvertible));
    fi;
    SET_NAME@(M,"(+)",a);
    return a;
end);

InstallMethod(DirectSumOp, "(FR) for two integer Mealy machines",
        [IsList,IsMealyMachine and IsMealyMachineIntRep],
        function(M,N)
    local trans, out, t, o, a, d, i, j, ashift, sshift, alphabet;

    d := 0;
    ashift := [];
    alphabet := [];
    for i in [1..Length(M)] do
        j := Length(AlphabetOfFRObject(M[i]));
        Add(ashift,[d+1..d+j]);
        d := d + j;
    od;

    trans := [];
    out := [];
    for i in [1..Length(M)] do
        sshift := Length(trans);
        for j in [1..M[i]!.nrstates] do
            t := ListWithIdenticalEntries(d,sshift+j);
            t{ashift[i]} := sshift+M[i]!.transitions[j];
            o := [1..d];
            o{ashift[i]} := ashift[i]{M[i]!.output[j]};
            Add(trans,t);
            Add(out,o);
        od;
    od;
    a := MealyMachineNC(FRMFamily([1..d]),trans,out);
    if ForAll(M,HasIsInvertible) then
        SetIsInvertible(a,ForAll(M,IsInvertible));
    fi;
    SET_NAME@(M,"#",a);
    return a;
end);

InstallMethod(DirectSumOp, "(FR) for generic FR machines",
        [IsList,IsFRMachine],
        function(M,N)
    M := List(M,ASINTREP@);
    return DirectSumOp(M,M[1]);
end);

InstallMethod(DirectProductOp, "(FR) for two Mealy machines",
        [IsList,IsMealyMachine and IsMealyMachineDomainRep],
        function(M,N)
    local a, s, d, trans, out;

    d := Length(M);
    a := Domain(Cartesian(List(M,AlphabetOfFRObject)));
    s := Domain(Cartesian(List(M,StateSet)));
    trans := function(s,a)
        return List([1..d],i->M[i]!.transitions(s[i],a[i]));
    end;
    out := function(s,a)
        return List([1..d],i->M[i]!.output(s[i],a[i]));
    end;
    a := MealyMachine(s,a,trans,out);
    if ForAll(M,HasIsInvertible) then
        SetIsInvertible(a,ForAll(M,IsInvertible));
    fi;
    SET_NAME@(M,"@",a);
    return a;
end);

InstallMethod(DirectProductOp, "(FR) for two integer Mealy machines",
        [IsList,IsMealyMachine and IsMealyMachineIntRep],
        function(M,N)
    local states, alphabet, trans, out, t, o, i, j, a, b, s;

    states := Cartesian(List(M,StateSet));
    alphabet := Cartesian(List(M,AlphabetOfFRObject));

    trans := [];
    out := [];
    for i in states do
        t := [];
        o := [];
        for a in alphabet do
            s := [];
            b := [];
            for j in [1..Length(i)] do
                Add(s,M[j]!.transitions[i[j]][a[j]]);
                Add(b,M[j]!.output[i[j]][a[j]]);
            od;
            Add(t,Position(states,s));
            Add(o,Position(alphabet,b));
        od;
        Add(trans,t);
        Add(out,o);
    od;
    a := MealyMachineNC(FRMFamily([1..Length(alphabet)]),trans,out);
    if ForAll(M,HasIsInvertible) then
        SetIsInvertible(a,ForAll(M,IsInvertible));
    fi;
    SET_NAME@(M,"@",a);
    return a;
end);

InstallMethod(DirectProductOp, "(FR) for generic FR machines",
        [IsList,IsFRMachine],
        function(M,N)
    M := List(M,ASINTREP@);
    return DirectProductOp(M,M[1]);
end);

InstallMethod(TreeWreathProduct, "(FR) for two domain Mealy machines",
        [IsMealyMachine and IsMealyMachineDomainRep,
         IsMealyMachine and IsMealyMachineDomainRep, IsObject, IsObject],
        function(g,h,x0,y0)
    local alphabet, states, trans, out, m;

    alphabet := Domain(Cartesian(AlphabetOfFRObject(g),AlphabetOfFRObject(h)));
    while not [x0,y0] in alphabet do
        Error("(x0,y0) must be in the product of the machines' alphabets");
    od;
    states := Domain(Union(Cartesian(StateSet(g),[1,3]),Cartesian(StateSet(h),[2]),[true]));

    trans := function(s,a)
        if s[2]=1 and a=[x0,y0] then
            return s;
        elif s[2]=1 and a[2]=y0 then
            return [s[1],3];
        elif s[2]=2 and a[1]=x0 then
            return [Transition(h,s[1],a[2]),2];
        elif s[2]=3 and a[2]=y0 then
            return [Transition(g,s[1],a[1]),3];
        else
            return true;
        fi;
    end;
    out := function(s,a)
        if s[2]=2 then
            return [a[1],Output(h,s[1],a[2])];
        elif s[2]=3 and a[2]=y0 then
            return [Output(g,s[1],a[1]),a[2]];
        else
            return a;
        fi;
    end;
    m := MealyMachine(states,alphabet,trans,out);
    if HasIsInvertible(g) and HasIsInvertible(h) then
        SetIsInvertible(m,IsInvertible(g) and IsInvertible(h));
    fi;
    SET_NAME@([g,h],"~",m);
    return m;
end);

InstallMethod(TreeWreathProduct, "(FR) for two integer Mealy machines",
        [IsMealyMachine and IsMealyMachineIntRep,
         IsMealyMachine and IsMealyMachineIntRep, IsPosInt, IsPosInt],
        function(g,h,x0,y0)
    local alphabet, one, trans, out, t, o, i, j, m;

    alphabet := Cartesian(AlphabetOfFRObject(g),AlphabetOfFRObject(h));
    while not [x0,y0] in alphabet do
        Error("(x0,y0) must be in the product of the machines' alphabets");
    od;
    one := 2*g!.nrstates+h!.nrstates+1;

    trans := [];
    out := [];
    for i in [1..g!.nrstates] do
        t := [];
        o := [];
        for j in alphabet do
            if j=[x0,y0] then
                Add(t,i);
            elif j[2]=y0 then
                Add(t,i+g!.nrstates+h!.nrstates);
            else
                Add(t,one);
            fi;
            Add(o,Position(alphabet,j));
        od;
        Add(trans,t);
        Add(out,o);
    od;
    for i in [1..h!.nrstates] do
        t := [];
        o := [];
        for j in alphabet do
            if j[1]=x0 then
                Add(t,Transition(h,i,j[2])+g!.nrstates);
            else
                Add(t,one);
            fi;
            Add(o,Position(alphabet,[j[1],Output(h,i,j[2])]));
        od;
        Add(trans,t);
        Add(out,o);
    od;
    for i in [1..g!.nrstates] do
        t := [];
        o := [];
        for j in alphabet do
            if j[2]=y0 then
                Add(t,Transition(g,i,j[1])+g!.nrstates+h!.nrstates);
                Add(o,Position(alphabet,[Output(g,i,j[1]),y0]));
            else
                Add(t,one);
                Add(o,Position(alphabet,j));
            fi;
        od;
        Add(trans,t);
        Add(out,o);
    od;
    Add(trans,ListWithIdenticalEntries(Length(alphabet),one));
    Add(out,[1..Length(alphabet)]);

    m := Minimized(MealyMachineNC(FRMFamily([1..Length(alphabet)]),trans,out));
    m!.Correspondence := [Trans([1..g!.nrstates],Correspondence(m)),
                          Trans([1..h!.nrstates]+g!.nrstates,Correspondence(m))];
    if HasIsInvertible(g) and HasIsInvertible(h) then
        SetIsInvertible(m,IsInvertible(g) and IsInvertible(h));
    fi;
    SET_NAME@([g,h],"~",m);
    return m;
end);

InstallMethod(TreeWreathProduct, "for two generic FR machines",
        [IsFRMachine, IsFRMachine, IsObject, IsObject],
        function(g,h,x0,y0)
    return TreeWreathProduct(ASINTREP@(g),ASINTREP@(h),x0,y0);
    # !!! probably x0, y0 should be changed to their int counterparts?
end);
############################################################################

############################################################################
##
#M Products of Mealy elements
##
InstallMethod(\*, "(FR) for two Mealy elements", IsIdenticalObj,
        [IsMealyElement and IsMealyMachineDomainRep,
         IsMealyElement and IsMealyMachineDomainRep],
        function(M,N)
    local q, a, trans, out;
    q := Domain(Cartesian(M!.states,N!.states));
    trans := function(s,a)
        return [M!.transition(s[1],a),N!.transition(s[2],M!.output(s[1],a))];
    end;
    out := function(s,a)
        return N!.output(s[2],M!.output(s[1],a));
    end;
    a := MealyElement(q,AlphabetOfFRObject(M),trans,out,[M!.initial,N!.initial]);
    if HasIsInvertible(M) and HasIsInvertible(N) then
        SetIsInvertible(a,IsInvertible(M) and IsInvertible(N));
    fi;
    SET_NAME@([M,N],"*",a);
    return a;
end);

InstallMethod(\*, "(FR) for two Mealy elements", IsIdenticalObj,
        [IsMealyElement and IsMealyMachineIntRep,
         IsMealyElement and IsMealyMachineIntRep],
        function(M,N)
    local sdict, todo, a, i, x, t, tr, trans, out;

    if IsOne(M) then return N; elif IsOne(N) then return M; fi;

    sdict := NewDictionary([1,1],true);
    todo := [[M!.initial,N!.initial]];
    AddDictionary(sdict,[M!.initial,N!.initial],1);

    trans := [];
    out := [];
    for i in todo do
        tr := [];
        for a in AlphabetOfFRObject(M) do
            t := [M!.transitions[i[1]][a],N!.transitions[i[2]][M!.output[i[1]][a]]];
            x := LookupDictionary(sdict,t);
            if x=fail then
                Add(todo,t);
                x := Length(todo);
                AddDictionary(sdict,t,x);
            fi;
            Add(tr,x);
        od;
        Add(trans,tr);
        Add(out,N!.output[i[2]]{M!.output[i[1]]});
    od;
    a := MMMINIMIZE@(FamilyObj(M),AlphabetOfFRObject(M),
                 Length(trans),trans,out,1,1);
    if HasIsInvertible(M) and HasIsInvertible(N) then
        SetIsInvertible(a,IsInvertible(M) and IsInvertible(N));
    fi;
    return a;
end);

InstallMethod(\*, "(FR) for an FR element and a Mealy element",
        [IsFRElement, IsMealyElement],
        function(M,N)
    Info(InfoFR, 1, "\\*: converting second argument to FR element");
    return M*AsSemigroupFRElement(N);
end);

InstallMethod(\*, "(FR) for a Mealy element and an FR element",
        [IsMealyElement, IsFRElement],
        function(M,N)
    Info(InfoFR, 1, "\\*: converting first argument to FR element");
    return AsSemigroupFRElement(M)*N;
end);
############################################################################

############################################################################
##
#M Comparisons
##
InstallMethod(\<, "(FR) for an FR element and a Mealy element",
        [IsFRElement, IsMealyElement],
        function(M,N)
    Info(InfoFR, 1, "\\<: converting second argument to FR element");
    return M<AsSemigroupFRElement(N);
end);

InstallMethod(\<, "(FR) for a Mealy element and an FR element",
        [IsMealyElement, IsFRElement],
        function(M,N)
    Info(InfoFR, 1, "\\<: converting first argument to FR element");
    return AsSemigroupFRElement(M)<N;
end);

InstallMethod(\=, "(FR) for an FR element and a Mealy element",
        [IsFRElement, IsMealyElement],
        function(M,N)
    Info(InfoFR, 1, "\\=: converting second argument to FR element");
    return M=AsSemigroupFRElement(N);
end);

InstallMethod(\=, "(FR) for a Mealy element and an FR element",
        [IsMealyElement, IsFRElement],
        function(M,N)
    Info(InfoFR, 1, "\\=: converting first argument to FR element");
    return AsSemigroupFRElement(M)=N;
end);
############################################################################

############################################################################
##
#M  Inverse . . . . . . . . . . . . . . . . . . . . . . invert Mealy machine
#M  One . . . . . . . . . . . . . . . . . . . . . .identity of Mealy machine
##
InstallMethod(IsInvertible, "(FR) for a Mealy machine",
        [IsMealyMachine and IsMealyMachineIntRep],
        M->ForAll(StateSet(M),i->ISINVERTIBLE@(M!.output[i])));

InstallMethod(IsInvertible, "(FR) for a Mealy element",
        [IsMealyElement and IsMealyMachineIntRep],
        M->ForAll(StateSet(M),i->ISINVERTIBLE@(M!.output[i])));

InstallMethod(IsGeneratorsOfMagmaWithInverses, "(FR) for a list of Mealy elements",
        [IsFRElementCollection],
        function(l)
    local i;
    for i in l do
        if not IsInvertible(i) then
            return false;
        fi;
    od;
    return true;
end);

BindGlobal("SETINVERSENAME@", function(M,N)
    local n;
    if HasName(N) then
        n := Name(N);
        if not ForAll(n,IsAlphaChar) then
            n := Concatenation("(",n,")");
        fi;
        if HasOrder(N) and Order(N)<infinity then
            SetName(M,Concatenation(n,"^",String(Order(N)-1)));
        else SetName(M,Concatenation(n,"^-1")); fi;
    fi;
end);

InstallMethod(InverseOp, "(FR) for a Mealy machine",
        [IsMealyMachine],
        function(M)
    local s, out;
    if not IsInvertible(M) then return fail; fi;
    if HasOrder(M) and Order(M) = 2 then return M; fi;

    out := List(M!.output,INVERSE@);
    s := MealyMachineNC(FamilyObj(M),
                 List([1..M!.nrstates], i->M!.transitions[i]{out[i]}),
                 out);
    SetInverse(M,s); SetInverse(s,M);
    if HasOrder(M) then SetOrder(s,Order(M)); fi;
    SETINVERSENAME@(s,M);
    return s;
end);

InstallMethod(InverseOp, "(FR) for a Mealy element",
        [IsMealyElement],
        function(E)
    local s, out;
    if not IsInvertible(E) then return fail; fi;
    if HasOrder(E) and Order(E) = 2 then return E; fi;

    out := List(E!.output,INVERSE@);
    s := MMMINIMIZE@(FamilyObj(E),AlphabetOfFRObject(E),
                 E!.nrstates,
                 List([1..E!.nrstates],i->E!.transitions[i]{out[i]}),
                 out,
                 E!.initial,2);
    SetInverse(E,s); SetInverse(s,E);
    if HasOrder(E) then SetOrder(s,Order(E)); fi;
    SETINVERSENAME@(s,E);
    return s;
end);

InstallMethod(OneOp, "(FR) compute identity of Mealy element",
        [IsMealyElement and IsMealyMachineIntRep], 1,
        function(E)
    return MealyElementNC(FamilyObj(E),[List(AlphabetOfFRObject(E),i->1)],[AlphabetOfFRObject(E)],1);
end);

InstallMethod(OneOp, "(FR) compute identity of Mealy machine",
        [IsMealyMachine and IsMealyMachineIntRep],
        function(M)
    return MealyMachineNC(FamilyObj(M),[List(AlphabetOfFRObject(M),i->1)],[AlphabetOfFRObject(M)]);
end);

InstallMethod(OneOp, "(FR) for a Mealy machine in domain rep",
        [IsMealyMachine and IsMealyMachineDomainRep],
        function(M)
    return MealyMachine(Domain([1]), AlphabetOfFRObject(M),
                   function(s,a) return s; end, function(s,a) return a; end);
end);

InstallMethod(OneOp, "(FR) for a Mealy element in domain rep",
        [IsMealyElement and IsMealyMachineDomainRep],
        function(E)
    return MealyElement(Domain([1]), AlphabetOfFRObject(E),
                   function(s,a) return s; end,function(s,a) return a; end, 1);
end);

InstallMethod(ZeroOp, "(FR) compute trivial Mealy machine",
        [IsMealyMachine],
        function(M)
    return MealyMachineNC(FamilyObj(M),[],[]);
end);
############################################################################

############################################################################
##
#M  DualMachine
#P  IsReversible
#P  IsBireversible
##
BindGlobal("ALPHABETINVOLUTION@", function(N)
    local l;
    l := List(StateSet(N),x->FRElement(N,x));
    l := List(l,x->Position(l,x^-1));
    if fail in l then return fail; fi;
    return l;
end);

InstallMethod(DualMachine, "(FR) for a Mealy machine in int rep",
        [IsMealyMachine and IsMealyMachineIntRep],
        function(M)
    local N, l;
    N := MealyMachineNC(FRMFamily(StateSet(M)),
                 TransposedMat(M!.output),
                 TransposedMat(M!.transitions));
    if HasAlphabetInvolution(M) then
        l := ALPHABETINVOLUTION@(M);
        if l<>fail then
            SetAlphabetInvolution(N,l);
        fi;
    fi;
    return N;
end);

InstallMethod(DualMachine, "(FR) for a Mealy machine in domain rep",
        [IsMealyMachine and IsMealyMachineDomainRep],
        function(M)
    return MealyMachine(StateSet(M),AlphabetOfFRObject(M),
                   function(s,a) return M!.output(a,s); end,
                     function(s,a) return M!.transitions(a,s); end);
end);

InstallMethod(IsReversible, "(FR) for a Mealy machine",
        [IsMealyMachine],
        function(M)
    return IsInvertible(DualMachine(M));
end);

InstallMethod(IsBireversible, "(FR) for a Mealy machine",
        [IsFRMachine],
        function(M)
    local Minv;
    Minv := Inverse(M);
    return Minv<>fail and IsReversible(M) and IsReversible(Minv);
end);

InstallTrueMethod(IsReversible, IsBireversible);
InstallTrueMethod(IsInvertible, IsBireversible);

InstallMethod(AlphabetInvolution, "(FR) for a bireversible Mealy machine",
        [IsMealyMachine],
        function(M)
    if not IsBireversible(M) then
        return fail;
    fi;
    return ALPHABETINVOLUTION@(DualMachine(M));
end);

InstallMethod(IsMinimized, "(FR) for a Mealy machine",
        [IsMealyMachine and IsMealyMachineIntRep],
        function(M)
    return MMMINIMIZE@(FamilyObj(M),AlphabetOfFRObject(M),
        M!.nrstates,M!.transitions,M!.output,fail,0)!.nrstates=M!.nrstates;
end);

InstallTrueMethod(IsMinimized, IsMealyElement and IsMealyMachineIntRep);
############################################################################

############################################################################
##
#M  StateGrowth
##
BindGlobal("STATEGROWTH@", function(M,z)
    local src, mat, dest, s, a, is, it, enum;
    src := [];
    enum := Enumerator(StateSet(M));
    mat := IdentityMat(Size(enum))*z^0;
    dest := [];
    for s in enum do
        if IsMealyElement(M) and s <> InitialState(M) then
            Add(src,0);
        else
            Add(src,1);
        fi;
        if IsOne(FRElement(M,s)) then Add(dest,0); else Add(dest,1); fi;
        is := Position(enum,s);
        for a in AlphabetOfFRObject(M) do
            it := Position(enum,Transition(M,s,a));
            mat[is][it] := mat[is][it]-z;
        od;
    od;
    return src*Inverse(mat)*dest;
end);

InstallMethod(StateGrowth, "(FR) for a Mealy machine and an indeterminate",
        [IsMealyMachine, IsRingElement],
        STATEGROWTH@);

InstallMethod(StateGrowth, "(FR) for a Mealy element and an indeterminate",
        [IsMealyElement, IsRingElement],
        STATEGROWTH@);

InstallMethod(StateGrowth, "(FR) for a FR machine and an indeterminate",
        [IsFRMachine, IsRingElement],
        function(M,z)
    Info(InfoFR, 1, "StateGrowth: converting to Mealy machine");
    return StateGrowth(ASINTREP@(M),z);
end);

InstallMethod(StateGrowth, "(FR) for a FR element and an indeterminate",
        [IsFRElement, IsRingElement],
        function(M,z)
    Info(InfoFR, 1, "StateGrowth: converting to Mealy element");
    return StateGrowth(ASINTREP@(M),z);
end);

InstallMethod(StateGrowth, "(FR) for a FR object",
        [IsFRObject],
        function(M)
    return StateGrowth(M,Indeterminate(Rationals));
end);

BindGlobal("DEGREE_MEALYME@", function(M)
    local d, e, f, i, j, k, fM;
    M := Minimized(M);
    if IsOne(M) then return -1; fi;
    fM := BinaryRelationOnPointsNC(M!.transitions);
    f := StronglyConnectedComponents(fM);
    e := EquivalenceClasses(f);
    for i in e do
        if Size(i)=1 then
            j := Representative(i);
            if ISONE@(M!.output[j]) and
               ForAll(M!.transitions[j],k->k=j) then
                continue; # is identity element
            fi;
        fi;
        d := [];
        for j in i do d[j] := 0; od;
        for j in i do
            for k in M!.transitions[j] do
                if k in i then d[k] := d[k]+1; fi;
            od;
        od;
        if ForAny(d,x->x>=2) then return infinity; fi;
    od;
    d := [];
    for i in [1..Length(e)] do for j in e[i] do d[j] := i; od; od;
    i := List(e,i->[]);
    for j in StateSet(M) do for k in AlphabetOfFRObject(M) do
        Add(i[d[j]],d[M!.transitions[j][k]]);
    od; od;
    f := TransitiveClosureBinaryRelation(BinaryRelationOnPointsNC(i));
    d := Filtered([1..Length(e)],x->x in Images(f,x));
    e := [];
    while d<>[] do
        Add(e,Filtered(d,x->Intersection(Images(f,x),d)=[x]));
        d := Difference(d,e[Length(e)]);
    od;
    return Length(e)-1;
end);
InstallMethod(DegreeOfFRMachine, "(FR) for a Mealy machine",
        [IsMealyMachine and IsMealyMachineIntRep],
        DEGREE_MEALYME@);
InstallMethod(DegreeOfFRMachine, "(FR) for an FR machine",
        [IsFRMachine],
        function(M)
    Info(InfoFR, 1, "Degree: converting to Mealy machine");
    return DEGREE_MEALYME@(ASINTREP@(M));
end);
InstallMethod(DegreeOfFRElement, "(FR) for a Mealy element",
        [IsMealyElement and IsMealyMachineIntRep],
        DEGREE_MEALYME@);
InstallMethod(DegreeOfFRElement, "(FR) for an FR element",
        [IsFRElement],
        function(E)
    Info(InfoFR, 1, "Degree: converting to Mealy element");
    return DEGREE_MEALYME@(ASINTREP@(E));
end);
InstallMethod(Degree, [IsFRMachine], DegreeOfFRMachine);
InstallMethod(Degree, [IsFRElement], DegreeOfFRElement);

BindGlobal("DEPTH_MEALYME@", function(M)
    local i, j, f, fM, one, d, todo;
    if IsOne(M) then return 0; fi;
    M := Minimized(M);
    one := First(StateSet(M),s->IsOne(FRElement(M,s)));
    if one=fail then return infinity; fi;
    fM := BinaryRelationOnPointsNC(M!.transitions);
    f := TransitiveClosureBinaryRelation(fM);
    for i in StateSet(M) do
        if i<>one and i in Images(f,i) then return infinity; fi;
    od;
    d := List(StateSet(M),s->0);
    todo := [one];
    for i in todo do
        for j in PreImages(fM,i) do if j <> one then
            if d[j]<=d[i] then
                d[j] := d[i]+1;
                Add(todo,j);
            fi;
        fi; od;
    od;
    if IsMealyElement(M) then
        return d[M!.initial];
    else
        return Maximum(d);
    fi;
end);
InstallMethod(DepthOfFRMachine, "(FR) for a Mealy machine",
        [IsMealyMachine and IsMealyMachineIntRep],
        DEPTH_MEALYME@);
InstallMethod(DepthOfFRMachine, "(FR) for an FR machine",
        [IsFRMachine],
        function(M)
    Info(InfoFR, 1, "Depth: converting to Mealy machine");
    return DEPTH_MEALYME@(ASINTREP@(M));
end);
InstallMethod(DepthOfFRElement, "(FR) for a Mealy element",
        [IsMealyElement and IsMealyMachineIntRep],
        DEPTH_MEALYME@);
InstallMethod(DepthOfFRElement, "(FR) for an FR element",
        [IsFRElement],
        function(E)
    Info(InfoFR, 1, "Depth: converting to Mealy element");
    return DEPTH_MEALYME@(ASINTREP@(E));
end);
InstallMethod(Depth, [IsFRMachine], DepthOfFRMachine);
InstallMethod(Depth, [IsFRElement], DepthOfFRElement);

InstallMethod(IsFinitaryFRMachine, "(FR) for an FR machine",
        [IsFRMachine],
        M->DegreeOfFRMachine(M)<=0);
InstallMethod(IsFinitaryFRElement, "(FR) for an FR element",
        [IsFRElement],
        M->DegreeOfFRElement(M)<=0);

InstallMethod(IsBoundedFRMachine, "(FR) for an FR machine",
        [IsFRMachine],
        M->DegreeOfFRMachine(M)<=1);
InstallMethod(IsBoundedFRElement, "(FR) for an FR element",
        [IsFRElement],
        M->DegreeOfFRElement(M)<=1);

InstallMethod(IsPolynomialGrowthFRMachine, "(FR) for an FR machine",
        [IsFRMachine],
        M->DegreeOfFRMachine(M)<infinity);
InstallMethod(IsPolynomialGrowthFRElement, "(FR) for an FR element",
        [IsFRElement],
        M->DegreeOfFRElement(M)<infinity);

InstallTrueMethod(IsFiniteStateFRMachine, IsMealyMachine);
InstallTrueMethod(IsFiniteStateFRElement, IsMealyElement);
InstallTrueMethod(IsBoundedFRElement, IsFinitaryFRElement);
InstallTrueMethod(IsBoundedFRMachine, IsFinitaryFRMachine);
InstallTrueMethod(IsPolynomialGrowthFRElement, IsBoundedFRElement);
InstallTrueMethod(IsPolynomialGrowthFRMachine, IsBoundedFRMachine);
InstallTrueMethod(IsFiniteStateFRElement, IsPolynomialGrowthFRElement);
InstallTrueMethod(IsFiniteStateFRMachine, IsPolynomialGrowthFRMachine);
############################################################################

############################################################################
##
#M  Guess Mealy machine
##
BindGlobal("SHRINKPERM@", function(perm,d,n)
    local l, m;

    l := ListTrans(perm,d^n);
    m := List(l{d*[1..d^(n-1)]},x->1+QuoInt(x-1,d));

    if ForAny([1..d^n],i->1+QuoInt(l[i]-1,d)<>m[1+QuoInt(i-1,d)]) then
        return fail;
    fi;
    if IsTransformation(perm) then
        return Transformation(m);
    else
        return TransList(m);
    fi;
end);

BindGlobal("DECOMPPERM@", function(perm,d,n)
    local l, m, i, trans, out;

    l := ListTrans(perm,d^n);
    trans := [];
    out := [];
    for i in [1..d] do
        m := l{[1..d^(n-1)]+(i-1)*d^(n-1)};
        Add(out,1+QuoInt(m[1]-1,d^(n-1)));
        if ForAny(m,x->1+QuoInt(x-1,d^(n-1))<>out[i]) then
            return fail;
        fi;
        Add(trans,m-d^(n-1)*(out[i]-1));
    od;
    if IsTransformation(perm) then
        return [List(trans,Transformation),Transformation(out)];
    else
        return [List(trans,Trans),Trans(out)];
    fi;
end);

InstallOtherMethod(GuessMealyElement, "(FR) for a perm/trans, degree and depth",
        [IsObject, IsPosInt, IsInt],
        function(perm,d,n)
    local trans, out, level, s, i, j, k, x, dec;

    trans := [];
    out := [];
    level := [n];
    s := [];
    for i in [n,n-1..1] do
        s[i] := [perm];
        perm := SHRINKPERM@(perm,d,i);
    od;
    i := 1;
    while i<=Length(level) do
        if level[i]=1 then
            return fail; # refuse to guess
        fi;
        Add(trans,[]);
        dec := DECOMPPERM@(s[level[i]][i],d,level[i]);
        Add(out,dec[2]);
        for j in [1..d] do
            x := Position(s[level[i]-1],dec[1][j]);
            if x=fail then
                if level[i]=1 then return fail; fi;
                Add(level,level[i]-1);
                for k in [level[i]-1,level[i]-2..1] do
                    Add(s[k],dec[1][j]);
                    dec[1][j] := SHRINKPERM@(dec[1][j],d,k);
                od;
                x := Length(level);
            elif Position(s[level[i]-1],dec[1][j],x)<>fail then
                return fail; # more than 1 match
            fi;
            Add(trans[i],x);
        od;
        i := i+1;
    od;
    return MealyElement(trans,out,1);
end);
############################################################################

############################################################################
##
#M  Signatures, transitivity, order
##
InstallMethod(Signatures, "(FR) for a Mealy element",
        [IsMealyElement and IsMealyMachineIntRep],
        function(E)
    local mat, dest, a, s, t;
    mat := 0*IdentityMat(E!.nrstates);
    dest := [];
    for s in [1..E!.nrstates] do
        for t in E!.transitions[s] do
            mat[s][t] := mat[s][t]+1;
        od;
        Add(dest,Trans(E!.output[s]));
    od;
    a := [];
    repeat
        Add(a,dest);
        dest := List([1..Length(dest)],i->Product([1..Length(dest)],j->dest[j]^mat[i][j]));
    until dest in a;
    return CompressedPeriodicList(
                   List(a,v->v[Position(StateSet(E),InitialState(E))]),
                   Position(a,dest));
end);
INSTALLMEHANDLER@(Signatures,true);

InstallMethod(VertexTransformationsFRMachine, "(FR) for an FR machine",
        [IsFRMachine],
        function(M)
    local t;
    t := List(GeneratorsOfFRMachine(M),s->Output(M,s));
    if ForAll(t,ISINVERTIBLE@) then
        return Group(List(t,PermList));
    else
        return Monoid(List(t,Transformation));
    fi;
end);

InstallMethod(VertexTransformationsFRElement, "(FR) for an FR element",
        [IsFRElement],
        E->VertexTransformationsFRMachine(UnderlyingFRMachine(E)));

InstallMethod(IsLevelTransitive, "(FR) for an FR element",
        [IsFRElement], 10, # easy
        function(E)
    if not IsAbelian(VertexTransformationsFRElement(E)) then
        TryNextMethod();
    else
        return ForAll(Flat(Signatures(E)),x->IsTransitive(Group(x),AlphabetOfFRObject(E)));
    fi;
end);

InstallMethod(IsLevelTransitive, "(FR) for a Mealy element",
        [IsMealyElement],
        function(E)
    local seen, d, c;
    seen := NewDictionary(E,false);
    while not KnowsDictionary(seen,E) do
        AddDictionary(seen,E);
        d := DecompositionOfFRElement(E); # could improve by reducing E by conjugation
        c := Cycle(PermList(d[2]),AlphabetOfFRObject(E),Representative(AlphabetOfFRObject(E)));
        if Set(c)<>AlphabetOfFRObject(E) then
            return false;
        fi;
        E := Product(d[1]{c});
    od;
    return true;
end);
############################################################################

#############################################################################
##
#F AllMealyMachines
##
InstallGlobalFunction(AllMealyMachines,
        function(arg)
    local m, n, filters, vertex, creator, trans, out, F, t, o,
          proja, projs, list;
    m := arg[1];
    n := arg[2];
    filters := arg{[3..Length(arg)]};
    if IsBireversible in filters then
        Append(filters,[IsInvertible,IsReversible]);
    fi;
    vertex := PositionProperty(filters,IsSemigroup);
    if vertex=fail then
        if IsInvertible in filters then
            vertex := SymmetricGroup(m);
        else
            vertex := FullTransformationSemigroup(m);
        fi;
    else
        vertex := Remove(filters,vertex);
    fi;
    if IsGroup(vertex) then
        creator := T->Group(List(T,PermList));
    elif IsMonoid(vertex) then
        creator := T->Monoid(List(T,Transformation));
    else
        creator := T->Semigroup(List(T,Transformation));
    fi;
    if IsReversible in filters then
        Remove(filters,Position(filters,IsReversible));
        trans := List(Tuples(Arrangements([1..n],n),m),TransposedMat);
    else
        trans := Tuples(Tuples([1..n],m),n);
    fi;
    out := [];
    for o in vertex do
        if IsTrans(o) then
            Add(out,ListTrans(o,m));
        elif IsTransformation(o) then
            Add(out,ImageListOfTransformation(o));
        else
            Add(out,ListPerm(o,m));
        fi;
    od;
    out := Tuples(out,n);
    if IsTransitive in filters then
        Remove(filters,Position(filters,IsTransitive));
        out := Filtered(out,function(T)
            local rel;
            rel := BinaryRelationOnPointsNC(TransposedMat(T));
            rel := StronglyConnectedComponents(rel);
            return Length(EquivalenceClasses(rel))=1;
        end);
    elif IsSurjective in filters then
        Remove(filters,Position(filters,IsSurjective));
        out := Filtered(out,T->Size(creator(T))=Size(vertex));
    fi;
    if IsBireversible in filters then
        Remove(filters,Position(filters,IsBireversible));
        F := [];
        for t in trans do for o in out do
            if ForAll(TransposedMat(List([1..n],i->t[i]{o[i]})),
                      r->Set(r)=[1..n]) then
                Add(F,[t,o]);
            fi;
        od; od;
    else
        F := Cartesian(trans,out);
    fi;
    list := EquivalenceClasses in filters;
    if list then
        Remove(filters,Position(filters,EquivalenceClasses));
        o := DirectProduct(SymmetricGroup(m),SymmetricGroup(n));
        proja := Projection(o,1);
        projs := Projection(o,2);
        F := List(Orbits(o,F,function(M,g)
            local ga, gs;
            ga := g^proja;
            gs := g^projs;
            return [Permuted(List(M[1],r->List(Permuted(r,ga),i->i^gs)),gs),
                    Permuted(List(M[2],r->List(Permuted(r,ga),i->i^ga)),gs)];
        end),Set);
    fi;
    if InverseClasses in filters then
        Remove(filters,Position(filters,InverseClasses));
        if not list then
            F := List(F,x->[x]);
            list := true;
        fi;
        F := List(Orbits(SymmetricGroup(2),F,function(ML,g)
            if IsOne(g) or not ForAll(ML,M->ForAll(M[2],ISINVERTIBLE@)) then
                return ML;
            else
                return Set(ML,M->[List([1..Length(M[1])],i->M[1][i]{M[2][i]}),
                               List(M[2],INVERSE@)]);
            fi;
        end),Representative);
    fi;
    if list then
        F := List(F,Representative);
    fi;
    m := FRMFamily([1..m]);
    F := List(F,p->MealyMachineNC(m,p[1],p[2]));
    for o in filters do
        F := Filtered(F,o);
    od;
    return F;
end);
#############################################################################

#############################################################################
##
#M ConfinalityClasses
##
InstallMethod(ConfinalityClasses, "(FR) for a Mealy element",
        [IsMealyElement and IsMealyMachineIntRep],
        function(E)
    local recur, classes, states, source, dest, one;
    if not IsBoundedFRElement(E) then return fail; fi;
    one := First(StateSet(E),s->IsOne(FRElement(E,s)));
    recur := function(s)
        local a, i;
        if s=one then return; fi;

        i := Position(states,s);
        if i=fail then
            Add(states,s);
            for a in AlphabetOfFRObject(E) do
                Add(source,a); Add(dest,Output(E,s,a));
                recur(Transition(E,s,a));
                Remove(source); Remove(dest);
            od;
            Remove(states);
        else
            i := [ConfinalityClass(PeriodicList(source,i)),
                  ConfinalityClass(PeriodicList(dest,i))];
            if i[1]<>i[2] then
                Add(classes,i);
            fi;
        fi;
    end;
    classes := [];
    states := []; source := []; dest := [];
    recur(InitialState(E));
    if classes=[] then return []; fi;
    one := Domain(Set(Concatenation(classes)));
    one := EquivalenceRelationByPairs(one,classes);
    return EquivalenceClasses(one);
end);
INSTALLMEHANDLER@(ConfinalityClasses,true);

InstallMethod(Germs, "(FR) for a Mealy element",
        [IsMealyElement],
        function(E)
    local recur, classes, states, path, one;
    if not IsBoundedFRElement(E) then return fail; fi;
    one := First(StateSet(E),s->IsOne(FRElement(E,s)));
    recur := function(s)
        local a, i;
        if s=one then return; fi;

        i := Position(states,s);
        if i=fail then
            Add(states,s);
            for a in AlphabetOfFRObject(E) do
                Add(path,a);
                recur(Transition(E,s,a));
                Remove(path);
            od;
            Remove(states);
        else
            Add(classes,[CompressedPeriodicList(path,i),
                    CompressedPeriodicList(states,i)]);
        fi;
    end;
    classes := [];
    states := []; path := [];
    recur(InitialState(E));
    return classes;
end);
INSTALLMEHANDLER@(Germs,true);

InstallMethod(NormOfBoundedFRElement, "(FR) for a Mealy element",
        [IsMealyElement],
        function(E)
    local recur, states, one;
    if not IsBoundedFRElement(E) then return infinity; fi;
    one := First(StateSet(E),s->IsOne(FRElement(E,s)));
    recur := function(s)
        local a, i, n;
        if s=one then
            return 0;
        fi;
        n := 0;
        i := PositionSorted(states,s);
        if IsBound(states[i]) and states[i]=s then
            n := n+1;
        else
            Add(states,s,i);
            for a in AlphabetOfFRObject(E) do
                n := n + recur(Transition(E,s,a));
            od;
            Remove(states,i);
        fi;
        return n;
    end;
    states := [];
    return recur(InitialState(E));
end);
INSTALLMEHANDLER@(NormOfBoundedFRElement,true);

InstallMethod(HasOpenSetConditionFRElement, "(FR) for a Mealy element",
        [IsMealyElement],
        function(E)
    local g;
    if not IsBoundedFRElement(E) then
        TryNextMethod();     # triggers an 'method not found' error
    fi;
    for g in Germs(E) do
        if g[1]^E=g[1] then return false; fi;
    od;
    return true;
end);
INSTALLMEHANDLER@(HasOpenSetConditionFRElement,true);

InstallMethod(IsWeaklyFinitaryFRElement, "(FR) for a Mealy element",
        [IsMealyElement],
        function(E)
    local c;
    c := ConfinalityClasses(E);
    return c<>fail and c=[];
end);
INSTALLMEHANDLER@(IsWeaklyFinitaryFRElement,true);
#############################################################################

#############################################################################
##
#M LimitFRMachine
#M NucleusMachine
##
InstallMethod(LimitFRMachine, "(FR) for a Mealy machine",
        [IsMealyMachine and IsMealyMachineIntRep],
        function(M)
    local S, pos, i;
    S := MEALYLIMITSTATES@(M);
    pos := [];
    pos{S} := [1..Length(S)];
    return MealyMachineNC(FamilyObj(M),List(M!.transitions{S},r->List(r,i->pos[i])),M!.output{S});
end);
INSTALLMMHANDLER@(LimitFRMachine,true);

InstallMethod(NucleusMachine, "(FR) for an FR machine",
        [IsFRMachine],
        function(M)
    local N, oldN, oldsize, size;
    M := LimitFRMachine(M);
    N := M;
    size := Size(StateSet(N));
    repeat
        oldN := N;
        oldsize := size;
        N := Minimized(LimitFRMachine(N*M));
        size := Size(StateSet(N));
        if size=oldsize then return oldN; fi;
        Info(InfoFR, 2, "NucleusMachine: at least ",size," states");
    until false;
end);
#############################################################################

#E mealy.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
