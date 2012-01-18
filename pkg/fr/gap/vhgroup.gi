#############################################################################
##
#W vhgroup.gi                                               Laurent Bartholdi
##
#H   @(#)$Id: vhgroup.gi,v 1.15 2011/09/20 11:45:34 gap Exp $
##
#Y Copyright (C) 2007, Laurent Bartholdi
##
#############################################################################
##
##  This file implements the category of VH groups
##
#############################################################################

Info(InfoFR,2,"Added method for IsQuasiprimitive(PermutationGroup,Set)");
InstallTrueMethod(IsQuasiPrimitive, IsPrimitive);
InstallOtherMethod(IsQuasiPrimitive, "(FR) for a permutation group and a set",
        [IsPermGroup, IsObject],
        function(G,X)
    return ForAll(MinimalNormalSubgroups(G),N->IsTransitive(N,X));
end);

#############################################################################
##
#M VHStructure
##
BindGlobal("VHSTRUCTURE@", function(result,r,v,h)
    local i, m, n, getv, geth, addrel;

    m := Length(v);
    n := Length(h);
    getv := function(x)
        if x<0 then return 2*m+1-Position(v,-x); else
            return Position(v,x);
        fi;
    end;
    geth := function(x)
        if x<0 then return 2*n+1-Position(h,-x); else
            return Position(h,x);
        fi;
    end;
    result.transitions := List([1..2*m],i->[]);
    result.output := List([1..2*m],i->[]);
    addrel := function(a,b,c,d)
        if IsBound(result.transitions[a][b]) and (result.transitions[a][b]<>c or result.output[a][b]<>d) then
            return true;
        fi;
        result.transitions[a][b] := c;
        result.output[a][b] := d;
        return false;
    end;
    for i in r do
        if addrel(getv(i[1]),geth(-i[4]),getv(-i[3]),geth(i[2])) then
            return fail;
        fi;
        if addrel(getv(-i[1]),geth(i[2]),getv(i[3]),geth(-i[4])) then
            return fail;
        fi;
        if addrel(getv(i[3]),geth(-i[2]),getv(-i[1]),geth(i[4])) then
            return fail;
        fi;
        if addrel(getv(-i[3]),geth(i[4]),getv(i[1]),geth(-i[2])) then
            return fail;
        fi;
    od;
    if Set(result.transitions,Length)<>[2*n] or Set(result.output,Length)<>[2*n] then
        return fail;
    fi;
    return true;
end);

InstallMethod(VHStructure, "for a f.p. group",
        [IsFpGroup],
        function(G)
    local i, v, h, r, result;

    v := [];
    h := [];
    r := [];
    for i in RelatorsOfFpGroup(G) do
        i := LetterRepAssocWord(i);
        if Length(i)<>4 then TryNextMethod(); fi;
        if AbsInt(i[2]) in v then
            i := i{[2,3,4,1]};
        fi;
        AddSet(v,AbsInt(i[1]));
        AddSet(h,AbsInt(i[2]));
        AddSet(v,AbsInt(i[3]));
        AddSet(h,AbsInt(i[4]));
        Add(r,i);
    od;
    if Intersection(v,h)<>[] then TryNextMethod(); fi;
    result := rec(v := GeneratorsOfGroup(G){v},
                  h := GeneratorsOfGroup(G){h});
    if VHSTRUCTURE@(result,r,v,h)=fail then
        TryNextMethod();
    fi;
    SetVHStructure(FamilyObj(One(G)),result);
    SetReducedMultiplication(G);
    return result;
end);

InstallMethod(ViewString, "for a VH group",
        [IsVHGroup], 10,
        function(G)
    local s, t;
    s := String(VHStructure(G).v);
    t := String(VHStructure(G).h);
    return Concatenation("<VH group on the generators ",s{[1..Length(s)-1]},"|",t{[2..Length(t)]},">");
end);
INSTALLPRINTERS@(IsVHGroup);

InstallMethod(FpElementNFFunction, "for a VH group",
        [IsElementOfFpGroupFamily and HasVHStructure],
        function(gfam)
    local r, vgens, hgens, rels, mfam, mffam, gffam, mon,
	i, j, m, n, g2m, m2g, rws, shift;
    r := VHStructure(gfam);
    gffam := FamilyObj(UnderlyingElement(Representative(CollectionsFamily(gfam)!.wholeGroup)));
    vgens := [];
    for i in r.v do Add(vgens,String(i)); od;
    for i in Reversed(r.v) do Add(vgens,CONCAT@(i,"^-1")); od;
    for i in r.h do Add(vgens,String(i)); od;
    for i in Reversed(r.h) do Add(vgens,CONCAT@(i,"^-1")); od;
    mon := FreeMonoid(vgens);
    mffam := FamilyObj(Representative(mon));
    m := Length(r.v);
    n := Length(r.h);
    vgens := GeneratorsOfMonoid(mon){[1..2*m]};
    hgens := GeneratorsOfMonoid(mon){2*m+[1..2*n]};
    rels := [];
    for i in [1..2*m] do Add(rels,[vgens[i]*vgens[2*m+1-i],One(mon)]); od;
    for i in [1..2*n] do Add(rels,[hgens[i]*hgens[2*n+1-i],One(mon)]); od;
    for i in [1..2*m] do
        for j in [1..2*n] do
	    Add(rels,[hgens[j]*vgens[r.transitions[i][j]],vgens[i]*hgens[r.output[i][j]]]);
	od;
    od;
    rws := KnuthBendixRewritingSystem(FactorFreeMonoidByRelations(mon,rels),ShortLexOrdering(mffam));
    SetIsConfluent(rws,true);
    SetIsReduced(rws,true);
    rws!.reduced := true;
    g2m := Concatenation(2*m+n+[1..n],m+[1..m],[0],[1..m],2*m+[1..n]);
    shift := m+n+1;
    m2g := Concatenation([1..m],[-m..-1],m+[1..n],-m+[-n..-1]);

    return x->AssocWordByLetterRep(gffam,m2g{LetterRepAssocWord(ReducedForm(rws,AssocWordByLetterRep(mffam,g2m{LetterRepAssocWord(x)+shift})))});
end);
#############################################################################

