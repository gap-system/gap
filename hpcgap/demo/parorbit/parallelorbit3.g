# This is a third try of a parallel orbit for hpcgap running in threads:
# This time we use individual channels for each worker to distribute
# the work, but we queue a configurable number of chunks for each worker.
# This should avoid the hotspot in the single channel and should be
# translatable to distributed memory without much change.

LoadPackage("orb");

HashServer := function(id,pt,inch,outchs,status,hashsize,chunksize,queuesize)
  # id is the ID of ourselves
  # pt is a sample point
  # hashsize is the hash size
  # inch is our input channel
  # outchs is a list work queues, one for each worker
  # chunksize is the size of a chunk of work
  # queuesize is the target for each work queue
  local Poll,Send,ht,p,pts,queued,r,sent,sumq,target,todo,val,w,work;
  #Print("I am hash #", ThreadID(CurrentThread()), " ", id, "\n");
  ht := HTCreate(pt,rec( hashlen := hashsize ));
  pts := EmptyPlist(hashsize);
  w := Length(outchs);  # number of workers
  target := queuesize * w;
  sent := 0;
  todo := EmptyPlist(1000);
  #sizes := EmptyPlist(1000);
  work := CreateChannel();  # a FIFO queue from us to ourselves
  queued := 0*[1..w];
  sumq := 0;
  Poll := function(wait)
      local r,x;
      if wait then
          r := ReceiveChannel(inch);
      else
          r := TryReceiveChannel(inch,fail);
          if r = fail then return false; fi;
      fi;
      if IsStringRep(r) and r = "exit" then
          MakeReadOnlySingleObj(ht!.els);
          MakeReadOnlySingleObj(ht!.vals);
          SendChannel(status,ht);
          MakeReadOnlySingleObj(pts);
          SendChannel(status,pts);
          #SendChannel(status,sizes);
          return true;
      elif IsInt(r) then
          x := TryReceiveChannel(work,fail);
          if x = fail then
              queued[r] := queued[r] - 1;
              sumq := sumq - 1;
              if queued[r] = 0 and sumq = 0 and Length(todo) = 0 then
                  SendChannel(status,id);   # we are idle
              fi;
          else
              SendChannel(outchs[r],x);
          fi;
          return false;
      else
          #Print("HS ",id," got data ",Length(r),"\n");
          Add(todo,r);
      fi;
      return false;
  end;
  Send := function(e)
      local i,tosend,x;
      tosend := EmptyPlist(e-sent+1);
      Add(tosend,id);
      for i in [sent+1..e] do
          Add(tosend,pts[i]);
      od;
      MakeReadOnlySingleObj(tosend);
      SendChannel(work,tosend);
      #Add(sizes,e-sent);
      sent := e;
      if sumq = target then return; fi;
      i := Random(1,w);
      while true do
          x := TryReceiveChannel(work,fail);
          if x = fail then return; fi;
          if queued[i] < queuesize then
              SendChannel(outchs[i],x);
              queued[i] := queued[i] + 1;
              sumq := sumq+1;
              if sumq = target then return; fi;
          fi;
          i := i + 1;
          if i > w then i := 1; fi;
      od;
  end;

  while true do
      if Poll(true) then return; fi;
      while Length(todo) > 0 do
          r := Remove(todo,1);
          for p in r do
              val := HTValue(ht,p);
              if val = fail then
                  HTAdd(ht,p,true);
                  Add(pts,p);
                  if Length(pts)-sent >= chunksize then
                      Send(sent+chunksize);
                  fi;
              fi;
          od;
          if Length(pts) > sent and sumq < target then
              Send(Length(pts));
          fi;
          if Poll(false) then return; fi;
          if sumq = 0 and Length(todo) = 0 then
              SendChannel(status,id);
          fi;
      od;
  od;
end;

Worker := function(id,gens,op,hashins,myqueue,status,f)
  # id is my ID
  # gens are the generators to act
  # op is the action function
  # hashins is a list of channels, one for each hashserver
  # myqueue is one channel for us to receive work
  # status is the global status channel
  # f is a distribution hash function
  local c,g,j,n,res,t,x;
  #Print("I am worker #",id,"\n");
  n := Length(hashins);
  while true do
      #c := 0;
      #while true do
      #    t := TryReceiveChannel(myqueue,fail);
      #    if t = fail then
      #        c := c + 1;
      #    else
      #        break;
      #    fi;
      #od;
      #if c > 0 then Print("Had to TryReceiveChannel ",c," times.\n"); fi;
      t := ReceiveChannel(myqueue);
      if IsStringRep(t) and t = "exit" then return; fi;
      #Print("Worker got work ",Length(t),"\n");
      res := List([1..n],x->EmptyPlist(QuoInt(Length(t)*Length(gens)*2,n)));
      for j in [2..Length(t)] do
          for g in gens do
              x := op(t[j],g);
              Add(res[f(x)],x);
          od;
      od;
      for j in [1..n] do
          if Length(res[j]) > 0 then
              SendChannel(status,-j);   # hashserver not ready
              MakeReadOnlySingleObj(res[j]);
              SendChannel(hashins[j],res[j]);
              #Print("Worker sent result to HS ",j,"\n");
          fi;
      od;
      SendChannel(hashins[t[1]],id);
      #Print("Worker sent done to HS ",t[1],"\n");
  od;
