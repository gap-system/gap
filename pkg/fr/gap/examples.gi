#############################################################################
##
#W examples.gi                                              Laurent Bartholdi
##
#H   @(#)$Id: examples.gi,v 1.66 2011/11/15 16:20:06 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  All interesting examples of Mealy machines and groups I came through
##
#############################################################################

BindGlobal("SETGENERATORNAMES@", function(G,n)
    local i;
    for i in [1..Length(n)] do
        if IsGroup(G) then
            SetName(GeneratorsOfGroup(G)[i],n[i]);
        elif IsMonoid(G) then
            SetName(GeneratorsOfMonoid(G)[i],n[i]);
        elif IsSemigroup(G) then
            SetName(GeneratorsOfSemigroup(G)[i],n[i]);
        fi;
    od;
end);

BindGlobal("LPGROUPIMAGE@", function(G,F,Ggens,Fgens,Sgens,Scoord)
    local knows, Gtop, Ftop, Ptop, init, recur, bootstrap;

    bootstrap := true;

    recur := function(g,seen)
        local d, w, p, x, h, todoh;

        p := LookupDictionary(knows,g);
        if p<>fail then return p; fi;
        if KnowsDictionary(seen,g) then
            if bootstrap then
                AddDictionary(knows,g,MAPPEDWORD@(ShortGroupWordInSet(Group(Ggens),g,infinity)[2],Fgens));
                Info(InfoFR,3,"Added ",g,"=",LookupDictionary(knows,g));
            fi;
            # we reached a recurring state not yet known
            return fail;
        fi;
        AddDictionary(seen,g);
        w := Position(Ptop,ActivityPerm(g));
        if w=fail then return fail; fi; # even activity is impossible
        w := Ftop[w];
        h := LeftQuotient(MAPPEDWORD@(w,Ggens),g);
        todoh := [];
        while not IsOne(h) do
            if h in todoh then return fail; fi; # stuck in a loop
            AddSet(todoh,h);
            d := DecompositionOfFRElement(h)[1];
            # start by hardest coordinate, i.e. one with largest norm
            x := List(d,x->NormOfBoundedFRElement(x));
            p := Maximum(x);
            if x[Scoord]=p then
                p := Scoord;
            else
                p := PositionProperty(x,n->n=p);
            fi;
            p := PositionProperty(Ptop,s->p^s=Scoord);
            x := recur(State(h^Gtop[p],Scoord),seen);
            if x=fail then return fail; fi;
            x := MAPPEDWORD@(x,Sgens)^(Ftop[p]^-1);
            w := w*x;
            h := LeftQuotient(MAPPEDWORD@(x,Ggens),h);
            Assert(1,MAPPEDWORD@(w,Ggens)*h=g);
        od;
        AddDictionary(knows,g,w);
        return w;
    end;

    init := function()
        local x, todo, i, y;

        knows := NewDictionary(Representative(G),true);
        AddDictionary(knows,One(G),One(F));

        Ptop := AsList(TopVertexTransformations(G));
        Ftop := [];
        for x in Ptop do
            Add(Ftop,MAPPEDWORD@(ShortGroupWordInSet(Group(Ggens),g->ActivityPerm(g)=x,infinity)[2],Fgens));
        od;
        Gtop := List(Ftop,x->MAPPEDWORD@(x,Ggens));

        todo := NewFIFO(TransposedMat([Ggens,Fgens]));
        for x in todo do
            y := false;
            while recur(x[1],NewDictionary(x[1],false))=fail do
                y := true;
                Info(InfoFR,3,"Bootstrapping recognizer with ",x[2]);
#                AddDictionary(knows,x[1],x[2]);
#                AddDictionary(knows,x[1]^-1,x[2]^-1);
            od;
            if y then
                for i in [1..Length(Ggens)] do
                    Add(todo,[x[1]*Ggens[i],x[2]*Fgens[i]]);
                od;
            fi;
        od;
        bootstrap := false;
    end;	

    return function(g)
        if bootstrap then init(); fi;
        return recur(g,NewDictionary(g,false));
    end;
end);

BindGlobal("LPGROUPPREIMAGE@", function(Fgens,Sgens,Ggens,depth,Scoord)
    local Sletter;

    Sletter := Length(Ggens)+1;
    if Sgens=fail then return fail; fi;

    if depth=infinity then
        return function(w)
            local up, down, g, i, j;
            up := 0; down := 0;
            g := One(Ggens[1]);
            for i in LetterRepAssocWord(UnderlyingElement(w)) do
                if i=Sletter then # down in tree
                    if up>0 then
                        up := up-1;
                    else
                        down := down+1;
                        g := VertexElement(Scoord,g);
                    fi;
                elif i=-Sletter then
                    if down>0 and ActivityPerm(g)=() then
                        down := down-1;
                        g := State(g,Scoord);
                    else
                        up := up+1;
                    fi;
                else
                    i := Fgens[AbsInt(i)];
                    for j in [1..up] do
                        i := MAPPEDWORD@(i,Sgens);
                    od;
                    g := g*MAPPEDWORD@(i,Ggens);
                fi;
            od;
            if up<>down then
                return fail;
                Error("Element ",w," has non-trivial translation ",down-up);
            elif up>0 then
                return fail;
                Error("Element ",w," does not fix the root vertex");
            fi;
            return g;
        end;
    else
        return w->MAPPEDWORD@(w,Ggens);
    fi;
end);

#############################################################################
##
#E AddingMachine(n)
#E AddingGroup(n)
##
InstallMethod(AddingMachine, "(FR) for a degree",
        [IsPosInt],
        function(n)
    local E;
    E := MealyMachine([List([1..n],i->1),List([1..n],i->1+QuoInt(i,n))],
                 [[1..n],List([1..n],i->1+RemInt(i,n))]);
    SetName(E,Concatenation("AddingMachine(",String(n),")"));
    return E;
end);

InstallMethod(AddingElement, "(FR) for a degree",
        [IsPosInt],
        function(n)
    local E;
    E := MealyElement([List([1..n],i->1),List([1..n],i->1+QuoInt(i,n))],
                 [[1..n],List([1..n],i->1+RemInt(i,n))],2);
    SetName(E,Concatenation("AddingElement(",String(n),")"));
    return E;
end);

InstallGlobalFunction(AddingGroup, function(n)
    local G;
    G := SCGroup(AddingMachine(n));
    SetName(G,Concatenation("AddingGroup(",String(n),")"));
    return G;
end);

InstallValue(BinaryAddingMachine,AddingMachine(2));
BinaryAddingMachine!.Name := "BinaryAddingMachine";

InstallValue(BinaryAddingElement,AddingElement(2));
BinaryAddingElement!.Name := "BinaryAddingElement";

InstallValue(BinaryAddingGroup,AddingGroup(2));
BinaryAddingGroup!.Name := "BinaryAddingGroup";
#############################################################################

#############################################################################
##
#E FiniteDepthBinaryGroup(l)
#E FinitaryBinaryGroup
#E BoundedBinaryGroup
#E PolynomialStateGrowthBinaryGroup
#E FiniteStateBinaryGroup
#E FullBinaryGroup
##
InstallGlobalFunction(FiniteDepthBinaryGroup, l->FullSCGroup([1..2],l));

InstallValue(FinitaryBinaryGroup,FullSCGroup([1..2],IsFinitaryFRSemigroup));

InstallValue(BoundedBinaryGroup,FullSCGroup([1..2],IsBoundedFRSemigroup));

InstallValue(PolynomialGrowthBinaryGroup,
        FullSCGroup([1..2],IsPolynomialGrowthFRSemigroup));

InstallValue(FiniteStateBinaryGroup,FullSCGroup([1..2],IsFiniteStateFRSemigroup));

InstallValue(FullBinaryGroup,FullSCGroup([1..2]));
#############################################################################

#############################################################################
##
#E MixerMachine
#E MixerGroup
##
InstallGlobalFunction(MixerMachine,
        function(arg)
    local A, B, f, g, a, b, d, i, out, trans, r, t, corr;
    if not (Length(arg) in [3,4] and IsGroup(arg[1]) and IsGroup(arg[2])) then
        Error("MixerMachine: requires <group> <group> <list> [<endomorphism>]");
    fi;
    A := arg[1];
    B := arg[2];
    f := arg[3];
    if not ForAll(f,r->ForAll(r,x->IsGroupHomomorphism(x) and Source(x)=B and Range(x)=A)) then
        Error("MixerMachine: third argument should be list of lists of endomorphisms B->A");
    fi;
    if Length(arg)=4 then
        g := arg[4];
        if not IsGroupHomomorphism(g) and Source(g)=B and Range(g)=B then
            Error("MixerMachine: fourth argument should be endomorphism B->B");
        fi;
    else
        g := IdentityMapping(B);
    fi;
    if not IsPeriodicList(f) then f := PeriodicList([],f); fi;
    d := Maximum(LargestMovedPoint(A),1+Maximum(List(f,Length)));
    b := ShallowCopy(GeneratorsOfGroup(B));
    for i in b do
        i := i^g;
        if not i in b then Add(b,i); fi;
    od;
    a := Unique(Concatenation([()],GeneratorsOfGroup(A)));
    for i in Unique(f) do for i in i do
        a := Unique(Concatenation(a,List(b,x->x^i)));
    od; od;
    out := [];
    trans := [];
    for i in a do
        Add(trans,List([1..d],i->1));
        Add(out,i);
    od;
    corr := [[2..Length(out)]];
    for r in [1..Length(PrePeriod(f))+Length(Period(f))] do
        for i in b do
            t := List(f[r],pi->Position(a,i^pi));
            while Length(t)<d-1 do Add(t,1); od;
            if r=Length(PrePeriod(f))+Length(Period(f)) then
                Add(t,Length(a)+Length(PrePeriod(f))*Length(b)+Position(b,i^g));
            else
                Add(t,Length(a)+r*Length(b)+Position(b,i^g));
            fi;
            Add(trans,t);
            Add(out,());
        od;
        Add(corr,[Length(out)-Length(b)+1..Length(out)]);
    od;
    i := MealyMachine(trans,out);
    SetCorrespondence(i,corr);
    return i;
end);

InstallGlobalFunction(MixerGroup,
        function(arg)
    return SCGroup(CallFuncList(MixerMachine,arg));
end);
#############################################################################

#############################################################################
##
#E GrigorchukGroup
#E GrigorchukGroups
##
InstallGlobalFunction(GrigorchukMachines,
        function(f)
    local a, b, pi;
    a := Group((1,2));
    b := Group((1,2),(3,4),(1,2)(3,4));
    pi := [GroupHomomorphismByImagesNC(b,a,[(1,2),(3,4)],[(1,2),()]),
           GroupHomomorphismByImagesNC(b,a,[(1,2),(3,4)],[(),(1,2)]),
           GroupHomomorphismByImagesNC(b,a,[(1,2),(3,4)],[(1,2),(1,2)])];
    if IsPeriodicList(f) then
        return MixerMachine(a,b,PeriodicList(f,x->[pi[x]]));
    else
        return MixerMachine(a,b,List(f,x->[pi[x]]));
    fi;
end);
InstallGlobalFunction(GrigorchukGroups,
        function(f)
    local a, m;
    m := GrigorchukMachines(f);
    a := Group(Concatenation(
                 List(Correspondence(m)[1],i->FRElement(m,i)),
                 List(Correspondence(m)[2],i->FRElement(m,i))));
    SetName(a,Concatenation("GrigorchukGroups(",String(f),")"));
    SetUnderlyingFRMachine(a,m);
    return a;
end);

InstallValue(GrigorchukMachine,
        MealyMachine([[5,5],[1,3],[1,4],[5,2],[5,5]],[[2,1],[1,2],[1,2],[1,2],[1,2]]));
InstallValue(GrigorchukGroup,SCGroup(GrigorchukMachine));
GrigorchukGroup!.Name := "GrigorchukGroup";
SETGENERATORNAMES@(GrigorchukGroup,["a","b","c","d"]);
CallFuncList(function(a,b,c,d)
    local x;
    x := Comm(a,b);
    SetBranchingSubgroup(GrigorchukGroup,Group(x,x^c,x^(c*a)));
end, GeneratorsOfGroup(GrigorchukGroup));
        
BindGlobal("ITERATEMAP@", function(s,n,w)
    local r, i;
    r := [w];
    for i in [1..n] do
        w := w^s;
        Add(r,w);
    od;
    return r;
end);

BindGlobal("GRIGP_IMAGE@", function(nuke,nukeimg,Fgens,Sgens,tau,reduce)
    local image, knows, i;
    knows := NewDictionary(nuke[1],true);
    for i in [1..Length(nuke)] do
        AddDictionary(knows,nuke[i],nukeimg[i]);
    od;
    return function(g)
        local todo, recur;
        todo := NewDictionary(g,false);
        recur := function(g)
            local i, x, y;
            i := LookupDictionary(knows,g);
            if i<>fail then return i; fi;
            i := DecompositionOfFRElement(g);
            if not i[2] in [[1,2],[2,1]] then return fail; fi;
            if KnowsDictionary(todo,g) then
                return fail; # we reached a recurring state not in the nucleus
            fi;
            AddDictionary(todo,g);
            x := recur(i[1][2]);
            if x=fail then return fail; fi;
            y := LeftQuotient(tau(i[1][2]),i[1][1]);
            if not IsOne(tau(y)) then return fail; fi;
            y := recur(y);
            if y=fail then return fail; fi;
            x := MAPPEDWORD@(x,Sgens)*Fgens[1]*MAPPEDWORD@(y,Sgens);
            if ISONE@(i[2]) then x:=x*Fgens[1]; fi;
            x := reduce(x);
            AddDictionary(knows,g,x);
            return x;
        end;
        return recur(g);
    end;
end);

