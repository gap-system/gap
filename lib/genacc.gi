BindGlobal("AccumulatorsFamily", NewFamily(IsAccumulator));


InstallMethod(Conjugate, [IsAccumulator and IsMutable, IsMultiplicativeElementWithInverse],
        function(acc, x)
    acc := LeftDivide(acc, x);
    if acc = fail then
        return fail;
    fi;
    return RightMultiply(acc,x);
end);

InstallMethod(Exponentiate, [IsAccumulator and IsMutable, IsInt],
        function(acc, pow)
    local  v, i;
    if pow < 0 then
        Invert(acc);
        pow := -pow;
    fi;
    v := ValueAccumulator(acc);
    if pow = 0 then
        RightDivide(acc,v);
    else
        for i in [2..pow] do
            RightMultiply(acc,v);
        od;
    fi;
    return acc;
end);
    
         
    
        
