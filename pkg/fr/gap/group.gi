#############################################################################
##
#W group.gi                                                 Laurent Bartholdi
##
#H   @(#)$Id: group.gi,v 1.86 2011/11/15 16:20:07 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  This file implements the category of functionally recursive groups.
##
#############################################################################

#############################################################################
##
#O SEARCH@
##
InstallValue(SEARCH@, rec(depth := 6, volume := 5000));

SEARCH@.DEPTH := function()
    local v;
    v := ValueOption("FRdepth");
    if v=fail then return SEARCH@.depth; else return v; fi;
end;

SEARCH@.VOLUME := function()
    local v;
    v := ValueOption("FRvolume");
    if v=fail then return SEARCH@.volume; else return v; fi;
end;

SEARCH@.BALL := 1;
SEARCH@.QUOTIENT := 2;

SEARCH@.INIT := function(G)
    # initializes search structure, stored in semigroup G
    if IsBound(G!.FRData) then return; fi;
    if IsFRGroup(G) then
        G!.FRData := rec(pifunc := EpimorphismPermGroup,
    sphere := [[One(G)],Difference(Set(Union(GeneratorsOfGroup(G),List(GeneratorsOfGroup(G),Inverse))),[One(G)])]);
    elif IsFRMonoid(G) then
        G!.FRData := rec(pifunc := EpimorphismTransformationMonoid,
    sphere := [[One(G)],Difference(Set(GeneratorsOfSemigroup(G)),[One(G)])]);
    elif IsFRSemigroup(G) then
        G!.FRData := rec(pifunc := EpimorphismTransformationSemigroup,
                         sphere := [[],Set(GeneratorsOfSemigroup(G))]);
    fi;
    G!.FRData.radius := 1;
    G!.FRData.runtimes := [0,0];
    G!.FRData.level := 0;
    G!.FRData.pi := G!.FRData.pifunc(G,0);
    G!.FRData.volume := Sum(List(G!.FRData.sphere,Length));
    G!.FRData.index := Size(Image(G!.FRData.pi));
    if IsFRGroup(G) and (HasIsBoundedFRSemigroup(G) or ForAll(GeneratorsOfGroup(G),IsMealyElement)) and IsBoundedFRSemigroup(G) and not IsFinitaryFRSemigroup(G) then
        G!.FRData.pifunc := EpimorphismGermGroup;
    fi;
end;

SEARCH@.RESET := function(G)
    Unbind(G!.FRData);
end;

SEARCH@.ERROR := function(G,str)
    # allow user to increase the search limits
    local obm, volume, depth;
    obm := OnBreakMessage;
    volume := fail; depth := fail;
    OnBreakMessage := function()
        Print("current limits are (volume = ",SEARCH@.VOLUME(),
              ", depth = ",SEARCH@.DEPTH(),")\n",
              "to increase search volume, type 'volume := <value>; return;'\n",
              "to increase search depth, type 'depth := <value>; return;'\n",
              "type 'quit;' if you want to abort the computation.\n");
        OnBreakMessage := obm;
    end;
    Error("Search for ",G," reached its limits in function ",str,"\n");
    if volume <> fail then PushOptions(rec(FRvolume := volume)); fi;
    if depth <> fail then PushOptions(rec(FRdepth := depth)); fi;
end;

SEARCH@.EXTEND := function(arg)
    # extend the search structure. argument1 is a group; argument2 is optional,
    # and is SEARCH@.BALL to extend search ball radius,
    # and is SEARCH@.QUOTIENT to extend search depth.
    # returns fail if the search limits do not allow extension.
    local i, j, k, l, d, r, strategy;
    d := arg[1]!.FRData;
    if Length(arg)=2 then
        strategy := [arg[2]];
    else
        strategy := [SEARCH@.BALL,SEARCH@.QUOTIENT]; fi;
    if d.volume>=SEARCH@.VOLUME() then
        strategy := Difference(strategy,[SEARCH@.BALL]);
    fi;
    if d.level>=SEARCH@.DEPTH() then
        strategy := Difference(strategy,[SEARCH@.QUOTIENT]);
    fi;
    if Length(strategy)=0 then
        return fail;
    elif Length(strategy)=1 then
        strategy := strategy[1];
    else
        if Maximum(d.runtimes)>5*Minimum(d.runtimes) then
            # at least 20% on each strategy
            strategy := Position(d.runtimes,Minimum(d.runtimes));
        elif d.index > d.volume^2 then
            strategy := SEARCH@.BALL;
        else
            strategy := SEARCH@.QUOTIENT;
        fi;
    fi;
    r := Runtime();
    if strategy=SEARCH@.BALL then
        d.radius := d.radius+1;
        d.sphere[d.radius+1] := [];
        if IsFRGroup(arg[1]) then
            for i in d.sphere[2] do
                for j in d.sphere[d.radius] do
                    k := i*j;
                    if not (k in d.sphere[d.radius-1] or k in d.sphere[d.radius]) then
                        AddSet(d.sphere[d.radius+1],k);
                    fi;
                od;
            od;
        else
            for i in d.sphere[2] do
                for j in d.sphere[d.radius] do
                    k := i*j;
                    for l in [1..d.radius] do
                        if k in d.sphere[l] then k := fail; break; fi;
                    od;
                    if k<>fail then
                        AddSet(d.sphere[d.radius+1],k);
                    fi;
                od;
            od;
        fi;
        MakeImmutable(d.sphere[d.radius+1]);
        d.volume := d.volume + Length(d.sphere[d.radius+1]);
        if d.sphere[d.radius+1]=[] then
            d.volume := d.volume+10^9; # force quotient searches
#            d.runtimes[strategy] := d.runtimes[strategy]+10^9; # infinity messes up arithmetic later
        fi;
    elif strategy=SEARCH@.QUOTIENT then
        d.level := d.level+1;
        d.pi := d.pifunc(arg[1],d.level);
        if IsPcpGroup(Range(d.pi)) then
            d.index := 2^Length(Pcp(Range(d.pi))); # exponential complexity
        elif IsPcGroup(Range(d.pi)) then           # in length of pcgs
            d.index := 2^Length(Pcgs(Range(d.pi)));
        else
            d.index := Size(Image(d.pi));
        fi;
    fi;
    d.runtimes[strategy] := d.runtimes[strategy]+Runtime()-r;
    return true;
end;

SEARCH@.IN := function(x,G)
    # check in x is in G. can return true, false or fail
    if not x^G!.FRData.pi in Image(G!.FRData.pi) then
        return false;
    elif ForAny(G!.FRData.sphere,s->x in s) then
        return true;
    fi;
    return fail;
end;

SEARCH@.EXTENDTRANSVERSAL := function(G,H,trans)
    # completes the tranversal trans of H^pi in G^pi, and returns it,
    # or "fail" if the search volume limit of G is too small.
    # trans is a partial transversal.
    local pitrans, got, todo, i, j, k;
    pitrans := RightTransversal(Image(G!.FRData.pi),Image(G!.FRData.pi,H));
    got := []; todo := Length(pitrans);
    for i in trans do
        got[PositionCanonical(pitrans,i^G!.FRData.pi)] := i;
        todo := todo-1;
    od;
    if todo=0 then return got; fi;
    i := 1;
    while true do
        if not IsBound(G!.FRData.sphere[i]) and SEARCH@.EXTEND(G,SEARCH@.BALL)=fail then
            return fail;
        fi;
        for j in G!.FRData.sphere[i] do
            k := PositionCanonical(pitrans,j^G!.FRData.pi);
            if not IsBound(got[k]) then
                got[k] := j;
                Add(trans,j);
                todo := todo-1;
                if todo=0 then return got; fi;
            fi;
        od;
        i := i+1;
    od;
    return fail;
end;

SEARCH@.CHECKTRANSVERSAL := function(G,H,trans)
    # check that trans is a transversal of H in G.
    # returns true on success, false on failure, and fail if the search
    # volume of H is too limited.
    local g, t, u, b, transinv, found;
    transinv := List(trans,Inverse);
    for g in G!.FRData.sphere[2] do for t in trans do
        repeat
            found := false;
            for u in transinv do
                b := SEARCH@.IN(t*g*u,H);
                if b=true then
                    found := true;
                    break;
                elif b=fail then
                    found := fail;
                fi;
            od;
            if found=false then
                return false;
            elif found=fail and SEARCH@.EXTEND(H)=fail then
                return fail;
            fi;
        until found=true;
    od; od;
    return true;
end;
#############################################################################

#############################################################################
##
#O SCGroup( <M> )
#O SCSemigroup( <M> )
#O SCMonoid( <M> )
##
InstallMethod(FRGroupImageData, "(FR) for a FR group with preimage data",
        [IsFRGroup and HasFRGroupPreImageData],
        G->FRGroupPreImageData(G)(-1)); # for caching, faster access

InstallAccessToGenerators(IsFRGroup,
        "(FR) for a FR group",GeneratorsOfGroup);

InstallAccessToGenerators(IsFRMonoid,
        "(FR) for a FR monoid",GeneratorsOfMonoid);

InstallAccessToGenerators(IsFRSemigroup,
        "(FR) for a FR semigroup",GeneratorsOfSemigroup);

InstallMethod(SCGroupNC, "(FR) for a Mealy machine",
        [IsMealyMachine],
        function(M)
    local G;
    G := Group(List(GeneratorsOfFRMachine(M),s->FRElement(M,s)));
    SetAlphabetOfFRSemigroup(G,AlphabetOfFRObject(M));
    SetIsStateClosed(G,true);
    SetCorrespondence(G,StateSet(M));
    SetUnderlyingFRMachine(G,M);
    return G;
end);

InstallMethod(SCGroupNC, "(FR) for a FR machine",
        [IsFRMachine and IsFRMachineStdRep],
        function(M)
    local G;
    G := Group(List(GeneratorsOfFRMachine(M),s->FRElement(M,s)));
    SetAlphabetOfFRSemigroup(G,AlphabetOfFRObject(M));
    SetIsStateClosed(G,true);
    SetCorrespondence(G,GroupHomomorphismByFunction(M!.free,G,w->FRElement(M,w)));
    SetUnderlyingFRMachine(G,M);
    return G;
end);

InstallMethod(SCMonoidNC, "(FR) for a Mealy machine",
        [IsMealyMachine],
        function(M)
    local G;
    G := Monoid(List(GeneratorsOfFRMachine(M),s->FRElement(M,s)));
    SetAlphabetOfFRSemigroup(G,AlphabetOfFRObject(M));
    SetIsStateClosed(G,true);
    SetCorrespondence(G,StateSet(M));
    SetUnderlyingFRMachine(G,M);
    return G;
end);

InstallMethod(SCMonoidNC, "(FR) for a FR machine",
        [IsFRMachine and IsFRMachineStdRep],
        function(M)
    local G;
    G := Monoid(List(GeneratorsOfFRMachine(M),s->FRElement(M,s)));
    SetAlphabetOfFRSemigroup(G,AlphabetOfFRObject(M));
    SetIsStateClosed(G,true);
    SetCorrespondence(G,MagmaHomomorphismByFunctionNC(M!.free,G,w->FRElement(M,w)));
    SetUnderlyingFRMachine(G,M);
    return G;
end);

InstallMethod(SCSemigroupNC, "(FR) for a Mealy machine",
        [IsMealyMachine],
        function(M)
    local G;
    G := Semigroup(List(GeneratorsOfFRMachine(M),s->FRElement(M,s)));
    SetAlphabetOfFRSemigroup(G,AlphabetOfFRObject(M));
    SetIsStateClosed(G,true);
    SetCorrespondence(G,StateSet(M));
    SetUnderlyingFRMachine(G,M);
    return G;
end);

InstallMethod(SCSemigroupNC, "(FR) for a FR machine",
        [IsFRMachine],
        function(M)
    local G;
    G := Semigroup(List(GeneratorsOfFRMachine(M),s->FRElement(M,s)));
    SetAlphabetOfFRSemigroup(G,AlphabetOfFRObject(M));
    SetIsStateClosed(G,true);
    SetCorrespondence(G,MagmaHomomorphismByFunctionNC(M!.free,G,w->FRElement(M,w)));
    SetUnderlyingFRMachine(G,M);
    return G;
end);

InstallMethod(SCGroup, "(FR) for a FR machine",
        [IsFRMachine],
        function(M)
    local gens, corr, i, x, G;
    gens := []; corr := [];
    for i in GeneratorsOfFRMachine(M) do
        x := FRElement(M,i);
        if IsOne(x) then
            Add(corr,0);
        elif x in gens then
            Add(corr,Position(gens,x));
        elif x^-1 in gens then
            Add(corr,-Position(gens,x^-1));
        else
            Add(gens,x);
            Add(corr,Size(gens));
        fi;
    od;
    if gens=[] then
        G := TrivialSubgroup(Group(FRElement(M,GeneratorsOfFRMachine(M)[1])));
    else
        G := Group(gens);
    fi;
    SetAlphabetOfFRSemigroup(G,AlphabetOfFRObject(M));
    SetIsStateClosed(G,true);
    if IsMealyMachine(M) then
        SetCorrespondence(G,corr);
    elif IsFRMachineStdRep(M) then
        SetCorrespondence(G,GroupHomomorphismByFunction(M!.free,G,w->FRElement(M,w)));
    fi;
    SetUnderlyingFRMachine(G,M);
    return G;
end);

InstallMethod(SCMonoid, "(FR) for a FR machine",
        [IsFRMachine],
        function(M)
    local gens, corr, i, x, G;
    gens := []; corr := [];
    for i in GeneratorsOfFRMachine(M) do
        x := FRElement(M,i);
        if IsOne(x) then
            Add(corr,0);
        elif x in gens then
            Add(corr,Position(gens,x));
        else
            Add(gens,x);
            Add(corr,Size(gens));
        fi;
    od;
    if gens=[] then
        G := TrivialSubmonoid(Monoid(FRElement(M,GeneratorsOfFRMachine(M)[1])));
    else
        G := Monoid(gens);
    fi;
    SetAlphabetOfFRSemigroup(G,AlphabetOfFRObject(M));
    SetIsStateClosed(G,true);
    if IsMealyMachine(M) then
        SetCorrespondence(G,corr);
    elif IsFRMachineStdRep(M) then
        SetCorrespondence(G,MagmaHomomorphismByFunctionNC(M!.free,G,w->FRElement(M,w)));
    fi;
    SetUnderlyingFRMachine(G,M);
    return G;
end);

InstallMethod(SCSemigroup, "(FR) for a FR machine",
        [IsFRMachine],
        function(M)
    local gens, corr, i, x, G;
    gens := []; corr := [];
    for i in GeneratorsOfFRMachine(M) do
        x := FRElement(M,i);
        if x in gens then
            Add(corr,Position(gens,x));
        else
            Add(gens,x);
            Add(corr,Size(gens));
        fi;
    od;
    G := Semigroup(gens);
    SetAlphabetOfFRSemigroup(G,AlphabetOfFRObject(M));
    SetIsStateClosed(G,true);
    if IsMealyMachine(M) then
        SetCorrespondence(G,corr);
    elif IsFRMachineStdRep(M) then
        SetCorrespondence(G,MagmaHomomorphismByFunctionNC(M!.free,G,w->FRElement(M,w)));
    fi;
    SetUnderlyingFRMachine(G,M);
    return G;
end);
#############################################################################

