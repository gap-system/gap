#############################################################################
##
#W linear.gi                                                Laurent Bartholdi
##
#H   @(#)$Id: linear.gi,v 1.20 2011/04/04 19:52:36 gap Exp $
##
#Y Copyright (C) 2007, Laurent Bartholdi
##
#############################################################################
##
##  This file implements the category of linear machines and elements, with
##  a free algebra as stateset.
##
#############################################################################

# apply a ring homomorphism to expr. here im is the list of images of
# generators of a free algebra; expr is an element of the free algebra.
# the last two entries in im are 0 and 1.
BindGlobal("SUBS@", function(expr,im)
    local mapped, i, j, m, e, w, one;

    e := ExtRepOfObj(expr);
    one := One(e[1]);
    e := e[2];
    if e=[] then return im[Length(im)-1]; fi;
    mapped := fail;
    for i in [2,4..Length(e)] do
        w := e[i-1];
        if w=[] then
            m := im[Length(im)];
        else
            m := im[w[1]]^w[2];
            for j in [4,6..Length(w)] do
                if w[j]=1 then
                    m := m*im[w[j-1]];
                else
                    m := m*im[w[j-1]]^w[j];
                fi;
            od;
        fi;
        if e[i]<>one then m := e[i]*m; fi;
        if mapped=fail then mapped := m; else mapped := mapped+m; fi;
    od;
    return mapped;
end);

BindGlobal("AUGMENTATION@", function(expr)
    local e;

    e := ExtRepOfObj(expr);
    if e[2]<>[] and e[2][1]=[] then
        return e[2][2];
    else
        return e[1];
    fi;
end);

BindGlobal("ALGEBRAELEMENT@", function(f,M,s)
    return Objectify(NewType(f,IsLinearFRElement and IsFRElementStdRep),
                   [M,s]);
end);

############################################################################
##
#O Output(<Machine>, <State>)
#O Transition(<Machine>, <State>, <Input>, <Output>)
#O Transitions(<Machine>, <State>, <Input>)
##
InstallMethod(InitialState, "(FR) for a linear machine",
        [IsLinearFRElement and IsFRElementStdRep],
        E->E![2]);

InstallMethod(Output, "(FR) for a linear machine",
        [IsLinearFRMachine and IsAlgebraFRMachineRep,IsElementOfFreeMagmaRing],
        function(M,s)
    return SUBS@(s,M!.output);
end);

InstallMethod(Output, "(FR) for a linear element",
        [IsLinearFRElement and IsFRElementStdRep],
        E->SUBS@(E![2],E![1]!.output));

InstallMethod(Transitions, "(FR) for a linear machine",
        [IsLinearFRMachine and IsAlgebraFRMachineRep,IsElementOfFreeMagmaRing,IsVector],
        function(M,s,a)
    return a*SUBS@(s,M!.transitions);
end);

InstallMethod(Transition, "(FR) for a linear machine",
        [IsLinearFRMachine and IsAlgebraFRMachineRep,IsElementOfFreeMagmaRing,IsVector,IsVector],
        function(M,s,a,b)
    return a*SUBS@(s,M!.transitions)*b;
end);

InstallMethod(Transitions, "(FR) for a linear element",
        [IsLinearFRElement and IsFRElementStdRep,IsVector],
        function(E,a)
    return a*SUBS@(E![2],E![1]!.transitions);
end);

InstallOtherMethod(\[\], "(FR) for a linear element",
        [IsLinearFRElement and IsFRElementStdRep,IsPosInt],
        function(E,i)
    return List(SUBS@(E![2],E![1]!.transitions)[i],v->ALGEBRAELEMENT@(FamilyObj(E),E![1],v));
end);

InstallMethod(Transition, "(FR) for a linear element",
        [IsLinearFRElement and IsFRElementStdRep,IsVector,IsVector],
        function(E,a,b)
    return a*SUBS@(E![2],E![1]!.transitions)*b;
end);

InstallMethod(StateSet, "(FR) for a linear machine in vector rep",
        [IsLinearFRMachine and IsAlgebraFRMachineRep],
        M->M!.free);

InstallMethod(StateSet, "(FR) for a linear element in vector rep",
        [IsLinearFRElement and IsFRElementStdRep],
        E->E![1]!.free);

InstallMethod(GeneratorsOfFRMachine, "(FR) for a linear machine",
        [IsLinearFRMachine and IsAlgebraFRMachineRep],
        M->GeneratorsOfAlgebraWithOne(M!.free));

InstallOtherMethod(\^, "(FR) for a vector and a linear element",
        [IsVector, IsLinearFRElement and IsFRElementStdRep],
        function(v,E)
    return v*MATRIX@(SUBS@(E![1],E![2]!.transitions),v->SUBS@(v,E![1]!.output));
end);

InstallMethod(Activity, "(FR) for a linear machine and a level",
        [IsLinearFRElement and IsFRElementStdRep, IsInt],
        function(E,n)
    local i, j, m, mm, oldm, e, x;
    m := [[E![2]]];
    for j in [1..n] do
        oldm := m;
        m := [];
        for x in oldm do
            mm := List(E![1]!.transitions[1],i->[]);
            for x in x do
                e := SUBS@(x,E![1]!.transitions);
                for i in [1..Length(e)] do
                    Append(mm[i],e[i]);
                od;
            od;
            Append(m,mm);
        od;
    od;
    m := MATRIX@(m,v->SUBS@(v,E![1]!.output));
    i := ValueOption("blocks");
    if i<>fail then
        m := AsBlockMatrix(m,i,i);
    fi;
    if IsJacobianElement(E) then
        m := LieObject(m);
    fi;
    return m;
end);

InstallMethod(Activities, "(FR) for a linear machine and a level",
        [IsLinearFRElement and IsFRElementStdRep, IsInt],
        function(E,n)
    local b, i, j, m, mm, oldm, e, x, result;
    m := [[E![2]]];
    result := [[[SUBS@(E![2],E![1]!.output)]]];
    b := ValueOption("blocks");
    for j in [1..n] do
        oldm := m;
        m := [];
        for x in oldm do
            mm := List(E![1]!.transitions[1],i->[]);
            for x in x do
                e := SUBS@(x,E![1]!.transitions);
                for i in [1..Length(e)] do
                    Append(mm[i],e[i]);
                od;
            od;
            Append(m,mm);
        od;
        x := MATRIX@(m,v->SUBS@(v,E![1]!.output));
        if b<>fail then
            x := AsBlockMatrix(x,b,b);
        fi;
        if IsJacobianElement(E) then
            x := LieObject(x);
        fi;
        Add(result,x);
    od;
    return result;
end);

