#############################################################################
##
#W img.gi                                                   Laurent Bartholdi
##
#H   @(#)$Id: img.gi,v 1.40 2009/10/13 09:37:06 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  Iterated monodromy groups
##
#############################################################################

#############################################################################
##
#M FRElement
##
InstallMethod(FRElement, "(FR) for an IMG machine and a word",
        [IsIMGMachine, IsAssocWord],
        function(M,init)
    if not init in M!.free then
        Error(init, " must be an element of ", M!.free,"\n");
    fi;
    return Objectify(NewType(FREFamily(M), IsIMGElement and IsFRElementStdRep),
                   [M,init]);
end);

InstallMethod(FRElement, "(FR) for an IMG machine and an initial list",
        [IsIMGMachine, IsList],
        function(M,init)
    return Objectify(NewType(FREFamily(M), IsIMGElement and IsFRElementStdRep),
                   [M,M!.pack(init)]);
end);

InstallMethod(FRElement, "(FR) for an IMG machine and an integer",
        [IsIMGMachine, IsPosInt],
        function(M,init)
    return Objectify(NewType(FREFamily(M), IsIMGElement and IsFRElementStdRep),
                   [M,M!.pack([init])]);
end);

InstallMethod(ViewObj, "(FR) for an IMG element",
        [IsIMGElement and IsFRElementStdRep],
        function(E)
    Print("<", Size(AlphabetOfFRObject(E)), "#");
    if IsOne(E![2]) then
        Print("identity ...>");
    else
        Print(E![2], ">");
    fi;
end);

BindGlobal("IMGISONE@", function(m,relator,w,skip)
    local rws, todo, d, t, seen;

    rws := NewFRMachineRWS(m);
    if not IsBound(rws.relator) then
        rws.addgprule(rws.letterrep(relator));
        rws.commit();
        rws.relator := relator;
    fi;
    seen := NewDictionary([],false);
    todo := NewFIFO([rws.letterrep(w)]);
    for t in todo do
        if skip then
            skip := false;
        else
            t := rws.reduce(rws.cyclicallyreduce(t));
        fi;
        if not IsEmpty(t) then
            if KnowsDictionary(seen,t) then
                return false;
            fi;
            AddDictionary(seen,t);
            d := rws.pi(t);
            if not ISONE@(d[2]) then return false; fi;
            Append(todo,d[1]);
        fi;
    od;
    return true;
end);

InstallMethod(IsOne, "(FR) for an IMG element",
        [IsIMGElement],
        function(x)
    return IMGISONE@(x![1],IMGRelator(x![1]),x![2],false);
end);

InstallMethod(\=, "(FR) for two IMG elements",
        IsIdenticalObj,
        [IsIMGElement,IsIMGElement],
        function(x,y)
    if x![1]<>y![1] then
        Error("Cannot compare IMG elements in different machines");
    fi;
    return IMGISONE@(x![1],IMGRelator(x![1]),x![2]/y![2],false);
end);

InstallMethod(Order, "(FR) for an IMG element",
        [IsIMGElement],
        function(e)
        local testing, recur;
    testing := NewDictionary(e,false); # elements we consider
    recur := function(g)
        local d, o, h, ho, i, j;
        if IsOne(g) then
            return 1;
        elif IsGroupFRElement(g) then
            g := FRElement(g,CyclicallyReducedWord(InitialState(g)));
        fi;
        if KnowsDictionary(testing,g) then
            return infinity;
        else
            AddDictionary(testing,g);
            d := DecompositionOfFRElement(g);
            o := 1;
            for i in Cycles(PermList(d[2]),AlphabetOfFRObject(g)) do
                h := One(g);
                for j in i do h := h*d[1][j]; od;
                ho := recur(h);
                if ho=infinity then
                    return infinity;
                else
                    o := LcmInt(o,Length(i)*ho);
                fi;
            od;
            return o;
        fi;
    end;
    return recur(e);
end);
#############################################################################

#############################################################################
##
#A AsGroupFRMachine, AsMonoidFRMachine, AsSemigroupFRMachine
#A AsIMGMachine
##
BindGlobal("ISIMGRELATOR@", function(M,w)
    local r;
    r := WreathRecursion(M)(w);
    return ISONE@(r[2]) and ForAll(r[1],x->IsOne(x) or IsConjugate(M!.free,x,w));
end);

InstallMethod(AsIMGMachine, "(FR) for a group FR machine and a word",
        [IsGroupFRMachine,IsAssocWord],
        function(M,w)
    local f, i, out, trans, r, p;
    if ISIMGRELATOR@(M,w) then
        M := COPYFRMACHINE@(M);
        SetIMGRelator(M,w);
    else
        f := ElementsFamily(FamilyObj(M!.free))!.names;
        if "t" in f then
            i := 1;
            while Concatenation("t",String(i)) in f do i := i+1; od;
            f := FreeGroup(Concatenation(f,[Concatenation("t",String(i))]));
        else
            f := FreeGroup(Concatenation(f,["t"]));
        fi;
        r := RankOfFreeGroup(f);
        i := GroupHomomorphismByImagesNC(M!.free,f,GeneratorsOfGroup(M!.free),GeneratorsOfGroup(f){[1..r-1]});
        p := INVERSE@(Output(M,w));

        trans := List(M!.transitions,r->List(r,x->x^i));
        Add(trans,List(AlphabetOfFRObject(M),a->Inverse(Transition(M,w,p[a]))^i));

        out := ShallowCopy(M!.output);
        Add(out,p);

        p := Maximum(List(trans[r],Length));
        p := PositionProperty(trans[r],x->Length(x)=p);
        trans[r][p] := trans[r][p]*w^i*f.(r);

        M := FRMachineNC(FamilyObj(M),f,trans,out);
        SetIMGRelator(M,w^i*f.(r));
    fi;
    return M;
end);

BindGlobal("IMGRELATORS@", function(gens,ordering)
    local e, o, i, relators;

    o := ShallowCopy(ordering);
    relators := [];
    for i in [1..Length(o)] do
        e := Product(gens{o});
        Add(relators,e);
        Add(relators,e^-1);
        Add(o,Remove(o,1));
    od;
    return relators;
end);

InstallMethod(SPIDERRELATORS@, [IsSpider],
        spider->IMGRELATORS@(GeneratorsOfGroup(spider!.model),spider!.ordering));

InstallOtherMethod(NFFUNCTION@, [IsGroup, IsWord], function(g,r)
    return FpElementNFFunction(FamilyObj(One(g / [r])));
end);

InstallMethod(NFFUNCTION@, [IsSpider],
        spider->NFFUNCTION@(spider!.model, SPIDERRELATORS@(spider)[1]));

BindGlobal("IMGOPTIMIZE@", function(trans, perm, relators, canfail)
    # modify entries in <trans> so that products along cycles of <perm>
    # are conjugates of a generator; or return fail if that's impossible.
    # also check that these generators occur only once.

    local g, h, i, j, nf, c, group, seen;

    group := CollectionsFamily(FamilyObj(relators[1]))!.wholeGroup;
    nf := NFFUNCTION@(group, relators[1]);
    seen := [];

    for i in [1..Length(trans)] do
        for c in Cycles(PermList(perm[i]),[1..Length(perm[i])]) do
            g := One(group);
            for j in c do
                h := nf(g*trans[i][j]);
                trans[i][j] := g^-1*h;
                g := h;
            od;
            if IsOne(h) then continue; fi;
            h := CyclicallyReducedWord(h);
            if not h in GeneratorsOfGroup(group) then
                g := First(relators,x->CyclicallyReducedWord(h*x) in GeneratorsOfGroup(group));
                while g=fail do
                    if canfail then return fail; fi;
                    Error("Could not express recursion on topological sphere");
                od;
                h := CyclicallyReducedWord(h*g);
                j := First(Reversed(c),j->not IsOne(trans[i][j])); # last <>1
                trans[i][j] := trans[i][j]*g;
            fi;
            if h in seen then return fail; fi;
            AddSet(seen,h);
        od;
    od;
    return true;
end);

#!!! this code is not very efficient. see AsPolynomialIMGMachine for a speedup
#using Thurston's algorithm
InstallMethod(AsIMGMachine, "(FR) for a group FR machine",
        [IsGroupFRMachine],
        function(M)
    local w, p, trans, perm;
    if IsIMGMachine(M) then
        return M;
    fi;
    for p in PermutationsList(GeneratorsOfGroup(M!.free)) do
        w := Product(p);
        if ISIMGRELATOR@(M,w) then
            trans := List(M!.transitions,ShallowCopy);
            perm := List(M!.output,ShallowCopy);

            if IMGOPTIMIZE@(trans,perm,SPIDERRELATORS@(p,[1..Length(GeneratorsOfGroup(M!.free))]),true)=fail then
                break;
            fi;
            M := FRMachineNC(FamilyObj(M),M!.free,trans,perm);
            SetIMGRelator(M,w);
            return M;
        fi;
    od;
    return fail;
end);

InstallMethod(AsGroupFRMachine, "(FR) for an IMG machine",
        [IsIMGMachine],
        COPYFRMACHINE@);

InstallMethod(ViewObj, "(FR) for an IMG machine",
        [IsIMGMachine and IsFRMachineStdRep],
        function(M)
    Print("<FR machine with alphabet ", AlphabetOfFRObject(M), " on ", StateSet(M), "/[ ",IMGRelator(M)," ]>");
end);

InstallMethod(Display, "(FR) for an IMG machine",
        [IsIMGMachine and IsFRMachineStdRep],
        function(M)
    DISPLAYFRMACHINE@(M);
    Print("Relator: ",IMGRelator(M),"\n");
end);
#############################################################################

#############################################################################
##
#A Direct / Tensor products and sums
##
InstallMethod(TensorProductOp, "(FR) for two IMG machines",
        [IsList, IsIMGMachine and IsFRMachineStdRep],
        function(M, N)
    local R;
    R := ApplicableMethod(TensorProductOp, [M,N], 0, 2)(M,N);
    if ForAll(M,x->IMGRelator(x)=IMGRelator(N)) then
        SetIMGRelator(R,IMGRelator(N));
    fi;
    return R;
end);

InstallMethod(DirectProductOp, "(FR) for two IMG machines",
        [IsList, IsIMGMachine and IsFRMachineStdRep],
        function(M, N)
    local R;
    R := ApplicableMethod(DirectProductOp, [M,N], 0, 2)(M,N);
    if ForAll(M,x->IMGRelator(x)=IMGRelator(N)) then
        SetIMGRelator(R,IMGRelator(N));
    fi;
    return R;
end);

InstallMethod(TensorSumOp, "(FR) for two IMG machines",
        [IsList, IsIMGMachine and IsFRMachineStdRep],
        function(M, N)
    local R;
    R := ApplicableMethod(TensorSumOp, [M,N], 0, 2)(M,N);
    if ForAll(M,x->IMGRelator(x)=IMGRelator(N)) then
        SetIMGRelator(R,IMGRelator(N));
    fi;
    return R;
end);

InstallMethod(DirectSumOp, "(FR) for two IMG machines",
        [IsList, IsIMGMachine and IsFRMachineStdRep],
        function(M, N)
    local R;
    R := ApplicableMethod(DirectSumOp, [M,N], 0, 2)(M,N);
    if ForAll(M,x->IMGRelator(x)=IMGRelator(N)) then
        SetIMGRelator(R,IMGRelator(N));
    fi;
    return R;
end);
#############################################################################

#############################################################################
##
#M PROD
##
BindGlobal("COPYADDER@", function(M,N)
    SetAddingElement(M,FRElement(M,InitialState(AddingElement(N))));
end);

InstallMethod(\*, "(FR) for an FR machine and a mapping",
        [IsFRMachine and IsFRMachineStdRep, IsMapping],
        function(M,f)
    local S, N, x;
    S := StateSet(M);
    if S<>Source(f) or S<>Range(f) then
        Error("\*: source, range and stateset must be the same\n");
    fi;
    N := FRMachineNC(FamilyObj(M),S,List(M!.transitions,r->List(r,x->x^f)),M!.output);
    if IMGISONE@(N,IMGRelator(M),IMGRelator(M),true) then
        SetIMGRelator(N,IMGRelator(M));
    else
        Info(InfoFR, 1, "Warning: result of composition does not seem to be an IMG machine");
    fi;
    if HasAddingElement(M) then
        x := InitialState(AddingElement(M));
	if x^f=x then COPYADDER@(N,M); fi;
    fi;
    return N;
end);

InstallMethod(\*, "(FR) for a mapping and an FR machine",
        [IsMapping, IsFRMachine and IsFRMachineStdRep],
        function(f,M)
    local S, trans, out, i, pi, x, N;
    S := StateSet(M);
    if S<>Source(f) or S<>Range(f) then
        Error("\*: source, range and stateset must be the same\n");
    fi;
    pi := WreathRecursion(M);
    trans := [];
    out := [];
    for i in [1..Length(M!.output)] do
        x := pi(GeneratorsOfFRMachine(M)[i]^f);
        Add(trans,x[1]);
        Add(out,x[2]);
    od;
    N := FRMachineNC(FamilyObj(M),S,trans,out);
    if IMGISONE@(M,IMGRelator(M),IMGRelator(M),true) then
        SetIMGRelator(N,IMGRelator(M));
    else
        Info(InfoFR, 1, "Warning: result of composition is not an IMG machine");
    fi;
    if HasAddingElement(M) then
        x := InitialState(AddingElement(M));
	if x^f=x then COPYADDER@(N,M); fi;
    fi;
    return N;
end);

InstallMethod(\^, "(FR) for a group FR machine and a mapping",
        [IsGroupFRMachine, IsMapping],
        function(M,f)
    local S, trans, out, i, pi, x, finv;
    S := StateSet(M);
    if S<>Source(f) or S<>Range(f) then
        Error("\*: source, range and stateset must be the same\n");
    fi;
    pi := WreathRecursion(M);
    trans := [];
    out := [];
    finv := Inverse(f);
    if finv=fail then return fail; fi;
    for i in [1..Length(M!.output)] do
        x := pi(GeneratorsOfFRMachine(M)[i]^finv);
        Add(trans,List(x[1],x->x^f));
        Add(out,x[2]);
    od;
    x := FRMachineNC(FamilyObj(M),S,trans,out);
    if HasIMGRelator(M) then
        SetIMGRelator(x,IMGRelator(M)^f);
    fi;
    if HasAddingElement(M) then
        SetAddingElement(x,FRElement(x,InitialState(AddingElement(M))^f));
    fi;
    return x;
end);

InstallMethod(ComplexConjugate, "(FR) for a group FR machine",
        [IsGroupFRMachine],
        function(M)
    local S;
    S := StateSet(M);
    M := M^GroupHomomorphismByImagesNC(S,S,GeneratorsOfGroup(S),List(GeneratorsOfGroup(S),Inverse));
    M!.AddingElement := AddingElement(M)^-1;#!!! is that really what we want?
    return M;
end);
#############################################################################

#############################################################################
##
#M ChangeFRMachineBasis
##
InstallMethod(ChangeFRMachineBasis, "(FR) for a group FR machine and a list",
        [IsGroupFRMachine, IsCollection],
        function(M,l)
    local trans, i;
    if Length(l)<>Size(AlphabetOfFRObject(M)) or not ForAll(l,x->x in StateSet(M)) then
        Error("Invalid base change ",l,"\n");
    fi;
    trans := [];
    for i in [1..Length(M!.transitions)] do
        Add(trans,List(AlphabetOfFRObject(M),a->l[a]^-1*M!.transitions[i][a]*l[M!.output[i][a]]));
    od;
    i := FRMachineNC(FamilyObj(M),StateSet(M),trans,M!.output);
    if HasIMGRelator(M) then
        SetIMGRelator(i,IMGRelator(M));
    fi;
    return i;
end);

InstallMethod(ChangeFRMachineBasis, "(FR) for an FR machine",
        [IsGroupFRMachine],
        function(M)
    local S, l, s, t, u, v;

    S := [];
    for s in GeneratorsOfFRMachine(M) do
        for t in Cycles(PermList(Output(M,s)),AlphabetOfFRObject(M)) do
            if Length(t)>1 then
                Add(S,[s,t]);
            fi;
        od;
    od;
    l := [];
    l[1] := One(StateSet(M));
#    l[Random([1..Length(AlphabetOfFRObject(M))])] := One(StateSet(M));
    while not IsEmpty(S) do
        t := First([1..Length(S)],i->Number(S[i][2],i->IsBound(l[i]))>0);
        if t=fail then
            Error("Action is not transitive");
            return fail;
        fi;
        t := Remove(S,t);
        s := Filtered(t[2],i->IsBound(l[i]));
        if Length(s)>1 then
            Error("Action is not contractible (tree-like)");
            return fail;
        fi;
        s := s[1];
        u := s;
        while true do
            v := PermList(Output(M,t[1],u));
            if v=s then
                break;
            else
                l[v] := LeftQuotient(Transition(M,t[1],u),l[u]);
                u := v;
            fi;
        od;
    od;
    return ChangeFRMachineBasis(M,l);
end);
#############################################################################