#############################################################################
##
#O FullSCGroup
#O FullSCSemigroup
#O FullSCMonoid
##
FILTERORDER@ := [IsFRObject, IsFinitaryFRElement, IsBoundedFRElement, IsPolynomialGrowthFRElement, IsFiniteStateFRElement, IsFRElement];
# value IsFRObject means a group for which the exact category of elements is
# not known; it really stand for "unspecified subgroup of FullSCGroup"

BindGlobal("FULLGETDATA@", function(arglist,
                                cat, Iscat, IsFRcat, GeneratorsOfcat, AscatFRElement,
                                makevertex, stype)
    local a, G, rep, alphabet, i, x, name, filter, depth, vertex, o, onerep;
    filter := IsFRElement;
    depth := infinity;
    for a in arglist do
        if Iscat(a) then
            vertex := a;
        elif IsList(a) or IsDomain(a) then
            alphabet := a;
        elif IsFilter(a) then
            if Position(FILTERORDER@,a)<Position(FILTERORDER@,filter) then filter := a; fi;
        elif IsInt(a) then
            depth := a;
        else
            Error("Unknown argument ",a,"\n");
        fi;
    od;
    if not IsBound(alphabet) then
        if IsBound(vertex) and IsSemigroup(vertex) then
            alphabet := [1..LargestMovedPoint(vertex)];
        else
            Error("Please specify at least a vertex group or an alphabet\n");
        fi;
    elif not IsBound(vertex) then
        vertex := makevertex(alphabet);
    fi;
    rep := First(GeneratorsOfSemigroup(vertex),x->not IsOne(x));
    if rep=fail then rep := Representative(vertex); fi;
    onerep := One(vertex);
    if onerep=fail then
        onerep := rep;
    fi; # maybe this does not define an element of the semigroup :(
    if IsList(alphabet) then
        rep := MealyElement([List(alphabet,a->2),List(alphabet,a->2)],[rep,onerep],1);
    else
        rep := MealyElement(Domain([1,2]),alphabet,function(s,a) return 1; end, function(s,a) if s=1 then return a; else return a^Representative(vertex); fi; end);
    fi;
    if depth < infinity then filter := IsFinitaryFRElement; fi;
    if filter=IsFRElement then rep := AscatFRElement(rep); fi;
    G := Objectify(NewType(FamilyObj(cat(rep)),
                 IsFRcat and IsAttributeStoringRep),
                 rec());
    SetAlphabetOfFRSemigroup(G,alphabet);
    SetDepthOfFRSemigroup(G,depth);
    if IsOne(onerep) then
        SetOne(G,One(rep));
    else
        SetOne(G,fail);
    fi;
    if ((IsList(alphabet) or HasSize(alphabet)) and Size(alphabet)=1) or not IsBound(Enumerator(vertex)[2]) or depth=0 then
        SetIsTrivial(G, true);
        SetIsFinite(G, true);
        Setter(GeneratorsOfcat)(G,[]);
        if Size(vertex)=0 or (One(G)=fail and depth<>infinity) then
            SetSize(G,0);
        else
            SetSize(G,1);
            SetRepresentative(G,rep);
        fi;
    else
        if filter<>IsFRObject and (onerep<>rep or depth=infinity) then
            SetRepresentative(G,rep); # if finite depth and semigroup,
            # maybe there are no representative
        fi;
        SetIsTrivial(G, false);
        if depth=infinity then
            SetIsFinite(G, false);
            SetSize(G, infinity);
        elif IsList(alphabet) or HasSize(alphabet) then
            SetIsFinite(G, true);
            SetSize(G, Size(vertex)^((Size(alphabet)^depth-1)/(Size(alphabet)-1)));
            x := GeneratorsOfcat(vertex);
            x := List(x,g->MealyElement([List(alphabet,a->2),List(alphabet,a->2)],[g,One(vertex)],1));
            if cat=Group then
                o := List(Orbits(vertex,alphabet),Representative);
            else
                o := alphabet;
            fi;
            a := x;
            for i in [1..depth-1] do
                x := Concatenation(List(x,g->List(o,a->VertexElement(a,g))));
                Append(a,x);
            od;
            Setter(GeneratorsOfcat)(G,a);
            if cat=Group then
                Append(a,List(a,Inverse));
                Setter(GeneratorsOfSemigroup)(G,a);
            fi;
        fi;
    fi;
    if filter=IsFRObject then
        name := "<recursive ";
        Append(name,LowercaseString(stype));
        Append(name," over ");
        Append(name,String(alphabet));
        Append(name,">");
    else
        name := "FullSC";
        Append(name,stype);
        Append(name,"(");
        Append(name,String(alphabet));
        if vertex<>makevertex(alphabet) then
            Append(name,", "); PrintTo(OutputTextString(name,true),vertex);
        fi;
        if depth < infinity then
            Append(name,", "); Append(name,String(depth));
        elif filter <> IsFRElement then
            Setter(filter)(G,true);
            x := ""; PrintTo(OutputTextString(x,false),filter);
            if x{[1..10]}="<Operation" then x := x{[13..Length(x)-2]}; fi;
            Append(name,", "); Append(name,x);
        fi;
        Append(name,")");
        for x in [2..Position(FILTERORDER@,filter)-1] do
            Setter(FILTERORDER@[x])(G,false);
        od;
        SetIsStateClosed(G, true);
        SetIsRecurrentFRSemigroup(G, depth=infinity);
        SetIsBranched(G, depth=infinity);
        if depth<infinity and cat=Group then
            SetBranchingSubgroup(G,TrivialSubgroup(G));
            x := EpimorphismPermGroup(G,depth);
            SetIsHandledByNiceMonomorphism(G,true);
            SetNiceMonomorphism(G,x);
        else
            SetBranchingSubgroup(G,G);
        fi;
        if filter=IsFinitaryFRElement then
            if One(G)=fail then
                SetNucleusOfFRSemigroup(G,[]);
            else
                SetNucleusOfFRSemigroup(G,[One(G)]);
            fi;
        else
            SetNucleusOfFRSemigroup(G,G);
        fi;
        SetIsContracting(G,filter=IsFinitaryFRElement or filter=IsBoundedFRElement);
        SetHasOpenSetConditionFRSemigroup(G,filter=IsFinitaryFRElement);
    fi;
    SetFullSCVertex(G,vertex);
    SetFullSCFilter(G,filter);
    SetName(G,name);
    return G;
end);

InstallGlobalFunction(FullSCGroup, "(FR) full tree automorphism group",
        function(arg)
    local  G;
    G := FULLGETDATA@(arg,Group,IsGroup,IsFRGroup,GeneratorsOfGroup,AsGroupFRElement,
                 SymmetricGroup,"Group");
    if IsTrivial(G) or FullSCFilter(G)=IsFRObject then
        return G;
    elif DepthOfFRSemigroup(G)=infinity then
        SetIsLevelTransitive(G,IsTransitive(FullSCVertex(G),AlphabetOfFRSemigroup(G)));
        SetIsFinitelyGeneratedGroup(G, false);
        SetCentre(G, TrivialSubgroup(G));
        SetIsSolvableGroup(G, false);
        SetIsAbelian(G, false);
    fi;
    SetIsPerfectGroup(G, IsPerfectGroup(FullSCVertex(G)));
    return G;
end);

InstallGlobalFunction(FullSCMonoid,
        function(arg)
    local M;
    M := FULLGETDATA@(arg,Monoid,IsMonoid,IsFRMonoid,GeneratorsOfMonoid,AsMonoidFRElement,
                 FullTransMonoid,
                 "Monoid");
    return M;
end);

InstallGlobalFunction(FullSCSemigroup,
        function(arg)
    local S;
    S := FULLGETDATA@(arg,Semigroup,IsSemigroup,IsFRSemigroup,GeneratorsOfSemigroup,AsSemigroupFRElement,
                 FullTransMonoid,"Semigroup");
    return S;
end);

InstallTrueMethod(HasFullSCData, HasFullSCVertex and HasFullSCFilter);
#############################################################################

#############################################################################
##
#M AlphabetOfFRSemigroup
##
InstallMethod(AlphabetOfFRSemigroup, "(FR) for an FR semigroup",
        [IsFRSemigroup],
        function(G)
    local p;
    while not HasRepresentative(G) and HasParent(G) and not IsIdenticalObj(Parent(G),G) do
        G := Parent(G);
    od;
    return AlphabetOfFRObject(Representative(G));
end);
#############################################################################

#############################################################################
##
#M IsGeneratorsOfMagmaWithInverses
##
InstallMethod(IsGeneratorsOfMagmaWithInverses, "(FR) for a list of FR elements",
        [IsListOrCollection],
        function(L)
    if ForAll(L,IsFRElement) and ForAll(L,IsInvertible) then return true;
    else TryNextMethod(); fi;
end);
#############################################################################

#############################################################################
##
#M  Random
#M  Pseudorandom
##
BindGlobal("RANDOMFINITARY@", function(G,d)
    local i, a, t, transitions, output;
    if d=0 then return One(G); fi;
    transitions := [];
    output := [Random(FullSCVertex(G))];
    for i in [0..d-2] do for i in [1..Size(AlphabetOfFRSemigroup(G))^i] do
        t := [];
        for a in AlphabetOfFRSemigroup(G) do
            Add(output,Random(FullSCVertex(G)));
            Add(t,Length(output));
        od;
        Add(transitions,t);
    od; od;
    Add(output,One(FullSCVertex(G)));
    for i in [0..Size(AlphabetOfFRSemigroup(G))^(d-1)] do
        Add(transitions,List(AlphabetOfFRSemigroup(G),a->Length(output)));
    od;
    return MealyElement(transitions,output,1);
end);

BindGlobal("RANDOMBOUNDED@", function(G)
    local E, F, M, s, n, i, j;
    if IsTrivial(G) then
        return One(G);
    fi;
    s := Size(AlphabetOfFRSemigroup(G));
    F := RANDOMFINITARY@(G,Random([2..4]));
    M := UnderlyingFRMachine(F);
    for i in [0..5] do
        n := Random([1..4]);
        E := MealyMachineNC(FRMFamily(AlphabetOfFRSemigroup(G)),List([1..n],i->List([1..s],i->Random(n+[1..M!.nrstates]))),List([1..n],i->ListTrans(Random(FullSCVertex(G)),s)))+M;
        for j in [1..n] do
            E!.transitions[j][Random([1..s])] := 1+RemInt(j,n);
        od;
        F := F*FRElement(E,1);
    od;
    return F;
end);

BindGlobal("RANDOMPOLYNOMIALGROWTH@", function(G)
    local E, F, i, j, one, n, p;
#    F := RANDOMBOUNDED@(G);
    for i in [0..5] do
        E := UnderlyingFRMachine(RANDOMBOUNDED@(G));
        for j in [1..Random([0..4])] do
            one := First([1..E!.nrstates],i->IsOne(FRElement(E,i)));
            repeat
                n := Random([1..E!.nrstates]);
                p := Random([1..Size(AlphabetOfFRSemigroup(G))]);
            until E!.transitions[n][p]=one;
            E := E+UnderlyingFRMachine(RANDOMBOUNDED@(G));
            E!.transitions[n^Correspondence(E)[1]][p] := 1^Correspondence(E)[2];
        od;
        return FRElement(E,1);
        F := F*E;
    od;
    return F;
end);

InstallMethod(Random, "(FR) for a full SC Group",
        [IsFRSemigroup and HasFullSCData],
        function (G)
    local n, f;
    if DepthOfFRSemigroup(G)<infinity then
        return Minimized(RANDOMFINITARY@(G,DepthOfFRSemigroup(G)));
    elif IsFinitaryFRSemigroup(G) then
        return Minimized(RANDOMFINITARY@(G,Random([0..5])));
    elif IsBoundedFRSemigroup(G) then
        return RANDOMBOUNDED@(G);
    elif IsPolynomialGrowthFRSemigroup(G) then
        return RANDOMPOLYNOMIALGROWTH@(G);
    elif IsFiniteStateFRSemigroup(G) then
        n := Random([1..20]);
        return MealyElement(List([1..n],s->List(AlphabetOfFRSemigroup(G),a->Random([1..n]))),List([1..n],s->Random(FullSCVertex(G))),1);
    else
        n := Random([1..5]);
        if IsGroup(StateSet(Representative(G))) then
            f := FreeGroup(n);
        else
            f := FreeMonoid(n);
        fi;
        return FRElement(f,List([1..n],s->List(AlphabetOfFRSemigroup(G),a->Random(f))),List([1..n],s->Random(FullSCVertex(G))),Random(f));
    fi;
end);

BindGlobal("INITPSEUDORANDOM@", function(g, len, scramble)
    local gens, seed, i;
    gens := GeneratorsOfSemigroup(g);
    if 0 = Length(gens) then
        SetPseudoRandomSeed(g,[[]]);
        return;
    fi;
    len := Maximum(len,Length(gens),2);
    seed := ShallowCopy(gens);
    for i in [Length(gens)+1..len] do
        seed[i] := Random(gens);
    od;
    SetPseudoRandomSeed(g,[seed]);
    for i in [1..scramble] do
        PseudoRandom(g);
    od;
end);

BindGlobal("PSEUDORANDOM@", function (g)
    local seed, i, j;
    if not HasPseudoRandomSeed(g) then
        i := Length( GeneratorsOfSemigroup(g) );
        INITPSEUDORANDOM@(g, i+10, Maximum(i*10,100));
    fi;
    seed := PseudoRandomSeed(g);
    if 0 = Length(seed[1]) then
        return One(g);
    fi;
    i := Random([1..Length(seed[1])]);
    repeat
        j := Random([1..Length(seed[1])]);
    until i <> j;
    if Random([true, false]) then
        seed[1][j] := seed[1][i] * seed[1][j];
    else
        seed[1][j] := seed[1][j] * seed[1][i];
    fi;
    return seed[1][j];
end);

InstallMethod(PseudoRandom, "(FR) for an FR group",
        [IsFRSemigroup],
        function(g)
    local lim, gens, i, x;
    lim := ValueOption("radius");
    if lim=fail then return PSEUDORANDOM@(g); fi;
    gens := GeneratorsOfSemigroup(g);
    x := Random(gens);
    for i in [1..lim] do x := x*Random(gens); od;
    return x;
end);
#############################################################################

#############################################################################
##
#M  IsSubgroup
#M \in
#M IsSubset
#M Size
#M IsFinite
#M Iterator
#M Enumerator
##
InstallMethod(IsSubset, "(FR) for two full FR semigroups",
        IsIdenticalObj,
        [IsFRSemigroup and HasFullSCData, IsFRSemigroup and HasFullSCData],
        100, # make sure groups with full SC data come first
        function (G, H)
    if FullSCFilter(G)=IsFRObject then
        return fail;
    elif not IsSubset(FullSCVertex(G), FullSCVertex(H)) then
        return false;
    elif DepthOfFRSemigroup(G)<DepthOfFRSemigroup(H) then
        return false;
    elif DepthOfFRSemigroup(H)<infinity then
        return true;
    elif Position(FILTERORDER@,FullSCFilter(G))<Position(FILTERORDER@,FullSCFilter(H)) then
        return false;
    else
        return true;
    fi;
end);

