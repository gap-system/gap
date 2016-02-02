BindGlobal("AccumulatorsFamily", NewFamily(IsAccumulator));


InstallMethod(Conjugate, [IsAccumulator and IsMutable, IsMultiplicativeElementWithInverse],
        function(acc, x)
    acc := LeftDivide(acc, x);
    if acc = fail then
        return fail;
    fi;
    return RightMultiply(acc,x);
end);

         
    
        