#############################################################################
##
#A Polynomial Machines
##
BindGlobal("TRUNC@", function(a)
    # fractional part of rational, contained in [0,1)
    a := a-Int(a);
    if a<0 then return a+1; else return a; fi;
end);

InstallMethod(ViewObj, "(FR) for a polynomial FR machine",
        [IsPolynomialFRMachine and IsFRMachineStdRep],
        function(M)
    Print("<FR machine with alphabet ", AlphabetOfFRObject(M), " and adder ", AddingElement(M), " on ", StateSet(M), ">");
end);

InstallMethod(Display, "(FR) for a polynomial FR machine",
        [IsPolynomialFRMachine and IsFRMachineStdRep],
        function(M)
    DISPLAYFRMACHINE@(M);
    Print("Adding element: ",AddingElement(M),"\n");
end);

InstallMethod(ViewObj, "(FR) for a polynomial IMG machine",
        [IsPolynomialIMGMachine and IsFRMachineStdRep],
        function(M)
    Print("<FR machine with alphabet ", AlphabetOfFRObject(M), " and adder ", AddingElement(M), " on ", StateSet(M), "/[ ",IMGRelator(M)," ]>");
end);

InstallMethod(Display, "(FR) for an IMG machine",
        [IsPolynomialIMGMachine and IsFRMachineStdRep],
        function(M)
    DISPLAYFRMACHINE@(M);
    Print("Adding element: ",AddingElement(M),"\n");
    Print("Relator: ",IMGRelator(M),"\n");
end);

BindGlobal("ISTREELIKEPERMUTATIONLIST@", function(S,A)
    local s, t;
    S := Concatenation(List(S,x->Cycles(x,A)));
    while Size(S)>1 do
        s := Remove(S);
        t := PositionProperty(S,x->Length(Intersection(x,s))=1);
        if t=fail then return false; fi;
        S[t] := Union(s,S[t]);
    od;
    return Set(S[1])=A;
end);

InstallMethod(IsKneadingMachine, "(FR) for an FR machine",
        [IsMealyMachine],
        function(M)
    local S, s, t;

    S := GeneratorsOfFRMachine(M);
    for s in S do
        if not IsOne(FRElement(M,s)) then
            if Sum(List(S,t->Number(AlphabetOfFRObject(M),a->Transition(M,t,a)=s)))>1 then
                return false;
            fi;
        fi;
        for t in Cycles(PermList(Output(M,s)),AlphabetOfFRObject(M)) do
            if Number(t,x->not IsOne(FRElement(M,Transition(M,s,t))))>1 then
                return false;
            fi;
        od;
    od;
    return ISTREELIKEPERMUTATIONLIST@(List(S,x->PermList(Output(M,x))),AlphabetOfFRObject(M));
end);

BindGlobal("PLANAREMBEDDINGMEALYMACHINE@", function(M,justone)
    local S, aS, result, a, x;
    # could be made faster, see [BS02a: Bruin & Schleicher, Symbolic Dynamics of quadratic polynomials]
    if not IsKneadingMachine(M) then
        return [];
    fi;
    S := M{GeneratorsOfFRMachine(M)};
    aS := Filtered([1..Length(S)],i->not IsOne(S[i]));
    result := [];
    for a in PermutationsList(aS) do
        x := List([1..Length(aS)],i->Product(S{a{[i+1..Length(aS)]}},S[1]^0)
                  *Product(S{a{[1..i]}}));
        if State(x[1]^Length(AlphabetOfFRObject(M)),AlphabetOfFRObject(M)[1]) in x then
            if justone then return a; fi;
            Add(result,a);
        fi;
    od;
    return result;
end);

InstallMethod(IsPlanarKneadingMachine, "(FR) for a Mealy machine",
        [IsMealyMachine],
        M->not IsEmpty(PLANAREMBEDDINGMEALYMACHINE@(M,true)));

InstallMethod(AsPolynomialFRMachine, "(FR) for a Mealy machine",
        [IsMealyMachine],
        function(M)
    local a;
    a := PLANAREMBEDDINGMEALYMACHINE@(M,true);
    if IsEmpty(a) then return fail; fi;
    M := AsGroupFRMachine(M);
    SetAddingElement(M,FRElement(M,Product(a,x->x^Correspondence(M))));
    return M;
end);

BindGlobal("REORDERREC@", function(m,perm)
    # reorder the entries of m=[trans,perm] according to the permutation perm.
    local i;
    for i in [1..Length(m[1])] do
        m[1][i] := Permuted(m[1][i],perm);
        m[2][i] := ListPerm(PermList(m[2][i])^perm,Length(m[2][i]));
    od;
end);

BindGlobal("COMPOSERECURSION@", function(trans,out,pre,post)
    # twist the recursion [trans,out] by precomposing by pre, and
    # post-composing by post^-1. These are homomorphisms with range
    # the (source, range) group of [trans,out].
    # returns the new [trans,out].
    local i, w, newout, newtrans, deg, psi;
    deg := Length(trans[1]);

    w := WreathProduct(Range(post),SymmetricGroup(deg));
    psi := GroupHomomorphismByImagesNC(Range(pre),w,GeneratorsOfGroup(Range(pre)),List([1..Length(GeneratorsOfGroup(Range(pre)))],i->Product([1..deg],j->trans[i][j]^Embedding(w,j))*PermList(out[i])^Embedding(w,deg+1)));

    newout := [];
    newtrans := [];
    for i in GeneratorsOfGroup(Source(pre)) do
        w := (i^pre)^psi;
        Add(newout,ListPerm(w![deg+1],deg));
        Add(newtrans,List([1..deg],j->PreImagesRepresentative(post,w![j])));
    od;
    
    return [newtrans,newout];
end);

BindGlobal("FJ@",["Fatou","Julia"]);

BindGlobal("LIFTPOLYNOMIAL@", function(M,adder,shift)
    # applies Thurston's algorithm to the machine M, a (supposedly) polynomial
    # FR machine.
    # adder is the position of the adding machine (or fail if there is none)
    # shift is an integer, or a list, telling how far after the position
    # of the critical value we shold go to start the cycle.
    # returns fail if the machine is not polynomial.
    local a, ap, g, i, j, k, kk, n,
          cycle, successor, type, start, phi, N;
    a := GeneratorsOfFRMachine(M);
    ap := [];
    successor := [];
    cycle := [];
    type := [];
    n := Length(a);
    for i in [1..Length(a)] do
        for k in Cycles(PermList(M!.output[i]),AlphabetOfFRObject(M)) do
            if (i<>adder and not IsSortedList(k)) or
               (i=adder and k<>Concatenation([1],[Length(AlphabetOfFRObject(M)),Length(AlphabetOfFRObject(M))-1..2])) then
                return fail;
            fi;
            g := Product(M!.transitions[i]{k});
            if IsOne(g) then
                if Length(k)=1 then continue; fi;
                n := n+1;
                j := n;
            else
                j := Position(a,CyclicallyReducedWord(g));
                if j=fail or IsBound(ap[j]) then return fail; fi;
                ap[j] := g;
            fi;
            successor[j] := i;
            cycle[j] := k;
        od;
    od;
    if BoundPositions(ap)<>BoundPositions(a) then return fail; fi;
    
    for j in [1..n] do
        if IsBound(type[j]) then continue; fi;
        k := j; kk := j;
        repeat
            k := successor[k]; kk := successor[successor[kk]];
        until k=kk;
        type[j] := FJ@[2]; # by default, is julia
        repeat
            k := successor[k];
            if Length(cycle[k])>1 then type[j] := FJ@[1]; fi;
        until k=kk;
    od;

    phi := GroupHomomorphismByImages(M!.free,M!.free,ap,a);
    if phi=fail then return fail; fi;
    
    Info(InfoFR,3,"Change f_i->f\"_i: ",phi);
    Info(InfoFR,3,"Active element in f\"_i: ",List(M!.transitions[1],x->x^phi),"sigma");
            
    start := [];
    for j in [1..Length(a)] do
        i := successor[j];
        start[j] := PositionProperty(cycle[j],k->PositionWord(M!.transitions[i][k]^phi,a[i]^-1)<>fail);
        if start[j]=fail then start[j] := Length(cycle[j]); fi;
        if IsList(shift) then
            start[j] := start[j]+shift[j];
        else
            start[j] := start[j]+shift;
        fi;
        start[j] := (start[j]-1) mod Length(cycle[j]);
        ap[j] := ap[j]^Product(M!.transitions[i]{cycle[j]{[1..start[j]]}},One(ap[j]));
        start[j] := cycle[j][start[j]+1];
    od;
    start[adder] := 1; # adder is the only element oriented differently
    
    phi := GroupHomomorphismByImages(M!.free,M!.free,a,ap);
    if phi=fail then return fail; fi;
    
    Info(InfoFR,3,"Change f'_i->f_i: ",phi);
    
    i := COMPOSERECURSION@(M!.transitions,M!.output,phi,phi);
    N := FRMachineNC(FamilyObj(M),M!.free,i[1],i[2]);
    if HasIMGRelator(M) then
        SetIMGRelator(N,PreImage(phi,IMGRelator(M)));
    fi;
    return rec(machine := N,
               twist := phi,
               successor := successor,
               start := start,
               type := type,
               cycle := cycle);
end);

BindGlobal("ADDER@", function(M)
    return Position(GeneratorsOfFRMachine(M),InitialState(AddingElement(M)));
end);

BindGlobal("ISADDER@", function(M,w)
    local r, c;
    r := WreathRecursion(M)(w);
    c := Cycles(PermList(r[2]),AlphabetOfFRObject(M));
    return Length(c)=1 and # transitive element
           IsConjugate(StateSet(M),w,Product(r[1]{c[1]}));
end);

BindGlobal("LIFT@", function(M,shift)
    local lift;
    lift := LIFTPOLYNOMIAL@(M,ADDER@(M),shift);
    if lift=fail then return fail; fi;
    COPYADDER@(lift.machine,M);
    return lift.machine;
end);

InstallMethod(Lift, "(FR) for a polynomial FR machine",
        [IsPolynomialFRMachine],
        M->LIFT@(M,0));

InstallMethod(Lift, "(FR) for a polynomial FR machine and an integer shift",
        [IsPolynomialFRMachine,IsInt],
        function(M,shift) return LIFT@(M,shift); end);

InstallMethod(Lift, "(FR) for a polynomial FR machine and shifts",
        [IsPolynomialFRMachine,IsHomogeneousList],
        function(M,shift) return LIFT@(M,shift); end);
        
BindGlobal("PERIODICLIFT@", function(lift,adder,maxlen,shift)
    # find a periodic recursion (= a periodic spider)
    # returns fail if no period found (some transition gets longer than maxlen
    # returs an dehn twist isomorphism if there's an obstruction
    # otherwise, returns a list with the period
    local l, n, i, j, sublift;

    lift := [lift];
    n := 1;
    repeat
        l := LIFTPOLYNOMIAL@(lift[n].machine,adder,shift);
        if l=fail then return fail; fi;
#        l.twist := l.twist*lift[n].twist; #! too slow
        Add(lift,l);
        n := n+1;
        if ForAny(lift[n].machine!.transitions,x->ForAny(x,y->Length(y)>=maxlen)) then
            return fail;
        fi;
    until lift[n].machine=lift[QuoInt(n,2)].machine;
    
    i := QuoInt(n,2);
    for j in DivisorsInt(n-i) do
        if lift[i].machine=lift[i+j].machine then # keep the period
#            if lift[i].twist<>lift[i+j].twist then
#                return lift[i].twist/lift[i+j].twist;
#            fi;
            lift := lift{i+[j,j-1..1]};
            j := Product(lift,l->l.twist);
            if not IsOne(j) then
                return rec(obstruction := "Dehn twist", machine := lift[1].machine, twist := j);
            fi;
            break;
        fi;
    od;
    return lift;
end);

BindGlobal("EXTERNALANGLES@", function(M,adder)
    local machines, l, N, n, lift, fatou, julia, angle, successor,
          a, b, i, j, k, deg, set, phi;
    n := 1;
    N := 2*Length(M!.transitions)*(Maximum(List(Flat(M!.transitions),Length))+1);
    deg := Length(AlphabetOfFRObject(M));
    lift := rec(machine := M, twist := IdentityMapping(StateSet(M)));
    
    lift := PERIODICLIFT@(lift,adder,N,0);
    if lift=fail then
        return rec(obstruction := "Topological");
    elif IsRecord(lift) then
        return lift;
    elif Length(lift)>1 then
        lift := PERIODICLIFT@(lift[Length(lift)],adder,N,1); # different shift
    fi;
    
    if Length(lift)>1 then
        Info(InfoFR,3,"code not tested for non-fixed spiders!");
    fi;
     
    fatou := [];
    julia := [];
    angle := [];
    successor := lift[1].successor; # the successor map

    for i in [1..Length(lift[1].cycle)] do
        a := lift[1].cycle[i]-1;
        j := successor[i];
        n := 1;
        k := 1;
        N := [];
        Info(InfoFR,3,"i = ",i," init = ",a);
        repeat # find preperiod
            Info(InfoFR,3," pos = ",j," digit = ",lift[n].start[j]-1);
            a := deg*a + (lift[n].start[j]-1);
            AddSet(N,[n,j]);
            n := (n mod Length(lift))+1;
            j := successor[j];
            k := k+1;
        until [n,j] in N;
        b := 0;
        l := 0;
        N := [n,j];
        repeat # now follow period
            Info(InfoFR,3," period digit = ",lift[n].start[j]-1);
            b := deg*b + (lift[n].start[j]-1);
            n := (n mod Length(lift))+1;
            j := successor[j];
            l := l+1;
        until [n,j] = N;
        a := (a + b / (deg^l-1)) / deg^k;

        if Length(a)>1 and i<>adder then
            if lift[1].type[i]=FJ@[1] then Add(fatou,a); else Add(julia,a); fi;
        fi;
        if IsBound(lift[1].start[i]) then # only postcritical points
            Add(angle,TRUNC@(deg*a[1]));
        fi;
    od;
    b := [];
    for i in Combinations([1..Length(fatou)],2) do
        if fatou[i[1]]=fatou[i[2]] then Add(b,i); fi;
    od;
    for i in Combinations([1..Length(julia)],2) do
        if julia[i[1]]=julia[i[2]] then Add(b,i); fi;
    od;
    if IsEmpty(b) then
        return rec(degree := deg, fatou := fatou, julia := julia,
                   angle := angle, twist := lift[1].twist);
    else
        return rec(obstruction := "Collisions", pairs := b);
    fi;
end);

InstallMethod(ExternalAngles, "(FR) for a polynomial IMG machine",
        [IsPolynomialFRMachine],
        function(M)
    local e;
    e := EXTERNALANGLES@(M,ADDER@(M));
    if IsBound(e.obstruction) then
        return e;
    fi;
    return [e.degree,e.fatou,e.julia];
end);

InstallMethod(ExternalAngles, "(FR) for a polynomial IMG machine and a bool",
        [IsPolynomialFRMachine,IsBool],
        function(M,b)
    local e;
    e := EXTERNALANGLES@(M,ADDER@(M));
    if IsBound(e.obstruction) then
        return e;
    elif b then
        return e;
    else
        return [e.degree,e.fatou,e.julia];
    fi;
end);

InstallMethod(AsPolynomialFRMachine, "(FR) for a group FR machine",
        [IsGroupFRMachine],
        function(M)
    local N, i, G, g;
    G := StateSet(M);
    for i in [1..Length(M!.transitions)] do
        g := GeneratorsOfGroup(G)[i];
        if ISADDER@(M,g) then
            N := COPYFRMACHINE@(M);
            SetAddingElement(N,FRElement(N,g));
            return N;
        fi;
    od;
    return fail;
end);

InstallMethod(AsPolynomialFRMachine, "(FR) for a group FR machine and an adder",
        [IsGroupFRMachine, IsAssocWord],
        function(M,w)
    local N;
    if not ISADDER@(M,w) then return fail; fi;
    N := COPYFRMACHINE@(M);
    SetAddingElement(N,FRElement(N,w));
    return N;
end);

InstallMethod(AsPolynomialFRMachine, "(FR) for a polynomial IMG machine",
        [IsPolynomialIMGMachine],
        function(M)
    local N;
    N := COPYFRMACHINE@(M);
    COPYADDER@(N,M);
    return N;
end);

InstallMethod(AsGroupFRMachine, "(FR) for a polynomial FR machine",
        [IsPolynomialFRMachine],
        COPYFRMACHINE@);