SetFRGroupPreImageData(GrigorchukGroup, function(depth)
    local tau, reduce, creator, nuke, nukeimg, Fgens, Sgens, Ggens,
          F, a, b, c, d, s, rels;
    if depth=infinity then
        F := FreeGroup("a","b","c","d","s");
        a := F.1; b := F.2; c := F.3; d := F.4; s := F.5;
        F := F / [a^2,b^2,c^2,d^2,b*c*d,(a*d)^4,(a*d*a*c*a*c)^4,
                  a^s/c^a,b^s/d,c^s/b,d^s/c];
        F := Subgroup(F,GeneratorsOfGroup(F){[1..4]});
        creator := ElementOfFpGroup;
    else
        F := FreeGroup("a","b","c","d");
        a := F.1; b := F.2; c := F.3; d := F.4;
        s := GroupHomomorphismByImagesNC(F,F,[a,b,c,d],[c^a,d,b,c]);
        rels := [a^2,b^2,c^2,d^2,b*c*d,(a*d)^4,(a*d*a*c*a*c)^4];
        if depth>=0 then
            F := F / Concatenation(rels{[1..5]},
                         ITERATEMAP@(s,depth+1,rels[6]),
                         ITERATEMAP@(s,depth,rels[7]));
            creator := ElementOfFpGroup;
        else
            F := LPresentedGroup(F,[],[s],rels);
            creator := ElementOfLpGroup;
        fi;
    fi;
    tau := function(g)
        local p, x;
        p := Portrait(g,2);
        x := One(GrigorchukGroup);
        if p[2][1]*p[3][2][1]*p[3][2][2]=(1,2) then x := x*GrigorchukGroup.1; fi;
        if p[2][2]*p[3][1][1]*p[3][1][2]=(1,2) then x := x*GrigorchukGroup.1^GrigorchukGroup.4; fi;
        if p[1]=(1,2) then x := x*GrigorchukGroup.4; fi;
        return x;
    end;
    reduce := function(g)
        local i, w, x, changed;
        w := UnderlyingElement(g);
        x := LetterRepAssocWord(w);
        changed := false;
        for i in [1..Length(x)] do
            if x[i]<0 then x[i] := -x[i]; changed := true; fi;
        od;
        i := 1;
        while i<Length(x) do
            if x[i]=x[i+1] then
                changed := true;
                Remove(x,i); Remove(x,i);
                if i>1 then i := i-1; fi;
            elif x[i]<>1 and x[i+1]<>1 then
                changed := true;
                x[i] := 9-x[i]-x[i+1];
                Remove(x,i+1);
            else
                i := i+1;
            fi;
        od;
        if changed then
            return creator(FamilyObj(g),AssocWordByLetterRep(FamilyObj(w),x));
        else
            return g;
        fi;
    end;
    Fgens := [F.1,        F.2,F.3,F.4];
    Sgens := [F.1*F.3*F.1,F.4,F.2,F.3];
    Ggens := [GrigorchukGroup.1,GrigorchukGroup.2,
              GrigorchukGroup.3,GrigorchukGroup.4];
    nuke := [One(GrigorchukGroup),Ggens[1],Ggens[2],Ggens[3],Ggens[4]];
    nukeimg := [One(F),F.1,F.2,F.3,F.4];
    SortParallel(nuke,nukeimg);
    return rec(F:=F,
               image:=GRIGP_IMAGE@(nuke,nukeimg,Fgens,Sgens,tau,reduce),
               preimage:=LPGROUPPREIMAGE@(Fgens,Sgens,Ggens,depth,2),
               reduce:=reduce);
end);

InstallValue(GrigorchukOverGroup, MixerGroup(Group((1,2)),Group((1,2)),
        [[IdentityMapping(Group((1,2)))],[],[]]));
SetName(GrigorchukOverGroup,"GrigorchukOverGroup");
SETGENERATORNAMES@(GrigorchukOverGroup,["a","bb","cc","dd"]);

# growth of PermGroup(GrigorchukOverGroup,5), generated by nucleus, is
# [1, 8, 14, 56, 89, 248, 416, 1160, 1804, 3816, 5871, 13400, 20344, 42248, 64020, 134072, 189600, 317984, 445352, 786144, 1066211, 1700736, 2340722, 3767744, 4833667, 6942160, 9039846, 13509040, 17041513, 24065960, 31045388, 43791128, 39928094, 23152344, 19514220, 13313384, 7589784, 2289688, 1030745, 386408, 60027]

SetFRGroupPreImageData(GrigorchukOverGroup, function(depth)
    local tau, reduce, nuke, nukeimg, Fgens, Sgens, Ggens,
          F, a, b, c, d, s, rels, creator;
    if depth=infinity then
        F := FreeGroup("a","bb","cc","dd","s");
        a := F.1; b := F.2; c := F.3; d := F.4; s := F.5;
    else
        F := FreeGroup("a","bb","cc","dd");
        a := F.1; b := F.2; c := F.3; d := F.4;
        s := GroupHomomorphismByImagesNC(F,F,[a,b,c,d],[b^a,d,b,c]);
    fi;
    rels := [a^2,b^2,c^2,d^2,Comm(b,c),Comm(b,d),Comm(c,d),
             (a*c)^4,(a*d)^4,(a*c*a*d)^2,(a*b)^8,
             (a*b*a*b*a*c)^4,(a*b*a*b*a*d)^4,(a*b*a*b*a*c*a*b*a*b*a*d)^2];
    if depth=infinity then
        F := F / Concatenation(rels,[a^s/b^a,b^s/d,c^s/b,d^s/c]);
        F := Subgroup(F,GeneratorsOfGroup(F){[1..4]});
        creator := ElementOfFpGroup;
    elif depth=-1 then
        F := LPresentedGroup(F,[],[s],rels);
        creator := ElementOfLpGroup;
    else
        F := F / Concatenation(rels{[1..7]},
                     Concatenation(List(rels{[8..11]},x->ITERATEMAP@(s,depth+1,x))),
                     Concatenation(List(rels{[12..14]},x->ITERATEMAP@(s,depth,x))));
        creator := ElementOfFpGroup;
    fi;
    tau := function(g)
        local p, x;
        p := Portrait(g,3);
        x := One(GrigorchukOverGroup);
        if Product(Flat(p[4][2]))=(1,2) then x := x*GrigorchukOverGroup.1; fi;
        if Product(Flat(p[4][1]))=(1,2) then x := x*GrigorchukOverGroup.1^GrigorchukOverGroup.3; fi;
        if p[1]=(1,2) then x := x*GrigorchukOverGroup.3; fi;
        return x;
    end;
    reduce := function(g)
        local i, w, x, changed;
        w := UnderlyingElement(g);
        x := LetterRepAssocWord(w);
        changed := false;
        for i in [1..Length(x)] do
            if x[i]<0 then x[i] := -x[i]; changed := true; fi;
        od;
        i := 1;
        while i<Length(x) do
            if x[i]=x[i+1] then
                changed := true;
                Remove(x,i); Remove(x,i);
                if i>1 then i := i-1; fi;
            elif x[i]>x[i+1] and x[i+1]<>1 then
                changed := x[i]; x[i] := x[i+1]; x[i+1] := changed;
                changed := true;
                if i>1 then i := i-1; fi;
            else
                i := i+1;
            fi;
        od;
        if changed then
            return creator(FamilyObj(g),AssocWordByLetterRep(FamilyObj(w),x));
        else
            return g;
        fi;
    end;
    Fgens := [F.1,        F.2,F.3,F.4];
    Sgens := [F.1*F.2*F.1,F.4,F.2,F.3];
    Ggens := [GrigorchukOverGroup.1,GrigorchukOverGroup.2,
              GrigorchukOverGroup.3,GrigorchukOverGroup.4];
    nuke := [One(GrigorchukOverGroup),Ggens[1],Ggens[2],Ggens[3],
             Ggens[4],Ggens[2]*Ggens[3],Ggens[2]*Ggens[4],
             Ggens[3]*Ggens[4],Ggens[2]*Ggens[3]*Ggens[4]];
    nukeimg := [One(F),F.1,F.2,F.3,F.4,F.2*F.3,F.2*F.4,F.3*F.4,F.2*F.3*F.4];
    SortParallel(nuke,nukeimg);
    return rec(F:=F,
               image:=GRIGP_IMAGE@(nuke,nukeimg,Fgens,Sgens,tau,reduce),
               preimage:=LPGROUPPREIMAGE@(Fgens,Sgens,Ggens,depth,2),
               reduce:=reduce);
end);

InstallValue(GrigorchukTwistedTwin, SCGroup(MealyMachine(
        [[5,5],[3,1],[1,4],[5,2],[5,5]],
        [(1,2),(),(),(),()])));
SETGENERATORNAMES@(GrigorchukTwistedTwin,["a","x","y","z"]);
SetFRGroupPreImageData(GrigorchukTwistedTwin, function(depth)
    local F, a, x, y, z, s, rels, Fgens, Ggens, Sgens;

    Ggens := GeneratorsOfGroup(GrigorchukTwistedTwin);
    if depth=infinity then
        F := FreeGroup("a","x","y","z","s");
        a := F.1; x := F.2; y := F.3; z := F.4; s := F.5;
        Fgens := [a,x,y,z];
        Sgens := [y^a,z,x^a,y];
    else
        F := FreeGroup("a","x","y","z");
        a := F.1; x := F.2; y := F.3; z := F.4;
        Fgens := [a,x,y,z];
        Sgens := [y^a,z,x^a,y];
        s := GroupHomomorphismByImagesNC(F,F,Fgens,Sgens);
    fi;
    rels := [a^2, x^2, y^2, z^2,
             Comm(z,y^a*x),
             Comm(z,Comm(z,a)),
             Comm(Comm(z,y),y^a*x),
             Comm(y^a*x,Comm(y^a*x,a))];
    if depth=infinity then
        F := F / Concatenation(rels,List([1..4],i->Fgens[i]^s/Sgens[i]));
        F := Subgroup(F,Fgens);
    elif depth=-1 then
        F := LPresentedGroup(F,[],[s],rels);
    else
        F := F / Concatenation(List(rels,x->ITERATEMAP@(s,depth,x)));
    fi;
    Fgens := GeneratorsOfGroup(F){[1..4]};
    if IsLpGroup(F) then
        Sgens := List(Sgens,x->ElementOfLpGroup(FamilyObj(F.1),x));
    else
        Sgens := List(Sgens,x->ElementOfFpGroup(FamilyObj(F.1),x));
    fi;
    return rec(F:=F,
               image:=LPGROUPIMAGE@(GrigorchukTwistedTwin,F,Ggens,GeneratorsOfGroup(F){[1..4]},Sgens,2),
               preimage:=LPGROUPPREIMAGE@(Fgens,Sgens,Ggens,depth,2),
               reduce:=w->w);
end);
GermData(GrigorchukTwistedTwin).init := function(data)
    local F;
    F := FreeGroup("x","y","z","c");
    F := PcGroupFpGroup(F/[F.1^2,F.2^2,F.3^2,F.4^2,
                 Comm(F.2,F.1)/F.4, Comm(F.3,F.1)/F.4, Comm(F.3,F.2)/F.4,
                 Comm(F.4,F.1), Comm(F.4,F.2), Comm(F.4,F.3)]);
    data.group := F;
    data.endo := GroupHomomorphismByImages(F,F,[F.1,F.2,F.3],[F.3,F.1,F.2]);
    data.map := [One(F),F.3,F.1,F.2,One(F)];
    data.eval := function(elm,data,h)
        local x, y, z, f1, f2, f3, i, recur;

        x := List(h,g->ExponentOfPcElement(Pcgs(data.group),g,1));
        y := List(h,g->ExponentOfPcElement(Pcgs(data.group),g,2));
        z := List(h,g->ExponentOfPcElement(Pcgs(data.group),g,3));
        f1 := []; f2 := []; f3 := [];

        recur := function(s)
            local i, t;
            if not IsBound(f1[s]) then
                f1[s] := 0;
                f2[s] := 0;
                f3[s] := 0;
                t := elm!.transitions[s];
                for i in t do recur(i); od;
                f1[s] := x[t[1]] + y[t[2]] + y[t[1]]*y[t[2]] + Sum([1..2],i->f2[t[i]]+x[t[i]]*z[t[3-i]]+y[t[i]]*z[t[3-i]]);
                f2[s] := z[t[1]] + y[t[2]] + y[t[1]]*y[t[2]] + Sum([1..2],i->f3[t[i]]);
                f3[s] := z[t[1]] + y[t[2]] + z[t[1]]*z[t[2]] + Sum([1..2],i->f1[t[i]]+y[t[i]]*x[t[3-i]]+z[t[i]]*x[t[3-i]]+y[t[i]]*z[t[3-i]]);
            fi;
        end;

        i := InitialState(elm);

        recur(i);

        return F.1^x[i]*F.2^y[i]*F.3^z[i]*F.4^(f3[i]+z[Transition(elm,i,1)]+y[Transition(elm,i,2)]);
    end;
    Unbind(data.init);