InstallMethod(IsSubset, "(FR) for an FR semigroup and a full SC semigroup",
        IsIdenticalObj,
        [IsFRSemigroup, IsFRSemigroup and HasFullSCData],
        function (G, H)
    if FullSCFilter(H)=IsFRObject then
        return fail;
    elif DepthOfFRSemigroup(H)<>infinity and
      ForAll(GeneratorsOfSemigroup(H),x->x in G) then
        return true;
    else
        return false;
    fi;
end);

InstallMethod(IsSubset, "(FR) for an FR semigroup and a f.g. FR group",
        IsIdenticalObj,
        [IsFRSemigroup, IsFRGroup and IsFinitelyGeneratedGroup],
        function (G, H)
    return IsSubset(G, GeneratorsOfGroup(H));
end);

InstallMethod(IsSubset, "(FR) for an FR semigroup and an FR monoid",
        IsIdenticalObj,
        [IsFRSemigroup, IsFRMonoid],
        function (G, H)
    return IsSubset(G, GeneratorsOfMonoid(H));
end);

InstallMethod(IsSubset, "(FR) for two FR semigroups",
        IsIdenticalObj,
        [IsFRSemigroup, IsFRSemigroup],
        function (G, H)
    return IsSubset(G, GeneratorsOfSemigroup(H));
end);

InstallMethod(\=, "(FR) for two FR semigroups",
        IsIdenticalObj,
        [IsFRSemigroup, IsFRSemigroup],
        function (G, H)
    return IsSubset(G, H) and IsSubset(H, G);
end);

InstallMethod(\in, "(FR) for an FR element and a full SC semigroup",
        IsElmsColls,
        [IsFRElement, IsFRSemigroup and HasFullSCData],
        function ( g, G )
    if FullSCFilter(G)=IsFRObject then
        return fail;
    elif not ForAll(States(g), s->Trans(Output(s)) in FullSCVertex(G)) then
        return false;
    elif not FullSCFilter(G)(g) then
        return false;
    elif DepthOfFRSemigroup(G)<>infinity and DepthOfFRElement(g)>DepthOfFRSemigroup(G) then
        return false;
    else
        return true;
    fi;
end);

InstallMethod(\in, "(FR) for an FR element and an FR semigroup",
        IsElmsColls,
        [IsFRElement, IsFRSemigroup],
        function ( g, G )
    local b;
    if HasNucleusOfFRSemigroup(G) and
       not IsSubset(NucleusOfFRSemigroup(G),LimitStates(g)) then
        return false;
    fi;
    SEARCH@.INIT(G);
    while true do
        b := SEARCH@.IN(g,G);
        if b<>fail then return b; fi;
        while SEARCH@.EXTEND(G)=fail do
            SEARCH@.ERROR(G,"\\in");
        od;
        Info(InfoFR, 3, "\\in: searching at level ",G!.FRData.level," and in sphere of radius ",G!.FRData.radius);
    od;
end);

BindGlobal("EDGESTABILIZER@", function(G)
    # returns the stabilizer of an edge in the tree; i.e.
    # computes the action on the second level, and takes the stabilizer of a subtree and at the root.
    local i, a, s;
    a := AlphabetOfFRSemigroup(G);

    s := Stabilizer(PermGroup(G,2),a,OnTuples); # fix [1,1],...,[1,d]
    for i in a do
        s := Stabilizer(s,a+(i-1)*Size(a),OnSets); # preserve {[i,1],...,[i,d]}
    od;
    # the following method is too slow
    #s := Stabilizer(s,List(AlphabetOfFRSemigroup(G),i->(i-1)*Size(AlphabetOfFRSemigroup(G))+AlphabetOfFRSemigroup(G)),OnTuplesSets);
    return s;
end);
    
BindGlobal("ISFINITE_THOMPSONWIELANDT@", function(G)
    # returns 'true' if G is finite, 'false' if not, 'fail' otherwise
    #
    # Thompson-Wielandt's theorem says that G is infinite if the stabilizer of a vertex is primitive
    # and the stabilizer of the star of an edge is not a p-group; see
    # Burger-Mozes, Lattices..., prop 1.3
    local q, s;

    if HasUnderlyingFRMachine(G) and IsBireversible(UnderlyingFRMachine(G))
       and IsPrimitive(VertexTransformations(G),AlphabetOfFRSemigroup(G)) then
        s := EDGESTABILIZER@(G);
        if not IsPGroup(s) then
            return false;
        fi;
    fi;
    return fail;
end);

InstallMethod(IsFinite, "(FR) for an FR group",
        [IsFRGroup],
        function(G)
    local b;

    if IsFinitaryFRSemigroup(G) then
        return true;
    fi;
    b := ISFINITE_THOMPSONWIELANDT@(G);
    if b<>fail then
        return b;
    elif IsLevelTransitive(G) then
        return false;
    else
        TryNextMethod();
    fi;
end);

BindGlobal("SIZE@", function(G,testorder)
    local n, g, iter;
    iter := Iterator(G);
    n := 0;
    while not IsDoneIterator(iter) do
        g := NextIterator(iter);
        if testorder and Order(g)=infinity then return infinity; fi;
        n := n+1;
        if RemInt(n,100)=0 then
            Info(InfoFR,2,"Size: is at least ",n);
        fi;
    od;
    return n;
end);

InstallMethod(IsTrivial, "(FR) for an FR semigroup",
        [IsFRSemigroup],
        function(G)
    return ForAll(GeneratorsOfSemigroup(G),IsOne);
end);

InstallMethod(IsTrivial, "(FR) for an FR monoid",
        [IsFRMonoid],
        function(G)
    return ForAll(GeneratorsOfMonoid(G),IsOne);
end);

InstallMethod(IsTrivial, "(FR) for an FR group",
        [IsFRGroup],
        function(G)
    return ForAll(GeneratorsOfGroup(G),IsOne);
end);

InstallMethod(Size, "(FR) for an FR semigroup",
        [IsFRSemigroup], 10,
        function(G)
    local b, gens, rays;
    if IsFinitaryFRSemigroup(G) then
        return SIZE@(G,false);
    fi;
    TryNextMethod();
end);

InstallMethod(Size, "(FR) for an FR semigroup",
        [IsFRSemigroup],
        function(G)
    return SIZE@(G,false);
end);

InstallMethod(Size, "(FR) for an FR semigroup",
        [IsFRSemigroup],
        function(G)
    return SIZE@(G,true);
end);

InstallMethod(Size, "(FR) for an FR group",
        [IsFRGroup],
        function(G)
    local b, gens, rays;
    b := ISFINITE_THOMPSONWIELANDT@(G);
    if b=true then
        TryNextMethod();
    elif b=false then
        return infinity;
    elif IsBoundedFRSemigroup(G) then
        gens := GeneratorsOfGroup(G);
        rays := Union(List(gens,g->List(Germs(g),p->p[1])));
        if ForAll(rays,x->ForAll(gens,s->x^s=x)) then
            return SIZE@(G,false);
        fi;
    fi;
    if IsLevelTransitive(G) then return infinity; fi;
    #!!! try to find a subgroup that acts transitively on a subtree
    TryNextMethod();
end);

SEARCH@.NEXTITERATOR := function(iter)
    if iter!.pos < Length(iter!.G!.FRData.sphere[iter!.radius+1]) then
        iter!.pos := iter!.pos+1;
    else
        iter!.pos := 1;
        while iter!.radius=iter!.G!.FRData.radius and
           SEARCH@.EXTEND(iter!.G,SEARCH@.BALL)=fail do
            SEARCH@.ERROR(iter!.G,"NextIterator");
        od;
        iter!.radius := iter!.radius+1;
        if iter!.G!.FRData.sphere[iter!.radius+1]=[] then return fail; fi;
    fi;
    return iter!.G!.FRData.sphere[iter!.radius+1][iter!.pos];
end;

SEARCH@.ISDONEITERATOR := function(iter)
    if iter!.pos < Length(iter!.G!.FRData.sphere[iter!.radius+1]) then
        return false;
    else
        iter!.pos := 0;
        while iter!.radius=iter!.G!.FRData.radius and
           SEARCH@.EXTEND(iter!.G,SEARCH@.BALL)=fail do
            SEARCH@.ERROR(iter!.G,"IsDoneIterator");
        od;
        iter!.radius := iter!.radius+1;
        return iter!.G!.FRData.sphere[iter!.radius+1]=[];
    fi;
end;

SEARCH@.SHALLOWCOPY := function(iter)
    return rec(
               NextIterator := SEARCH@.NEXTITERATOR,
               IsDoneIterator := SEARCH@.ISDONEITERATOR,
               ShallowCopy := SEARCH@.SHALLOWCOPY,
               G := iter!.G,
               pos := iter!.pos,
               radius := iter!.radius);
end;

SEARCH@.ELEMENTNUMBER := function(iter,n)
    local i;
    i := 1;
    while n > Length(iter!.G!.FRData.sphere[i]) do
        n := n-Length(iter!.G!.FRData.sphere[i]);
        i := i+1;
        while not IsBound(iter!.G!.FRData.sphere[i]) and
           SEARCH@.EXTEND(iter!.G,SEARCH@.BALL)=fail do
            SEARCH@.ERROR(iter!.G,"ElementNumber");
        od;
        if iter!.G!.FRData.sphere[i]=[] then return fail; fi;
    od;
    return iter!.G!.FRData.sphere[i][n];
end;

SEARCH@.NUMBERELEMENT := function(iter,x)
    local i, n, p;
    i := 1; n := 0;
    repeat
        while not IsBound(iter!.G!.FRData.sphere[i]) and
           SEARCH@.EXTEND(iter!.G,SEARCH@.BALL)=fail do
            SEARCH@.ERROR(iter!.G,"NumberElement");
        od;
        p := Position(iter!.G!.FRData.sphere[i],x);
        if p<>fail then return n+p; fi;
        n := n+Length(iter!.G!.FRData.sphere[i]);
        i := i+1;
    until false;
end;

InstallMethod(Iterator, "(FR) for an FR semigroup",
        [IsFRSemigroup],
        function(G)
    SEARCH@.INIT(G);
    return IteratorByFunctions(rec(
                   NextIterator := SEARCH@.NEXTITERATOR,
                   IsDoneIterator := SEARCH@.ISDONEITERATOR,
                   ShallowCopy := SEARCH@.SHALLOWCOPY,
                   G := G,
                   pos := 0,
                   radius := 0));
end);

InstallMethod(Iterator, "(FR) for an FR semigroup with SC data",
        [IsFRSemigroup and HasFullSCData],
        function(G)
    local maker;
    if DepthOfFRSemigroup(G)<infinity then
        TryNextMethod(); # GAP does a fine job here
    elif IsFinitaryFRSemigroup(G) then
        if IsGroup(G) then
            maker := n->FullSCGroup(AlphabetOfFRSemigroup(G),VertexTransformations(G),n);
        elif IsMonoid(G) then
            maker := n->FullSCMonoid(AlphabetOfFRSemigroup(G),VertexTransformations(G),n);
        else
            maker := n->FullSCSemigroup(AlphabetOfFRSemigroup(G),VertexTransformations(G),n);
        fi;
        return IteratorByFunctions(rec(
                       NextIterator := function(iter)
            local n;
            repeat
                if IsDoneIterator(iter!.iter) then
                    iter!.level := iter!.level+1;
                    iter!.iter := Iterator(maker(iter!.level));
                fi;
                n := NextIterator(iter!.iter);
            until DepthOfFRSemigroup(n)>=iter!.level;
            return n;
        end,
                       IsDoneIterator := ReturnFalse,
                       ShallowCopy := function(iter)
            return rec(NextIterator := iter!.NextIterator,
                       IsDoneIterator := iter!.IsDoneIterator,
                       ShallowCopy := iter!.ShallowCopy,
                       level := iter!.level,
                       iter := ShallowCopy(iter!.iter));
        end,
                       level := 0,
                       iter := Iterator(maker(0))));
    else
        return fail; # probably not worth coding
    fi;
end);

InstallMethod(Enumerator, "(FR) for an FR semigroup",
        [IsFRSemigroup],
        function(G)
    SEARCH@.INIT(G);
    return EnumeratorByFunctions(G,rec(
                   ElementNumber := SEARCH@.ELEMENTNUMBER,
                   NumberElement := SEARCH@.NUMBERELEMENT,
                   G := G));
end);

InstallMethod(PreImagesRepresentative, "(FR) for a map to an FR group",
        [IsGroupGeneralMappingByImages, IsMultiplicativeElementWithInverse],
        function(f,y)
    local iter, x;
    if not IsFRGroup(Range(f)) then TryNextMethod(); fi;
    iter := Iterator(Source(f));
    while not IsDoneIterator(iter) do
        x := NextIterator(iter);
        if x^f=y then return x; fi;
    od;
    return fail;
end);
#############################################################################

#############################################################################
##
#M View
##
BindGlobal("VIEWFRGROUP@", function(G,gens,name)
    local n, s;
    s := "<";
    if HasIsStateClosed(G) then
        if not IsStateClosed(G) then Append(s,"non-"); fi;
        Append(s,"state-closed");
    else
        Append(s,"recursive");
    fi;
    if HasIsRecurrentFRSemigroup(G) and IsRecurrentFRSemigroup(G) then
        Append(s,", recurrent");
    fi;
    if HasIsLevelTransitive(G) and IsLevelTransitive(G) then
        Append(s,", level-transitive");
    fi;
    if HasIsContracting(G) and IsContracting(G) then
        Append(s,", contracting");
    fi;
    if HasIsFinitaryFRSemigroup(G) and IsFinitaryFRSemigroup(G) then
        Append(s,", finitary");
    elif HasIsBoundedFRSemigroup(G) and IsBoundedFRSemigroup(G) then
        Append(s,", bounded");
    elif HasIsPolynomialGrowthFRSemigroup(G) and IsPolynomialGrowthFRSemigroup(G) then
        Append(s,", polynomial-growth");
    elif HasIsFiniteStateFRSemigroup(G) and IsFiniteStateFRSemigroup(G) then
        Append(s,", finite-state");
    fi;
    if HasIsBranched(G) and IsBranched(G) then
        Append(s,", branched");
    fi;
    n := Length(gens(G));
    APPEND@(s," ",name," over ",AlphabetOfFRSemigroup(G)," with ",n," generator");
    if n<>1 then Append(s,"s"); fi;
    if HasSize(G) then APPEND@(s,", of size ",Size(G)); fi;
    Append(s,">");
    return s;
end);

InstallMethod(ViewString, "(FR) for an FR group",
        [IsFRGroup and IsFinitelyGeneratedGroup],
        G->VIEWFRGROUP@(G,GeneratorsOfGroup,"group"));