InstallMethod(AsPolynomialIMGMachine, "(FR) for an IMG machine",
        [IsIMGMachine],
        function(M)
    local N;
    N := AsPolynomialFRMachine(M);
    if N=fail then return fail; fi;
    SetIMGRelator(N,IMGRelator(M));
    return N;
end);

InstallMethod(AsPolynomialIMGMachine, "(FR) for an IMG machine and an adder",
        [IsIMGMachine, IsAssocWord],
        function(M,w)
    local N;
    N := AsPolynomialFRMachine(M,w);
    if N=fail then return fail; fi;
    SetIMGRelator(N,IMGRelator(M));
    return N;
end);

InstallMethod(AsPolynomialIMGMachine, "(FR) for a polynomial machine",
        [IsPolynomialFRMachine],
        function(M)
    local e, r;
    
    e := EXTERNALANGLES@(M,ADDER@(M));    
    r := ShallowCopy(GeneratorsOfGroup(StateSet(M)));
    SortParallel(e.angle,r);
    r := Product(Reversed(r))^e.twist;
    Assert(0,ISIMGRELATOR@(M,r));
    SetIMGRelator(M,r);
    return M;
end);

InstallMethod(AsPolynomialIMGMachine, "(FR) for a polynomial machine and an img relatorn",
        [IsPolynomialFRMachine, IsAssocWord],
        function(M,w)
    if ISIMGRELATOR@(M,w) then
        M := ShallowCopy(M);
        SetIMGRelator(M,w);
        return M;
    fi;
    return fail;
end);

InstallMethod(AsPolynomialIMGMachine, "(FR) for a group FR machine",
        [IsGroupFRMachine],
        function(M)
    M := AsPolynomialFRMachine(M);
    if M=fail then return fail; fi;
    return AsPolynomialIMGMachine(M);
end);    

InstallMethod(AsPolynomialIMGMachine, "(FR) for a group FR machine, and adder and an IMG relator",
        [IsGroupFRMachine, IsAssocWord, IsAssocWord],
        function(M,a,r)
    M := AsPolynomialFRMachine(M,a);
    if M=fail then return fail; fi;
    M := AsPolynomialIMGMachine(M,r);
    if M=fail then return fail; fi;
    return M;
end);

InstallMethod(AsIMGMachine, "(FR) for a polynomial IMG machine",
        [IsPolynomialIMGMachine],
        function(M)
    local N;
    N := COPYFRMACHINE@(M);
    SetIMGRelator(N,IMGRelator(M));
    return N;
end);
#############################################################################

##############################################################################
##
#M Normalize polynomial machine
##
BindGlobal("NORMALIZEADDINGMACHINE@", function(model,trans,out,adder,sign)
    # conjugate the recursion so that element adder, which is checked to
    # be an adding machine, becomes of the form t=(1,...,t)s or
    # (t,...,1)s^-1, where s is the cycle i|->i+1 mod d.
    # adder is the position of the adding element.
    # model is the ambient fundamental group.
    # sign is +1 in first case and -1 in second.
    local cycle, deg, perm, x, i, j, basis;
    
    deg := Length(trans[1]);
    cycle := Cycles(PermList(out[adder]),[1..deg]);
    while Length(cycle)<>1 or not IsConjugate(model,Product(trans[adder]{cycle[1]}),model.(adder)) do
        Error("Element #",adder," is not an adding element");
    od;
    
    if sign=1 then
        perm := PermList(Concatenation([2..deg],[1]));
    elif sign=-1 then
        perm := PermList(Concatenation([deg],[1..deg-1]));
    fi;
    perm := RepresentativeAction(SymmetricGroup(deg),PermList(out[adder]),perm);
    REORDERREC@([trans,out],perm);

    basis := [];
    x := One(model);
    for i in (sign)*[1..deg]+(1-sign)*(deg+1)/2 do
        basis[i] := x;
        x := x*trans[adder][i];
    od;
    basis := RepresentativeAction(model,model.(adder),x)*basis;
    for i in [1..Length(trans)] do
        for j in [1..deg] do
            trans[i][j] := basis[j]*trans[i][j]/basis[out[i][j]];
        od;
    od;
end);

InstallMethod(NormalizedPolynomialFRMachine, "(FR) for a polynomial FR machine",
        [IsPolynomialFRMachine],
        function(M)
    local trans, out, adder, N;
    
    trans := List(M!.transitions,ShallowCopy);
    out := List(M!.output,ShallowCopy);
    adder := Position(GeneratorsOfFRMachine(M),InitialState(AddingElement(M)));
    if adder=fail then return fail; fi;
    NORMALIZEADDINGMACHINE@(M!.free,trans,out,adder,-1);
    N := FRMachineNC(FamilyObj(M),M!.free,trans,out);
    COPYADDER@(N,M);
    return N;
end);

InstallMethod(NormalizedPolynomialIMGMachine, "(FR) for a polynomial IMG machine",
        [IsPolynomialIMGMachine],
        function(M)
    local N;
    N := NormalizedPolynomialFRMachine(M);
    if N=fail then return fail; fi;
    SetIMGRelator(N,IMGRelator(M));
    return N;
end);

InstallMethod(NormalizedPolynomialIMGMachine, "(FR) for a polynomial IMG machine",
        [IsPolynomialFRMachine],
        M->NormalizedPolynomialFRMachine(AsIMGMachine(M)));
#############################################################################

#############################################################################
##
#M PolynomialMealyMachine
#M PolynomialFRMachine
#M PolynomialIMGMachine
##
BindGlobal("KM$INPART@", function(part,x)
    # part is a list of subsets of [0,1) given as a list of pairs [lo,hi).
    # returns the index of the subset that contains x
    local i, j;
    for i in [1..Length(part)] do
        for j in part[i] do
            if j[1]<=x and x<j[2] then
                return i;
            fi;
        od;
    od;
end);

BindGlobal("KM$SPLITPART@", function(part,p,epsilon)
    # part is a list of subsets as above.
    # p is a list of points on [0,1).
    # intersect part with the partition cutting [0,1) at all p[i]-epsilon.
    local ind, i, j, newp;

    ind := List(p,x->KM$INPART@(part,x-epsilon));
    if Size(Set(ind))<>1 then
        Error("Some parts cross");
    fi;
    ind := part[ind[1]];
    i := 1;
    j := 1;
    while j<Length(p) do # split off ind\cap [p[j]..p[j+1]]
        while ind[i][2]<=p[j] do
            i := i+1;
        od;
        newp := [];
        if ind[i][1]<p[j] then
            Add(ind,[ind[i][1],p[j]],i);
            i := i+1;
            ind[i][1] := p[j];
        fi;
        j := j+1;
        while Length(ind)>=i and ind[i][2]<=p[j] do
            Add(newp,Remove(ind,i));
        od;
        if Length(ind)>= i and ind[i][1]<p[j] then
            Add(newp,[ind[i][1],p[j]]);
            ind[i][1] := p[j];
        fi;
        Add(part,newp);
    od;
end);

BindGlobal("POLYNOMIALMACHINE@", function(d,F,J,machtype,inner,formal)
    # d is the degree
    # F is a list of Fatou critical points
    # J is a list of Julia critical points
    # inner=true: make finite recursion nice; =false: make adding machine nice
    # machtype=1: mealy machine; =2: FR machine; =3: IMG machine
    # formal=true: formal kneading machine; =false: collapse points
    # returns an FR machine, and sets correspondence to [fF,fJ], where
    # these functions return, for a given angle, the corresponding generator.
    local C, V, i, j, part, pcp, f, g, trans, t, out, o, p, q, rank, epsilon,
          one, machine;
    
    C := Concatenation(List(F,x->[x,FJ@[1]]),List(J,x->[x,FJ@[2]]));
    for i in C do
        if IsRat(i[1]) then
            i[1] := Set([1..d],j->TRUNC@((i[1]+j)/d));
        else
            i[1] := Set(i[1],TRUNC@);
        fi;
    od;
    epsilon := 1/2/Lcm(List(C,x->Lcm(List(x[1],DenominatorRat))));
    
    if ForAny(C,x->Size(Set(d*x[1],TRUNC@))<>1) then
        Error("F and J must be ",d,"-prearguments");
    fi;

    pcp := [];
    V := List(C,i->[TRUNC@(d*i[1][1]),i[2]]); # critical values
    for i in V do
        p := i;
        while not p in pcp do
            AddSet(pcp,p);
            p := [TRUNC@(d*p[1]),p[2]];
        od;
        while Gcd(DenominatorRat(p[1]),d)<>1 do
            p := [TRUNC@(d*p[1]),p[2]];
        od;
        q := p;
        t := false;
        repeat # search for a critical point on limit cycle
            p := [TRUNC@(d*p[1]),p[2]];
            t := t or (p in V);
        until q=p;
#        while (p[2]="Fatou") <> t do # this can in fact happen, see example 7
#            Error("critical value ",i[1]," should not be in the ",p[2]," set");
#        od;
    od;
    Sort(pcp,function(x,y)
        return x[1]<y[1] or (x[1]=y[1] and x[2]=FJ@[2] and y[2]=FJ@[1]);
    end);
    rank := Length(pcp);

    part := [[[0,1]]];
    for i in C do
        if i[2]=FJ@[1] then
            KM$SPLITPART@(part,i[1],0);
        else
            KM$SPLITPART@(part,i[1],epsilon);
        fi;
    od;
    
    
    if Sum(C,x->Length(x[1])-1)<>d-1 then
        Error("F and J describe a map of wrong degree");
    fi;
    
    part := part{List([0..d-1]/d,x->KM$INPART@(part,x))};

    if machtype=1 then
        g := [1..rank+1];
        one := rank+1;
    elif machtype=2 then
        f := FreeGroup(rank);
        g := GeneratorsOfGroup(f);
        one := One(f);
    elif machtype=3 then
        f := FreeGroup(rank+1);
        g := GeneratorsOfGroup(f);
        one := One(f);
    fi;
    trans := [];
    out := [];
    for i in pcp do
        t := [];
        o := [];
        for j in [0..d-1] do
            q := (i[1]+j)/d;
            p := First(C,x->i[2]=x[2] and q in x[1]);
            if p=fail then
                p := q;
            else
                p := p[1][Position(p[1],q) mod Length(p[1])+1];
            fi;
            if inner then
                o[KM$INPART@(part,q)] := KM$INPART@(part,p);

                p := Position(pcp,[q,i[2]]);
                if p<>fail then
                    p := g[p];
                else
                    p := one;
                fi;
                t[KM$INPART@(part,q)] := p;
            else
                if p<>q then
                    Add(o,1+(j+d*(p-q)) mod d);
                    if p>q then
                        Add(t,Product(g{Filtered([rank,rank-1..1],j->pcp[j][1]>q and pcp[j][1]<p and pcp[j][2]=i[2])},one)^-1);
                    else
                        Add(t,Product(g{Filtered([rank,rank-1..1],j->pcp[j][1]>=p and pcp[j][1]<=q and pcp[j][2]=i[2])},one));
                    fi;
                else
                    Add(o,j+1);
                    p := Position(pcp,[q,i[2]]);
                    if p<>fail then
                        Add(t,g[p]);
                    else
                        Add(t,one);
                    fi;
                fi;
            fi;
        od;
        Add(trans,t);
        Add(out,o);
    od;
    if machtype=1 then
        Add(trans,List([1..d],i->Length(g)));
        Add(out,[1..d]);
        machine := MealyMachine(trans,out);
        SetCorrespondence(machine,pcp);
        SetAddingElement(machine,Product(g,i->FRElement(machine,i)));
    elif machtype=2 then
        machine := FRMachine(f,trans,out);
        SetCorrespondence(machine,pcp);
        SetAddingElement(machine,FRElement(machine,Product(g)));
    elif machtype=3 then
        t := [g[Length(g)]];
        Append(t,List([1..d-1],i->one));
        Add(trans,t);
        Add(out,Concatenation([d],[1..d-1]));
        machine := FRMachine(f,trans,out);
        SetIMGRelator(machine,Product(Reversed(g)));
        SetAddingElement(machine,FRElement(machine,g[Length(g)]));
        SetCorrespondence(machine,pcp);
    fi;

    if not formal then
        while machtype<>3 or inner do
            Error("Non-formal polynomials are only supported for IMG machines");
        od;
        p := [[1..rank]];
        t := List(pcp,x->x[1]);
        for i in [1..rank] do
            q := [];
            for i in p do
                o := List([1..d],i->[]);
                for i in i do
                    Add(o[KM$INPART@(part,t[i])],i);
                od;
                UniteSet(q,Difference(o,[[]]));
            od;
            t := List(t,x->TRUNC@(d*x));
            p := q;
        od;
        if Length(p)<rank then
            q := [];
            for i in p do
                o := one;
                for j in [i[Length(i)],i[Length(i)]-1..i[1]] do
                    if not j in i then o := g[j]^-1*o; fi;
                    o := o*g[j];
                od;
                Add(q,o);
            od;
            i := FreeGroup(Length(p)+1);
            i := GroupHomomorphismByImagesNC(i,f,GeneratorsOfGroup(i),Concatenation(q,[g[Length(g)]]));
            trans := COMPOSERECURSION@(trans,out,i,i);
            out := trans[2]; trans := trans[1];
            machine := FRMachine(Source(i),trans,out);
            SetIMGRelator(machine,Product(Reversed(GeneratorsOfGroup(Source(i)))));
            SetAddingElement(machine,FRElement(machine,PreImagesRepresentative(i,g[Length(g)])));
            q := [];
            for i in p do
                Add(q,[List(pcp{i},x->x[1]),pcp[i[1]][2]]);
            od;
            SetCorrespondence(machine,q);
        fi;
    fi;

    return machine;
end);

InstallMethod(PolynomialMealyMachine, "(FR) for a degree, Fatou and Julia preangles",
        [IsPosInt,IsList,IsList],
        function(n,F,J)
    return POLYNOMIALMACHINE@(n,F,J,1,true,true);
end);

InstallMethod(PolynomialFRMachine, "(FR) for a degree, Fatou and Julia preangles",
        [IsPosInt,IsList,IsList],
        function(n,F,J)
    return POLYNOMIALMACHINE@(n,F,J,2,true,true);
end);

InstallMethod(PolynomialIMGMachine, "(FR) for a degree, Fatou and Julia preangles",
        [IsPosInt,IsList,IsList],
        function(n,F,J)
    return POLYNOMIALMACHINE@(n,F,J,3,false,true);
end);

InstallMethod(PolynomialIMGMachine, "(FR) for a degree, Fatou and Julia preangles, and formal",
        [IsPosInt,IsList,IsList,IsBool],
        function(n,F,J,formal)
    return POLYNOMIALMACHINE@(n,F,J,3,false,formal);
end);

BindGlobal("MATING@", function(machines,adders,formal)
    local w, i, j, states, gen, sgen, sum, f, c, trans, out;
    
    if not formal then
        Error("Non-formal matings are not yet implemented");
    fi;

    w := List(machines,m->CyclicallyReducedWord(IMGRelator(m)));
    for i in [1..2] do
        j := PositionWord(w[i],adders[i]);
        if j=fail then
            Error("Cannot find adding machine in ",machines[i]);
        fi;
        w[i] := Subword(w[i],j+1,Length(w[i]))*Subword(w[i],1,j-1);
    od;

    states := List(machines,StateSet);
    gen := []; c := [];
    for i in [1..2] do
        c[i] := Position(GeneratorsOfGroup(states[i]),adders[i]);
        if c[i]=fail then
            Error("Adder must be a generator of machine");
        else
            gen[i] := ShallowCopy(GeneratorsOfGroup(states[i]));
            Remove(gen[i],c[i]);
        fi;
    od;
    sgen := List(gen,x->List(x,String));
    if Intersection(sgen[1],sgen[2])<>[] then
        i := sgen[1][1][1];
        if ForAll(Concatenation(sgen),w->w[1]=i) then
            sgen[2] := List(sgen[2],ShallowCopy);
            for j in sgen[2] do j[1] := CHAR_INT(INT_CHAR(i)+1); od;
        else
            sgen := List([1,2],i->List(sgen[i],s->Concatenation(s,String(i))));
        fi;
    fi;
    f := FreeGroup(Concatenation(sgen));
    sgen := [GeneratorsOfGroup(f){[1..Length(gen[1])]},
             GeneratorsOfGroup(f){[1..Length(gen[2])]+Length(gen[1])}];
    for i in [1..2] do
        Add(sgen[i],fail,c[i]);
        w[i] := MappedWord(w[i],GeneratorsOfGroup(states[i]),sgen[i]);
        sgen[i][c[i]] := w[i]^-1;
    od;
    j := [];
    for i in [1..2] do
        trans := List(machines[i]!.transitions,ShallowCopy);
        out := List(machines[i]!.output,ShallowCopy);
        NORMALIZEADDINGMACHINE@(StateSet(machines[i]),trans,out,c[i],2*i-3);
        Add(j,FRMachineNC(FamilyObj(machines[i]),StateSet(machines[i]),trans,out));
    od;
    machines := j;
    
    c := List([1..2],i->GroupHomomorphismByImagesNC(states[i],f,
                 GeneratorsOfGroup(states[i]),sgen[i]));
    trans := [];
    out := [];
    for i in [1..2] do
        for j in gen[i] do
            Add(trans,List(AlphabetOfFRObject(machines[i]),a->Transition(machines[i],j,a)^c[i]));
            Add(out,Output(machines[i],j));
        od;
    od;
    sum := FRMachineNC(FamilyObj(machines[1]),f,trans,out);
    SetCorrespondence(sum,c);
    SetIMGRelator(sum,w[1]*w[2]);
    return sum;
end);