#############################################################################
##
#M StructuralGroup
#M StructuralSemigroup
#M StructuralMonoid
##
InstallMethod(StructuralGroup, "(FR) for a Mealy machine",
        [IsMealyMachine],
        function(M)
    local ggens, wgens, f, fggens, fwgens, phi, r, i, j, m, n, t, o;
    if IsSubset(Integers,StateSet(M)) then
        ggens := List(StateSet(M),i->WordAlp("abcdefgh",i));
    else
        ggens := List(StateSet(M),String);
    fi;
    n := Size(AlphabetOfFRObject(M));
    f := FreeGroup(Concatenation(ggens,List(AlphabetOfFRObject(M),String)));
    fggens := GeneratorsOfGroup(f){[1..Length(ggens)]};
    fwgens := GeneratorsOfGroup(f){Length(ggens)+[1..n]};
    f := f / List(Cartesian([1..Length(ggens)],AlphabetOfFRObject(M)),
                 p->fggens[p[1]]*fwgens[Output(M,p[1],p[2])]/fggens[Transition(M,p[1],p[2])]/fwgens[p[2]]);
    if IsMealyMachineIntRep(M) and IsBireversible(M) then
        m := Length(M!.transitions);
        r := rec(v := GeneratorsOfGroup(f){[1..Length(ggens)]},
                 h := GeneratorsOfGroup(f){Length(ggens)+[1..n]},
                 transitions := List([1..2*m],i->[]),
                 output := List([1..2*m],i->[]));
        for i in [1..m] do
            for j in [1..n] do
                t := M!.transitions[i][j];
                o := M!.output[i][j];
                r.transitions[i][j] := t; r.output[i][j] := o;
                r.transitions[2*m+1-t][j] := 2*m+1-i; r.output[2*m+1-t][j] := o;
                r.transitions[i][2*n+1-o] := t; r.output[i][2*n+1-o] := 2*n+1-j;
                r.transitions[2*m+1-t][2*n+1-o] := 2*m+1-i; r.output[2*m+1-t][2*n+1-o] := 2*n+1-j;
            od;
        od;
        SetVHStructure(f,r);
        SetVHStructure(FamilyObj(One(f)),r);
        SetReducedMultiplication(f);
    fi;
    return f;
end);

InstallMethod(StructuralMonoid, "(FR) for a monoid FR machine",
        [IsMealyMachine],
        function(M)
    local ggens, wgens, f, fggens, fwgens, phi;
    if IsSubset(Integers,StateSet(M)) then
        ggens := List(StateSet(M),i->WordAlp("abcdefgh",i));
    else
        ggens := List(StateSet(M),String);
    fi;
    f := FreeMonoid(Concatenation(ggens,List(AlphabetOfFRObject(M),String)));
    fggens := GeneratorsOfMonoid(f){[1..Length(ggens)]};
    fwgens := GeneratorsOfMonoid(f){[Length(ggens)+1..Length(ggens)+Size(AlphabetOfFRObject(M))]};
    return f / List(Cartesian([1..Length(ggens)],AlphabetOfFRObject(M)),
                   p->[fggens[p[1]]*fwgens[Output(M,p[1],p[2])],fwgens[p[2]]*fggens[Transition(M,p[1],p[2])]]);
end);

InstallMethod(StructuralSemigroup, "(FR) for a semigroup FR machine",
        [IsMealyMachine],
        function(M)
    local ggens, wgens, f, fggens, fwgens, phi;
    if IsSubset(Integers,StateSet(M)) then
        ggens := List(StateSet(M),i->WordAlp("abcdefgh",i));
    else
        ggens := List(StateSet(M),String);
    fi;
    f := FreeSemigroup(Concatenation(ggens,List(AlphabetOfFRObject(M),String)));
    fggens := GeneratorsOfSemigroup(f){[1..Length(ggens)]};
    fwgens := GeneratorsOfSemigroup(f){[Length(ggens)+1..Length(ggens)+Size(AlphabetOfFRObject(M))]};
    return f / List(Cartesian([1..Length(ggens)],AlphabetOfFRObject(M)),
                   p->[fggens[p[1]]*fwgens[Output(M,p[1],p[2])],fwgens[p[2]]*fggens[Transition(M,p[1],p[2])]]);
end);
#############################################################################

#############################################################################
##
#M VerticalAction
#M HorizontalAction
##
InstallMethod(VerticalAction, "for a VH group",
        [IsVHGroup],
        function(G)
    local r, m;
    r := VHStructure(G);
    m := MealyMachine(r.transitions,r.output);
    SetAlphabetInvolution(m,[2*Length(r.h),2*Length(r.h)-1..1]);
    return GroupHomomorphismByImagesNC(Subgroup(G,r.v),SCGroup(m),
                   r.v,List([1..Length(r.v)],x->FRElement(m,x)));
end);

