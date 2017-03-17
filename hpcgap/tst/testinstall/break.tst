gap> START_TEST("break.tst");
gap> break;
Error, A break statement can only appear inside a loop
gap> continue;
Error, A continue statement can only appear inside a loop
gap> f := function() break; end;
Syntax error: break statement not enclosed in a loop in stream:1
f := function() break; end;
                     ^
gap> f := function() continue; end;
Syntax error: continue statement not enclosed in a loop in stream:1
f := function() continue; end;
                        ^
gap> f := function() local i; for i in [1..5] do continue; od; end;;
gap> f();
gap> f := function() local i; for i in [1..5] do break; od; end;;
gap> f();
gap> f := function() local i; i := 1; while i in [1..5] do i := i + 1; continue; od; end;;
gap> f();
gap> f := function() local i; i := 1; while i in [1..5] do break; od; end;;
gap> f();
gap> f := function() local i; i := 1; repeat i := i + 1; continue; until i in [1..5]; end;;
gap> f();
gap> f := function() local i; i := 1; repeat i := i + 1; break; until i in [1..5]; end;;
gap> f();
gap> for i in [1..5] do List([1..5], function(x) continue; return 1; end); od;
Syntax error: continue statement not enclosed in a loop in stream:1
for i in [1..5] do List([1..5], function(x) continue; return 1; end); od;
                                                    ^
gap> for i in [1..5] do List([1..5], function(x) break; return 1; end); od;
Syntax error: break statement not enclosed in a loop in stream:1
for i in [1..5] do List([1..5], function(x) break; return 1; end); od;
                                                 ^
gap> for i in [1..5] do List([1..5], function(x) break; return 1; end); od;
Syntax error: break statement not enclosed in a loop in stream:1
for i in [1..5] do List([1..5], function(x) break; return 1; end); od;
                                                 ^
gap> STOP_TEST("break.tst", 1);