InstallMethod(Mating, "(FR) for two polynomial IMG machines",
        [IsPolynomialFRMachine,IsPolynomialFRMachine],
        function(M1,M2)
    return MATING@([M1,M2],[InitialState(AddingElement(M1)),InitialState(AddingElement(M2))],true);
end);

InstallMethod(Mating, "(FR) for two polynomial IMG machines and a boolean",
        [IsPolynomialFRMachine,IsPolynomialFRMachine,IsBool],
        function(M1,M2,formal)
    return MATING@([M1,M2],[InitialState(AddingElement(M1)),InitialState(AddingElement(M2))],formal);
end);
#############################################################################

##############################################################################
##
#M  triangulations
##
BindGlobal("EPS@", rec(
        mesh := MacFloat(2*10^-1), # refine triangulation if points are that close
        prec := MacFloat(10^-6), # points that far apart are considered equal
        obst := MacFloat(10^-1), # points that far apart are suspected to form
                                 # an obstruction
        juliaiter := 1000,       # maximum depth in iteration
        fast := MacFloat(10^-1), # if spider moved that little, just wiggle it
        ratprec := MacFloat(10^-10), # quality to achieve in rational fct.
        fail := fail));

BindGlobal("POSITIONID@", function(l,x)
    return PositionProperty(l,y->IsIdenticalObj(x,y));
end);

BindGlobal("INID@", function(x,l)
    return ForAny(l,y->IsIdenticalObj(x,y));
end);

BindGlobal("MACFLOAT_1mEPS@", MacFloat(1-10^-8));
BindGlobal("SPHEREDIST@", function(u,v)
    local d;
    d := u*v;
    if d<=-MACFLOAT_1 then
        return MACFLOAT_PI;
    elif d>=MACFLOAT_1mEPS@ then
        return Sqrt((u-v)^2); # less roundoff error this way
    else
        return ACOS_MACFLOAT(d);
    fi;
end);

BindGlobal("ISCLOSE@", function(x,y)
    return SPHEREDIST@(x,y)<EPS@.prec;
end);

InstallMethod(ViewObj, "(FR) for a triangulation",
        [IsSphereTriangulation],
        function(t)
    Print("<triangulation with ",Length(t!.v)," vertices, ",Length(t!.e), " edges and ",Length(t!.f)," faces>");
end);

InstallMethod(PrintObj, "(FR) for a triangulation",
        [IsSphereTriangulation],
        ViewObj);

BindGlobal("STRINGCOORD@", function(l)
    local f, s;
    s := ""; f := OutputTextString(s,false);
    PrintTo(f,"(",l[1],",",l[2],",",l[3],")");
    return s;
end);

InstallMethod(Display, "(FR) for a triangulation",
        [IsSphereTriangulation],
        function(t)
    local i, j;
    Print("   vertex | position                       | neighbours\n");
    Print("----------+--------------------------------+-------------\n");
    for i in t!.v do
        Print(String(Concatenation("Vertex ",String(i.index)),9)," | ",String(STRINGCOORD@(i.pos),-30)," |");
        for j in i.n do Print(" ",j.index); od;
        Print("\n");
    od;
    Print("----------+--------------------------------+-------------\n");
    Print("     edge | position                       |frm to lt rt\n");
    Print("----------+--------------------------------+-------------\n");
    for i in t!.e do
        Print(String(Concatenation("Edge ",String(i.index)),9)," | ",String(STRINGCOORD@(i.pos),-30)," |");
        for j in [i.from,i.to,i.left,i.right] do Print(String(j.index,3)); od;
        Print("\n");
    od;
    Print("----------+--------------------------------+----------v-----------\n");
    Print("     face | position                       | radius   | neighbours\n");
    Print("----------+--------------------------------+----------+-----------\n");
    for i in t!.f do
        Print(String(Concatenation("Face ",String(i.index)),9)," | ",String(STRINGCOORD@(i.pos),-30)," | ",String(i.radius,-5)," |");
        for j in i.n do Print(" ",j.index); od;
        Print("\n");
    od;
    Print("----------+--------------------------------+----------+-----------\n");
end);

InstallMethod(DelaunayTriangulation, "(FR) for a list of points",
        [IsList],
        function(points)
    local t, d, e, f, i, j, k, n;

    while not (IsList(points) and ForAll(points,l->IsList(l) and ForAll(l,IsMacFloat))) do
        Error("DelaunayTriangution: argument should be a list of points on the sphere");
    od;
    n := Length(points);
    while n<2 do
        Error("DelaunayTriangution: need at least 2 points");
    od;
    t := rec(v := List([1..n],i->rec(pos := points[i], n := [])),
             e := [],
             f := []);

    d := DELAUNAY_TRIANGULATION(EPS@.mesh,true,points);

    while IsInt(d) do
        i := RoundCyc(d/100);
        j := d-100*i;
        Error("A FORTRAN error ",j," occurred in ",ELM_LIST(["fr_dll","trmesh_","crlist_","addnod_"],i+1));
    od;

    for i in d[4] do
        Add(t.v, rec(pos := i, n := [], fake := true));
    od;

    for i in [1..Length(d[3])] do
        j := d[3][i];
        repeat
            j := d[2][j];
            t.e[j] := rec(pos := SphereProject(t.v[i].pos+t.v[d[1][j]].pos),
                          from := t.v[i], to := t.v[d[1][j]]);
            Add(t.v[i].n, t.e[j]);
        until j=d[3][i];
    od;
    for i in t.e do
        i.reverse := First(i.to.n,e->IsIdenticalObj(e.to,i.from));
    od;

    for i in [1..Length(d[7])] do
        f := rec(radius := d[8][i], n := []);
        for j in [1..3] do
            k := PositionProperty([1..Length(d[6])],k->d[6][k]=i and (j=1 or IsIdenticalObj(f.n[j-1].to,t.e[k].from)));
            Add(f.n, t.e[k]);
        od;
        f.pos := SphereProject(Sum(f.n,x->x.to.pos));
        # we could use the circumcenter d[7][i], but it's not guaranteed
        # to be in the circle; so we use the center of mass
        Add(t.f, f);
    od;

    for i in t.f do
        for j in i.n do
            j.left := i;
            j.reverse.right := i;
        od;
    od;

    t.mesh := d[10];

    for i in [1..Length(t.v)] do t.v[i].index := i; od;
    for i in [1..Length(t.e)] do t.e[i].index := i; od;
    for i in [1..Length(t.f)] do t.f[i].index := i; od;

    # prevent from printing whole recursive structure
    for i in t.v do
        i.operations := rec(ViewObj := function(x)
            Print("<vertex ",x.index,">"); end, PrintObj := ~.ViewObj);
    od;
    for i in t.e do
        i.operations := rec(ViewObj := function(x)
            Print("<edge ",x.index,">"); end, PrintObj := ~.ViewObj);
    od;
    for i in t.f do
        i.operations := rec(ViewObj := function(x)
            Print("<face ",x.index,">"); end, PrintObj := ~.ViewObj);
    od;

    return Objectify(TYPE_TRIANGULATION, t);
end);

BindGlobal("WIGGLETRIANGULATION@", function(t,points)
    # move positions in t so vertices match <points>
    local r, i, j;
    r := rec(v := StructuralCopy(t!.v),
             e := [],
             f := [],
             wiggled := MACFLOAT_0);
    for i in [1..Length(r.v)] do
        if not IsBound(r.v[i].fake) then
            r.wiggled := r.wiggled + SPHEREDIST@(r.v[i].pos, points[i]);
            r.v[i].pos := points[i];
        fi;
        for j in r.v[i].n do r.e[j.index] := j; od;
    od;
    for i in r.e do
        r.f[i.left.index] := i.left;
        i.pos := SphereProject(i.from.pos+i.to.pos);
    od;
    for i in r.f do
        i.pos := SphereProject(Sum(i.n,e->e.to.pos));
    od;
    return Objectify(TYPE_TRIANGULATION, r);
end);

BindGlobal("ISVERTEX@", r->IsBound(r.n) and not IsBound(r.radius));
BindGlobal("ISEDGE@", r->IsBound(r.to));
BindGlobal("ISFACE@", r->IsBound(r.radius));

BindGlobal("LOCATE@", function(t,seed,p)
    local vertex, coord, i, v, f;

    vertex := DELAUNAY_FIND(t!.mesh, seed, p);
    coord := vertex[2]/Sqrt(vertex[2]^2);
    vertex := vertex[1];
    
    while vertex[3]=0 do
        Error("ClosestFaceInTriangulation: point should always be in convex hull");
    od;

    v := t!.v[vertex[2]];
    f := First(t!.v[vertex[1]].n,e->IsIdenticalObj(e.to,v)).left;
    i := Filtered([1..3],i->coord[i]<EPS@.prec);
    if IsEmpty(i) then # not on edge
        return f;
    elif Size(i)=2 then # at a vertex
        return t!.v[vertex[Difference([1..3],i)[1]]];
    else
        v := t!.v[vertex[i[1]]];
        return First(f.n,e->not INID@(v,[e.from,e.to]));
    fi;
end);

BindGlobal("CLOSESTFACES@", function(x)
    if ISFACE@(x) then
        return [x];
    elif ISEDGE@(x) then
        return [x.left,x.right];
    else
        return List(x.n,x->x.to.left);
    fi;
end);

BindGlobal("CLOSESTVERTICES@", function(x)
    if ISFACE@(x) then
        return List(x.n,x->x.to);
    elif ISEDGE@(x) then
        return [x.to,x.from];
    else
        return [x];
    fi;
end);

InstallMethod(LocateInTriangulation, "(FR) for a triangulation and point",
        [IsSphereTriangulation, IsList],
        function(t,p)
    return LOCATE@(t,1,p);
end);

InstallMethod(LocateInTriangulation, "(FR) for a triangulation, integer seed and point",
        [IsSphereTriangulation, IsInt, IsList],
        function(t,s,p)
    return LOCATE@(t,s,p);
end);

InstallMethod(LocateInTriangulation, "(FR) for a triangulation, face/edge/vertex and point",
        [IsSphereTriangulation, IsRecord, IsList],
        function(t,s,p)
    if ISFACE@(s) then
        return LOCATE@(t,s.n[1].to.index,p);
    elif ISEDGE@(s) then
        return LOCATE@(t,s.to.index,p);
    else
        return LOCATE@(t,s.index,p);
    fi;
end);

BindGlobal("INTERPOLATE_ARC@", function(l)
    # interpolate along points of l
    local r, i, p;
    r := ShallowCopy(l);
    i := 1;
    while i<Length(r) do
        if SPHEREDIST@(r[i],r[i+1])>MACFLOAT_PI/12 then
            Add(r,SphereProject(r[i]+r[i+1]),i+1);
        else
            i := i+1;
        fi;
    od;
    return r;
end);

BindGlobal("PRINTPT@", function(f,p,s)
    PrintTo(f, p[1], " ", p[2], " ", p[3], s, "\n");
end);

BindGlobal("PRINTARC@", function(f,a,col,sep)
    local j;
    a := INTERPOLATE_ARC@(a);
    PrintTo(f, "ARC ",Length(a)," ",String(col[1])," ",String(col[2])," ",String(col[3]),"\n");
    for j in a do
        PRINTPT@(f, j*sep, "");
    od;
end);

InstallMethod(Draw, "(FR) for a triangulation",
        [IsSphereTriangulation],
        function(t)
    local i, s, f;
    s := ""; f := OutputTextString(s, false);

    PrintTo(f, "POINTS ",Length(t!.v)+Length(t!.f),"\n");
    for i in t!.v do
        if IsBound(i.fake) then
            PRINTPT@(f, i.pos, " 1.0");
        else
            PRINTPT@(f, i.pos, " 4.0");
        fi;
    od;
    for i in t!.f do PRINTPT@(f, i.pos, " 2.0"); od;

    PrintTo(f, "ARCS ", 2*Length(t!.e),"\n");
    for i in t!.e do
        PRINTARC@(f, [i.from.pos,i.pos,i.to.pos], [255,0,255], MACFLOAT_1);
        PRINTARC@(f, [i.left.pos,i.pos,i.right.pos], [0,255,255], MACFLOAT_1);
    od;
    Info(InfoFR,3,"calling javaplot with:\n",s);
    JAVAPLOT@(InputTextString(s));
end);
##############################################################################

##############################################################################
##
#M  Spiders
##
InstallMethod(ViewObj, "(FR) for a point in Teichmuller space",
        [IsSpider],
        function(s)
    Print("<spider on ",s!.cut," marked by ",s!.marking,">");
end);

InstallMethod(PrintObj, "(FR) for a point in Teichmuller space",
        [IsSpider],
        ViewObj);

InstallMethod(Display, "(FR) for a point in Teichmuller space",
        [IsSpider],
        function(s)
    Display(s!.cut);
    Print("Spanning tree on edges ",List(s!.treeedge,r->r.index)," costing ",s!.treecost,"\n");
    Print("Marking ",s!.marking,"\n");
end);

InstallMethod(Draw, "(FR) for a point in Teichmuller space",
        [IsSpider],
        function(spider)
    local a, i, j, k, s, f, t, points, arcs;
    s := ""; f := OutputTextString(s, false);
    t := spider!.cut;
    if IsBound(spider!.points) then
        points := spider!.points;
    else
        points := [];
    fi;
    if IsBound(spider!.arcs) then
        arcs := spider!.arcs;
    else
        arcs := [];
    fi;
    PrintTo(f, "POINTS ",Length(t!.v)+Length(t!.f)+Length(points),"\n");
    for i in t!.v do
        if IsBound(i.fake) then
            PRINTPT@(f, i.pos, " 1.0");
        else
            PRINTPT@(f, i.pos, " 4.0");
        fi;
    od;
    for i in t!.f do PRINTPT@(f, i.pos, " 2.0"); od;
    for i in points do PRINTPT@(f, i, " 0.5"); od;

    PrintTo(f, "ARCS ", Length(t!.e)+Length(arcs),"\n");
    for i in t!.e do
        if i.from.index>i.to.index then # print only in 1 direction
            continue;
        fi;
        j := [128,64,64];
        k := [64,128,64];
        if spider!.intree[i.index] and (INID@(i,spider!.treeedge) or INID@(i.reverse,spider!.treeedge) or not (IsBound(i.from.fake) or IsBound(i.to.fake))) then
            j := [255,64,64];
        else
            k := [64,255,64];
        fi;
        PRINTARC@(f, [i.from.pos,i.pos,i.to.pos], j, MacFloat(101/100));
        PRINTARC@(f, [i.left.pos,i.pos,i.right.pos], k, MacFloat(102/100));
    od;
    for a in arcs do PRINTARC@(f, a[3], a[1], a[2]); od;

    Info(InfoFR,3,"calling javaplot with:\n",s);
    JAVAPLOT@(InputTextString(s));
end);

