#############################################################################
##
#W vector.gi                                                Laurent Bartholdi
##
#H   @(#)$Id: vector.gi,v 1.24 2009/06/16 19:12:53 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  This file implements the category of linear machines and elements with a
##  vector space as stateset.
##
#############################################################################

############################################################################
##
#M  Minimized . . . . . . . . . . . . . . . . . . . .minimize linear machine
##
# mode=0 means normal
# mode=1 means all states are known to be accessible
# mode=2 means all states are known to be distinct and accessible
# boolean corr=true means compute correspondence
##
BindGlobal("MATRIX@", function(l,f)
    return List(l,__x->List(__x,f));
end);

BindGlobal("VECTORZEROM@", function(f,n,r)
    return VectorMachineNC(f,MATRIX@(IdentityMat(n),x->IdentityMat(0,r)),IdentityMat(0,r));
end);

BindGlobal("VECTORZEROE@", function(f,n,r)
    return VectorElementNC(f,MATRIX@(IdentityMat(n),x->IdentityMat(0,r)),IdentityMat(0,r),IdentityMat(0,r));
end);

BindGlobal("COEFF@", function(B,v)
    local x;
    x := Coefficients(B,v);
    ConvertToVectorRep(x);
    MakeImmutable(x);
    return x;
end);

BindGlobal("CONSTANTVECTOR@", function(S,x)
    local v;
    v := ListWithIdenticalEntries(Length(S),x);
    ConvertToVectorRep(v);
    return v;
end);

BindGlobal("VECTORMINIMIZE@", function(fam,r,transitions,output,input,mode,docorr)
    local B, i, n, v, V, W, t, m, todo, f, corr;

    if input<>fail then ConvertToVectorRep(input); fi;
    ConvertToVectorRep(output);
    for i in transitions do for i in i do
        ConvertToMatrixRep(i);
    od; od;
    if docorr then
        corr := IdentityMat(Length(output),r);
        MakeImmutable(corr);
    fi;
    if input<>fail and mode=0 and Length(output)>0 then
        todo := NewFIFO([input]);
        V := Subspace(r^Length(output),[]);
        for v in todo do
            if not v in V then
                V := ClosureLeftModule(V,v);
                for i in transitions do for i in i do
                    Add(todo,v*i);
                od; od;
            fi;
        od;
        if Dimension(V)<Length(input) then
            B := Basis(V);
            input := COEFF@(B,input);
            v := transitions;
            transitions := [];
            for i in v do
                t := [];
                for i in i do
                    m := List(B,x->COEFF@(B,x*i));
                    MakeImmutable(m);
                    ConvertToMatrixRep(m);
                    Add(t,m);
                od;
                Add(transitions,t);
            od;
            if docorr then
                corr := List(corr,v->COEFF@(B,v));
                MakeImmutable(corr);
                ConvertToMatrixRep(corr);
                Error("cannot happen");
            fi;
            if IsEmpty(B) then
                output := [];
            else
                output := B*output;
                ConvertToVectorRep(output);
                MakeImmutable(output);
            fi;
        fi;
    fi;
    if Length(output)=0 or IsZero(output) then
        if input=fail then
            f := VECTORZEROM@(fam,Length(transitions),r);
        else
            f := VECTORZEROE@(fam,Length(transitions),r);
        fi;
        if docorr then SetCorrespondence(f,[]); fi;
        return f;
    fi;
    if mode<=1 then
        todo := NewFIFO([output]);
        W := r^Length(output);
        V := Subspace(W,[]);
        for v in todo do
            if not v in V then
                V := ClosureLeftModule(V,v);
                for i in transitions do for i in i do
                    Add(todo,i*v);
                od; od;
            fi;
        od;
        if Dimension(V)<Length(output) then
            f := AsList(Basis(V));
            ConvertToMatrixRep(f);
            f := NaturalHomomorphismBySubspace(W,Subspace(W,NullspaceMat(TransposedMat(f))));
            B := Basis(Range(f));
            W := List(B,x->PreImagesRepresentative(f,x));
            ConvertToMatrixRep(W);
            if input <> fail then
                input := COEFF@(B,input^f);
            fi;
            v := transitions;
            transitions := [];
            for i in v do
                t := [];
                for i in i do
                    m := List(W,x->COEFF@(B,(x*i)^f));
                    MakeImmutable(m);
                    ConvertToMatrixRep(m);
                    Add(t,m);
                od;
                Add(transitions,t);
            od;
            if docorr then
                corr := List(corr,v->COEFF@(B,v^f));
                MakeImmutable(corr);
                ConvertToMatrixRep(corr);
            fi;
            output := W*output;
            ConvertToVectorRep(output);
            MakeImmutable(output);
        fi;
    fi;
    if input=fail then
        f := VectorMachineNC(fam,transitions,output);
    else
        todo := [input];
        V := Subspace(r^Length(output),[]);
        f := 1;
        while f <= Length(todo) do
            if todo[f] in V then
                Remove(todo,f);
            else
                V := ClosureLeftModule(V,todo[f]);
                for i in transitions do for i in i do
                    Add(todo,todo[f]*i);
                od; od;
                f := f+1;
            fi;
        od;
        if todo<>IdentityMat(Length(output),r) then
            B := BasisNC(V,todo);
            input := COEFF@(B,input);
            v := transitions;
            transitions := [];
            for i in v do
                t := [];
                for i in i do
                    m := List(B,x->COEFF@(B,x*i));
                    MakeImmutable(m);
                    ConvertToMatrixRep(m);
                    Add(t,m);
                od;
                Add(transitions,t);
            od;
            if docorr then
                corr := List(corr,v->COEFF@(B,v));
                MakeImmutable(corr);
                ConvertToMatrixRep(corr);
            fi;
            output := B*output;
            ConvertToVectorRep(output);
            MakeImmutable(output);
        fi;
        f := VectorElementNC(fam,transitions,output,input);
    fi;
    if docorr then
        SetCorrespondence(f,corr);
    fi;
    return f;
end);

