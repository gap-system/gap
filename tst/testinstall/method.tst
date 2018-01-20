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
gap> STOP_TEST("method.tst", 1);
