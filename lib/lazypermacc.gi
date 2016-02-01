DeclareRepresentation("IsLazyPermutationAccumulatorRep", 
        IsPositionalObjectRep and IsPermutationAccumulator, 2);

BindGlobal("LazyPermutationAccumulatorDefaultType", 
        NewType(AccumulatorsFamily, IsMutable and IsLazyPermutationAccumulatorRep));


InstallMethod(AccumulatorCons,[IsLazyPermutationAccumulatorRep, IsPerm],
        function(type, p)
    return Objectify(LazyPermutationAccumulatorDefaultType, [[],[p],[],[true]]);    
end);

InstallMethod(RightMultiply, [IsLazyPermutationAccumulatorRep and IsMutable, IsPerm],
        function(acc,p)
    Add(acc![2],p);
    Add(acc![4],true);
    return acc;
end);

InstallMethod(LeftMultiply, [IsLazyPermutationAccumulatorRep and IsMutable, IsPerm],
        function(acc,p)
    Add(acc![1],p);
    Add(acc![3],true);
    return acc;
end);

InstallMethod(RightDivide, [IsLazyPermutationAccumulatorRep and IsMutable, IsPerm],
        function(acc,p)
    Add(acc![2],p);
    Add(acc![4],false);    
    return acc;
    
end);

InstallMethod(LeftDivide, [IsLazyPermutationAccumulatorRep and IsMutable, IsPerm],
        function(acc,p)
    Add(acc![1],p);
    Add(acc![3],false);
    return acc;
end);

InstallMethod(Invert, [IsLazyPermutationAccumulatorRep and IsMutable],
        function(acc)
    local x;
    x := acc![1];
    acc![1] := acc![2];
    acc![2] := x;
    x := acc![3];
    acc![3] := List(acc![4], y-> not y);
    acc![4] := List(x, y-> not y);
    return acc;
end);

InstallMethod(Exponentiate, [IsLazyPermutationAccumulatorRep and IsMutable, IsInt],
        function (acc, pow)
    local  i, new, x, l, j;
    if pow < 0 then 
        Invert(acc);
        pow := -pow;
    fi;
    if pow = 0 then
        for i in [1..4] do
            acc![i] := [];
        od;
        return acc;
    fi;
    if pow = 1 then
        return acc;
    fi;
    new := [[],[],[],[]];
    for i in [1..4] do
        x  := acc![i];
        l := ShallowCopy(x);
        for j in [2..pow] do
            Append(l,x);
        od;
        acc![i] := l;
    od;
    return acc;
end);


InstallMethod(ShallowCopy,[IsLazyPermutationAccumulatorRep],
        function(acc)
    return Objectify(LazyPermutationAccumulatorDefaultType, List([1..4],
                   i -> ShallowCopy(acc![i])));
end);

#
# Could be implemented better usign an EagerPermutationAccumulator
#

InstallMethod(ValueAccumulator, [IsLazyPermutationAccumulatorRep],
        function(acc)
    local  v, l, i;
    v := ();
    l := Length(acc![1]);
    for i in [l,l-1..1] do
        if acc![3][i] then
            v := v*acc![1][i];
        else
            v := v/acc![1][i];
        fi;
    od;
    for i in [1..Length(acc![2])] do
        if acc![4][i] then
            v := v*acc![2][i];
        else
            v := v/acc![2][i];
        fi;
    od;
    acc![2] := [v];
    acc![1] := [];
    acc![3] := [];
    acc![4] := [true];    
    return v;
end);


InstallMethod(OnPointsAccumulator,[IsPosInt, IsLazyPermutationAccumulatorRep], 
        function(pt, acc)
    local  l, i;
    l := Length(acc![1]);
    for i in [l,l-1..1] do
        if acc![3][i] then
            pt := pt^acc![1][i];
        else
            pt := pt/acc![1][i];
        fi;
    od;
    for i in [1..Length(acc![2])] do
        if acc![4][i] then
            pt := pt^acc![2][i];
        else
            pt := pt/acc![2][i];
        fi;
    od;
    return pt;
end);

        

#T View/Print                   