InstallMethod(Minimized, "(FR) for a vector machine",
        [IsLinearFRMachine and IsVectorFRMachineRep],
        M->VECTORMINIMIZE@(FamilyObj(M),LeftActingDomain(M),
                M!.transitions,M!.output,fail,0,true));

InstallMethod(Minimized, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        E->VECTORMINIMIZE@(FamilyObj(E),LeftActingDomain(E),
                E!.transitions,E!.output,E!.input,0,true));

InstallMethod(IsMinimized, "(FR) for a vector machine",
        [IsLinearFRMachine and IsVectorFRMachineRep],
        M->Length(VECTORMINIMIZE@(FamilyObj(M),LeftActingDomain(M),
                M!.transitions,M!.output,fail,0,true)!.transitions[1][1]=Length(M!.transitions[1][1])));
############################################################################

InstallOtherMethod(KroneckerProduct, "generic method for nested lists",
        [IsObject, IsObject, IsInt],
        function(l1,l2,level)
    local i1, i2, row, kroneckerproduct;
    if level=0 then
        return l1 * l2;
    elif level=1 then
        kroneckerproduct := [];
        for i1 in l1 do Append(kroneckerproduct,i1*l2); od;
        ConvertToVectorRepNC(kroneckerproduct);
    else
        kroneckerproduct := [];
        for i1 in l1 do
            for i2 in l2 do
                Add(kroneckerproduct,KroneckerProduct(i1,i2,level-1));
            od;
        od;
    fi;
    return kroneckerproduct;
end);

#############################################################################
##
#O LeftActingDomain
##
InstallOtherMethod(LeftActingDomain, "(FR) for a linear machine",
        [IsLinearFRMachine],
        M->LeftActingDomain(AlphabetOfFRObject(M)));

InstallOtherMethod(LeftActingDomain, "(FR) for a linear element",
        [IsLinearFRElement],
        E->LeftActingDomain(AlphabetOfFRObject(E)));
############################################################################

############################################################################
##
#O Output(<Machine>, <State>)
#O Transition(<Machine>, <State>, <Input>, <Output>)
#O Transitions(<Machine>, <State>, <Input>)
##
InstallMethod(InitialState, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        E->E!.input);

InstallMethod(Output, "(FR) for a vector machine",
        [IsLinearFRMachine and IsVectorFRMachineRep,IsVector],
        function(M,s)
    return s*M!.output;
end);

InstallMethod(Output, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        M->M!.input*M!.output);

InstallMethod(Transitions, "(FR) for a vector machine",
        [IsLinearFRMachine and IsVectorFRMachineRep,IsVector,IsVector],
        function(M,s,a)
    return List(a*M!.transitions,v->s*v);
end);

InstallMethod(Transition, "(FR) for a vector machine",
        [IsLinearFRMachine and IsVectorFRMachineRep,IsVector,IsVector,IsVector],
        function(M,s,a,b)
    return s*(a*M!.transitions*b);
end);

InstallMethod(Transitions, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep,IsVector],
        function(M,a)
    return List(a*M!.transitions,v->M!.input*v);
end);

InstallOtherMethod(\[\], "(FR) for a vector element and an index",
        [IsLinearFRElement and IsVectorFRMachineRep,IsPosInt],
        function(E,i)
    return List(E!.transitions[i],v->VECTORMINIMIZE@(FamilyObj(E),LeftActingDomain(E),E!.transitions,E!.output,E!.input*v,0,false));
end);

InstallMethod(Transition, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep,IsVector,IsVector],
        function(M,a,b)
    return M!.input*(a*M!.transitions*b);
end);

InstallMethod(StateSet, "(FR) for a vector machine in vector rep",
        [IsLinearFRMachine and IsVectorFRMachineRep],
        M->LeftActingDomain(M)^Length(M!.output));

InstallMethod(StateSet, "(FR) for a vector element in vector rep",
        [IsLinearFRElement and IsVectorFRMachineRep],
        E->LeftActingDomain(E)^Length(E!.output));

InstallMethod(GeneratorsOfFRMachine, "(FR) for a vector machine",
        [IsLinearFRMachine and IsVectorFRMachineRep],
        M->Basis(StateSet(M)));

InstallOtherMethod(\^, "(FR) for a vector and a vector element",
        [IsVector, IsLinearFRElement and IsVectorFRMachineRep],
        function(v,e)
    return v*MATRIX@(e!.transitions,v->e!.input*v*e!.output);
end);

InstallMethod(Activity, "(FR) for a vector element and a level",
        [IsLinearFRElement and IsVectorFRMachineRep, IsInt],
        function(e,n)
    local i, m;
    if IsZero(e) then
        i := Dimension(AlphabetOfFRObject(e))^n;
        return NullMat(i,i,LeftActingDomain(e));
    fi;
    if n=0 then
        i := [[e!.input*e!.output]];
        ConvertToMatrixRep(i);
        return i;
    fi;
    m := MATRIX@(e!.transitions, function(v)
        v := [e!.input*v]; ConvertToMatrixRep(v); return v;
    end);
    for i in [2..n] do m := KroneckerProduct(m,e!.transitions,2); od;
    m := MATRIX@(m,v->v[1]*e!.output);
    i := ValueOption("blocks");
    if i=fail then
        ConvertToMatrixRep(m);
        return m;
    else
        return AsBlockMatrix(m,i,i);
    fi;
end);

InstallMethod(Activity, "(FR) for a linear element",
        [IsLinearFRElement],
        x->Activity(x,1));

InstallMethod(Activities, "(FR) for a vector element and a level",
        [IsLinearFRElement and IsVectorFRMachineRep, IsInt],
        function(e,n)
    local i, b, m, r, result;
    result := [[[e!.input*e!.output]]];
    m := e!.transitions;
    b := ValueOption("blocks");
    for i in [2..n] do
        r := MATRIX@(m,v->e!.input*v*e!.output);
        if b<>fail then
            r := AsBlockMatrix(r,b,b);
        fi;
        Add(result,r);
        if i<>n then m := KroneckerProduct(m,e!.transitions,2); fi;
    od;
    return result;
end);