end;
GermData(GrigorchukTwistedTwin).init(GermData(GrigorchukTwistedTwin));
#############################################################################

#############################################################################
##
#E SunicMachine
#E SunicGroup
##
InstallGlobalFunction(SunicMachine,
        function(phi)
    local k, p, A, B, d, f, g, gB, i, j;

    k := Field(CoefficientsOfUnivariatePolynomial(phi));
    p := Size(k);
    A := ElementaryAbelianGroup(IsPermGroup,p);
    d := DegreeOfUnivariateLaurentPolynomial(phi);
    B := ElementaryAbelianGroup(p^d);
    gB := GeneratorsOfGroup(B);
    f := GroupHomomorphismByImages(B,A,gB,Concatenation(ListWithIdenticalEntries((d-1)*Dimension(k),One(A)),GeneratorsOfGroup(A)));
    i := gB{[Dimension(k)+1..d*Dimension(k)]};
    for j in Basis(k) do
        j := Concatenation(List(CoefficientsOfUnivariatePolynomial(phi){[1..d]},x->Coefficients(Basis(k),-j*x)));
        Add(i,Product([1..Length(j)],i->gB[i]^IntFFE(j[i]),One(B)));
    od;
    g := GroupHomomorphismByImages(B,B,GeneratorsOfGroup(B),i);
    i := MixerMachine(A,B,[[f]],g);
    SetName(i,Concatenation("SunicMachine(",String(phi),")"));
    return i;
end);

InstallGlobalFunction(SunicGroup,
        function(phi)
    local g;
    g := SCGroup(SunicMachine(phi));
    SetName(g,Concatenation("SunicGroup(",String(phi),")"));
    return g;
end);
#############################################################################

#############################################################################
##
#E AleshinMachine
#E AleshinGroup
#E BabyAleshinMachine
#E BabyAleshinGroup
##
InstallGlobalFunction(AleshinMachines,
        function(n)
    local trans, out;
    trans := Concatenation([[3,2],[2,3]],List([3..n-1],s->[s+1,s+1]),[[1,1]]);
    out := Concatenation([(1,2),(1,2)],List([3..n],s->()));
    return MealyMachine(trans,out);
end);

InstallGlobalFunction(AleshinGroups,
        function(n)
    local g;
    g := SCGroup(AleshinMachines(n));
    SetName(g,Concatenation("AleshinGroups(",String(n),")"));
    return g;
end);

InstallValue(AleshinMachine, AleshinMachines(3));
InstallValue(AleshinGroup, SCGroup(AleshinMachine)); # the main example
AleshinGroup!.Name := "AleshinGroup";
SETGENERATORNAMES@(AleshinGroup,["a","b","c"]);

InstallValue(BabyAleshinMachine,
        MealyMachine([[2,3],[3,2],[1,1]],[(),(),(1,2)]));

InstallValue(BabyAleshinGroup, SCGroup(BabyAleshinMachine));
SetName(BabyAleshinGroup,"BabyAleshinGroup");
SETGENERATORNAMES@(BabyAleshinGroup,["a","b","c"]);

InstallValue(SidkiFreeGroup, FRGroup("a=<a^2,a^t>","t=<,t>(1,2)"));
SetName(SidkiFreeGroup,"SidkiFreeGroup");
# F := FreeGroup("a","t");
# a := F.1; t := F.2;
# H := Subgroup(F,[a,a^t,t^2]);
# K := Subgroup(F,[a^2,t^a,t]);
# phi := GroupHomomorphismByImages(H,K,[a,a^t,t^2],[a^2,t^a,t]);
# psi := GroupHomomorphismByImages(K,H,[a^2,t^a,t],[a,a^t,t^2]);
#
# # Group([ a^-4, t^-1, a^2*t^-1*a^-2, t*a^-1*t*a*t^-1*a^-2,
# #   t*a^-1*t^-1*a*t^-1*a^-2 ])
#
# F := FreeGroup("a","b","c");
# a := F.1; b := F.2; c := F.3;
# H := Subgroup(F,[a^2,b^2,a*b,c,c^a]);
# K0 := Subgroup(F,[b*c,c*b,b^2,a,a^c]);
# K1 := Subgroup(F,[c*b,b*c,c^2,a,a^b]);
# phi := GroupHomomorphismByImages(H,K0,GeneratorsOfGroup(H),GeneratorsOfGroup(K0));
# psi := GroupHomomorphismByImages(K0,H,GeneratorsOfGroup(K0),GeneratorsOfGroup(H));
#
# S := [H];
# Append(S,[Image(psi,Intersection(K0,S[Size(S)]))]);
# Append(S,[Image(psi,Intersection(K0,S[Size(S)]))]);
# Append(S,[Image(psi,Intersection(K0,S[Size(S)]))]);
# Append(S,[Image(psi,Intersection(K0,S[Size(S)]))]);
# W := Subgroup(F,[b^-1*a*c,b^-1*c*a]);
#############################################################################

#############################################################################
##
#E BrunnerSidkiVieiraMachine
#E BrunnerSidkiVieiraGroup
##
InstallValue(BrunnerSidkiVieiraMachine,
            MealyMachine([[5,1],[5,3],[2,5],[4,5],[5,5]],[(1,2),(1,2),(1,2),(1,2),()]));

InstallValue(BrunnerSidkiVieiraGroup, SCGroup(BrunnerSidkiVieiraMachine));
SetName(BrunnerSidkiVieiraGroup,"BrunnerSidkiVieiraGroup");
SETGENERATORNAMES@(BrunnerSidkiVieiraGroup,["tau","mu"]);
SetFRGroupPreImageData(BrunnerSidkiVieiraGroup, function(depth)
    local F, rels, sigma, tau, lambda, mu, Fgens, Ggens, Sgens;

    if depth=infinity then
        F := FreeGroup("tau","mu","s");
        sigma := F.3;
    else
        F := FreeGroup("tau","mu");
    fi;
    tau := F.1; mu := F.2; lambda := tau/mu;
    rels := [Comm(lambda,lambda^tau),Comm(lambda,lambda^(tau^3))];
    Sgens := [tau^2,tau^-1*mu^-1];
    if depth=infinity then
        F := F / Concatenation(rels,[tau^sigma/Sgens[1],mu^sigma/Sgens[2]]);
        Fgens := GeneratorsOfGroup(F){[1..2]};
        F := Subgroup(F,Fgens);
    else
        sigma := GroupHomomorphismByImagesNC(F,F,[tau,mu],Sgens);
        if depth>=0 then
            F := F / Concatenation(List(rels,r->ITERATEMAP@(sigma,depth,r)));
        else
            F := LPresentedGroup(F,[],[sigma],rels);
        fi;
        Fgens := GeneratorsOfGroup(F);
    fi;
    Ggens := GeneratorsOfGroup(BrunnerSidkiVieiraGroup);
    if IsLpGroup(F) then
        Sgens := List(Sgens,x->ElementOfLpGroup(FamilyObj(Representative(F)),x));
    else
        Sgens := List(Sgens,x->ElementOfFpGroup(FamilyObj(Representative(F)),x));
    fi;
    return rec(F:=F,
               image:=LPGROUPIMAGE@(BrunnerSidkiVieiraGroup,F,Ggens,Fgens,Sgens,2),
               preimage:=LPGROUPPREIMAGE@(Fgens,Sgens,Ggens,depth,2),
               reduce:=w->w);
end);

#growth of H:
#[ 1, 4, 12, 36, 100, 276, 760, 2020, 5306, 13828, 35832 ]
#SEEMS TO BE EXPONENTIAL!
#
#growth of semigroup generated by {t,m}:
#[2, 4, 8, 16, 32, 64, 120, 225, 420, 784, 1456, 2704, 4992, 9216, 16992, 31329, 57702, 106276]
#
#H / H' = Z^2 = <t,l>
#H' / H" = Z^5 = <[l,t^i]: i=1..5>
#H / <<l>> = Z = <t>
#action of l on H'/H" is trivial
#action of t on H'/H" has eigenvals 1,-1,I,-I:
#[-1 -1 -1 -1 -1]
#[ 1           1]
#[    1         ]
#[       1     1]
#[          1   ]

#log_2 of size of H_n:
#[1 2 4 7 13 24 46 89] = (2^(n+1) + 3n - 2 + (1-(-1)^n)/2) / 6
#weakly branched on H', w/ branch structure
#1 --> IxI --> H --> <t> --> 1 with H = <<lt^-2>>
#1 --> H'xH' --> I --> <[l,t],lt^-2|abelian> --> 1
#1 --> H'xH' --> H' --> <[l,t]> --> 1

#lower central series:
#[ 32*64, ]
#[ 16*64, 16, 8, 8, 2*8, 2*4 (6x), 4, 2*4 (6x), 4 (46x), 2 (192x) ]@10
#[ 16*32, 16, 8, 8,   8,   4, 2*4, 2*4, 2*4,    4 (23x), 2 (96x) ]@9
#[ 8*32,  8,  8, 8,                             4 (12x), 2 (48x) ]@8

#OUT(H)=V_4?
#############################################################################

#############################################################################
##
#E GuptaSidkiMachines
#E GuptaSidkiGroups
#E GuptaSidkiGroup
#E FabrykowskiGuptaGroup
#E ZugadiSpinalGroup
##
InstallGlobalFunction(GuptaSidkiMachines, function(n)
    local P;
    P := CyclicGroup(IsPermGroup,n);
    return MixerMachine(P,P,[[IdentityMapping(P),GroupHomomorphismByImages(P,P,[P.1],[P.1^-1])]]);
end);

InstallGlobalFunction(GuptaSidkiGroups, function(n)
    local G, a, t;
    G := SCGroup(GuptaSidkiMachines(n));
    SETGENERATORNAMES@(G,["a","t"]);
    a := G.1; t := G.2;
    SetBranchingSubgroup(G,GroupByGenerators(ListX([0..n-1],[0..n-1],function(x,y) return Comm(a,t)^(a^x*t^y); end)));
    SetName(G,Concatenation("GuptaSidkiGroups(",String(n),")"));
    return G;
end);

BindGlobal("GUPTASIDKIGROUPIMAGE@", function(g,f,Ggens,Fgens,Sgens,Scoord)
    local nuke, knows, x, y, Gtop, Ftop, Ptop, GENREDUCE;

    nuke := NucleusOfFRSemigroup(g);
    knows := NewDictionary(nuke[1],true);
    for x in nuke do
        AddDictionary(knows,x,MAPPEDWORD@(ShortGroupWordInSet(Group(Ggens),x,infinity)[2],Fgens));
    od;
    Ptop := AsList(TopVertexTransformations(g));
    Ftop := [];
    for x in Ptop do
        Add(Ftop,MAPPEDWORD@(ShortGroupWordInSet(Group(Ggens),g->ActivityPerm(g)=x,infinity)[2],Fgens));
    od;
    Gtop := List(Ftop,x->MAPPEDWORD@(x,Ggens));
    GENREDUCE := function(h,w)
        local n, i, j, x;
        n := NormOfBoundedFRElement(h);
        for i in [1..Length(Ggens)] do
            for j in [1..Length(Ftop)-1] do
                x := LeftQuotient(Ggens[i]^j,h);
                if NormOfBoundedFRElement(x)<n then
                    return [x,w*Fgens[i]^j];
                fi;
            od;
        od;
        return fail;
    end;
    return function(g)
        local todo, recur;
        todo := NewDictionary(g,false);
        recur := function(g)
            local d, w, p, x, h;
            p := LookupDictionary(knows,g);
            if p<>fail then return p; fi;
            if KnowsDictionary(todo,g) then
                return fail;    # we reached a recurring state not in the nucleus
            fi;
            AddDictionary(todo,g);
            w := Position(Ptop,ActivityPerm(g));
            if w=fail then return fail; fi;
            w := Ftop[w];
            h := LeftQuotient(MAPPEDWORD@(w,Ggens),g);
            while not IsOne(h) do
                x := GENREDUCE(h,w);
                if x<>fail then
                    h := x[1];
                    w := x[2];
                    continue;
                fi;
                d := DecompositionOfFRElement(h)[1];
                # start by hardest coordinate, i.e. one with largest norm
                x := List(d,x->NormOfBoundedFRElement(x));
                p := Maximum(x);
                p := PositionProperty(x,n->n=p);
                p := PositionProperty(Ptop,s->p^s=Scoord);
                x := recur(State(h^Gtop[p],Scoord));
                if x=fail then return fail; fi;
                x := MAPPEDWORD@(x,Sgens)^(Ftop[p]^-1);
                w := w*x;
                h := LeftQuotient(MAPPEDWORD@(x,Ggens),h);
                Assert(1,MAPPEDWORD@(w,Ggens)*h=g);
            od;
            AddDictionary(knows,g,w);
            return w;
        end;
        return recur(g);
    end;
end);

