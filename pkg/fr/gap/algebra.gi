#############################################################################
##
#W algebra.gi                                               Laurent Bartholdi
##
#H   @(#)$Id: algebra.gi,v 1.30 2011/06/13 22:54:33 gap Exp $
##
#Y Copyright (C) 2007, Laurent Bartholdi
##
#############################################################################
##
##  This file implements self-similar associative algebras.
##
#############################################################################

InstallAccessToGenerators(IsFRAlgebra,
        "(FR) for a FR algebra",GeneratorsOfAlgebra);

InstallAccessToGenerators(IsFRAlgebraWithOne,
        "(FR) for a FR algebra-with-one",GeneratorsOfAlgebraWithOne);

#############################################################################
##
#M AlphabetOfFRAlgebra
##
InstallMethod(AlphabetOfFRAlgebra, "(FR) for an FR algebra",
        [IsFRAlgebra],
        G->AlphabetOfFRObject(Representative(G)));
#############################################################################

#############################################################################
##
#O SCAlgebra
#O SCAlgebraWithOne
##
InstallMethod(AlgebraHomomorphismByFunction, "(FR) for two algebras and a function",
        [IsAlgebra,IsAlgebra,IsFunction],
        function(S,R,f)
    return Objectify(TypeOfDefaultGeneralMapping(S,R,
                   IsSPGeneralMapping and IsAlgebraGeneralMapping
                   and IsMappingByFunctionRep), rec(fun:=f));
end);

InstallMethod(AlgebraWithOneHomomorphismByFunction, "(FR) for two algebras and a function",
        [IsAlgebraWithOne,IsAlgebraWithOne,IsFunction],
        function(S,R,f)
    return Objectify(TypeOfDefaultGeneralMapping(S,R,
                   IsSPGeneralMapping and IsAlgebraWithOneGeneralMapping
                   and IsMappingByFunctionRep), rec(fun:=f));
end);
#############################################################################

#############################################################################
##
#O SCAlgebra
#O SCAlgebraWithOne
##
InstallMethod(SCAlgebraNC, "(FR) for a linear machine",
        [IsLinearFRMachine],
        function(M)
    local a, g;
    a := Objectify(NewType(CollectionsFamily(FREFamily(M)),
                 IsFRAlgebra and IsAttributeStoringRep),
                 rec());
    SetLeftActingDomain(a,LeftActingDomain(M));
    g := List(GeneratorsOfFRMachine(M),x->FRElement(M,x));
    SetGeneratorsOfLeftOperatorRing(a,g);
    SetCorrespondence(a,g);
    SetUnderlyingFRMachine(a,M);
    if IsVectorFRMachineRep(M) then
        SetFilterObj(a,IsVectorFRElementSpace);
    fi;
    SetFilterObj(a,IsLinearFRElementSpace);
    return a;
end);

InstallMethod(SCAlgebra, "(FR) for a linear machine",
        [IsLinearFRMachine], SCAlgebraNC);

BindGlobal("SCALGEBRAWITHONE@", function(M)
    local a;
    a := Objectify(NewType(CollectionsFamily(FREFamily(M)),
                 IsFRAlgebraWithOne and IsAttributeStoringRep),
                 rec());
    SetLeftActingDomain(a,LeftActingDomain(M));
    SetCorrespondence(a,List(GeneratorsOfFRMachine(M),x->FRElement(M,x)));    
    SetUnderlyingFRMachine(a,M);
    if IsVectorFRMachineRep(M) then
        SetFilterObj(a,IsVectorFRElementSpace);
    fi;
    SetFilterObj(a,IsLinearFRElementSpace);
    return a;
end);
        
InstallMethod(SCAlgebraWithOneNC, "(FR) for a linear machine",
        [IsLinearFRMachine],
        function(M)
    local a;
    a := SCALGEBRAWITHONE@(M);
    SetGeneratorsOfLeftOperatorRingWithOne(a,Correspondence(a));
    return a;
end);