BindGlobal("LINEARSTATES@", function(l)
    local W, todo, x;
    todo := NewFIFO(l);
    W := VectorSpace(LeftActingDomain(l[1]),[],Zero(l[1]));
    for x in todo do
        if not x in W then
            W := ClosureLeftModule(W,x);
            for x in DecompositionOfFRElement(x) do
                Append(todo,x);
            od;
            if RemInt(Dimension(W),10)=0 then
                Info(InfoFR,2,"The states have dimension at least ",Dimension(W));
            fi;
        fi;
    od;
    return W;
end);

InstallOtherMethod(State, "(FR) for a linear element and two vectors",
        [IsLinearFRElement and IsFRElementStdRep, IsVector, IsVector],
        function(E,a,b)
    return ALGEBRAELEMENT@(FamilyObj(E),E![1],a*SUBS@(E![2],E![1]!.transitions)*b);
end);

InstallOtherMethod(NestedMatrixState, "(FR) for a linear element and two lists",
        [IsLinearFRElement and IsFRElementStdRep, IsList, IsList],
        function(E,ilist,jlist)
    local x, n;
    x := E![2];
    for n in [1..Length(ilist)] do
        x := SUBS@(x,E![1]!.transitions)[ilist[n]][jlist[n]];
    od;
    return ALGEBRAELEMENT@(FamilyObj(E),E![1],x);
end);

InstallOtherMethod(NestedMatrixCoefficient, "(FR) for a linear element and two lists",
        [IsLinearFRElement and IsFRElementStdRep, IsList, IsList],
        function(E,ilist,jlist)
    local x, n;
    x := E![2];
    for n in [1..Length(ilist)] do
        x := SUBS@(x,E![1]!.transitions)[ilist[n]][jlist[n]];
    od;
    return SUBS@(x,E![1]!.output);
end);

InstallMethod(DecompositionOfFRElement, "(FR) for a linear element",
        [IsLinearFRElement and IsFRElementStdRep],
        function(E)
    return MATRIX@(SUBS@(E![2],E![1]!.transitions),
                   v->ALGEBRAELEMENT@(FamilyObj(E),E![1],v));
end);

InstallMethod(States, "(FR) for a linear element",
        [IsLinearFRElement and IsFRElementStdRep],
        E->LINEARSTATES@([E]));

InstallMethod(States, "(FR) for a space of linear elements",
        [IsVectorSpace and IsFRElementCollection],
        V->LINEARSTATES@(GeneratorsOfVectorSpace(V)));

InstallMethod(States, "(FR) for a collection of linear elements",
        [IsFRElementCollection],1, # give it higher priority than FR method
        function(L)
    if not ForAll(L,IsLinearFRElement) then
        TryNextMethod();
    fi;
    return LINEARSTATES@(L);
end);

InstallMethod(TransposedFRElement, "(FR) for a linear element",
        [IsLinearFRElement and IsFRElementStdRep],
        function(E)
    return AlgebraElementNC(FamilyObj(E),E![1]!.free,List(E![1]!.transitions,TransposedMat),E![1]!.output,E![2]);
end);
############################################################################

############################################################################
##
#O  AlgebraMachine
#O  AlgebraElement
##
InstallMethod(AlgebraMachineNC, "(FR) for family, free, transitions, output",
        [IsFamily,IsFreeMagmaRing,IsTransitionTensor,IsVector],
        function(f,free,transitions,output)
    local M;
    M := Objectify(NewType(f, IsLinearFRMachine and IsAlgebraFRMachineRep),
                 rec(free := free,
                     transitions := transitions,
                     output := output));
    return M;
end);

BindGlobal("PREPARESUBS@", function(n,l)
    if Length(l)<n then
        Error("Substitution list is too short -- should have at least ",n," elements\n");
    fi;
    if Length(l)=n+2 then return l; fi;
    l := ShallowCopy(l);
    if Length(l)<n+1 then l[n+1] := Zero(l[1]); fi;
    if Length(l)<n+2 then l[n+2] := One(l[1]); fi;
    return l;
end);

InstallMethod(AlgebraMachine, "(FR) for domain, free, transitions, output",
        [IsRing,IsFreeMagmaRing,IsTransitionTensor,IsVector],
        function(r,free,transitions,output)
    local n;
    n := Length(GeneratorsOfAlgebraWithOne(free));
    transitions := PREPARESUBS@(n,transitions);
    output := PREPARESUBS@(n,output);
    return AlgebraMachineNC(FRMFamily(r^Length(transitions[1])),
                   free,transitions,output);
end);

InstallMethod(AlgebraMachine, "(FR) for free, transitions, output",
        [IsFreeMagmaRing,IsTransitionTensor,IsVector],
        function(free,transitions,output)
    return AlgebraMachine(LeftActingDomain(free),free,transitions,output);
end);

InstallMethod(UnderlyingFRMachine, "(FR) for a linear element",
        [IsLinearFRElement and IsFRElementStdRep],
        E->E![1]);

InstallMethod(AlgebraElementNC, "(FR) for family, free, transitions, output and input",
        [IsFamily,IsFreeMagmaRing,IsTransitionTensor,
         IsVector,IsElementOfFreeMagmaRing],
        function(f,free,transitions,output,input)
    local M;
    M := AlgebraMachineNC(FRMFamily(f), free, transitions, output);
    return ALGEBRAELEMENT@(f,M,input);
end);

InstallMethod(AlgebraElement, "(FR) for domain, free, transitions, output and input",
        [IsRing,IsFreeMagmaRing,IsTransitionTensor,
         IsVector,IsElementOfFreeMagmaRing],
        function(r,free,transitions,output,input)
    local M;
    M := AlgebraMachine(r, free, transitions, output);
    return ALGEBRAELEMENT@(FREFamily(M),M,input);
end);

InstallMethod(AlgebraElement, "(FR) for domain, free, transitions, output, input and category",
        [IsRing,IsFreeMagmaRing,IsTransitionTensor,
         IsVector,IsElementOfFreeMagmaRing,IsOperation],
        function(r,free,transitions,output,input,cat)
    local M, f;
    M := AlgebraMachine(r, free, transitions, output);
    if cat=IsJacobianElement then
        f := FRJFAMILY@(M);
    else
        f := FREFamily(M);
    fi;
    return ALGEBRAELEMENT@(f,M,input);
end);

InstallMethod(AlgebraElement, "(FR) for free, transitions, output and input",
        [IsFreeMagmaRing,IsTransitionTensor,IsVector,IsElementOfFreeMagmaRing],
        function(free,transitions,output,input)
    return AlgebraElement(LeftActingDomain(free),free,transitions,output,input);
end);

InstallMethod(FRElement, "(FR) for a linear machine and a state",
        [IsLinearFRMachine and IsAlgebraFRMachineRep,IsElementOfFreeMagmaRing],
        function(M,s)
    return ALGEBRAELEMENT@(FREFamily(M),M,s);
end);