ACTIVITYSPARSE@ := fail; # shut up warning
ACTIVITYSPARSE@ := function(l,e,v,n,x,y)
    local d, p, i, j;
    if IsZero(v) then return; fi;
    if n=0 then
        d := v*e!.output;
        if not IsZero(d) then
            p := PositionFirstComponent(l,[x,y]);
            if IsBound(l[p]) and l[p][1]=[x,y] then
                l[p][2] := l[p][2] + d;
            else
                Add(l,[[x,y],d],p);
            fi;
        fi;
    else
        d := Length(e!.transitions);
        for i in [1..d] do for j in [1..d] do
            ACTIVITYSPARSE@(l,e,v*e!.transitions[i][j],n-1,(x-1)*d+i,(y-1)*d+j);
        od; od;
    fi;
end;
MakeReadOnlyGlobal("ACTIVITYSPARSE@");

InstallMethod(ActivitySparse, "(FR) for a vector element and a level",
        [IsLinearFRElement and IsVectorFRMachineRep, IsInt],
        function(e,n)
    local l;
    l := [];
    ACTIVITYSPARSE@(l,e,e!.input,n,1,1);
    return l;
end);

BindGlobal("VECTORLIMITSTATES@", function(E)
    local V, W, i, j;

    W := StateSet(E);
    repeat
        V := W;
        W := Subspace(V,[]);
        for i in Basis(V) do
            for j in E!.transitions do for j in j do
                W := ClosureLeftModule(W,i*j);
            od; od;
        od;
    until V=W;
    return W;
end);

InstallMethod(LimitStates, "(FR) for a vector machine",
        [IsLinearFRMachine and IsVectorFRMachineRep],
        VECTORLIMITSTATES@);

InstallMethod(LimitStates, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        VECTORLIMITSTATES@);

InstallOtherMethod(State, "(FR) for a vector element and two vectors",
        [IsLinearFRElement and IsVectorFRMachineRep, IsVector, IsVector],
        function(E,a,b)
    return VECTORMINIMIZE@(FamilyObj(E),LeftActingDomain(E),E!.transitions,E!.output,E!.input*(a*E!.transitions*b),0,false);
end);

InstallOtherMethod(NestedMatrixState, "(FR) for a vector element and two lists",
        [IsLinearFRElement and IsVectorFRMachineRep, IsList, IsList],
        function(E,ilist,jlist)
    local x, n;
    x := E!.input;
    for n in [1..Length(ilist)] do
        x := x*E!.transitions[ilist[n]][jlist[n]];
    od;
    return VECTORMINIMIZE@(FamilyObj(E),LeftActingDomain(E),E!.transitions,E!.output,x,0,false);
end);

InstallOtherMethod(NestedMatrixCoefficient, "(FR) for a vector element and two lists",
        [IsLinearFRElement and IsVectorFRMachineRep, IsList, IsList],
        function(E,ilist,jlist)
    local x, n;
    x := E!.input;
    for n in [1..Length(ilist)] do
        x := x*E!.transitions[ilist[n]][jlist[n]];
    od;
    return x*E!.output;
end);

InstallMethod(DecompositionOfFRElement, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        function(E)
    return MATRIX@(E!.transitions,v->VECTORMINIMIZE@(FamilyObj(E),LeftActingDomain(E),E!.transitions,E!.output,E!.input*v,0,false));
end);

InstallMethod(IsConvergent, "(FR) for a vector element",
        [IsLinearFRElement],
        E->DecompositionOfFRElement(E)[1][1]=E);

InstallMethod(States, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        E->VectorSpace(LeftActingDomain(E),
                List(Basis(StateSet(E)),s->FRElement(E,s))));

InstallOtherMethod(States, "(FR) for a vector machine",
        [IsLinearFRMachine and IsVectorFRMachineRep],
        StateSet);

BindGlobal("DECOMPMATRIX@", function(m,d,n)
    local result, N, i, j, k;
    result := List([1..d],i->List([1..d],j->[]));
    for k in [2..n] do
        N := d^(k-2);
        for i in [1..d] do
            for j in [1..d] do
                Add(result[i][j],m[k]{[(i-1)*N+1..i*N]}{[(j-1)*N+1..j*N]});
            od;
        od;
    od;
    return result;
end);

BindGlobal("GUESSMATRIX@", function(r,matlist,d)
    local spaces, bases, trans, inp, out, i, ii, j, jj, k, m, n, todo, c, x;

    n := Length(matlist);
    if n<=1 then return fail; fi;
    if IsZero(matlist[n]) then
        return VECTORZEROE@(FREFamily(r^d),d,r);
    fi;
    spaces := [];
    bases := [];
    for i in [1..n] do
        c := [Flat(matlist{[1..i]})];
        Add(spaces,VectorSpace(r,c));
        Add(bases,Basis(spaces[i],c));
    od;
    trans := List([1..d],i->List([1..d],j->[]));
    out := [];
    inp := [];
    todo := [matlist];
    for m in todo do
        Add(out,m[1][1][1]);
        if inp=[] then
            Add(inp,One(r));
        else
            Add(inp,Zero(r));
        fi;
        n := Length(m)-1;
        m := DECOMPMATRIX@(m,d,n+1);
        if spaces[n]=fail then return fail; fi;
        for i in [1..d] do
            for j in [1..d] do
                x := Flat(m[i][j]);
                c := Coefficients(bases[n],x);
                if c=fail then
                    Add(todo,m[i][j]);
                    for ii in [1..d] do for jj in [1..d] do
                        for k in trans[ii][jj] do
                            Add(k,Zero(r));
                        od;
                    od; od;
                    for k in [1..n] do
                        c := Flat(m[i][j]{[1..k]});
                        if spaces[k]=fail or c in spaces[k] then
                            spaces[k] := fail;
                        else
                            spaces[k] := ClosureLeftModule(spaces[k],c);
                            bases[k] := Basis(spaces[k],Concatenation(bases[k],[c]));
                        fi;
                    od;
                    c := Coefficients(bases[n],x);
                fi;
                Add(trans[i][j],c);
            od;
        od;
    od;
    return VectorElement(r,trans,out,inp);
end);

