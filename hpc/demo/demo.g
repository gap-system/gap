#############################################################################
#
# The code in this file should run in the HPC-GAP version
#
#############################################################################

ReadGapRoot("demo/threads.g");

# "Hello, World" from a thread example

t:=CreateThread( function() Print("Hello, Multithreaded World!\n");end );
WaitThread(t);

CurrentThread();

# multithreaded "Hello, World" example
hello:=function(n)
Sleep(n mod 3);
Print("Hello World, thread ", n, " with id ", CurrentThread(), " is here\n");
end;
threads:=List( [1..10], i -> CreateThread( hello, i ) );
Perform( threads, WaitThread );

# Global variables example
counter:=0;
nrthreads:=10;
l:=[];
ShareObj(l);;
w:=AtomicList(nrthreads);
hello:=function(n)
local t;
Sleep(n mod 3);
t:=counter;
counter:=counter+1;
Print("Thread ", n, " : ", t , " + 1 = ", counter, " \n");
w[n]:=counter;
atomic readwrite l do
    l[n]:=counter;
od;
end;
threads:=List( [1..nrthreads], i -> CreateThread( hello, i ) );
Perform( threads, WaitThread );
counter;
w;
r:=FromAtomicList(w);
atomic readwrite l do
    ADOPT(l); 
od;    
Print(r,"\n",l,"\n");
Print("Global variables test : ", r=l, "\n");

# Example 1. Simple operations channels with no threads
ch1:=CreateChannel();   
ch2:=CreateChannel();
SendChannel(ch1,6);
SendChannel(ch1,7);
SendChannel( ch2, ReceiveChannel(ch1)*ReceiveChannel(ch1));
ReceiveChannel(ch2);

Print("Passed example 1\n");

# Example 2. Sending to channel list elements in a loop inside a thread
ch:=CreateChannel();
n:=10000;
f:=function() local i; for i in [1..n] do SendChannel(ch,i); od; end;
CreateThread(f);
l:=List([1..n],i->ReceiveChannel(ch));;
l=[1..n];

Print("Passed example 2\n");

# Example 3. Two threads, each with own input and output channels
chin1:=CreateChannel();
chin2:=CreateChannel();
chout1:=CreateChannel();
chout2:=CreateChannel();
mult1:=function() SendChannel( chout1, ReceiveChannel(chin1)*ReceiveChannel(chin1)); end;
mult2:=function() SendChannel( chout2, ReceiveChannel(chin2)*ReceiveChannel(chin2)); end;
CreateThread(mult1);
CreateThread(mult2);
SendChannel(chin1,2);
SendChannel(chin1,3);
SendChannel(chin2,4);
SendChannel(chin2,5);
ReceiveChannel(chout1);
ReceiveChannel(chout2);

Print("Passed example 3\n");

# Example 4. Sending objects to a thread and receiving them back
ChannelTest:=function( obj )
local chin, chout, r, thread;
chin:=CreateChannel();
chout:=CreateChannel();
thread := CreateThread( function() SendChannel(chout, ReceiveChannel(chin) ); end ); 
SendChannel( chin, obj );
r:=ReceiveChannel( chout );
WaitThread( thread );
return r=obj;
end;

Print("Starting ChannelTests ... \n");
ChannelTest(1);
ChannelTest(E(4)); 
ChannelTest(Integers);
ChannelTest(DihedralGroup(1000));
ChannelTest(GAPInfo);            
ChannelTest(2^160000);
ChannelTest(Factorial);
ChannelTest(GlobalRandomSource);
ChannelTest("bla");  

Print("Performing ChannelTest in a loop ... ");
for i in [1..10000] do r:=ChannelTest(i); od; # time;
Print("done\n");

Print("Passed example 4\n");

# Example 5. A function to multiply objects in a thread
MultiplyInThread := function(a,b)
local chin, chout, thread, r;
chin:=CreateChannel();
chout:=CreateChannel();
SendChannel( chin, a );
SendChannel( chin, b );
thread := CreateThread( function() SendChannel(chout, ReceiveChannel(chin)*ReceiveChannel(chin) ); end ); 
r:=ReceiveChannel( chout );
WaitThread( thread );
return r;
end;
MultiplyInThread(6,7);

Print("Passed example 5\n");

# Example 6. Usage of CallFuncListThread and FinaliseThread
chin:=CreateChannel();
chout:=CreateChannel();
r:=CallFuncListThread( function(s) return s*s; end, [ 10 ], chin, chout);
# r:=CallFuncListThread( s -> Factorial(s), [ 10 ], chin, chout);
# The line below causes GAP to run forever
# r:=CallFuncListThread( s -> Size(SmallGroup(s)), [[8,3]], chin, chout);
FinaliseThread( r, chin, chout );

Print("Passed example 6\n");

# Example 7. Recursive computation of Fibonacci(n) with two threads on top.
fib_recursive := function(n)
if n in [1, 2] then
  return 1;