InstallMethod(FRElement, "(FR) for a linear machine, a state and a category",
        [IsLinearFRMachine and IsAlgebraFRMachineRep,IsElementOfFreeMagmaRing,IsOperation],
        function(M,s,cat)
    local f;
    if cat=IsJacobianElement then
        f := FRJFAMILY@(M);
    else
        f := FREFamily(M);
    fi;
    return ALGEBRAELEMENT@(f,M,s);
end);

InstallMethod(FRElement, "(FR) for a linear element and a state",
        [IsLinearFRElement and IsFRElementStdRep, IsElementOfFreeMagmaRing],
        function(E,s)
    return ALGEBRAELEMENT@(FamilyObj(E),E![1],s);
end);

InstallMethod(FRElement, "(FR) for a linear machine and a state index",
        [IsLinearFRMachine and IsAlgebraFRMachineRep,IsInt],
        function(M,s)
    return ALGEBRAELEMENT@(FREFamily(M),M,GeneratorsOfAlgebraWithOne(M!.free)[s]);
end);

InstallMethod(FRElement, "(FR) for a linear element and a state index",
        [IsLinearFRElement and IsFRElementStdRep, IsInt],
        function(E,s)
    return ALGEBRAELEMENT@(FamilyObj(E),E![1],GeneratorsOfAlgebraWithOne(E![1]!.free)[s]);
end);

InstallMethod(LieObject, "(FR) for an associative linear element",
        [IsLinearFRElement and IsFRElementStdRep and IsAssociativeElement],
        e->ALGEBRAELEMENT@(FRJFAMILY@(e),e![1],e![2]));

InstallMethod(AssociativeObject, "(FR) for a jacobian linear element",
        [IsLinearFRElement and IsFRElementStdRep and IsJacobianElement],
        e->ALGEBRAELEMENT@(FREFamily(e),e![1],e![2]));
#############################################################################

#############################################################################
##
#M ViewObj
#M String
#M Display
##
InstallMethod(ViewString, "(FR) for a linear machine",
        [IsLinearFRMachine and IsAlgebraFRMachineRep],
        function(M)
    return CONCAT@("<Linear machine on alphabet ", LeftActingDomain(M), "^",
          Length(M!.transitions[1]), " with generators ",
          GeneratorsOfAlgebraWithOne(M!.free), ">");
end);

InstallMethod(ViewString, "(FR) for a linear element",
        [IsLinearFRElement and IsFRElementStdRep],
        function(E)
    local s;
    s := CONCAT@("<", LeftActingDomain(E), "^", Length(E![1]!.transitions[1]), "|",
          E![2]);
    if IsJacobianElement(E) then Append(s,"-"); fi;
    Append(s,">");
    return s;
end);

InstallMethod(String, "(FR) Linear machine to string",
        [IsLinearFRMachine and IsAlgebraFRMachineRep],
        function(M)
    return CONCAT@("AlgebraMachine(",LeftActingDomain(M),", ", M!.transitions,", ", M!.output,")");
end);

InstallMethod(String, "(FR) Linear element to string",
        [IsLinearFRElement and IsFRElementStdRep],
        function(E)
    local x;
    if IsJacobianElement(E) then
        x := ",IsJacobianElement";
    else
        x := "";
    fi;
    return CONCAT@("AlgebraElement(",LeftActingDomain(E),", ",
                   E![1]!.free,", ",
                   E![1]!.transitions,", ",
                   E![1]!.output,", ",E![2],x,")");
end);

BindGlobal("ALG2STRING@", function(expr)
    local i, j, m, e, w, map, mapped, one;

    e := ExtRepOfObj(expr);
    one := One(e[1]);
    e := e[2];
    if e=[] then return "0"; fi;
    mapped := fail;
    for i in [2,4..Length(e)] do
        w := e[i-1];
        if w=[] then
            map := "1";
        else
            map := fail;
            for j in [2,4..Length(w)] do
                m := FamilyObj(expr)!.names[w[j-1]];
                if w[j]>1 then
                    m := Concatenation(m,"^",String(w[j]));
                fi;
                if map=fail then
                    map := m;
                else
                    map := Concatenation(map,"*",m);
                fi;
            od;
        fi;
        if e[i]=one then;
        elif e[i]=-one then
            map := Concatenation("-",map);
        elif IsFFE(e[i]) then
            map := Concatenation(String(IntFFE(e[i])),"*",map);
        else
            map := Concatenation(String(e[i]),"*",map);
        fi;
        if mapped=fail then
            mapped := map;
        elif map[1]='-' then
            mapped := Concatenation(mapped,map);
        else
            mapped := Concatenation(mapped,"+",map);
        fi;
    od;
    return mapped;
end);

InstallMethod(DisplayString, "(FR) for a linear machine",
        [IsLinearFRMachine and IsAlgebraFRMachineRep],
        function(M)
    local r, i, j, k, l, m, n, xlen, xprint, xrule, headlen, headrule, headblank, s;
    r := LeftActingDomain(M);
    n := Length(M!.transitions[1]);
    m := Length(GeneratorsOfAlgebraWithOne(M!.free));
    xlen := Maximum(List(Flat(M!.transitions),x->Length(ALG2STRING@(x))))+1;
    xprint := x->String(ALG2STRING@(x),xlen-1);
    xrule := ListWithIdenticalEntries(xlen,'-');
    headlen := Length(String(r))+1;
    headrule := ListWithIdenticalEntries(headlen,'-');
    headblank := ListWithIdenticalEntries(headlen,' ');

    s := Concatenation(String(r,headlen)," |");
    for i in [1..n] do
        APPEND@(s,String(i,QuoInt(xlen,2)+1),String("",xlen-QuoInt(xlen,2)),"|");
    od;
    APPEND@(s,"\n");
    APPEND@(s,headrule, "-+");
    for i in [1..n] do APPEND@(s,xrule,"-+"); od;
    APPEND@(s,"\n");
    for i in [1..n] do
        APPEND@(s,String(i,headlen)," |");
        for j in [1..m] do
            if j>1 then APPEND@(s,headblank," |"); fi;
            for k in [1..n] do
                APPEND@(s," ",xprint(M!.transitions[j][i][k])," |");
            od;
            APPEND@(s,"\n");
        od;
        APPEND@(s,headrule,"-+");
        for i in [1..n] do APPEND@(s,xrule,"-+"); od;
        APPEND@(s,"\n");
    od;
    APPEND@(s,"Output:");
    for i in [1..m] do
        APPEND@(s," ");
        if IsFFE(M!.output[i]) then
            APPEND@(s,IntFFE(M!.output[i]));
        else
            APPEND@(s,M!.output[i]);
        fi;
    od;
    APPEND@(s,"\n");
    return s;
end);