BindGlobal("GUPTASIDKIFRDATA@", function(G,p,depth,fullgroup)
    local F, rels, rels0, sigma, a, t, tt, Fgens, Ggens, Sgens, creator,
          i, j, k, l, e, image;

    if depth=infinity then
        Error("Do not know yet any 'subgroup of FP group' for GeneralizedGuptaSidkiGroups()");
    else
        if fullgroup then a := ["a"]; else a := []; fi;
        F := FreeGroup(Concatenation(a,List([1..p],i->Concatenation("t",String(i)))));
        if fullgroup then
            a := F.1;
            t := GeneratorsOfGroup(F){[2..p+1]};
            rels0 := List([1..p],i->t[1]^(a^(i-1))/t[i]);
            rels0[1] := a^p;
        else
            t := GeneratorsOfGroup(F);
            rels0 := [];
        fi;
        rels := List(t,x->x^p);

        tt := List(t,x->[x]);
        for i in GF(p) do
            for l in [1..p-1] do
                j := First(Cartesian(GF(p),GF(p)),p->p[1]<>p[2] and p[1]<>i and p[2]<>i and IntFFE((p[1]-i)*(i-p[2])/(p[1]-p[2])/2)=l);
                k := j[2]; j := j[1];
                e := (2*(j-k))^-1;
                tt[1+IntFFE(i)][1+l] := t[1+IntFFE(i)] / Comm(t[1+IntFFE(i)]^IntFFESymm(e*(j-k))*t[1+IntFFE(j)]^IntFFESymm(e*(k-i)),t[1+IntFFE(k)]^IntFFESymm(e*(i-j))*t[1+IntFFE(i)]^IntFFESymm(e*(j-k)));
            od;
        od;
        # tt[i][n] is a word in the t[*], equal to t[i]^(a[i]^n)
        for i in [1..p] do
            for j in Difference([1..p],[i]) do
                for k in [0..p-1] do
                    for l in [0..p-1] do
                        Add(rels,tt[i][1+RemInt(k+i,p)]^-1*tt[j][1+RemInt(l+i,p)]^-1*tt[i][1+RemInt(k+j,p)]*tt[j][1+RemInt(l+j,p)]);
                    od;
                od;
            od;
        od;
        if fullgroup then
            sigma := GroupHomomorphismByImagesNC(F,F,Concatenation([a],t),Concatenation([t[p]],tt[1]));
        else
            sigma := GroupHomomorphismByImagesNC(F,F,t,tt[1]);
        fi;

        if depth>=0 then
            F := F / Flat([rels0,List(rels,r->ITERATEMAP@(sigma,depth,r))]);
            creator := x->ElementOfFpGroup(FamilyObj(Representative(F)),x);
        elif fullgroup then
            F := LPresentedGroup(F,rels0,[sigma],rels);
            creator := x->ElementOfLpGroup(FamilyObj(Representative(F)),x);
        else
            F := LPresentedGroup(F,rels0,[sigma,GroupHomomorphismByImagesNC(F,F,t,t{Concatenation([2..p],[1])})],rels);
            creator := x->ElementOfLpGroup(FamilyObj(Representative(F)),x);
        fi;
        Fgens := GeneratorsOfGroup(F);
    fi;
    Ggens := List([0..p-1],i->G.2^(G.1^i));
    if fullgroup then
        Ggens := Concatenation([G.1],Ggens);
    fi;
    Sgens := List(MappingGeneratorsImages(sigma)[2],creator);
    if fullgroup then
        return rec(F:=F,
                   image:=GUPTASIDKIGROUPIMAGE@(G,F,Ggens,Fgens,Sgens,p),
                   preimage:=LPGROUPPREIMAGE@(Ggens,Fgens,Sgens,depth,p),
                   reduce:=w->w);
    else
        return rec(F:=F);
    fi;
end);

InstallGlobalFunction(GeneralizedGuptaSidkiGroups, function(p)
    local P, G, a, t;
    P := CyclicGroup(IsPermGroup,p);
    P := MixerMachine(P,P,[List([1..p-1],i->GroupHomomorphismByImages(P,P,[P.1],[P.1^i]))]);
    G := Group(FRElement(P,2),FRElement(P,p+1));
    SETGENERATORNAMES@(G,["a","t"]);
    SetName(G,Concatenation("GeneralizedGuptaSidkiGroups(",String(p),")"));
    SetUnderlyingFRMachine(G,P);
    SetIsStateClosed(G,true);
    a := G.1; t := G.2;
    SetBranchingSubgroup(G,GroupByGenerators(ListX([0..p-1],[0..p-1],function(x,y) return Comm(a,t)^(a^x*t^y); end)));

    SetFRGroupPreImageData(G,function(depth)
        local r, s;
        r := GUPTASIDKIFRDATA@(G,p,depth,true);
        if depth=-1 then
            s := GUPTASIDKIFRDATA@(G,p,depth,false);
            SetEmbeddingOfAscendingSubgroup(r.F,GroupHomomorphismByImagesNC(
                    s.F,r.F,GeneratorsOfGroup(s.F),List([1..p],i->r.F.2^(r.F.1^(i-1)))));
        fi;
        return r;
    end);
    return G;
end);

InstallValue(GuptaSidkiMachine, GuptaSidkiMachines(3));

InstallValue(GuptaSidkiGroup, GeneralizedGuptaSidkiGroups(3));
GuptaSidkiGroup!.Name := "GuptaSidkiGroup";

# automorphisms:
# u := MealyElement([[1,1,1]],[(1,2)],1);
# v := MealyElement([[2,2,2],[1,1,1]],[(),(1,2)],1);
# x := GuptaSidkiGroup.1;
# N3 := ClosureGroup(GuptaSidkiGroup,[DiagonalElement(0,x),
#               DiagonalElement([0,0],x),DiagonalElement([0,0,0],x)]);
# N := ClosureGroup(GuptaSidkiGroup,[DiagonalElement(0,x),
#              DiagonalElement([0,0],x),DiagonalElement([0,0,0],x)],u,v]);
# NN := ClosureGroup(N,[DiagonalElement([1,0],x)]);
# NNN := ClosureGroup(NN,[A(C(a))]);
#
# N := ClosureGroup(GuptaSidkiGroup,[DiagonalElement([0],x),
#              DiagonalElement([0,0],x),DiagonalElement([0,0,0],x),
#              DiagonalElement([0,0,0,0],x)]);
# M := ClosureGroup(N,[DiagonalElement([1],x),DiagonalElement([1,0],x),
#              DiagonalElement([1,0,0],x),DiagonalElement([1,0,0,0],x)]);
# L := ClosureGroup(M,[DiagonalElement([2],x),DiagonalElement([2,0],x),
#              DiagonalElement([2,0,0],x),DiagonalElement([2,0,0,0],x),
#              DiagonalElement([0,1],x),DiagonalElement([0,1,0],x),
#              DiagonalElement([0,1,0,0],x)]);
# K := ClosureGroup(L,[DiagonalElement([1,1],x),DiagonalElement([1,1,0],x),
#              DiagonalElement([1,1,0,0],x)]);
# J := ClosureGroup(K,[DiagonalElement([2,1],x),DiagonalElement([2,1,0],x),
#              DiagonalElement([2,1,0,0],x)]);
# I := ClosureGroup(J,[DiagonalElement([0,2],x),DiagonalElement([0,2,0],x),
#              DiagonalElement([0,2,0,0],x),DiagonalElement([0,0,1],x),
#              DiagonalElement([0,0,1,0],x)]);
# H := ClosureGroup(I,[DiagonalElement([1,2],x),DiagonalElement([1,2,0],x),
#              DiagonalElement([1,2,0,0],x)]);
# Y := ClosureGroup(H,[DiagonalElement([2,2],x),DiagonalElement([2,2,0],x),
#              DiagonalElement([2,2,0,0],x)]);
# W := ClosureGroup(Y,[DiagonalElement([1,0,1],x),DiagonalElement([1,0,1,0],x)]);
#
# T := [W,Y,H,I,J,K,L,M,N,G];
# TST := g->1+Size(T)-First([Size(T),Size(T)-1..1],n->T[n]^g=T[n]);
#
#-------------------
# lower central series growth: can be computed by
#
#alpha := [1,2];
#for i in [3..10] do alpha[i] := 2*alpha[i-1]+alpha[i-2]; od;
#h := Indeterminate(Rationals);
#P := [h];
#for i in [1..9] do P[i+1] := P[i+1-1]*(1+h^alpha[i]+h^(2*alpha[i])); od;
#Q := [];
#for i in [1..9] do
#    Q[i] := h+Sum([0..i],j->P[j+1]*h^alpha[j+1])+Sum([0..i-1],j->P[j+1]*h^(2*alpha[j+1]));
#od;
#
#then Q[n] tends to the Poincare series. In particular, Corollary 3.9 in
#[Bartholdi:LCS] is wrong, and should read
# \begin{align*}
#    Q_1&=0,\\
#    Q_2&=\hbar+\hbar^2,\\
#    Q_3&=\hbar+\hbar^2+2\hbar^3+\hbar^4+\hbar^5,\\
#    Q_n&=(1+\hbar^{\alpha_n-\alpha_{n-1}})Q_{n-1}
#    +\hbar^{\alpha_{n-1}}(\hbar^{-\alpha_{n-3}}+1+\hbar^{\alpha_{n-3}})Q_{n-2}
#    \text{ for }n\ge4.
#  \end{align*}

InstallGlobalFunction(NeumannMachine, function(P)
    return MixerMachine(P,P,[[IdentityMapping(P)]]);
end);

InstallGlobalFunction(NeumannGroup, function(P)
    local G, M;
    M := NeumannMachine(P);
    G := SCGroup(M);
    SetName(G,Concatenation("NeumannGroup(",STRINGGROUP@(P),")"));
    G!.Correspondence := [GroupHomomorphismByImages(P,G,GeneratorsOfGroup(P),
      GeneratorsOfGroup(G){Correspondence(G){Correspondence(M)[1]}}),
    GroupHomomorphismByImages(P,G,GeneratorsOfGroup(P),
      GeneratorsOfGroup(G){Correspondence(G){Correspondence(M)[2]}})];
    return G;
end);

InstallGlobalFunction(FabrykowskiGuptaGroups, function(p)
    local G;
    G := NeumannGroup(CyclicGroup(IsPermGroup,p));
    G!.Name := Concatenation("FabrykowskiGuptaGroups(",String(p),")");
    SETGENERATORNAMES@(G,["a","r"]);
    SetFRGroupPreImageData(G,function(depth)
        local F, rels, sigma, a, r, Fgens, Ggens, Sgens, j, k, l;

        if depth=infinity then
            F := FreeGroup("a","r","s");
            sigma := F.3;
        else
            F := FreeGroup("a","r");
        fi;
        a := F.1;
        r := List([0..p-1],i->F.2^(a^i));
        rels := [a^p];
        for j in [3..p-1] do
            for k in [0..p-1] do
                for l in [0..p-1] do
                    Add(rels,Comm(r[2]^(r[1]^l),r[j+1]^(r[j]^k)));
                od;
            od;
        od;
        for k in [0..p-1] do
            for l in [1..p-1] do
                Add(rels,Comm(r[3]^(r[2]^k),Comm(r[1]^l,r[2]^-1)));
            od;
        od;
        Sgens := [r[1]^(a^-1),r[1]];
        if depth=infinity then
            F := F / Concatenation(rels,[a^sigma/Sgens[1],r[1]^sigma/Sgens[2]]);
            Fgens := GeneratorsOfGroup(F){[1..2]};
            F := Subgroup(F,Fgens);
        else
            sigma := GroupHomomorphismByImagesNC(F,F,[a,r[1]],Sgens);
            if depth>=0 then
                F := F / Flat([rels[1],r[1]^p,List(rels{[2..Length(rels)]},r->ITERATEMAP@(sigma,depth,r))]);
            else
                F := LPresentedGroup(F,[],[sigma],rels);
            fi;
            Fgens := GeneratorsOfGroup(F);
        fi;
        Ggens := GeneratorsOfGroup(G);
        if IsLpGroup(F) then
            Sgens := List(Sgens,x->ElementOfLpGroup(FamilyObj(Representative(F)),x));
        else
            Sgens := List(Sgens,x->ElementOfFpGroup(FamilyObj(Representative(F)),x));
        fi;
        return rec(F:=F,
                   image:=LPGROUPIMAGE@(G,F,Ggens,Fgens,Sgens,p),
                   preimage:=LPGROUPPREIMAGE@(Ggens,Fgens,Sgens,depth,p),
                   reduce:=w->w);
    end);
    return G;
end);

InstallValue(FabrykowskiGuptaGroup, FabrykowskiGuptaGroups(3));
FabrykowskiGuptaGroup!.Name := "FabrykowskiGuptaGroup";

InstallValue(ZugadiSpinalGroup, MixerGroup(Group((1,2,3)),Group((1,2,3)),
        [[IdentityMapping(Group((1,2,3))),IdentityMapping(Group((1,2,3)))]]));
SetName(ZugadiSpinalGroup,"ZugadiSpinalGroup");
SETGENERATORNAMES@(ZugadiSpinalGroup,["a","s"]);
#############################################################################

