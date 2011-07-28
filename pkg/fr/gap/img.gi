#############################################################################
##
#W img.gi                                                   Laurent Bartholdi
##
#H   @(#)$Id: img.gi,v 1.90 2011/06/20 14:14:31 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  Iterated monodromy groups
##
#############################################################################

ReadPackage("fr", "gap/spider.g");

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

InstallMethod(ViewString, "(FR) for an IMG element",
        [IsIMGElement and IsFRElementStdRep],
        function(E)
    local s;
    s := CONCAT@("<", Size(AlphabetOfFRObject(E)), "#");
    if IsOne(E![2]) then
        Append(s,"identity ...");
    else
        APPEND@FR(s,InitialState(E));
    fi;
    Append(s,">");
    return s;
end);

BindGlobal("IMGISONE@", function(m,relator,w,skip)
    local rws, todo, d, t, seen;

    rws := NewFRMachineRWS(m);
    if not IsBound(rws.relator) then
        rws.addgprule(rws.letterrep(relator),false);
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
        if t<>[] then
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

BindGlobal("MAKENFREL@", function(rel)
    rel := LetterRepAssocWord(rel);
    if rel[1]<0 then rel := -Reversed(rel); fi;
    rel := [rel,[],[]];
    rel[2]{rel[1]} := [1..Length(rel[1])];
    rel[3]{rel[1]} := 3*Length(rel[1])+1-[1..Length(rel[1])];
    Append(rel[1],rel[1]);
    Append(rel[1],-Reversed(rel[1]));
    return rel;
end);

InstallOtherMethod(NFFUNCTION@, [IsGroup, IsWord], function(g,rel)
    # simplify a word in the free group g/[rel]
    local gfam;
    gfam := FamilyObj(Representative(g));
    rel := MAKENFREL@(rel);
    return x->AssocWordByLetterRep(gfam,NFFUNCTION_FR(rel,true,LetterRepAssocWord(x)));
end);

BindGlobal("REMOVEADDER@", function(g,rel,adder)
    # get rid of generator adder in g/[rel]
    local gens, img, i, w;
    gens := GeneratorsOfGroup(g);
    img := ShallowCopy(gens);
    i := PositionWord(rel,adder);
    if i=fail then rel := rel^-1; i := PositionWord(rel,adder); fi;
    img[Position(gens,adder)] := (Subword(rel,i+1,Length(rel))*Subword(rel,1,i-1))^-1;
    return x->MappedWord(x,gens,img);
end);

# a homomorphism from the free group with 1 relation to a genuinely free group
BindGlobal("ISOMORPHISMSIMPLIFIEDIMGGROUP@", function(src, rel)
    local f, srcfam, ffam;
    
    rel := MAKENFREL@(rel);
    f := FreeGroup(RankOfFreeGroup(src)-1);
    srcfam := FamilyObj(Representative(src));
    ffam := FamilyObj(Representative(f));
    return GroupHomomorphismByFunction(src,f,
                   x->AssocWordByLetterRep(ffam,NFFUNCTION_FR(rel,false,LetterRepAssocWord(x))),
                   y->AssocWordByLetterRep(srcfam,NFFUNCTION_FR(rel,true,LetterRepAssocWord(y))));
end);
    
# takes into account the IMG relator to try harder to express a machine
# as a subfrmachine
InstallMethod(SubFRMachine, "(FR) for an IMG machine and a map",
        [IsIMGMachine, IsGroupHomomorphism],
        function(M,f)
    local S, trans, out, i, pi, x, rel, g, h;
    S := StateSet(M);
    while S<>Range(f) do
        Error("SubFRMachine: range and stateset must be the same\n");
    od;
    pi := WreathRecursion(M);
    rel := IMGRelator(M);
    trans := [];
    out := [];
    x := LetterRepAssocWord(rel);
    if [1..RankOfFreeGroup(S)] in [SortedList(x),SortedList(-x)] then
        h := ISOMORPHISMSIMPLIFIEDIMGGROUP@(S,rel);
        g := f*h;
    else
        h := IdentityMapping(S);
        g := f;
    fi;
    
    for i in GeneratorsOfGroup(Source(f)) do
        x := pi(i^f);
        x[1] := List(x[1],x->PreImagesRepresentative(g,x^h));
        if fail in x[1] then return fail; fi;
        Add(trans,x[1]);
        Add(out,x[2]);
    od;
    x := FRMachineNC(FamilyObj(M),Source(f),trans,out);
    i := PreImagesRepresentative(f,rel);
    if i<>fail then
        SetIMGRelator(x,i);
        x := CleanedIMGMachine(x);
    fi;
    if HasAddingElement(M) then
        i := PreImagesRepresentative(f,InitialState(AddingElement(M)));
        if i<>fail then
            SetAddingElement(x,FRElement(x,i));
        fi;
    fi;
    return x;
end);
#############################################################################

#############################################################################
##
#A AsGroupFRMachine, AsMonoidFRMachine, AsSemigroupFRMachine
#A AsIMGMachine
##
InstallGlobalFunction(NewSemigroupFRMachine,
        function(arg)
    if Length(arg)=1 and IsSemigroupFRMachine(arg[1]) then
        return COPYFRMACHINE@(arg[1]);
    fi;
    return UnderlyingFRMachine(CallFuncList(FRSemigroup,arg:IsFRElement).1);
end);
InstallGlobalFunction(NewMonoidFRMachine,
        function(arg)
    if Length(arg)=1 and IsMonoidFRMachine(arg[1]) then
        return COPYFRMACHINE@(arg[1]);
    fi;
    return UnderlyingFRMachine(CallFuncList(FRMonoid,arg:IsFRElement).1);
end);
InstallGlobalFunction(NewGroupFRMachine,
        function(arg)
    if Length(arg)=1 and IsGroupFRMachine(arg[1]) then
        return COPYFRMACHINE@(arg[1]);
    fi;
    return UnderlyingFRMachine(CallFuncList(FRGroup,arg:IsFRElement).1);
end);

InstallGlobalFunction(NewIMGMachine,
        function(arg)
    local relator, args, group, machine, data;
    
    if Length(arg)=1 and IsIMGMachine(arg[1]) then
        machine := COPYFRMACHINE@(arg[1]);
        SetIMGRelator(machine,IMGRelator(arg[1]));
        SetCorrespondence(machine,IdentityMapping(StateSet(machine)));
        return machine;
    fi;
    
    if '=' in arg[Length(arg)] then
        relator := fail;
        args := arg;
    else
        relator := arg[Length(arg)];
        args := arg{[1..Length(arg)-1]};
    fi;
    machine := UnderlyingFRMachine(CallFuncList(FRGroup,args:IsFRElement).1);
    if relator=fail then
        return AsIMGMachine(machine);
    else
        data := rec(holdername := RANDOMNAME@());
        BindGlobal(data.holdername, StateSet(machine));
        relator := STRING_WORD2GAP@(List(GeneratorsOfFRMachine(machine),String),"GeneratorsOfGroup",data,relator);
        MakeReadWriteGlobal(data.holdername);
        UnbindGlobal(data.holdername);
        return AsIMGMachine(machine,relator);
    fi;
end);

BindGlobal("ISIMGRELATOR@", function(M,w)
    local r;
    r := WreathRecursion(M)(w);
    return ISONE@(r[2]) and ForAll(r[1],x->IsOne(x) or IsConjugate(M!.free,x,w));
end);

InstallMethod(IMGMachineNC, "(FR) for a group, a list of transitions, a list of outputs, and a relator",
        [IsFamily,IsFreeGroup,IsList,IsList,IsAssocWord],
        function(fam,g,trans,out,rel)
    local M;
    M := FRMachineNC(fam,g,trans,out);
    SetIMGRelator(M,rel);
    return M;
end);

InstallMethod(AsIMGMachine, "(FR) for a group FR machine and a word",
        [IsGroupFRMachine,IsAssocWord],
        function(M,w)
    local f, i, out, trans, r, p, N;
    if ISIMGRELATOR@(M,w) then
        N := COPYFRMACHINE@(M);
        SetIMGRelator(N,w);
        i := IdentityMapping(StateSet(M));
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

        N := FRMachineNC(FamilyObj(M),f,trans,out);
        SetIMGRelator(N,w^i*f.(r));
    fi;
    SetCorrespondence(N,i);
    return N;
end);

BindGlobal("IMGOPTIMIZE@", function(trans, perm, relator, canfail)
    # modify entries in <trans> so that products along cycles of <perm>
    # are conjugates of a generator; or return fail if that's impossible.
    # also check that these generators occur only once.
    local g, h, i, j, nf, iso, c, group, seen, w, x, y, z;
    
    group := CollectionsFamily(FamilyObj(relator))!.wholeGroup;
    nf := NFFUNCTION@(group, relator);
    iso := ISOMORPHISMSIMPLIFIEDIMGGROUP@(group, relator);
    seen := [];

    for i in [1..Length(trans)] do
        for c in Cycles(PermList(perm[i]),[1..Length(perm[i])]) do
            g := One(group);
            for j in c do
                h := nf(g*trans[i][j]);
                trans[i][j] := g^-1*h;
                g := h;
            od;
            if IsOne(h) or # product of entries is 1
               # or product of entries is a conjugate of a generator
               ForAny(GeneratorsOfGroup(group),g->IsConjugate(group,g,h)) then
                continue;
            fi;
            # we try to be subtle: maybe it becomes a conjugate of a generator
            # only using the IMG relation.
            x := h^iso;
            for y in GeneratorsOfGroup(group) do
                z := RepresentativeAction(Range(iso),y^iso,x);
                if z<>fail then break; fi;
            od;
            while z=fail or y in seen do # either x<>y^z, or y appears twice
                if canfail then return fail; fi;
                Error("Could not express recursion on topological sphere");
            od;
            z := PreImage(iso,z); # now h=y^z            
            AddSet(seen,y);
            # ok, now we want to change the last <>1 entry of trans[i]{c} so
            # that the product really is a conjugate of a generator.
            j := First(Reversed(c),j->not IsOne(trans[i][j]));
            trans[i][j] := trans[i][j]/h*nf(y^z);
        od;
    od;
    return true;
end);

InstallMethod(CleanedIMGMachine, "(FR) for an IMG machine",
        [IsIMGMachine],
        function(M)
    local perm, trans, f, newM;
    
    perm := M!.output;
    trans := List(M!.transitions,ShallowCopy);
    
    if IMGOPTIMIZE@(trans, perm, IMGRelator(M), true)=fail then # cheap method, then
        f := NFFUNCTION@(StateSet(M),IMGRelator(M));
        trans := List(M!.transitions,r->List(r,f));
    fi;
    newM := FRMachineNC(FamilyObj(M),StateSet(M),trans,perm);
    SetIMGRelator(newM,IMGRelator(M));
    return newM;
end);

InstallMethod(AsIMGMachine, "(FR) for a group FR machine",
        [IsIMGMachine], M->M);

InstallMethod(AsIMGMachine, "(FR) for a group FR machine",
        [IsGroupFRMachine],
        function(M)
    local w, p, trans, perm, N;
    
    # try running a spider algorithm to discover a good ordering
    w := SPIDERALGORITHM@(M);
    perm := [fail];
    if w<>fail and w.minimal then # insert that ordering
        Add(perm,GeneratorsOfGroup(M!.free){w.ordering},1);
    fi;
    for p in perm do
        if p=fail then # add now all permutations fixing first letter
            for p in SymmetricGroup([2..Length(GeneratorsOfGroup(M!.free))]) do
                Add(perm,Permuted(GeneratorsOfGroup(M!.free),p));
            od;
            continue;
        fi;
        w := Product(p,One(StateSet(M)));
        if ISIMGRELATOR@(M,w) then
            trans := List(M!.transitions,ShallowCopy);
            perm := List(M!.output,ShallowCopy);

            if IMGOPTIMIZE@(trans,perm,w,true)=fail then
                break;
            fi;
            N := FRMachineNC(FamilyObj(M),M!.free,trans,perm);
            SetIMGRelator(N,w);
            SetCorrespondence(N,IdentityMapping(M!.free));
            return N;
        fi;
    od;
    return fail;
end);

InstallMethod(AsGroupFRMachine, "(FR) for an IMG machine",
        [IsIMGMachine],
        COPYFRMACHINE@);

InstallMethod(ViewString, "(FR) for an IMG machine",
        [IsIMGMachine and IsFRMachineStdRep],
        M->CONCAT@("<FR machine with alphabet ", AlphabetOfFRObject(M), " on ", StateSet(M), "/[ ",IMGRelator(M)," ]>"));

InstallMethod(DisplayString, "(FR) for an IMG machine",
        [IsIMGMachine and IsFRMachineStdRep],
        M->CONCAT@(DISPLAYFRMACHINE@(M),"Relator: ",IMGRelator(M),"\n"));
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

BindGlobal("NORMALIZEHOMOMORPHISM@", function(f)
    local g, mapi, sf, rf, gens;
    if not HasMappingGeneratorsImages(f) then
        return f;
    fi;
    mapi := MappingGeneratorsImages(f);
    sf := Source(f);
    rf := Range(f);
    gens := GeneratorsOfGroup(sf);
    if mapi[1]=gens then
        return f;
    fi;
    g := Group(mapi[1]);
    mapi := mapi[2];
    return GroupHomomorphismByImagesNC(sf,rf,gens,List(gens,x->Product(AsWordLetterRepInGenerators(x,g),i->mapi[AbsInt(i)]^SignInt(i),One(rf))));
end);
                       
InstallMethod(\*, "(FR) for an FR machine and a mapping",
        [IsFRMachine and IsFRMachineStdRep, IsMapping],
        function(M,f)
    local S, N, x;
    S := StateSet(M);
    if S<>Source(f) or S<>Range(f) then
        Error("\*: source, range and stateset must be the same\n");
    fi;
    f := NORMALIZEHOMOMORPHISM@(f);
    N := FRMachineNC(FamilyObj(M),S,List(M!.transitions,r->List(r,x->x^f)),M!.output);
    if HasIMGRelator(M) then
        if IMGISONE@(N,IMGRelator(M),IMGRelator(M),true) then
            SetIMGRelator(N,IMGRelator(M));
        else
            Info(InfoFR, 2, "Warning: result of composition does not seem to be an IMG machine");
        fi;
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
    if HasIMGRelator(M) then
        if IMGISONE@(N,IMGRelator(M),IMGRelator(M),true) then
            SetIMGRelator(N,IMGRelator(M));
        else
            Info(InfoFR, 2, "Warning: result of composition does not seem to be an IMG machine");
        fi;
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
        Error("\^: source, range and stateset must be the same\n");
    fi;
    pi := WreathRecursion(M);
    trans := [];
    out := [];
    finv := Inverse(f);
    f := NORMALIZEHOMOMORPHISM@(f);
    if finv=fail then return fail; fi;
    for i in [1..Length(M!.output)] do
        x := pi(GeneratorsOfFRMachine(M)[i]^finv);
        Add(trans,List(x[1],x->x^f));
        Add(out,x[2]);
    od;
    x := FRMachineNC(FamilyObj(M),S,trans,out);
    if HasIMGRelator(M) then
        SetIMGRelator(x,CyclicallyReducedWord(IMGRelator(M)^f));
    fi;
    if HasAddingElement(M) then
        SetAddingElement(x,FRElement(x,InitialState(AddingElement(M))^f));
    fi;
    return x;
end);

#############################################################################

#############################################################################
##
#M ChangeFRMachineBasis
##
BindGlobal("REORDERREC@", function(m,perm)
    # reorder the entries of m=[trans,perm] according to the permutation perm.
    local i;
    for i in [1..Length(m[1])] do
        m[1][i] := Permuted(m[1][i],perm);
        m[2][i] := ListPerm(PermList(m[2][i])^perm,Length(m[2][i]));
    od;
end);

BindGlobal("FLIPSPIDER@", function(m,adder)
    # reverses the marking at infinity, by conjugating by the base change
    # <adder,1,...,1>[1,deg,deg-1,...,2]
    # this is a change of basis that sends the adding machine to its inverse,
    # assuming the adding machine was normalized to be <adder,1,...,1>(i->i-1)
    local j, k, deg;
    
    for j in [1..Length(m[1])] do
        m[1][j][1] := adder^-1*m[1][j][1];
        k := Position(m[2][j],1);
        m[1][j][k] := m[1][j][k]*adder;
    od;
    deg := Length(m[1][1]);
    REORDERREC@(m,PermList(Concatenation([1],[deg,deg-1..2])));
end);

BindGlobal("CHANGEFRMACHINEBASIS@", function(M,l,p)
    local trans, i, d, newM;
    d := Size(AlphabetOfFRObject(M));
    while Length(l)<>d or not ForAll(l,x->x in StateSet(M)) do
        Error("Invalid base change ",l,"\n");
    od;
    while LargestMovedPoint(p)>d do
	Error("Invalid permutation ",p,"\n");
    od;
    trans := [];
    for i in [1..Length(M!.transitions)] do
        Add(trans,Permuted(List(AlphabetOfFRObject(M),a->l[a]^-1*M!.transitions[i][a]*l[M!.output[i][a]]),p));
    od;
    newM := FRMachineNC(FamilyObj(M),StateSet(M),trans,List(M!.output,r->ListPerm(PermList(r)^p,d)));
    if HasIMGRelator(M) then
        SetIMGRelator(newM,IMGRelator(M));
    fi;
    if HasAddingElement(M) then
        SetAddingElement(newM,FRElement(newM,InitialState(AddingElement(M))));
    fi;
    return newM;
end);

InstallMethod(ChangeFRMachineBasis, "(FR) for a group FR machine and a list",
        [IsGroupFRMachine, IsCollection],
        function(M,l)
    return CHANGEFRMACHINEBASIS@(M,l,());
end);	
InstallMethod(ChangeFRMachineBasis, "(FR) for a group FR machine and a permutation",
        [IsGroupFRMachine, IsPerm],
        function(M,p)
    return CHANGEFRMACHINEBASIS@(M,List(AlphabetOfFRObject(M),x->One(StateSet(M))),p);
end);	
InstallMethod(ChangeFRMachineBasis, "(FR) for a group FR machine, a list and a permutation",
        [IsGroupFRMachine, IsCollection, IsPerm],
    CHANGEFRMACHINEBASIS@);

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
    while S<>[] do
        t := First([1..Length(S)],i->Number(S[i][2],i->IsBound(l[i]))>0);
        if t=fail then
            Error("Action is not transitive");
            return fail;
        fi;
        t := Remove(S,t);
        s := Filtered(t[2],i->IsBound(l[i]));
        if Length(s)>1 and not IsIMGMachine(M) then
            Error("Action is not contractible (tree-like)");
            return fail;
        fi;
        s := s[1];
        u := s;
        while true do
            v := Output(M,t[1],u);
            if v=s then
                break;
            else
                l[v] := LeftQuotient(Transition(M,t[1],u),l[u]);
                u := v;
            fi;
        od;
    od;
    return CHANGEFRMACHINEBASIS@(M,l,());
end);


