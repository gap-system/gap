# Test for VeryFewPoints:
Print("Test: S2wrS100\n");
g := WreathProduct(SymmetricGroup(2),SymmetricGroup(100));
ri := RECOG.TestGroup(g,false,Factorial(2)^100*Factorial(100));
