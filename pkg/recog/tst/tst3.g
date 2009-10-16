# Test for NonTransitive:
Print("Test: NonTransitive\n");
g := DirectProduct(SymmetricGroup(5),SymmetricGroup(6));
ri := RECOG.TestGroup(g,false,Factorial(5)*Factorial(6));