InstallMethod(ComplexConjugate, "(FR) for a group FR machine",
        [IsGroupFRMachine],
        function(M)
    local S;
    S := StateSet(M);
    M := M^GroupHomomorphismByImagesNC(S,S,GeneratorsOfGroup(S),List(GeneratorsOfGroup(S),Inverse));
    return M;
end);

InstallMethod(ComplexConjugate, "(FR) for an IMG FR machine",
        [IsIMGMachine],
        function(M)
    local S, N, a, m;
    S := StateSet(M);
    N := M^GroupHomomorphismByImagesNC(S,S,GeneratorsOfGroup(S),List(GeneratorsOfGroup(S),Inverse));
    N!.IMGRelator := Reversed(IMGRelator(M)); # make it a positive word
    if HasAddingElement(N) then
        m := [List(N!.transitions,ShallowCopy),ShallowCopy(N!.output)];
        a := InitialState(AddingElement(N));
        FLIPSPIDER@(m,a);
        a := Inverse(a);
        N!.transitions := List(m[1],x->List(x,y->y^a));
        N!.output := m[2];
        N!.AddingElement := FRElement(N,a); # make it a positive generator
    fi;
    return N;
end);

InstallMethod(RotatedSpider, "(FR) for a polynomial IMG machine",
        [IsPolynomialIMGMachine,IsInt],
        function(M,p)
    local adder;
    adder := DecompositionOfFRElement(AddingElement(M)^p);
    return CHANGEFRMACHINEBASIS@(M,List(adder[1],InitialState),PermList(adder[2]));
end);

