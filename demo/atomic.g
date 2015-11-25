z:=0;

f:=function() 
local l,k,t; 
l:=ShareInternalObj([]); 
k:=ShareObj([]);
t:=LOCK(k);
k[1]:=1;
atomic readwrite l do
 k[2]:=2;
 z:=k[1]+k[2];
 l[1]:=z;
 l[2]:=z+1;
 z:=z+l[1]+l[2];
od;
UNLOCK(t);
Print( "z=", z, "\n");
end;

t:=CreateThread(f);;
WaitThread(t);
z;

#############################################################################

f:=function()
local l, threads, i;
l:=ShareObj([]); 
threads:=List( [1..10], i -> 
 CreateThread( function(i) atomic readwrite l do l[i]:=CurrentThread(); od; end, i ) );
Perform( threads, WaitThread );
atomic readwrite l do
   Print(l,"\n");
od;
end;

t:=CreateThread(f);;
WaitThread(t);

#############################################################################


f:=function()
local l, threads, i;
l:=ShareObj([]); 
atomic readwrite l do
   for i in [1..10] do
      l[i]:=i;
   od;
od;
threads:=List( [1..10], i -> 
 CreateThread( function(i) atomic readwrite l do l[i]:=l[i]^2; od; end, i ) );
Perform( threads, WaitThread );
atomic readwrite l do
  Print(l,"\n");
od;
end;

t:=CreateThread(f);;
WaitThread(t);


#############################################################################


Parmap:=function( nr, nrthreads )
local l, map, threads, i;
l:=ShareObj([]); 
atomic readwrite l do
   for i in [1..nr] do
     l[i]:=i;
 od;
od;

map := function(i) 
local k, j, res;
for j in [ i, nrthreads+i .. ((nr/nrthreads)-1)*(nrthreads)+i] do 
 atomic readwrite l do
 k:=l[j];
 od;
 res := k^2;
 atomic readwrite l do
 l[j]:=res;
od;
od;
end;

threads:=List( [1..nrthreads], i -> CreateThread( map, i ) );
Perform( threads, WaitThread );
atomic readwrite l do
Print( l, "\n" );
od;
end;

t:=CreateThread( Parmap, 10, 2 );;
WaitThread(t);


#############################################################################

# Computing the sum of all elements of a matrix.
# The matrix is represented as a shared list of shared lists.
# Threads are computing sums over rows and store them in a shared list.
# Then the sum of elements in that list is computed.
      
z:=0; # global variable to store the result

ParSumMat:=function( nr, nrthreads )
local l, row, map, threads, i, j, s;
l:=ShareObj([]); # matrix
s:=ShareObj([]); # list of sums over rows
# populate square matrix nr x nr with numbers from [ 1.. nr^2 ] );
atomic readwrite l do
  for i in [1..nr] do
    # this will be changed when we will have full recursive support
    row:=ShareInternalObj([]); # create row
    atomic readonly row do
      l[i]:=row;
    od;
    atomic readwrite l[i] do # otherwise an error (no recursive)
      for j in [1..nr] do
        l[i][j]:=j+nr*(i-1);
      od;
    od;  
  od;
od;

# initialize sums over rows
atomic readwrite s do
  for i in [1..nr] do
    s[i]:=0;
  od;
od;

# thread function to be called in the thread number i
# it computes sums for each row assigned to i-th thread
map := function(i) 
local k, j, res, t, sum, n;
# j is the number of a row
for j in [ i, nrthreads+i .. ((nr/nrthreads)-1)*(nrthreads)+i] do 
  sum := 0;
  atomic readonly l do
  atomic readonly l[j] do # because of missing recursion
    for n in [1..nr] do   # Length doesn't work
      sum := sum + l[j][n];
    od;
  od;
  od;
  atomic readwrite s do
    s[j]:=sum;
  od;
od;
end;

threads:=List( [1..nrthreads], i -> CreateThread( map, i ) );
Perform( threads, WaitThread );

z:=0;
atomic readonly s do
 for i in [1..nr] do
   z := z+s[i]; # Sum(s) doesn't work
 od;
od;

# atomic readwrite l do
#  for i in [1..nr] do
#    atomic readwrite l[i] do # otherwise an error (no recurisve)
#      Print( l[i], "\n" ); # Print(l) gives an error
#    od;  
#  od;
# od;  

end;

nr:=10; t:=CreateThread(ParSumMat,nr,2);; WaitThread(t); z; sum:=Sum([1..nr^2]);

Print("atomic test : ", z=sum,"\n");

