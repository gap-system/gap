#############################################################################
##
#W  atomic_base.tst         GAP Library                    Chris Jefferson
##
##
#Y  Copyright (C)  2014,  University of St Andrews
##
##  This test checks the 'atomic' statement for compatability with original
##  GAP. It does not do any interesting thread-safe behaviour
##
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
gap> Print(f,"\n");
function ( x )
    atomic L  do
        return x + 1;
    od;
    return;
end
gap> g := function(x) atomic readwrite L do return x+1; od; end;;
gap> Print(g,"\n");
function ( x )
    atomic readwrite L  do
        return x + 1;
    od;
    return;
end
gap> h := function(x) atomic readonly L do return x+1; od; end;;
gap> Print(h,"\n");
function ( x )
    atomic readonly L  do
        return x + 1;
    od;
    return;
end
gap> h2 := function(x) atomic readonly L,M do return x+1; od; end;;
gap> Print(h2,"\n");
function ( x )
    atomic readonly L, M  do
        return x + 1;
    od;
    return;
end
gap> STOP_TEST("atomic_basic.tst", 100000);