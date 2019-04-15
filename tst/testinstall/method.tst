gap> START_TEST("method.tst");
gap> InstallMethod(Integers, [IsInt], function(n) return n; end);
Error, <opr> is not an operation
gap> InstallMethod(Size, [IsInt], function(n) return n; end);
Error, required filters [ "IsInt", "IsRat", "IsCyc", "IsExtAElement", 
  "IsNearAdditiveElement", "IsNearAdditiveElementWithZero", 
  "IsNearAdditiveElementWithInverse", "IsAdditiveElement", "IsExtLElement", 
  "IsExtRElement", "IsMultiplicativeElement", "IsMultiplicativeElementWithOne"
    , "IsMultiplicativeElementWithInverse", "IsZDFRE", "IsAssociativeElement",
  "IsAdditivelyCommutativeElement", "IsCommutativeElement", "IsCyclotomic" ]
for 1st argument do not match a declaration of Size
gap> InstallTrueMethod( IsInternalRep, IsList );
Error, <tofilt> must not involve representation filters
gap> InstallTrueMethod( IsDenseCoeffVectorRep, IsList );
Error, <tofilt> must not involve representation filters
gap> InstallTrueMethod( IsInternalRep, IsSmallIntRep );
gap> STOP_TEST("method.tst", 1);