#############################################################################
##
#E HanoiMachine
#E HanoiGroup
#E GuptaSidkiGroup
#E FabrykowskiGuptaGroup
##
InstallGlobalFunction(HanoiGroup, function(k)
    local G, trans, out, i;
    trans := [List([1..k],i->1)];
    out := [()];
    for i in Combinations([1..k],2) do
        Add(trans,List([1..k],i->Length(trans)+1));
        trans[Length(trans)][i[1]] := 1;
        trans[Length(trans)][i[2]] := 1;
        Add(out,(i[1],i[2]));
    od;
    G := SCGroup(MealyMachine(trans,out));
    SetName(G, Concatenation("HanoiGroup(",String(k),")"));
    if k=3 then
        SetFRGroupPreImageData(G,function(depth)
            local F, Fgens, Ggens, Sgens, a, b, c, d, e, f, g, h, i, tau, rels;
            
            if depth=infinity then
                F := FreeGroup("a","b","c","tau");
                tau := F.4;
            else
                F := FreeGroup("a","b","c");
            fi;
            
            a := F.1; b := F.2; c := F.3;
            d := Comm(a,b); e := Comm(b,c); f := Comm(c,a);
            g := d^c; h := e^a; i := f^b;
            Fgens := [a,b,c];
            Sgens := [a,b^c,c^b];
            rels := [a^2,b^2,c^2,d^-1*e*f/i*g/e,h/e/d*f*d/i,e^-1/g/f*e*g*f,e^-1*d*h/e^2/d*h^2];
            if depth=infinity then
                F := F / Concatenation(rels,List([1..3],i->Fgens[i]^tau/Sgens[i]));
                Fgens := GeneratorsOfGroup(F){[1..3]};
                F := Subgroup(F,Fgens);
            else
                tau := GroupHomomorphismByImagesNC(F,F,Fgens,Sgens);
                if depth>=0 then
                    F := F / Flat([rels{[1..3]},List(rels{[4..Length(rels)]},r->ITERATEMAP@(tau,depth,r))]);
                else
                    F := LPresentedGroup(F,[],[tau],rels);
                fi;
                Fgens := GeneratorsOfGroup(F);
            fi;
            Ggens := GeneratorsOfGroup(G);
            if IsLpGroup(F) then
                Sgens := List(Sgens,x->ElementOfLpGroup(FamilyObj(Representative(F)),x));
            else
                Sgens := List(Sgens,x->ElementOfFpGroup(FamilyObj(Representative(F)),x));
            fi;
            return rec(F:=F,
                   image:=LPGROUPIMAGE@(G,F,Ggens,Fgens,Sgens,3),
                   preimage:=LPGROUPPREIMAGE@(Ggens,Fgens,Sgens,depth,3),
                   reduce:=w->w);
        end);
    fi;
    return G;
end);

InstallValue(DahmaniGroup,
        SCGroup(MealyMachine([[3,1],[2,1],[2,3]],[(1,2),(1,2),()])));
SetName(DahmaniGroup,"DahmaniGroup");

InstallValue(MamaghaniGroup,
        SCGroup(FRMachine(["a","b","c"],[[[],[2]],[[1],[3]],[[1],[-1]]],[(1,2),(),(1,2)])));
SetName(MamaghaniGroup,"MamaghaniGroup");

InstallValue(WeierstrassGroup,
        SCGroup(MealyMachine([[1,1,1,1],[1,1,1,1],[1,1,1,1],[1,1,1,1],[5,2,3,4]],[(),(1,2)(3,4),(1,3)(2,4),(1,4)(2,3),()])));
SetName(WeierstrassGroup,"WeierstrassGroup");
#############################################################################

#############################################################################
##
#E FRAffineGroup
#E CayleyMachine
#E CayleyGroup
InstallMethod(FRAffineGroup, "(FR) for a dimension, a ring, an element",
        [IsPosInt,IsRing,IsRingElement],
        function(dim,ring,unif)
    local trans;
    if IsIntegers(ring) then
        trans := List(ring mod AbsInt(unif),Int);
    elif IsUnivariatePolynomialRing(ring) and [unif]=IndeterminatesOfPolynomialRing(ring) then
        trans := Elements(CoefficientsRing(ring))*One(ring);
    else
        Error("FRAffineGroup: cannot handle ring ",ring," with uniformizer ",unif,"\n");
    fi;
    return FRAffineGroup(dim,ring,unif,trans);
end);

InstallMethod(FRAffineGroup, "(FR) for a dimension, a ring, an element, a transversal",
        [IsPosInt,IsRing,IsRingElement,IsCollection],
        function(dim,ring,unif,transversal)
    local d, G, phi, t, i, fam, tval, eval, o, out, a;
    d := Length(transversal);
    phi := PermutationMat(PermList(Concatenation([dim],[1..dim-1])),dim+1,ring);
    phi[1][dim] := 1/unif;
    fam := FREFamily([1..d]);
    if IsIntegers(ring) then
        eval := x->x mod unif;
    elif IsUnivariatePolynomialRing(ring) and [unif]=IndeterminatesOfPolynomialRing(ring) then
        eval := x->Value(x,Zero(ring));
    else
        Error("FRAffineGroup: cannot handle ring ",ring," with uniformizer ",unif,"\n");
    fi;
    tval := List(transversal,eval);
    out := [];
    for i in transversal do
        for t in transversal do if Inverse(eval(t))<>fail then
            o := [];
            for a in transversal do
                Add(o,Position(tval,eval(i+a*t)));
            od;
            Add(out,PermList(o));
        fi; od;
    od;
    G := Group(MinimalGeneratingSet(Group(out))); # vertex group
    G := FullSCGroup([1..d],G,IsFRObject);
    SetCorrespondence(G,GroupHomomorphismByFunction(MatrixAlgebra(ring,dim+1),
            G,function(mat)
        local i, j, states, trans, out, t, o, x, y, p, a;
        for i in [1..dim] do
            for j in [1..i-1] do
                if not IsZero(eval(mat[i][j])) then return fail; fi;
            od;
            if Inverse(eval(mat[i][i]))=fail then return fail; fi;
            if not IsZero(mat[i][dim+1]) then return fail; fi;
        od;
        if not IsOne(mat[dim+1][dim+1]) then return fail; fi;
        states := [mat];
        trans := [];
        out := [];
        i := 1;
        while i <= Length(states) do
            t := [];
            o := [];
            for a in transversal do
                x := ShallowCopy(states[i]);
                x[dim+1] := x[dim+1]+a*states[i][1];
                y := eval(x[dim+1][1]);
                p := Position(tval,y);
                if p=fail then return fail; fi;
                Add(o,p);
                x[dim+1][1] := x[dim+1][1]-transversal[p];
                x := x^phi;
                p := Position(states,x);
                if p=fail then
                    Add(states,x);
                    Add(t,Length(states));
                else
                    Add(t,p);
                fi;
            od;
            Add(trans,t);
            Add(out,o);
            if not ISINVERTIBLE@(out[i]) then return fail; fi;
            i := i+1;
            if RemInt(i,10)=0 then
                Info(InfoFR, 2, "FRAffineGroup: at least ",i," states");
            fi;
        od;
        i := MealyElementNC(fam,trans,out,1);
        return i;
    end));
    return G;
end);

InstallGlobalFunction(CayleyMachine, function(g)
    local e, h;
    if IsPermGroup(g) then
        h := IdentityMapping(g);
    else
        h := IsomorphismPermGroup(g);
    fi;
    e := Elements(Range(h));
    return MealyMachine(List(e,x->[1..Size(e)]),List(e,Inverse));
end);

InstallGlobalFunction(CayleyGroup, function(g)
    local h, m, id, s;
    if IsPermGroup(g) then
        h := IdentityMapping(g);
    else
        h := IsomorphismPermGroup(g);
    fi;
    m := SCGroup(CayleyMachine(Range(h)));
    s := GeneratorsOfGroup(m);
    id := First(s,x->ActivityPerm(x)=());
    m!.Correspondence := [GroupHomomorphismByImages(g,m,GeneratorsOfGroup(g),List(GeneratorsOfGroup(g),x->First(s,y->ActivityPerm(y)=(x^h)^-1)^-1*id)),id];
    SetName(m,Concatenation("CayleyGroup(",STRINGGROUP@(g),")"));
    return m;
end);

InstallMethod(LamplighterGroup, "(FR) yielding an FR group",
        [IsFRGroup,IsGroup],
        function(filter,G)
    local L;
    if IsAbelian(G) and IsFinite(G) then
        L := CayleyGroup(G);
        L!.Name := Concatenation("LamplighterGroup(",StructureDescription(G),")");
        return L;
    else
        TryNextMethod();
    fi;
end);
#############################################################################

#############################################################################
##
#E BinaryKneadingGroup
#E BasilicaGroup
##
BindGlobal("BINARYKNEADINGMACHINE@", function(arg)
    local dbl, i, s, G, M, gen, act, h0, h1, k, n, ksym, transition, output, name, kseq, preperiod, period;

    if arg=[] then arg := ["*"]; fi;

    kseq := ["",""];

    ksym := function(c)
        if c='0' or c=0 then
            return '0';
        elif c='1' or c=1 then
            return '1';
        else
            Error("Kneading symbol should be 0,1,'0' or '1', but not ",c,"\n");
        fi;
    end;
    name := "(";
    if IsRat(arg[1]) then # argument is theta
        dbl := function(a)
            if a>=1/2 then return 2*a-1; else return 2*a; fi;
        end;
        h0 := function(a)
            if a<arg[1] then return a/2; else return (a+1)/2; fi;
        end;
        h1 := function(a)
            if a<arg[1] then return (a+1)/2; else return a/2; fi;
        end;
        gen := function(a)
            if a in period then return Position(period,a); else return 1; fi;
        end;
        act := function(x)
            if x=arg[1] then return (1,2); else return (); fi;
        end;

        i := arg[1]; period := [666]; # out of the way; will correspond to id
        while not i in period do
            if i=arg[1]/2 or i=(arg[1]+1)/2 then
                k := '*';
            elif i>arg[1]/2 and i<(arg[1]+1)/2 then
                k := '1';
            else
                k := '0';
            fi;
            if IsEvenInt(DenominatorRat(i)) then
                Add(kseq[1],k);
            else
                Add(kseq[2],k);
            fi;
            Add(period,i);
            i := dbl(i);
        od;
        transition := []; output := [];
        for i in period do
            Add(transition, [gen(h0(i)),gen(h1(i))]);
            Add(output, act(i));
        od;
        M := MealyMachine(transition, output);
        G := SCGroup(M);
        G!.Correspondence := function(alpha)
            local p;
            p := Position(period,alpha);
            if p<>fail then
                return GeneratorsOfGroup(G)[p];
            else return One(G); fi;
        end;
        Append(name,String(arg[1]));
    elif not ForAll(arg,IsList) then
        Error("Arguments should be lists\n");
    elif (Length(arg)=2 and arg[1]<>[])
      or (Length(arg)=1 and IsPeriodicList(arg[1])) then # argument is pair of lists w,v
        if Length(arg)=2 then
            preperiod := arg[1]; period := arg[2];
        else
            preperiod := PrePeriod(arg[1]); period := Period(arg[2]);
        fi;
        k := Length(preperiod);
        n := Length(period);
        transition := [[n+k+1,n+k+1]]; # b1
        output := [(1,2)];
        Add(name,'"'); #" to fix font-lock
        for i in [1..k-1] do
            s := ksym(preperiod[i]);
            if s='1' then
                Add(transition,[n+k+1,i]);
            else Add(transition,[i,n+k+1]); fi;
            Add(name,s);
            Add(kseq[1],s);
            Add(output,());
        od;
        s := ksym(preperiod[k]);
        if s=ksym(period[n]) then
            Error("Last symbols of w and v must differ\n");
        fi;
        if s='1' then
            Add(transition,[n+k,k]); # a1
        else Add(transition,[k,n+k]); fi;
        Add(name,s);
        Add(kseq[1],s);
        Add(output,());
        Append(name,"\",\"");
        for i in [1..n-1] do
            s := ksym(period[i]);
            if s='1' then
                Add(transition,[n+k+1,k+i]);
            else Add(transition,[k+i,n+k+1]); fi;
            Add(name,s);
            Add(kseq[2],s);
            Add(output,());
        od;
        Add(transition,[n+k+1,n+k+1]); # identity state
        Add(output,());
        Add(name,ksym(period[n]));
        Add(kseq[2],ksym(period[n]));
        Add(name,'"');
        M := MealyMachine(transition, output);
        G := SCGroup(M);
        G!.Correspondence := [GeneratorsOfGroup(G){[1..k]},
                              GeneratorsOfGroup(G){[1+k..n+k]}];


    elif Length(arg)=1 or arg[1]=[] then # argument is list v
        period := Concatenation(arg);
        Add(name,'"');
        if Length(period)=0 then
            n := 1;
        elif period[Length(period)]='*' then
            n := Length(period);
        else
            n := Length(period)+1;
        fi;
        transition := [[n+1,n]]; # a1
        output := [(1,2)];
        for i in [1..n-1] do
            s := ksym(period[i]);
            if s='1' then
                Add(transition,[n+1,i]);
            else Add(transition,[i,n+1]); fi;
            Add(name,s);
            Add(kseq[2],s);
            Add(output,());
        od;
        Add(transition,[n+1,n+1]); # identity state
        Add(output,());
        Append(name,"*\"");
        Add(kseq[2],'*');
        M := MealyMachine(transition, output);
        G := SCGroup(M);
        G!.Correspondence := GeneratorsOfGroup(G);
    fi;
    SetKneadingSequence(G,PeriodicList(kseq[1],kseq[2]));
    SetKneadingSequence(M,PeriodicList(kseq[1],kseq[2]));
    Append(name,")");
    return [M,G,name];
end);

