# Test for ThrowAwayFixedPoints:
Print("Test: ThrowAwayFixedPoints\n");
g := Group( (100,101,102,103,104,105,106,107,108,109,110), (100,101) );
ri := RECOG.TestGroup(g,false,Factorial(11));