end;

TimeDiff := function(t,t2)
  return (t2-t)*1.E-9;
end;

ParallelOrbit := function(gens,pt,op,opt)
    local allhashes,allpts,change,h,i,k,pos,ptcopy,q,ready,s,ti,ti2,w,x;
    if not IsBound(opt.nrhash) then opt.nrhash := 1; fi;
    if not IsBound(opt.nrwork) then opt.nrwork := 1; fi;
    if not IsBound(opt.disthf) then opt.disthf := x->1; fi;
    if not IsBound(opt.hashlen) then opt.hashlen := 100001; fi;
    if not IsBound(opt.chunksize) then opt.chunksize := 1000; fi;
    if not IsBound(opt.queuesize) then opt.queuesize := 3; fi;
    if IsGroup(gens) then gens := GeneratorsOfGroup(gens); fi;
    if IsMutable(gens) then MakeImmutable(gens); fi;
    if not(IsReadOnlyObj(gens)) then MakeReadOnlySingleObj(gens); fi;
    if IsMutable(pt) then pt := MakeImmutable(StructuralCopy(pt)); fi;
    if not(IsReadOnlyObj(pt)) then MakeReadOnlySingleObj(pt); fi;

    ti := IO_gettimeofday();
    ptcopy := StructuralCopy(pt);
    ShareObj(ptcopy);
    i := List([1..opt.nrhash],k->CreateChannel());
    MakeReadOnlySingleObj(i);
    q := List([1..opt.nrwork],k->CreateChannel());
    MakeReadOnlySingleObj(q);
    s := CreateChannel();
    h := List([1..opt.nrhash],k->RunTask(HashServer,k,ptcopy,i[k],q,s,
                  opt.hashlen,opt.chunksize,opt.queuesize));
    Print("Hash servers started.\n");
    pos := opt.disthf(pt);
    SendChannel(i[pos],[pt]);
    Print("Seed sent.\n");
    w := List([1..opt.nrwork],
              k->RunTask(Worker,k,gens,op,i,q[k],s,opt.disthf));
    Print("Workers started...\n");
    ready := BlistList([1..opt.nrhash],[1..opt.nrhash]);
    ready[pos] := false;
    while ForAny([1..opt.nrhash],i->ready[i]=false) do
        change := false;
        x := ReceiveChannel(s);
        while true do
            if x = fail then break; 
            elif x < 0 then 
                if ready[-x] = true then 
                    change := true; 
                    #Print("Hash server #",x," got some work.\n");
                fi;
                ready[-x] := false;
            else 
                if ready[x] = false then 
                    change := true; 
                    #Print("Hash server #",x," became idle.\n");
                fi;
                ready[x] := true;
            fi;
            x := TryReceiveChannel(s,fail);
        od;
        # if change then Print("\nCentral: ready is ",ready,"\r"); fi;
    od;
    # Now terminate all workers:
    for k in [1..opt.nrwork] do
        SendChannel(q[k],"exit");
    od;
    Print("Sent exit.\n");
    for k in [1..opt.nrwork] do
        WaitTask(w[k]);
    od;
    Print("All workers done.\n");
    # Now terminate all hashservers:
    allhashes := EmptyPlist(k);
    allpts := EmptyPlist(k);
    #allstats := EmptyPlist(k);
    for k in [1..opt.nrhash] do
        SendChannel(i[k],"exit");
        Add(allhashes,ReceiveChannel(s));
        Add(allpts,ReceiveChannel(s));
        #Add(allstats,ReceiveChannel(s));
        WaitTask(h[k]);
    od;
    Print("All hashservers done.\n");
    ti2 := IO_gettimeofday();
    return rec( allhashes := allhashes, allpts := allpts,
                time := TimeDiff(ti,ti2),
                #allstats := allstats, 
                nrhash := opt.nrhash, 
                nrwork := opt.nrwork );
end;

