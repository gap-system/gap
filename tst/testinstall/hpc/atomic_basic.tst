#############################################################################
##
##  This test checks the 'atomic' statement for compatibility with original
##  GAP. It does not do any interesting thread-safe behaviour
##
#@local L,M,f,g,h,h2,h3,h4,h5,x
gap> START_TEST("atomic_basic.tst");
gap> L := [];; M := [];;
gap> x := 1;;
gap> atomic L do Print("A\n"); od;
A
gap> atomic L,M do Print("B\n"); od;
B
gap> atomic readwrite L,M do Print("C\n"); od;
C
gap> atomic readonly L,M do Print("D\n"); od;
D
gap> atomic L do atomic M do Print("E\n"); od; od;
E
gap> atomic L do Print("F\n"); od;
F
gap> f := function(x) atomic L do return x+1; od; end;;
gap> f(1);
2
#@if IsHPCGAP
gap> Print(f,"\n");
function ( x )
    atomic L do
        return x + 1;
    od;
    return;
end
gap> g := function(x) atomic readwrite L do return x+1; od; end;;
gap> Print(g,"\n");
function ( x )
    atomic readwrite L do
        return x + 1;
    od;
    return;
end
gap> h := function(x) atomic readonly L do return x+1; od; end;;
gap> Print(h,"\n");
function ( x )
    atomic readonly L do
        return x + 1;
    od;
    return;
end
gap> h2 := function(x) atomic readonly L,M do return x+1; od; end;;
gap> Print(h2,"\n");
function ( x )
    atomic readonly L, M do
        return x + 1;
    od;
    return;
end
gap> h3 := atomic function(x) end;;
gap> Print(h3, "\n");
atomic function ( x )
    return;
end
gap> h4 := atomic function(readwrite x, readonly y, z) end;;
gap> Print(h4, "\n");
atomic function ( readwrite x, readonly y, z )
    return;
end
gap> # test parsing an atomic function entered as a statement
gap> atomic function() end;
atomic function(  ) ... end
#@else
gap> Print(f,"\n");
function ( x )
    return x + 1;
end
gap> g := function(x) atomic readwrite L do return x+1; od; end;;
gap> Print(g,"\n");
function ( x )
    return x + 1;
end
gap> h := function(x) atomic readonly L do return x+1; od; end;;
gap> Print(h,"\n");
function ( x )
    return x + 1;
end
gap> h2 := function(x) atomic readonly L,M do return x+1; od; end;;
gap> Print(h2,"\n");
function ( x )
    return x + 1;
end
gap> h3 := atomic function(x) end;;
gap> # We do not preserve atomic functions in non-HPC gap, just want them to parse
gap> Print(h3, "\n");
function ( x )
    return;
end
gap> h4 := atomic function(readwrite x, readonly y, z) end;;
gap> Print(h4, "\n");
function ( x, y, z )
    return;
end
gap> # test parsing an atomic function entered as a statement
gap> atomic function() end;
function(  ) ... end
#@fi
gap> h5 := function(readwrite x, readonly y, z) end;;
Syntax error: 'readwrite' argument of non-atomic function in stream:1
h5 := function(readwrite x, readonly y, z) end;;
               ^^^^^^^^^
gap> h5 := function(readonly x, readonly y, z) end;;
Syntax error: 'readonly' argument of non-atomic function in stream:1
h5 := function(readonly x, readonly y, z) end;;
               ^^^^^^^^
gap> h5 := {readonly x} -> x;
Syntax error: 'readonly' argument of non-atomic function in stream:1
h5 := {readonly x} -> x;
       ^^^^^^^^
gap> h5 := {readonly x} -> x;
Syntax error: 'readonly' argument of non-atomic function in stream:1
h5 := {readonly x} -> x;
       ^^^^^^^^
gap> h5 := {x, readonly y} -> x;
Syntax error: 'readonly' argument of non-atomic function in stream:1
h5 := {x, readonly y} -> x;
          ^^^^^^^^
gap> h5 := {readwrite x, y} -> x;
Syntax error: 'readwrite' argument of non-atomic function in stream:1
h5 := {readwrite x, y} -> x;
       ^^^^^^^^^
gap> h5 := {x, readwrite y} -> x;
Syntax error: 'readwrite' argument of non-atomic function in stream:1
h5 := {x, readwrite y} -> x;
          ^^^^^^^^^
gap> h5 := {readwrite} -> x;
Syntax error: 'readwrite' argument of non-atomic function in stream:1
h5 := {readwrite} -> x;
       ^^^^^^^^^
gap> h5 := {readwrite readonly x} -> x;
Syntax error: 'readwrite' argument of non-atomic function in stream:1
h5 := {readwrite readonly x} -> x;
       ^^^^^^^^^
gap> STOP_TEST("atomic_basic.tst", 1);