InstallMethod(RotatedSpider, "(FR) for a polynomial IMG machine",
        [IsPolynomialIMGMachine],
        M->RotatedSpider(M,1));

InstallMethod(VirtualEndomorphism, "(FR) for a group FR machine and a vertex",
        [IsIMGMachine,IsPosInt],
        function(M,v)
    local G, Q, T, T2, Hgens, Himg, g, c;
    G := StateSet(M);
    # construct transversal: T[i] maps i to v
    T2 := RightTransversal(G,Stabilizer(G,v,function(w,g) return w^FRElement(M,g); end));
    T := [];
    T{List(T2,g->v^FRElement(M,g))} := List(T2,Inverse);
    
    # now choose good generators: one per cycle of the action
    Hgens := [];
    Himg := [];
    for g in GeneratorsOfGroup(G) do
        for c in Cycles(PermList(Output(M,g)),AlphabetOfFRObject(M)) do
            Add(Hgens,(g^Length(c))^T[c[1]]);
            Add(Himg,Product(Transitions(M,g){c})^Transition(M,T[c[1]],c[1]));
        od;
    od;
    Q := G/[IMGRelator(M)];
    Hgens := List(Hgens,g->ElementOfFpGroup(FamilyObj(One(Q)),g));
    Himg := List(Himg,g->ElementOfFpGroup(FamilyObj(One(Q)),g));
    return GroupHomomorphismByImages(Group(Hgens),Q,Hgens,Himg);
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

InstallMethod(ViewString, "(FR) for a polynomial FR machine",
        [IsPolynomialFRMachine and IsFRMachineStdRep],
        M->CONCAT@("<FR machine with alphabet ", AlphabetOfFRObject(M), " and adder ", AddingElement(M), " on ", StateSet(M), ">"));

InstallMethod(DisplayString, "(FR) for a polynomial FR machine",
        [IsPolynomialFRMachine and IsFRMachineStdRep],
        M->CONCAT@(DISPLAYFRMACHINE@(M),"Adding element: ",AddingElement(M),"\n"));

InstallMethod(ViewString, "(FR) for a polynomial IMG machine",
        [IsPolynomialIMGMachine and IsFRMachineStdRep],
        M->CONCAT@("<FR machine with alphabet ", AlphabetOfFRObject(M), " and adder ", AddingElement(M), " on ", StateSet(M), "/[ ",IMGRelator(M)," ]>"));

InstallMethod(DisplayString, "(FR) for an IMG machine",
        [IsPolynomialIMGMachine and IsFRMachineStdRep],
        M->CONCAT@(DISPLAYFRMACHINE@(M),
                "Adding element: ",AddingElement(M),"\n",
                "Relator: ",IMGRelator(M),"\n"));

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
    local S, aS, result, a, x, perm;

    if not IsKneadingMachine(M) then
        return [];
    fi;
    S := M{GeneratorsOfFRMachine(M)};
    aS := Filtered([1..Length(S)],i->not IsOne(S[i]));
    result := [];
    perm := PermutationsList(aS);
    
    # use a spider algorithm to try to guess a good ordering
    a := SPIDERALGORITHM@(AsGroupFRMachine(M));
    if a<>fail and a.minimal then
        Add(perm,a.ordering,1); # put it at front
    fi;
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
        M->PLANAREMBEDDINGMEALYMACHINE@(M,true)<>[]);