InstallMethod(HorizontalAction, "for a VH group",
        [IsVHGroup],
        function(G)
    local r, m;
    r := VHStructure(G);
    m := MealyMachine(TransposedMat(r.output),TransposedMat(r.transitions));
    SetAlphabetInvolution(m,[2*Length(r.v),2*Length(r.v)-1..1]);
    return GroupHomomorphismByImagesNC(Subgroup(G,r.h),SCGroup(m),
                   r.h,List([1..Length(r.h)],x->FRElement(m,x)));
end);
#############################################################################

#############################################################################
##
#F VHGroup
##
InstallGlobalFunction(VHGroup, function(arg)
    local l, i, m, n, v, h, r, f, addset;
    if Length(arg)=1 and IsList(arg[1]) then
        l := arg[1];
    else
        l := arg;
    fi;
    m := Maximum(List(l,x->Maximum(AbsInt(x[1]),AbsInt(x[3]))));
    n := Maximum(List(l,x->Maximum(AbsInt(x[2]),AbsInt(x[4]))));
    r := [];
    addset := function(p)
        if p in r then
            Error("Corner ",p," occurs too many times");
        fi;
        AddSet(r,p);
    end;
    for i in l do
        if Length(i)<>4 then
            Error("Bad length of relator ",i);
        fi;
        addset([i[1],i[2]]);
        addset([i[3],i[4]]);
        addset([-i[1],-i[4]]);
        addset([-i[3],-i[2]]);
    od;
    if Length(l)<>m*n or ForAny(l,x->0 in x) then
        Error("Missing corners ",Difference(Cartesian(Concatenation([-m..-1],[1..m]),Concatenation([-n..-1],[1..n])),r));
    fi;
    v := List([1..m],i->CONCAT@("a",i));
    h := List([1..n],i->CONCAT@("b",i));
    f := FreeGroup(Concatenation(v,h));
    v := GeneratorsOfGroup(f){[1..m]};
    h := GeneratorsOfGroup(f){[m+1..m+n]};
    f := f / List(l,x->v[AbsInt(x[1])]^SignInt(x[1])*h[AbsInt(x[2])]^SignInt(x[2])*v[AbsInt(x[3])]^SignInt(x[3])*h[AbsInt(x[4])]^SignInt(x[4]));
    i := rec(v := GeneratorsOfGroup(f){[1..m]},
             h := GeneratorsOfGroup(f){[m+1..m+n]});
    VHSTRUCTURE@(i,l,[1..m],[1..n]);
    SetVHStructure(f,i);
    SetVHStructure(FamilyObj(One(f)),i);
    SetReducedMultiplication(f);
    return f;
end);
#############################################################################

#############################################################################
##
#M methods for VH groups
##
InstallMethod(IsSQUniversal, "(FR) for a VH group",
        # by [Rattaggi's PhD, pages 31 and 89]
        [IsVHGroup],
        function(G)
    local v, h;
    v := Range(VerticalAction(G));
    v := Transitivity(VertexTransformations(v),AlphabetOfFRSemigroup(v));
    h := Range(HorizontalAction(G));
    v := Transitivity(VertexTransformations(h),AlphabetOfFRSemigroup(h));
    if v>=1 and h>=1 then
        return v<=1 or h<=1;
    fi;
    TryNextMethod();
end);

InstallMethod(IsIrreducibleVHGroup, "(FR) for a VH group",
        # by [BM3, Proposition 1.3]
        [IsVHGroup],
        function(G)
    local act, q;
    act := [Range(VerticalAction(G)),Range(HorizontalAction(G))];
    if not ForAll(act,x->IsTransitive(VertexTransformations(x),AlphabetOfFRSemigroup(x))) then
        return false;
    fi;
    if not ForAll(act,x->IsPrimitive(VertexTransformations(x),AlphabetOfFRSemigroup(x))) then
        TryNextMethod();
    fi;
    for q in act do
        if not IsPGroup(EDGESTABILIZER@(q)) then return true; fi;
    od;
    if ForAny(act,IsFinite) then return false; fi;
    TryNextMethod();
end);

InstallMethod(LambdaElementVHGroup, "(FR) for a VH group",
        [IsVHGroup],
        function(G)
    local act, pi, iter, trans, clock, i, x, y;
    act := [VerticalAction(G),HorizontalAction(G)];
    trans := Filtered([1,2],i->IsInfinitelyTransitive(Range(act[i])));
    if trans=[] then
        return fail;
    fi;
    pi := List(act,x->EpimorphismFromFreeGroup(Source(x)));
    for i in [1..2] do
        act[i] := GroupHomomorphismByImages(Source(pi[i]),Range(act[i]),
                          GeneratorsOfGroup(Source(pi[i])),GeneratorsOfGroup(Range(act[i])));
    od;
    iter := List(pi,x->Iterator(Source(x)));
    clock := 0;
    for i in PeriodicList([],trans) do
        x := NextIterator(iter[i]);
        y := x^pi[i];
        if IsOne(y) then continue; fi;
        if IsOne(x^act[i]) then
            return [i,x];
        fi;
        clock := clock+1;
        if clock mod 1000=0 then
            Info(InfoFR, 2, "FindLambdaElement: looped ",clock/1000,"k times");
        fi;
    od;
    #!!! this command never returns fail here!
end);

InstallMethod(IsResiduallyFinite, "(FR) for a VH group",
        # by [BM3, Proposition 2.1]
        [IsVHGroup],
        function(G)
    local l;
    l := LambdaElementVHGroup(G);
    if l=fail then
        TryNextMethod();
    fi;
    return false;
end);

InstallMethod(IsJustInfinite, "(FR) for a VH group",
        [IsVHGroup],
        function(G)
    if IsFinite(G) then
        return false;
    fi;
    if IsVirtuallySimpleGroup(G) then
        return true;
    fi;
    TryNextMethod();
end);

