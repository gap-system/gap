r := rec(); for i in [1..10000] do r := rec(a := r); od;
Print(r);
String(r);