else
  return fib_recursive(n-1) + fib_recursive(n-2);
fi;
end;

fib_threads_recursive:= function(n)
local chin1, chin2, chout1, chout2, thread1, thread2, r1, r2;
if n in [1, 2] then
  return 1;
else
  chin1:=CreateChannel();
  chin2:=CreateChannel();
  chout1:=CreateChannel();
  chout2:=CreateChannel();  
  thread1:= CallFuncListThread( fib_recursive, [ n-1 ], chin1, chout1 );
  thread2:= CallFuncListThread( fib_recursive, [ n-2 ], chin2, chout2 );
  r1 := FinaliseThread( thread1, chin1, chout1 );
  r2 := FinaliseThread( thread2, chin2, chout2 );
 return r1+r2; 
fi;
end; 
fib_threads_recursive(6);

Print("Passed example 7\n");

# Example 8. Recursive computation of Fibonacci(n) creating two subthreads 
# on each step (good to exhaust resources and get segfaults)
fib_threads:= function(n)
local chin1, chin2, chout1, chout2, thread1, thread2, r1, r2;
if n in [1, 2] then
  return 1;
else
  chin1:=CreateChannel();
  chin2:=CreateChannel();
  chout1:=CreateChannel();
  chout2:=CreateChannel();  
  thread1:= CallFuncListThread( fib_threads, [ n-1 ], chin1, chout1 );
  thread2:= CallFuncListThread( fib_threads, [ n-2 ], chin2, chout2 );
  r1 := FinaliseThread( thread1, chin1, chout1 );
  r2 := FinaliseThread( thread2, chin2, chout2 );
  return r1+r2; 
fi;
end; 
fib_threads(6);

Print("Passed example 8\n");

ReadGapRoot("demo/atomic.g");
ReadGapRoot("demo/migrate.g");
ReadGapRoot("demo/fibtasks.g");


# Example 9. Compare standard, Fibonacci and threaded Fibonacci multiplication
ReadGapRoot("demo/karatsuba.g");
x:=Indeterminate(Rationals,"x");
nr:=IndeterminateNumberOfLaurentPolynomial(x);
fam:=FamilyObj(1);;
l:=[-4..5];
deg:=5000;
KARATSUBA_CUTOFF:=150; # quasi-optimal value for one main and two subthreads
f:=LaurentPolynomialByCoefficients( fam, List([1..deg],i->l[(i mod 10) + 1]), 0, 1 );;
g:=LaurentPolynomialByCoefficients( fam, List([1..deg],i->l[((i+5) mod 10) + 1]), 0, 1 );;
Print("Testing standard multiplication of polynomials ... ");
t1:=f*g;;
Print("done\n");
Print("Testing Karatsuba multiplication of polynomials ... ");
t2:=KaratsubaPolynomialMultiplication(f,g);; 
Print("done\n");
Print("Testing Karatsuba multiplication of polynomials in threads ... ");
t3:=KaratsubaPolynomialMultiplicationThreaded(f,g);; 
Print("done\n");
t1=t2; t1=t3; # this causes crash 

Print("Passed example 9\n");

# Example 10. Barriers
# This example works:
Print("Barrier test 1 \n");
bar:=CreateBarrier();
StartBarrier( bar, 3 );
t:=[];
for i in [1..3] do
    t[i]:=CreateThread( 
             function(i) 
             local t, s; 
             t:=CurrentTime();
             s := Concatenation("Thread ", String(i), " started at ", 
                    String(t.tv_sec), ".", String(t.tv_usec), "\n");
             Print( s );
             Sleep(i); 
             WaitBarrier(bar); 
             t:=CurrentTime();
             s := Concatenation("Thread ", String(i), " stopped at ", 
                    String(t.tv_sec), ".", String(t.tv_usec), "\n");
             Print( s );
             end, 
             i );
od;
for i in [1..3] do WaitThread(t[i]); od;

# And this not:
Print("Barrier test 2 \n");
m:=MakeImmutable(List([1..10],i->List([1..10],j->10*(i-1)+j)));
s:=AtomicList(10);
bar:=CreateBarrier();
StartBarrier( bar, Length(m)+1 );
t:=[];
for i in [1..Length(m)] do
    t[i]:=CreateThread( function(i) s[i]:=Sum( List(m[i], Factorial ) ); WaitBarrier(bar); end, i );
od;
WaitBarrier(bar);
x1:=Sum(FromAtomicList(s));
x2:=Sum(List([1..100],Factorial));
for i in [1..Length(t)] do WaitThread(t[i]); od;
Print(x1,"\n");
Print(x2,"\n");
Print( "Barrier test 2 ", x1=x2, "\n");

Print("Passed example 10\n");

Print("=======================\nChecking access.tst ...\n");
tst := Filename( DirectoriesLibrary("tst"), "access.tst" );;
Test(tst);
Print("Completed access.tst!!!\n");

Print("*** END OF THE TEST ***\n");

