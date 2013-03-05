# This is a second try of a parallel orbit for hpcgap running in threads:
# This time we use a central channel for work distribution.
LoadPackage("orb");
Read ("../bench.g");

TaskPool := ShareObj (rec (nrTasks := 0,
                    chunkSize := 0,
                    tasks := [],
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
      MakeReadOnlyObj(x);
      Add(results[distHashFun(x)],x);
    od;
  od;
end;

Worker := function(nrWorkers, op, gens, chunkSize, distHashFun)
  local lock, haveTaskPoolLock, work, i, hashLock, 
        nrProducedElems, nrTasksToGrab, results, accResults,
        j, res, val, t, tasksToAdd;
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
    
    # 1.2 if there are not enough tasks in the task pool, and one of the workers is
    #     still processing tasks, we release the lock on the task pool and wait for
    #     task pool semaphore to signal when enough tasks are available
    if TaskPool.nrTasks < TaskPool.chunkSize and TaskPool.outstandingWork > 0 then
      UNLOCK(lock);
      haveTaskPoolLock := false;
      WaitSemaphore(taskPoolSemaphore);
      lock := LOCK(TaskPool);
      haveTaskPoolLock := true;
    fi;
    
    # 1.3 if we are here, it means that either 
    #     i)  there are enough (>chunksize) tasks in the task pool or
    #     ii) there are not enough tasks in the task pool, but we are the only
    #         worker doing work
    if TaskPool.nrTasks > TaskPool.chunkSize then
      nrTasksToGrab := TaskPool.chunkSize;
    elif TaskPool.nrTasks > 0 then
      nrTasksToGrab := TaskPool.nrTasks;
    else
      return;
    fi;
    
    # 1.4 grab the nrTasksToGrab from the task pool
    for i in [1..nrTasksToGrab] do
      work[i] := Remove(TaskPool.tasks);
    od;
    TaskPool.nrTasks := TaskPool.nrTasks - nrTasksToGrab;
    TaskPool.outstandingWork := TaskPool.outstandingWork + 1;
    
    # 1.5 if there remains enough tasks in the task pool for other workers,
    #     then signal the taskPoolSemaphore and release the lock on the task pool. 
    #     also, if some workers are currently processing tasks, release the task pool
    #     lock, so they can add their results to the task pool.
    if TaskPool.nrTasks > TaskPool.chunkSize or TaskPool.outstandingWork > 1 then
      if TaskPool.nrTasks > TaskPool.chunkSize then
        SignalSemaphore(taskPoolSemaphore);
      fi;
      UNLOCK(lock);
      haveTaskPoolLock := false;
    fi;
    
    # 2. do work (this stores results in results list of lists)
    DoWork(work, nrTasksToGrab, op, gens, distHashFun, results);
    
    # 3. add results to the hash table and task pool
    
    # 3.1 accumulate all results that have not been seen before in 
    #     accResults list
    for i in [1..nrWorkers] do
      if Length(results[i]) > 0 then
        hashLock := LOCK(HashTables[i]);
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
      lock := LOCK(TaskPool);
      haveTaskPoolLock := true;
    fi;
    
    TaskPool.outstandingWork := TaskPool.outstandingWork - 1;
    tasksToAdd := Length(accResults);
    
    # 3.3 add the tasks from accResults to the task pool
    if tasksToAdd > 0 then
      while not IsEmpty(accResults) do
        Add (TaskPool.tasks, Remove(accResults));
      od;
      TaskPool.nrTasks := TaskPool.nrTasks + tasksToAdd;
    fi;
    
    # 3.4 if there are now enough tasks (>chunksize) in the
    #     task pool, signal the task pool semaphore
    if TaskPool.nrTasks > TaskPool.chunkSize and 
       TaskPool.nrTasks - tasksToAdd <= TaskPool.chunkSize then
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
  if not(IsReadOnly(gens)) then MakeReadOnlyObj(gens); fi;
  if IsMutable(pt) then pt := MakeImmutable(StructuralCopy(pt)); fi;
  if not(IsReadOnly(pt)) then MakeReadOnlyObj(pt); fi;
  
  hasWork := CreateChannel();
  HashTables := AtomicList ([]);
  for i in [1..opt.nrwork] do
    HashTables[i] := ShareObj(HTCreate(pt, rec (hashlen := opt.hashlen)));
  od;
  atomic TaskPool do
    TaskPool.nrTasks := 1;
    Add(TaskPool.tasks, MakeReadOnlyObj(pt));
    TaskPool.chunkSize := opt.chunksize;
  od;
  SendChannel (hasWork, 1);
  workers := List ([1..opt.nrwork], \x -> CreateThread(Worker,opt.nrwork,op,gens,opt.chunksize,opt.disthf));
  for i in [1..opt.nrwork] do
    WaitThread(workers[i]);
  od;
  
  return true;
    
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

MakeDistributionHF := function(x,n) 
  local hf,data;
  hf := ChooseHashFunction(x,n);
  data := hf.data;
  MakeReadOnlyObj(data);
  hf := hf.func;
  return y->hf(y,data);
end;

m := MathieuGroup(24);
# r := ParallelOrbit(m,1,OnPoints,rec());;
r := Bench( do ParallelOrbit(m,[1,2,3,4],OnTuples,
        rec(nrwork := 2, disthf := MakeDistributionHF([1,2,3,4],2)));; od);
Print ("Runtime is ", r, "\n");
        
