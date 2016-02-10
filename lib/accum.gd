DeclareCategory("IsAccumulator", IsCopyable);

DeclareOperation("ValueAccumulator", [IsAccumulator]);

DeclareConstructor("AccumulatorCons", [IsAccumulator, IsObject]);

DeclareOperation("RightAdd", [IsAccumulator and IsMutable, IsExtAElement] );
DeclareOperation("LeftAdd", [IsAccumulator and IsMutable, IsExtAElement] );
DeclareOperation("Subtract", [IsAccumulator and IsMutable, IsNearAdditiveElementWithInverse] );
DeclareOperation("Negate", [IsAccumulator and IsMutable] );
DeclareOperation("RightMultiply", [IsAccumulator and IsMutable, IsExtLElement] );
DeclareOperation("LeftMultiply", [IsAccumulator and IsMutable, IsExtRElement] );
DeclareOperation("RightDivide", [IsAccumulator and IsMutable, IsMultiplicativeElementWithInverse] );
DeclareOperation("LeftDivide", [IsAccumulator and IsMutable, IsMultiplicativeElementWithInverse] );
DeclareOperation("Invert", [IsAccumulator and IsMutable] );
DeclareOperation("Conjugate", [IsAccumulator and IsMutable, IsMultiplicativeElementWithInverse] );

DeclareCategory("IsPermutationAccumulator", IsAccumulator);
DeclareOperation("OnPointsAccumulator", [IsPosInt, IsPermutationAccumulator]);
DeclareOperation("OnTuplesAccumulator", [IsRowVector and IsCyclotomicCollection, 
        IsPermutationAccumulator]);