InstallGlobalFunction(GuessVectorElement, "(FR) for a matrix[list], ring, degree",
        function(arg)
    local n, r, d, matlist, i;
    for i in arg do
        if IsInt(i) then
            if IsBound(d) then Error("Degree specified twice"); fi;
            d := i;
        elif IsList(i) then
            if IsBound(matlist) then Error("Matrix specified twice"); fi;
            matlist := i;
        elif IsRing(i) then
            if IsBound(r) then Error("Ring specified twice"); fi;
            r := i;
        fi;
    od;
    if not IsBound(matlist) then Error("Matrix not specified"); fi;
    if IsMatrix(matlist) then
        if not IsBound(d) then
            d := PrimePowersInt(Length(matlist));
            if Length(d)>2 then
                Error("Cannot guess degree d");
            fi;
            d := d[1];
        fi;
        n := LogInt(Length(matlist),d);
        if Length(matlist)<>d^n then
            Error("Matrix dimension must be d^n for some n");
        fi;
        matlist := List([0..n],i->matlist{[1..d^i]}{[1..d^i]});
    else
        n := Length(matlist);
        if not IsBound(d) then
            if n>1 then d := Length(matlist[2]); else d := 0; fi;
        fi;
        if not ForAll([1..n],i->IsMatrix(matlist[i]) and Length(matlist[i][1])=d^(i-1)) then
            Error("<matlist> should be a list of matrices of size 1,d,d^2,...,d^n");
        fi;
    fi;
    if not IsBound(r) then
        r := FieldOfMatrixList(matlist);
    fi;
    return GUESSMATRIX@(r,matlist,d);
end);

InstallMethod(TransposedFRElement, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        function(E)
    return VECTORMINIMIZE@(FamilyObj(E),LeftActingDomain(E),
                   TransposedMat(E!.transitions),E!.output,E!.input,2,false);
end);

BindGlobal("ISTRIANGULARVECTOR@", function(e,prop)
    local V, x, n, v, w, i, j, todo;
    V := TrivialSubspace(StateSet(e));
    n := Length(e!.transitions);
    todo := NewFIFO([e!.input]);
    for v in todo do
        if not v in V then
            V := ClosureLeftModule(V,v);
            for i in [1..n] do
                for j in [1..n] do
                    w := v*e!.transitions[i][j];
                    if i<j and prop in [IsDiagonalFRElement,IsLowerTriangularFRElement] and not IsZero(w) then
                        return false;
                    elif i>j and prop in [IsDiagonalFRElement,IsUpperTriangularFRElement] and not IsZero(w) then
                        return false;
                    elif i=j then
                        Add(todo,w);
                    fi;
                od;
            od;
        fi;
    od;
    return true;
end);

InstallMethod(IsSymmetricFRElement, "(FR) for a linear element",
        [IsLinearFRElement],
        E->E=TransposedFRElement(E));

InstallMethod(IsAntisymmetricFRElement, "(FR) for a linear element",
        [IsLinearFRElement],
        E->E=-TransposedFRElement(E));

InstallMethod(IsLowerTriangularFRElement, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        E->ISTRIANGULARVECTOR@(E,IsLowerTriangularFRElement));

InstallMethod(IsUpperTriangularFRElement, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        E->ISTRIANGULARVECTOR@(E,IsUpperTriangularFRElement));

InstallMethod(IsDiagonalFRElement, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        E->ISTRIANGULARVECTOR@(E,IsDiagonalFRElement));

InstallMethod(LDUDecompositionFRElement, "(FR) for an FR element",
        [IsLinearFRElement],
        function(A)
    local F, L, D, U, gL, gD, gU, s, n;

    F := LeftActingDomain(A);
    L := [];
    D := [];
    U := [];
    n := 0;
    while true do
        s := SemiEchelonMatTransformation(Activity(A,n));
        n := n+1;
        Add(U,s.vectors);
        s := s.coeffs;
        Add(D,DiagonalMat(List([1..Length(s)],i->s[i][i]^-1)));
        Add(L,s^-1/D[n]);
        if n=1 then continue; fi;
        gL := GuessVectorElement(L,F);
        if gL=fail then continue; fi;
        gD := GuessVectorElement(D,F);
        if gD=fail then continue; fi;
        gU := GuessVectorElement(U,F);
        if gU=fail then continue; fi;
        if gL*gD*gU=A then
            return [gL,gD,gU];
        fi;
        Info(InfoFR, 2, "LDUDecompositionFRElement: trying at level ",n);
    od;
end);
############################################################################

############################################################################
##
#O  VectorMachine
#O  VectorElement
##
BindGlobal("VECTORCHECK@", function(transitions,output,input)
    local m, n, i, j;
    if input<>fail then
        MakeImmutable(input);
        ConvertToVectorRep(input);
    fi;
    MakeImmutable(output);
    ConvertToVectorRep(output);
    n := Length(output);
    if input<>fail and Length(input)<>n then
        Error("input and output should have the same length");
    fi;
    m := Length(transitions);
    for i in [1..m] do
        if Length(transitions[i])<>m then
            Error("transitions should be a square matrix");
        fi;
        for j in transitions[i] do
            if Length(j)<>n or ForAny(j,x->Length(x)<>n) then
                Error("transitions[i,j] should be a ",n,"x",n,"-matrix");
            fi;
            MakeImmutable(j);
            ConvertToMatrixRep(j);
        od;
    od;
end);

InstallMethod(VectorMachineNC, "(FR) for lists of transitions and output",
        [IsFamily,IsTransitionTensor,IsVector],
        function(f,transitions,output)
    local M;
    M := Objectify(NewType(f, IsLinearFRMachine and IsVectorFRMachineRep),
                 rec(transitions := transitions,
                     output := output));
    return M;
end);