InstallMethod(ViewString, "(FR) for an FR monoid",
        [IsFRMonoid],
        G->VIEWFRGROUP@(G,GeneratorsOfMonoid,"monoid"));

InstallMethod(ViewString, "(FR) for an FR semigroup",
        [IsFRSemigroup],
        G->VIEWFRGROUP@(G,GeneratorsOfSemigroup,"semigroup"));

INSTALLPRINTERS@(IsFRGroup);
INSTALLPRINTERS@(IsFRMonoid);
INSTALLPRINTERS@(IsFRSemigroup);
#############################################################################

#############################################################################
##
#M ExternalSet
##
InstallOtherMethod(ExternalSet, "(FR) for an FR semigroup and a depth",
        [IsFRSemigroup, IsPosInt],
        function( g, n )
    return ExternalSet(g,Cartesian(List([1..n],i->AlphabetOfFRSemigroup(g))),\^);
end);
#############################################################################

#############################################################################
##
#M VertexTransformations
##
InstallMethod(TopVertexTransformations, "(FR) for a f.g. FR group",
        [IsFRGroup and IsFinitelyGeneratedGroup],
        function(g)
    if GeneratorsOfGroup(g)=[] then return Group(()); fi;
    return Group(List(GeneratorsOfGroup(g),ActivityPerm));
end);

InstallMethod(TopVertexTransformations, "(FR) for a FR monoid",
        [IsFRMonoid],
        function(g)
    if GeneratorsOfMonoid(g)=[] then return Monoid(OneTrans); fi;
    return Monoid(List(GeneratorsOfMonoid(g),ActivityTransformation));
end);

InstallMethod(TopVertexTransformations, "(FR) for a FR semigroup",
        [IsFRSemigroup],
        function(g)
    return Semigroup(List(GeneratorsOfSemigroup(g),ActivityTransformation));
end);

InstallMethod(VertexTransformations, "(FR) for a f.g. FR group",
        [IsFRGroup and IsFinitelyGeneratedGroup],
        function(g)
    if GeneratorsOfGroup(g)=[] then return Group(()); fi;
    return Group(Concatenation(List(GeneratorsOfGroup(g),g->List(States(g),ActivityPerm))));
end);

InstallMethod(VertexTransformations, "(FR) for a FR monoid",
        [IsFRMonoid],
        function(g)
    if GeneratorsOfMonoid(g)=[] then return Monoid(OneTrans); fi;
    return Monoid(Concatenation(List(GeneratorsOfMonoid(g),g->List(States(g),ActivityTransformation))));
end);

InstallMethod(VertexTransformations, "(FR) for a FR semigroup",
        [IsFRSemigroup],
        function(g)
    return Semigroup(Concatenation(List(GeneratorsOfSemigroup(g),g->List(States(g),ActivityTransformation))));
end);

InstallMethod(TopVertexTransformations, "(FR) for a full SC semigroup",
        [IsFRSemigroup and HasFullSCData],
        FullSCVertex);

InstallMethod(VertexTransformations, "(FR) for a full SC semigroup",
        [IsFRSemigroup and HasFullSCData],
        FullSCVertex);
#############################################################################

#############################################################################
##
#M PermGroup
#M EpimorphismPermGroup
##
InstallMethod(PermGroup, "(FR) for a f.g. FR group and a level",
        [IsFRGroup and IsFinitelyGeneratedGroup, IsInt], 1,
        function( g, n )
    if IsTrivial(g) then return Group(()); fi;
    return Group(List(GeneratorsOfGroup(g),x->ActivityPerm(x,n)));
end);

InstallMethod(PermGroup, "(FR) for a full FR group and a level",
        [IsFRGroup and HasFullSCData, IsInt],
        function( g, n )
    return PermGroup(FullSCGroup(FullSCVertex(g),FullSCFilter(g),n),n);
end);

InstallMethod(EpimorphismPermGroup, "(FR) for a f.g. FR group and a level",
        [IsFRGroup, IsInt], 1,
        function( g, n )
    local q, h;
    q := PermGroup(g,n);
    if HasGeneratorsOfGroup(g) then
        h := GroupGeneralMappingByImages(q,g,List(GeneratorsOfGroup(g),w->ActivityPerm(w,n)),GeneratorsOfGroup(g));
        q := GroupHomomorphismByFunction(g,q,w->ActivityPerm(w,n),false,x->ImagesRepresentative(h,x));
    else
        q := GroupHomomorphismByFunction(g,q,w->ActivityPerm(w,n));
    fi;
    SetLevelOfEpimorphismFromFRGroup(q,n);
    return q;
end);

InstallMethod(EpimorphismPermGroup, "(FR) for a full FR group and a level",
        [IsFRGroup and HasFullSCData, IsInt],
        function( g, n )
    local gn, q, h;
    if DepthOfFRSemigroup(g)>n then
        gn := FullSCGroup(FullSCVertex(g),FullSCFilter(g),n);
    else
        gn := g;
    fi;
    q := PermGroup(gn,n);
    h := GroupGeneralMappingByImages(q,g,List(GeneratorsOfGroup(gn),w->ActivityPerm(w,n)),GeneratorsOfGroup(gn));
    q := GroupHomomorphismByFunction(g,q,w->ActivityPerm(w,n),false,x->ImagesRepresentative(h,x));
    SetLevelOfEpimorphismFromFRGroup(q,n);
    return q;
end);

BindGlobal("PERMTRANS2COLL@", function(l)
    local i;
    if IsCollection(l) then
        return l;
    else # is a combination of permutations and transformations
        for i in [1..Length(l)] do
            if IsPerm(l[i]) then l[i] := AsTrans(l[i]); fi;
        od;
        return l;
    fi;
end);

BindGlobal("TRANSMONOID@", function(g,n,gens,filt,fullconstr,mconstr,constr,subconstr,activity)
    local s;
    if ForAny(filt,x->x(g)) then
        s := gens(g);
    elif HasFullSCData(g) then
        s := gens(fullconstr(FullSCVertex(g),FullSCFilter(g),n));
    else
        TryNextMethod();
    fi;
    if s=[] then # GAP hates monoids and semigroups with 0 generators
        return subconstr(mconstr(constr([1..Size(AlphabetOfFRSemigroup(g))^n])),[]);
    fi;
    return mconstr(PERMTRANS2COLL@(List(s,x->activity(x,n))));
end);

InstallMethod(TransformationMonoid, "(FR) for a f.g. FR monoid and a level",
        [IsFRMonoid, IsInt],
        function(g, n)
    return TRANSMONOID@(g,n,GeneratorsOfMonoid,[HasGeneratorsOfMonoid,HasGeneratorsOfGroup],FullSCMonoid,Monoid,Transformation,Submonoid,ActivityTransformation);
end);

InstallMethod(TransMonoid, "(FR) for a f.g. FR monoid and a level",
        [IsFRMonoid, IsInt],
        function(g, n)
    return TRANSMONOID@(g,n,GeneratorsOfMonoid,[HasGeneratorsOfMonoid,HasGeneratorsOfGroup],FullSCMonoid,Monoid,Trans,Submonoid,Activity);
end);

InstallMethod(EpimorphismTransformationMonoid, "(FR) for a f.g. FR monoid and a level",
        [IsFRMonoid, IsInt],
        function(g, n)
    local q, f;
    q := TransformationMonoid(g,n);
    f := MagmaHomomorphismByFunctionNC(g,q,w->ActivityTransformation(w,n));
    f!.prefun := x->Error("Factorization not implemented in monoids");
    return f;
end);

InstallMethod(EpimorphismTransMonoid, "(FR) for a f.g. FR monoid and a level",
        [IsFRMonoid, IsInt],
        function(g, n)
    local q, f;
    q := TransMonoid(g,n);
    f := MagmaHomomorphismByFunctionNC(g,q,w->Activity(w,n));
    f!.prefun := x->Error("Factorization not implemented in monoids");
    return f;
end);

InstallMethod(TransformationSemigroup, "(FR) for a f.g. FR semigroup and a level",
        [IsFRSemigroup, IsInt],
        function(g, n)
    return TRANSMONOID@(g,n,GeneratorsOfSemigroup,[HasGeneratorsOfSemigroup,HasGeneratorsOfMonoid,HasGeneratorsOfGroup],FullSCSemigroup,Semigroup,Transformation,Subsemigroup,ActivityTransformation);
end);

InstallMethod(TransSemigroup, "(FR) for a f.g. FR semigroup and a level",
        [IsFRSemigroup, IsInt],
        function( g, n )
    return TRANSMONOID@(g,n,GeneratorsOfSemigroup,[HasGeneratorsOfSemigroup,HasGeneratorsOfMonoid,HasGeneratorsOfGroup],FullSCSemigroup,Semigroup,Trans,Subsemigroup,Activity);
end);

InstallMethod(EpimorphismTransformationSemigroup, "(FR) for a f.g. FR semigroup and a level",
        [IsFRSemigroup, IsInt],
        function( g, n )
    local q ,f;
    q := TransformationSemigroup(g,n);
    f := MagmaHomomorphismByFunctionNC(g,q,w->ActivityTransformation(w,n));
    f!.prefun := x->Error("Factorization not implemented in semigroups");
    return f;
end);

InstallMethod(EpimorphismTransSemigroup, "(FR) for a f.g. FR semigroup and a level",
        [IsFRSemigroup, IsInt],
        function( g, n )
    local q ,f;
    q := TransSemigroup(g,n);
    f := MagmaHomomorphismByFunctionNC(g,q,w->Activity(w,n));
    f!.prefun := x->Error("Factorization not implemented in semigroups");
    return f;
end);

InstallMethod(PcGroup, "(FR) for an FR group and a level",
        [IsFRGroup, IsInt],
        function(g,n)
    local q;
    q := Image(IsomorphismPcGroup(PermGroup(g,n)));
    if IsPGroup(VertexTransformations(g)) then
        SetPrimePGroup(q,PrimePGroup(VertexTransformations(g)));
    fi;
    return q;
end);

InstallMethod(EpimorphismPcGroup, "(FR) for an FR group and a level",
        [IsFRGroup, IsInt],
        function(g,n)
    local q;
    q := EpimorphismPermGroup(g,n);
    q := q*IsomorphismPcGroup(Image(q));
    if IsPGroup(VertexTransformations(g)) then
        SetPrimePGroup(Range(q),PrimePGroup(VertexTransformations(g)));
    fi;
    return q;
end);

InstallMethod(KernelOfMultiplicativeGeneralMapping, "(FR) for an epimorphism to perm or pc group",
        [IsGroupHomomorphism and HasLevelOfEpimorphismFromFRGroup],
        f->LevelStabilizer(Source(f),LevelOfEpimorphismFromFRGroup(f)));
#############################################################################

#############################################################################
##
#P IsContracting
#A NucleusOfFRSemigroup
#A NucleusMachine
##
InstallMethod(IsContracting, "(FR) for an FR semigroup",
        [IsFRSemigroup],
        function(G)
    local N;
    N := NucleusOfFRSemigroup(G);
    return IsCollection(N) and IsFinite(N);
end);

InstallMethod(NucleusOfFRSemigroup, "(FR) for an FR semigroup",
        [IsFRSemigroup],
        G->NUCLEUS@(GeneratorsOfSemigroup(G)));

InstallMethod(NucleusMachine, "(FR) for an FR semigroup",
        [IsFRSemigroup],
        G->AsMealyMachine(NucleusOfFRSemigroup(G)));

BindGlobal("ADJACENCYBASESWITHONE@",
        function(nuke)
    local seen, i, j, a, len, u, bases, basepos, machine, skip, addelt;
    
    addelt := function(new)
        local i;
        i := 1;
        while i <= Length(bases) do
            if IsSubset(bases[i],new) then
                return false;
            elif IsSubset(new,bases[i]) then
                Remove(bases,i);
                if basepos >= i then basepos := basepos-1; fi;
            else
                i := i+1;
            fi;
        od;
        Add(bases,new);
        return true;
    end;
    
    nuke := Set(nuke);
    machine := AsMealyMachine(nuke);
    
    seen := [[[1..Length(nuke)],[],false]];
    bases := [];
    len := 1;
    basepos := 1;
    while len <= Length(seen) do
        if seen[len][3] then len := len+1; continue; fi;
        for i in AlphabetOfFRObject(machine) do
            u := Set(seen[len][1],x->Transition(machine,x,i));
            a := Concatenation(seen[len][2],[i]);
            skip := false;
            for j in [1..Length(seen)] do
                if a{[1..Length(seen[j][2])]}=seen[j][2] then # parent
                    if seen[j][1]=u then
                        addelt(u);
                        skip := true;
                        break;
                    fi;
                elif j > len then
                    if IsSubset(seen[j][1],u) then skip := true; break; fi;
                fi;
            od;
            Add(seen,[u,a,skip]);
        od;
        len := len+1;
    od;
    
    basepos := 1;
    while basepos <= Length(bases) do
        for i in AlphabetOfFRObject(machine) do
            addelt(Set(bases[basepos],x->Transition(machine,x,i)));
        od;
        basepos := basepos+1;
    od;
    return [bases,nuke,List(bases,x->nuke{x})];
end);

InstallMethod(AdjacencyBasesWithOne, "(FR) for a nucleus",
        [IsFRElementCollection],
        L->ADJACENCYBASESWITHONE@(L)[3]);

InstallMethod(AdjacencyBasesWithOne, "(FR) for an FR semigroup",
        [IsFRSemigroup],
        G->ADJACENCYBASESWITHONE@(NucleusOfFRSemigroup(G))[3]);

BindGlobal("ADJACENCYPOSET@",
        function(nuke)
    local b, c, x, y, elements, oldelements, rel, bases, dom;
    
    bases := ADJACENCYBASESWITHONE@(nuke);
    nuke := bases[2];
    bases := bases[1];
    
    elements := [];
    for b in bases do
#        for x in b do # that would be to include adjacent tiles in the relation
#            c := b "/" nuke[x];
            c := b;
            if not c in elements then
                oldelements := ShallowCopy(elements);
                AddSet(elements,c);
                for y in oldelements do
                    AddSet(elements,Intersection(y,c));
                od;
            fi;
#        od;
    od;
    dom := Domain(List(elements,x->nuke{x}));
    rel := [];
    for b in elements do for c in elements do
        if IsSubset(b,c) then Add(rel,Tuple([nuke{b},nuke{c}])); fi;
    od; od;
    return BinaryRelationByElements(dom,rel);
end);

InstallMethod(AdjacencyPoset, "(FR) for a nucleus",
        [IsFRElementCollection],
        ADJACENCYPOSET@);

InstallMethod(AdjacencyPoset, "(FR) for an FR semigroup",
        [IsFRSemigroup],
        G->ADJACENCYPOSET@(NucleusOfFRSemigroup(G)));
#############################################################################

#############################################################################
##
#M  Degree
##
BindGlobal("FILTERCOMPARE@", function(G,filter)
    if FullSCFilter(G)=IsFRObject then
        TryNextMethod();
    fi;
    return Position(FILTERORDER@,FullSCFilter(G))<=Position(FILTERORDER@,filter);
end);