BindGlobal("TRIVIALSPIDER@", function(points)
    # constructs a spider with identity marking on <points>
    local r, f, edges, tree, i, ii, j, n, gens;
    n := Length(points);
    f := FreeGroup(n-1);
    gens := GeneratorsOfGroup(f);
    r := rec(model := f,                            # marking group
             cut := DelaunayTriangulation(points),  # triangulation
             group := f,                            # group on spanning tree
             marking := IdentityMapping(f),         # isomorphism between them
             intree := [],                          # if an edge is in the tree
             treeelt := [],                         # group element on edge
             treeedge := []);                       # list of edges in tree

    # construct a spanning tree
    edges := [];
    for i in r!.cut!.e do
        j := [i.from.index,i.to.index];
        # force edges to fake vertices, or to infinity, to be more expensive,
        # so they will be leaves in the tree
        if IsBound(i.from.fake) or IsBound(i.to.fake) then
            Add(j,MACFLOAT_2PI*Number([i.from,i.to],x->IsBound(x.fake)));
        else
            Add(j,SPHEREDIST@(i.from.pos,i.to.pos));
        fi;
        Add(edges,j);
        Add(r.intree,false);
    od;
    tree := ARC_MIN_SPAN_TREE(Length(r!.cut!.v),edges);
    r.treecost := Remove(tree);

    j := 1;
    for i in [1..Length(edges)] do
        if edges[i]{[1,2]} in tree then
            ii := r.cut!.e[i].reverse.index;
            r.intree[i] := true;
            r.intree[ii] := true;
            if edges[i][3]<MACFLOAT_PI then     # usual edge
                r.treeelt[i] := gens[j];
                r.treeelt[ii] := gens[j]^-1;
                r.treeedge[j] := r.cut!.e[i];
                j := j+1;
            elif edges[i][3]<MACFLOAT_2PI then # edge to infinity
                if r.cut!.e[i].to.index=n then
                    r.treeelt[i] := gens[n-1];
                    r.treeelt[ii] := gens[n-1]^-1;
                    r.treeedge[n-1] := r.cut!.e[i];
                else
                    r.treeelt[i] := gens[n-1]^-1;
                    r.treeelt[ii] := gens[n-1];
                    r.treeedge[n-1] := r.cut!.e[ii];
                fi;
            fi;
        fi;
    od;

    if BoundPositions(r.treeedge)<>[1..n-1] then # two opposite clusters
        # we must take an edge from one of the clusters to a fake point;
        # since we only use the .left, .right and .pos fields of edges
        # in r.treeedge, we shouldn't worry that the edge we take doesn't
        # actually form a tree
        for i in [n+1..n+3] do
            ii := Filtered(tree,e->e[1]=i or e[2]=i);
            if Length(ii)=2 then
                n := Intersection(ii)[1];
                ii := Difference(Union(ii),[n]); # so edges ii[1]--n--ii[2]
                break;
            fi;
        od;
        r.treeedge[j] := First(r.cut!.v[ii[1]].n,e->e.to.index=n);

        for i in [Position(edges,[ii[1],n,MACFLOAT_2PI]),
                Position(edges,[n,ii[2],MACFLOAT_2PI])] do
            ii := r.cut!.e[i].reverse.index;
            r.intree[i] := true;
            r.intree[ii] := true;
            r.treeelt[i] := gens[j];
            r.treeelt[ii] := gens[j]^-1;
        od;
    fi;

    return Objectify(TYPE_SPIDER,r);
end);

BindGlobal("WIGGLESPIDER@", function(spider,points)
    # move vertices of spider to <points>
    local r;
    r := rec(model := spider!.model,
             cut := WIGGLETRIANGULATION@(spider!.cut,points),
             group := spider!.group,
             marking := spider!.marking,
             treecost := spider!.treecost,
             intree := spider!.intree,
             treeelt := spider!.treeelt);
    r.treeedge := r.cut!.e{List(spider!.treeedge,e->e.index)};
    if IsBound(spider!.ordering) then
        r.ordering := spider!.ordering;
    fi;

    return Objectify(TYPE_SPIDER,r);
end);

InstallMethod(TREEBOUNDARY@, [IsSpider],
        function(spider)
    # return a list of edges traversed when one surrounds the tree with
    # it on our left. visit vertex n first.
    local i, e, edges, n;

    n := Length(VERTICES@(spider));
    e := First(spider!.cut!.e,e->spider!.intree[e.index] and e.from.index=n);
    edges := [];
    repeat
        Add(edges,e);
        i := POSITIONID@(e.to.n,e.reverse);
        repeat
            i := i+1;
            if i>Length(e.to.n) then i := 1; fi;
        until spider!.intree[e.to.n[i].index];
        e := e.to.n[i];
    until IsIdenticalObj(e,edges[1]);
    return edges;
end);

BindGlobal("IMGMARKING@", function(spider,model)
    # changes the marking group so that it's generated by lollipops
    # around punctures.
    # if ordering<>fail, then the product of the lollipops, in that order,
    # must be trivial.
    local e, image, ordering;

    spider!.model := model;
    ordering := [];
    image := [];

    for e in TREEBOUNDARY@(spider) do
        if not IsBound(e.from.fake) then
            if not IsBound(image[e.from.index]) then
                image[e.from.index] := One(spider!.group);
                Add(ordering,e.from.index);
            fi;
            if IsBound(spider!.treeelt[e.index]) then
                image[e.from.index] := image[e.from.index] / spider!.treeelt[e.index];
            fi;
        fi;
    od;
    while ordering[1]<>Length(ordering) do # force ordering[n]=n
        Add(ordering,Remove(ordering,1));
    od;
    spider!.ordering := Reversed(ordering);
    spider!.marking := GroupHomomorphismByImagesNC(model,spider!.group,GeneratorsOfGroup(model),image{[1..Length(GeneratorsOfGroup(model))]});
end);
##############################################################################

##############################################################################
##
#M  Function to IMG
##
BindGlobal("JULIASET@", function(cachesize,f)
    local i, j, m, n, p, q, prejulia, julia, cache, critexp, deg, df, fp,
          JULIAITER;

    deg := DegreeOfRationalFunction(f);
    df := Derivative(f);
    fp := ComplexRootsOfUnivariatePolynomial(NumeratorOfRationalFunction(f)
                  -IndeterminateOfUnivariateRationalFunction(f)*
                  DenominatorOfRationalFunction(f)); # fixed points
    SortParallel(List(fp,x->Norm(Value(Derivative(f),x))),fp);
    fp := fp[Length(fp)]; # the one with largest derivative

    JULIAITER := function(p,d,iter)
        local i, j, k;

        if p=P1infinity then
            k := COMPLEX_0;
            i := 2;
        elif Norm(Complex(p))>MACFLOAT_1 then
            k := COMPLEX_1/Complex(p);
            i := 2;
        else
            k := Complex(p);
            i := 1;
        fi;
        j := Int(1+(cachesize-EPS@.prec)*(RealPart(k)+1)/2);
        k := Int(1+(cachesize-EPS@.prec)*(ImaginaryPart(k)+1)/2);
        if cache[i][j][k] then
            return;
        fi;
        Add(julia,SphereP1(p));
        cache[i][j][k] := true;
        if d<0 and iter<EPS@.juliaiter then
            for p in P1PreImages(f,p) do
                JULIAITER(p,d+LOG_MACFLOAT(AbsoluteValue(Value(df,Complex(p))))-critexp,iter+1);
            od;
        fi;
    end;

    cache := List([1..2],i->List([1..cachesize],j->BlistList([1..cachesize],[])));
    julia := [];
    prejulia := [[P1Point(fp),1]];
    n := LogInt(1000,deg); # compute at most 1000 points to estimate hausdorff dimension
    for i in [1..n] do
        j := prejulia;
        prejulia := [];
        for p in j do
            for q in P1PreImages(f,p[1]) do
                Add(prejulia,[q,p[2]*Value(df,Complex(q))]);
            od;
        od;
    od;
    for i in prejulia do
        i[2] := LOG_MACFLOAT(AbsoluteValue(i[2]));
        if i[2]<MACFLOAT_0 then
            Info(InfoFR,2,"Doesn't seem possible to compute critical exponent");
            critexp := MACFLOAT_0;
            break;
        fi;
    od;
    if not IsBound(critexp) then
        p := MACFLOAT_0; q := MacFloat(10^8);
        while AbsoluteValue(p-q)>q/100 do
            m := (p+q)/2;
            i := Sum(prejulia,x->EXP_MACFLOAT(-m*x[2]));
            if i>MACFLOAT_1 then
                p := m;
            else
                q := m;
            fi;
        od;
        critexp := q*LOG_MACFLOAT(MacFloat(deg));
    fi;
    Info(InfoFR,2,"Critical exponent approximated by ",critexp);
    for i in prejulia do
        JULIAITER(i[1],i[2]-n*critexp,0);
    od;
    return julia;
end);

BindGlobal("LIFTPOINT@", function(t,map,p)
    # lifts point <p> through <map>.
    # returns a list of rec(pos, cell), where
    # <cell> is a face containing <p> in <t>
    local i, r, f;
    f := [];
    for i in map(p) do
        r := rec(pos := i);
        i := LocateInTriangulation(t,i);
        r.cell := CLOSESTFACES@(i)[1];
        Add(f, r);
    od;
    return f;
end);

BindGlobal("MATCHPOINTS@", function(ptA, ptB)
    # ptA is a list of n points; ptB[i] is a list of neighbours of ptA[i]
    # each ptB[i][j] is a sphere point
    # returns: a matching i|->j(i), [1..n]->[1..n] such that
    # ptA is at least 2x closer to ptB[i][j(i)] as to other neighbours;
    # or return fail if no such matching exists.
    local i, j, dists, perm;

    dists := [];
    for i in [1..Length(ptA)] do
        dists[i] := List(ptB[i],v->SPHEREDIST@(ptA[i],v));
    od;
    perm := List(dists, l->Position(l,Minimum(l)));

    for i in [1..Length(dists)] do
        for j in [1..Length(dists[i])] do
            if j<>perm[i] and dists[i][j]<dists[i][perm[i]]*2 then
                return fail;
            fi;
        od;
    od;
    return perm;
end);

BindGlobal("MATCHLIFTS@", function(t, from, to)
    # tries to order points in <to> so that they're all at least 2x closer
    # to the respective point in <from>.pos, corners of respective <from>,
    # or other points in <to>.
    # return fail, or <newpos> so that face[i].cell is the face/edge/vertex
    # containing to[matched i].
    local i, j, perm, e, olde, f, newpos, edge;

    perm := [];
    for i in [1..Length(to)] do
        perm[i] := List(from,r->r.pos); # match to face centers
        if ISEDGE@(from[i].cell) then # avoid edge endpoints
            Append(perm[i],[from[i].cell.from.pos,from[i].cell.to.pos]);
        elif ISFACE@(from[i].cell) then # avoid face corners
            Append(perm[i],List(from[i].cell.n,e->e.to.pos));
        fi;
    od;
    perm := MATCHPOINTS@(to,perm);
    if perm=fail or Set(perm)<>[1..Length(to)] then return fail; fi;

    SortParallel(perm,to);

    newpos := [];
    for i in [1..Length(to)] do
        Add(newpos, rec(pos := to[i],
            cell := LocateInTriangulation(t, from[i].cell, to[i])));
    od;
    return newpos;
end);

BindGlobal("CROSSEDELEMENT@", function(spider,from,to)
    # an edge just progressed from <from> to <to>. Update
    # edge.elt or return fail if <from> and <to> do not touch.
    # maybe bind newface.from, if newface.cell is a vertex and we want
    # to remember how we reached it.
    local e, g, j;

    e := []; # probably no edge crossed
    if IsIdenticalObj(from.cell,to.cell) then # nothing crossed
        if IsBound(from.from) then to.from := from.from; fi;
    elif ISFACE@(from.cell) and ISFACE@(to.cell) then # face to other face
        Add(e,First(from.cell.n,f->IsIdenticalObj(f.right,to.cell)));
        if e[1]=fail then # not adjacent face
            Info(InfoFR,3," faces ",from," and ",to," do not touch");
            return fail;
        fi;
    elif ISEDGE@(from.cell) and ISEDGE@(to.cell) then
        if IsIdenticalObj(from.cell.reverse,to.cell) then
            to.cell := from.cell; # make sure we stay in the same orientation
        else
            Info(InfoFR,3," edges ",from," and ",to," are different");
            return fail;        # two different edges in sequence
        fi;
    elif ISEDGE@(from.cell) and ISFACE@(to.cell) then
        if IsIdenticalObj(from.cell.right,to.cell) then
            Add(e,from.cell); # an edge crossed
        elif IsIdenticalObj(from.cell.left,to.cell) then
        else
            Info(InfoFR,3," edge ",from," and face ",to," do not touch");
            return fail;
        fi;
    elif ISFACE@(from.cell) and ISEDGE@(to.cell) then
        if IsIdenticalObj(from.cell,to.cell.left) then
        elif IsIdenticalObj(from.cell,to.cell.right) then
            to.cell := to.cell.reverse; # make sure we cross from L to R
        else
            Info(InfoFR,3," face ",from," and edge ",to," do not touch");
            return fail;
        fi;
    elif ISFACE@(from.cell) and ISVERTEX@(to.cell) then
        j := PositionProperty(to.cell.n,e->IsIdenticalObj(e.left,from.cell));
        if j=fail then
            Info(InfoFR,3," face ",from," and vertex ",to," do not touch");
            return fail;
        fi;
        to.from := j; # remember edge leaving vertex and in face we came from
    elif ISEDGE@(from.cell) and ISVERTEX@(to.cell) then
        if IsIdenticalObj(from.cell.from,to.cell) then
            to.from := POSITIONID@(to.cell.n,from.cell);
        elif IsIdenticalObj(from.cell.to,to.cell) then
            to.from := PositionProperty(to.cell.n,e->IsIdenticalObj(e.left,from.cell.left));
        else
            Info(InfoFR,3," edge ",from," and vertex ",to," do not touch");
            return fail;
        fi;
    elif ISVERTEX@(from.cell) and ISFACE@(to.cell) then
        j := PositionProperty(from.cell.n,e->IsIdenticalObj(e.left,to.cell));
        if j=fail then
            Info(InfoFR,3," vertex ",from," and face ",to," do not touch");
            return fail;
        fi;
        while j<>from.from do # we assume direction in which we go around is
            # unimportant, because from.cell is a fake vertex
            j := j-1; if j=0 then j := Length(from.cell.n); fi;
            Add(e,from.cell.n[j]);
        od;
    elif ISVERTEX@(from.cell) and ISEDGE@(to.cell) then
        if IsIdenticalObj(to.cell.from,from.cell) then
        elif IsIdenticalObj(to.cell.to,from.cell) then
            to.cell := to.cell.reverse;
        else
            Info(InfoFR,3," vertex ",from," and edge ",to," do not touch");
            return fail;
        fi;
        j := POSITIONID@(from.cell.n,to.cell);
        e := [];
        while j<>from.from do
            j := j-1; if j=0 then j := Length(from.cell.n); fi;
            Add(e,from.cell.n[j]);
        od;
    fi;
    g := One(spider!.group);
    for e in e do
        if IsBound(spider!.treeelt[e.index]) then
            g := g * spider!.treeelt[e.index];
        fi;
    od;
    return g;
end);

BindGlobal("CELLCENTER@", function(cell)
    # return a cell record corresponding to the center of <face>
    return rec(pos := cell.cell.pos, cell := cell.cell);
end);

BindGlobal("LIFTEDGE@", function(spider,map,from,to,arc)
    # lifts list <arc> through <map>. <from> is a list of rec(pos, cell).
    # <to> is either fail or a list of rec(pos, cell);
    # in these two cases, <cell> is a face.
    # <arc> is a list of points along which to lift.
    # returns list <edge> where:
    # <edge> is a list of rec(arc, from:=<cell>, to:=<cell>, elt),
    # <cell> is a list of rec(pos, cell) as above describing start
    # and end of <arc>, and
    # <elt> is a the spider!.group element crossed along the edge.
    # if <to> is bound, then edge.to will have to belong to that list.
    local face, newface, edge, next, iarc, elt, i, j, m;
if ForAny(from,r->not ISFACE@(r.cell)) then Error("not a face"); fi;
    arc := ShallowCopy(arc);
    iarc := 2;
    edge := List(from, r->rec(from := r, arc := [r.cell.pos,r.pos]));
    face := List(from, ShallowCopy);
    for i in [1..Length(edge)] do
        edge[i].elt := CROSSEDELEMENT@(spider,CELLCENTER@(from[i]),face[i]);
    od;
    next := List(arc,map);
    while iarc <= Length(arc) do
        newface := MATCHLIFTS@(spider!.cut, face, next[iarc]);
        if newface<>fail then
            elt := [];
            for i in [1..Length(edge)] do
                elt[i] := CROSSEDELEMENT@(spider,face[i],newface[i]);
                if elt[i]=fail then
                    newface := fail; break;
                fi;
            od;
        fi;
        if newface=fail then # subdivide
            Add(arc,SphereProject(arc[iarc-1]+arc[iarc]),iarc);
            Add(next,map(arc[iarc]),iarc);
        else
            for i in [1..Length(edge)] do
                Add(edge[i].arc,next[iarc][i]);
                edge[i].elt := edge[i].elt * elt[i];
                face := newface;
            od;
            iarc := iarc+1;
        fi;
    od;

    for i in [1..Length(edge)] do
        if to=fail then # create new face at which we end
            edge[i].to := rec(pos := face[i].pos,
                              cell := CLOSESTFACES@(face[i].cell)[1]);
        else
            for j in to do
                if ISCLOSE@(face[i].pos,j.pos) then
                    edge[i].to := j;
                    break;
                fi;
            od;
            while not IsBound(edge[i].to) do
                Error("Could not match up edge ",edge[i]);
            od;
        fi;
        Add(edge[i].arc,edge[i].to.pos);
        edge[i].elt := edge[i].elt * CROSSEDELEMENT@(spider,face[i],edge[i].to);
        Add(edge[i].arc,edge[i].to.cell.pos);
        edge[i].elt := edge[i].elt * CROSSEDELEMENT@(spider,edge[i].to,CELLCENTER@(edge[i].to));
    od;
    return edge;
end);

