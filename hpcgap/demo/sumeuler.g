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
# chunks := Reversed(chunks);
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

#############################################################################
#
# We store the list of 3432 primes less than 32000, extending the 
# list of 168 primes less than 1000, that is defined in GAP
#
MakeReadWriteGlobal( "Primes" );
Primes := Filtered( [ 1 .. 32000 ], IsPrimeInt );;
MakeReadOnlyGlobal( "Primes" );
MakeReadOnly( Primes );;

LiouvilleFunction:=function( n )
#
# For an integer n, the Liouville's function of n is equal to (-1)^r(n), 
# where r(n) is the number of prime factors of n, counted according to 
# their multiplicity, with r(1)=0.
#
if n=1 then
  return 1;
elif Length( FactorsInt(n) ) mod 2 = 0  then
  return 1;
else
  return -1;
fi;
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

# Sum of the number of prime factors
SumNrPrimeFactors:=function(t) 
local s, i;
s:=0;
for i in [ t[1] .. t[2] ] do
  s := s + Length(FactorsInt(i));
od;
return s;
end;

# Counting primes
NumberOfPrimes:=function(t) 
local s, i;
s:=0;
for i in [ t[1] .. t[2] ] do
  if IsPrimeInt( i ) then
     s := s + 1;
  fi;
od;
return s;
end;

# Counting probable primes
NumberOfProbablePrimes:=function(t) 
local s, i;
s:=0;
for i in [ t[1] .. t[2] ] do
  if IsProbablyPrimeInt( i ) then
     s := s + 1;
  fi;
od;
return s;
end;

# Summatory Liouville function
SummatoryLiouvilleFunction:=function(t) 
local s, i;
s:=0;
for i in [ t[1] .. t[2] ] do
  s := s + LiouvilleFunction(i);
od;
return s;
end;

# Compare parallel and sequential 'FoldSkeleton'
Compare:=function( func, a, b, c )
local r1, r2, s;
r1 := FoldSkeleton( func, a, b, c, true  );
Print("Parallel   : ", r1.time, "\n");
r2 := FoldSkeleton( func, a, b, c, false );
Print("Sequential : ", r2.time, "\n");
if r1.result=r2.result then
  s := Float(r2.time/r1.time);
  Print("Speedup ", s, "\n");
  return s;
else
  Error("Incorrect results!!!");
fi;
end;

############################################################################
#
# Examples
#
Compare( SumIntegers, 1, 10^8, 10^5); # 21.1 on 32 cores, 26.5 on 64 cores
Compare( SumIntegers, 1, 10^9, 10^6); # 24.2 on 32 cores, 31.2 on 64 cores
Compare( SumEulerByDefinition, 1, 10^4, 10^2); # 7.1 on 8 cores, 12.5 on 16, 19.5 on 32, 30.1 on 64
Compare( SumEulerByDefinition, 1, 10^5, 10^2); # 7.62 on 8 cores, 13.3 on 16, 25.2 on 32 cores, 38x on 64 cores
Compare( SummatoryLiouvilleFunction, 1, 10^7, 10^4); # 6.8 on 8 cores, 20x on 64 cores
Compare( SummatoryLiouvilleFunction, 1, 10^7, 10^5); # 18x on 64 cores (24x speedup with with SCSCP on 64 cores)
Compare( SummatoryLiouvilleFunction, 1, 10^6, 10^3); # 6.1 on 8 cores, 16x on 64 cores
Compare( SumEulerByFormula, 1, 10^7, 10^4); # 6.3 on 8 cores, 26x on 64 cores
Compare( SumNrPrimeFactors, 1, 10^6, 10^3); # 28x on 64 cores
Compare( SumNrPrimeFactors, 1, 10^7, 10^4); # 26x on 64 cores

List([1..10],i->Compare( SumEulerByDefinition, 1, 10^4, 10^2));Sum(last)/10;
 
# Compare HPC-GAP and SCSCP performance: 1765s with HPC-GAP, 1135 with SCSCP
curtime1:=CurrentTime();FoldSkeleton( SummatoryLiouvilleFunction, 1, 906180359, 10^5, true  );curtime2:=CurrentTime();
duration:=runtime(curtime1,curtime2);

# TODO: parallel slower than sequential! With Primes extended, becames even worse
# since 'Primes' is also used for checking "small factors"
# Also, reversing the order of chunks may play a bad role here
MakeReadWriteGlobal( "Primes" );
Primes := Filtered( [ 1 .. 1000 ], IsPrimeInt );;
MakeReadOnlyGlobal( "Primes" );
MakeReadOnly( Primes );;
Compare( NumberOfPrimes, 1, 10^7, 10^4);
Compare( NumberOfProbablePrimes, 1, 10^7, 10^4);