InstallMethod(DegreeOfFRSemigroup, "(FR) for a self-similar semigroup",
        [IsFRSemigroup],
        G->Maximum(List(GeneratorsOfSemigroup(G),DegreeOfFRElement)));
InstallMethod(Degree, [IsFRSemigroup], DegreeOfFRSemigroup);
InstallMethod(DegreeOfFRSemigroup, "(FR) for a full SC semigroup",
        [IsFRSemigroup and HasFullSCData],
        function(G)
    if IsTrivial(G) then
        return -1;
    elif IsFinitaryFRSemigroup(G) then
        return 0;
    elif IsBoundedFRSemigroup(G) then
        return 1;
    else
        return infinity;
    fi;
end);

InstallMethod(IsFinitaryFRSemigroup, "(FR) for a self-similar semigroup",
        [IsFRSemigroup],
        G->ForAll(GeneratorsOfSemigroup(G),IsFinitaryFRElement));
InstallMethod(IsFinitaryFRSemigroup, "(FR) for a full SC semigroup",
        [IsFRSemigroup and HasFullSCData],
        G->FILTERCOMPARE@(G,IsFinitaryFRElement));

InstallMethod(IsWeaklyFinitaryFRSemigroup, "(FR) for a self-similar semigroup",
        [IsFRSemigroup],
        G->ForAll(GeneratorsOfSemigroup(G),IsWeaklyFinitaryFRElement));
InstallTrueMethod(IsFinitaryFRSemigroup, IsWeaklyFinitaryFRSemigroup);

InstallMethod(DepthOfFRSemigroup, "(FR) for a self-similar semigroup",
        [IsFRSemigroup],
        G->Maximum(List(GeneratorsOfSemigroup(G),DepthOfFRElement)));
InstallMethod(Depth, [IsFRSemigroup], DepthOfFRSemigroup);

InstallMethod(IsBoundedFRSemigroup, "(FR) for a self-similar semigroup",
        [IsFRSemigroup],
        G->ForAll(GeneratorsOfSemigroup(G),IsBoundedFRElement));
InstallMethod(IsBoundedFRSemigroup, "(FR) for a full SC semigroup",
        [IsFRSemigroup and HasFullSCData],
        G->FILTERCOMPARE@(G,IsBoundedFRElement));

InstallMethod(IsPolynomialGrowthFRSemigroup, "(FR) for a self-similar semigroup",
        [IsFRSemigroup],
        G->ForAll(GeneratorsOfSemigroup(G),IsPolynomialGrowthFRElement));
InstallMethod(IsPolynomialGrowthFRSemigroup, "(FR) for a full SC semigroup",
        [IsFRSemigroup and HasFullSCData],
        G->FILTERCOMPARE@(G,IsPolynomialGrowthFRElement));

InstallMethod(IsFiniteStateFRSemigroup, "(FR) for a self-similar semigroup",
        [IsFRSemigroup],
        G->ForAll(GeneratorsOfSemigroup(G),IsFiniteStateFRElement));
InstallMethod(IsFiniteStateFRSemigroup, "(FR) for a full SC semigroup",
        [IsFRSemigroup and HasFullSCData],
        G->FILTERCOMPARE@(G,IsFiniteStateFRElement));
#############################################################################

#############################################################################
##
#M  IsTorsionGroup
#M  IsTorsionFreeGroup
#M  IsAmenableGroup
#M  IsVirtuallySimpleGroup
#M  IsSQUniversal
#M  IsResiduallyFinite
#M  IsJustInfinite
##
InstallTrueMethod(IsResiduallyFinite, IsFinite);
InstallTrueMethod(IsResiduallyFinite, IsFreeGroup);
InstallMethod(IsResiduallyFinite, "(FR) for an FR group",
        [IsFRGroup],
        function(G)
    return IsFinite(AlphabetOfFRSemigroup(G)) or IsResiduallyFinite(VertexTransformations(G));
end);

InstallMethod(IsJustInfinite, "(FR) for a free group",
        [IsFreeGroup],
        G->RankOfFreeGroup(G)=1);
InstallMethod(IsJustInfinite, "(FR) for a finite group",
        [IsGroup and IsFinite],
        ReturnFalse);
InstallMethod(IsJustInfinite, "(FR) for a f.p. group",
        [IsFpGroup],
        function(G)
    if 0 in AbelianInvariants(G) and not IsCyclic(G) then
        return false;
    fi;
    if IsFinite(G) then
        return false;
    fi;
    TryNextMethod();
end);
InstallMethod(IsJustInfinite, "(FR) for a FR group",
        [IsFRGroup],
        function(G)
    local K;
    K := BranchingSubgroup(G);
    if K=fail then
        TryNextMethod();
    fi;
    return Index(G,K)<infinity and not 0 in AbelianInvariants(K);
end);

InstallMethod(IsSQUniversal, "(FR) for a free group",
        [IsFreeGroup],
        G->RankOfFreeGroup(G)>=2);
InstallMethod(IsSQUniversal, "(FR) for a finite object",
        [IsFinite],
        ReturnFalse);
InstallMethod(IsSQUniversal, "(FR) for an amenable group",
        [IsGroup],
        function(G)
    if HasIsAmenableGroup(G) and IsAmenableGroup(G) then
        return false;
    fi;
    TryNextMethod();
end);

BindGlobal("TORSIONSTATES@", function(g)
    local s, todo, i, j, x, y;
    todo := [g];
    i := 1;
    while i <= Length(todo) do
        if Order(todo[i])=infinity then
            return fail;
        fi;
        x := DecompositionOfFRElement(todo[i]);
        for j in Cycles(PermList(x[2]),AlphabetOfFRObject(g)) do
            y := Product(x[1]{j});
            if not y in todo then
                Add(todo,y);
            fi;
        od;
        i := i+1;
    od;
    return todo;
end);

BindGlobal("TORSIONLIMITSTATES@", function(L)
    local s, d, dd, S, oldS, i, x;
    s := [];
    for i in L do
        x := TORSIONSTATES@(i);
        if x=fail then return fail; fi;
        UniteSet(s,x);
    od;
    d := [];
    for i in s do
        x := DecompositionOfFRElement(i);
        dd := [];
        for i in Cycles(PermList(x[2]),AlphabetOfFRObject(L[1])) do
            Add(dd,Position(s,Product(x[1]{i})));
        od;
        Add(d,dd);
    od;
    S := [1..Length(s)];
    repeat
        oldS := S;
        S := Union(d{S});
    until oldS=S;
    return Set(s{S});
end);

BindGlobal("TORSIONNUCLEUS@", function(G)
    local s, olds, news, gens, i, j;

    gens := Set(GeneratorsOfSemigroup(G));
    s := TORSIONLIMITSTATES@(gens);
    if s=fail then return fail; fi;
    olds := [];
    repeat
        news := Difference(s,olds);
        olds := ShallowCopy(s);
        for i in news do
            for j in gens do AddSet(s,i*j); od;
        od;
        s := TORSIONLIMITSTATES@(s);
        if s=fail then return fail; fi;
        Info(InfoFR, 2, "TorsionNucleus: The nucleus contains at least ",s);
    until olds=s;
    return s;
end);

InstallMethod(IsTorsionGroup, "(FR) for a self-similar group",
        [IsFRGroup],
        function(G)
    Info(InfoFR,1,"Beware! This code has not been tested nor proven valid!");
    return TORSIONNUCLEUS@(G)<>fail;
end);

InstallMethod(IsTorsionFreeGroup, "(FR) for a self-similar group",
        [IsFRGroup],
        function(G)
    local iter, n, g;
    if IsBoundedFRSemigroup(G) and ForAll(AbelianInvariants(G),IsZero)
       and IsAbelian(VertexTransformations(G)) then
        return true;
    fi;
    iter := Iterator(G);
    n := 0;
    # !!! have to be much more subtle!!! is there a finite set of
    # infinite-order elements such that for all elements x in G,
    # a stable state of some x^n belongs to the set?
    while true do
        g := NextIterator(iter);
        if IsOne(g) then continue; fi;
        if Order(g)<infinity then return false; fi;
        n := n+1;
        if RemInt(n,100)=0 then
            Info(InfoFR,2,"IsTorsionFreeGroup: size is at least ",n);
        fi;
    od;
end);

InstallTrueMethod(IsTorsionFreeGroup, IsFreeGroup);

InstallMethod(IsSolvableGroup, [IsFreeGroup],
        function(G)
    return RankOfFreeGroup(G)<=1;
end);

InstallTrueMethod(IsAmenableGroup, IsGroup and IsBoundedFRSemigroup);
InstallTrueMethod(IsAmenableGroup, IsGroup and IsFinite);
InstallTrueMethod(IsAmenableGroup, IsSolvableGroup);

InstallMethod(IsAmenableGroup, [IsFreeGroup],
        G->RankOfFreeGroup(G)<=1);
#!!! could be much more subtle, e.g. handling small cancellation groups
#############################################################################

#############################################################################
##
#F  FRGroup
#F  FRSemigroup
#F  FRMonoid
##
BindGlobal("STRING_ATOM2GAP@", function(s)
    local stream, result;
    stream := InputTextString(Concatenation(s,";"));
    result := READ_COMMAND(stream,true);
    CloseStream(stream);
    return result;
end);
BindGlobal("STRING_WORD2GAP@", function(gens,s_generator,data,w)
    local s, f, i;
    s := "CallFuncList(function() local ";
    Append(s,gens[1]);
    for i in [2..Length(gens)] do Append(s,","); Append(s,gens[i]); od;
    Append(s,";");
    for i in [1..Length(gens)] do
        Append(s,Concatenation(gens[i],":=",s_generator,"(",data.holdername,")[",String(i),"];"));
    od;
    Append(s,"return "); Append(s,w); Append(s,";end,[])");
    return STRING_ATOM2GAP@(s);
end);
BindGlobal("STRING_TRANSFORMATION2GAP@", function(t,data)
    local p;
    p := STRING_ATOM2GAP@(t);
    if IsPerm(p) then
        p := ListPerm(p);
    elif IsTransformation(p) then
        p := ImageListOfTransformation(p);
    elif IsTrans(p) then
        p := ListTrans(p);
    fi;
    data.degree := Maximum(data.degree,Length(p),MaximumList(p,0));
    return p;
end);
BindGlobal("RANDOMNAME@", function()
    return List([1..10],i->Random("ABCDEFGHIJKLMNOPQRSTUVWXYZ"));
end);
BindGlobal("STRING_GROUP@", function(freecreator, s_generator, creator, arg)
    local temp, i, gens, states, action, mgens, data, Error, category;
    
    Error := function(arg)
        if IsBound(data) then
            MakeReadWriteGlobal(data.holdername); Unbind(data.holdername);
        fi;
        CallFuncList(VALUE_GLOBAL("Error"),arg);
    end;
    
    if not IsString(arg[Length(arg)]) then
        category := Remove(arg);
    else
        category := IsFRObject;
    fi;
    
    if arg=[] or not ForAll(arg,IsString) then
        Error("<arg> should be a non-empty sequence of strings\n");
    fi;
    temp := List(arg, x->SplitString(x,"="));
    if ForAny(temp,x->Size(x)<>2) then
        Error("<arg> should have the form g=...\n");
    fi;
    gens := List(temp, x->x[1]);
    if Size(Set(gens)) <> Size(gens) then
        Error("all generators should have a distinct name\n");
    fi;
    states := [];
    action := [];
    data := rec(degree := -1, holdername := RANDOMNAME@(),
                holder := freecreator(gens));
    BindGlobal(data.holdername, data.holder);

    for temp in List(temp,x->x[2]) do
        temp := SplitString(temp,"<");
        if Size(temp)=1 then
            Add(action,STRING_TRANSFORMATION2GAP@(temp[1],data));
            Add(states,[]);
        elif Size(temp)=2 and temp[1]="" then
            temp := SplitString(temp[2],">");
            if Size(temp)>2 then
                Error("<arg> should have the form g=<...>...\n");
            elif Size(temp)=1 then
                Add(action,[]);
            else
                Add(action,STRING_TRANSFORMATION2GAP@(temp[2],data));
            fi;
            temp := STRING_WORD2GAP@(gens,s_generator,data,Concatenation("[",temp[1],"]"));
            for i in [1..Length(temp)] do
                if not IsBound(temp[i]) or temp[i]=1 then
                    if IsMagmaWithOne(data.holder) then
                        temp[i] := One(data.holder);
                    else
                        Error("coordinate may not be one for a semigroup");
                    fi;
                fi;
            od;
            Add(states,temp);
            data.degree := Maximum(data.degree,Size(temp));
        else
            Error("<arg> should have the form g=<...\n");
        fi;
    od;
    
    for i in action do
        for temp in [1..data.degree] do
            if not IsBound(i[temp]) then
                i[temp] := temp;
            fi;
        od;
    od;
    for i in states do
        while Length(i)<data.degree do
            if IsMagmaWithOne(data.holder) then
                Add(i,One(data.holder));
            else
                Error("coordinate may not be one for a semigroup");
            fi;
        od;
    od;
    if freecreator=FreeGroup and not ForAll(action,ISINVERTIBLE@) then
        Error("<arg> should have the form g=<...>permutation\n");
    fi;
    temp := FRMachine(data.holder,states,action);
    i := Set(GeneratorsOfFRMachine(temp));
    if HasOne(data.holder) then
        AddSet(i,One(data.holder));
    fi;
    mgens := List(GeneratorsOfFRMachine(temp),x->FRElement(temp,x));
    if category=IsFRMealyElement then
        List(mgens,UnderlyingMealyElement); # set attribute
    else
        if (ForAll(states,s->IsSubset(i,s)) and category<>IsFRElement) or category=IsMealyElement then # if all transitions are generators,
            mgens := List(mgens,AsMealyElement); # default is Mealy elements
            for i in [1..Length(gens)] do
                SetName(mgens[i],gens[i]);
            od;
        fi;
    fi;
    i := creator(mgens);
    SetAlphabetOfFRSemigroup(i,AlphabetOfFRObject(temp));
    SetIsStateClosed(i,true);
    MakeReadWriteGlobal(data.holdername); UnbindGlobal(data.holdername);
    return i;
end);

InstallGlobalFunction(FRGroup,
        function(arg)
    return STRING_GROUP@(FreeGroup, "GeneratorsOfGroup", Group, arg);
end);

InstallGlobalFunction(FRMonoid,
        function(arg)
    return STRING_GROUP@(FreeMonoid, "GeneratorsOfMonoid", Monoid, arg);
end);

InstallGlobalFunction(FRSemigroup,
        function(arg)
    return STRING_GROUP@(FreeSemigroup, "GeneratorsOfSemigroup", Semigroup, arg);
end);
#############################################################################

#############################################################################
##
#F  FRGroupByVirtualEndomorphism
##
InstallMethod(FRGroupByVirtualEndomorphism, "(FR) for a virtual endomorphism",
        [IsGroupHomomorphism],
        f->FRGroupByVirtualEndomorphism(f,RightTransversal(Range(f),Source(f))));

