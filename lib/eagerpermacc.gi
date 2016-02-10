
DeclareRepresentation("IsEagerPermutationAccumulatorRep", 
        IsDataObjectRep and IsPermutationAccumulator, 2);

BindGlobal("DefaultTypeEagerPermAccumulator", 
        NewType(AccumulatorsFamily, IsMutable and IsEagerPermutationAccumulatorRep));

InstallMethod(AccumulatorCons,[IsEagerPermutationAccumulatorRep, IsPerm and IsInternalRep],
        function(t,p)
    return NEW_PERMACC(p);
end);

InstallMethod(ValueAccumulator, [IsEagerPermutationAccumulatorRep],
        VALUE_PERMACC);

InstallMethod(RightMultiply, [IsEagerPermutationAccumulatorRep and IsMutable, IsPerm and IsInternalRep],
        RIGHT_MULTIPLY_PERMACC);

InstallMethod(LeftMultiply, [IsEagerPermutationAccumulatorRep and IsMutable, IsPerm and IsInternalRep],
        LEFT_MULTIPLY_PERMACC);

InstallMethod(RightDivide, [IsEagerPermutationAccumulatorRep and IsMutable, IsPerm and IsInternalRep],
        RIGHT_DIVIDE_PERMACC);

InstallMethod(LeftDivide, [IsEagerPermutationAccumulatorRep and IsMutable, IsPerm and IsInternalRep],
        LEFT_DIVIDE_PERMACC);

InstallMethod(Invert, [IsEagerPermutationAccumulatorRep and IsMutable],
        INVERT_PERMACC);

InstallMethod(ShallowCopy, [IsEagerPermutationAccumulatorRep],
        SHALLOWCOPY_PERMACC);

InstallMethod(OnPointsAccumulator, [IsPosInt, IsEagerPermutationAccumulatorRep, ],
        ONPOINTS_PERMACC);






