# This is a second try of a parallel orbit for hpcgap running in threads:
# This time we use a central channel for work distribution.
LoadPackage("orb");
LoadPackage("io");
Read ("../bench.g");
Read ("logging.g");

TaskPool := ShareObj (rec (nrChunks := 0,
                    chunks := [],
                    currentChunk := [],
                    currentChunkSize := 0,
                    outstandingWork := 0));

DeclareGlobalVariable("hasWork");
MakeReadWriteGVar("hasWork");
DeclareGlobalVariable("HashTables");
MakeReadWriteGVar("HashTables");

taskPoolSemaphore := CreateSemaphore(1);
  
DoWork := function (work, nrTasks, op, gens, distHashFun, results)
  local g, x, i;
  for i in [1..nrTasks] do
    for g in gens do 
      x := op (work[i], g);
      MakeReadOnlySingleObj(x);
      Add(results[distHashFun(x)],x);
    od;
  od;
end;

Worker := function(nrWorkers, op, gens, chunkSize, distHashFun, tracing)
  local lock, haveTaskPoolLock, work, i, hashLock, 
        nrProducedElems, nrTasksToGrab, results, accResults,
        j, res, val, t, tasksToAdd, prevNrChunks, bound;
  if tracing then
    Tracing.InitWorkerLog();
  fi;
  tasksToAdd := 0;
  haveTaskPoolLock := false;
  results := EmptyPlist(nrWorkers);
  nrProducedElems := Length(gens);
  for i in [1..nrWorkers] do
    results[i] := EmptyPlist(nrProducedElems*chunkSize);
  od;
  accResults := EmptyPlist(nrProducedElems*chunkSize);
  work := EmptyPlist(chunkSize);
  while true do
    ###### 1. get work
    # 1.1 lock the task pool
    if not haveTaskPoolLock then
      lock := LOCK(TaskPool);
      haveTaskPoolLock := true;
    fi;
    
    # 1.2 if there are 0 chunks of work in the task pool, and one of the workers is
    #     still processing tasks, we release the lock on the task pool and wait for
    #     task pool semaphore to signal when enough tasks are available
    if TaskPool.nrChunks = 0 and TaskPool.outstandingWork > 0 then
      UNLOCK(lock);
      haveTaskPoolLock := false;
      WaitSemaphore(taskPoolSemaphore);
      lock := LOCK(TaskPool);
      haveTaskPoolLock := true;
    fi;
    
    # 1.3 if we are here, it means that either 
    #     i)  there are > 0 chunks of work in the task pool or
    #     ii) there are 0 chunks of work in the task pool, but we are the only
    #         worker doing work
    #     if i) holds, then grab a chunk of work
    #     if ii) holds, grab an incomplete chunk of work
    if TaskPool.nrChunks = 0 then
      if TaskPool.currentChunkSize > 0 then
        work := AdoptObj(TaskPool.currentChunk);
        TaskPool.currentChunk := MigrateObj(EmptyPlist(chunkSize),TaskPool);
        TaskPool.currentChunkSize := 0;
      else
        if tracing then
          Tracing.Close();
        fi;
        return;
      fi;
    else
      work := AdoptObj(Remove(TaskPool.chunks));
      TaskPool.nrChunks := TaskPool.nrChunks - 1;
    fi;
    
    if tracing then
      Tracing.TraceWorkerGotTask();
    fi;
    TaskPool.outstandingWork := TaskPool.outstandingWork + 1;
    
    # 1.5 if there remains > 0 chunks of work in the task pool,
    #     then signal the taskPoolSemaphore and release the lock on the task pool. 
    #     also, if some workers are currently processing tasks, release the task pool
    #     lock, so they can add their results to the task pool.

    
    if TaskPool.nrChunks > 0 or TaskPool.outstandingWork > 1 then
      if TaskPool.nrChunks > 0 then
        SignalSemaphore(taskPoolSemaphore);
      fi;
      UNLOCK(lock);
      haveTaskPoolLock := false;
    fi;
    
    if tracing then
      Tracing.TraceTaskStarted();
    fi;
    
    # 2. do work (this stores results in results list of lists)
    DoWork(work, Length(work), op, gens, distHashFun, results);
    
    # 3. add results to the hash table and task pool
    
    # 3.1 accumulate all results that have not been seen before in 
    #     accResults list
    for i in [1..nrWorkers] do
      if Length(results[i]) > 0 then
        if tracing then
          Tracing.TraceWorkerBlocked();
        fi;
        hashLock := LOCK(HashTables[i]);
        if tracing then
          Tracing.TraceWorkerResumed();
        fi;
        for j in [1..Length(results[i])] do
          res := Remove(results[i]);
          val := HTValue(HashTables[i], res);
          if val = fail then
            HTAdd (HashTables[i], res, true);
            Add(accResults, res);
          fi;
        od;
        UNLOCK(hashLock);
      fi;
    od;
    
    
    # 3.2 if we are not already holding task pool lock, obtain it
    if not haveTaskPoolLock then
      if tracing then
        Tracing.TraceWorkerBlocked();
      fi;
      lock := LOCK(TaskPool);
      if tracing then
        Tracing.TraceWorkerResumed();
      fi;
      haveTaskPoolLock := true;
    fi;
    
    TaskPool.outstandingWork := TaskPool.outstandingWork - 1;
    tasksToAdd := Length(accResults);
    
    # 3.3 add the tasks from accResults to the task pool
    
    if tasksToAdd > 0 then
      prevNrChunks := TaskPool.nrChunks;
      while not IsEmpty(accResults) do
        if Length(accResults) < chunkSize - TaskPool.currentChunkSize then
          bound := Length(accResults);
        else
          bound := chunkSize - TaskPool.currentChunkSize;
        fi;
        for i in [1..bound] do
          Add (TaskPool.currentChunk, Remove(accResults));
        od;
        if tracing and TaskPool.currentChunkSize = 0 then
          Tracing.TraceTaskCreated();
        fi;
        TaskPool.currentChunkSize := TaskPool.currentChunkSize + bound;
        if TaskPool.currentChunkSize = chunkSize then
          Add (TaskPool.chunks, TaskPool.currentChunk);
          TaskPool.nrChunks := TaskPool.nrChunks + 1;
          TaskPool.currentChunk := MigrateObj(EmptyPlist(chunkSize), TaskPool);
          TaskPool.currentChunkSize := 0;
        fi;
      od;
    fi;
    
    if tracing then
      Tracing.TraceTaskFinished();
      Tracing.TraceWorkerIdle();  
    fi;
    
    # 3.4 if there are now enough tasks (>chunksize) in the
    #     task pool, signal the task pool semaphore
    if TaskPool.nrChunks > 0 and prevNrChunks = 0 then
      SignalSemaphore(taskPoolSemaphore);
    fi;
    
    # 3.5 if there are workers processing tasks, release the task pool
    #     lock so they can add their results to it
    if TaskPool.outstandingWork > 0 then 
      UNLOCK(lock);
      haveTaskPoolLock := false;
    fi;
    
  od;
