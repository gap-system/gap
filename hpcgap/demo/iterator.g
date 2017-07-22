#############################################################################
#
# Example 11. Parallel iterator
# Brute force computation of the sum of orders of elements of a permutation group
# (we deliberately not using representatives of conjugacy classes)

runtime:=function(t1,t2) return (t2-t1)/1000.; end;
n := 5;
S := SymmetricGroup(n);
map := Order;

# First do it sequentially
t1:=NanosecondsSinceEpoch();
Print("Sum of orders sequential : ", Sum( List(S, s -> CallFuncList( map, [s] ) ) ), "\n");
t2:=NanosecondsSinceEpoch();
Print("Iterator sequential : ", runtime(t1,t2), "\n"); 

# Now in parallel
S := SymmetricGroup(n);
nrworkers := 2;     # number of workers
sizefactor := 1000; # input channel length "per worker"
jobsize := 1;       # for workers in MultiReceiveChannel
chunksize := 1;    # for MultiSendChannel
inch  := CreateChannel( nrworkers*sizefactor ); # "shared" input channel
outch := CreateChannel( nrworkers );            # output channel 

t1:=NanosecondsSinceEpoch();

worker := function()
    local input, x, res;
    res := 0;
    while true do
        input := MultiReceiveChannel( inch, jobsize );
        for x in input do
        	if x = fail then
            	SendChannel(outch, res);
            	return;
        	else
            	res := res + CallFuncList( map, [x] );     
        	fi;
        od;	
    od;
    end;

# master thread runs the iterator
master :=CreateThread( 
            function() 
            local s, chunk, i;
            chunk := [];
            i:=0;
            for s in Iterator( S ) do
                i:=i+1;
                chunk[i]:=s;
                if i=chunksize then
                	MultiSendChannel( inch, chunk );
                	chunk:=[];
                	i:=0;
                fi;	
            od;
            if Length(chunk) > 0 then
            	MultiSendChannel( inch, chunk );
            fi;
            Print("Iteration completed, waiting for workers ... \n");
            for s in [1..nrworkers] do
                SendChannel( inch, fail );
            od;
            end);
            
# worker threads start to wait
workers:=List([1..nrworkers], i -> CreateThread( worker ) );

# wait for all threads            
WaitThread( master ); 
for i in [1..nrworkers] do
    WaitThread( workers[i] );
od;

# now collect results
sum := 0;
for i in [1..nrworkers] do
    sum := sum + ReceiveChannel( outch );
od;

t2:=NanosecondsSinceEpoch();           
Print("Sum of orders parallel   : ", sum, "\n");
Print("Iterator parallel : ", runtime(t1,t2), "\n");            
           

    
            