InstallMethod(SCAlgebraWithOne, "(FR) for a linear machine",
        [IsLinearFRMachine],
        function(M)
    local a, g, p;
    a := SCALGEBRAWITHONE@(M);
    g := DuplicateFreeList(Correspondence(a));
    if Length(g)>=1 then
        p := Position(g,One(g[1]));
        if p<>fail then Remove(g,p); fi;
    fi;
    SetGeneratorsOfLeftOperatorRingWithOne(a,g);
    return a;
end);

InstallMethod(SCLieAlgebra, "(FR) for a linear machine",
        [IsLinearFRMachine],
        function(M)
    local a;
    a := Objectify(NewType(CollectionsFamily(FRJFAMILY@(M)),
                 IsFRAlgebra and IsAttributeStoringRep),
                 rec());
    SetLeftActingDomain(a,LeftActingDomain(M));
    SetGeneratorsOfLeftOperatorRing(a,List(GeneratorsOfFRMachine(M),x->FRElement(M,x,IsJacobianElement)));    
    SetUnderlyingFRMachine(a,M);
    if IsVectorFRMachineRep(M) then
        SetFilterObj(a,IsVectorFRElementSpace);
    fi;
    SetFilterObj(a,IsLinearFRElementSpace);
    return a;
end);
############################################################################

#############################################################################
##
#F FRAlgebra
#F FRAlgebraWithOne
##
BindGlobal("TOTALDEGREE@", function(x)
    local d, i;
    d := -1;
    x := ExtRepOfObj(x)[2];
    for i in x{[1,3..Length(x)-1]} do
        d := Maximum(d,Sum(i{[2,4..Length(i)]}));
    od;
    return d;
end);

BindGlobal("STRINGSTOLMACHINE@", function(r,arg,creator)
    local temp, i, j, gens, transitions, output, data, Error;

    Error := function(arg)
        if IsBound(data) then
            MakeReadWriteGlobal(data.holdername); Unbind(data.holdername);
        fi;
        CallFuncList(VALUE_GLOBAL("Error"),arg);
    end;
    
    if not IsRing(r) or not ForAll(arg,IsString) then
        Error("<arg> should contain a ring and strings\n");
    fi;
    temp := List(arg, x->SplitString(x,"="));
    if ForAny(temp,x->Size(x)<>2) then
        Error("<arg> should have the form a=[[...]...]\n");
    fi;
    gens := List(temp, x->x[1]);
    if Size(Set(gens)) <> Size(gens) then
        Error("all generators should have a distinct name\n");
    fi;
    data := rec(holdername := RANDOMNAME@(),
                holder := FreeAssociativeAlgebraWithOne(r,gens));
    BindGlobal(data.holdername, data.holder);
    Error := function(arg)
        MakeReadWriteGlobal(data.holdername); Unbind(data.holdername);
        CallFuncList(VALUE_GLOBAL("Error"),arg);
    end;

    transitions := [];
    output := [];
    for temp in List(temp,x->x[2]) do
        temp := SplitString(temp,":");
        if Length(temp)=2 then
            Add(output,STRING_ATOM2GAP@(temp[2])*One(r));
        else
            Add(output,One(r));
        fi;
        temp := STRING_WORD2GAP@(gens,"GeneratorsOfAlgebraWithOne",data,temp[1])*One(data.holder);
        if not IsMatrix(temp) then
            Error("<arg> should have the form a=[[...]...]\n");
        fi;
        Add(transitions,temp);
    od;

    i := AlgebraMachine(r,data.holder,transitions,output);
    if ValueOption("IsVectorElement")=true or
       (ForAll(Flat(transitions),x->TOTALDEGREE@(x)<=1) and ValueOption("IsAlgebraElement")<>true) then
        i := AsVectorMachine(i);
        i := List(Correspondence(i),x->FRElement(i,x));
        for temp in [1..Length(gens)] do
            SetName(i[temp],gens[temp]);
        od;
        i := creator(r,i);
    else
        i := creator(r,List(GeneratorsOfFRMachine(i),x->FRElement(i,x)));
    fi;
    SetIsStateClosed(i,true);
    MakeReadWriteGlobal(data.holdername); UnbindGlobal(data.holdername);
    return i;
end);

