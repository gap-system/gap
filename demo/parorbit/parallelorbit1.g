# This is a trivial parallel orbit for hpcgap running in threads:

LoadPackage("orb");

HashServer := function(pt,hashsize,inch,outch,chunksize)
  local Poll,count,done,ht,p,pts,r,running,todo,val;
  ht := HTCreate(pt,rec( hashlen := hashsize ));
  pts := EmptyPlist(hashsize);
  done := 0;
  running := 0;
  todo := [];
  Poll := function(wait)
      local l,len,r;
      if wait then
          r := ReceiveChannel(inch);
      else
          r := TryReceiveChannel(inch,fail);
          if r = fail then return; fi;
      fi;
      if IsStringRep(r) then
          if r = "exit" then 
              SendChannel(outch,ht);
              SendChannel(outch,pts);
              return;
          elif r = "done" then
              running := running - 1;
              return;
          elif r = "gettask" then
              len := Length(pts);
              if len = done then
                  if running = 0 and Length(todo) = 0 then
                      SendChannel(outch,len);
                      return;
                  fi;
                  l := [];
              elif len - done >= chunksize then
                  l := pts{[done+1..done+chunksize]};
                  done := done + chunksize;
              else
                  l := pts{[done+1..len]};
                  done := len;
              fi;
              if Length(l) > 0 then
                  running := running + 1;
              fi;
              SendChannel(outch,l);
          fi;
      else
          Add(todo,r);
      fi;
  end;

  while true do
      Poll(true);
      if Length(todo) > 0 then
          r := Remove(todo,1);
          count := 0;
          for p in r do
              val := HTValue(ht,p);
              if val = fail then
                  HTAdd(ht,p,true);
                  Add(pts,p);
              fi;
              count := count + 1;
              if count mod 1000 = 0 then Poll(false); fi;
          od;
      fi;
  od;
end;

Worker := function(gens,op,hashins,hashouts,f)
  local g,i,j,lens,n,readies,res,t,x;
  Print("Hello there\n");
  atomic readonly hashins,hashouts,gens do
      n := Length(hashins);
      i := Random([1..n]);
      lens := EmptyPlist(n);
      while true do
          readies := 0;
          while true do
              i := i + 1; if i > n then i := 1; fi;
              SendChannel(hashins[i],"gettask");
              t := ReceiveChannel(hashouts[i]);
              if IsInt(t) then
                  # for the first n "ready" signals we see we keep their
                  # point count, for the next n "ready" signals we check
                  # we check whether or not it is still the same.
                  # When we have seen a "ready" signal from each hash server
                  # twice and no one has scheduled a job between the two,
                  # then all is done and we exit.
                  readies := readies + 1;
                  if readies <= n then
                      lens[i] := t;
                  elif lens[i] < t then
                      lens[i] := t;
                      readies := 1;
                  elif readies >= 2*n then 
                      return; 
                  fi;
                  continue;
              fi;
              readies := 0;
              if Length(t) > 0 then break; fi;
          od;
          res := List([1..n],x->EmptyPlist(QuoInt(Length(t)*Length(gens)*2,n)));
          for j in [1..Length(t)] do
              for g in gens do
                  x := op(t[j],g);
                  Add(res[f(x)],x);
              od;
          od;
          for j in [1..n] do
              if Length(res[j]) > 0 then
                  SendChannel(hashins[j],res[j]);
              fi;
          od;
          SendChannel(hashins[i],"done");
      od;
  od;
end;

TimeDiff := function(t,t2)
  local a,b;
  a := 1.0 * t.tv_sec + 1.E-6 * t.tv_usec;
  b := 1.0 * t2.tv_sec + 1.E-6 * t2.tv_usec;
  return b - a;
end;

ParallelOrbit := function(gens,pt,op,opt)
    local allhashes,allpts,h,i,k,o,pos,ptcopy,ti,ti2,w;
    if not IsBound(opt.nrhash) then opt.nrhash := 1; fi;
    if not IsBound(opt.nrwork) then opt.nrwork := 1; fi;
    if not IsBound(opt.disthf) then opt.disthf := x->1; fi;
    if not IsBound(opt.hashlen) then opt.hashlen := 100001; fi;
    if not IsBound(opt.chunksize) then opt.chunksize := 1000; fi;
    if IsGroup(gens) then gens := GeneratorsOfGroup(gens); fi;
    if IsMutable(gens) then MakeImmutable(gens); fi;
    if IsMutable(pt) then pt := MakeImmutable(StructuralCopy(pt)); fi;

    ti := IO_gettimeofday();
    ptcopy := StructuralCopy(pt);
    ShareObj(ptcopy);
    i := List([1..opt.nrhash],x->CreateChannel());
    o := List([1..opt.nrhash],x->CreateChannel());
    h := List([1..opt.nrhash],x->CreateThread(HashServer,ptcopy,opt.hashlen,
                                          i[x],o[x],opt.chunksize));
    pos := opt.disthf(pt);
    SendChannel(i[pos],[pt]);
    ShareSingleObj(i);
    ShareSingleObj(o);
    w := List([1..opt.nrwork],
              x->CreateThread(Worker,gens,op,i,o,opt.disthf));
    for k in [1..opt.nrwork] do
        WaitThread(w[k]);
    od;
    allhashes := EmptyPlist(k);
    allpts := EmptyPlist(k);
    atomic readonly i,o do
        for k in [1..opt.nrhash] do
            SendChannel(i[k],"exit");
            Add(allhashes,ReceiveChannel(o[k]));
            Add(allpts,ReceiveChannel(o[k]));
        od;
    od;
    ti2 := IO_gettimeofday();
    return rec( allhashes := allhashes, allpts := allpts,
                time := TimeDiff(ti,ti2) );
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
  MakeReadOnlyObj(y);
  return y;
end;

OnSubspacesByCanonicalBasisRO := function(x,g)
  local y;
  y := OnSubspacesByCanonicalBasis(x,g);
  MakeReadOnlyObj(y);
  return y;
end;

m := MathieuGroup(24);
# r := ParallelOrbit(m,1,OnPoints,rec());;
# r := ParallelOrbit(m,[1,2,3,4],OnTuples,
#     rec(nrhash := 2,nrwork := 2, disthf := x -> (x[1] mod 2) + 1));;
