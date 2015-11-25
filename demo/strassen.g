Read("demo/bench.g");
#
# This is basically intended to be the simplkest natural parallel 
# implementation of Strassen-Winograd. Also included is a sequential version
# and a parallel divide-and-conquer that does not use Strassen (so 8 recursive
# calls instead of 7).
#

#
# The parallel element works well, but the Strassen not so well at the moment
# Memory and addition overheads need more work
#

#
# One additional thing to try is to move the post-multiplication additions and assembly into
# a task, and use ScheduleTask to get it to run at the right time. This should reduce the number
# of waiting threads (although working out when the whole computation has finished is a qn).
#

#
# To do it really well we need to pass "windows" around in the interfaces
#

CUTOFF := 200;

#
# Basic algorithm
#

ParMatMultStrassen := function(a,b)
    local  n, n2, a11, b11, p1, a12, b21, p2, a21, a22, b12, b22, s1, 
           s2, s4, p3, s3, t1, p5, t2, p6, t4, p4, t3, p7, u1, u2, u3, 
           u4, u5, u6, u7, c;
    n := Length(a);
    if n <= CUTOFF then
        return a*b;
    fi;
    n2 := QuoInt(n,2);
    a11 := `a{[1..n2]}{[1..n2]};
    b11 := `b{[1..n2]}{[1..n2]};
    p1 := RunTask(ParMatMultStrassen, a11, b11);
    a12 := `a{[1..n2]}{[n2+1..n]};
    b21 := `b{[n2+1..n]}{[1..n2]};
    p2 := RunTask(ParMatMultStrassen, a12, b21);
    a21 := `a{[n2+1..n]}{[1..n2]};
    a22 := `a{[n2+1..n]}{[n2+1..n]};
    b12 := `b{[1..n2]}{[n2+1..n]};
    b22 := `b{[n2+1..n]}{[n2+1..n]};
    s1 := a21+a22;
    s2 := s1 - a11;
    s4 := a12-s2;
    p3 := RunTask(ParMatMultStrassen, s4, b22);
    s3 := a11-a21;
    t1 := b12-b11;
    p5 := RunTask(ParMatMultStrassen, s1,t1);
    t2 := b22-t1;
    p6 := RunTask(ParMatMultStrassen, s2, t2);    
    t4 := t2-b21;
    p4 := RunTask(ParMatMultStrassen, a22, t4);    
    t3 := b22-b12;
    p7 := RunTask(ParMatMultStrassen, s3, t3);
    p1 := TaskResult(p1);
    p2 := TaskResult(p2);
    u1 := p1+p2;
    p6 := TaskResult(p6);
    u2 := p1+p6;
    p7 := TaskResult(p7);
    u3 := u2+p7;
    p5 := TaskResult(p5);
    u4 := u2+p5;
    p3 := TaskResult(p3);
    u5 := u4+ p3;
    p4 := TaskResult(p4);
    u6 := u3-p4;
    u7 := u3 + p5;
    c := ZeroMutable(a);
    c{[1..n2]}{[1..n2]} := u1;
    c{[1..n2]}{[n2+1..n]} := u5;
    c{[n2+1..n]}{[1..n2]} := u6;
    c{[n2+1..n]}{[n2+1..n]} := u7;
    return MakeImmutable(c);
end;

    
#
# Same Strassen algorithm, but with function calls rather than tasks
#
    
SeqMatMultStrassen := function(a,b)
    local  n, n2, a11, b11, p1, a12, b21, p2, a21, a22, b12, b22, s1, 
           s2, s4, p3, s3, t1, p5, t2, p6, t4, p4, t3, p7, u1, u2, u3, 
           u4, u5, u6, u7, c;
    n := Length(a);
    if n <= CUTOFF then
        return a*b;
    fi;
    n2 := QuoInt(n,2);
    a11 := `a{[1..n2]}{[1..n2]};
    b11 := `b{[1..n2]}{[1..n2]};
    p1 := SeqMatMultStrassen(a11, b11);
    a12 := `a{[1..n2]}{[n2+1..n]};
    b21 := `b{[n2+1..n]}{[1..n2]};
    p2 := SeqMatMultStrassen( a12, b21);
    a21 := `a{[n2+1..n]}{[1..n2]};
    a22 := `a{[n2+1..n]}{[n2+1..n]};
    b12 := `b{[1..n2]}{[n2+1..n]};
    b22 := `b{[n2+1..n]}{[n2+1..n]};
    s1 := a21+a22;
    s2 := s1 - a11;
    s4 := a12-s2;
    p3 := SeqMatMultStrassen( s4, b22);
    s3 := a11-a21;
    t1 := b12-b11;
    p5 := SeqMatMultStrassen( s1,t1);
    t2 := b22-t1;
    p6 := SeqMatMultStrassen( s2, t2);    
    t4 := t2-b21;
    p4 := SeqMatMultStrassen( a22, t4);    
    t3 := b22-b12;
    p7 := SeqMatMultStrassen( s3, t3);
    u1 := p1+p2;
    u2 := p1+p6;
    u3 := u2+p7;
    u4 := u2+p5;
    u5 := u4+ p3;
    u6 := u3-p4;
    u7 := u3 + p5;
    c := ZeroMutable(a);
    c{[1..n2]}{[1..n2]} := u1;
    c{[1..n2]}{[n2+1..n]} := u5;
    c{[n2+1..n]}{[1..n2]} := u6;
    c{[n2+1..n]}{[n2+1..n]} := u7;
    return MakeImmutable(c);
end;


#
# Non-Strassen divide and conquer parallel multiply
#
    
ParMatMultNaive := function(a,b)
    local  n, n2, a11, b11, p1, a12, b21, p2, b12, p3, b22, p4, a21, 
           p5, p6, a22, p7, p8, c;
    n := Length(a);
    if n <= CUTOFF then
        return a*b;
    fi;
    n2 := QuoInt(n,2);
    a11 := `a{[1..n2]}{[1..n2]};
    b11 := `b{[1..n2]}{[1..n2]};
    p1 := RunTask(ParMatMultNaive, a11, b11);
    a12 := `a{[1..n2]}{[n2+1..n]};
    b21 := `b{[n2+1..n]}{[1..n2]};
    p2 := RunTask(ParMatMultNaive, a12, b21);
    b12 := `b{[1..n2]}{[n2+1..n]};
    p3 := RunTask(ParMatMultNaive, a11, b12);
    b22 := `b{[n2+1..n]}{[n2+1..n]};
    p4 := RunTask(ParMatMultNaive, a12, b22);
    a21 := `a{[n2+1..n]}{[1..n2]};
    p5 := RunTask(ParMatMultNaive, a21, b11);
    p6 := RunTask(ParMatMultNaive, a21, b12);
    a22 := `a{[n2+1..n]}{[n2+1..n]};
    p7 := RunTask(ParMatMultNaive, a22, b21);
    p8 := RunTask(ParMatMultNaive, a22, b22);
    c := ZeroMutable(a);
    p1 := TaskResult(p1);
    p2 := TaskResult(p2);
    c{[1..n2]}{[1..n2]} := p1+p2;
    p3 := TaskResult(p3);
    p4 := TaskResult(p4);
    c{[1..n2]}{[n2+1..n]} := p3+p4;
    p5 := TaskResult(p5);
    p7 := TaskResult(p7);
    c{[n2+1..n]}{[1..n2]} := p5+p7;
    p6 := TaskResult(p6);
    p8 := TaskResult(p8);
    c{[n2+1..n]}{[n2+1..n]} := p6+p8;
    return MakeImmutable(c);
end;