InstallMethod(DisplayString, "(FR) for a linear element",
        [IsLinearFRElement and IsFRElementStdRep],
        function(E)
    local s;
    s := DisplayString(E![1]);
    if IsJacobianElement(E) then
        Append(s, "Jacobian; ");
    fi;
    APPEND@(s,"Initial state: ",ALG2STRING@(E![2]),"\n");
end);
#############################################################################

#############################################################################
##
#M AsAlgebraMachine
#M AsAlgebraElement
##
BindGlobal("ASALGEBRAMACHINE@", function(r,M)
    local s, f, g, inj, A, trans, out, zero, i, x;
    g := GeneratorsOfFRMachine(M);
    f := FreeAssociativeAlgebraWithOne(r,ElementsFamily(FamilyObj(M!.free))!.names);
    inj := MagmaHomomorphismByFunctionNC(StateSet(M),f,w->MappedWord(w,g,GeneratorsOfAlgebraWithOne(f)));
    trans := [];
    out := [];
    zero := List(AlphabetOfFRObject(M),i->List(AlphabetOfFRObject(M),j->Zero(f)));
    for s in g do
        x := StructuralCopy(zero);
        for i in AlphabetOfFRObject(M) do
            x[i][Output(M,s,i)] := Transition(M,s,i)^inj;
        od;
        Add(trans,x);
        Add(out,One(r));
    od;
    Add(trans,zero);
    Add(trans,One(zero));
    Add(out,Zero(r));
    Add(out,One(r));
    A := AlgebraMachineNC(FRMFamily(r^Size(AlphabetOfFRObject(M))),f,trans,out);
    SetCorrespondence(A,inj);
    return A;
end);

InstallMethod(AsAlgebraMachine, "(FR) for a semigroup FR machine",
        [IsRing,IsSemigroupFRMachine],
        ASALGEBRAMACHINE@);

InstallMethod(AsAlgebraMachine, "(FR) for a monoid FR machine",
        [IsRing,IsMonoidFRMachine],
        ASALGEBRAMACHINE@);

InstallMethod(AsAlgebraMachine, "(FR) for a group FR machine",
        [IsRing,IsGroupFRMachine],
        function(r,M)
    local N, A;
    N := AsMonoidFRMachine(M);
    A := ASALGEBRAMACHINE@(r,N);
    A!.Correspondence := Correspondence(N)*Correspondence(A);
    return A;
end);

InstallMethod(AsAlgebraMachine, "(FR) for a Mealy machine",
        [IsRing,IsMealyMachine and IsMealyMachineIntRep],
        function(r,M)
    local N, A;
    Info(InfoFR,2,"AsAlgebraMachine: converting to monoid machine");
    N := AsMonoidFRMachine(M);
    A := ASALGEBRAMACHINE@(r,N);
    A!.Correspondence := List(Correspondence(N),x->x^Correspondence(A));
    return A;
end);

InstallMethod(AsLinearMachine, "(FR) for an FR machine",
        [IsRing,IsFRMachine],
        AsAlgebraMachine);

BindGlobal("VECTOR2ALGEBRA@", function(fam,M)
    local i, f, g, N, trans, out;
    f := FreeAssociativeAlgebraWithOne(LeftActingDomain(M),Length(M!.output));
    g := GeneratorsOfAlgebraWithOne(f);
    trans := [];
    for i in [1..Length(g)] do
        Add(trans,MATRIX@(M!.transitions,v->v[i]*g));
    od;
    Add(trans,Zero(trans[1]));
    Add(trans,One(trans[1]));
    out := ShallowCopy(M!.output);
    Add(out,Zero(out[1]));
    Add(out,One(out[1]));
    N := AlgebraMachineNC(fam,f,trans,out);
    SetCorrespondence(N,g);
    return N;
end);

InstallMethod(AsAlgebraMachine, "(FR) for a vector machine",
        [IsLinearFRMachine and IsVectorFRMachineRep],
        M->VECTOR2ALGEBRA@(FamilyObj(M),M));

InstallMethod(AsAlgebraMachine, "(FR) for an algebra machine",
        [IsLinearFRMachine],
        X->X);

InstallMethod(AsVectorMachine, "(FR) for an algebra machine",
        [IsLinearFRMachine and IsAlgebraFRMachineRep],
        function(M)
    local gens, states, B, corr, d, trans, out, i, j, s, t;

    gens := List(GeneratorsOfFRMachine(M),x->FRElement(M,x));
    states := LINEARSTATES@(gens);
    B := Basis(states);
    d := List(B,DecompositionOfFRElement);
    trans := [];
    out := List(B,Output);
    for i in [1..Length(d[1])] do
        t := [];
        for j in [1..Length(d[1])] do
            Add(t,List(d,s->Coefficients(B,s[i][j])));
        od;
        Add(trans,t);
    od;
    M := VectorMachineNC(FamilyObj(M),trans,out);
    SetCorrespondence(M,List(gens,s->Coefficients(B,s)));
    return M;
end);

InstallMethod(AsVectorMachine, "(FR) for a linear machine",
        [IsLinearFRMachine],
        X->X);

BindGlobal("ASALGEBRAELEMENT@", function(r,E)
    local A;
    A := ASALGEBRAMACHINE@(r,E![1]);
    return FRElement(A,E![2]^Correspondence(A));
end);

InstallMethod(AsAlgebraElement, "(FR) for a semigroup FR element",
        [IsRing,IsSemigroupFRElement],
        ASALGEBRAELEMENT@);

InstallMethod(AsAlgebraElement, "(FR) for a monoid FR element",
        [IsRing,IsMonoidFRElement],
        ASALGEBRAELEMENT@);

InstallMethod(AsAlgebraElement, "(FR) for a group FR element",
        [IsRing,IsGroupFRElement],
        function(r,E)
    local M, A;
    M := AsMonoidFRMachine(E![1]);
    A := ASALGEBRAMACHINE@(r,M);
    return FRElement(A,(E![2]^Correspondence(M))^Correspondence(A));
end);

InstallMethod(AsAlgebraElement, "(FR) for a Mealy element",
        [IsRing,IsMealyElement and IsMealyMachineIntRep],
        function(r,E)
    Info(InfoFR,2,"AsAlgebraElement: converting to monoid element");
    return ASALGEBRAELEMENT@(r,AsMonoidFRElement(E));
end);

InstallMethod(AsLinearElement, "(FR) for an FR element",
        [IsRing,IsFRElement],
        AsAlgebraElement);

InstallMethod(AsAlgebraElement, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        function(E)
    local N;
    N := VECTOR2ALGEBRA@(FRMFamily(E),E);
    return FRElement(N,Correspondence(N)[1]);
end);

InstallMethod(AsAlgebraElement, "(FR) for a linear element",
        [IsLinearFRElement],
        X->X);