InstallMethod(VectorMachine, "(FR) for lists of transitions and output",
        [IsRing,IsTransitionTensor,IsVector],
        function(r,transitions,output)
    VECTORCHECK@(transitions,output,fail);
    return VectorMachineNC(FRMFamily(r^Length(transitions)),
                   One(r)*transitions,One(r)*output);
end);

InstallMethod(UnderlyingFRMachine, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        function(E)
    return VectorMachineNC(FRMFamily(E),E!.transitions,E!.output);
end);

InstallMethod(VectorElementNC, "(FR) for lists of transitions, output and input",
        [IsFamily,IsTransitionTensor,IsVector,IsVector],
        function(f,transitions,output,input)
    local E;
    E := Objectify(NewType(f, IsLinearFRElement and IsVectorFRMachineRep),
                 rec(input := input,
                     transitions := transitions,
                     output := output));
    return E;
end);

InstallMethod(VectorElement, "(FR) for lists of transitions, output and input",
        [IsRing,IsTransitionTensor,IsVector,IsVector],
        function(r,transitions,output,input)
    VECTORCHECK@(transitions,output,input);
    return VECTORMINIMIZE@(FREFamily(r^Length(transitions)),r,
                   One(r)*transitions,One(r)*output,One(r)*input,0,false);
end);

InstallMethod(FRElement, "(FR) for a vector machine and a state",
        [IsLinearFRMachine and IsVectorFRMachineRep, IsVector],
        function(M,s)
    return VECTORMINIMIZE@(FREFamily(M),LeftActingDomain(M),M!.transitions,M!.output,s,0,false);
end);

InstallMethod(FRElement, "(FR) for a vector element and a state",
        [IsLinearFRElement and IsVectorFRMachineRep, IsVector],
        function(E,s)
    return VECTORMINIMIZE@(FamilyObj(E),LeftActingDomain(E),E!.transitions,E!.output,s,2,false);
end);

InstallMethod(FRElement, "(FR) for a vector machine and a state index",
        [IsLinearFRMachine and IsVectorFRMachineRep, IsInt],
        function(M,s)
    if IsZero(M) then
        return VECTORZEROE@(FREFamily(M),Dimension(AlphabetOfFRObject(M)),LeftActingDomain(M));
    fi;
    return VECTORMINIMIZE@(FREFamily(M),LeftActingDomain(M),M!.transitions,M!.output,\[\](M!.transitions[1][1]^0,s),0,false);
end);

InstallMethod(FRElement, "(FR) for a vector element and a state index",
        [IsLinearFRElement and IsVectorFRMachineRep, IsInt],
        function(E,s)
    if IsZero(E) then
        return VECTORZEROE@(FamilyObj(E),Dimension(AlphabetOfFRObject(E)),LeftActingDomain(E));
    fi;
    return VECTORMINIMIZE@(FamilyObj(E),LeftActingDomain(E),E!.transitions,E!.output,\[\](E!.transitions[1][1]^0,s),2,false);
end);
#############################################################################

#############################################################################
##
#M ViewObj
#M String
#M Display
##
InstallMethod(ViewObj, "(FR) for a vector machine",
        [IsLinearFRMachine and IsVectorFRMachineRep],
        function(M)
    Print("<Linear machine on alphabet ", LeftActingDomain(M), "^",
          Length(M!.transitions), " with ",
          Length(M!.output), "-dimensional stateset>");
end);

InstallMethod(ViewObj, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        function(E)
    local skip;
    if IsZero(E) then
        Print("<Zero l"); skip := true;
    elif IsOne(E) then
        Print("<Identity l"); skip := true;
    else
        Print("<L"); skip := false;
    fi;
    Print("inear element on alphabet ", LeftActingDomain(E), "^",
          Length(E!.transitions));
    if not skip then
        Print(" with ", Length(E!.output), "-dimensional stateset");
    fi;
    Print(">");
end);

InstallMethod(String, "(FR) vector machine to string",
        [IsLinearFRMachine and IsVectorFRMachineRep],
        function(M)
    return Concatenation("VectorMachine(",String(LeftActingDomain(M)),", ",
                   String(M!.transitions),", ",
                   String(M!.output),")");
end);

InstallMethod(String, "(FR) vector element to string",
        [IsLinearFRElement and IsVectorFRMachineRep],
        function(E)
    return Concatenation("VectorElement(",String(LeftActingDomain(E)),", ",
                   String(E!.transitions),", ",
                   String(E!.output),", ",String(E!.input),")");
end);

BindGlobal("VECTORDISPLAY@", function(M)
    local r, i, j, k, l, m, n, xlen, xprint, xrule, headlen, headrule, headblank;
    r := LeftActingDomain(M);
    n := Length(M!.transitions);
    m := Length(M!.output);
    if IsFFECollection(r) and DegreeOverPrimeField(r)=1 then
        xlen := LogInt(Characteristic(r),10)+2;
        xprint := function(x) if IsZero(x) then return String(".",xlen-1); else return String(IntFFE(x),xlen-1); fi; end;
    else
        xlen := Maximum(List(Flat(M!.transitions),x->Length(String(x))))+1;
        xprint := x->String(x,xlen-1);
    fi;
    xrule := ListWithIdenticalEntries(xlen,'-');
    headlen := Length(String(r))+1;
    headrule := ListWithIdenticalEntries(headlen,'-');
    headblank := ListWithIdenticalEntries(headlen,' ');

    Print(String(r,headlen)," |");
    for i in [1..n] do
        Print(String(i,QuoInt(xlen*m,2)+1),String("",xlen*m-QuoInt(xlen*m,2)),"|");
    od;
    Print("\n");
    Print(headrule, "-+");
    for i in [1..n] do
        for j in [1..m] do Print(xrule); od;
        Print("-+");
    od;
    Print("\n");
    for i in [1..n] do
        Print(String(i,headlen)," ");
        if m>=1 then
            Print("|");
            for j in [1..m] do
                if j>1 then Print(headblank," |"); fi;
                for k in [1..n] do
                    for l in [1..m] do
                        Print(" ",xprint(M!.transitions[i][k][j][l]));
                    od;
                    Print(" |");
                od;
                Print("\n");
            od;
            Print(headrule,"-");
        fi;
        Print("+");
        for i in [1..n] do
            for j in [1..m] do Print(xrule); od;
            Print("-+");
        od;
        Print("\n");
    od;
    Print("Output:");
    for i in [1..m] do
        Print(" ",xprint(M!.output[i]));
    od;
    Print("\n");
    if IsLinearFRElement(M) then
        Print("Initial state:");
        for i in [1..m] do
            Print(" ",xprint(M!.input[i]));
        od;
        Print("\n");
    fi;
end);