BindGlobal("LIFTSPIDER@", function(target,src,map,poly)
    # lifts all dual arcs in <src> through <map>; rounds their endpoints
    # to faces of <target>; and rewrites the generators of <src> as words
    # in <target>'s group. <base> is a preferred starting face of <src>.
    # returns [face,edge] where:
    # face, edge are lists of length Degree(map^-1), and contain lifts of faces,
    # edges indexed by the faces, edges of <src>
    # face[i][j] is rec(pos, targetface, targetgpelt)
    # edge[i][j] is rec(arc, targetfromface, targettoface, targetgpelt)
    local face, edge, f, e, i, j, todo, lifts, perm, state, p, s, base;

    target!.arcs := [];

    face := [];
    edge := [];

    if poly then
        base := First(src!.cut!.f,f->ForAny(f.n,e->e.to.index=Length(GeneratorsOfGroup(src!.group))));
    else
        base := src!.cut!.f[1];
    fi;

    # first lift edges in the dual tree
    lifts := LIFTPOINT@(target!.cut,map,base.pos);
    for f in lifts do
        f.elt := One(target!.group);
    od;
    todo := NewFIFO([[base,lifts]]);
    for f in todo do
        face[f[1].index] := f[2];
        for e in f[1].n do
            if not src!.intree[e.index] and not IsBound(face[e.right.index]) then
                lifts := LIFTEDGE@(target,map,face[f[1].index],fail,[e.left.pos,e.pos,e.right.pos]);
                edge[e.index] := lifts;
                edge[e.reverse.index] := List(lifts, l->rec(elt := l.elt^-1,
                                                 from := l.to, to := l.from,
                                                 arc := Reversed(l.arc)));
                for i in [1..Length(lifts)] do
                    Add(target!.arcs, [[255,255,255],MacFloat(103/100),lifts[i].arc]);
                    lifts[i].to.elt := f[2][i].elt*lifts[i].elt;
                od;
                Add(todo,[e.right,List(lifts,x->x.to)]);
            fi;
        od;
    od;

    # then lift edges cutting the tree
    perm := [];
    state := [];
    for e in src!.treeedge do
        lifts := LIFTEDGE@(target,map,face[e.left.index],face[e.right.index],[e.left.pos,e.pos,e.right.pos]);
        p := [];
        s := [];
        for i in [1..Length(lifts)] do
            j := POSITIONID@(face[e.right.index],lifts[i].to);
            Add(p,j);
            Add(s,face[e.left.index][i].elt*lifts[i].elt/face[e.right.index][j].elt);
            Add(target!.arcs, [[255,255,0],MacFloat(104/100),lifts[i].arc]);
        od;
        Add(perm,p);
        Add(state,s);
    od;

    if IsBound(src!.points) then
        target!.points := [];
        for i in src!.points do
            Add(target!.points, Random(map(i)));
        od;
    fi;

    return [state,perm];
end);

BindGlobal("POSTCRITICALPOINTS@", function(f)
    # return [poly,[critical points],[post-critical points],[transitions]]
    # where poly=true/false says if there is a fixed point of maximal degree;
    # it is then the last element of <post-critical points>
    # critical points is a list of [point in P1,degree]
    # post-critical points are points in P1
    # post-critical graph is a list of [i,j,n] meaning pcp[i] maps to pcp[j]
    # with local degree n>=1; or, if i<0, then cp[-i] maps to pcp[j].

    local c, i, j, cp, pcp, n, deg, newdeg, poly, transitions, src, dst;

    i := NumeratorOfRationalFunction(f);
    j := DenominatorOfRationalFunction(f);
    cp := List(ComplexRootsOfUnivariatePolynomial(Derivative(i)*j-Derivative(j)*i),P1Point);
    deg := DegreeOfRationalFunction(f);
    while Length(cp)<2*deg-2 do Add(cp,P1infinity); od;
    cp := List(cp,x->[x,2]);
    i := 1;
    while i<=Length(cp) do
        j := i+1;
        while j<= Length(cp) do
            if P1Distance(cp[i][1],cp[j][1])<EPS@.prec then
                Remove(cp,j);
                cp[i][2] := cp[i][2]+1;
            else
                j := j+1;
            fi;
        od;
        i := i+1;
    od;

    poly := First([1..Length(cp)],i->cp[i][2]=deg and P1Distance(Value(f,cp[i][1]),cp[i][1])<EPS@.prec);

    pcp := [];
    transitions := [];
    n := 0;
    for i in [1..Length(cp)] do
        c := cp[i][1];
        src := -i;
        deg := cp[i][2];
        repeat
            c := Value(f,c);
            j := PositionProperty(cp,x->P1Distance(c,x[1])<EPS@.prec);
            if j<>fail then
                c := cp[j][1];
                newdeg := cp[j][2];
            else
                newdeg := 1;
            fi;
            dst := PositionProperty(pcp,d->P1Distance(c,d)<EPS@.prec);
            if dst=fail then
                if j=fail then
                    Add(pcp,c);
                else
                    Add(pcp,cp[j][1]);
                fi;
                dst := Length(pcp);
                Add(transitions,[src,dst,deg]);
                n := n+1;
                if IsInt(poly) and IsIdenticalObj(pcp[n],cp[poly][1]) then
                    poly := n;
                fi;
            else
                Add(transitions,[src,dst,deg]);
                break;
            fi;
            deg := newdeg;
            src := dst;
        until false;
    od;

    if poly=fail then
        poly := false;
    else
        Add(pcp,Remove(pcp,poly)); # force infinity to be at end
        poly := true;
    fi;

    return [poly,cp,pcp,transitions];
end);

BindGlobal("RAT2FRMACHINE@", function(f)
    local i, j, perm, poly, pcp, spider, deg, m, n;

    if ValueOption("precision")<>fail then
        EPS@.prec := ValueOption("precision");
    else
        EPS@.prec := MacFloat(10^-5);
    fi;

    deg := DegreeOfRationalFunction(f);
    pcp := POSTCRITICALPOINTS@(f);
    poly := pcp[1];
    pcp := List(pcp[3],SphereP1);
    n := Length(pcp);
    Info(InfoFR,2,"Post-critical points at ",pcp);

    spider := TRIVIALSPIDER@(pcp);

    m := LIFTSPIDER@(spider,spider,SPHEREINVF@(f),poly);
    Add(m,spider);
    Add(m,poly);

    i := ValueOption("julia");
    if i<>fail then
        if not IsInt(i) then # default grid size
            i := 250;
        fi;
        spider!.points := JULIASET@(i,f);
        Info(InfoFR,2,"Computed Julia set with ",Length(spider!.points)," points");
    fi;

    return m;
end);

InstallMethod(FRMachine, "(FR) for a rational function",
        [IsRationalFunction],
        function(f)
    local m, x;

    x := RAT2FRMACHINE@(f);
    m := FRMachine(x[3]!.model, x[1], x[2]);
    SetSpider(m, x[3]);
    SetRationalFunction(m,f);

    return m;
end);

BindGlobal("IMGRECURSION@", function(to,from,trans,out,poly)
    # <trans,out> describe a recursion from spider <from> to spider <to>;
    # each line corresponds to a generator of <from>.group.
    # if poly, then last generator is assumed to correspond to fixed element
    # of maximal degree; put it in standard form.
    # returns: [ <newtrans> <newout> ], where now
    # each line corresponds to a generator of <from>.model, and each
    # entry in <newtrans>[i] is an element of <to>.model.

    trans := COMPOSERECURSION@(trans,out,from!.marking,to!.marking);
    out := trans[2]; trans := trans[1];
    
    IMGOPTIMIZE@(trans, out, SPIDERRELATORS@(to),false);

    if poly then
        NORMALIZEADDINGMACHINE@(from!.model,trans,out,Length(trans),-1);
    fi;
    
    return [trans, out];
end);

InstallMethod(IMGMachine, "(FR) for a rational function",
        [IsRationalFunction],
        function(f)
    local x, m, spider, poly;

    x := RAT2FRMACHINE@(f);
    spider := x[3];
    poly := x[4];
    IMGMARKING@(spider,FreeGroup(Length(x[1])+1));
    x := IMGRECURSION@(spider,spider,x[1],x[2],poly);

    m := FRMachine(spider!.model, x[1], x[2]);
    SetIMGRelator(m, SPIDERRELATORS@(spider)[1]);
    SetSpider(m, spider);
    SetRationalFunction(m, f);
    if poly then
        SetAddingElement(m,FRElement(m,spider!.model.(Length(x[1]))));
    fi;

    return m;
end);
##############################################################################

#############################################################################
##
#M IMG Machine to Function
##
InstallMethod(IMGORDERING@, [IsIMGMachine],
        function(M)
    local w;
    w := LetterRepAssocWord(IMGRelator(M));
    if ForAny(w,IsNegInt) then w := -Reversed(w); fi;
    while w[Length(w)]<>Length(w) do
        Add(w,Remove(w,1));
    od;
    return w;
end);

InstallMethod(VERTICES@, [IsSpider],
        function(spider)
    # the vertices a spider lies on
    return List(Filtered(spider!.cut!.v,v->not IsBound(v.fake)),v->v.pos);
end);

BindGlobal("STRINGTHETAPHI@", function(point)
    return Concatenation(String(ATAN2_MACFLOAT(point[2],point[1]))," ",
                   String(ACOS_MACFLOAT(point[3])));
end);

BindGlobal("RUNCIRCLEPACK@", function(values,perm)
    local spider, s, output, f, i, j, p;

    spider := TRIVIALSPIDER@(values);
    IMGMARKING@(spider,FreeGroup(Length(values)));
    f := GroupHomomorphismByImagesNC(spider!.model,SymmetricGroup(Length(perm[1])),GeneratorsOfGroup(spider!.model),List(perm,PermList));
    s := "";
    output := OutputTextString(s, false);

    PrintTo(output,"SLITCOUNT: ",Length(spider!.treeedge),"\n");
    for i in spider!.treeedge do
        PrintTo(output,STRINGTHETAPHI@(i.from.pos)," ",STRINGTHETAPHI@(i.to.pos),"\n");
    od;

    PrintTo(output,"\nPASTECOUNT: ",Length(spider!.treeedge)*Length(perm[1]),"\n");
    for i in [1..Length(spider!.treeedge)] do
        p := PreImagesRepresentative(spider!.marking,spider!.group.(i))^f;
        for j in [1..Length(perm[1])] do
            PrintTo(output,j," ",2*i-1," ",j^p," ",2*i,"\n");
        od;
    od;
    Print(s);
    CHECKEXEC@("mycirclepack");
    output := "";
    Process(DirectoryCurrent(), EXEC@.mycirclepack, InputTextString(s),
            OutputTextString(output,false), []);
    Error("Interface to circlepack is not yet written. Contact the developers for more information. Output is ", output);
end);

BindGlobal("TRICRITICAL@", function(z,perm)
    # find a rational function with critical values 0,1,infinity
    # with monodromy action perm[1],perm[2],perm[3]
    # return fail if it's too hard to do.
    local deg, cl, i, j, k, m, points, f, order;

    deg := Length(perm[1]);
    perm := List(perm,PermList);
    cl := List(perm,x->SortedList(CycleLengths(x,[1..deg])));
    
    points := [[MACFLOAT_0,MACFLOAT_0,MACFLOAT_1], # 0
               [MACFLOAT_1,MACFLOAT_0,MACFLOAT_0], # 1
               [MACFLOAT_0,MACFLOAT_0,-MACFLOAT_1]]; # infinity
    
    if deg=4 and ForAll(cl,x->x=[1,3]) then # (1,2,3), (1,2,4), (1,3,4)
        f := z^3*(z-2)/(1-2*z);
        Add(points,SphereP1(P1Point(1/2)));
        Add(points,SphereP1(P1Point(-1)));
        Add(points,SphereP1(P1Point(2)));
        return [f,points,[1,2,3]];
    fi;

    i := First([1..3],i->cl[i]=[deg]); # max. cycle
    if i=fail then return fail; fi;
    if Product(perm)=() then
        j := i mod 3+1; k := j mod 3+1;
    else
        k := i mod 3+1; j := k mod 3+1;
    fi;
    if IsSubset(cl{[j,k]},[[2,2],[1,1,2]]) then # (1,2,3,4), (1,2)(3,4), (2,3)
        f := z^2*(z-2)^2;
        if cl[j]=[2,2] then
	    order := [j,k,i];
        else
            order := [k,j,i];
        fi;
	points := points{order};
        Add(points,SphereP1(P1Point(2)));
        Add(points,SphereP1(P1Point(2+Sqrt(2*COMPLEX_1))));
        Add(points,SphereP1(P1Point(2-Sqrt(2*COMPLEX_1))));
        return [f,points,order];
    fi;
    
    m := Maximum(cl[j]);
    if Set(cl[j])<>[1,m] or Set(cl[k])<>[1,deg-m+1] then
        return fail;
    fi;
    # so we know the action around i is (1,...,deg), at infinity
    # the action around j is (m,m-1,...,1), at 0
    # the action around k in (deg,deg-1...,m), at 1
    f := m*Binomial(deg,m)*Primitive(z^(m-1)*(1-z)^(deg-m));
    order := [j,k,i];
    points := points{order};
    for i in [0,1] do
        j := P1PreImages(f,P1Point(i));
        k := List(j,x->P1Distance(x,P1Point(i)));
        SortParallel(k,j);
        if i=0 then
            j := j{[m+1..deg]};
        else
            j := j{[deg+2-m..deg]};
        fi;
        Append(points,List(j,SphereP1));
    od;
    
    return [f,points,order];
end);

BindGlobal("RATIONALMAP@", function(z,values,perm,oldf,oldlifts)
    # find a rational map that has critical values at <values>, with
    # monodromy action given by <perm>, a list of permutations (as lists).
    # returns [map,points] where <points> is the full preimage of <values>
    local cv, p, f, points, deg, i;
    cv := Filtered([1..Length(values)],i->not ISONE@(perm[i]));
    deg := Length(perm[1]);
    if Length(cv)=2 then # bicritical
        p := List(values{cv},C2SPHERE@);
        f := (p[2][1]*z^deg+p[1][1])/(p[2][2]*z^deg+p[1][2]);
        points := [[MACFLOAT_0,MACFLOAT_0,MACFLOAT_1],
                   [MACFLOAT_0,MACFLOAT_0,-MACFLOAT_1]];
    elif Length(cv)=3 then
        p := TRICRITICAL@(z,perm{cv});
        if p<>fail then
            f := PSL2VALUE@(CallFuncList(P1Map,List(ELMS_LIST(values{cv},p[3]),P1Sphere)),p[1]);
            points := p[2];
        fi;
    fi;
    if not IsBound(points) then # run circlepack
        p := RUNCIRCLEPACK@(values{cv},perm{cv});
        Error(p);
        f := fail;
        points := fail;
    fi;
    for i in [1..Length(values)] do if not i in cv then
        Append(points,SPHEREINVF@(f)(values[i]));
    fi; od;
    return [f,points];
end);

BindGlobal("MATCHPERMS@", function(M,q)
    # find a bijection of [1..n] that conjugates M!.output[i] to q[i] for all i
    local c, g, p;
    g := SymmetricGroup(Length(q[1]));
    p := List(GeneratorsOfGroup(StateSet(M)),g->PermList(Output(M,g)));
    q := List(q,PermList);
    c := List([1..Length(p)],i->RepresentativeAction(g,q[i],p[i]));
    Assert(0, not fail in c);
    c := Intersection(List([1..Length(p)],i->RightCoset(Centralizer(g,q[i]),c[i])));
    Assert(0, not IsEmpty(c));
    return c[1];
end);

BindGlobal("MATCHTRANS@", function(M,recur,spider,v)
    # match generators g[i] of M to elements of v.
    # returns a list <w> of elements of <v> such that:
    # if, in M, g[i]^N lifts to a conjugate of g[j] for some integer N, and
    # through <recur> g[i]^N lifts to a conjugate of generator h[k], then
    # set w[j] = v[k].
    # it is in particular assumed that recur[1] has as many lines as
    # StateSet(M) has generators; and that entries in recur[1][j] belong to a
    # free group of rank the length of v.
    local w, i, j, k, c, x, gensM, gensR;

    gensM := GeneratorsOfGroup(StateSet(M));
    gensR := List(GeneratorsOfGroup(spider!.model),x->x^spider!.marking);
    w := [];

    for i in [1..Length(gensM)] do
        x := WreathRecursion(M)(gensM[i]);
        Assert(0,x[2]=recur[2][i]);
        for c in Cycles(PermList(x[2]),AlphabetOfFRObject(M)) do
            j := CyclicallyReducedWord(Product(x[1]{c}));
            k := CyclicallyReducedWord(Product(recur[1][i]{c})^spider!.marking);
            if IsOne(j) then continue; fi;
            j := Position(gensM,j);
            k := PositionProperty(gensR,g->IsConjugate(spider!.group,k,g));
            w[j] := v[k];
        od;
    od;
    Assert(0,BoundPositions(w)=[1..Length(gensM)]);
    return w;
end);