InstallGlobalFunction(FRAlgebra,
        function(arg)
    return STRINGSTOLMACHINE@(arg[1],arg{[2..Length(arg)]},Algebra);
end);

InstallGlobalFunction(FRAlgebraWithOne,
        function(arg)
    return STRINGSTOLMACHINE@(arg[1],arg{[2..Length(arg)]},AlgebraWithOne);
end);

InstallMethod(AssignGeneratorVariables, "(FR) for an FR algebra",
        [IsFRAlgebra],
        function(G)
    ASSIGNGENERATORVARIABLES@(GeneratorsOfAlgebra(G));
end);

InstallMethod(AssignGeneratorVariables, "(FR) for an FR algebra with one",
        [IsFRAlgebraWithOne],
        function(G)
    ASSIGNGENERATORVARIABLES@(GeneratorsOfAlgebraWithOne(G));
end);
############################################################################

#############################################################################
##
#O ThinnedAlgebra
#O ThinnedAlgebraWithOne
##
InstallMethod(ThinnedAlgebra, "(FR) for a ring and a FR semigroup",
        [IsRing, IsFRSemigroup],
        function(r,G)
    local a, g, s;
    s := GeneratorsOfSemigroup(G);
    g := List(s,x->AsLinearElement(r,x));
    for a in [1..Length(s)] do
        if HasName(s[a]) then SetName(g[a],Name(s[a])); fi;
    od;
    a := Objectify(NewType(CollectionsFamily(FamilyObj(g[1])),
                 IsFRAlgebra and IsAttributeStoringRep),
                 rec());
    SetLeftActingDomain(a,LeftActingDomain(g[1]));
    SetGeneratorsOfLeftOperatorRing(a,g);
    if HasSize(G) and Size(G)=infinity then
        SetDimension(G,infinity);
    fi;
    return a;
end);

BindGlobal("THINNEDALGEBRAWITHONE@",
        function(r,G,s)
    local a, g;
    g := List(s,x->AsLinearElement(r,x));
    for a in [1..Length(s)] do
        if HasName(s[a]) then SetName(g[a],Name(s[a])); fi;
    od;
    a := Objectify(NewType(CollectionsFamily(FamilyObj(g[1])),
                 IsFRAlgebraWithOne and IsAttributeStoringRep),
                 rec());
    SetLeftActingDomain(a,LeftActingDomain(g[1]));
    SetGeneratorsOfLeftOperatorRingWithOne(a,g);
    SetAugmentationIdeal(a,TwoSidedIdealByGenerators(a,List(g,x->x-One(a))));
    return a;
end);

InstallMethod(ThinnedAlgebraWithOne, "(FR) for a ring and a FR monoid",
        [IsRing, IsFRMonoid],
        function(r,G)
    return THINNEDALGEBRAWITHONE@(r,G,GeneratorsOfMonoid(G));
end);

InstallMethod(Embedding, "(FR) for a semigroup and a FR algebra",
        [IsFRSemigroup, IsFRAlgebra],
        function(G,A)
    if IsGroup(G) then
        return GroupHomomorphismByFunction(G,A,x->AsLinearElement(LeftActingDomain(A),x));
    else
        return MagmaHomomorphismByFunctionNC(G,A,x->AsLinearElement(LeftActingDomain(A),x));
    fi;
end);
############################################################################

#############################################################################
##
#O Nillity
##
BindGlobal("ISNIL_GENERIC@", function(x) # returns false or 2-powers of x till 0
    local powx, rank, oldrank, ring;

    powx := [x];
    if IsMatrix(x) then
        ring := DefaultRing(x[1][1]);
    else
        ring := DefaultRing(x);
    fi;
    if IsMatrix(x) and (HasIsIntegralRing(x) and IsIntegralRing(x)) then
        rank := RankMat(x);
        while not IsZero(x) do
            x := x*x;
            Add(powx,x);
            oldrank := rank;
            rank := RankMat(x);
            if rank=oldrank then return false; fi;
        od;
        # certainly not a nil element if has non-zero generalized eigenspace
    else
        if HasIsIntegralRing(x) and IsIntegralRing(x) then
            if IsZero(x) then return [x]; else return false; fi;
        fi;
        while not IsZero(x) do
            if IsOne(x) then return false; fi;
            x := x*x;
            Add(powx,x);
        od;
    fi;
    return powx;
end);

