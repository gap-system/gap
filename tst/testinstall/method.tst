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

# Check names are set correctly
gap> cheese := NewOperation("cheese", [IsObject]);
<Operation "cheese">

# These are in lists as assignments of the form 'f := x -> x' set the name
# of the function to 'f'
gap> funcs := [x -> x, x -> x, x -> x];;;
gap> ranks := [{} -> 10, {} -> 10, {} -> 10];;
gap> SetNameFunction(funcs[3], "func3");
gap> SetNameFunction(ranks[3], "rank3");
gap> InstallMethod(cheese, [IsInt], ranks[1], funcs[1]);
gap> InstallMethod(cheese, "for a list", [IsList], ranks[2], funcs[2]);
gap> InstallMethod(cheese, "for a string", [IsString], ranks[3], funcs[3]);
gap> List(Concatenation(funcs, ranks), NameFunction);
[ "cheese method", "cheese for a list", "func3", 
  "Priority calculation for cheese", 
  "Priority calculation for cheese for a list", "rank3" ]
gap> STOP_TEST("method.tst", 1);
