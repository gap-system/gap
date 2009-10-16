# Test for ThrowAwayFixedPoints 2:
Print("Test: ThrowAwayFixedPoints2\n");
x := PermList(Concatenation([2..1000],[1],[1002,1003,1001]))^1000;
y := PermList(Concatenation([2..1000],[1],[1001,1002,1004,1005,1003]))^1000;
g := Group( x,y );
ri := RECOG.TestGroup(g,false,60);