InstallMethod(AsVectorElement, "(FR) for an algebra element",
        [IsLinearFRElement and IsFRElementStdRep],
        function(E)
    local B, input, output, trans, dec, i, j, k, row, col;
    B := Basis(States(E));
    input := Coefficients(B,E);
    output := List(B,Output);
    dec := List(B,DecompositionOfFRElement);
    trans := [];
    for i in [1..Length(dec[1])] do
        row := [];
        for j in [1..Length(dec[1])] do
            col := [];
            for k in dec do
                Add(col,Coefficients(B,k[i][j]));
            od;
            Add(row,col);
        od;
        Add(trans,row);
    od;
    B := VECTORMINIMIZE@(FamilyObj(E),LeftActingDomain(E),
                 trans,output,input,0,false);
    return B;
end);

InstallMethod(AsVectorElement, "(FR) for a linear element",
        [IsLinearFRElement],
        X->X);
#############################################################################

############################################################################
##
#M  InverseOp
#M  OneOp
#M  ZeroOp
##
InstallMethod(InverseOp, "(FR) for a linear element",
        [IsLinearFRElement and IsFRElementStdRep],
        function(E)
    Info(InfoFR, 1, "InverseOp: converting to vector element");
    return InverseOp(AsVectorElement(E));
end);

InstallMethod(OneOp, "(FR) for a linear machine",
        [IsLinearFRMachine and IsAlgebraFRMachineRep],
        function(M)
    local f, n;
    n := Length(M!.transitions);
    f := FreeAssociativeAlgebraWithOne(LeftActingDomain(M),0);
    return AlgebraMachineNC(FamilyObj(M),f,
                   M!.transitions{[n-1..n]},M!.output{[n-1..n]});
end);

InstallMethod(OneOp, "(FR) for a linear element",
        [IsLinearFRElement and IsFRElementStdRep],
        E->ALGEBRAELEMENT@(FamilyObj(E),E![1],One(E![2])));

InstallMethod(ZeroOp, "(FR) for a linear machine",
        [IsLinearFRMachine and IsAlgebraFRMachineRep],
        function(M)
    local f, n;
    n := Length(M!.transitions);
    f := FreeAssociativeAlgebraWithOne(LeftActingDomain(M),0);
    return AlgebraMachineNC(FamilyObj(M),f,
                   M!.transitions{[n-1..n]},M!.output{[n-1..n]});
end);

InstallMethod(ZeroOp, "(FR) for a linear element",
        [IsLinearFRElement and IsFRElementStdRep],
        E->ALGEBRAELEMENT@(FamilyObj(E),E![1],Zero(E![2])));

InstallMethod(\+, "for two linear machines", IsIdenticalObj,
        [IsLinearFRMachine and IsAlgebraFRMachineRep,
         IsLinearFRMachine and IsAlgebraFRMachineRep],
        function(M,N)
    local x, y, m, trans, i;
    if LeftActingDomain(M)<>LeftActingDomain(N) then
        Error("Cannot (yet) add two machines with different acting domains\n");
    fi;
    x := ElementsFamily(FamilyObj(M!.free))!.names;
    y := ElementsFamily(FamilyObj(N!.free))!.names;
    if Intersection(x,y)=[] then
        x := Concatenation(x,y);
    else
        x := Concatenation(List(x,x->Concatenation(x,".1")),
                     List(y,x->Concatenation(x,".2")));
    fi;
    x := FreeAssociativeAlgebraWithOne(LeftActingDomain(M),x);
    m := Length(M!.output)-2;
    y := [GeneratorsOfAlgebraWithOne(x){[1..m]},
          GeneratorsOfAlgebraWithOne(x){[1..Length(N!.output)-2]+m}];
    Add(y[1],Zero(x)); Add(y[1],One(x));
    Add(y[2],Zero(x)); Add(y[2],One(x));
    trans := [];
    for i in [1..m] do
        Add(trans,MATRIX@(M!.transitions[i],v->SUBS@(v,y[1])));
    od;
    for i in N!.transitions do
        Add(trans,MATRIX@(i,v->SUBS@(v,y[2])));
    od;
    x := AlgebraMachineNC(FamilyObj(M),x,
                 trans,Concatenation(M!.output{[1..m]},N!.output));
    SetCorrespondence(x,y);
    return x;
end);

InstallMethod(\+, "for two linear elements", IsIdenticalObj,
        [IsLinearFRElement and IsFRElementStdRep,
         IsLinearFRElement and IsFRElementStdRep],
        function(E,F)
    local M;
    if E![1]=F![1] then
        return ALGEBRAELEMENT@(FamilyObj(E),E![1],E![2]+F![2]);
    else
        M := E![1]+F![1];
        return ALGEBRAELEMENT@(FamilyObj(E),M,
                       SUBS@(E![2],Correspondence(M)[1])+
                       SUBS@(F![2],Correspondence(M)[2]));
    fi;
end);

InstallMethod(\+, "for a scalar and a linear element",
        [IsScalar,IsLinearFRElement and IsFRElementStdRep],
        function(x,E)
    if not IsRat(x) and not x in LeftActingDomain(E) then TryNextMethod(); fi; # matrix?
    return ALGEBRAELEMENT@(FamilyObj(E),E![1],x*One(E![1]!.free)+E![2]);
end);

InstallMethod(\+, "for a linear element and a scalar",
        [IsLinearFRElement and IsFRElementStdRep,IsScalar],
        function(E,x)
    if not IsRat(x) and not x in LeftActingDomain(E) then TryNextMethod(); fi; # matrix?
    return ALGEBRAELEMENT@(FamilyObj(E),E![1],E![2]+x*One(E![1]!.free));
end);

InstallMethod(\+, "(FR) for two linear elements", IsIdenticalObj,
        [IsLinearFRElement and IsVectorFRMachineRep,
         IsLinearFRElement and IsFRElementStdRep],
        function(E,F)
    Info(InfoFR, 1, "\\+: converting first argument to algebra element");
    return AsAlgebraElement(E)+F;
end);

InstallMethod(\+, "(FR) for two linear elements", IsIdenticalObj,
        [IsLinearFRElement and IsFRElementStdRep,
         IsLinearFRElement and IsVectorFRMachineRep],
        function(E,F)
    Info(InfoFR, 1, "\\+: converting second argument to algebra element");
    return E+AsAlgebraElement(F);
end);

InstallMethod(AINV, "for a linear machine",
        [IsLinearFRMachine and IsAlgebraFRMachineRep],
        function(M)
    return AlgebraMachineNC(FamilyObj(M),M!.free,M!.transitions,-M!.output);
end);

InstallMethod(AINV, "for a linear element",
        [IsLinearFRElement and IsFRElementStdRep],
        function(E)
    return ALGEBRAELEMENT@(FamilyObj(E),E![1],-E![2]);
end);