BindGlobal("REDUCEINNER@", function(img0,gen,nf)
    # repeatedly apply conjugation by elements of gen to reduce img, the list
    # of images of generators under an endomorphism.
    # nf makes elements in normal form.
    # modifies img, and returns the conjugating element that was used to reduce;
    # i.e. after the run, List(img,x->x^elt) = img0

    local cost, oldcost, i, img, oldimg, elt, idle;

    elt := One(img0[1]);
    oldimg := List(img0,nf);
    oldcost := Sum(oldimg,Length);

    repeat
        idle := true;
        for i in gen do
            img := List(oldimg,x->nf(x^i));
            cost := Sum(img,Length);
            if cost < oldcost then
                oldcost := cost;
                oldimg := img;
                elt := elt*i;
                idle := false;
                break;
            fi;
        od;
    until idle;
    for i in [1..Length(oldimg)] do img0[i] := oldimg[i]; od;
    return elt;
end);

BindGlobal("MATCHMARKINGS@", function(M,group,recur)
    # return a homomorphism phi from StateSet(M) to <group> such that:
    # if g[i]^k lifts to a conjugate h of g[j] for some integer k, then
    # phi(g[i]^k) = corresponding expression obtained from <recur>.
    local src, dst, transM, transR, i, c, x, gens, g, h;

    gens := GeneratorsOfGroup(StateSet(M));
    transM := [One(StateSet(M))];
    transR := [One(group)];
    src := [1];
    dst := Difference(AlphabetOfFRObject(M),src);
    while not IsEmpty(dst) do
        c := Cartesian(src,dst);
        for i in [1..Length(gens)] do
            x := First(c,p->Output(M,gens[i])[p[1]]=p[2]);
            if x<>fail then break; fi;
        od;
        transM[x[2]] := Transition(M,gens[i],x[1])^-1*transM[x[1]];
        transR[x[2]] := recur[1][i][x[1]]^-1*transR[x[1]];
        Add(src,Remove(dst,Position(dst,x[2])));
    od;

    src := [];
    dst := [];
    for i in [1..Length(gens)] do
        x := WreathRecursion(M)(gens[i]);
        Assert(0,recur[2][i]=x[2]);
        for c in Cycles(PermList(x[2]),AlphabetOfFRObject(M)) do
            g := Product(x[1]{c})^transM[c[1]];
            h := Product(recur[1][i]{c})^transR[c[1]];
            Add(src,g);
            Add(dst,h);
        od;
    od;

    x := GroupHomomorphismByImagesNC(StateSet(M),group,src,dst);
    dst := List(gens,g->g^x);
    REDUCEINNER@(dst,GeneratorsOfMonoid(group),x->x);

    return GroupHomomorphismByImagesNC(StateSet(M),group,gens,dst);
end);

BindGlobal("NORMALIZINGROT@", function(points,oldpoints)
    # returns the (matrix of) Mobius transformation that is a rotation sending
    # P1Sphere(last point) to P1infinity and, if oldpoints<>fail,
    # matches points and oldpoints as well as possible by rotating around the
    # 0-infinity axis
    local i, m, p, q, r;
    
    i := Length(points);
    p := P1Sphere(points[i]);
    if p=P1infinity then
        m := IdentityMat(2,COMPLEX_FIELD);
    else
        p := Complex(p);
        m := [[ComplexConjugate(p),COMPLEX_1],[COMPLEX_1,-p]];
    fi;
    
    r := fail;
    p := List(points,x->CallFuncList(Complex,SphereP1(PSL2VALUE@(m,P1Sphere(x))){[1,2]}));
    
    if oldpoints<>fail then # find optimal rotation to match with oldpoints
        q := List(oldpoints,x->Complex(x[1],x[2]));
        r := (ComplexConjugate(p)*q) / (ComplexConjugate(p)*p);
        
        if AbsoluteValue(r) < 9/10 then # there's no good rotation
            r := fail;
        fi;
    fi;
    if r=fail then
        q := MACFLOAT_1/10; r := MACFLOAT_1;
        for p in p do
            i := AbsoluteValue(p);
            if i>q then q := i; r := p; fi;
        od;
    fi;
    
    return [r/AbsoluteValue(r)*m[1],m[2]];
end);

BindGlobal("NORMALIZINGMAP@", function(points,oldpoints)
    # returns the (matrix of) Mobius transformation that sends v[n] to infinity,
    # the barycenter to 0, and makes the new points as close as possible
    # to oldpoints by a rotation fixing 0-infinity.
    local map, rot, i, barycenter, dilate;

    barycenter := FIND_BARYCENTER(points,[MACFLOAT_1,MACFLOAT_1,MACFLOAT_1],100,MACFLOAT_EPS*10);
    while IsString(barycenter) do
        Error("FIND_BARYCENTER returned ",barycenter,"\nRepent.");
    od;
    dilate := Sqrt(barycenter[1]^2);
    rot := NORMALIZINGROT@([-barycenter[1]/dilate],fail);
    map := [dilate*rot[1],rot[2]];

    points := List(points,p->SphereP1(PSL2VALUE@(map,P1Sphere(p))));

    return NORMALIZINGROT@(points,oldpoints)*map;
end);

BindGlobal("SPIDERDIST@", function(spiderA,spiderB,fast)
    local model, points, perm, dist, recur, endo, nf, g;

    model := spiderA!.model;

    # try to match feet of spiderA and spiderB
    points := VERTICES@(spiderA);
    perm := VERTICES@(spiderB);

    perm := MATCHPOINTS@(perm,List(perm,x->points));
    if perm=fail or Set(perm)<>[1..Length(points)] then # no match, find something coarse
        return Sum(GeneratorsOfGroup(spiderA!.group),x->Length(PreImagesRepresentative(spiderA!.marking,x)^spiderB!.marking));
    fi;

    # move points of spiderB to their spiderA matches
    spiderB := WIGGLESPIDER@(spiderB,points{perm});
    dist := spiderB!.cut!.wiggled;
    
    if fast then # we just wiggled the points, the combinatorics didn't change
        return dist;
    fi;
    
    recur := LIFTSPIDER@(spiderA,spiderB,z->[z],false);
    
    if Group(Concatenation(recur[1]))<>spiderA!.group then
        Error("Endomorphism is not invertible");
    fi;
    

    endo := GroupHomomorphismByImagesNC(spiderB!.group,model,
                    GeneratorsOfGroup(spiderB!.group),
        List(recur[1],x->PreImagesRepresentative(spiderA!.marking,x[1])))*spiderB!.marking;

    endo := List(GeneratorsOfGroup(spiderB!.group),x->x^endo);
    REDUCEINNER@(endo,GeneratorsOfMonoid(spiderB!.group),x->x);
    
    for g in endo do
        dist := dist + (Length(g)-1); # if each image in a gen, then endo=1
    od;
    return dist;
end);

BindGlobal("PUSHRECURSION@", function(map,M)
    # returns a WreathRecursion() function for Range(map), and not
    # Source(map) = StateSet(M)
    local w;
    w := WreathRecursion(M);
    return function(x)
        local l;
        l := w(PreImagesRepresentative(map,x));
        return [List(l[1],x->Image(map,x)),l[2]];
    end;
end);

BindGlobal("PULLRECURSION@", function(map,M)
    # returns a WreathRecursion() function for Source(map), and not
    # Range(map) = StateSet(M)
    local w;
    w := WreathRecursion(M);
    return function(x)
        local l;
        l := w(Image(map,x));
        return [List(l[1],x->PreImagesRepresentative(map,x)),l[2]];
    end;
end);

BindGlobal("PERRONMATRIX@", function(mat)
    local i, j, len;
    # find if there's an eigenvalue >= 1, without using numerical methods

    len := Length(mat);
    if IsEmpty(NullspaceMat(mat-IdentityMat(len))) then # no 1 eigenval
        i := List([1..len],i->1);
        j := List([1..len],i->1); # first approximation to perron-frobenius vector
        repeat
            i := i*mat;
            j := j*mat*mat; # j should have all entries growing exponentially
            if ForAll([1..len],a->j[a]=0 or j[a]<i[a]) then
                return false; # perron-frobenius eigenval < 1
            fi;
        until ForAll(j-i,IsPosRat);
    fi;
    return true;
end);

BindGlobal("SURROUNDINGCURVE@", function(t,x)
    # returns a CCW sequence of edges disconnecting x from its complement in t.
    # x is a sequence of indices of vertices. t is a triangulation.
    local starte, a, c, v, e, i;

    starte := First(t!.e,j->j.from.index in x and not j.to.index in x);
    v := starte.from;
    a := [starte.left.pos];
    c := [];
    i := POSITIONID@(v.n,starte);
    repeat
        i := i+1;
        if i > Length(v.n) then i := 1; fi;
        e := v.n[i];
        if e.to.index in x then
            v := e.to;
            e := e.reverse;
            i := POSITIONID@(v.n,e);
        else
            Add(c,e);
            Add(a,e.pos);
            Add(a,e.left.pos);
        fi;
    until IsIdenticalObj(e,starte);
    return [a,c];
end);

BindGlobal("FINDOBSTRUCTION@", function(M,multicurve,spider,boundary)
    # search for an obstruction starting with the elements of M.
    # return fail or a record describing the obstruction.
    # spider and boundary may be "fail".
    local len, w, x, mat, row, i, j, c, d, group, pi, gens, peripheral;

    len := Length(multicurve);
    gens := GeneratorsOfGroup(StateSet(M));
    group := FreeGroup(Length(gens)-1);
    c := IMGRelator(M);
    pi := GroupHomomorphismByImagesNC(StateSet(M),group,List([1..Length(gens)],i->Subword(c,i,i)),Concatenation(GeneratorsOfGroup(group),[Product(List(Reversed(GeneratorsOfGroup(group)),Inverse))]));

    w := PUSHRECURSION@(pi,M);

    peripheral := List(GeneratorsOfSemigroup(StateSet(M)),x->CyclicallyReducedWord(x^pi));
    multicurve := List(multicurve,x->CyclicallyReducedWord(x^pi));
    mat := [];
    for i in multicurve do
        d := w(i);
        row := List([1..len],i->0);
        for i in Cycles(PermList(d[2]),AlphabetOfFRObject(M)) do
            c := CyclicallyReducedWord(Product(d[1]{i}));
            if ForAny(peripheral,x->IsConjugate(group,x,c)) then
                continue; # peripheral curve
            fi;
            j := First([1..len],j->IsConjugate(group,c,multicurve[j])
                       or IsConjugate(group,c^-1,multicurve[j]));
            if j=fail then # add one more curve
                for j in mat do Add(j,0); od;
                Add(row,1/Length(i));
                len := len+1;
                Add(multicurve,c);
            else
                row[j] := row[j] + 1/Length(i);
            fi;
        od;
        Add(mat,row);
    od;

    Info(InfoFR,1,"Thurston matrix is ",mat);

    x := List(EquivalenceClasses(StronglyConnectedComponents(BinaryRelationOnPoints(List([1..len],x->Filtered([1..len],y->IsPosRat(mat[x][y])))))),Elements);
    for i in x do
        if PERRONMATRIX@(mat{i}{i}) then # there's an eigenvalue >= 1
            d := rec(machine := M,
                     obstruction := [],
                     matrix := mat{i}{i});
            if spider<>fail then
                d.spider := spider;
            fi;
            for j in i do
                if spider<>fail and IsBound(boundary[j]) then
                    Add(spider!.arcs,[[0,0,255],MacFloat(105/100),boundary[j][1]]);
                fi;
                c := [PreImagesRepresentative(pi,multicurve[j])];
                if spider<>fail then
                    REDUCEINNER@(c,GeneratorsOfMonoid(StateSet(M)),NFFUNCTION@(spider));
                fi;
                Append(d.obstruction,c);
            od;
            return d;
        fi;
    od;
    return fail;
end);

InstallOtherMethod(FindThurstonObstruction, "(FR) for a list of IMG elements",
#        [IsIMGElementCollection], !method selection doesn't work!
        [IsFRElementCollection],
        function(elts)
    local M;
    M := UnderlyingFRMachine(elts[1]);
    while not IsIMGMachine(M) or ForAny(elts,x->not IsIdenticalObj(M,UnderlyingFRMachine(x))) do
        Error("Elements do not all have the same underlying IMG machine");
    od;
    return FINDOBSTRUCTION@(M,List(elts,InitialState),fail,fail);
end);

BindGlobal("SPIDEROBSTRUCTION@", function(spider,M)
    # check if <spider> has coalesced points; in that case, read the
    # loops around them and check if they form an obstruction
    local multicurve, boundary, i, j, c, d, x, w;

    # construct a list <x> of (lists of vertices that coalesce)
    w := VERTICES@(spider);
    x := Filtered(Combinations([1..Length(w)],2),p->SPHEREDIST@(w[p[1]],w[p[2]])<EPS@.obst);
    x := EquivalenceClasses(EquivalenceRelationByPairs(Domain([1..Length(w)]),x));
    x := Filtered(List(x,Elements),c->Size(c)>1);
    if IsEmpty(x) then
        return fail;
    fi;

    # replace each x by its conjugacy class
    multicurve := [];
    boundary := [];
    for i in x do
        c := One(spider!.group);
        for j in TREEBOUNDARY@(spider) do
            if (not j.from.index in i) and j.to.index in i and IsBound(spider!.treeelt[j.index]) then
                c := c*spider!.treeelt[j.index];
            fi;
        od;
        Add(multicurve,c);
        Add(boundary,SURROUNDINGCURVE@(spider!.cut,i));

    od;
    Info(InfoFR,1,"Testing multicurve ",multicurve," for an obstruction");

    return FINDOBSTRUCTION@(M,List(multicurve,x->PreImagesRepresentative(spider!.marking,x)),spider,boundary);
end);

BindGlobal("EQUIDISTRIBUTEDPOINTS@", function(N)
    # creates a list of N points equidistributed on the sphere, spiralling
    # from the north pole to the south pole
    local points, i, angle, x, y, z, s, sN;

    points := [];

    while Length(points)<N do
        x := List([1..3],i->Random([-10^6..10^6]));
        if x^2 > 0 and x^2 < 10^12 then
            Add(points,SphereProject(MACFLOAT_1*x));
        fi;
    od;
    return points;

    # old code creates spiral, but it's not nicer
    angle := MACFLOAT_0;
    sN := Sqrt(MACFLOAT_1*N);
    for i in [1..N] do
        z := MACFLOAT_1 - (2*i-1)/N;
        s := Sqrt(MACFLOAT_1-z^2);
        angle := angle + s;
        x := COS_MACFLOAT(angle)*s;
        y := SIN_MACFLOAT(angle)*s;
        Add(points, [x,y,z]);
    od;
    return points;
end);