BindGlobal("PERIODICBKG_PREIMAGE@", function(G,depth)
    local a, s, t, kseq, i, j, n, d, epsilon, F, r, tau, image, knows,
          nuke, nukeimg, Ggens, Fgens, Sgens, preimage, makeSgens;
    kseq := KneadingSequence(G);
    a := ShallowCopy(Period(kseq));
    n := Length(a);
    a[n] := '0';
    d := n/Length(Period(CompressedPeriodicList("",a)));
    if d>1 then
        epsilon := 1;
    else
        epsilon := -1;
        a[n] := '1';
        d := n/Length(Period(CompressedPeriodicList("",a)));
    fi;
    Ggens := GeneratorsOfGroup(G);

    makeSgens := function(Fgens)
        local i, Sgens;
        Sgens := [];
        for i in [1..n] do
            if kseq[i]='0' then
                Add(Sgens,Fgens[i+1]);
            elif kseq[i]='1' then
                Add(Sgens,Fgens[i+1]^(Fgens[1]^-1));
            else
                Add(Sgens,Fgens[1]^2);
            fi;
        od;
        return Sgens;
    end;

    if depth=infinity then
        F := FreeGroup("a","t");
        a := F.1; t := F.2;
        s := One(F);
        for i in [1..n-1] do
            if kseq[i]='1' then s := a*s; fi;
            s := s^t;
        od;
        r := [a^(t^n)/(a^2)^s];
        for i in [1..n-1] do for j in [1..n-1] do
            Add(r,Comm(a^(t^i),a^(t^j*a)));
            Add(r,Comm(a^(t^i),a^(t^j*a^3)));
        od; od;
        F := F / r;
        a := F.1; t := F.2;
        r := a^-1; Fgens := [r];
        for i in [1..n-1] do
            r := r^t;
            if kseq[i]='1' then r := r^(a^-1); fi;
            Add(Fgens,r);
        od;
        F := Subgroup(F,Fgens);
    else
        F := FreeGroup(n,"a");
        a := GeneratorsOfGroup(F);
        s := GroupHomomorphismByImagesNC(F,F,a,makeSgens(a));
        r := [];
        if depth=-1 then
            depth := 0;
            knows := true; # knows that we want an L presentation
        else
            knows := false;
        fi;
        for i in [2..n] do for j in [2..n] do
            if kseq[i-1]=kseq[j-1] then
                Append(r,ITERATEMAP@(s,depth,Comm(a[i],a[j]^a[1])));
            else
                Append(r,ITERATEMAP@(s,depth,Comm(a[i],a[j])));
                Append(r,ITERATEMAP@(s,depth,Comm(a[i],a[j]^(a[1]^2))));
            fi;
        od; od;
        if knows then
            F := LPresentedGroup(F,[],[s],r);
        else
            F := F / r;
        fi;
        Fgens := GeneratorsOfGroup(F);
    fi;
    tau := function(g)
        local x, t;
        t := 0;
        for x in Germs(g) do
            if Output(g,ConfinalityClass(x[2])[n],1)=2 then
                t := t+2*ConfinalityClass(x[1])[n]-3;
            fi;
        od;
        return Ggens[n]^t;
    end;
    nuke := [One(G)]; Append(nuke,Ggens); Append(nuke,List(Ggens,Inverse));
    nukeimg := [One(F)]; Append(nukeimg,Fgens);
    Append(nukeimg,List(Fgens,Inverse));
    for j in [1..d-1] do for i in [1..n] do
        r := RemInt(i+(n/d)*j-1,n)+1;
        Add(nuke,Ggens[i]^epsilon/Ggens[r]^epsilon);
        Add(nukeimg,Fgens[i]^epsilon/Fgens[r]^epsilon);
    od; od;
    SortParallel(nuke,nukeimg);
    if depth=infinity then
        knows := NewDictionary(nuke[1],true);
        for i in [1..Length(nuke)] do
            AddDictionary(knows,nuke[i],nukeimg[i]);
        od;
        image := function(g)
            local todo, recur;
            todo := NewDictionary(g,false);
            recur := function(g)
                local i, x, y;
                i := LookupDictionary(knows,g);
                if i<>fail then return i; fi;
                i := DecompositionOfFRElement(g);
                if not i[2] in [[1,2],[2,1]] then return fail; fi;
                if KnowsDictionary(todo,g) then
                    return fail; # we reached a recurring state not in the nucleus
                fi;
                AddDictionary(todo,g);
                x := recur(i[1][1]);
                y := recur(LeftQuotient(tau(i[1][1]),i[1][2]));
                if x=fail or y=fail then return fail; fi;
                x := x^t*a*y^t;
                if ISONE@(i[2]) then x := x/a; fi;
                AddDictionary(knows,g,x);
                return x;
            end;
            return recur(g);
        end;
        r := FreeGroup(n,"a");
        Fgens := GeneratorsOfGroup(r);
        Sgens := makeSgens(Fgens);
        preimage := function(w)
            local up, down, g, i, j;
            up := 0; down := 0;
            g := One(Ggens[1]);
            for i in LetterRepAssocWord(UnderlyingElement(w)) do
                if AbsInt(i)=1 then
                    i := r.1^(-SignInt(i));
                    for j in [1..up] do
                        i := MappedWord(i,Fgens,Sgens);
                    od;
                    g := g*MappedWord(i,Fgens,Ggens);
                elif i=2 then
                    if up>0 then
                        up := up-1;
                    else
                        down := down+1;
                        g := VertexElement(1,g);
                    fi;
                elif i=-2 then
                    if down>0 and ActivityPerm(g)=() then
                        down := down-1;
                        g := State(g,1);
                    else
                        up := up+1;
                    fi;
                fi;
            od;
            if up<>down then
                return fail;
                Error("Element ",w," has non-trivial translation ",down-up,"\n");
            elif up>0 then
                return fail;
                Error("Element ",w," does not fix the root vertex\n");
            fi;
            return g;
        end;
    else
        Sgens := makeSgens(Fgens);
        knows := NewDictionary(nuke[1],true);
        for i in [1..Length(nuke)] do
            AddDictionary(knows,nuke[i],nukeimg[i]);
        od;
        image := function(g)
            local todo, recur;
            todo := NewDictionary(g,false);
            recur := function(g)
                local i, x, y;
                i := LookupDictionary(knows,g);
                if i<>fail then return i; fi;
                i := DecompositionOfFRElement(g);
                if not i[2] in [[1,2],[2,1]] then return fail; fi;
                if KnowsDictionary(todo,g) then
                    return fail;    # we reached a recurring state not in the nucleus
                fi;
                AddDictionary(todo,g);
                x := recur(i[1][1]);
                y := recur(LeftQuotient(tau(i[1][1]),i[1][2]));
                if x=fail or y=fail then return fail; fi;
                x := MappedWord(x,Fgens,Sgens)/Fgens[1]*
                     MappedWord(y,Fgens,Sgens);
                if ISONE@(i[2]) then x := x*Fgens[1]; fi;
                AddDictionary(knows,g,x);
                return x;
            end;
            return recur(g);
        end;
        preimage := w->MappedWord(w,Fgens,Ggens);
    fi;
    return rec(F:=F, image:=image, preimage:=preimage, reduce:=w->w);
end);