InstallMethod(IsVirtuallySimpleGroup, "(FR) for a VH group",
        [IsVHGroup],
        function(G)
    local l, q;
    if IsResiduallyFinite(G) then
        return false;
    fi;
    l := LambdaElementVHGroup(G);
    q := FreeGroupOfFpGroup(G) / Concatenation(RelatorsOfFpGroup(G),[l]);
    return IsFinite(q);
end);

InstallMethod(MaximalSimpleSubgroup, "(FR) for a VH group",
        [IsVHGroup],
        function(G)
    local l, q;
    if IsResiduallyFinite(G) then
        return fail;
    fi;
    l := LambdaElementVHGroup(G);
    q := FreeGroupOfFpGroup(G) / Concatenation(RelatorsOfFpGroup(G),[l]);
    return Kernel(GroupHomomorphismByImagesNC(G,q,GeneratorsOfGroup(G),GeneratorsOfGroup(q)));
end);
#############################################################################

#############################################################################
##
#M methods for FR groups
##
InstallMethod(IsInfinitelyTransitive, "(FR) for an FR group",
        [IsFRGroup],
        function(G)
    local M, q, s;
    if not HasUnderlyingFRMachine(G) then TryNextMethod(); fi;
    M := UnderlyingFRMachine(G);
    if not IsBireversible(M) then TryNextMethod(); fi;
    
    # first see if the top group is 2-transitive, and has sufficient
    # transitivity in its 2-neighbourhood (see [Rattaggi, Prop. 1.2(3a)])
    if Transitivity(VertexTransformations(G),AlphabetOfFRSemigroup(G))>=2 and
       not IsSolvable(Stabilizer(VertexTransformations(G),1)) then
        Info(InfoFR,3, "IsInfinitelyTransitive: testing non-solvability of edge stabilizers");
        return not IsSolvable(EDGESTABILIZER@(G));
    fi;
    if not HasAlphabetInvolution(M) then
        return IsLevelTransitive(G);
    fi;
    # try to find an element fixing an infinite ray, and acting transitively on the sphere of radius 1 (except that ray's beginning)
    Info(InfoFR,3, "IsInfinitelyTransitive: looking for transitive element");
    for q in G do
        s := FixedRay(q);
        if s<>fail and IsTransitive(Group(q),Difference(AlphabetOfFRSemigroup(G),[s[1]])) then
            return true;
        fi;
    od;
    Error("Should not be reached!");
end);

BindGlobal("MEALY2WORD@", function(x,g,h)
    local stack, seen, work, i, nx, nw, n, time;
    if IsOne(x) then
        return One(h[1]);
    fi;
    if not ForAll(g,x->IsOne(x^2)) then
        g := Concatenation(g,List(g,Inverse));
        h := Concatenation(h,List(h,Inverse));
    fi;
    seen := NewDictionary(x,false);
    stack := [];
    stack[x!.nrstates] := [[x,One(h[1])]];
    time := 0;
    while true do
        if ForAll(stack,IsEmpty) then
            return fail;
        fi;
        work := Remove(First(stack,x->x<>[]));
        time := time+1;
        if time mod 1000 = 0 then
            Info(InfoFR,1,"MEALY2WORD@: considering now a Mealy machine on ",work[1]!.nrstates, " states");
        fi;
        AddDictionary(seen,work[1]);
        for i in [1..Length(g)] do
            nx := work[1]/g[i];
            if KnowsDictionary(seen,nx) then continue; fi;
            nw := h[i]*work[2];
            if IsOne(nx) then
                return nw;
            fi;
            n := 0*Length(nw)+nx!.nrstates;
            if not IsBound(stack[n]) then stack[n] := []; fi;
            Add(stack[n],[nx,nw]);
        od;
    od;
end);

InstallTrueMethod(IsLevelTransitiveOnPatterns, IsInfinitelyTransitive);

InstallMethod(IsomorphismFpGroup, "(FR) for an FR group",
        [IsFRGroup],
        function(G)
    local m, mm, f, g, h;
    if not HasUnderlyingFRMachine(G) then
        TryNextMethod();
    fi;
    m := UnderlyingFRMachine(G);
    if not IsBireversible(m) then
        TryNextMethod();
    fi;
    m := Minimized(m+m^-1);
    if IsLevelTransitiveOnPatterns(SCGroup(m)) then
        f := FreeGroup(m!.nrstates)/[];
        g := m{StateSet(m)};
        h := GeneratorsOfGroup(f);
        SortParallel(g,h);
        return GroupHomomorphismByFunction(G,f,x->MEALY2WORD@(x,g,GeneratorsOfGroup(f)),w->MappedWord(w,GeneratorsOfGroup(f),g));
    fi;
    TryNextMethod();
end);
#############################################################################

#############################################################################
##
#E GammaPQMachine
#E GammaPQGroup
##
BindGlobal("QUATERNIONBASIS@", fail); # must be computed only at run-time

