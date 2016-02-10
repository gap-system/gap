InstallMethod(RightAdd,[IsPermutationAccumulator and IsMutable, IsExtAElement], ReturnFail);
InstallMethod(LeftAdd,[IsPermutationAccumulator and IsMutable, IsExtAElement], ReturnFail);
InstallMethod(Subtract,[IsPermutationAccumulator and IsMutable, 
        IsNearAdditiveElementWithInverse], ReturnFail);
InstallMethod(Negate,[IsPermutationAccumulator and IsMutable], ReturnFail);

InstallMethod(OnTuplesAccumulator, 
        [IsSmallList and IsCyclotomicCollection and IsRowVector, IsPermutationAccumulator],
        function(tup,acc)
    return List(tup, x -> OnPointsAccumulator(acc,x));
end);

