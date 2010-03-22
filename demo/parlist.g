ParList1 := function(l, f, n)
    local   inch,  outch,  worker,  threads,  count,  res,  i,  x,  t;
    inch := CreateChannel();
    outch := CreateChannel();
    worker := function()
        local   x;
        while true do
            x := ReceiveChannel(inch);
            if x[1] = fail then
                    return;
            fi;
            x[2] := f(x[2]);    
            SendChannel(outch, x);
        od;
    end;
    threads := List([1..n], i->CreateThread(worker));
    count := 0;
    res := [];
    for i in [1..Length(l)] do
        SendChannel(inch, [i,l[i]]);
        while true do
            x := TryReceiveChannel(outch,fail);
            if x = fail then
                break;
            fi;
            res[x[1]] := x[2];
            count := count+1;
        od;
    od;
    for i in [1..n] do
        SendChannel(inch, [fail]);
    od;
    while count < Length(l) do
        x := ReceiveChannel(outch);
        if x = fail then
            break;
        fi;
        res[x[1]] := x[2];
        count := count+1;
    od;
    for t in threads do
        WaitThread(t);
    od;
    DestroyChannel(inch);
    DestroyChannel(outch);
    return res;
end;
            
