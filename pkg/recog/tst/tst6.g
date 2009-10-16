# Test for VeryFewPoints:
Print("Test: S5wrS32\n");
g := WreathProduct(SymmetricGroup(5),SymmetricGroup(32));
ri := RECOG.TestGroup(g,false,Factorial(5)^32*Factorial(32));