InstallMethod(AsPolynomialFRMachine, "(FR) for a Mealy machine",
        [IsMealyMachine],
        function(M)
    local a;
    a := PLANAREMBEDDINGMEALYMACHINE@(M,true);
    if a=[] then return fail; fi;
    M := AsGroupFRMachine(M);
    SetAddingElement(M,FRElement(M,Product(a,x->x^Correspondence(M))));
    return M;
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

InstallMethod(SupportingRays, "(FR) for a group FR machine",
        [IsGroupFRMachine],
        function(M)
    local e;
    e := SPIDERALGORITHM@(M);
    if e.minimal = false then
        return e;
    fi;
    return [Length(AlphabetOfFRObject(M)),e.supportingangles[1],e.supportingangles[2]];
end);

InstallMethod(SupportingRays, "(FR) for a group FR machine",
        [IsPolynomialIMGMachine],
        function(M)
    local e, trans, out, nf, newM, i;
    
    # first remove all occurrences of the adding element, if possible
    e := InitialState(AddingElement(M));
    nf := REMOVEADDER@(StateSet(M),IMGRelator(M),e);
    trans := List(M!.transitions,r->List(r,nf));
    i := Position(GeneratorsOfFRMachine(M),e);
    trans[i] := M!.transitions[i];
    newM := IMGMachineNC(FamilyObj(M),StateSet(M),trans,M!.output,IMGRelator(M));
    
    e := SPIDERALGORITHM@(newM);
    if e.minimal = false then
        return e;
    fi;
    return [Length(AlphabetOfFRObject(M)),e.supportingangles[1],e.supportingangles[2]];
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
    # add one generator for adding element
    local f, i, n, trans, perm, rel, newM;
    n := RankOfFreeGroup(StateSet(M));
    f := FreeGroup(n+1);
    i := GroupHomomorphismByImages(StateSet(M),f,GeneratorsOfFRMachine(M),GeneratorsOfGroup(f){[1..n]});
    trans := List(M!.transitions,r->List(r,x->x^i));
    perm := ShallowCopy(M!.output);
    newM := WreathRecursion(M)(InitialState(AddingElement(M)));
    Add(trans,List(newM[1],x->x^i));
    Add(perm,newM[2]);
    rel := InitialState(AddingElement(M))^i/GeneratorsOfGroup(f)[n+1];
    IMGOPTIMIZE@(trans,perm,rel,true);
    newM := FRMachineNC(FamilyObj(M),f,trans,perm);
    SetAddingElement(newM,FRElement(newM,n+1));
    SetIMGRelator(newM,rel);
    SetCorrespondence(newM,i);
    return newM;
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
    gen := Concatenation(gen,List(gen,Inverse));
    
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
    while dst<>[] do
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

BindGlobal("NORMALIZEADDINGMACHINE@", function(model,trans,out,adder)
    # conjugate the recursion so that element adder, which is checked to
    # be an adding machine, becomes of the form (t,...,1)s,
    # where s is the cycle i|->i-1 mod d.
    # adder is the position of the adding element.
    # model is the ambient fundamental group.
    local cycle, deg, perm, x, i, j, basis;
    
    deg := Length(trans[1]);
    cycle := Cycles(PermList(out[adder]),[1..deg]);
    while Length(cycle)<>1 or not IsConjugate(model,Product(trans[adder]{cycle[1]}),model.(adder)) do
        Error("Element #",adder," is not an adding element");
    od;
    
    perm := PermList(Concatenation([deg],[1..deg-1]));
    perm := RepresentativeAction(SymmetricGroup(deg),PermList(out[adder]),perm);
    REORDERREC@([trans,out],perm);

    basis := [];
    x := One(model);
    for i in [deg,deg-1..1] do
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
    NORMALIZEADDINGMACHINE@(M!.free,trans,out,adder);
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

InstallMethod(SimplifiedIMGMachine, "(FR) for a polynomial IMG machine",
        [IsPolynomialIMGMachine],
        function(M)
    local r, i, x;
    r := SPIDERALGORITHM@(M);
    if r<>fail and r.minimal then
        SetCorrespondence(r.machine,r.transformation);
        x := IMGRelator(M);
        for i in r.transformation do x := x^i; od;
        SetIMGRelator(r.machine,x);
        return r.machine;
    fi;
    return M;
end);

InstallMethod(SimplifiedIMGMachine, "(FR) for an IMG machine",
        [IsIMGMachine],
        function(M)
    local N;
    Info(InfoFR,2,"Simplification not yet implemented for general IMG machines");
    N := COPYFRMACHINE@(M);
    SetIMGRelator(N,IMGRelator(M));
    if HasAddingElement(M) then
        SetAddingElement(N,FRElement(N,InitialState(AddingElement(M))));
    fi;
    SetCorrespondence(N,[]);
    return N;
end);
#############################################################################

ReadPackage("fr", "gap/triangulations.g");
  
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
        repeat
            p := [TRUNC@(d*p[1]),p[2]];
            t := t or (p in V); # check if there's a critical point on cycle
        until q=p;
        while (p[2]=FJ@[1] and not t) or (p[2]=FJ@[2] and t and d=2) do
            Error("critical value ",i[1]," should not be in the ",p[2]," set");
        od;
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
    
    
    while Sum(C,x->Length(x[1])-1)<>d-1 do
        Error("F and J describe a map of wrong degree");
    od;
    
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
        #!!! Product(Reversed(g)) should be faster, but buggy in 4.dev
        SetAddingElement(machine,Product(Reversed(g),i->FRElement(machine,i)));
    elif machtype=2 then
        machine := FRMachine(f,trans,out);
        SetCorrespondence(machine,pcp);
        SetAddingElement(machine,FRElement(machine,Reversed(Product(g))));
    elif machtype=3 then
        t := [g[Length(g)]];
        Append(t,List([1..d-1],i->one));
        Add(trans,t);
        Add(out,Concatenation([d],[1..d-1]));
        machine := FRMachine(f,trans,out);
        SetIMGRelator(machine,Reversed(Product(g)));
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

BindGlobal("FATOUANGLES@", function(n,A)
    return Filtered(A,x->Gcd(DenominatorRat(x),n)=1);
end);
BindGlobal("JULIAANGLES@", function(n,A)
    return Filtered(A,x->Gcd(DenominatorRat(x),n)<>1);
end);

InstallMethod(PolynomialMealyMachine, "(FR) for a degree and preangles",
        [IsPosInt,IsList],
        function(n,A)
    return PolynomialMealyMachine(n,FATOUANGLES@(n,A),JULIAANGLES@(n,A));
end);

InstallMethod(PolynomialFRMachine, "(FR) for a degree and preangles",
        [IsPosInt,IsList],
        function(n,A)
    return PolynomialFRMachine(n,FATOUANGLES@(n,A),JULIAANGLES@(n,A));
end);

InstallMethod(PolynomialIMGMachine, "(FR) for a degree and preangles",
        [IsPosInt,IsList],
        function(n,A)
    return PolynomialIMGMachine(n,FATOUANGLES@(n,A),JULIAANGLES@(n,A));
end);

InstallMethod(PolynomialIMGMachine, "(FR) for a degree, preangles, and formal",
        [IsPosInt,IsList,IsBool],
        function(n,A,formal)
    return PolynomialIMGMachine(n,FATOUANGLES@(n,A),JULIAANGLES@(n,A),formal);
end);

BindGlobal("MATING@", function(machines,adders,formal)
    local w, i, j, k, states, gen, sgen, sum, f, c, trans, out, deg;
    
    if not formal then
        Error("Non-formal matings are not yet implemented. Complain to laurent.bartholdi@gmail.com");
    fi;
    
    deg := List(machines,m->Length(AlphabetOfFRObject(m)));
    while deg[1]<>deg[2] do
        Error("In a mating, the machines must have same degree, not ",deg);
    od;
    deg := deg[1];
           
    w := List(machines,m->CyclicallyReducedWord(IMGRelator(m)));
    for i in [1..2] do
        j := PositionWord(w[i],adders[i]);
        if j=fail then
            Assert(0,false); # this should not happen, adders are normalized
            w[i] := w[i]^-1;
            j := PositionWord(w[i],adders[i]);
        fi;
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
        trans := List(machines[i]!.transitions,ShallowCopy);
        out := List(machines[i]!.output,ShallowCopy);
        NORMALIZEADDINGMACHINE@(StateSet(machines[i]),trans,out,c[i]);
        if i=2 then
            FLIPSPIDER@([trans,out],GeneratorsOfGroup(states[i])[c[i]]);
        fi;
        machines[i] := FRMachineNC(FamilyObj(machines[i]),StateSet(machines[i]),trans,out);
        c[i] := GroupHomomorphismByImagesNC(states[i],f,GeneratorsOfGroup(states[i]),sgen[i]);
    od;
    
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
    return Mating(M1,M2,true);
end);

InstallMethod(Mating, "(FR) for two polynomial IMG machines and a boolean",
        [IsPolynomialFRMachine,IsPolynomialFRMachine,IsBool],
        function(M1,M2,formal)
    local i, inj, M;
    M := [M1,M2];
    inj := [];
    for i in [1..2] do
        if IsIMGMachine(M[i]) then
            inj[i] := IdentityMapping(StateSet(M[i]));
        else
            M[i] := AsPolynomialIMGMachine(M[i]);
            inj[i] := Correspondence(M[i]);
        fi;
    od;
    M := MATING@(M,List(M,x->InitialState(AddingElement(x))),formal);
    M!.Correspondence := List([1..2],i->inj[i]*Correspondence(M)[i]);
    return M;
end);
#############################################################################

#############################################################################
##
#F Automorphisms of machines and virtual endomorphisms
##
BindGlobal("PUREMCG@", function(arg)
    local r, i, j, m, ni, nj, gens, img, aut, relator, G, maker;
    
    if Length(arg)=1 and IsFpGroup(arg[1]) then
        G := arg[1];
        relator := RelatorsOfFpGroup(G)[1];
        maker := w->ElementOfFpGroup(FamilyObj(One(G)),w);
    elif Length(arg)=2 and IsFreeGroup(arg[1]) and arg[2] in arg[1] then
        G := arg[1];
        relator := arg[2];
        maker := w->w;
    else
        Error("PUREMCG@fr: requires a fp group or a free group and a relator");
    fi;
    gens := GeneratorsOfGroup(G);
        
    aut := [];
    for ni in [1..Length(relator)] do
        for nj in [ni+1..Length(relator)] do
            m := maker(Subword(relator,ni+1,nj-1));
            i := LetterRepAssocWord(relator)[ni];
            j := LetterRepAssocWord(relator)[nj];
            img := ShallowCopy(gens);
            img[i] := gens[i]^(m*gens[j]/m);
            img[j] := gens[j]^(m^-1*gens[i]*m*gens[j]);
            Add(aut,GroupHomomorphismByImages(G,G,gens,img));
        od;
    od;
    if Length(gens)=2 then Add(aut,InnerAutomorphism(G,gens[1])); fi;
    return Group(aut);
end);

InstallMethod(AutomorphismVirtualEndomorphism, "(FR) for a virtual endo",
        [IsGroupHomomorphism],
        function(vendo)
    # given a virtual endomorphism h->g, constructs the induced
    # virtual endomorphism on aut(g)
    local g, h, freeg, freeh, isog, isoh, embedding, v, vinverse,
          mcg, mch, freemcg, cch, restricth, mcv, mcvimg, act;
    
    g := Range(vendo);
    h := Source(vendo);
    isog := IsomorphismSimplifiedFpGroup(g);
    isog := isog*GroupHomomorphismByImages(Range(isog),FreeGroupOfFpGroup(Range(isog)));
    isoh := IsomorphismFpGroup(h);
    isoh := isoh*IsomorphismSimplifiedFpGroup(Range(isoh));
    isoh := isoh*GroupHomomorphismByImages(Range(isoh),FreeGroupOfFpGroup(Range(isoh)));
    freeg := Range(isog);
    freeh := Range(isoh);
    embedding := GroupHomomorphismByImages(freeh,freeg,List(GeneratorsOfGroup(h),x->x^isoh),List(GeneratorsOfGroup(h),x->x^isog));
    v := GroupHomomorphismByImages(freeh,freeg,List(GeneratorsOfGroup(h),x->x^isoh),List(GeneratorsOfGroup(h),x->(x^vendo)^isog));
    vinverse := GroupHomomorphismByImages(freeg,freeh,GeneratorsOfGroup(freeg),List(GeneratorsOfGroup(freeg),x->PreImagesRepresentative(vendo,PreImage(isog,x))^isoh));
    
    mcg := PUREMCG@(g);
    freemcg := Group(List(GeneratorsOfGroup(mcg),x->x^isog));
#    isomcg := GroupHomomorphismByImagesNC(mcg,freemcg);
    
    # first the subgroup of mcg stabilizing h
    act := function(subgroup,aut)
        return Group(List(GeneratorsOfGroup(subgroup),x->x^aut));
    end;
    mch := Stabilizer(freemcg,Image(embedding),act);

    # then the subgroup fixing parabolic conjugacy classes in h;
    cch := List(GeneratorsOfGroup(h),x->ConjugacyClass(freeh,x^isoh));
    restricth := aut->GroupHomomorphismByImages(freeh,freeh,List(GeneratorsOfGroup(freeh),g->PreImagesRepresentative(embedding,(g^embedding)^aut)));
    act := function(list,aut)
        return List(list,x->ConjugacyClass(freeh,Representative(x)^restricth(aut)));
    end;
    mch := Stabilizer(mch,cch,act);
    
    mch := GroupByGenerators(List(GeneratorsOfGroup(mch),a->GroupHomomorphismByImages(g,g,List(GeneratorsOfGroup(g),x->PreImage(isog,(x^isog)^a)))));
    return GroupHomomorphismByFunction(mch,mcg,a->GroupHomomorphismByImages(g,g,List(GeneratorsOfGroup(g),x->PreImage(isog,((PreImage(isoh,(x^isog)^vinverse)^a)^isoh)^v))));        
end);

BindGlobal("DISTILLATE@", function(M)
    # distillates the machine M to a machine with at most one non-trivial
    # transition on each cycle; which is at the beginning of the cycle
    # and is a generator.
    # returns [new machine, free group automorphism encoding distillation]
    local G, perm, trans, cc, zero, g, i, j, c, cg, aut;
    
    G := StateSet(M);
    cc := List(GeneratorsOfFRMachine(M),g->ConjugacyClass(G,g));
    zero := ConjugacyClass(G,One(G));
    aut := [];
    
    perm := M!.output;
    trans := List(M!.transitions,ShallowCopy);
    for i in [1..Length(trans)] do
        for c in Cycles(PermList(perm[i]),AlphabetOfFRObject(M)) do
            g := One(G);
            for j in c do
                g := g*trans[i][j];
                trans[i][j] := One(G);
            od;
            cg := ConjugacyClass(G,g);
            if cg<>zero then
                j := Position(cc,cg);
                trans[i][c[1]] := GeneratorsOfFRMachine(M)[j];
                aut[j] := g;
            fi;
        od;
    od;
    return [FRMachineNC(FamilyObj(M),G,trans,perm),GroupHomomorphismByImages(G,G,aut)];
end);

BindGlobal("FACTORIZEAUT@", function(epi,M,aut)
    local nf, img, oldimg, cost, oldcost, w, gens, i, idle;
    
    w := One(Source(epi));
    nf := NFFUNCTION@(StateSet(M),IMGRelator(M));
    gens := GeneratorsOfFRMachine(M);
    img := List(gens,x->nf(x^aut));
    oldimg := img;
    oldcost := Sum(oldimg,Length);
    repeat
        idle := true;
        for i in GeneratorsOfMonoid(Source(epi)) do
            img := List(oldimg,x->x^(i^epi));
            REDUCEINNER@(img,gens,nf);
            cost := Sum(img,Length);
            if cost < oldcost then
                oldcost := cost;
                oldimg := img;
                w := w*i;
                idle := false;
                break;
            fi;
        od;
    until idle;
    Assert(0,oldimg=gens);
    return w;
end);

BindGlobal("MOTIONGROUP@", function(G)
    local i, j, gens, img, aut;
    
    gens := GeneratorsOfGroup(G);
        
    aut := [];
    for i in [1..Length(gens)] do
        for j in [1..Length(gens)] do
            if i=j then continue; fi;
            img := ShallowCopy(gens);
            img[i] := gens[i]^gens[j];
            Add(aut,GroupHomomorphismByImages(G,G,img));
        od;
    od;
    return Group(aut);
end);

InstallMethod(AutomorphismIMGMachine, "(FR) for an IMG machine",
        [IsIMGMachine],
        function(M)
    local orbit, act, inneract, pmcg, states, output, transition, o, t,
          reps, transversal, epi, a, b, d, g, newM, recur;
    
    states := StateSet(M);
    act := function(machine,aut) return DISTILLATE@(aut^-1*machine)[1]; end;
    inneract := function(machine,g) return DISTILLATE@(InnerAutomorphism(states,g^-1)*machine)[1]; end;
    pmcg := PUREMCG@(states,IMGRelator(M));
    orbit := Orbit(pmcg,DISTILLATE@(M)[1],act);
    
    # sort orbit so that consecutive blocks are related by inner automorphisms
    orbit := OrbitsDomain(states,orbit,inneract);
    reps := List(orbit,o->RepresentativeAction(pmcg,orbit[1][1],o[1],act)*List(o,machine->InnerAutomorphism(states,RepresentativeAction(states,o[1],machine,inneract))));
    transversal := List([1..Length(orbit)],i->List([1..Length(orbit[i])],j->reps[i][j]^-1*M));
    # now orbit[i][j] is a distilled machine;
    # orbit[i][j] and orbit[i][k] are related by inner automorphisms
    # act(M,reps[i][j]) = orbit[i][j]
    # transversal[i][j] = reps[i][j]^-1*M
    # distil(transversal[i][j])=orbit[i][j]

    epi := EpimorphismFromFreeGroup(pmcg);
    
    output := [];
    transition := [];
    
    for g in GeneratorsOfGroup(Source(epi)) do
        o := [];
        t := [];
        for a in [1..Length(orbit)] do
            newM := (g^-1)^epi*transversal[a][1];
            d := DISTILLATE@(newM)[1];
            b := [PositionProperty(orbit,o->d in o)];
            Add(b,Position(orbit[b[1]],d));
            Add(o,b[1]);
            d := transversal[b[1]][b[2]];
            d := MATCHMARKINGS@(newM,states,[d!.transitions,d!.output]);
            Add(t,FACTORIZEAUT@(epi,M,d));
        od;
        Add(output,o);
        Add(transition,t);
    od;
    a := FRMachine(Source(epi),transition,output);
    SetCorrespondence(a,pmcg);
    return a;
end);
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
    if Length(roots)>=2 and not infinity in roots and AbsoluteValue(roots[1]-roots[2])<EPS@.prec then
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

InstallGlobalFunction(Mandel, function(arg)
    local f, a, b, c, d, cmd;

    while Length(arg)>1 or not ForAll(arg,IsRationalFunction) do
        Error("Mandel: argument should be at most one rational function");
    od;
    cmd := "mandel";
    if arg<>[] then
        f := RationalP1Map(IndeterminateOfUnivariateRationalFunction(arg[1]),NORMALIZEV@(P1MapRational(arg[1]),0,false)); # (az^2+b)/(cz^2+d)
        if IsPolynomial(f) then
            f := CoefficientsOfUnivariatePolynomial(f);
            if f[1]=COMPLEX_0 then # z^2
                a := COMPLEX_0;
            else # az^2+1
                a := f[3];
            fi;
            Add(cmd,' '); Append(cmd, String(RealPart(a)));
            Add(cmd,' '); Append(cmd, String(ImaginaryPart(a)));
        else
            f := [NumeratorOfRationalFunction(f),DenominatorOfRationalFunction(f)];
            b := CoefficientsOfUnivariatePolynomial(f[1])[1];
            c := CoefficientsOfUnivariatePolynomial(f[2])[3];
            d := CoefficientsOfUnivariatePolynomial(f[2])[1];
            if DegreeOfRationalFunction(f[1])<2 then # b/(cz^2+d)
                f := [c*b^2/d^3,COMPLEX_0];
            else # (az^2+b)/(cz^2+d)
                a := CoefficientsOfUnivariatePolynomial(f[1])[3];
                f := [c^2*b/a^3,c*d/a^2];
            fi;
            Add(cmd,' '); Append(cmd, String(RealPart(f[1])));
            Add(cmd,' '); Append(cmd, String(ImaginaryPart(f[1])));
            Add(cmd,' '); Append(cmd, String(RealPart(f[2])));
            Add(cmd,' '); Append(cmd, String(ImaginaryPart(f[2])));
        fi;
    fi;
    EXECINSHELL@(InputTextNone(),cmd,ValueOption("detach"));
end);        
#############################################################################

#############################################################################
# conversions
#
BindGlobal("SEPARATION@", function(set,s)
    local a, b, c, i, j, cut;
  
    cut := function(set,s)
        local bins, i;
        bins := List([0..Length(s)],i->[]);
        for i in set do
            Add(bins[PositionSorted(s,i)],i);
        od;  
        if Length(bins[1])=1 then
            UniteSet(bins[1],Remove(bins));
        fi;
        return bins;
    end;
  
    b := [];
    c := [];
    for i in set do
        a :=[];
        for j in s do
            UniteSet(a,Difference(Set(cut(j,i)),[[]]));
        od;
        s := a;
    od;  
    
    return s;
end);

BindGlobal("EXTERNALANGLESRELATION@",[]);

InstallGlobalFunction(ExternalAnglesRelation, function(degree,n)
    local a, b, c, i, j, set;
    
    if not IsBound(EXTERNALANGLESRELATION@[degree]) then
        EXTERNALANGLESRELATION@[degree] := [];
    fi;
    
    if not IsBound(EXTERNALANGLESRELATION@[degree][n]) then
        a := [0..degree-2]/(degree-1);
        set := [ShallowCopy(a)];
        for i in [2..n] do
            b := [1..degree^i-2]/(degree^i-1);
            SubtractSet(b,a);
            UniteSet(a,b);
            c := SEPARATION@(set,[b]);
            UniteSet(set,c);
        od;
        EXTERNALANGLESRELATION@[degree][n] := EquivalenceRelationByPartition(Rationals,set);
    fi;
    return EXTERNALANGLESRELATION@[degree][n];
end);

InstallGlobalFunction(ExternalAngle, function(arg)
    # convert supporting rays to external angle
    local deg, sr, n;
    
    if Length(arg)=1 and IsFRMachine(arg[1]) then
        n := SupportingRays(arg[1]);
    elif Length(arg)>=2 and IsPosInt(arg[1]) and IsList(arg[2]) then
        n := arg;
    elif Length(arg)=1 and IsList(arg[1]) then
        n := arg[1];
    else
        Error("ExternalAngle: call with FR machine or supporting rays data, not ",arg);
    fi;
    deg := n[1];
    if Length(n[2])=1 then
        sr := n[2][1];
    elif Length(n[3])=1 then
        sr := n[3][1];
    fi;
    sr := sr[1]*deg; sr := sr - Int(sr);

    if RemInt(DenominatorRat(sr),deg)=0 then
        return sr;
    fi;
    n := 1; while not IsInt((deg^n-1)*sr) do n := n+1; od;
    return EquivalenceClassOfElement(ExternalAnglesRelation(deg,n),sr);
end);

InstallMethod(KneadingSequence, "(FR) for a rational angle",
        [IsRat],
        function(angle)
    local i, t, s, set, j, marked;
        
    s := [];
    set := [];
    t := angle;
    marked := angle>=1/7 and angle<=2/7 and ValueOption("marked")<>fail;
    
    if marked then j := "A1"; else j := 1; fi;
    while not t in s do
        Add(set,j);
        if marked then j := "C0"; else j := 0; fi;
        Add(s,t);
   
        t := 2*t - Int(2*t);
        if t>angle/2 and t<angle/2+1/2 then
            if marked then j := "C1"; else j := 1; fi;
        fi; 
        if marked and t>=1/7 and t<2/7 then j := "A1"; fi;
        if marked and t>=2/7 and t<4/7 then j := "B1"; fi;
        if marked and t>=9/14 and t<11/14 then j := "A0"; fi;
        if marked and t>=11/14 or t<1/14 then j := "B0"; fi;
    od;
    i := Position(s,t);

    if i=1 then 
        Remove(set);
    else
        s:=[[],set];
        for j in [1..i-1] do
            Add(s[1],set[1]);
            Remove(set,1);
        od; 
        set := s;
    fi;
  
    return set;
end);

InstallGlobalFunction(AllInternalAddresses, function(n)
    local a, b, c, i, j, set, s, external, isseparate;
    
    external := function(n)
        local a, b, c, i, j, set, s;
        a := [];
        set := [];
        s := [[]];
        for i in [2..n] do
            b := [];
            for j in [1..2^i-2] do
                Add(b,j/(2^i-1));
            od;
            SubtractSet(b,a);
            UniteSet(a,b);
            c := SEPARATION@(set,[b]);
            UniteSet(set,c);
            Add(s,c);
        od;
        return [a,s];
    end;

    isseparate := function(a,b)
        return not (a[1]<b[1] or a[2]>b[2]);
    end;

    a := external(n);
    s := a[2];
    a := a[1]; 
    for i in [2..n] do
        for j in [1..Length(s[i])]  do
            Add(s[i][j],i);
        od;   
    od;
    
    for i in [2..n] do
        for j in [1..Length(s[i])] do
            a:=i-1;
            while a>1 and Length(s[i][j])<4 do
                for b in s[a] do
                    if isseparate(s[i][j],b) then
                        for c in b do
                            Add(s[i][j],c);
                        od; 
                    fi;
                od; 
                a :=a-1;  
            od;
        od;   
    od;

    return s;
end);
#############################################################################

#E img.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