BindGlobal("ISNIL_FR@", function(x)
    # return either a list of non-trivial 2-powers of x, or false
    local powx, deg, testing, found, recur;

    deg := Dimension(AlphabetOfFRObject(x));
    powx := [x];
    testing := NewDictionary(x,true); # current order during recursion
    found := NewDictionary(x,true); # elements for which we found the nillity
    AddDictionary(testing,Zero(x),infinity);
    AddDictionary(found,Zero(x),1);
    
    recur := function(x,mult,level,depth)
        local i, c, d, order;

        if KnowsDictionary(testing,x) then
            if KnowsDictionary(found,x) then
                return LookupDictionary(found,x);
            elif mult>LookupDictionary(testing,x) then
                return infinity;
            else
                return 1;
            fi;
        fi;

        AddDictionary(testing,x,mult);
            
        # first see if element is triangular
        d := DecompositionOfFRElement(x);
        
        # c are indices of diagonal blocks of size 1
        c := List(Filtered(List(EquivalenceClasses(StronglyConnectedComponents(TransitiveClosureBinaryRelation(BinaryRelationOnPoints(List([1..deg],i->Filtered([1..deg],j->not IsZero(d[i][j]))))))),AsList),x->Length(x)=1),c->c[1]);
        
        order := 1;
        for i in c do
            i := recur(d[i][i],mult,level+1,1);
            if i=infinity then return infinity; fi;
            order := Maximum(order,i);
        od;
        if IsDiagonalMat(d) then
            return order;
        fi;
        
        # now see if a projection is non-nil

        if IsVectorFRMachineRep(x) then
            d := LogInt(Dimension(StateSet(x))+1,deg)+1;
        else
            d := LogInt(Length(Flat(ExtRepOfObj(InitialState(x)))),deg)+2;
        fi;
        if d > depth then # work at new depth
            if ISNIL_GENERIC@(Activity(x,depth))=false then
                return infinity;
            fi;
        fi;
        
        i := recur(x*x,mult+1,level,d);
        AddDictionary(found,x,i);
        return i;
    end;

    if recur(x,0,0,0)=infinity then
        return false;
    fi;
    return powx;
end);

BindGlobal("NILLITY@", function(x,isnil)
    local powx, pown, n, y;

    powx := isnil(x);

    if powx=false then return infinity; fi;

    Append(powx,ISNIL_GENERIC@(Remove(powx))); # get all 2-powers of x
    Remove(powx);
    pown := List([0..Length(powx)-1],i->2^i);

    if powx=[] then return 1; fi;

    x := Remove(powx);
    n := Remove(pown)+1;
    while powx<>[] do
        y := x*Remove(powx);
        if IsZero(y) then
            Remove(pown);
        else
            x := y;
            n := n+Remove(pown);
        fi;
    od;
    return n;
end);

InstallMethod(Nillity, "(FR) for an associative element",
        [IsAssociativeElement and IsMultiplicativeElementWithZero],
        x->NILLITY@(x,ISNIL_GENERIC@));

InstallMethod(Nillity, "(FR) for an FR element",
        [IsLinearFRElement],
        x->NILLITY@(x,ISNIL_FR@));

InstallMethod(IsNilElement, "(FR) for an associative element",
        [IsAssociativeElement and IsMultiplicativeElementWithZero],
        x->ISNIL_GENERIC@(x)<>false);

InstallMethod(IsNilElement, "(FR) for an FR element",
        [IsLinearFRElement],
        x->ISNIL_FR@(x)<>false);

InstallTrueMethod(IsHomogeneousElement,# "(FR) for a vector with degree",
        IsLinearFRElement and HasDegreeOfHomogeneousElement);