InstallMethod(FRGroupByVirtualEndomorphism, "(FR) for a virtual endomorphism and a transversal",
        [IsGroupHomomorphism, IsList],
        function(phi,T)
    local F, G, M, pi, f, a, y, out, trans, o, t, i, fam;
    G := Range(phi);
    if IsFinitelyGeneratedGroup(G) and not ValueOption("MealyElement")=true then
        pi := EpimorphismFromFreeGroup(G);
        F := Source(pi);
        trans := []; out := [];
        for f in GeneratorsOfGroup(G) do
            t := [];
            o := [];
            for a in T do
                y := a*f;
                if IsRightTransversal(T) then
                    i := PositionCanonical(T,y);
                else
                    i := First([1..Length(T)],i->y*T[i] in Source(phi));
                fi;
                Add(t,PreImagesRepresentative(pi,(y/T[i])^phi));
                Add(o,i);
            od;
            Add(trans,t);
            Add(out,o);
        od;
        M := FRMachineNC(FRMFamily([1..Index(G,Source(phi))]),F,trans,out);
        F := Group(List(GeneratorsOfGroup(G),g->FRElement(M,PreImagesRepresentative(pi,g))));
        SetCorrespondence(F,GroupHomomorphismByImagesNC(G,F,
                GeneratorsOfGroup(G),GeneratorsOfGroup(F)));
        return F;
    else
        fam := FREFamily([1..Length(T)]);
        pi := function(g)
            local i, states, trans, out, t, o, y, a, p;
            states := [g];
            trans := [];
            out := [];
            i := 1;
            while i <= Length(states) do
                t := [];
                o := [];
                for a in T do
                    y := a*states[i];
                    if IsRightTransversal(T) then
                        p := PositionCanonical(T,y);
                    else
                        p := First([1..Length(T)],i->y*T[i] in Source(phi));
                    fi;
                    if p=fail then return fail; fi;
                    Add(o,p);
                    y := (y/T[p])^phi;
                    p := Position(states,y);
                    if p=fail then
                        Add(states,y);
                        Add(t,Length(states));
                    else
                        Add(t,p);
                    fi;
                od;
                Add(trans,t);
                Add(out,o);
                if not ISINVERTIBLE@(o) then return fail; fi;
                i := i+1;
                if RemInt(i,10)=0 then
                    Info(InfoFR, 2, "FRGroupByVirtualEndomorphism: at least ",i," states");
                fi;
            od;
            i := MealyElementNC(fam,trans,out,1);
            return i;
        end;
        if IsFinitelyGeneratedGroup(G) then
            F := Group(List(GeneratorsOfGroup(G),pi));
        else
            F := FullSCGroup([1..Index(G,Source(phi))],IsFRObject);
        fi;
        SetCorrespondence(F,GroupHomomorphismByFunction(G,F,pi));
        return F;
    fi;
end);

InstallMethod(VirtualEndomorphism, "(FR) for a FR group and a vertex",
        [IsFRGroup,IsObject],
        function(G,v)
    return GroupHomomorphismByFunction(Stabilizer(G,v),G,g->State(g,v));
end);
#############################################################################

#############################################################################
##
#F  IsomorphismFRGroup( <arg> )
#F  IsomorphismMealyGroup( <arg> )
##
BindGlobal("ISOMORPHICFRGENS@", function(g,iso)
    local m, e, i, f, gens;

    m := fail;
    gens := [];
    for e in g do
        e := iso(e);
        if m=fail then
            m := UnderlyingFRMachine(e);
        fi;
        if IsIdenticalObj(m,UnderlyingFRMachine(e)) then
            Add(gens,e);
        elif m=UnderlyingFRMachine(e) then
            Add(gens,FRElement(m,InitialState(e)));
        else
            f := SubFRMachine(m,UnderlyingFRMachine(e));
            if f=fail then
                m := m+UnderlyingFRMachine(e);
                for i in [1..Length(gens)] do
                    gens[i] := FRElement(m,InitialState(gens[i])^Correspondence(m)[1]);
                od;
                Add(gens,FRElement(m,InitialState(e)^Correspondence(m)[2]));
            else
                Add(gens,FRElement(m,InitialState(e)^f));
            fi;
        fi;
    od;
    m := Minimized(m);
    return [m,List(gens,g->FRElement(m,InitialState(g)^Correspondence(m)))];
end);

InstallMethod(FRMachineFRGroup, "(FR) for a state-closed group",
        [IsFRGroup],
        function(G)
    return ISOMORPHICFRGENS@(GeneratorsOfGroup(G),AsGroupFRElement)[1];
end);

InstallMethod(FRMachineFRMonoid, "(FR) for a state-closed monoid",
        [IsFRMonoid],
        function(G)
    return ISOMORPHICFRGENS@(GeneratorsOfMonoid(G),AsMonoidFRElement)[1];
end);

InstallMethod(FRMachineFRSemigroup, "(FR) for a state-closed semigroup",
        [IsFRSemigroup],
        function(G)
    return ISOMORPHICFRGENS@(GeneratorsOfSemigroup(G),AsSemigroupFRElement)[1];
end);

InstallMethod(MealyMachineFRGroup, "(FR) for a state-closed group",
        [IsFRGroup],
        function(G)
    return ISOMORPHICFRGENS@(GeneratorsOfGroup(G),AsMealyElement)[1];
end);

InstallMethod(MealyMachineFRMonoid, "(FR) for a state-closed monoid",
        [IsFRMonoid],
        function(G)
    return ISOMORPHICFRGENS@(GeneratorsOfMonoid(G),AsMealyElement)[1];
end);

InstallMethod(MealyMachineFRSemigroup, "(FR) for a state-closed semigroup",
        [IsFRSemigroup],
        function(G)
    return ISOMORPHICFRGENS@(GeneratorsOfSemigroup(G),AsMealyElement)[1];
end);

InstallMethod(IsomorphismFRGroup, "(FR) for a self-similar group",
        [IsFRGroup],
        function(G)
    local gens;
    gens := ISOMORPHICFRGENS@(GeneratorsOfGroup(G),AsGroupFRElement)[2];
    return GroupHomomorphismByImagesNC(G,Group(gens),GeneratorsOfGroup(G),gens);
end);

InstallMethod(IsomorphismFRMonoid, "(FR) for a self-similar monoid",
        [IsFRMonoid],
        function(G)
    return MagmaHomomorphismByFunctionNC(G,
                   Monoid(ISOMORPHICFRGENS@(GeneratorsOfMonoid(G),AsMonoidFRElement)[2]),AsMonoidFRElement);
end);

InstallMethod(IsomorphismFRSemigroup, "(FR) for a self-similar semigroup",
        [IsFRSemigroup],
        function(G)
    return MagmaHomomorphismByFunctionNC(G,
                   Semigroup(ISOMORPHICFRGENS@(GeneratorsOfSemigroup(G),AsSemigroupFRElement)[2]),AsSemigroupFRElement);
end);

BindGlobal("ISOMORPHISMMEALYXXX@", function(G,gens,cons)
    local H, Hgens, m, states, g;
    states := [];
    Hgens := ShallowCopy(gens(G));
    for g in Hgens do
        if not IsMealyElement(g) then
            Add(states,g);
        fi;
    od;
    if states=[] then
        return IdentityMapping(G);
    fi;
    states := States(states);
    m := MAKEMEALYMACHINE@(FamilyObj(states[1]),states,fail);
    for g in [1..Length(Hgens)] do
        if not IsMealyElement(Hgens[g]) then
            Hgens[g] := FRElement(m,Position(states,Hgens[g]));
        fi;
    od;
    H := cons(Hgens);
    return MagmaHomomorphismByImagesNC(G,H,gens(H));
end);

InstallMethod(IsomorphismMealyGroup, "(FR) for a self-similar group",
        [IsFRGroup],
        G->ISOMORPHISMMEALYXXX@(G,GeneratorsOfGroup,Group));

InstallMethod(IsomorphismMealyMonoid, "(FR) for a self-similar monoid",
        [IsFRMonoid],
        G->ISOMORPHISMMEALYXXX@(G,GeneratorsOfMonoid,Monoid));

InstallMethod(IsomorphismMealySemigroup, "(FR) for a self-similar semigroup",
        [IsFRSemigroup],
        G->ISOMORPHISMMEALYXXX@(G,GeneratorsOfSemigroup,Semigroup));
#############################################################################

#############################################################################
##
#F  IsStateClosed
#M  StateClosure
#F  IsRecurrent
#P  IsLevelTransitive
##
InstallMethod(IsStateClosed, "(FR) for a self-similar group",
        [IsFRGroup and HasGeneratorsOfGroup],
        function(G)
    local g, x, b;
    SEARCH@.INIT(G);
    for g in GeneratorsOfGroup(G) do for x in DecompositionOfFRElement(g)[1] do
        while true do
            b := SEARCH@.IN(x,G);
            if b=false then return false; elif b=true then break; fi;
            if SEARCH@.EXTEND(G)=fail then return fail; fi;
            Info(InfoFR, 3, "IsStateClosed: searching at level ",G!.FRData.level," and in sphere of radius ",G!.FRData.radius);
        od;
    od; od;
    return true;
end);

InstallMethod(IsStateClosed, "(FR) for a FR monoid",
        [IsFRMonoid and HasGeneratorsOfMonoid],
        function(E)
    return ForAll(GeneratorsOfMonoid(E),x->IsSubset(E,DecompositionOfFRElement(x)[1]));
end);

InstallMethod(IsStateClosed, "(FR) for a FR semigroup",
        [IsFRSemigroup and HasGeneratorsOfSemigroup],
        function(E)
    return ForAll(GeneratorsOfSemigroup(E),x->IsSubset(E,DecompositionOfFRElement(x)[1]));
end);

InstallMethod(StateClosure, "(FR) for a self-similar group",
        [IsFRGroup and HasGeneratorsOfGroup],
        function(G)
    local H;
    if HasIsStateClosed(G) and IsStateClosed(G) then return G; fi;
    H := Group(States(GeneratorsOfGroup(G)));
    SetIsStateClosed(H,true);
    return H;
end);

InstallMethod(StateClosure, "(FR) for a self-similar monoid",
        [IsFRMonoid and HasGeneratorsOfMonoid],
        function(G)
    local H;
    if HasIsStateClosed(G) and IsStateClosed(G) then return G; fi;
    H := Monoid(States(GeneratorsOfMonoid(G)));
    SetIsStateClosed(H,true);
    return H;
end);

InstallMethod(StateClosure, "(FR) for a self-similar semigroup",
        [IsFRSemigroup and HasGeneratorsOfSemigroup],
        function(G)
    local H;
    if HasIsStateClosed(G) and IsStateClosed(G) then return G; fi;
    H := Semigroup(States(GeneratorsOfSemigroup(G)));
    SetIsStateClosed(H,true);
    return H;
end);

InstallMethod(IsRecurrentFRSemigroup, "(FR) for a self-similar group",
        [IsFRGroup],
        function(G)
    if not IsStateClosed(G) then return false; fi;
    return ForAll(AlphabetOfFRSemigroup(G),i->IsSubgroup(StabilizerImage(G,i),G));
end);

InstallMethod(IsLevelTransitive, "(FR) for a self-similar group",
        [IsFRGroup],
        function(G)
    local level, size, iter;
    if not IsTransitive(TopVertexTransformations(G),AlphabetOfFRSemigroup(G)) then
        return false;
    fi;
    if IsFinitaryFRSemigroup(G) then
        return false;
    fi;
    if IsRecurrentFRSemigroup(G) then
        return true;
    fi;
    level := 0; size := 0;
    iter := Iterator(G);
    repeat
        if IsDoneIterator(iter) then # finite group
            return false;
        fi;
        if IsLevelTransitive(NextIterator(iter)) then
            return true;
        fi;
        size := size+1;
        if size > 2^level then
            level := level+1;
            if not IsTransitive(PermGroup(G,level),[1..Size(AlphabetOfFRSemigroup(G))^level]) then
                return false;
            fi;
        fi;
    until false;
end);
#############################################################################

#############################################################################
##
#F  StabilizerImage
##
InstallMethod(StabilizerImage, "(FR) for a self-similar group",
        [IsFRGroup, IsObject],
        function(G,v)
    local H;
    if HasIsRecurrentFRSemigroup(G) and IsRecurrentFRSemigroup(G) then
        return G;
    fi;
    H := Group(List(GeneratorsOfGroup(Stabilizer(G,v)),x->State(x,v)));
    if HasIsStateClosed(G) and IsStateClosed(G) then
        SetParent(H,G);
    fi;
    return H;
end);
#############################################################################

#############################################################################
##
#F  Index
##
InstallMethod(Index, "(FR) for two self-similar groups",
        [IsFRGroup, IsFRGroup],
        function(G,H)
    local i;
    if not IsSubgroup(G,H) then return fail; fi;
    i := RightTransversal(G,H);
    if i=fail then return fail; else return Length(i); fi;
end);

InstallMethod(RightCosetsNC, "(FR) for two self-similar groups",
        [IsFRGroup, IsFRGroup],
        function(G,H)
    local trans, b;
    trans := [One(G)];
    SEARCH@.INIT(G);
    SEARCH@.INIT(H);
    repeat
        while SEARCH@.EXTENDTRANSVERSAL(G,H,trans)=fail do
           SEARCH@.ERROR(G,"RightCosets");
        od;
        b := SEARCH@.CHECKTRANSVERSAL(G,H,trans);
        if b=fail then
            return fail;
        elif b=true then
            return List(trans,x->RightCoset(H,x));
        else
            while SEARCH@.EXTEND(G,SEARCH@.QUOTIENT)=fail do
                SEARCH@.ERROR(G,"RightCosets");
            od;
        fi;
        Info(InfoFR, 3, "RightCosets: searching at level ",G!.FRData.level);
    until false;
end);
#############################################################################

#############################################################################
##
#M  NormalClosure( <G>, <U> )
##
InstallMethod(NormalClosure, "(FR) for two FR groups -- avoid using IsFinite",
        [IsFRGroup, IsFRGroup],
        function(G,N)
    local g, gens, n, x;

    SEARCH@.INIT(G);
    gens := ShallowCopy(GeneratorsOfGroup(N));
    for n in gens do
        for g in G!.FRData.sphere[2] do
            x := n^g;
            if not x in N then
                N := ClosureGroup(N, x);
                Info(InfoFR, 2, "NormalClosure has at least ",Size(gens)," generators");
                Add(gens, x);
            fi;
        od;
    od;
    return N;
end);

InstallMethod(DerivedSubgroup, "(FR) for an FR group -- add more generators",
        [IsFRGroup],
        function (G)
    local  D, gens, i, j, g;
    D := TrivialSubgroup( G );
    gens := GeneratorsOfGroup( G );
    for i  in [ 2 .. Length( gens ) ]  do
        g := gens[i];
        for j  in [ 1 .. i - 1 ]  do
            D := ClosureSubgroupNC( D, Comm( g, gens[j] ) );
        od;
        g := g^-1;
        for j  in [ 1 .. i - 1 ]  do
            D := ClosureSubgroupNC( D, Comm( g, gens[j] ) );
        od;
    od;
    D := NormalClosure( G, D );
    if D = G  then return G; else return D; fi;
end);
#############################################################################