BindGlobal("QUATERNIONNORMP@", function(p)
    local a, b, c, d, bound, result, x, y, z;
    
    if not IsPrime(p) then
        Error("Argument ",p," should be prime");
    fi;
    bound := 2*RootInt(QuoInt(p,4));
    result := [];
    if p mod 4 = 1 then
        x := [1,3..bound+1];
        y := [-bound,2-bound..bound];
        z := y;
    elif p mod 8 = 3 or p mod 8 = 7 then
        x := [1,3..bound+1];
        y := [-bound,2-bound..bound];
        z := [-1-bound,1-bound..bound+1];
    fi;
    for a in x do
        for b in y do
            if (a=0 and b<0) or a^2+b^2>p then continue; fi;
            for c in z do
                if a^2+b^2+c^2>p then continue; fi;
                d := RootInt(p-a^2-b^2-c^2);
                if a^2+b^2+c^2+d^2=p then
                    Add(result,[a,b,c,d]*QUATERNIONBASIS@);
                    if d<>0 then
                        Add(result,[a,b,c,-d]*QUATERNIONBASIS@);
                    fi;
                fi;
            od;
        od;
    od;
    return result;
end);

#qconj := function(q)
#    local c;
#    c := Coefficients(QUATERNIONBASIS@,q);
#    return [c[1],-c[2],-c[3],-c[4]]*QUATERNIONBASIS@;
#end;

#qnorm := function(q)
#    return Coefficients(QUATERNIONBASIS@,q)^2;
#end;

BindGlobal("QUATERNIONFACTOR@", function(q,l)
    local result, i, j, p, qq;
    result := [];
    for i in l do
        p := Coefficients(QUATERNIONBASIS@,i[1])^2;
        for j in [1..Length(i)] do
            qq := Inverse(i[j])*q;
            if ForAll(Coefficients(QUATERNIONBASIS@,qq),IsInt) then
                q := qq;
                Add(result,j);
                break;
            fi;
        od;
        if not ForAll(Coefficients(QUATERNIONBASIS@,qq),IsInt) then
            return fail;
        fi;
    od;
    if not IsOne(q) and not IsOne(-q) then return fail; fi;
    return result;
end);

InstallGlobalFunction(GammaPQMachine, function(p,q)
    local i, j, k, pset, qset, trans, out;

    if QUATERNIONBASIS@=fail then
        MakeReadWriteGlobal("QUATERNIONBASIS@FR");
        QUATERNIONBASIS@ := Basis(QuaternionAlgebra(Rationals));
        MakeReadOnlyGlobal("QUATERNIONBASIS@FR");
    fi;

    pset := QUATERNIONNORMP@(p);
    qset := QUATERNIONNORMP@(q);
    trans := List(pset,x->[]);
    out := List(pset,x->[]);
    for i in [1..p+1] do
        for j in [1..q+1] do
            k := QUATERNIONFACTOR@(pset[i]*qset[j],[qset,pset]);
            out[i][k[1]] := j;
            trans[i][k[1]] := k[2];
        od;
    od;
    i := MealyMachine(trans,out);
    SetName(i,CONCAT@("GammaPQMachine(",p,",",q,")"));
    SetCorrespondence(i,[pset,qset]);
    out := [];
    for j in qset do
        j := q/j;
        k := Position(qset,j);
        if k=fail then
            Add(out,Position(qset,-j));
        else
            Add(out,k);
        fi;
    od;
    SetAlphabetInvolution(i,out);
    return i;
end);

InstallGlobalFunction(GammaPQGroup, function(p,q)
    local g, a;
    g := StructuralGroup(GammaPQMachine(p,q));
    for a in [VerticalAction(g),HorizontalAction(g)] do
        SetIsInfinitelyTransitive(Range(a),true);
        SetIsResiduallyFinite(Range(a),true);
    od;
    return g;
end);
#############################################################################