InstallMethod(Display, "(FR) for a vector machine",
        [IsLinearFRMachine and IsVectorFRMachineRep],
        VECTORDISPLAY@);

InstallMethod(Display, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        VECTORDISPLAY@);
#############################################################################

#############################################################################
##
#M AsVectorMachine
#M AsVectorElement
##
BindGlobal("DELTA@", function(x) if x then return 1; else return 0; fi; end);

BindGlobal("ASVECTORMACHINE@", function(r,M)
    local id, V;
    id := IdentityMat(Size(StateSet(M)),r);
    V := VectorMachineNC(FRMFamily(r^Size(AlphabetOfFRObject(M))),
                 List(AlphabetOfFRObject(M),i->List(AlphabetOfFRObject(M),j->List(StateSet(M),s->DELTA@(Output(M,s,i)=j)*id[Transition(M,s,i)]))),
                 CONSTANTVECTOR@(StateSet(M),One(r)));
    SetCorrespondence(V,id);
    return V;
end);

InstallMethod(AsVectorMachine, "(FR) for a Mealy machine",
        [IsRing,IsMealyMachine and IsMealyMachineIntRep],
        ASVECTORMACHINE@);

InstallMethod(AsVectorMachine, "(FR) for a FR machine",
        [IsRing,IsFRMachine],
        function(r,M)
    local N, V;
    Info(InfoFR,2,"AsVectorMachine: converting to Mealy machine");
    N := AsMealyMachine(M);
    V := ASVECTORMACHINE@(r,N);
    V!.Correspondence := Correspondence(V){Correspondence(N)};
    return V;
end);

InstallMethod(AsLinearMachine, "(FR) for a Mealy machine",
        [IsRing,IsMealyMachine and IsMealyMachineIntRep],
        ASVECTORMACHINE@);

BindGlobal("ASVECTORELEMENT@", function(r,E)
    local id, V;
    id := IdentityMat(Size(StateSet(E)),r);
    V := VECTORMINIMIZE@(FREFamily(r^Size(AlphabetOfFRObject(E))),r,
                 List(AlphabetOfFRObject(E),i->List(AlphabetOfFRObject(E),j->List(StateSet(E),s->DELTA@(Output(E,s,i)=j)*id[Transition(E,s,i)]))),
                 CONSTANTVECTOR@(StateSet(E),One(r)),
                 IdentityMat(Size(StateSet(E)),r)[1],0,true);
    return V;
end);

InstallMethod(AsVectorElement, "(FR) for a Mealy element",
        [IsRing,IsMealyElement and IsMealyMachineIntRep],
        ASVECTORELEMENT@);

InstallMethod(AsVectorElement, "(FR) for a FR element",
        [IsRing,IsFRElement],
        function(r,E)
    Info(InfoFR,2,"AsVectorMachine: converting to Mealy machine");
    return ASVECTORELEMENT@(r,AsMealyElement(E));
end);

InstallMethod(AsLinearElement, "(FR) for a Mealy element",
        [IsRing,IsMealyElement and IsMealyMachineIntRep],
        ASVECTORELEMENT@);

InstallMethod(AsMealyElement, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        function(E)
    local states, trans, out, t, o, x, y, s, i;
    states := [E];
    trans := [];
    out := [];
    for s in states do
        t := []; o := [];
        for i in DecompositionOfFRElement(s) do
            x := Filtered([1..Length(i)],x->not IsZero(i[x]));
            if Length(x)<>1 then
                return fail;
            fi;
            x := x[1];
            Add(o,x);
            x := i[x];
            y := Position(states,x);
            if y=fail then
                Add(states,x);
                Add(t,Length(states));
                if RemInt(Length(states),100)=0 then
                    Info(InfoFR,3,"AsMealyElement: at least ",Length(states)," states");
                fi;
            else
                Add(t,y);
            fi;
        od;
        Add(trans,t);
        Add(out,o);
    od;
    return MealyElement(trans,out,1);
end);

InstallMethod(TopElement, "(FR) for a ring and a matrix",
        [IsRing, IsMatrix],
        function(r,m)
    if IsOne(m) then
        return VectorElementNC(FRMFamily(r^Length(m)),
                       One(r)*MATRIX@(m,x->[[x]]),[One(r)],[One(r)]);
    else
        return VectorElementNC(FRMFamily(r^Length(m)),
                       One(r)*(MATRIX@(m,x->[[0,x],[0,0]])+MATRIX@(m^0,x->[[0,0],[0,x]])),
            [One(r),One(r)],[One(r),Zero(r)]);
    fi;
end);
#############################################################################

############################################################################
##
#M  InverseOp
#M  OneOp
#M  ZeroOp
##
InstallMethod(IsInvertible, "(FR) for a linear element",
        [IsLinearFRElement],
        E->InverseOp(E)<>fail);

InstallMethod(InverseOp, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        function(E)
    local A, n, F;
    n := LogInt(20,Dimension(AlphabetOfFRObject(E)));
    A := List(Activities(E,n),Inverse);
    repeat
        Add(A,Inverse(Activity(E,n)));
        if A[n+1]=fail then return fail; fi;
        F := GuessVectorElement(LeftActingDomain(E),A);
        if F<>fail and IsOne(F*E) then return F; fi;
        n := n+1;
        Info(InfoFR, 2, "InverseOp: extending to depth ",n);
    until false;
end);

