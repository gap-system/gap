# Test for Pcgs:
Print("Test: S4^10\n");
g := DirectProduct(SymmetricGroup(4),SymmetricGroup(4));
g := DirectProduct(g,g);
g := DirectProduct(g,g);
g := DirectProduct(g,g);
g := DirectProduct(g,g);
ri := RECOG.TestGroup(g,false,146811384664566452713597726037899455366168576);
