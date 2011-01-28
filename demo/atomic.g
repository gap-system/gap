
z:=0;

f:=function() 
local l; 
l:=SHARED_LIST(); 
atomic readwrite l do
 l[1]:=1; 
 l[2]:=2;
 z:=l[1]+l[2];
od;
Print( "Sum=", z, "\n");
end;

t:=CreateThread(f);;
WaitThread(t);
z;

#############################################################################

f:=function()
local l, threads, i;
l:=SHARED_LIST(); 
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
l:=SHARED_LIST(); 
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
l:=SHARED_LIST(); 
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
