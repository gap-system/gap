#############################################################################
#
# Example 11. Parallel iterator
# Brute force computation of the sum of orders of elements of a permutation group
# (we deliberately not using representatives of conjugacy classes)

runtime:=function(t1,t2) return 1000000*(t2.tv_sec-t1.tv_sec)+t2.tv_usec-t1.tv_usec; end;
S := SymmetricGroup(10);

# First do it sequentially
t1:=CurrentTime();
Print("Sum of orders sequential : ", Sum( List(S, s -> Order(s) ) ), "\n");
t2:=CurrentTime();
Print("Iterator sequential : ", runtime(t1,t2), "\n"); 

# Now in parallel
nrworkers := 2; # number of workers
inch  := CreateChannel( nrworkers*10 ); # ten times larger "shared" input channel
outch := CreateChannel( nrworkers );    # output channel 

worker := function()
    local x, res;
    res := 0;
    while true do
        x := ReceiveChannel(inch);
        if x = fail then
            SendChannel(outch, res);
            return;
        else
            res := res + Order(x);     
        fi;
    od;
    end;
    
# worker threads start to wait
workers:=List([1..nrworkers], i -> CreateThread( worker ) );

t1:=CurrentTime();

# master thread fires up the computation
master :=CreateThread( 
            function() 
            local s;
            for s in Iterator( S ) do
                SendChannel( inch, s );
            od;
            for s in [1..nrworkers] do
                SendChannel( inch, fail );
            od;
            end);

# wait for all threads            
WaitThread( master ); 
t2:=CurrentTime();           
for i in [1..nrworkers] do
    WaitThread( workers[i] );
od;

# now collect results
sum := 0;
for i in [1..nrworkers] do
    sum := sum + ReceiveChannel( outch );
od;


Print("Sum of orders parallel   : ", sum, "\n");
Print("Iterator parallel : ", runtime(t1,t2), "\n");            
           

    
            
