# Calculating time interval between t1 (start) and t2 (end) in microseconds
runtime:=function(t1,t2) 
return 1000000*(t2.tv_sec-t1.tv_sec)+(t2.tv_usec-t1.tv_usec); 
end;

# Parallel or sequential computation of Sum( List( [n1..n2], <func> ) )
FoldSkeleton:=function( func, n1, n2, chunksize, par )
local b1, b2, chunks, partialsums, jobs, t, res, curtime1, curtime2, duration;
b1:=n1;
b2:=Minimum(b1+chunksize-1,n2);
chunks := [ [b1,b2] ];
while b2 < n2 do
  b1 := b2+1;
  b2 := Minimum(b2+chunksize,n2);
  Add( chunks, [b1,b2] );
od;
curtime1:=CurrentTime();
if not par then
   partialsums:=List( chunks, func );
else
   jobs:=List( chunks, t -> RunTask( func, `t ) );
   partialsums :=List(jobs, TaskResult);
fi;
res := Sum(partialsums);
curtime2:=CurrentTime();
duration:=runtime(curtime1,curtime2);
return rec(result:=res, time:=duration);
end;

# Some functions to test with 'FoldSkeleton'

# Just sum of all elements of the range
SumIntegers:=function(t) 
local s, i;
s:=0;
for i in [ t[1] .. t[2] ] do
  s := s + i;
od;
return s;
end;

# Sum of values of the Euler's function calculated from its definition
SumEulerByDefinition:=function(t) 
local s, i, q;
s:=0;
for i in [ t[1] .. t[2] ] do
  s := s + Number([1..i-1], q -> GcdInt(i,q)=1 );
od;
return s;
end;

# Sum of values of the Euler's function calculated using 'Phi'
SumEulerByFormula:=function(t) 
local s, i;
s:=0;
for i in [ t[1] .. t[2] ] do
  s := s + Phi(i);
od;
return s;
end;

# Compare parallel and sequential 'FoldSkeleton'
Compare:=function( func, a, b, c )
local r1, r2;
r1 := FoldSkeleton( func, a, b, c, true  );
Print("Parallel   : ", r1.time, "\n");
r2 := FoldSkeleton( func, a, b, c, false );
Print("Sequential : ", r2.time, "\n");
if r1.result=r2.result then
  Print("Speedup ", Float(r2.time/r1.time), "\n");
else
  Error("Incorrect results!!!");
fi;
end;


Compare( SumIntegers, 1, 10^8, 10^5);
Compare( SumEulerByFormula, 1, 10^4, 10^2);
Compare( SumEulerByDefinition, 1, 10^4, 10^2);
Compare( SumEulerByFormula, 1, 10^5, 10^2);
Compare( SumEulerByDefinition, 1, 10^5, 10^2); 

