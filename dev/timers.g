#
#  This file contains some routines useful for reasonably exact timing 
#  of GAP operations. 
#


TIMERS_MIN_RUN_LENGTH := 200;
#
#        timer ( <test function> )
#
# This function accepts as argument one function f, which must accept
# an integer n and do n repetitions of some test. timer will rerun it
# with larger and larger n until it takes at least
# TIMERS_MIN_RUN_LENGTH ms and then return the average time per
# iteration in nanoseconds
#
#
# A typical usage is 
#
#  foo := function(n) 
#    local i,x,mm; 
#    mm := m; 
#    for i in [1..n] do
#       x := MinimalPolynomial( GF(17), mm );
#    od;
#  end;  
#
#  m := RandomMat( 200, 200, GF(17) );
#
#  Print(ns2times( timer( foo ) ) );
#
#  In this example, we copy things into local variables to avoid the significantly
# higher cost of accessing (and especially assigning to) globals.
#


timer := function(f)
    local t,n;
    n := 1;
    t := 0;
    while t < TIMERS_MIN_RUN_LENGTH do
        GASMAN("collect");
        t := -Runtime();
        f(n);
        t := t+Runtime();
        n := n*5;
    od;
    return Int(5000000*t/n);
end;

#
#  timer2( <shorter test>, <longer test> )
#
#  This function accepts as arguments two functions, and attempts to
#  determine the extra time taken by the second function compared to
#  the first. The functions should take an argument n as for the
#  argument to timer. They are called with larger and larger arguments 
#  until the difference in runtimes reaches TIMERS_MIN_RUN_LENGTH ms.
#  the return is the average difference in nanoseconds.
#
#  The intended use of this function is to time operations that require
#  significant preparation for each operation (for instance
#  destructive matrix operations). An example is:
#
#  foo := function(n) 
#    local i,x,mm; 
#    for i in [1..n] do
#        mm := List(m,ShallowCopy);
#    od;
#  end;  
#
#  bar := function(n) 
#    local i,x,mm; 
#    for i in [1..n] do
#        mm := List(m,ShallowCopy);
#        TriangulizeMat(mm);
#    od;
#  end;  
#
#  m := RandomMat( 200, 200, GF(17) );
#
#  Print(ns2times(timer2(foo,bar)));
#  
#

timer2 := function(f, f2)
    local t,n;
    n := 1;
    t := 0;
    while AbsInt(t) < TIMERS_MIN_RUN_LENGTH do
        GASMAN("collect");
        t := Runtime();
        f(n);
        t := t-2*Runtime();
        f2(n);
        t := t + Runtime();
        n := n*5;
    od;
    return Int(5000000*t/n);
end;


#
# ns2times turns a number of nanoseconds into a tidy 
#  human-readable string form
#

ns2times := function(n)
    local s;
    if n < 1000 then 
        s := ShallowCopy(String(n));
        Append(s,"ns");
    elif n < 1000000 then
        s := ShallowCopy(String(Int(n/1000)));
        if (n < 100000) then
            Append(s,".");
            Append(s,String(Int((n mod 1000)/100)));
            if ( n < 10000) then
                Append(s, String(Int((n mod 100)/10)));
            fi;
        fi;
        Append(s,"us");
    elif n < 10^9 then
        s := ShallowCopy(String(Int(n/1000000)));
        if (n < 10^8) then
            Append(s,".");
            Append(s,String(Int((n mod 10^6)/100000)));
            if ( n < 10^7) then
                Append(s, String(Int((n mod 10^5)/10000)));
            fi;
        fi;
        Append(s,"ms");
    else
        s := ShallowCopy(String(Int(n/10^9)));
        if (n < 10^11) then
            Append(s,".");
            Append(s,String(Int((n mod 10^9)/10^8)));
            if ( n < 10^10) then
                Append(s, String(Int((n mod 10^8)/10^7)));
            fi;
        fi;
        Append(s,"s");
    fi;
    IsString(s);
    return s;
end;








                     