Measure := function(gens,pt,op,n)
  local Ping,Pong,c1,c2,computebandwidth,g,ht,i,j,k,l,ll,
        lookupbandwidth,t,t1,ti,ti2,timeperlookup,timeperop,times,x;
  if IsGroup(gens) then gens := GeneratorsOfGroup(gens); fi;
  if IsMutable(gens) then MakeImmutable(gens); fi;
  if IsMutable(pt) then pt := MakeImmutable(StructuralCopy(pt)); fi;

  # First measure computation bandwidth to get some idea and some data:
  Print("Measuring computation bandwidth... \c");
  k := Length(gens);
  l := EmptyPlist(n*k);
  l[1] := pt;
  ti := IO_gettimeofday();
  # This does Length(gens)*n operations and keeps the results:
  for j in [1..n] do
      for g in gens do
          Add(l,op(l[j],g));
      od;
  od;
  ti2 := IO_gettimeofday();
  timeperop := TimeDiff(ti,ti2)/(k*n);  # time for one op
  computebandwidth := 1.0/timeperop;
  Print(computebandwidth,"\n");

  # Now hash lookup bandwith:
  Print("Measuring lookup bandwidth... \c");
  ht := HTCreate(pt,rec( hashlen := NextPrimeInt(2*k*n) ));
  # Store things in the hash:
  for j in [1..n*k] do
      x := HTValue(ht,l[j]);
      if x = fail then HTAdd(ht,l[j],j); fi;
  od;
  ti := IO_gettimeofday();
  for j in [1..n*k] do
      x := HTValue(ht,l[j]);
  od;
  ti2 := IO_gettimeofday();
  timeperlookup := TimeDiff(ti,ti2)/(k*n);  # time for one op
  lookupbandwidth := 1.0/timeperlookup;
  Print(lookupbandwidth,"\n");

  # Now transfer data between two threads:
  Ping := function(c,cc,n)
    local i,o,oo;
    o := ReceiveChannel(cc);
    for i in [1..n] do
        SendChannel(c,o);
        oo := ReceiveChannel(cc);
    od;
    SendChannel(c,o);
  end;
  Pong := function(c,cc,n)
    local i,oo;
    for i in [1..n] do
        oo := ReceiveChannel(c);
        SendChannel(cc,oo);
    od;
  end;
  times := [];
  c1 := CreateChannel();
  c2 := CreateChannel();
  Print("Measuring ping pong speed...\n");
  for i in [0..30] do
      if 2^i > Length(l) then break; fi;
      ll := l{[1..2^i]};
      Print(2^i,"... ");
      ti := IO_gettimeofday();
      t1 := CreateThread(Ping,c1,c2,10000000);
      ti2 := IO_gettimeofday();
      t := TimeDiff(ti,ti2)/10000000.0;
      Add(times,t);
      Print(t," ==> ",1.0/t," ping pongs/s.\n");
  od;
  
  return rec( timeperop := timeperop, 
              computebandwidth := computebandwidth,
              timeperlookup := timeperlookup, 
              lookupbandwidth := lookupbandwidth,
              pingpongtimes := times,
              pingpongbandwidth := List(times,x->1.0/x) );
end;

OnRightRO := function(x,g)
  local y;
  y := x*g;
  MakeReadOnlySingleObj(y);
  return y;
end;

OnSubspacesByCanonicalBasisRO := function(x,g)
  local y;
  y := OnSubspacesByCanonicalBasis(x,g);
  MakeReadOnlySingleObj(y);
  return y;
end;

MakeDistributionHF := function(x,n) 
  local hf,data;
  if n = 1 then return x->1; fi;
  hf := ChooseHashFunction(x,n);
  data := hf.data;
  MakeReadOnlySingleObj(data);
  hf := hf.func;
  return y->hf(y,data);
end;

DoStatistics := function(gens,v,op,hash,work,opt)
  local stats,s,h,w,r;
  stats := [];
  for h in hash do
    s := [];
    for w in work do
      opt.nrhash := h;
      opt.nrwork := w;
      opt.disthf := MakeDistributionHF(v,h);
      Print("Doing garbage collection...\c");
      GASMAN("collect");
      Print("\nDoing ",h," hashservers and ",w," workers... \c");
      r := ParallelOrbit(gens,v,op,opt);
      Add(s,r.time);
      Print(r.time,"\n");
    od;
    Add(stats,s);
  od;
  return stats;
end;


m := MathieuGroup(24);
# r := ParallelOrbit(m,1,OnPoints,rec());;
# r := ParallelOrbit(m,[1,2,3,4],OnTuples,
#     rec(nrhash := 2,nrwork := 2, disthf := x -> (x[1] mod 2) + 1));;