InstallMethod(\*, "for two linear machines", IsIdenticalObj,
        [IsLinearFRMachine and IsAlgebraFRMachineRep,
         IsLinearFRMachine and IsAlgebraFRMachineRep],
        function(M,N)
    Error("Multiplication of algebra machines is not implemented. Please use ADD\n");
end);

InstallMethod(\*, "for two linear elements", IsIdenticalObj,
        [IsLinearFRElement and IsFRElementStdRep and IsAssociativeElement,
         IsLinearFRElement and IsFRElementStdRep and IsAssociativeElement],
        function(E,F)
    local M;
    if E![1]=F![1] then
        return ALGEBRAELEMENT@(FamilyObj(E),E![1],E![2]*F![2]);
    else
        M := E![1]+F![1];
        return ALGEBRAELEMENT@(FamilyObj(E),M,
                       SUBS@(E![2],Correspondence(M)[1])*
                       SUBS@(F![2],Correspondence(M)[2]));
    fi;
end);

InstallMethod(\*, "for two linear elements", IsIdenticalObj,
        [IsLinearFRElement and IsFRElementStdRep and IsJacobianElement,
         IsLinearFRElement and IsFRElementStdRep and IsJacobianElement],
        function(E,F)
    local M;
    if E![1]=F![1] then
        return ALGEBRAELEMENT@(FamilyObj(E),E![1],LieBracket(E![2],F![2]));
    else
        M := E![1]+F![1];
        return ALGEBRAELEMENT@(FamilyObj(E),M,
                       LieBracket(SUBS@(E![2],Correspondence(M)[1]),
                               SUBS@(F![2],Correspondence(M)[2])));
    fi;
end);

InstallMethod(PthPowerImage, "for a linear element",
        [IsLinearFRElement and IsFRElementStdRep and IsJacobianElement],
        function(x)
    local p;
    p := Characteristic(LeftActingDomain(x));
    if not IsPrime(p) then TryNextMethod(); fi;
    return ALGEBRAELEMENT@(FamilyObj(x),x![1],x![2]^p);
end);
           
InstallMethod(PthPowerImage, "for a linear element and a number",
        [IsLinearFRElement and IsFRElementStdRep and IsJacobianElement,IsInt],
        function(x,n)
    local p;
    p := Characteristic(LeftActingDomain(x));
    if not IsPrime(p) then TryNextMethod(); fi;
    return ALGEBRAELEMENT@(FamilyObj(x),x![1],x![2]^(p^n));
end);

InstallMethod(\*, "for a scalar and a linear machine",
        [IsScalar,IsLinearFRMachine and IsAlgebraFRMachineRep],
        function(x,M)
    if not IsRat(x) and not x in LeftActingDomain(M) then TryNextMethod(); fi; # matrix?
    return AlgebraMachineNC(FamilyObj(M),M!.free,M!.transitions,x*M!.output);
end);

InstallMethod(\*, "for a linear machine and a scalar",
        [IsLinearFRMachine and IsAlgebraFRMachineRep,IsScalar],
        function(M,x)
    if not IsRat(x) and not x in LeftActingDomain(M) then TryNextMethod(); fi; # matrix?
    return AlgebraMachineNC(FamilyObj(M),M!.free,M!.transitions,M!.output*x);
end);

InstallMethod(\*, "for a scalar and a linear element",
        [IsScalar,IsLinearFRElement and IsFRElementStdRep],
        function(x,E)
    if not IsRat(x) and not x in LeftActingDomain(E) then TryNextMethod(); fi; # matrix?
    return ALGEBRAELEMENT@(FamilyObj(E),E![1],x*E![2]);
end);

InstallMethod(\*, "for a linear element and a scalar",
        [IsLinearFRElement and IsFRElementStdRep,IsScalar],
        function(E,x)
    if not IsRat(x) and not x in LeftActingDomain(E) then TryNextMethod(); fi; # matrix?
    return ALGEBRAELEMENT@(FamilyObj(E),E![1],E![2]*x);
end);

InstallMethod(\*, "(FR) for two linear elements", IsIdenticalObj,
        [IsLinearFRElement and IsVectorFRMachineRep,
         IsLinearFRElement and IsFRElementStdRep],
        function(E,F)
    Info(InfoFR, 1, "\\*: converting first argument to algebra element");
    return AsAlgebraElement(E)*F;
end);

InstallMethod(\*, "(FR) for two linear elements", IsIdenticalObj,
        [IsLinearFRElement and IsFRElementStdRep,
         IsLinearFRElement and IsVectorFRMachineRep],
        function(E,F)
    Info(InfoFR, 1, "\\*: converting second argument to algebra element");
    return E*AsAlgebraElement(F);
end);
############################################################################

############################################################################
##
#M  Minimized . . . . . . . . . . . . . . . . . . . .minimize linear machine
##
InstallMethod(Minimized, "(FR) for a linear machine",
        [IsLinearFRMachine and IsAlgebraFRMachineRep],
        function(M)
    local f, gens, imgs, i, j, found, newgens, N, trans, out;
    gens := List(GeneratorsOfFRMachine(M),i->FRElement(M,i));
    imgs := [];
    newgens := [];
    for i in [1..Length(gens)] do
        if IsZero(gens[i]) then
            Add(imgs,[fail,-1]);
            found := true;
        elif IsOne(gens[i]) then
            Add(imgs,[fail,0]);
            found := true;
        else
            found := false;
            for j in imgs do if gens[i]=j[1] then
                found := true; Add(imgs,[fail,j[2]]); break;
            fi; od;
        fi;
        if not found then
            Add(newgens,ElementsFamily(FamilyObj(M!.free))!.names[i]);
            Add(imgs,[gens[i],Length(newgens)]);
        fi;
    od;
    f := FreeAssociativeAlgebraWithOne(LeftActingDomain(M),newgens);
    gens := [];
    for j in [1..Length(imgs)] do
        if imgs[j][2] = -1 then
            Add(gens,Zero(f));
        elif imgs[j][2] = 0 then
            Add(gens,One(f));
        else
            Add(gens,GeneratorsOfAlgebraWithOne(f)[imgs[j][2]]);
        fi;
    od;
    Add(gens,Zero(f));
    Add(gens,One(f));
    trans := [];
    out := [];
    for j in [1..Length(gens)-2] do if imgs[j][1]<>fail then
        Add(trans,MATRIX@(M!.transitions[j],v->SUBS@(v,gens)));
        Add(out,M!.output[j]);
    fi; od;
    Add(trans,Zero(trans[1]));
    Add(trans,One(trans[1]));
    Add(out,Zero(out[1]));
    Add(out,One(out[1]));
    N := AlgebraMachineNC(FamilyObj(M),f,trans,out);
    SetCorrespondence(N,gens);
    return N;
end);