InstallMethod(NucleusOfFRAlgebra, "(FR) for a ss algebra",
        [IsFRAlgebra],
        A->LINEARNUCLEUS@(VectorSpace(LeftActingDomain(A),GeneratorsOfAlgebra(A))));

InstallMethod(NucleusOfFRAlgebra, "(FR) for a ss algebra with one",
        [IsFRAlgebraWithOne],
        A->LINEARNUCLEUS@(VectorSpace(LeftActingDomain(A),GeneratorsOfAlgebraWithOne(A))));

InstallMethod(NucleusMachine, "(FR) for a ss algebra",
        [IsFRAlgebra],
        A->AsVectorMachine(NucleusOfFRAlgebra(A)));
        
InstallMethod(IsContracting, "(FR) for a ss algebra",
        [IsFRAlgebra],
        function(A)
    local N;
    N := NucleusOfFRAlgebra(A);
    return IsVectorSpace(N) and IsFiniteDimensional(N);
end);
#############################################################################

#############################################################################
##
#O MatrixQuotient
##
InstallMethod(MatrixQuotient, "(FR) for a FR algebra and a level",
        [IsFRAlgebra,IsInt],
        function(A,n)
    return Algebra(LeftActingDomain(A),List(GeneratorsOfAlgebra(A),x->Activity(x,n)));
end);

InstallMethod(EpimorphismMatrixQuotient, "(FR) for a FR algebra and a level",
        [IsFRAlgebra,IsInt],
        function(A,n)
    local Q;
    Q := MatrixQuotient(A,n);
    return AlgebraHomomorphismByFunction(A,Q,x->Activity(x,n));
end);

InstallMethod(MatrixQuotient, "(FR) for a FR algebra-with-one and a level",
        [IsFRAlgebraWithOne,IsInt],
        function(A,n)
    local Q;
    Q := AlgebraWithOne(LeftActingDomain(A),List(GeneratorsOfAlgebraWithOne(A),x->Activity(x,n)));
    if HasAugmentationIdeal(A) then
        SetAugmentationIdeal(Q,IdealNC(Q,List(GeneratorsOfIdeal(AugmentationIdeal(A)),x->Activity(x,n))));
    fi;
    return Q;
end);

InstallMethod(EpimorphismMatrixQuotient, "(FR) for a FR algebra-with-one and a level",
        [IsFRAlgebraWithOne,IsInt],
        function(A,n)
    local Q;
    Q := MatrixQuotient(A,n);
    return AlgebraWithOneHomomorphismByFunction(A,Q,x->Activity(x,n));
end);
############################################################################

#############################################################################
##
#M View
##
BindGlobal("VIEWALGEBRA@", function(A)
    local n, x, y, s;
    if HasIsJacobianRing(A) and IsJacobianRing(A) then
        x := "Lie ";
    else
        x := "";
    fi;
    if IsAlgebraWithOne(A) then
        n := Length(GeneratorsOfAlgebraWithOne(A));
        y := "-with-one";
    else
        n := Length(GeneratorsOfAlgebra(A));
        y := "";
    fi;
    s := Concatenation("<self-similar ",x,"algebra",y," on alphabet ",
                 String(LeftActingDomain(A)), "^", String(Dimension(AlphabetOfFRAlgebra(A))),
                 " with ",String(n)," generator");
    if n<>1 then Append(s,"s"); fi;
    if HasDimension(A) then Append(s,", of dimension "); Append(s,String(Dimension(A))); fi;
    Append(s,">");
    return s;
end);

InstallMethod(ViewString, "(FR) for an FR algebra",
        [IsFRAlgebra],
        VIEWALGEBRA@);
InstallMethod(ViewString, "(FR) for an FR algebra-with-one",
        [IsFRAlgebraWithOne],
        VIEWALGEBRA@);
INSTALLPRINTERS@(IsFRAlgebra);
INSTALLPRINTERS@(IsFRAlgebraWithOne);
############################################################################

#E algebra.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