InstallMethod(OneOp, "(FR) for a vector machine",
        [IsLinearFRMachine and IsVectorFRMachineRep],
        function(M)
    return VectorMachineNC(FamilyObj(M),
                   MATRIX@(IdentityMat(Length(M!.transitions),LeftActingDomain(M)),x->[[x]]),
                   [One(LeftActingDomain(M))]);
end);

InstallMethod(OneOp, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        function(E)
    return VectorElementNC(FamilyObj(E),
                   MATRIX@(IdentityMat(Length(E!.transitions),LeftActingDomain(E)),x->[[x]]),
                   [One(LeftActingDomain(E))],
                   [One(LeftActingDomain(E))]);
end);

InstallMethod(ZeroOp, "(FR) for a vector machine",
        [IsLinearFRMachine and IsVectorFRMachineRep],
        M->VECTORZEROM@(FamilyObj(M),Length(M!.transitions),
                LeftActingDomain(M)));

InstallMethod(ZeroOp, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        E->VECTORZEROE@(FamilyObj(E),Length(E!.transitions),
                LeftActingDomain(E)));

BindGlobal("VECTORPLUS@", function(M,N)
    local i, j, t, x, zM, zN, transitions, output, input;

    if IsZero(M) then return N; fi;
    if IsZero(N) then return M; fi; # otherwise zM, zN are undefined

    transitions := [];
    zM := 0*M!.output;
    zN := 0*N!.output;
    for i in [1..Length(M!.transitions)] do
        t := [];
        for j in [1..Length(M!.transitions)] do
            x := List(M!.transitions[i][j],r->Concatenation(r,zN));
            Append(x,List(N!.transitions[i][j],r->Concatenation(zM,r)));
            MakeImmutable(x);
            ConvertToMatrixRepNC(x);
            Add(t,x);
        od;
        Add(transitions,t);
    od;
    output := Concatenation(M!.output,N!.output);
    MakeImmutable(output);
    ConvertToVectorRepNC(output);
    if IsLinearFRElement(M) then
        input := Concatenation(M!.input,N!.input);
        MakeImmutable(input);
        ConvertToVectorRepNC(input);
        return VECTORMINIMIZE@(FamilyObj(M),LeftActingDomain(M),
                       transitions,output,input,0,false);
    else
        return VectorMachineNC(FamilyObj(M),transitions,output);
    fi;
end);

InstallMethod(\+, "for two vector machines", IsIdenticalObj,
        [IsLinearFRMachine and IsVectorFRMachineRep,
         IsLinearFRMachine and IsVectorFRMachineRep],
        VECTORPLUS@);

InstallMethod(\+, "for two vector elements", IsIdenticalObj,
        [IsLinearFRElement and IsVectorFRMachineRep,
         IsLinearFRElement and IsVectorFRMachineRep],
        VECTORPLUS@);

InstallMethod(\*, "for a scalar and a vector machine",
        [IsScalar,IsLinearFRMachine and IsVectorFRMachineRep],
        function(x,M)
    return VectorMachineNC(FamilyObj(M),M!.transitions,x*M!.output);
end);

InstallMethod(\*, "for a vector machine and a scalar",
        [IsLinearFRMachine and IsVectorFRMachineRep,IsScalar],
        function(M,x)
    return VectorMachineNC(FamilyObj(M),M!.transitions,M!.output*x);
end);

InstallMethod(\+, "for a scalar and a vector element",
        [IsScalar,IsLinearFRElement and IsVectorFRMachineRep],
        function(x,E)
    return x*One(E)+E;
end);

InstallMethod(\+, "for a vector element and a scalar",
        [IsLinearFRElement and IsVectorFRMachineRep,IsScalar],
        function(E,x)
    return E+x*One(E);
end);

InstallMethod(AINV, "for a vector machine",
        [IsLinearFRMachine and IsVectorFRMachineRep],
        function(M)
    return VectorMachineNC(FamilyObj(M),M!.transitions,-M!.output);
end);

InstallMethod(AINV, "for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        function(E)
    return VectorElementNC(FamilyObj(E),E!.transitions,-E!.output,E!.input);
end);

BindGlobal("VECTORTIMES@", function(M,N)
    local i, j, k, t, x, transitions, output, input;

    if Length(M!.output)=0 or Length(N!.output)=0 then
        return Zero(M);
    fi;
    transitions := [];
    for i in [1..Length(M!.transitions)] do
        t := [];
        for k in [1..Length(M!.transitions)] do
            x := Sum([1..Length(M!.transitions)],j->KroneckerProduct(M!.transitions[i][j],N!.transitions[j][k]));
            Add(t,x);
        od;
        Add(transitions,t);
    od;
    output := KroneckerProduct(M!.output,N!.output,1);

    if IsLinearFRElement(M) then
        input := KroneckerProduct(M!.input,N!.input,1);
        MakeImmutable(input);
        ConvertToVectorRepNC(input);
        x := VECTORMINIMIZE@(FamilyObj(M),LeftActingDomain(M),
                       transitions,output,input,0,false);
    else
        x := VectorMachineNC(FamilyObj(M),transitions,output);
    fi;
    return x;
end);

InstallMethod(\*, "for two vector machines", IsIdenticalObj,
        [IsLinearFRMachine and IsVectorFRMachineRep,
         IsLinearFRMachine and IsVectorFRMachineRep],
        VECTORTIMES@);

InstallMethod(\*, "for two vector elements", IsIdenticalObj,
        [IsLinearFRElement and IsVectorFRMachineRep,
         IsLinearFRElement and IsVectorFRMachineRep], 1000,
        VECTORTIMES@);

InstallMethod(\*, "for a scalar and a vector element",
        [IsScalar,IsLinearFRElement and IsVectorFRMachineRep],
        function(x,E)
    return VECTORMINIMIZE@(FamilyObj(E),LeftActingDomain(E),
                   E!.transitions,x*E!.output,E!.input,1,false);
end);