InstallMethod(Minimized, "(FR) for a linear element",
        [IsLinearFRElement and IsFRElementStdRep],
        E->E);
############################################################################

############################################################################
##
#M  IsOne
#M  IsZero
#M  =
#M  <
##
InstallMethod(\=, "(FR) for two linear machines", IsIdenticalObj,
        [IsLinearFRMachine and IsAlgebraFRMachineRep,
         IsLinearFRMachine and IsAlgebraFRMachineRep],
        function(M,N)
    return M!.free=N!.free and M!.transitions=N!.transitions
           and M!.output=N!.output;
end);

InstallMethod(\<, "(FR) for two linear machines", IsIdenticalObj,
        [IsLinearFRMachine and IsAlgebraFRMachineRep,
         IsLinearFRMachine and IsAlgebraFRMachineRep],
        function(M,N)
    return M!.free<N!.free or (M!.free=N!.free and
                   (M!.transitions<N!.transitions or
                    (M!.transitions=N!.transitions and M!.output<N!.output)));
end);

InstallMethod(IsOne, "(FR) for a linear machine",
        [IsLinearFRMachine and IsAlgebraFRMachineRep],
        function(M)
    return M!.output=[];
end);

InstallMethod(IsZero, "(FR) for a linear machine",
        [IsLinearFRMachine and IsAlgebraFRMachineRep],
        function(M)
    return M!.output=[];
end);

if LoadPackage("gbnp")=fail then

BindGlobal("ALGEBRAISZERO@", function(M,x)
    local zero, todo, i;

    zero := Subspace(M!.free,[]);
    todo := NewFIFO([x]);
    for x in todo do
        if not x in zero then
            if not IsZero(SUBS@(x,M!.output)) then return false; fi;
            zero := ClosureLeftModule(zero,x);
            x := SUBS@(x,M!.transitions);
            for i in x do Append(todo,i); od;
        fi;
    od;
    return true;
end);

else

InstallMethod(FRMachineRWS, "(FR) for an algebra machine",
        [IsLinearFRMachine and IsAlgebraFRMachineRep],
        function(M)
    local rws;
    rws := rec(free := M!.free, gbasis := [], gbasiscopy := []);

    rws.restart := function()
        rws.gbasis := ShallowCopy(rws.gbasiscopy);
    end;

    rws.commit := function()
        rws.gbasiscopy := ShallowCopy(rws.gbasis);
    end;

    rws.reduce := function(x)
        return NP2GP(StrongNormalFormNP(GP2NP(x),rws.gbasis),M!.free);
    end;
    #!!! maybe work purely in the GBNP format, to speed up?

    rws.addrule := function(x)
        Add(rws.gbasis,GP2NP(x));
        rws.gbasis := GBNP.ReducePol(rws.gbasis);
    end;

    return rws;
end);

BindGlobal("ALGEBRAISZERO@", function(M,x)
    local rws, todo, i;

    rws := NewFRMachineRWS(M);
    todo := NewFIFO([x]);
    for x in todo do
        x := rws.reduce(x);
        if not IsZero(x) then
            if not IsZero(SUBS@(x,M!.output)) then return false; fi;
            rws.addrule(x);
            x := SUBS@(x,M!.transitions);
            for i in x do Append(todo,i); od;
        fi;
    od;
    rws.commit();
    return true;
end);

fi;

InstallMethod(\=, "(FR) for two linear elements", IsIdenticalObj,
        [IsLinearFRElement and IsFRElementStdRep,
         IsLinearFRElement and IsFRElementStdRep],
        function(E,F)
    local M;
    if IsIdenticalObj(E![1], F![1]) then
        return ALGEBRAISZERO@(E![1],E![2]-F![2]);
    else
        M := E![1]+F![1];
        return ALGEBRAISZERO@(M,
                       SUBS@(E![2],Correspondence(M)[1])-
                       SUBS@(F![2],Correspondence(M)[2]));
    fi;
end);

InstallMethod(\=, "(FR) for two linear elements", IsIdenticalObj,
        [IsLinearFRElement and IsVectorFRMachineRep,
         IsLinearFRElement and IsFRElementStdRep],
        function(E,F)
    Info(InfoFR, 1, "\\=: converting first argument to algebra element");
    return AsAlgebraElement(E)=F;
end);

InstallMethod(\=, "(FR) for two linear elements", IsIdenticalObj,
        [IsLinearFRElement and IsFRElementStdRep,
         IsLinearFRElement and IsVectorFRMachineRep],
        function(E,F)
    Info(InfoFR, 1, "\\=: converting second argument to algebra element");
    return E=AsAlgebraElement(F);
end);

InstallMethod(\<, "(FR) for two linear elements", IsIdenticalObj,
        [IsLinearFRElement and IsFRElementStdRep,
         IsLinearFRElement and IsFRElementStdRep],
        function(left,right)
    local out, trans, todo, mach, idle, states, i, j, t, row, x, y, a, b, c, p, u;

    if left=right then return false; fi;
    # now we know they're different, it's just a matter of finding where

    mach := [left![1],right![1]];
    todo := [[left![2]],[right![2]]];
    out := [[],[]];
    trans := [[],[]];
    states := [VectorSpace(LeftActingDomain(left),[left]),
               VectorSpace(LeftActingDomain(right),[right])];
    i := 1;
    repeat
        idle := [true,true];
        for p in [1,2] do
            if i <= Length(todo[p]) then
                idle[p] := false;
                x := SUBS@(todo[p][i],mach[p]!.transitions);
                Add(out[p],SUBS@(todo[p][i],mach[p]!.output));
                t := [];
                Add(trans[p],t);
                for a in x do
                    row := [];
                    Add(t,row);
                    for b in a do
                        c := FRElement(mach[p],b);
                        y := Coefficients(Basis(states[p]),c);
                        if y<>fail then
                            Add(row,y);
                        else
                            Add(todo[p],b);
                            y := LeftModuleByGenerators(LeftActingDomain(states[p]),Concatenation(BasisVectors(Basis(states[p])),[c]));
                            for u in trans do for u in u do
                                Add(u,Zero(LeftActingDomain(states[p])));
                            od; od;
                            Add(row,Coefficients(Basis(y),c));
                            states[p] := y;
                        fi;
                    od;
                od;
            fi;
        od;
        if idle[2] then
            return false; # right machine is finite state, left has more states
        elif idle[1] then
            return true; # left machine is finite state, right has more states
        elif out[1][i]<>out[2][i] then
            return out[1][i]<out[2][i]; # compare outputs lexicographically
        fi;
        for j in [1..i] do # compare transitions lexicographically
            if trans[1][i][j]<>trans[2][i][j] then
                return trans[1][i][j]<trans[2][i][j];
            fi;
        od;
        for j in [1..i-1] do
            if trans[1][j][i]<>trans[2][j][i] then
                return trans[1][j][i]<trans[2][j][i];
            fi;
        od;
        i := i+1;
    until false;
end);