#############################################################################
##
#M  NaturalHomomorphismByNormalSubgroup
#M  AbelianInvariants
##
if false then # this is not good -- it assumes the congruence property
InstallMethod(NaturalHomomorphismByNormalSubgroupOp, "(FR) for a FR group and a normal subgroup",
        [IsFRGroup,IsFRGroup],
        function(G,N)
    local d, f;
    SEARCH@.INIT(G);
    d := Index(G,N);
    repeat
        f := G!.FRData.pi*NaturalHomomorphismByNormalSubgroupNC(Image(G!.FRData.pi),Image(G!.FRData.pi,N));
        if Size(Image(f))=d then
            return f;
        else
            while SEARCH@.EXTEND(G,SEARCH@.QUOTIENT)=fail do
                SEARCH@.ERROR(G,"NaturalHomomorphismByNormalSubgroupOp");
            od;
        fi;
        Info(InfoFR, 2, "NaturalHomomorphismByNormalSubgroupOp: extending to level ",G!.FRData.level);
    until false;
end);
else
InstallMethod(FindActionKernel, "(FR) for two FR groups",
        [IsFRGroup,IsFRGroup],
        function(G,N)
    local t, hom;
    t := RightCosets(G,N);
    hom := GroupHomomorphismByFunction(G,SymmetricGroup(Length(t)),function(g)
        return PermList(List(t,x->PositionCanonical(t,x*g)));
    end);
    if IsSolvable(Image(hom)) then
        hom := hom*IsomorphismPcGroup(Image(hom));
    fi;
    return hom;
end);
fi;

InstallMethod(AbelianInvariants, "(FR) for a FR group",
        [IsFRGroup],
        function(G)
    local n, map, rel, sub, sup;
    if IsBoundedFRSemigroup(G) then
        map := EpimorphismGermGroup;
    else
        map := EpimorphismPermGroup;
    fi;
    n := 0;
    repeat
        n := n+1;
        sub := AbelianInvariants(Image(map(G,n)));
        rel := ShortGroupRelations(G,n);
        sup := AbelianInvariants(Source(rel[1])/rel{[2..Length(rel)]});
        Info(InfoFR,2,"AbelianInvariants: searched to level/radius ",n);
    until sub=sup;
    return sup;
#    return AbelianInvariants(G/DerivedSubgroup(G));
end);

InstallMethod(AbelianInvariants, "(FR) for a FR group with preimage data",
        [IsFRGroup and HasFRGroupPreImageData],
        G->AbelianInvariants(FRGroupImageData(G).F));
#############################################################################

#############################################################################
##
#O TreeWreathProduct
##
InstallMethod(TreeWreathProduct, "(FR) for FR semigroups",
        [IsFRGroup and HasGeneratorsOfGroup, IsFRGroup and HasGeneratorsOfGroup, IsObject, IsObject],
        function(g,h,x0,y0)
    local i, srcg, srch, gensg, gensh, one, m;

    srcg := GeneratorsOfGroup(g);
    srch := GeneratorsOfGroup(h);

    if HasUnderlyingFRMachine(g) and HasUnderlyingFRMachine(h) and ForAll(srcg, x->IsIdenticalObj(UnderlyingFRMachine(x),UnderlyingFRMachine(g))) and ForAll(srch, x->IsIdenticalObj(UnderlyingFRMachine(x),UnderlyingFRMachine(h))) then
        m := TreeWreathProduct(UnderlyingFRMachine(g),UnderlyingFRMachine(h),x0,y0);
        gensg := List(GeneratorsOfGroup(g),i->FRElement(m,InitialState(i)^Correspondence(m)[1]));
        gensh := List(GeneratorsOfGroup(h),i->FRElement(m,InitialState(i)^Correspondence(m)[2]));
    else
        one := UnderlyingFRMachine(One(g));
        gensg := [];
        for i in GeneratorsOfGroup(g) do
            m := TreeWreathProduct(UnderlyingFRMachine(i),one,x0,y0);
            Add(gensg,FRElement(m,InitialState(i)^Correspondence(m)[1]));
        od;
        one := UnderlyingFRMachine(One(h));
        gensh := [];
        for i in GeneratorsOfGroup(h) do
            m := TreeWreathProduct(one,UnderlyingFRMachine(i),x0,y0);
            Add(gensh,FRElement(m,InitialState(i)^Correspondence(m)[2]));
        od;
    fi;
    m := Group(Concatenation(gensg,gensh));
    SetCorrespondence(m,[GroupHomomorphismByImagesNC(g,m,GeneratorsOfGroup(g),gensg),GroupHomomorphismByImagesNC(h,m,GeneratorsOfGroup(h),gensh)]);
    return m;
end);

InstallMethod(WeaklyBranchedEmbedding, "(FR) for an FR semigroup",
        [IsFRGroup and HasGeneratorsOfGroup],
        function(g)
    local m, adder, srcg, gens, gensg, i;

    srcg := GeneratorsOfGroup(g);
    adder := AddingMachine(Length(AlphabetOfFRSemigroup(g)));

    if HasUnderlyingFRMachine(g) and ForAll(srcg, x->IsIdenticalObj(UnderlyingFRMachine(x),UnderlyingFRMachine(g))) then
        m := TreeWreathProduct(UnderlyingFRMachine(g),adder,1,1);
        gens := [];
        for i in GeneratorsOfGroup(g) do
            Add(gens,FRElement(m,InitialState(i)^Correspondence(m)[1]));
        od;
        for i in GeneratorsOfFRMachine(adder) do
            Add(gens,FRElement(m,i^Correspondence(m)[2]));
        od;
        m := TENSORPRODUCT@(UnderlyingFRMachine(g),UnderlyingFRMachine(g));
        gensg := List(GeneratorsOfFRMachine(g),x->FRElement(m,x));
    else
        gens := [];
        gensg := [];
        for i in GeneratorsOfGroup(g) do
            m := TENSORPRODUCT@(UnderlyingFRMachine(i),UnderlyingFRMachine(i));
            Add(gensg,FRElement(m,InitialState(i)));
            m := TreeWreathProduct(UnderlyingFRMachine(i),adder,1,1);
            Add(gens,FRElement(m,InitialState(i)^Correspondence(m)[1]));
        od;
        for i in GeneratorsOfFRMachine(adder) do
            Add(gens,FRElement(m,i^Correspondence(m)[2]));
        od;
    fi;
    m := Group(Concatenation(gensg,gens));
    i := GroupHomomorphismByImagesNC(g,m,GeneratorsOfGroup(g),gensg);
    SetIsInjective(i,true);
    return i;
end);

#############################################################################

#############################################################################
##
#O IsBranchingSubgroup
#O BranchingSubgroup
#O IsBranched
##
InstallMethod(IsBranchingSubgroup, "(FR) for an FR group",
        [IsFRGroup],
        function(K)
    local a, g;
    for g in GeneratorsOfGroup(K) do
        for a in AlphabetOfFRSemigroup(K) do
            if not VertexElement(a,g) in K then return false; fi;
        od;
    od;
    return true;
end);

InstallMethod(IsBranched, "(FR) for an FR group",
        [IsFRGroup],
        G->Index(G,BranchingSubgroup(G))<infinity);

InstallTrueMethod(IsWeaklyBranched, IsBranched);
InstallTrueMethod(IsWeaklyBranched, HasBranchingSubgroup);
InstallImmediateMethod(IsSolvableGroup,IsWeaklyBranched,0,ReturnFalse);

InstallMethod(BranchingSubgroup, "(FR) for an FR group",
        [IsFRGroup],
        function(G)
    local r, K;
    r := 1;
    while true do
        K := FindBranchingSubgroup(G,infinity,r);
        if K<>fail then return K; fi;
        r := r+1;
        Info(InfoFR, 3, "BranchingSubgroup: searching at radius ",r);
    od;
end);

InstallMethod(FindBranchingSubgroup, "(FR) for an FR group, a level and a radius",
        [IsFRGroup, IsObject, IsPosInt],
        function(G,level,radius)
    local K, H, g, d, i, l, oldK;
    if not IsRecurrentFRSemigroup(G) then return fail; fi;
    if not IsTransitive(G,AlphabetOfFRSemigroup(G)) then return fail; fi;

    K := G;
    l := 1; while l <= level do
        oldK := K;
        H := Stabilizer(K,AlphabetOfFRSemigroup(G),OnTuples);
        K := TrivialSubgroup(G);
        SEARCH@.INIT(H);
        for i in [2..radius] do
            while not IsBound(H!.FRData.sphere[i]) and SEARCH@.EXTEND(H,SEARCH@.BALL)=fail do
                SEARCH@.ERROR(G,"FindBranchingSubgroup");
            od;
            for g in H!.FRData.sphere[i] do
                d := DecompositionOfFRElement(g);
                if Number(d[1],IsOne)=Size(AlphabetOfFRSemigroup(G))-1 then
                    K := ClosureGroup(K,First(d[1],x->not IsOne(x)));
                fi;
            od;
            i := i+1;
        od;
        if IsTrivial(K) then return fail; fi;
        K := NormalClosure(G,K);
        if IsSubgroup(K,oldK) then break; fi;
        l := l+1;
        Info(InfoFR, 3, "BranchingSubgroup: searching at level ",l);
    od;
    SetParent(K,G);
    SetIsBranchingSubgroup(K,true);
    return K;
end);

InstallMethod(BranchStructure, [IsFRGroup and HasFullSCData],
        function(G)
    local X, Q;
    
    X := AlphabetOfFRSemigroup(G);
    Q := TopVertexTransformations(G);
    return rec(group := TrivialSubgroup(Q),
               quo := GroupHomomorphismByFunction(G,~.group,x->One(~.group)),
               set := X,
               top := Q,
               wreath := WreathProduct(~.group,Q),
               epi := GroupHomomorphismByImages(~.wreath,~.group,GeneratorsOfGroup(~.wreath),List(GeneratorsOfGroup(~.wreath),x->One(Q))));
end);

InstallMethod(BranchStructure, [IsFRGroup],
        function(G)
    local pi, K, Q, W, S, SS, g, d, set, i;
    
    K := BranchingSubgroup(G);
    
    # a shortcut in case it's difficult to compute coset actions
    if false and HasHasCongruenceProperty(G) and HasCongruenceProperty(G) then
        d := 1;
        i := Index(G,K);
        repeat
            pi := EpimorphismPermGroup(G,d);
            d := d+1;
        until Index(Image(pi),Image(pi,K))=i;
        pi := pi*NaturalHomomorphismByNormalSubgroup(Image(pi),Image(pi,K));
    else
        pi := NaturalHomomorphismByNormalSubgroup(G,K);
    fi;

    Q := Image(pi);
    W := WreathProduct(Q,TopVertexTransformations(G));
    S := GeneratorsOfGroup(G);
    set := AlphabetOfFRSemigroup(G);
    SS := [];
    for g in S do
        d := DecompositionOfFRElement(g);
        Add(SS,Product(set,i->(d[1][i]^pi)^Embedding(W,i))*PermList(d[2])^Embedding(W,Length(set)+1));
    od;
    return rec(group := Q,
               quo := pi,
               set := set,
               top := TopVertexTransformations(G),
               wreath := W,
               epi := GroupHomomorphismByImages(Group(SS),Range(pi),SS,List(S,x->x^pi))
               );
end);

#############################################################################

BindGlobal("ASSIGNGENERATORVARIABLES@", function(gens)
    local names, i;
    if ForAny(gens,g->HasName(g) or not IsMealyElement(g)) then
        names := [];
        for i in gens do
            if HasName(i) then
                Add(names,Name(i));
            elif IsMealyElement(i) then
                Add(names,"");
            else
                Add(names,String(InitialState(i)));
            fi;
        od;
    else
        names := List([1..Length(gens)],i->WordAlp("abcdefgh",i));
    fi;
    for i in names do if IS_READ_ONLY_GLOBAL(i) then
        Error("Variable `", i, "' is write protected\n");
    fi; od;
    for i in [1..Length(gens)] do if names[i]<>"" then
        if ISBOUND_GLOBAL(names[i]) then
            Info(InfoWarning + InfoGlobal, 1, "Global variable `", names[i],
                 "' is already defined and will be overwritten");
            UNBIND_GLOBAL(names[i]);
        fi;
        ASS_GVAR(names[i], gens[i]);
    fi; od;
    Info(InfoWarning + InfoGlobal, 1, "Assigned the global variables ", names);
end);

InstallMethod(AssignGeneratorVariables, "(FR) for an FR group",
        [IsFRGroup],
        function(G)
    ASSIGNGENERATORVARIABLES@(GeneratorsOfGroup(G));
end);

InstallMethod(AssignGeneratorVariables, "(FR) for an FR monoid",
        [IsFRMonoid],
        function(G)
    ASSIGNGENERATORVARIABLES@(GeneratorsOfMonoid(G));
end);

InstallMethod(AssignGeneratorVariables, "(FR) for an FR semigroup",
        [IsFRSemigroup],
        function(G)
    ASSIGNGENERATORVARIABLES@(GeneratorsOfSemigroup(G));
end);
#############################################################################

#############################################################################
##
#M LevelStabilizer
##
InstallMethod(LevelStabilizer, "(FR) for an FR group and a level",
        [IsFRGroup, IsInt],
        function(G,n)
    return Stabilizer(G,Cartesian(List([1..n],i->AlphabetOfFRSemigroup(G))),OnTuples);
end);
#############################################################################

