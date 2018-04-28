gap> START_TEST("break.tst");

#
gap> break;
Syntax error: 'break' statement not enclosed in a loop in stream:1
break;
    ^
gap> if true then break; fi;
Syntax error: 'break' statement not enclosed in a loop in stream:1
if true then break; fi;
                 ^
gap> if false then break; fi;
Syntax error: 'break' statement not enclosed in a loop in stream:1
if false then break; fi;
                  ^
gap> f := function() break; end;
Syntax error: 'break' statement not enclosed in a loop in stream:1
f := function() break; end;
                    ^
gap> for i in [1..5] do List([1..5], function(x) break; return 1; end); od;
Syntax error: 'break' statement not enclosed in a loop in stream:1
for i in [1..5] do List([1..5], function(x) break; return 1; end); od;
                                                ^

#
gap> continue;
Syntax error: 'continue' statement not enclosed in a loop in stream:1
continue;
       ^
gap> if true then continue; fi;
Syntax error: 'continue' statement not enclosed in a loop in stream:1
if true then continue; fi;
                    ^
gap> if false then continue; fi;
Syntax error: 'continue' statement not enclosed in a loop in stream:1
if false then continue; fi;
                     ^
gap> f := function() continue; end;
Syntax error: 'continue' statement not enclosed in a loop in stream:1
f := function() continue; end;
                       ^
gap> for i in [1..5] do List([1..5], function(x) continue; return 1; end); od;
Syntax error: 'continue' statement not enclosed in a loop in stream:1
for i in [1..5] do List([1..5], function(x) continue; return 1; end); od;
                                                   ^

#
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

#
gap> STOP_TEST("break.tst", 1);
