# Test for Imprimitive:
Print("Test: Imprimitive\n");
g := WreathProduct(SymmetricGroup(5),SymmetricGroup(12));
ri := RECOG.TestGroup(g,false,Factorial(5)^12*Factorial(12));
