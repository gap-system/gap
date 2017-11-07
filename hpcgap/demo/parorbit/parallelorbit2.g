# This is a second try of a parallel orbit for hpcgap running in threads:
# This time we use a central channel for work distribution.

LoadPackage("orb");

HashServer := function(id,pt,hashsize,inch,outch,status,chunksize)
  local Poll,ht,i,p,pts,r,running,sent,sizes,todo,tosend,val;
  #Print("I am hash #", ThreadID(CurrentThread()), " ", id, "\n");
  ht := HTCreate(pt,rec( hashlen := hashsize ));
  pts := EmptyPlist(hashsize);
  sent := 0;
  running := 0;
  todo := [];
  sizes := EmptyPlist(1000);
  Poll := function(wait)
      local r;
      if wait then
          r := ReceiveChannel(inch);
      else
          r := TryReceiveChannel(inch,fail);
          if r = fail then return false; fi;
      fi;
      if IsStringRep(r) then
          if r = "exit" then 
              MakeReadOnlySingleObj(ht!.els);
              MakeReadOnlySingleObj(ht!.vals);
              SendChannel(outch,ht);
              MakeReadOnlySingleObj(pts);
              SendChannel(outch,pts);
              SendChannel(outch,sizes);
              return true;
          elif r = "done" then
              running := running - 1;
              if running = 0 and Length(todo) = 0 then
                  SendChannel(status,id);
              fi;
              return false;
          fi;
      else
          #Print("HS ",id," got data ",Length(r),"\n");
          Add(todo,r);
      fi;
      return false;
  end;

  while true do
      #Print("Hashserver ",id," main loop\n");
      if Poll(true) then return; fi;
      while Length(todo) > 0 do
          r := Remove(todo,1);
          #count := 0;
          for p in r do
              val := HTValue(ht,p);
              if val = fail then
                  HTAdd(ht,p,true);
                  Add(pts,p);
                  if Length(pts)-sent >= chunksize then
                      tosend := EmptyPlist(chunksize+1);
                      Add(tosend,id);
                      for i in [sent+1..sent+chunksize] do
                          Add(tosend,pts[i]);
                      od;
                      MakeReadOnlySingleObj(tosend);
                      running := running + 1;
                      SendChannel(outch,tosend);
                      sent := sent + chunksize;
                      Add(sizes,chunksize);
                      #Print("HS ",id," scheduled ",chunksize,"\n");
                  fi;
              fi;
              #count := count + 1;
              #if count mod 1000 = 0 then Poll(false); fi;
          od;
          if Length(pts) > sent and running < 10 then
              tosend := EmptyPlist(Length(pts)-sent+1);
              Add(tosend,id);
              for i in [sent+1..Length(pts)] do
                  Add(tosend,pts[i]);
              od;
              running := running + 1;
              MakeReadOnlySingleObj(tosend);
              SendChannel(outch,tosend);
              Add(sizes,Length(pts)-sent);
              #Print("HS ",id," scheduled ",Length(pts)-sent,"\n");
              sent := Length(pts);
          fi;
          if Poll(false) then return; fi;
          if running = 0 and Length(todo) = 0 then
              SendChannel(status,id);
              #Print("HS ",id," sent ready.\n");
          fi;
      od;
  od;
end;

Worker := function(gens,op,hashins,hashout,status,f)
  local g,j,n,res,t,x;
  #Print("I am work\n");
  atomic readonly hashins do
      n := Length(hashins);
      while true do
          t := ReceiveChannel(hashout);
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
          SendChannel(hashins[t[1]],"done");
          #Print("Worker sent done to HS ",t[1],"\n");
      od;
  od;
end;

TimeDiff := function(t,t2)
  return (t2-t)*1.E-9;
end;

ParallelOrbit := function(gens,pt,op,opt)
    local allhashes,allpts,allstats,change,h,i,k,o,pos,ptcopy,ready,s,
          started,ti,ti2,ti3,w,x;
    if not IsBound(opt.nrhash) then opt.nrhash := 1; fi;
    if not IsBound(opt.nrwork) then opt.nrwork := 1; fi;
    if not IsBound(opt.disthf) then opt.disthf := x->1; fi;
    if not IsBound(opt.hashlen) then opt.hashlen := 100001; fi;
    if not IsBound(opt.chunksize) then opt.chunksize := 1000; fi;
    if IsGroup(gens) then gens := GeneratorsOfGroup(gens); fi;
    if IsMutable(gens) then MakeImmutable(gens); fi;
    if not(IsReadOnlyObj(gens)) then MakeReadOnlySingleObj(gens); fi;
    if IsMutable(pt) then pt := MakeImmutable(StructuralCopy(pt)); fi;
    if not(IsReadOnlyObj(pt)) then MakeReadOnlySingleObj(pt); fi;

    ti := IO_gettimeofday();
    ptcopy := StructuralCopy(pt);
    ShareObj(ptcopy);
    i := List([1..opt.nrhash],x->CreateChannel());
    o := CreateChannel();
    s := CreateChannel();
    h := List([1..opt.nrhash],x->CreateThread(HashServer,x,ptcopy,opt.hashlen,
                                          i[x],o,s,opt.chunksize));
    #Print("Hash servers started.\n");
    pos := opt.disthf(pt);
    SendChannel(i[pos],[pt]);
    #Print("Seed sent.\n");
    ShareSingleObj(i);
    w := List([1..opt.nrwork],
              x->CreateThread(Worker,gens,op,i,o,s,opt.disthf));
    #Print("Workers started...\n");
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
                    # Print("Hash server #",-x," got some work.\n");
                fi;
                ready[-x] := false;
            else 
                if ready[x] = false then 
                    change := true; 
                    # Print("Hash server #",-x," became idle.\n");
                fi;
                ready[x] := true;
            fi;
            x := TryReceiveChannel(s,fail);
        od;
        # if change then Print("\nCentral: ready is ",ready,"\r"); fi;
    od;
    ti3 := IO_gettimeofday();
    # Now terminate all workers:
    for k in [1..opt.nrwork] do
        SendChannel(o,"exit");
    od;
    #Print("Sent exit.\n");
    for k in [1..opt.nrwork] do
        WaitThread(w[k]);
    od;
    #Print("All workers done.\n");
    # Now terminate all hashservers:
    allhashes := EmptyPlist(k);
    allpts := EmptyPlist(k);
    allstats := EmptyPlist(k);
    atomic readonly i do
        for k in [1..opt.nrhash] do
            SendChannel(i[k],"exit");
            Add(allhashes,ReceiveChannel(o));
            Add(allpts,ReceiveChannel(o));
            Add(allstats,ReceiveChannel(o));
        od;
    od;
    #Print("All hashservers done.\n");
    ti2 := IO_gettimeofday();
    return rec( allhashes := allhashes, allpts := allpts,
                time := TimeDiff(ti,ti2), timeready := TimeDiff(ti,ti3),
                allstats := allstats, nrhash := opt.nrhash,
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