end;

ParallelOrbit := function (gens, pt, op, opt)
  local i, workers;
  if not IsBound(opt.nrwork) then opt.nrwork := 1; fi;
  if not IsBound(opt.disthf) then opt.disthf := x->1; fi;
  if not IsBound(opt.hashlen) then opt.hashlen := 100001; fi;
  if not IsBound(opt.chunksize) then opt.chunksize := 1000; fi;
  if IsGroup(gens) then gens := GeneratorsOfGroup(gens); fi;
  if IsMutable(gens) then MakeImmutable(gens); fi;
  if not(IsReadOnly(gens)) then MakeReadOnlySingleObj(gens); fi;
  if IsMutable(pt) then pt := MakeImmutable(StructuralCopy(pt)); fi;
  if not(IsReadOnly(pt)) then MakeReadOnlySingleObj(pt); fi;
  
  if not IsBound(opt.tracing) then opt.tracing := false; fi;
  
  if opt.tracing then
    StartLogging();
  fi;
  
  hasWork := CreateChannel();
  HashTables := AtomicList ([]);
  for i in [1..opt.nrwork] do
    HashTables[i] := ShareObj(HTCreate(pt, rec (hashlen := opt.hashlen)));
  od;
  atomic TaskPool do
    TaskPool.nrChunks := 0;
    TaskPool.currentChunk := MigrateObj(EmptyPlist(opt.chunksize), TaskPool);
    Add(TaskPool.currentChunk, MakeReadOnlySingleObj(pt));
    if opt.tracing then
      Tracing.TraceTaskCreated();
    fi;
    TaskPool.currentChunkSize := 1;
  od;
  SendChannel (hasWork, 1);
  workers := List ([1..opt.nrwork], \x -> CreateThread(Worker,opt.nrwork,op,gens,opt.chunksize,opt.disthf,opt.tracing));
  for i in [1..opt.nrwork] do
    WaitThread(workers[i]);
  od;
  
  if opt.tracing then
    StopLogging();
  fi;
  
  return true;
    
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
  hf := ChooseHashFunction(x,n);
  data := hf.data;
  MakeReadOnlySingleObj(data);
  hf := hf.func;
  return y->hf(y,data);
end;

if IsBound(MakeReadOnlySingleObj) then
    OnRightRO := function(x,g)
      local y;
      y := x*g;
      MakeReadOnlySingleObj(y);
      return y;
    end;
else
    OnRightRO := OnRight;
fi;

#Read ("HNdata.g");
#r := Bench( do ParallelOrbit(gens,v,OnRightRO,
#        rec(nrwork := 16, disthf := MakeDistributionHF(v,16)));; od);
        