BindGlobal("PREPERIODICBKG_PREIMAGE@", function(G,depth)
    local kseq, k, n, d, a, b, i, j, rel, sigma, t, w,
          glob_t, glob_s, glob_m, glob_u,
          makeSgens, image, knows, preimage, dihedralimage, reduce, tau,
          F, Fgens, Ggens, Sgens, Fnuke, Gnuke, O, creator;

    kseq := KneadingSequence(G);
    k := Length(PrePeriod(kseq));
    n := Length(Period(kseq));
    d := n/Length(Period(CompressedPeriodicList(kseq)));
    Ggens := GeneratorsOfGroup(G);

    makeSgens := function(Fgens)
        # returns images of Fgens under sigma
        # also sets globals glob_t, glob_s, glob_m, glob_u
        #
        local i, s, t, Sgens, ob, ooob;
        Sgens := [];
        for i in [1..k+n] do
            if i<k+n then s := i+1; else s := i+1-n; fi;
            if kseq[i]='0' then
                Add(Sgens,Fgens[s]);
            else
                Add(Sgens,Fgens[s]^Fgens[1]);
            fi;
        od;

        ob := Sgens[1]^(Fgens[1]^-1);

        if k>=2 and n>=2 then
            if kseq[k+n-1]=kseq[k-1] then
                s := Fgens[1]; t := ob;
            else
                s := One(Fgens[1]); t := One(Fgens[1]);
            fi;
            glob_m := 1;
        elif k>=3 and n=1 then
            ooob := Fgens[3];
            if kseq[2]='0' then ooob := ooob^Fgens[1]; fi;
            if kseq[1]='0' then ooob := ooob^ob; fi;
            if kseq[k-1]='1' and kseq[k-2]='1' then
                s := ob; t := ooob;
            elif kseq[k-1]='0' and kseq[k-2]='0' then
                s := ob^(Fgens[1]^-1); t := ooob^(ob^-1);

            else
                s := One(Fgens[1]); t := One(Fgens[1]);
            fi;
            if kseq[k]<>kseq[k-1] then s := Fgens[1]*s; t := ob^-1*t; fi;
            glob_m := 1;
        elif k=2 and n=1 then
            if kseq[1]<>kseq[2] then
                s := Fgens[1]; t := ob;
            else
                s := One(Fgens[1]); t := One(Fgens[1]);
            fi;
            glob_m := 2;
        elif k=1 and n>=2 then
            s := One(Fgens[1]); t := One(Fgens[1]);
            glob_m := 2;
        else
            s := One(Fgens[1]); t := One(Fgens[1]);
            glob_m := infinity;
        fi;
        if kseq[k]='1' then
            glob_u := t^Fgens[1];
            t := Fgens[1]*t;
        else
            glob_u := t;
        fi;
        glob_s := Fgens[k+n]^s;
        glob_t := Fgens[k+1]^t;

        Sgens[k] := glob_t;
        return Sgens;
    end;

    if depth=infinity then
        F := FreeGroup("a","b","t");
        a := F.1; b := F.2; t := F.3;
        w := One(F);
        Fgens := [b];
        for i in [1..k] do
            w := w^t;
            if kseq[i]='1' then w := b*w; fi;
            Add(Fgens,b^(t^i/w));
        od;
        rel := [a^2,b^2,b^(t^k)/a^w];
        w := One(F);
        for i in [k+1..k+n] do
            w := w^t;
            if kseq[i]='1' then w := b*w; fi;
        od;
        Remove(Fgens);
        Append(Fgens,ListWithIdenticalEntries(n,One(F))); # not needed
        makeSgens(Fgens); # to compute glob_u
        Add(rel,a^(glob_u^-1*t^n)/a^(glob_u^-1*w));
        if glob_m<>infinity then
            Add(rel,(a*b)^(2^(glob_m+1)));
        fi;
        for i in [1..d] do for j in i+[1..d-1]*n/d do
            Add(rel,Comm(a^(t^i),a^(t^j)));
        od; od;
        for i in [1..k-1] do for j in [1..k-1] do
            for w in [0..2^glob_m] do
                Add(rel,Comm(b^(t^i),b^(t^j*b*(a*b)^(2*w))));
            od;
        od; od;
        for i in [1..n-1] do for j in [1..k-1] do
            for w in [0..2^glob_m] do
                Add(rel,Comm(a^(t^i),b^(t^j*b*(a*b)^(2*w))));
            od;
        od; od;
        for i in [1..n-1] do for j in [1..n-1] do
            for w in [0..2^glob_m] do
                Add(rel,Comm(a^(t^i),a^(t^j*b*(a*b)^(2*w))));
            od;
        od; od;
        F := F / rel;
        a := F.1; b := F.2; t := F.3;
        w := b;
        Fgens := [w];
        for i in [1..k-1] do
            w := w^t;
            if kseq[i]='1' then w := w^b; fi;
            Add(Fgens,w);
        od;
        Append(Fgens,ListWithIdenticalEntries(n,One(F))); # not needed
        makeSgens(Fgens); # to compute glob_u
        Fgens := Fgens{[1..k]}; # back to previous Fgens
        w := a^glob_u;
        Add(Fgens,w);
        for i in [1..n-1] do
            w := w^t;
            if kseq[i]='1' then w := w^b; fi;
            Add(Fgens,w);
        od;
        F := Subgroup(F,Fgens);
        creator := ElementOfFpGroup;
    else
        F := FreeGroup(Concatenation(List([1..k],i->Concatenation("b",String(i))),List([1..n],i->Concatenation("a",String(i)))));
        Fgens := GeneratorsOfGroup(F);
        sigma := GroupHomomorphismByImagesNC(F,F,Fgens,makeSgens(Fgens));
        rel := List(Fgens,x->x^2);
        for i in [1..n/d] do for j in [1..d-1] do
            Add(rel,Comm(Fgens[k+i],Fgens[k+i+j*n/d]));
        od; od;
        O := [[],[]];
        if depth=-1 then
            creator := ElementOfLpGroup;
            depth := 0;
        else
            creator := ElementOfFpGroup;
        fi;
        if glob_m<infinity then
            Append(rel,ITERATEMAP@(sigma,depth,(Fgens[1]*glob_t)^(2^(glob_m+1))));
            for i in [1..2^glob_m] do
                Add(O[2-RemInt(i,2)], (glob_t*Fgens[1])^i);
                Add(O[1+RemInt(i,2)], (Fgens[1]*glob_t)^(i+1));
                Add(O[1+RemInt(i,2)], Fgens[1]*(glob_t*Fgens[1])^i);
                Add(O[2-RemInt(i,2)], glob_t*(Fgens[1]*glob_t)^i);
            od;
        fi;
        for i in Concatenation([2..k],[k+2..k+n]) do
            for j in Concatenation([2..k],[k+2..k+n]) do
                if kseq[i-1]=kseq[j-1] then
                    for w in O[1] do Append(rel,ITERATEMAP@(sigma,depth,Comm(Fgens[i],Fgens[j]^w))); od;
                else
                    for w in O[2] do Append(rel,ITERATEMAP@(sigma,depth,Comm(Fgens[i],Fgens[j]^w))); od;
                fi;
            od;
        od;
        if creator=ElementOfFpGroup then
            F := F / rel;
        else
            F := LPresentedGroup(F,[],[sigma],rel);
        fi;
        Fgens := GeneratorsOfGroup(F);
    fi;
    tau := function(g,bkimg,animg)
        local i, p, x;
        x := One(F);
        p := Portrait(g,k+n-1);
        if k=1 and n=1 then
            Error("not branched; treated separately\n");
        elif k=1 then
            if kseq[k+n-1]='0' then i := 1; else i := 2; fi;
            if Product(Flat(p[k+n][i]))=(1,2) then x := x*animg; fi;
            if Product(Flat(p[k+n][3-i]))=(1,2) then x := x*animg^bkimg; fi;
            if p[1]=(1,2) then x := x*bkimg; fi;
        elif k=2 and n=1 then
            if kseq[1]=kseq[2] then i := 1; else i := 2; fi;
            p := Portrait(g,3); # we need more here
            if Product(Flat(p[3]))=(1,2) then x := x*animg; fi;
            if Product(Flat(p[2]))=(1,2) then x := x*bkimg; fi;
            if p[3][1][1]*Product(p[4][1][1])*p[3][2][i]*Product(p[4][2][i])=
               (1,2) then x := x*Comm(bkimg,animg); fi;
        else
            if Product(Flat(p[k+n]))=(1,2) then x := x*animg; fi;
            if Product(Flat(p[k]))=(1,2) then x := x*bkimg; fi;
        fi;
        return x;
    end;
    Gnuke := [One(G)]; Append(Gnuke,Ggens{[1..k]});
    Fnuke := [One(F)]; Append(Fnuke,Fgens{[1..k]});
    for j in [k+1..k+n/d] do for i in Combinations([j,j+n/d..j+n-n/d]) do
        if i<>[] then
            Add(Gnuke,Product(Ggens{i}));
            Add(Fnuke,Product(Fgens{i}));
        fi;
    od; od;
    SortParallel(Gnuke,Fnuke);
    reduce := function(g)
        local i, w, x, changed;
        w := UnderlyingElement(g);
        x := LetterRepAssocWord(w);
        changed := false;
        for i in [1..Length(x)] do
            if x[i]<0 then x[i] := -x[i]; changed := true; fi;
        od;
        i := 1;
        while i<Length(x) do
            if x[i]=x[i+1] then
                changed := true;
                Remove(x,i); Remove(x,i);
                if i>1 then i := i-1; fi;
            elif x[i]>x[i+1] and x[i+1]>k and RemInt(x[i+1]-x[i],n/d)=0 then
                changed := x[i]; x[i] := x[i+1]; x[i+1] := changed;
                changed := true;
                if i>1 then i := i-1; fi;
            else
                i := i+1;
            fi;
        od;
        if changed then
            return creator(FamilyObj(g),AssocWordByLetterRep(FamilyObj(w),x));
        else
            return g;
        fi;
    end;
    dihedralimage := function(g,b,a)
        local x, n, i;
        if kseq[1]='0' then i := x->x=1; else i := x->x=2; fi;
        n := 0;
        for x in Germs(g) do
            if IsOddInt(Number(x[1],i)) then n := n+1; else n := n-1; fi;
        od;
        x := (b*a)^n;
        if (ActivityPerm(g)=(1,2))=IsEvenInt(n) then x := x*b; fi;
        return reduce(x);
    end;
    if depth=infinity then
        if k=1 and n=1 then
            image := g->dihedralimage(g,b,a);
        else
            makeSgens(Fgens); # compute global glob_s
            rel := [glob_s,Fgens[k]]; # and save it away
            knows := NewDictionary(Gnuke[1],true);
            for i in [1..Length(Gnuke)] do
                AddDictionary(knows,Gnuke[i],Fnuke[i]);
            od;
            image := function(g)
                local todo, recur;
                todo := NewDictionary(g,false);
                recur := function(g)
                    local i, x, y;
                    i := LookupDictionary(knows,g);
                    if i<>fail then return i; fi;
                    i := DecompositionOfFRElement(g);
                    if not i[2] in [[1,2],[2,1]] then return fail; fi;
                    if KnowsDictionary(todo,g) then
                        return fail; # we reached a recurring state not in the nucleus
                    fi;
                    AddDictionary(todo,g);
                    x := recur(i[1][1]);
                    y := recur(i[1][2]);
                    if x=fail or y=fail then return fail; fi;
                    x := x^t*b/tau(i[1][1],rel[1],rel[2])^t*y^t;
                    if ISONE@(i[2]) then x := x*b; fi;
                    AddDictionary(knows,g,x);
                    return x;
                end;
                return recur(g);
            end;
        fi;
        Fgens := GeneratorsOfGroup(FreeGroup(Concatenation(List([1..k],i->Concatenation("b",String(i))),List([1..n],i->Concatenation("a",String(i))))));
        Sgens := makeSgens(Fgens);
        preimage := function(w)
            local up, down, g, i, j;
            up := 0; down := 0;
            g := One(Ggens[1]);
            for i in LetterRepAssocWord(UnderlyingElement(w)) do
                if AbsInt(i)=1 then
                    i := Fgens[k+1]^glob_u;
                    for j in [1..up] do
                        i := MappedWord(i,Fgens,Sgens);
                    od;
                    g := g*MappedWord(i,Fgens,Ggens);
                elif AbsInt(i)=2 then
                    i := Fgens[1];
                    for j in [1..up] do
                        i := MappedWord(i,Fgens,Sgens);
                    od;
                    g := g*MappedWord(i,Fgens,Ggens);
                elif i=3 then
                    if up>0 then
                        up := up-1;
                    else
                        down := down+1;
                        g := VertexElement(1,g);
                    fi;
                elif i=-3 then
                    if down>0 and ActivityPerm(g)=() then
                        down := down-1;
                        g := State(g,1);
                    else
                        up := up+1;
                    fi;
                fi;
            od;
            if up<>down then
                return fail;
                Error("Element ",w," has non-trivial translation ",down-up,"\n");
            elif up>0 then
                return fail;
                Error("Element ",w," does not fix the root vertex\n");
            fi;
            return g;
        end;
    else
        Sgens := List(makeSgens(Fgens),reduce);
        for i in [2..k+n] do
            if DecompositionOfFRElement(MappedWord(Sgens[i],Fgens,Ggens))<>[[Ggens[i],MappedWord(reduce(tau(Ggens[i],glob_s,Fgens[k])),Fgens,Ggens)],[1,2]] then
                Error("Bad generator decomposition ",i,"\n");
            fi;
        od;
        if k=1 and n=1 then
            image := g->dihedralimage(g,Fgens[1],Fgens[2]);
        else
            knows := NewDictionary(Gnuke[1],true);
            for i in [1..Length(Gnuke)] do
                AddDictionary(knows,Gnuke[i],Fnuke[i]);
            od;
            image := function(g)
                local todo, recur;
                todo := NewDictionary(g,false);
                recur := function(g)
                    local i, x, y;
                    i := LookupDictionary(knows,g);
                    if i<>fail then return i; fi;
                    i := DecompositionOfFRElement(g);
                    if not i[2] in [[1,2],[2,1]] then return fail; fi;
                    if KnowsDictionary(todo,g) then
                        return fail; # we reached a recurring state not in the nucleus
                    fi;
                    AddDictionary(todo,g);

                    x := recur(i[1][1]);
                    y := recur(i[1][2]);
                    if x=fail or y=fail then return fail; fi;
                    x := MappedWord(x,Fgens,Sgens)*Fgens[1]/
                         MappedWord(tau(i[1][1],glob_s,Fgens[k]),Fgens,Sgens)*
                         MappedWord(y,Fgens,Sgens);
                    if ISONE@(i[2]) then x := x*Fgens[1]; fi;
                    AddDictionary(knows,g,x);
                    return x;
                end;
                return recur(g);
            end;
        fi;
        preimage := w->MappedWord(w,Fgens,Ggens);
    fi;
    return rec(F:=F, image:=image, preimage:=preimage, reduce:=reduce);
end);

InstallGlobalFunction(BinaryKneadingMachine, function(arg)
    local t;
    t := CallFuncList(BINARYKNEADINGMACHINE@,arg);
    SetName(t[1],Concatenation("BinaryKneadingMachine",t[3]));
    return t[1];
end);

InstallGlobalFunction(BinaryKneadingGroup, function(arg)
    local t;
    t := CallFuncList(BINARYKNEADINGMACHINE@,arg);
    SetName(t[2],Concatenation("BinaryKneadingGroup",t[3]));
    if PrePeriod(KneadingSequence(t[2]))="" then
        SetFRGroupPreImageData(t[2],n->PERIODICBKG_PREIMAGE@(t[2],n));
    else
        SetFRGroupPreImageData(t[2],n->PREPERIODICBKG_PREIMAGE@(t[2],n));
    fi;
    SetIsBoundedFRSemigroup(t[2],true);
    NucleusOfFRSemigroup(t[2]);
    return t[2];
end);

InstallValue(BasilicaGroup, BinaryKneadingGroup("1"));
BasilicaGroup!.Name := "BasilicaGroup";
SETGENERATORNAMES@(BasilicaGroup,["a","b"]);
SetName(GeneratorsOfSemigroup(BasilicaGroup)[4],"a^-1");
SetName(GeneratorsOfSemigroup(BasilicaGroup)[5],"b^-1");
SetName(NucleusOfFRSemigroup(BasilicaGroup)[4],"a"); #???

InstallValue(FornaessSibonyGroup, FRGroup("alpha=(1,2)(3,4)",
        "beta=<alpha,gamma,alpha,gamma>","gamma=<beta,,,beta>","a=(1,3)(2,4)",
        "b=<alpha*a,alpha*a,c,c>","c=<beta*b,beta*b,b,b>":IsMealyElement));

InstallGlobalFunction(PoirierExamples, function(arg)
    if arg=[1] then
        return PolynomialIMGMachine(2,[1/7],[]);
    elif arg=[2] then
        return PolynomialIMGMachine(2,[],[1/2]);
    elif arg=[3,1] then
        return PolynomialIMGMachine(2,[],[5/12]);
    elif arg=[3,2] then
        return PolynomialIMGMachine(2,[],[7/12]);
    elif arg=[4,1] then
        return PolynomialIMGMachine(3,[[3/4,1/12],[1/4,7/12]],[]);
    elif arg=[4,2] then
        return PolynomialIMGMachine(3,[[7/8,5/24],[5/8,7/24]],[]);
    elif arg=[4,3] then
        return PolynomialIMGMachine(3,[[1/8,19/24],[3/8,17/24]],[]);
    elif arg=[5] then
        return PolynomialIMGMachine(3,[[3/4,1/12],[3/8,17/24]],[]);
    elif arg=[6,1] then
        return PolynomialIMGMachine(4,[],[[1/4,3/4],[1/16,13/16],[5/16,9/16]]);
    elif arg=[6,2] then
        return PolynomialIMGMachine(4,[],[[1/4,3/4],[3/16,15/16],[7/16,11/16]]);
    elif arg=[7] then
        return PolynomialIMGMachine(5,[[0,4/5],[1/5,2/5,3/5]],[[1/5,4/5]]);
    elif arg=[9,1] then
        return PolynomialIMGMachine(3,[[0,1/3],[5/9,8/9]],[]);
    elif arg=[9,2] then
        return PolynomialIMGMachine(3,[[0,1/3]],[[5/9,8/9]]);
    fi;
end);
#############################################################################

#############################################################################
##
#E I2Machine
#E I2Monoid
#E I4Machine
#E I4Monoid
##
InstallValue(I2Machine,MealyMachine([[1,1],[2,1]],[(1,2),[2,2]]));

InstallValue(I2Monoid,SCMonoid(I2Machine));
SetName(I2Monoid,"I2");
SETGENERATORNAMES@(I2Monoid,["f0","f1"]);

InstallValue(I4Machine,MealyMachine([[3,3],[1,2],[3,3]],[(1,2),[1,1],()]));

InstallValue(I4Monoid,SCMonoid(I4Machine));
SetName(I4Monoid,"I4");
SETGENERATORNAMES@(I4Monoid,["s","f"]);
#############################################################################