BindGlobal("FRMACHINE2RAT@", function(z,M)
    local oldspider, spider, t, gens, n, deg, model, poly,
          f, mobius, match, v, i, j, recf, recmobius, map,
          dist, obstruction, lifts, sublifts, fast;

    if ValueOption("precision")<>fail then
        EPS@.prec := ValueOption("precision");
    fi;
    if ValueOption("obstruction")<>fail then
        EPS@.obst := ValueOption("obstruction");
    fi;

    model := StateSet(M);
    gens := GeneratorsOfGroup(model);
    n := Length(gens);
    deg := Length(AlphabetOfFRObject(M));

    # find out if last state is odometer
    poly := Output(M,n)=Concatenation([2..deg],[1]) and Transition(M,n,deg)=gens[n] and ForAll(Transitions(M,n){[1..deg-1]},IsOne);

    # create spider on equidistributed points on Greenwich meridian
    v := [];
    for i in [1..n] do
        i := MACFLOAT_PI*(i/n); # on positive real axis, tending to infinity
        Add(v,[SIN_MACFLOAT(i),MACFLOAT_0,COS_MACFLOAT(i)]);
    od;
    v := Permuted(v,PermList(IMGORDERING@(M)));
    spider := TRIVIALSPIDER@(v);
    IMGMARKING@(spider,model);

    if ValueOption("julia")<>fail then
        i := ValueOption("julia");
        if not IsInt(i) then i := 1000; fi; # number of points to trace
        spider!.points := EQUIDISTRIBUTEDPOINTS@(i);
    fi;
    
    lifts := fail;
    f := fail; # in the beginning, we don't know them
    fast := false;
    repeat
        oldspider := spider;

        # find a rational map that has the right critical values
        f := RATIONALMAP@(z,VERTICES@(spider),List(gens,g->Output(M,g)),f,lifts);
        lifts := f[2]; f := f[1];
        Info(InfoFR,3,"1: found rational map ",f," on vertices ",lifts);

        if fast then # just get points closest to those in spider t
            match := MATCHPOINTS@(sublifts,List(sublifts,x->lifts));
            if match=fail then
		Info(InfoFR,3,"Back to slow mode");
                fast := false; continue;
            fi;
            sublifts := lifts{match};
        else
            # create a spider on the full preimage of the points of <spider>
            t := TRIVIALSPIDER@(lifts);
            IMGMARKING@(t,FreeGroup(Length(lifts)));
            Info(InfoFR,3,"2: created liftedspider ",t);

            # lift paths in <spider> to <t>
            recf := LIFTSPIDER@(t,spider,SPHEREINVF@(f),poly);
            recf := IMGRECURSION@(t,spider,recf[1],recf[2],poly);
            Info(InfoFR,3,"3: recursion ",recf);

            # find a bijection between the alphabets of <recf> and <M>
            match := MATCHPERMS@(M,recf[2]);
            REORDERREC@(recf,match);
            Info(InfoFR,3,"4: alphabet permutation ",match);

            # extract those vertices in <v> that appear in the recursion
            sublifts := MATCHTRANS@(M,recf,t,lifts);
            Info(InfoFR,3,"5: extracted and sorted vertices ",sublifts);
        fi;
 
        # find a mobius transformation that normalizes <sublifts> wrt PSL2C
        mobius := NORMALIZINGMAP@(sublifts,VERTICES@(spider));
        Info(InfoFR,3,"6: normalize by mobius map ",mobius);
        
        # now create the new spider on the image of these points
        map := p->SphereP1(PSL2VALUE@(mobius,P1Sphere(p)));
        v := List(sublifts,map);
        
        if fast then # just wiggle spider around
            spider := WIGGLESPIDER@(spider,v);
        else
            spider := TRIVIALSPIDER@(v);
            recmobius := LIFTSPIDER@(spider,t,p->[map(p)],poly)[1];
            Info(InfoFR,3,"7: new spider ",spider," with recursion ",recmobius);

            # compose recursion of f with that of mobius
            map := t!.marking*GroupHomomorphismByImagesNC(t!.group,spider!.group,GeneratorsOfGroup(t!.group),List(recmobius,x->x[1]));
            for i in recf[1] do
                for j in [1..Length(i)] do i[j] := i[j]^map; od;
            od;
            Info(InfoFR,3,"8: composed recursion is ",recf);

            # finally set marking of new spider using M
            spider!.model := model;
            spider!.ordering := oldspider!.ordering;
            spider!.marking := MATCHMARKINGS@(M,spider!.group,recf);
            Info(InfoFR,3,"9: marked new spider ",spider);
        fi;
        
        dist := SPIDERDIST@(spider,oldspider,fast);
        Info(InfoFR,2,"Spider moved ",dist," steps; feet=",VERTICES@(spider)," marking=",spider!.marking);
        
        if dist<EPS@.ratprec then
            break;
        elif dist<EPS@.fast then
            fast := true;
            continue;
        else
            fast := false;
        fi;
        obstruction := SPIDEROBSTRUCTION@(spider,M);
        if obstruction<>fail then
            return obstruction;
        fi;
    until false;
    
    Info(InfoFR,1,"Spider converged");

    # use last values computed for f,mobius
    # we have to truncate microscopic coefficients to 0, otherwise Value()
    # creates 0/0 and infinity/infinity values
    i := CLEANUPRATIONAL@(PSL2VALUE@(mobius^-1,z),EPS@.ratprec);
    f := CLEANUPRATIONAL@(Value(f,i),EPS@.ratprec);

    # construct a new machine with simpler recursion
    for i in recf[1] do
        for j in [1..Length(i)] do
            i[j] := PreImagesRepresentative(spider!.marking,i[j]);
        od;
    od;
    IMGOPTIMIZE@(recf[1], recf[2], SPIDERRELATORS@(spider),false);
    t := FRMachine(model, recf[1], recf[2]);
    SetIMGRelator(t, SPIDERRELATORS@(spider)[1]);
    SetIMGMachine(f, t);
    #!!! we should "untwist" by seeking a
    # free group automorphism that "untwists" far more spider!.marking
    # set Correspondence(t) to [automorphism, feet positions on P1]
    
    SetSpider(f,spider);

    return f;
end);

InstallMethod(RationalFunction, "(FR) for an IMG machine",
        [IsIMGMachine],
        M->FRMACHINE2RAT@(Indeterminate(COMPLEX_FIELD,"z":old),M));

InstallMethod(RationalFunction, "(FR) for an indeterminate and an IMG machine",
        [IsRingElement,IsIMGMachine],
        FRMACHINE2RAT@);
#############################################################################

#############################################################################
##
#F DBRationalIMGGroup
##
BindGlobal("IMGDB@", []);
Add(IMGDB@, function()
    local e, f, z, h, H, Z;

    f := function(arg)
        local G;
        G := CallFuncList(FRGroup,arg{[4..Length(arg)]});
        SetName(G,Concatenation("IMG(",arg[2],")"));
        G!.Correspondence := arg[3];
        Add(IMGDB@,[arg[1],arg[3],G]);
    end;
    e := function(p)
        local k;
        k := AlgebraicExtension(Rationals,p);
        H := RootOfDefiningPolynomial(k);
        Z := Indeterminate(k,"z":new);
    end;

    z := Indeterminate(Rationals,"z":new);
    h := Indeterminate(Rationals,"h":new);
    Remove(IMGDB@);

    f([2,1],"z^2",z^2,
      "a=<,a>(1,2)");
    f([2,2],"z^-2",z^-2,
      "a=<,a>(1,2)");
    f([3,1],"(z-1)^2",(z-1)^2,
      "a=<,b>(1,2)","b=<,b*a/b>");
    f([3,2],"(2z-1)^2",(2*z-1)^2,
      "a=(1,2)","b=<a,b>");
    f([3,3],"(2z-1)^-2",(2*z-1)^-2,
      "a=<,a^-1/b>(1,2)","b=<a,b>");
    f([3,4],"((z-1)/(z+1))^2",((z-1)/(z+1))^2,
      "a=<,b>(1,2)","b=<a,a^-1/b>");
    f([3,5],"((z-1)/z)^2",((z-1)/z)^2,
      "a=<,b>(1,2)","b=<,a^-1/b>");
    e(2*h^3+2*h^2+2*h+1);
    f([4,1,1],"(z/h+1)^2|2h^3+2h^2+2h+1=0,h~-0.64",(Z/H+1)^2,
      "a=<,a>(1,2)","b=<,a/c>","c=<b,a/b>");
    f([4,1,2],"((z/h+1)^2|2h^3+2h^2+2h+1=0,h~-0.17-0.86i",(Z/H+1)^2,
      "a=(1,2)","b=<a,>","c=<b,c>");
    f([4,2],"((z/i+1)^2",(z/E(4)+1)^2,
      "a=(1,2)","b=<c,c*a/c>","c=<,c*b/c>");
    e(h^3+h^2+2*h+1);
    f([4,3,1],"(z/h+1)^2|h^3+h^2+2h+1=0,h~-0.56",(Z/H+1)^2,
      "a=<,a>(1,2)","b=<,a/c>","c=<b,a/c>");
    f([4,3,2],"(z/h+1)^2|h^3+h^2+2h+1=0,h~-0.21-1.30i",(Z/H+1)^2,
      "a=<,a*c/a>(1,2)","b=<a,>","c=<a*b/a,>");
    H := (1+Sqrt(-7))/4;
    f([4,4],"((z+h)/((-1-2h)z+h))^2|2h^2-h+1=0",((z+H)/((-1-2*H)*z+H))^2,
      "a=(1,2)","b=<c^-1*b*c,a>","c=<c^-1/b/a,c>");
    f([4,5],"((z-1)/(-2z-1))^2",((z-1)/(-2*z-1))^2,
      "a=<,a*c*b/c/a>(1,2)","b=<,a*c*b*a/b/c/a>","c=<a*c/a,b^-1/c/a>");
    f([4,7,1],"((z+i)/(z-i))^2",((z+E(4))/(z-E(4)))^2,
      "a=(1,2)","b=<c*a*b,b*a*b>","c=<b,b*a*c*a*b>");
    f([4,7,2],"((z+1+sqrt2)/(z-1-sqrt2))^2",((z+1+Sqrt(2))/(z-1-Sqrt(2)))^2,
      "a=(1,2)","b=<a,a*b*c>","c=<b,a*b*c*b*a>");
    f([4,7,3],"((z+1-sqrt2)/(z-1+sqrt2))^2",((z+1-Sqrt(2))/(z-1+Sqrt(2)))^2,
      "a=(1,2)","b=<b*a*c,a>","c=<b,c>");
    e(h^3+4*h^2+6*h+2);
    f([4,8,1],"(hz+1)^-2|h^3+4h^2+6h+2=0,h~-0.45",(H*Z+1)^-2,
      "a=<,a^-1/c/b>(1,2)","b=<a,>","c=<a^-1*b*a,a^-1*c*a>");
    f([4,8,2],"(hz+1)^-2|h^3+4h^2+6h+2=0,h~-1.77+1.11i",(H*Z+1)^-2,
      "a=<,c^-1/a/b>(1,2)","b=<,c^-1/a*c>","c=<b,c>");
    H := (1+Sqrt(-7))/4;
    f([4,9],"((z-h/(1+2h))/(z+h))^2|2h^2-h+1=0",((z-H/(1+2*H))/(z+H))^2,
      "a=(1,2)","b=<a*c*a,c^-1/b/a>","c=<a,a*b*a>");
    f([4,10],"(-z/2+1)^-2",(-z/2+1)^-2,
      "a=<,b^-1>(1,2)","b=<c,b^-1*a>","c=<,b>");
    f([4,11],"((z-1)/(z+1+i))^2",((z-1)/(z+1+E(4)))^2,
      "a=<,c^-1*a*b>(1,2)","b=<b^-1/a,c>","c=<,c^-1*a>");
    e(h^3-h^2+3*h+1);
    f([4,12,1],"((z+h)/(z-h))^2|h^3-h^2+3h+1=0,h~-0.29",((Z+H)/(Z-H))^2,
      "a=<,c>(1,2)","b=<a,c/b/c/a/c>","c=<,c*b/c>");
    f([4,12,2],"((z+h)/(z-h))^2|h^3-h^2+3h+1=0,h~-0.64-1.72i",((Z+H)/(Z-H))^2,
      "a=<,b*a*c/a/b>(1,2)","b=<c^-1/a/b,b*a*c*a/c/a/b>","c=<,b*a*c*b/c/a/b>");
    f([4,13],"((z-1)/(z+1/2+i/2))^2",((z-1)/(z+1/2+E(4)/2))^2,
      "a=<,b>(1,2)","b=<,a^-1/c/b>","c=<a,b*c/b>");
    f([4,14],"((z-1)/(-z/2-1))^2",((z-1)/(-z/2-1))^2,
      "a=<,b>(1,2)","b=<a,b*c/b>","c=<,b/c/b/a/b>");
    f([4,15,1],"((-3/2+sqrt5/2)z+1)^-2",((-3/2+Sqrt(5)/2)*z+1)^-2,
      "a=<,c^-1>(1,2)","b=<,c^-1*a>","c=<,c^-1*b>");
    f([4,15,2],"((-3/2-sqrt5/2)z+1)^-2",((-3/2-Sqrt(5)/2)*z+1)^-2,
      "a=<,a^-1>(1,2)","b=<,c^-1*a>","c=<b,>");
    f([4,16],"((z-1)/(z+1/2+sqrt3i/2))^2",((z-1)/(z+E(6)))^2,
      "a=<,a*b/a>(1,2)","b=<,c^-1/b/a>","c=<a,>");
end);

BindGlobal("VALUERATIONAL@", function(f,x)
    local n, d, finv;
    if x=infinity then
        finv := Value(f,1/IndeterminateOfUnivariateRationalFunction(f));
        n := Value(NumeratorOfRationalFunction(finv),0);
        d := Value(DenominatorOfRationalFunction(finv),0);
        if d=0 then return infinity; else return n/d; fi;
    else
        n := Value(NumeratorOfRationalFunction(f),x);
        d := Value(DenominatorOfRationalFunction(f),x);
        if d=0 then return infinity; else return n/d; fi;
    fi;
end);

BindGlobal("CVQUADRATICRATIONAL@", function(f)
    local roots, m, z;
    z := IndeterminateOfUnivariateRationalFunction(f);
    roots := [];
    m := function(func,exp)
        local d, e, r, k;
        d := CoefficientsOfUnivariatePolynomial(NumeratorOfRationalFunction(Derivative(func)));
        if Length(d)=2 then
            r := [-d[1]/d[2]];
        elif Length(d)=3 then
            e := d[2]^2-4*d[3]*d[1];
            if IsRat(e) or IS_COMPLEX(e) then
                e := Sqrt(e);
            else
                k := AlgebraicExtension(z^2-e);
                e := RootOfDefiningPolynomial(k);
                z := Indeterminate(k,String(z):new);
                f := Value(f,z);
            fi;
            r := [(-d[2]-e)/2/d[3],(-d[2]+e)/2/d[3]];
        else return; fi;
        if exp=1 then
            UniteSet(roots,r);
        else
            UniteSet(roots,List(r,x->VALUERATIONAL@(1/z,x)));
        fi;
    end;
    m(f,1);
    m(1/Value(f,1/z),-1);
    if Length(roots)=0 then
        roots := [0,infinity];
    fi;
    if Length(roots)>=2 and AbsoluteValue(roots[1]-roots[2])<EPS@.prec then
        Remove(roots,1);
    fi;
    if Length(roots)=1 then
        Add(roots,infinity);
    fi;
    return Set(roots,x->VALUERATIONAL@(f,x));
end);

BindGlobal("CANONICALQUADRATICRATIONAL@", function(f)
    local d, m, z;
    if DegreeOfLaurentPolynomial(NumeratorOfRationalFunction(f))>2 or
       DegreeOfLaurentPolynomial(DenominatorOfRationalFunction(f))>2 then
        return fail;
    fi;
    z := IndeterminateOfUnivariateRationalFunction(f);
    m := [];
    for d in CVQUADRATICRATIONAL@(f) do
        if IsInfinity(d) then Append(m,[1,0]); else Append(m,[d,1]); fi;
    od;
    f := Value((m[2]*z-m[1])/(-m[4]*z+m[3]),Value(f,(m[3]*z+m[1])/(m[4]*z+m[2])));
    m := VALUERATIONAL@(f,infinity);
    if IsZero(m) or IsInfinity(m) then m := VALUERATIONAL@(f,0); fi;
    if IsZero(m) then
        return [z^2];
    elif IsInfinity(m) then
        return [z^-2];
    fi;
    return Set([Value(f,z*m)/m,m/Value(f,1/m/z)]);
end);

InstallGlobalFunction(PostCriticalMachine, function(f)
    local states, trans, x, i;
    trans := [];
    if DegreeOfRationalFunction(f)<=2 then
        states := CVQUADRATICRATIONAL@(f);
        i := 1;
        while i <= Length(states) do
            x := VALUERATIONAL@(f,states[i]);
            if x in states then
                Add(trans,[Position(states,x)]);
            else
                Add(states,x);
                Add(trans,[Length(states)]);
            fi;
            i := i+1;
            if RemInt(i,10)=0 then
                Info(InfoFR, 2, "PostCriticalMachine: at least ",i," states");
            fi;
        od;
    else
        i := POSTCRITICALPOINTS@(f);
        states := i[3];
        for i in i[4] do
            if i[1]>0 then trans[i[1]] := [i[2]]; fi;
        od;
    fi;
    i := MealyMachineNC(FRMFamily([1]),trans,List(trans,x->[1]));
    SetCorrespondence(i,states);
    return i;
end);

InstallGlobalFunction(DBRationalIMGGroup, function(arg)
    local i, f;
    if IsFunction(IMGDB@[1]) then IMGDB@[1](); fi; # bootstrap
    if arg=[] then
        return  IMGDB@;
    elif IsCollection(arg) and IsInt(arg[1]) then
        for i in IMGDB@ do
            if arg=i[1] then return i[3]; fi;
        od;
        return fail;
    elif IsUnivariateRationalFunction(arg[1]) then
        f := CANONICALQUADRATICRATIONAL@(arg[1]);
        for i in IMGDB@ do
            if i[2] in f then return i[3]; fi;
        od;
        return fail;
    else
        Error("Argument should be indices in Dau's table, or a rational function\n");
    fi;
end);
#############################################################################

#E img.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