#############################################################################
##
#E RattaggiGroup
##
InstallValue(RattaggiGroup,
        rec(2_2 := VHGroup([1,1,-1,-1],[1,2,-1,-3],[1,3,2,-2],
                           [1,-3,-3,2],[2,1,-3,-2],[2,2,-3,-3],
                           [2,3,-3,1],[2,-3,3,2],[2,-1,-3,-1]),
                   # THM 2.3: (A6,A6), just infinite, irreducible
                   # CONJ 2.5: G0 is simple
                   2_15 := VHGroup([1,1,-1,-2],[1,2,-2,1],[1,3,-1,3],
                           [1,-2,2,-1],[2,1,-3,-3],[2,2,-3,3],
                           [2,3,-3,2],[2,-3,-3,1],[3,1,3,2]),
                   # THM 2.16: (A6,A6), just infinite, irreducible
                   # CONJ 2.17: G'' is simple, of index 192
                   2_18 := VHGroup([1,1,-2,-2],[1,2,-1,-1],[1,3,-1,-3],
                           [1,4,-1,-4],[1,5,-1,-6],[1,6,-1,-5],
                           [1,-1,2,2],[2,1,2,-3],[2,3,2,-4],
                           [2,4,-3,-5],[2,5,2,6],[2,-6,2,-2],
                           [2,-5,3,4],[3,1,-3,-2],[3,2,-3,-1],
                           [3,3,3,-6],[3,5,-3,-4],[3,6,3,-3]),
                   # THM 2.19: (A6,M12), just infinite, irreducible
                   # CONJ 2.20: G0 is simple
                   2_21 := VHGroup([1,1,-1,-1],[1,2,-1,-2],[1,3,-1,-4],
                           [1,4,-2,-3],[1,-4,-2,3],[2,1,-2,-2],
                           [2,2,-3,1],[2,3,-2,4],[2,-2,3,-1],
                           [3,1,3,-3],[3,2,3,-4],[3,3,3,4]),
                   # THM 2.22: (A6,S8), just infinite, irreducible
                   # CONJ 2.23: G0 is simple
                   2_26 := VHGroup([1,1,-1,-1],[1,2,-2,-3],[1,3,-1,-4],
                           [1,4,-1,-5],[1,5,-1,-6],[1,6,-1,-2],
                           [1,-2,2,3],[2,1,-2,-5],[2,2,2,-3],
                           [2,4,-2,4],[2,5,-2,-1],[2,6,-2,6]),
                   # THM 2.27: (A4,PSL(2,5)), irreducible, Lambda_2<>1, not residually finite
                   2_30 := VHGroup([1,1,-1,-1],[1,2,-2,-3],[1,3,-1,-4],
                           [1,4,-1,-5],[1,5,-1,-6],[1,6,-1,-2],
                           [1,7,2,-8],[1,8,2,8],[1,-8,2,-7],
                           [1,-7,3,7],[1,-2,2,3],[2,1,-2,-5],
                           [2,2,2,-3],[2,4,-2,4],[2,5,-2,-1],
                           [2,6,-2,6],[2,7,3,-7],[3,1,-3,8],
                           [3,2,-3,2],[3,3,-3,-4],[3,4,-3,1],
                           [3,5,-3,3],[3,6,-3,6],[3,8,-3,5]),
                   # THM 2.31: (A6,A16), virtually simple
                   2_33 := VHGroup([1,1,-1,-1],[1,2,-2,-3],[1,3,-1,-4],
                           [1,4,-1,-5],[1,5,-1,-6],[1,6,-1,-2],
                           [1,7,-2,-7],[1,-7,3,7],[1,-2,2,3],
                           [2,1,-2,-5],[2,2,2,-3],[2,4,-2,4],
                           [2,5,-2,-1],[2,6,-2,6],[2,7,-4,-7],
                           [3,1,4,4],[3,2,-3,-3],[3,3,-4,-2],
                           [3,4,4,7],[3,5,4,-6],[3,6,4,-1],
                           [3,-7,4,1],[3,-6,4,5],[3,-5,4,6],
                           [3,-4,4,-5],[3,-3,4,2],[3,-1,4,-4],
                           [4,3,4,-2]),
                   # THM 2.34: (ASL(3,2),A14), virtually simple
                   # CONJ 2.35: G0 is simple
                   2_36 := VHGroup([1,2,-1,-1],[2,2,-2,-1],[1,3,-2,-3],
                           [1,1,-2,-2],[2,1,-1,-3],[2,3,-1,-2]),
                   # THM 2.37: irreducible, not <b1,b2,b3>-separable
                   2_39 := VHGroup([1,2,-1,-1],[2,2,-2,-1],[1,3,-2,-3],
                           [1,1,-2,-2],[2,1,-1,-3],[2,3,-1,-2],
                           [3,2,-3,-1],[4,2,-4,-1],[3,3,-4,-3],
                           [3,1,-4,-2],[4,1,-3,-3],[4,3,-3,-2]),
                   # THM 2.40: a2/a1*a3/a4 \in N for all finite-index N
                   2_43 := VHGroup([1,1,-2,-2],[1,2,-1,-1],[1,3,-2,-3],
                           [1,4,2,-5],[1,5,-5,4],[1,-5,3,-4],
                           [1,-4,3,5],[1,-3,-2,2],[1,-1,-2,3],
                           [2,2,-2,-1],[2,4,-2,5],[2,5,4,-4],
                           [3,1,-4,-2],[3,2,-3,-1],[3,3,-4,-3],
                           [3,4,4,5],[3,-5,4,4],[3,-3,-4,2],
                           [3,-1,-4,3],[4,2,-4,-1],[4,-5,-5,-4],
                           [5,1,-5,3],[5,2,-5,-5],[5,3,-5,-1],
                           [5,4,-5,-2]),
                   # THM 2.44: (A10,A10), Z(a5)=<a5>, Z(a5^4) \ni b1
                   # THM 2.45: simple subgroup of index 4
                   2_46 := VHGroup([1,1,-2,-2],[1,2,-1,-1],[1,3,-2,-3],
                           [1,4,3,4],[1,-4,2,-4],[1,-3,-2,2],
                           [1,-1,-2,3],[2,2,-2,-1],[2,4,5,4],
                           [3,1,-4,-2],[3,2,-3,-1],[3,3,-4,-3],
                           [3,-4,-4,-4],[3,-3,-4,2],[3,-1,-4,3],
                           [4,2,-4,-1],[4,-4,5,-4],[5,1,-6,2],
                           [5,2,-6,-2],[5,3,-5,-3],[5,-2,-6,-1],
                           [5,-1,-6,1],[6,3,-6,-4],[6,4,-6,3]),
                   # THM 2.47: (M12,A8), G0 is simple
                   2_48 := VHGroup([1,1,-2,-2],[1,2,-1,-1],[1,3,-2,-3],
                           [1,4,2,-4],[1,5,2,-5],[1,6,-4,4],
                           [1,-6,4,6],[1,-5,-2,5],[1,-4,-4,-6],
                           [1,-3,-2,2],[1,-1,-2,3],[2,2,-2,-1],
                           [2,4,-3,-6],[2,6,-3,-4],[2,-6,3,6],
                           [3,1,-4,-2],[3,2,-3,-1],[3,3,-4,-3],
                           [3,4,5,5],[3,5,-4,-4],[3,-5,-4,-5],
                           [3,-3,-4,2],[3,-1,-4,3],[4,2,-4,-1],
                           [4,-4,5,-5],[5,1,-5,-1],[5,2,-5,2],
                           [5,3,-5,5],[5,4,-5,-3],[5,6,-5,6]),
                   # THM 2.49: (A10,A12), simple subgroup of index 12
                   2_50 := VHGroup([1,1,-2,-2],[1,2,-1,-1],[1,3,-2,-3],
                           [1,4,3,4],[1,5,-1,-5],[1,-4,2,-4],
                           [1,-3,-2,2],[1,-1,-2,3],[2,2,-2,-1],
                           [2,4,4,4],[2,5,-5,-5],[2,-5,-5,5],
                           [3,1,-4,-2],[3,2,-3,-1],[3,3,-4,-3],
                           [3,5,4,-4],[3,-5,4,-5],[3,-4,4,5],
                           [3,-3,-4,2],[3,-1,-4,3],[4,2,-4,-1],
                           [5,1,-5,-3],[5,2,-5,-2],[5,3,-5,4],
                           [5,4,-5,1]),
                   # THM 2.51: (A10,10), simple subgroup of index 40
                   2_52 := VHGroup([1,1,-2,-2],[1,2,-1,-1],[1,3,-2,-3],
                           [1,4,1,5],[1,-5,2,-5],[1,-4,-4,-4],
                           [1,-3,-2,2],[1,-1,-2,3],[2,2,-2,-1],
                           [2,4,2,5],[2,-4,-3,-4],[3,1,-4,-2],
                           [3,2,-3,-1],[3,3,-4,-3],[3,5,4,-4],
                           [3,-5,-5,-5],[3,-4,4,5],[3,-3,-4,2],
                           [3,-1,-4,3],[4,2,-4,-1],[4,-5,5,-5],
                           [5,1,5,4],[5,2,-5,3],[5,3,-5,2],
                           [5,-4,5,-1]),
                   # PROP 2.53: (3840,S10), not residually finite, irreducible
                   # THM 2.54: G0 has no f.i. subgroup, not simple
                   2_56 := VHGroup([1,1,-2,-2],[1,2,-1,-1],[1,3,-2,-3],
                           [1,4,-2,4],[1,-4,-2,-4],[1,-3,-2,2],
                           [1,-1,-2,3],[2,2,-2,-1],[3,1,-4,-2],
                           [3,2,-3,-1],[3,3,-4,-3],[3,4,-3,4],
                           [3,-3,-4,2],[3,-1,-4,3],[4,2,-4,-1],
                           [4,4,-4,-4]),
                   # THM 2.57: if w=a2/a1*a3/a4, then G/<w^2> is not residually finite, and not virtually torsion-free.
                   2_58 := VHGroup([1,1,-1,2],[1,2,-2,-3],[1,3,-2,1],
                           [1,4,-2,-5],[1,5,-2,5],[1,-5,-2,-4],
                           [1,-4,2,-1],[1,-3,-2,3],[1,-2,2,4],
                           [2,1,-3,2],[2,2,-3,1],[3,1,3,2],
                           [3,3,-3,-3],[3,4,3,-4],[3,5,-3,5]),
                   # THM 2.59: (A6,S5), SQ-universal, irreducible
                   # CONJ 2.61: intersection of all N = G0
                   # CONJ 2.63: QZ(H2)=1
                   # CONJ 2.65: G/N has (T), for infinite-index non-trivial N
                   # CONJ 2.70: G0 is simple
                   2_70 := VHGroup([1,1,-1,-2],[1,2,-2,-1],[1,3,-2,1],
                           [1,-3,2,3],[1,-2,-2,-3],[2,1,-2,2]),
                   
                   # PROP 3.27: (PGL(2,13),PGL(2,17)), virtually simplex
                   # if V=<1+2i+2j+2k,3+2i,1+4j,3+2i+2j>, then group is V/ZV
                   3_26 := VHGroup([1,1,3,3],[1,2,2,1],[1,3,4,2],
                           [1,4,6,8],[1,5,7,-1],[1,6,5,4],
                           [1,7,-2,-6],[1,8,7,6],[1,9,5,-2],
                           [1,-9,-3,-8],[1,-8,-2,9],[1,-7,6,-3],
                           [1,-6,-4,-7],[1,-5,-4,-4],[1,-4,-3,5],
                           [1,-3,5,-9],[1,-2,7,-5],[1,-1,6,7],
                           [2,2,-3,-3],[2,3,6,-6],[2,4,5,7],
                           [2,5,4,-4],[2,6,6,-1],[2,7,-7,9],
                           [2,9,6,4],[2,-9,4,-8],[2,-8,5,3],
                           [2,-6,3,-7],[2,-5,-7,-2],[2,-4,3,-5],
                           [2,-3,-4,1],[2,-2,5,8],[2,-1,-7,5],
                           [3,1,-4,-2],[3,2,5,-8],[3,5,5,6],
                           [3,6,7,-9],[3,7,-6,-1],[3,8,5,-3],
                           [3,-9,-6,5],[3,-8,4,9],[3,-6,4,7],
                           [3,-4,7,2],[3,-3,-6,-7],[3,-1,7,4],
                           [4,1,7,-4],[4,4,7,-2],[4,8,6,-5],
                           [4,-9,-5,-3],[4,-7,7,8],[4,-6,6,1],
                           [4,-5,-5,-7],[4,-3,6,6],[4,-2,-5,9],
                           [5,1,-5,-1],[5,-7,5,-6],[5,-5,5,-4],
                           [6,2,-6,-2],[6,5,6,-4],[6,-9,6,-8],
                           [7,3,-7,-3],[7,7,7,-6],[7,9,7,-8]),
                   # PROP 3.29: (PGL(2,5),PGL(2,13)), virtually U(H(Z[1/5,1/13])) / ZU
                   3_28 := VHGroup([1,1,3,-6],[1,2,2,7],[1,3,-2,-7],
                           [1,4,1,-1],[1,5,-1,-5],[1,6,3,3],
                           [1,7,-2,-4],[1,-7,2,1],[1,-6,-3,2],
                           [1,-4,-3,6],[1,-3,1,-2],[2,2,-3,-5],
                           [2,3,2,-1],[2,4,3,5],[2,5,-3,-3],
                           [2,6,-2,-6],[2,-5,3,1],[2,-4,2,-2],
                           [3,2,3,-1],[3,7,-3,-7],[3,-4,3,-3]),
                   # PROP 3.32: (PGL(2,3),PSL(2,11))
                   3_31 := VHGroup([1,1,1,-6],[1,2,1,-4],[1,3,1,6],
                           [1,4,-2,-3],[1,5,-1,-5],[1,-3,-2,4],
                           [1,-2,2,-1],[1,-1,2,-2],[2,1,2,-3],
                           [2,2,2,-5],[2,4,2,5],[2,6,-2,-6]),
                   # PROP 3.34: (PGL(2,3),PGL(2,7))
                   3_33 := VHGroup([1,1,-2,-2],[1,2,-1,3],[1,3,-2,-4],[1,4,1,-1],
                           [1,-4,2,2],[1,-3,2,1],[2,3,2,-2],[2,4,-2,1]),
                   # PROP 3.37: (PGL(2,7),PGL(2,5))
                   # aut(X)=S4
                   3_36 := VHGroup([1,1,3,-3],[1,2,4,-2],[1,3,-4,2],[1,-3,4,3],
                           [1,-2,2,1],[1,-1,4,-1],[2,2,-3,-3],[2,3,4,1],
                           [2,-3,3,3],[2,-2,3,2],[2,-1,3,-1],[3,1,4,2]),
                   # PROP 3.39: (PGL(2,7),PGL(2,13))
                   3_38 := VHGroup([1,1,1,-5],[1,2,4,3],[1,3,-1,-2],[1,4,4,-1],
                           [1,5,2,6],[1,6,-2,-3],[1,7,3,5],[1,-7,-3,-4],
                           [1,-6,-4,-7],[1,-4,-2,-6],[1,-2,-3,7],[1,-1,4,4],
                           [2,1,-2,4],[2,2,2,-5],[2,3,-4,7],[2,5,4,-7],
                           [2,7,-3,-6],[2,-7,-4,-1],[2,-4,3,1],[2,-3,3,-2],
                           [2,-2,3,-3],[3,3,3,-5],[3,4,-3,1],[3,6,-4,2],
                           [3,-6,4,5],[3,-1,-4,-6],[4,2,-4,-3],[4,-5,4,-4]),
                   # PROP 3.41: (PGL(2,7),PGL(2,17))
                   3_40 := VHGroup([1,1,2,4],[1,2,4,8],[1,3,3,6],[1,4,2,2],
                           [1,5,4,-6],[1,6,3,1],[1,7,-3,-2],[1,8,4,3],
                           [1,9,3,-4],[1,-9,-4,-1],[1,-8,3,-5],[1,-7,2,-8],
                           [1,-6,2,-9],[1,-5,-2,-3],[1,-4,4,7],[1,-3,-2,5],
                           [1,-2,-3,-7],[1,-1,-4,9],[2,1,-4,7],[2,6,-3,-4],
                           [2,7,-4,-3],[2,8,3,-1],[2,9,-3,2],[2,-7,-3,5],
                           [2,-6,4,-2],[2,-5,-4,-9],[2,-4,-4,8],[2,-3,-3,9],
                           [2,-2,4,6],[2,-1,3,-8],[3,4,4,-3],[3,5,-4,1],
                           [3,8,-4,-6],[3,9,-4,-7],[3,-3,4,-4],[3,-2,-4,5]),
#                   # PROP 3.43: virtually torsion-free
#                   3_42 := VHGroup([1,1,1,1],[1,2,1,2],[1,3,1,3],
#                           [1,-3,4,-2],[1,-2,2,-1],[1,-1,3,-3],
#                           [2,1,2,1],[2,2,2,2],[2,3,-4,-1],
#                           [2,-3,2,-3],[2,-2,-3,3],[3,1,3,1],
#                           [3,3,3,3],[3,-2,3,-2],[3,-1,-4,2],
#                           [4,2,4,2],[4,3,4,3],[4,-1,4,-1]),
                   # PROP 3.47: (PGL(2,7),PGL(2,5))
                   3_44 := VHGroup([1,1,-4,1],[1,2,-3,2],[1,3,-2,3],[1,-3,4,-2],
                           [1,-2,2,-1],[1,-1,3,-3],[2,1,3,1],[2,2,4,2],
                           [2,3,-4,-1],[2,-2,-3,3],[3,3,4,3],[3,-1,-4,2]),
                   # PROP 3.47: (S4,PGL(2,5)), virtually U(H(Z[1/3,1/5])) / ZU
                   3_46 := VHGroup([1,1,2,2],[1,2,2,-1],[1,3,-2,1],
                           [1,-3,1,-2],[1,-1,-2,3],[2,3,2,-2]),
                   # PROP 3.73: (1,S4[6]), reducible, virtually F49 x F3
                   3_72 := VHGroup([1,1,-1,-1],[1,2,-1,-3],[1,3,-1,2],
                           [2,1,-2,3],[2,2,-2,-2],[2,3,-2,-1],
                           [3,1,-3,-2],[3,2,-3,1],[3,3,-3,-3]),
		   # from AGT 2009
		   JensenWise := VHGroup([1,2,-2,-1],[-1,-2,1,-1],[-2,2,-1,-1],[2,2,2,-1]),
                   ));
#############################################################################

#E vhgroup.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