InstallMethod(\*, "for a vector element and a scalar",
        [IsLinearFRElement and IsVectorFRMachineRep,IsScalar],
        function(E,x)
    return VECTORMINIMIZE@(FamilyObj(E),LeftActingDomain(E),
                   E!.transitions,E!.output*x,E!.input,1,false);
end);
############################################################################

############################################################################
##
#M  IsOne
#M  IsZero
#M  =
#M  <
##
InstallMethod(\=, "(FR) for two vector machines", IsIdenticalObj,
        [IsLinearFRMachine and IsVectorFRMachineRep,
         IsLinearFRMachine and IsVectorFRMachineRep],
        function(M,N)
    return M!.transitions=N!.transitions and M!.output=N!.output;
end);

InstallMethod(\<, "(FR) for two vector machines", IsIdenticalObj,
        [IsLinearFRMachine and IsVectorFRMachineRep,
         IsLinearFRMachine and IsVectorFRMachineRep],
        function(M,N)
    return M!.transitions<N!.transitions or
           (M!.transitions=N!.transitions and M!.output<N!.output);
end);

InstallMethod(IsOne, "(FR) for a vector machine",
        [IsLinearFRMachine and IsVectorFRMachineRep],
        function(M)
    local n, i, j, r;
    n := Length(M!.transitions);
    r := LeftActingDomain(M);
    for i in [1..n] do for j in [1..n] do
        if (i=j and M!.transitions[i][j]<>[[One(r)]]) or
           (i<>j and M!.transitions[i][j]<>[[Zero(r)]]) then
            return false;
        fi;
    od; od;
    return M!.output=[One(r)];
end);

InstallMethod(IsZero, "(FR) for a vector machine",
        [IsLinearFRMachine and IsVectorFRMachineRep],
        function(M)
    return Length(M!.output)=0;
end);

InstallMethod(\=, "(FR) for two vector elements", IsIdenticalObj,
        [IsLinearFRElement and IsVectorFRMachineRep,
         IsLinearFRElement and IsVectorFRMachineRep],
        function(M,N)
    return M!.transitions=N!.transitions and M!.output=N!.output;
end);

InstallMethod(\<, "(FR) for two vector elements", IsIdenticalObj,
        [IsLinearFRElement and IsVectorFRMachineRep,
         IsLinearFRElement and IsVectorFRMachineRep],
        function(M,N)
    local i, j, Mt, Nt, a;
    i := 1;
    a := [1..Length(N!.transitions)];
    repeat
        if not IsBound(N!.output[i]) then
            return false; # either left longer, or equal elements
        elif not IsBound(M!.output[i]) then
            return true; # SHORTlex, right longer
        elif M!.output[i]<>N!.output[i] then
            return M!.output[i]<N!.output[i]; # shortLEX
        else
            for j in [1..i] do
                Mt := M!.transitions{a}{a}[i][j];
                Nt := N!.transitions{a}{a}[i][j];
                if Mt<>Nt then
                    return Mt<Nt;
                fi;
            od;
            for j in [1..i-1] do
                Mt := M!.transitions{a}{a}[j][i];
                Nt := N!.transitions{a}{a}[j][i];
                if Mt<>Nt then
                    return Mt<Nt;
                fi;
            od;
        fi;
        i := i+1;
    until false;
end);

InstallMethod(IsOne, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        function(E)
    local n, i, j, r;
    n := Length(E!.transitions);
    r := LeftActingDomain(E);
    for i in [1..n] do for j in [1..n] do
        if (i=j and E!.transitions[i][j]<>[[One(r)]]) or
           (i<>j and E!.transitions[i][j]<>[[Zero(r)]]) then
            return false;
        fi;
    od; od;
    return E!.output=[One(r)];
end);

InstallMethod(IsZero, "(FR) for a vector element",
        [IsLinearFRElement and IsVectorFRMachineRep],
        function(E)
    return Length(E!.output)=0;
end);
############################################################################

############################################################################
##
#M  Nice basis
##
InstallHandlingByNiceBasis("IsVectorFRElementSpace", rec(
        detect := function(R,l,V,z)
    if IsEmpty(l) then
        return IsLinearFRElement(z) and IsVectorFRMachineRep(z)
               and LeftActingDomain(z)=R;
    else
        return ForAll(l,x->IsLinearFRElement(x) and IsVectorFRMachineRep(x)
                      and LeftActingDomain(x)=R);
    fi;
end,
  NiceFreeLeftModuleInfo := function(V)
    local m, b, init;
    b := GeneratorsOfLeftModule(V);
    if IsEmpty(b) or ForAll(b,IsZero) then
        return rec(machine := UnderlyingFRMachine(Zero(V)),
                   space := VectorSpace(LeftActingDomain(V),[],Zero(LeftActingDomain(V))),
                   dim := 0);
    fi;
    m := Minimized(Sum(List(b,UnderlyingFRMachine)));
    init := List([1..Length(b)],i->Concatenation(List([1..Length(b)],
                 j->DELTA@(i=j)*AsList(b[j]!.input))));
    # need "AsList" because NullMapMatrix is not a list :(

    return rec(machine := m,
               space := VectorSpace(LeftActingDomain(V),init*Correspondence(m)),
               dim := Length(m!.output));
end,
  NiceVector := function(V,v)
    local i, x, n, w;
    i := NiceFreeLeftModuleInfo(V);
    if IsZero(v) then
        return Zero(i.space);
    fi;
    n := Minimized(i.machine+UnderlyingFRMachine(v));
    if Length(n!.output)>Length(i.machine!.output) then
        return fail;
    else
        x := v!.input*Correspondence(n){[1..Length(v!.output)]+i.dim};
        if x in i.space then
            return x;
        else
            return fail;
        fi;
    fi;
end,
  UglyVector := function(V,v)
    local i;
    i := NiceFreeLeftModuleInfo(V);
    if v in i.space then
        if IsTrivial(i.space) then # avoid GAP bug with 0-dimensional space
            return FRElement(i.machine,NullMapMatrix);
        fi;
        return FRElement(i.machine,v);
    else
        return fail;
    fi;
end));
############################################################################

#E vector.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . .ends here
