# Test for VeryFewPoints:
Print("Test: A5wrS32\n");
g := WreathProduct(AlternatingGroup(5),SymmetricGroup(32));
ri := RECOG.TestGroup(g,false,(Factorial(5)/2)^32 * Factorial(32));
