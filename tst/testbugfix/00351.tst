# 2017-02-18 (MH): Comparing recursive data structures should not
# crash. See issue #1150
gap> [~] < [~];
Error, recursion depth trap (5000)
gap> [~] = [~];
Error, recursion depth trap (5000)
gap> rec(a:=~) = rec(a:=~);
Error, recursion depth trap (5000)
gap> rec(a:=~) < rec(a:=~);
Error, recursion depth trap (5000)
