# test iterating over local variables from within a break loop
f:=function(x) local y; y:=42; Error("bar"); end;;
i:=0;
f(1);
x;
y;
for i in [x..y] do od;