#############################################################################
##
#M ConfinalityClasses
##
InstallMethod(GermData, "(FR) for a FR group",
        [IsFRGroup],
        function(G)
    local g, h, p, e,
          src, dst, cs, cd, classes, data, cgens, m, map;

    if not IsBoundedFRSemigroup(G) then
        return fail;
    fi;

    if HasParent(G) and not IsIdenticalObj(G,Parent(G)) and HasGermData(Parent(G)) then
        return GermData(Parent(G));
    fi;

    classes := [];
    data := rec(nucleus := [], nucleusmachine := NucleusMachine(G),
                map := [], machines := []);
    cgens := 0;
    for g in NucleusOfFRSemigroup(G) do
        g := ASINTREP@(g);
        Add(data.nucleus,g);
        h := Germs(g);
        m := [];
        if h<>[] then # not finitary; one germ
            src := h[1][1];
            dst := h[1][1]^g;
            cs := PositionProperty(classes,c->src in c[1]);
            cd := PositionProperty(classes,c->dst in c[1]);
            if cs=fail and cd=fail then
                if src=dst then
                    Add(classes,[[src],[g],[One(g)],[0]]);
                    Add(m,[Length(classes),1]);
                else
                    cgens := cgens+1;
                    Add(classes,[[src,dst],[],[One(g),g],[0,cgens]]);
                    Add(m,cgens);
                fi;
            elif cs=fail then
                cgens := cgens+1;
                Add(classes[cd][1],src);
                p := Position(classes[cd][1],dst);
                Add(classes[cd][3],classes[cd][3][p]/g);
                Add(classes[cd][4],cgens);
                if p<>1 then
                    Add(m,classes[cd][4][p]);
                fi;
                Add(m,-cgens);
            elif cd=fail then
                cgens := cgens+1;
                Add(classes[cs][1],dst);
                p := Position(classes[cs][1],src);
                Add(classes[cs][3],classes[cs][3][p]*g);
                if p<>1 then
                    Add(m,-classes[cs][4][p]);
                fi;
                Add(classes[cs][4],cgens);
                Add(m,cgens);
            elif cs<>cd then # merge classes cs and cd
                cgens := cgens+1;
                Append(classes[cs][1],classes[cd][1]); classes[cd][1] := [];
                for p in [1..Length(classes[cd][3])] do
                    classes[cd][3][p] := g*classes[cd][3][p];
                od;
                classes[cd][4][1] := cgens;
                Append(classes[cs][3],classes[cd][3]); classes[cd][3] := g^-1;
                Append(classes[cs][4],classes[cd][4]); classes[cd][4] := cs;
                for p in [1..Length(classes[cd][2])] do
                    Add(classes[cs][2],classes[cd][2][p]^classes[cd][3]);
                od;
                Error("merge ",cs," ",cd);
            else
                p := Position(classes[cs][1],src);
                if p<>1 then
                    g := classes[cs][3][p]*g;
                    Add(m,-classes[cs][4][p]);
                fi;
                p := Position(classes[cs][1],dst);
                if p<>1 then
                    g := g/classes[cs][3][p];
                    Add(m,classes[cs][4][p]);
                fi;
                if not IsOne(g) then
                    p := Position(classes[cs][2],g);
                    if p=fail then
                        Add(classes[cs][2],g);
                        Add(m,[cs,Length(classes[cs][2])]);
                    else
                        Add(m,[cs,p]);
                    fi;
                fi;
            fi;
        fi;
        Add(data.map,m);
    od;
    src := []; dst := [];
    for cs in [1..Length(classes)] do if classes[cs][1]<>[] then
        p := GroupByGenerators(classes[cs][2],One(G));
        Size(p); # so that IsomorphismPermGroup succeeds
        if cgens>0 then
            p := IsomorphismPermGroup(p);
            p := p*IsomorphismPcpGroup(Range(p));
        else
            p := IsomorphismPcGroup(p);
        fi;
        classes[cs][5] := p*NaturalHomomorphismByNormalSubgroup(Range(p),DerivedSubgroup(Range(p)));
        Add(dst,Range(classes[cs][5]));
        src[cs] := Length(dst);
    fi; od;
    while true do
        cs := PositionProperty(classes,c->not IsBound(c[5]) and IsBound(classes[c[4]][5]));
        if cs=fail then break; fi;
        p := GroupByGenerators(classes[cs][2],One(G));
        classes[cs][5] := GroupHomomorphismByImagesNC(p,Range(classes[classes[cs][4]][5]),GeneratorsOfGroup(p),List(GeneratorsOfGroup(p),
                                  w->(w^classes[cs][3])^classes[classes[cs][4]][5]));
        if IsInt(classes[classes[cs][4]][4]) then
            src[cs] := src[classes[classes[cs][4]][4]];
        else
            src[cs] := src[classes[cs][4]];
        fi;
    od;
    if cgens>0 then
        Add(dst,PcpGroupByCollector(FromTheLeftCollector(cgens)));
    fi;
    data.group := DirectProduct(dst);
    if cgens>0 then
        e := Embedding(data.group,Length(dst));
    fi;
    for p in [1..Length(classes)] do
        classes[p][5] := classes[p][5]*Embedding(data.group,src[p]);
    od;
    for p in [1..Length(data.map)] do
        g := One(data.group);
        for m in data.map[p] do
            if IsInt(m) then
                g := g*(GeneratorsOfGroup(Source(e))[AbsoluteValue(m)]^SignInt(m))^e;
            else
                g := g*classes[m[1]][2][m[2]]^classes[m[1]][5];
            fi;
        od;
        data.map[p] := g;
    od;
    src := GeneratorsOfGroup(data.group);
    dst := [];
    for g in src do
        g := data.nucleus[Position(data.map,g)];
        h := PositionProperty(data.nucleus,x->g in DecompositionOfFRElement(x)[1]);
        Add(dst,data.map[h]);
    od;
    data.endo := GroupHomomorphismByImagesNC(data.group,data.group,src,dst);
    return data;
end);

InstallMethod(GermValue, "(FR) for a Mealy element and germ data",
        [IsFRElement, IsRecord],
        function(elm,data)
    local corr, m0, m, h, i, p, recur;

    if IsOne(elm) then return One(data.group); fi;

    recur := function(s)
        local i;
        if not IsBound(h[s]) then
            h[s] := fail; # prevent loops except in nucleus
            for i in m!.transitions[s] do recur(i); od;
            i := h{m!.transitions[s]};
            if not fail in i then
                h[s] := Product(i)^data.endo;
            fi;
        fi;
    end;

    elm := ASINTREP@(elm);
    m := UnderlyingFRMachine(elm);
    m0 := m+data.nucleusmachine;
    corr := [ListTrans(Correspondence(m0)[1],Size(StateSet(m))),
             ListTrans(Correspondence(m0)[2],Size(StateSet(data.nucleusmachine)))];
    m := Minimized(m0);
    corr := List(corr,x->List(x,x->x^Correspondence(m)));

    h := [];
    h{corr[2]} := data.map;
    i := corr[1][InitialState(elm)];
    recur(i);

    if IsBound(data.eval) then
        return data.eval(elm,data,h{corr[1]});
    else
        return h[i];
    fi;
end);

InstallMethod(GermValue, "(FR) for an FR element and germ data",
        [IsGroupFRElement and IsFRElementStdRep, IsRecord],
        function(elm,data)
    local m, p;
    if IsOne(elm) then return One(data.group); fi;
    m := UnderlyingFRMachine(elm);
    p := First(data.machines,x->IsIdenticalObj(x[1],m));
    if p=fail then
        p := List(GeneratorsOfFRMachine(m),
                  w->GermValue(ASINTREP@(FRElement(m,w)),data));
        if fail in p then return fail; fi;
        Add(data.machines,[m,p]);
    else
        p := p[2];
    fi;
    return MAPPEDWORD@(InitialState(elm),p,One(data.group));
end);

InstallMethod(EpimorphismGermGroup, "(FR) for a group",
        [IsFRGroup],
        function(G)
    local data;
    data := GermData(G);
    return GroupHomomorphismByFunction(G,data.group,x->GermValue(x,data));
end);

BindGlobal("HOMOMORPHISMGERMPCGROUP@", function(G,data,n)
    local pcpP, pcpG, Q, pcpQ, l, i;

    l := Length(AlphabetOfFRSemigroup(G))^n;
    i := IsomorphismPcGroup(PermGroup(G,n));
    if i=fail then return fail; fi;
    Q := WreathProduct(data.group,Range(i),InverseGeneralMapping(i),l);
    pcpP := Pcgs(Range(i));
    pcpG := Pcgs(data.group);
    pcpQ := Pcgs(Q);
    return GroupHomomorphismByFunction(G,Q,function(g)
        local e, d, x, y;
        d := DecompositionOfFRElement(g,n);
        x := PermList(d[2]);
        if not x in Source(i) then return fail; fi;
        e := ExponentsOfPcElement(pcpP,x^i);
        for x in INVERSE@(d[2]) do
            y := GermValue(d[1][x],data);
            if y=fail then return fail; fi;
            Append(e,ExponentsOfPcElement(pcpG,y));
        od;
        return PcElementByExponentsNC(pcpQ,e);
    end);
end);

BindGlobal("HOMOMORPHISMGERMPCPGROUP@", function(G,data,n)
    local pcpP, pcpG, Q, pcpQ, l, i;

    l := Length(AlphabetOfFRSemigroup(G))^n;
    i := IsomorphismPcpGroup(PermGroup(G,n));
    if i=fail then return fail; fi;
    Q := WreathProduct(data.group,Range(i),InverseGeneralMapping(i),l);
    pcpP := Pcp(Range(i));
    pcpG := Pcp(data.group);
    pcpQ := Collector(Q);
    return GroupHomomorphismByFunction(G,Q,function(g)
        local e, d, x, y;
        d := DecompositionOfFRElement(g,n);
        x := PermList(d[2]);
        if not x in Source(i) then return fail; fi;
        e := ExponentsByPcp(pcpP,x^i);
        for x in INVERSE@(d[2]) do
            y := GermValue(d[1][x],data);
            if y=fail then return fail; fi;
            Append(e,ExponentsByPcp(pcpG,y));
        od;
        return PcpElementByExponentsNC(pcpQ,e);
    end);
end);

BindGlobal("DIRECTPRODUCT@", function( list )
    local len, D, F, G, pcgsG, gensF, s, h, i, j, t,
          info, first, coll, orders, exp;

    # Check the arguments.
    if ForAny( list, G -> not IsPcGroup( G ) ) then
      TryNextMethod();
    fi;
    if ForAll( list, IsTrivial ) then
      return list[1];
    fi;
    len := Sum( List( list, x -> Length( Pcgs( x ) ) ) );
    F   := FreeGroup(IsSyllableWordsFamily, len );
    orders := [];
    for G in list do
        Append( orders, RelativeOrders(Pcgs(G)) );
    od;
    if false and ForAll(orders,x->x=orders[1]) then
        coll := CombinatorialCollector(F,orders);
    else
	coll := SingleCollector(F,orders);
    fi;
    gensF := GeneratorsOfGroup( F );

    s := 0;
    first := [1];
    for G in list do
        pcgsG := Pcgs( G );
        len   := Length(pcgsG);
        for i in [1..len] do
	    exp := ExponentsOfRelativePower( pcgsG, i );
	    t := One( F );
            for h in [1..len] do
                t := t * gensF[s+h]^exp[h];
            od;
            SetPower(coll, s+i, t);
	    for j in [i+1..len] do
	        exp := ExponentsOfPcElement( pcgsG, pcgsG[j]^pcgsG[i] );
            	t := One( F );
		for h in [1..len] do
                    t := t * gensF[s+h]^exp[h];
            	od;
            	SetConjugate(coll, s+j, s+i, t);
	    od;
	od;
        s := s+len;
        Add( first, s+1 );
    od;

    # create direct product
    D := GroupByRwsNC(coll);

    # create info
    info := rec( groups := list,
                 first  := first,
                 embeddings := [],
                 projections := [] );
    SetDirectProductInfo( D, info );
    return D;
end);

InstallMethod(EpimorphismGermGroup, "(FR) for a group and a level",
        [IsFRGroup, IsInt],
        function(G,n)
    local data, emb, P, pi;

    data := GermData(G);
    emb := [GroupHomomorphismByFunction(G,data.group,x->GermValue(x,data))];
    if IsPcGroup(data.group) then
        Append(emb,List([1..n],i->HOMOMORPHISMGERMPCGROUP@(G,data,i)));
    else
        Append(emb,List([1..n],i->HOMOMORPHISMGERMPCPGROUP@(G,data,i)));
    fi;
    if n=0 then
        pi := emb[1];
    else
        pi := GroupGeneralMappingByImages(Image(emb[2]),Image(emb[1]),List(GeneratorsOfGroup(G),x->x^emb[2]),List(GeneratorsOfGroup(G),x->x^emb[1]));
        if IsSingleValued(pi) then
            pi := emb[n+1];
        else
            # P := DirectProduct(List(emb,Image));
            P := DIRECTPRODUCT@(List(emb,Image));
            emb := List([1..n+1],i->emb[i]*Embedding(P,i));
            pi := GroupHomomorphismByFunction(G,P,x->Product(emb,i->x^i));
        fi;
    fi;
    return GroupHomomorphismByFunction(G,Image(pi),pi!.fun);
end);

InstallMethod(HasOpenSetConditionFRSemigroup, "(FR) for an FR group",
        [IsFRGroup],
        G->ForAll(GeneratorsOfGroup(G),g->HasOpenSetConditionFRElement(g)=true));

InstallMethod(HasCongruenceProperty, "(FR) for an FR group",
        [IsFRGroup],
        function(G)
    local n, K;
    n := 0;
    K := BranchingSubgroup(G);
    while true do
        n := n+1;
        if AbelianInvariants(K)=AbelianInvariants(PermGroup(K,n)) then
            return true;
        fi;
        Info(InfoFR,2,"HasCongruenceProperty: searching at level ",n);
    od;
    #!!! very poor: should know when to stop and return 'false'
end);
#############################################################################

#############################################################################
## finite and recursive presentations
##
InstallMethod(EpimorphismFromFpGroup, "(FR) for FR groups with preimage data",
        [IsFRGroup and HasFRGroupPreImageData,IsInt],
        function(G,n)
    local r;
    r := FRGroupPreImageData(G)(n);
    return GroupHomomorphismByFunction(r.F,G,r.preimage,false,r.image);
end);

InstallMethod(IsomorphismSubgroupFpGroup, "(FR) for FR groups with preimage data",
        [IsFRGroup and HasFRGroupPreImageData],
        function(G)
    local r;
    r := FRGroupPreImageData(G)(infinity);
    return GroupHomomorphismByFunction(G,r.F,r.image,r.preimage);
end);

InstallMethod(AsSubgroupFpGroup, "(FR) for FR groups with preimage data",
        [IsFRGroup and HasFRGroupPreImageData],
        G->FRGroupPreImageData(G)(infinity).F);

InstallMethod(IsomorphismLpGroup, "(FR) for FR groups with preimage data",
        [IsFRGroup and HasFRGroupPreImageData],
        function(G)
    local r;
    r := FRGroupImageData(G);
    return GroupHomomorphismByFunction(G,r.F,r.image,r.preimage);
end);

InstallMethod(AsLpGroup, "(FR) for FR groups with preimage data",
        [IsFRGroup and HasFRGroupPreImageData],
        G->FRGroupImageData(G).F);

InstallMethod(IsomorphismFRGroup, "(FR) for a self-similar group with preimage data",
        [IsFRGroup and HasFRGroupPreImageData],
        function(G)
    local r, gens;

    gens := ISOMORPHICFRGENS@(GeneratorsOfGroup(G),AsGroupFRElement)[2];
    r := FRGroupPreImageData(G)(0);
    return GroupHomomorphismByFunction(G,Group(gens),
                   g->FRElement(gens[1],UnderlyingElement(r.image(g))),
                   AsMealyElement);
    return GroupHomomorphismByImagesNC(G,Group(gens),GeneratorsOfGroup(G),gens);
end);

InstallMethod(\in, "(FR) for a self-similar group with preimage data",
        IsElmsColls,
        [IsFRElement, IsFRGroup and HasFRGroupPreImageData],
        function(g,G)
    return FRGroupImageData(G).image(g)<>fail;
end);
#############################################################################

#E group.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