#############################################################################
# the PSZ algebras
#
InstallGlobalFunction(PSZAlgebra, function(arg)
    local p, t, u, i, k, m;
    
    while Length(arg)=0 or Length(arg)>2 do
        Error("PSZAlgebra: need 1 or 2 arguments");
    od;
    if IsPosInt(arg[1]) then
        k := GF(arg[1]);
    elif IsField(arg[1]) then
        k := arg[1];
    else
        k := Rationals; # trigger error
    fi;
    p := Characteristic(k);
    while p=0 do
        Error("PSZAlgebra: first argument ",k," must be a field of positive characteristic");
    od;
    if Length(arg)=2 then
        m := arg[2];
        while not IsPosInt(arg[2]) do
            Error("PSZAlgebra: optional second argument ",arg[2]," must be a positive integer");
        od;
    else
        m := 2;
    fi;
    
    u := NullMat(m+1,m+1,k);
    t := MATRIX@(IdentityMat(p,k),i->u);
    
    u := NullMat(m+1,m+1,k);
    for i in [1..m-1] do
        u[i+1][i] := One(k);
    od;
    u[m+1][m+1] := One(k);
    for i in [1..p] do t[i][i] := u; od;
    
    u := NullMat(m+1,m+1,k);
    u[1][m+1] := One(k);
    for i in [1..p-1] do t[i+1][i] := u; od;
    
    u := NullMat(m+1,m+1,k);
    u[m][m] := -One(k);
    t[1][p] := u;
    
    u := ListWithIdenticalEntries(m+1,Zero(k)); u[m+1] := One(k);
    t := SCAlgebraWithOne(VectorMachine(k,t,u));
    SetName(t,Concatenation("PSZAlgebra(",String(k),",",String(m),")"));
    if m=2 then
        SetName(t.1,"d");
    else
        for i in [1..m-1] do
            SetName(t.(i),Concatenation("d",String(i)));
        od;
    fi;
    SetName(t.2,"v");
    
    for i in [1..m] do
        SetDegreeOfHomogeneousElement(t.(i),IdentityMat(m)[i]);
    od;
    t!.components := NewDictionary(u,true);
    SetDegreeOfHomogeneousElement(One(t),Zero(Integers^m));
    i := VectorSpace(k,[One(t)]);
    SetParent(i,t);
    AddDictionary(t!.components,Zero(Integers^m),i);
    SetGrading(t,rec(source := Integers^m, hom_components := function(arg)
        local i, j, v;
        
        while not arg in Grading(t).source do
            Error("Grading degree ",arg," must belong to ",Grading(t).source);
        od;
        if KnowsDictionary(t!.components,arg) then
            return LookupDictionary(t!.components,arg);
        fi;
        v := MutableBasis(k,[],Zero(t));
        for i in [1..m] do
            if arg[i]>0 then
                for j in Basis(CallFuncList(Grading(t)!.hom_components,arg-IdentityMat(m)[i])) do
                    j := t.(i)*j;
                    SetDegreeOfHomogeneousElement(j,arg);
                    CloseMutableBasis(v,j);
                od;
            fi;
        od;
        v := VectorSpace(k, BasisVectors(v), Zero(t), "basis");
        AddDictionary(t!.components,arg,v);
        return v;
    end));
    return t;
end);
#############################################################################

#############################################################################
# Grigorchuk's thinned algebra
#
InstallGlobalFunction(GrigorchukThinnedAlgebra, function(k)
    local a, i, g;

    if IsPosInt(k) then k := GF(k); fi;

    a := ThinnedAlgebraWithOne(k,GrigorchukGroup);
    SetDimension(a,infinity);
    if Characteristic(k)=2 then
        g := GeneratorsOfAlgebraWithOne(a);
        a!.components := [SubmoduleNC(a,[One(a)],"basis")];
        SetDegreeOfHomogeneousElement(One(a),0);
        i := VectorSpace(k,g-One(a));
        Add(a!.components, SubmoduleNC(a,Basis(i)));
        for i in Basis(a!.components[2]) do
            SetDegreeOfHomogeneousElement(i,1);
        od;
        SetGrading(a, rec(source := Integers,
                                    min_degree := 0, max_degree := infinity,
                                    hom_components := function(n)
            local i, j;
            for i in [2..n] do if not IsBound(a!.components[i+1]) then
                a!.components[i+1] := ProductSpace(a!.components[i],a!.components[2]);
                for j in Basis(a!.components[i+1]) do
                    SetDegreeOfHomogeneousElement(j,i);
                od;
            fi; od;
            return a!.components[n+1];
        end));
        SetBranchingIdeal(a,TwoSidedIdealByGenerators(a,[g[2]*g[1]-g[1]*g[2],(One(a)+g[1]*g[2])*(One(a)+g[1]), (g[4]+g[1]*g[3])*(One(a)+g[1])]));
    fi;
    return a;
end);

InstallGlobalFunction(GuptaSidkiThinnedAlgebra, function(k)
    local a, g;

    if IsPosInt(k) then k := GF(k); fi;

    a := THINNEDALGEBRAWITHONE@(k,GuptaSidkiGroup,GeneratorsOfGroup(GuptaSidkiGroup));
    return a;
end);

InstallGlobalFunction(GuptaSidkiLieAlgebra, function(k)
    local a, g;

    if IsPosInt(k) then k := GF(k); fi;

    a := FRAlgebraWithOne(k,"a=[[0,1,0],[0,0,1],[0,0,0]]:0",
                 "t=[[0,0,0],[a,0,0],[-t,-a,0]]:0");
    if Characteristic(k)=3 then
        a!.components := [[SubmoduleNC(a,[One(a)],"basis"),
                           SubmoduleNC(a,[a.2],"basis")],
                          [SubmoduleNC(a,[a.1],"basis")]];
        SetDegreeOfHomogeneousElement(One(a),[0,0]);
        SetDegreeOfHomogeneousElement(a.1,[1,0]);
        SetDegreeOfHomogeneousElement(a.2,[0,1]);
        SetGrading(a, rec(source := Integers^2,
                                    hom_components := function(i,j)
            local u, v;
            if i<0 or j<0 then
                return SubmoduleNC(a,[]);
            fi;
            if not IsBound(a!.components[i+1]) then
                a!.components[i+1] := [];
            fi;
            if not IsBound(a!.components[i+1][j+1]) then
                u := Basis(Grading(a).hom_components(i-1,j));
                v := Basis(Grading(a).hom_components(i,j-1));
                u := Basis(VectorSpace(k,Concatenation(u*a.1,v*a.2)));
                for v in u do
                    SetDegreeOfHomogeneousElement(v,[i,j]);
                od;
                a!.components[i+1][j+1] := SubmoduleNC(a,u,"basis");
            fi;
            return a!.components[i+1][j+1];
        end));
    fi;
    return a;
end);

InstallGlobalFunction(GrigorchukLieAlgebra, function(k)
    local a, g;

    if IsPosInt(k) then k := GF(k); fi;

    a := FRAlgebraWithOne(k,"a=[[0,1],[0,0]]:0","b=[[0,0],[a+c,0]]:0",
                 "c=[[0,0],[a+d,0]]:0","d=[[0,0],[b,0]]:0");
    if Characteristic(k)=2 then
        a!.components := [SubmoduleNC(a,[One(a)],"basis"),
                          SubmoduleNC(a,[a.1,a.2,a.3],"basis")];
        SetDegreeOfHomogeneousElement(One(a),0);
        SetDegreeOfHomogeneousElement(a.1,1);
        SetDegreeOfHomogeneousElement(a.2,1);
        SetDegreeOfHomogeneousElement(a.3,1);
        SetDegreeOfHomogeneousElement(a.4,1);
        SetGrading(a, rec(source := Integers,
                                    min_degree := 0, max_degree := infinity,
                                    hom_components := function(i)
            local u, v;
            if i<0 then
                return SubmoduleNC(a,[]);
            fi;
            if not IsBound(a!.components[i+1]) then
                u := Basis(Grading(a).hom_components(i-1));
                u := Basis(VectorSpace(k,Concatenation(u*a.1,u*a.2,u*a.3)));
                for v in u do
                    SetDegreeOfHomogeneousElement(v,i);
                od;
                a!.components[i+1] := SubmoduleNC(a,u,"basis");
            fi;
            return a!.components[i+1];
        end));
    fi;
    return a;
end);

InstallGlobalFunction(SidkiFreeAlgebra, function(k)
    if IsPosInt(k) then k := GF(k); fi;

    return FRAlgebraWithOne(k,"s=[[1,0],[0,2*s]]","t=[[0,2*s],[0,2*t]]:0");
end);

InstallGlobalFunction(SidkiMonomialAlgebra, function(k)
    local a;
    if IsPosInt(k) then k := GF(k); fi;

    a := FRAlgebraWithOne(k,"s=[[0,0],[1,0]]:0","t=[[0,t],[0,s]]:0");
    a!.components := [SubmoduleNC(a,[One(a)]),SubmoduleNC(a,[a.1,a.2])];
    SetDegreeOfHomogeneousElement(One(a),0);
    SetDegreeOfHomogeneousElement(a.1,1);
    SetDegreeOfHomogeneousElement(a.2,1);
    SetGrading(a, rec(source := Integers,
                                min_degree := 0, max_degree := infinity,
                                hom_components := function(n)
        local i, j;
        for i in [2..n] do if not IsBound(a!.components[i+1]) then
            a!.components[i+1] := ProductSpace(a!.components[i],a!.components[2]);
            for j in Basis(a!.components[i+1]) do
                SetDegreeOfHomogeneousElement(j,i);
            od;
        fi; od;
        return a!.components[n+1];
    end));
    return a;
end);
#############################################################################

#############################################################################
# a non-finite state automaton suggested by S. Sidki
#
#AlphaElement := FRElement(["alpha"],[[[1],[1,1]]],[(1,2)],[1]);
#
#depth:           0               5
#
#action vector: [ 1, 1, 3, 5, 7, 17, 31, 77, 135, 237, 491, 981, 1935 ]
#
#state growth:  [ 1, 2, 3, 5, 8, 12, 18, 27, 41,  (62,  93, 140,  210) ]
# =A061419; a(1)=1, a(n)=ceil(a(n-1)*3/2)
#############################################################################

#############################################################################
# the "L" group
#
#LGroup := SCGroup(MealyMachine([[1,1],[1,1],[2,1],[2,5],[2,6],[1,4]],[(),(1,2),(),(),(),()]));
#
# let M = < a, c, d >^L.
# let N = < L', ac >^L = < [a,b], ac >^L
#
# L -----> (LxL) wr 2 with image of index 4
# |         |
# |32       |
# |         |
# L'------ L'xL' with L'/(L'xL') = (Z/2)^4
#
# |gamma_n/gamma_n+1| = 32 for all n
#############################################################################

#############################################################################
# the "X" group
#
#XGroup := SCGroup(MealyMachine([[1,1,1,1],[1,1,1,1],[1,1,1,1],[1,1,1,1],[5,2,3,4]],[(),(1,2)(3,4),(1,3)(2,4),(1,4)(2,3),()]));
# G''=gamma_4
# G'''=gamma_9
#############################################################################

#############################################################################
# the "Y" group
#
#YGroup := FRGroup("a=(1,2)","b=(2,3)","c=<c,a,>","d=<d,b,>");
#############################################################################

#############################################################################
# the "sierpinski gasket" group
#
#SGasketGroup := FRGroup("a=<,,a>(1,2)","b=<,b,>(1,3)","c=<c,,>(2,3)");
#
#some relations:
#aa
#bb
#cc
#abcbacababcbabcacbcb
#babcacbcacabacbcacbc
#abacababcbacabacacbc
#abacabcbabacabacbcac
#abacabcbabcbcacbabcb
#abacacbcacbabcbcacbc
#############################################################################

#############################################################################
# the "sierpinski carpet" group
#
#SCarpetGroup := FRGroup("a=<d,>","b=<z^-1,a*z>(1,2)","c=<,b>","d=<,c>",
#                        "x=<z,>","y=<d*x,d^-1>(1,2)","z=<,y>");
#
#IsOne(G.4*G.5*G.2*G.6*G.3*G.1*G.7)
#
#List([1..8],i->LogInt(Size(PermGroup(SCarpetGroup,i)),2));
#[ 1, 3, 7, 15, 31, 63, 126, 252, 504 ]
#
#l := LowerCentralSeries(PermGroup(SCarpetGroup,8));
#List([1..Length(l)-1],i->AbelianInvariants(l[i]/l[i+1]));
#[ [ 2^4, 4^2 ], [ 2^4, 4 ], 5, 5, 5, 5, 5, 8*4, 16*3, 32*2, 64*1 ]
#############################################################################

#############################################################################
# a fake SL2 group
#
#SL2M := FRMachine([[[1],[2],[3],[],[],[]],[[],[],[],[-2],[-3],[-1]],[[],[],[],[],[],[]]],[(1,6)(2,4)(3,5),(1,2,3)(4,6,5),(1,5)(2,6)(3,4)]);
#act := n->Group(Activity(FRElementNC(SL2M,[2]),n),Activity(FRElementNC(SL2M,[-2]),n),Activity(FRElementNC(SL2M,[3]),n));
#u := FRElementNC(SL2M,[2]);
#v := FRElementNC(SL2M,[3]);
#p := u*v;
#q := u^-1*v;
#IsOne((p^5*q^2*p^3*q^2*p*q^2)^2); # a relation that should not exist
#############################################################################

#E examples.gi. . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