InstallMethod(\<, "(FR) for a vector and a linear element", IsIdenticalObj,
        [IsLinearFRElement and IsFRElementStdRep,
         IsLinearFRElement and IsVectorFRMachineRep],
        function(E,F)
    Info(InfoFR, 1, "\\<: converting second argument to linear element");
    return E<AsAlgebraElement(F);
end);

InstallMethod(\<, "(FR) for a linear and a vector element", IsIdenticalObj,
        [IsLinearFRElement and IsVectorFRMachineRep,
         IsLinearFRElement and IsFRElementStdRep],
        function(E,F)
    Info(InfoFR, 1, "\\<: converting first argument to linear element");
    return AsAlgebraElement(E)<F;
end);

InstallMethod(IsOne, "(FR) for a linear element",
        [IsLinearFRElement and IsFRElementStdRep],
        function(E)
    return ALGEBRAISZERO@(E![1],E![2]-One(E![1]!.free));
end);

InstallMethod(IsZero, "(FR) for a linear element",
        [IsLinearFRElement and IsFRElementStdRep],
        function(E)
    return ALGEBRAISZERO@(E![1],E![2]);
end);
############################################################################

############################################################################
##
#M  Nice basis
##
InstallHandlingByNiceBasis("IsLinearFRElementSpace", rec(
        # info stores 'gens', the generators;
        # 'where', a list of tuples [ilist,jlist,values] of the evaluations
        #   of generators at (nested) coordinates (ilist,jlist)
        # 'hom', a quotient map from the vector space on the generators
        #   to a basis of V
        detect := function(R,l,V,z)
    if l=[] then
        return IsLinearFRElement(z) and IsFRElementStdRep(z)
               and LeftActingDomain(z)=R;
    else
        return ForAll(l,x->IsLinearFRElement(x) and LeftActingDomain(x)=R)
               and not ForAll(l,IsVectorFRMachineRep);
        # there's a faster method for purely vector FR element spaces
    fi;
end,
  NiceFreeLeftModuleInfo := function(V)
    local m, n, info, o, t, space, kernel, image,
          i, j, x, todo, machine;
    info := rec(gens := ShallowCopy(GeneratorsOfLeftModule(V)),
                where := []);
    m := Length(info.gens);
    if m=0 then
        return rec(trivial := true);
    fi;
    n := Length(info.gens[1]![1]!.transitions[1]);
    for i in [1..m] do
        if IsVectorFRMachineRep(info.gens[i]) then
            info.gens[i] := AsAlgebraElement(info.gens[i]);
        fi;
    od;
    space := LeftActingDomain(V)^m;
    image := Subspace(space,[]);
    todo := [[],[],[]]; # row address, col addr, element

    machine := UnderlyingFRMachine(info.gens[1]);
    if ForAll(info.gens,x->UnderlyingFRMachine(x)=machine) then
        todo[3] := List(info.gens,x->x![2]);
    else
        machine := Sum(List(info.gens,UnderlyingFRMachine));
        j := 0;
        for i in [1..m] do
            x := Length(GeneratorsOfAlgebraWithOne(info.gens[i]![1]!.free));
            o := Concatenation(GeneratorsOfAlgebraWithOne(machine!.free){[j+1..j+x]},[Zero(machine!.free),One(machine!.free)]);
            Add(todo[3],SUBS@(info.gens[i]![2],o));
            j := j+x;
        od;
        machine := Minimized(machine);
        for i in [1..m] do
            todo[3][i] := SUBS@(todo[3][i],Correspondence(machine));
        od;
    fi;
    todo := NewFIFO([todo]);

    for t in todo do
        o := List(t[3],v->SUBS@(v,machine!.output));
        if not o in image then
            image := ClosureLeftModule(image,o);
            Add(info.where,[t[1],t[2],o]);
            kernel := NullspaceMat(TransposedMat(Basis(image)));
            if kernel=[] or IsZero(kernel*info.gens) then
                break;
            fi;
        fi;
        x := List(t[3],e->SUBS@(e,machine!.transitions));
        # !!! and reduce... keep space of FreeAlgebra-tuples that have been considered.
        # unfortunately, GAP cannot handle vector spaces over machine!.free
        for i in [1..n] do
            for j in [1..n] do
                Add(todo,[Concatenation(t[1],[i]),Concatenation(t[2],[j]),
                        List(x,m->m[i][j])]);
            od;
        od;
    od;
    info.hom := NaturalHomomorphismBySubspace(space,Subspace(space,kernel));
    info.basis := List(Basis(Range(info.hom)),
                  v->PreImagesRepresentative(info.hom,v));
    for i in info.where do
        i[3] := info.basis*i[3];
    od;
    return info;
end,
  NiceVector := function(V,v)
    local i, info, m, x;
    info := NiceFreeLeftModuleInfo(V);
    if IsBound(info.trivial) then
        if IsZero(v) then return []; else return fail; fi;
    fi;
    m := [];
    x := [];
    for i in info.where do
        Add(m,i[3]);
        Add(x,NestedMatrixCoefficient(v,i[1],i[2]));
    od;
    m := ShallowCopy(TransposedMat(m));
    Add(m,x);
    m := NullspaceMat(m);
    if m=[] then
        return fail;
    else
        m := -m[1]{[1..Length(m[1])-1]}/m[1][Length(m[1])];
        if (m*info.basis)*info.gens=v then
            return m;
        else
            return fail;
        fi;
    fi;
end,
  UglyVector := function(V,v)
    local info;
    info := NiceFreeLeftModuleInfo(V);
    if IsBound(info.trivial) then
        if v=[] then return Zero(V); else return fail; fi;
    fi;
    if v in Range(info.hom) then
        return PreImagesRepresentative(info.hom,v)*info.gens;
    else
        return fail;
    fi;
end));


InstallMethod(IsFiniteDimensional, "(FR) for an algebra of linear elements",
        # could be made a global method; but it's so primitive that
        # it's probably useless in general. Indeed it either returns true
        # or runs forever.
        [IsAlgebra and IsLinearFRElementSpace],
        function(A)
    local R, B, V, todo, t, v;

    R := LeftActingDomain(A);
    B := [];
    V := VectorSpace(R,B,Zero(A));
    todo := NewFIFO(GeneratorsOfAlgebra(A));

    for t in todo do
        if not t in V then
            Add(B, t);
            V := LeftModuleByGenerators(R, B);
            Append(todo, t*GeneratorsOfAlgebra(A));
        fi;
    od;
    return true; # else we're in an infinite loop
end);
############################################################################

#E linear.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . .ends here
