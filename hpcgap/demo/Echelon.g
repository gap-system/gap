#############################################################################
##  
#W  Echelon.g                    GAP Library                    Frank Lübeck 
##  
#Y  Copyright (C)  2010,  The GAP Group
##  
##  This file contains functions to compute echelon forms of matrices using 
##  multiple threads. 
##  It also contains some generic utility functions for writing such code
##  (see ThreadFunction, CreateChannelsAndThreads,
##  DestroyChannelsAndThreads, DistributeTasks, and their usage in
##  TrigonalizeByThreads).
##  
##  (for the moment we only trigonalize, we can easily extend it to
##  semi-echelon and full-echelon if we keep this code.)
## 
##  # some example input
##  time := 0;
##  m1 := RandomMat(500,500,GF(5));;
##  m := List(m1,ShallowCopy);;
##  res := TrigonalizeBySubsets(m,10,25);;time;
##  m := List(m1,ShallowCopy);;
##  t1:=CurrentTime();res1:=TrigonalizeByThreads(m,4,5,40);;t2:=CurrentTime();
##  

# (very?) temporary helper, until RecieveAnyChannel is available
# 
# this version is bad, it eats up CPU cycles and doesn't provide a good
# load balancing
MyReceiveAnyChannel := function(l)
  local res, ch;
  while true do
    for ch in l do
      res := TryReceiveChannel(ch, fail);
      if res <> fail then
        return res;
      fi;
    od;
  od;
end;


#############################################################################
##  
##  TrigonalizeSubset(mat, pivots, inds)  
##  
##  Arguments: matrix mat with, say, n rows;
##             list pivots of length n, such that 
##                  pivots[i] = PositionNonZero(mat[i]) or = 0;
##             inds is a sublist of [1..n].
##  
##  We assume that pivots is monotonically increasing.
##  TrigonalizeSubset computes destructively a trigonal form of the submatrix
##  mat{inds} using row operations. (So with inds = [1..Length(mat)] the whole 
##  job would be done.)
##  
##  This function could easily be provided from the kernel for compressed 
##  matrices, but it is not so bad as it is.
##  
##  I have experimented with PositionNonZero, PositionNot, POSITION_NOT,
##  but the fastest way to find the new pivots seems to be to use none of
##  these. This is probably reasonable for dense matrices, but may not be
##  true for very sparse matrices.
##  
TrigonalizeSubset := function(mat, pivots, inds)
  local t, ncols, zero, res, newpivots, done, piv, v, c, i, pos;
  t := Runtime();
  ncols := Length(mat[1]);
  zero := Zero(mat[1][1]);
  res := [];
  newpivots := [];
  done := [];
  # populate result with rows with different pivots
  if pivots[inds[1]] > 0 then
    piv := 0;
    for i in inds do
      if pivots[i] > piv then
        Add(res, mat[i]);
        piv := pivots[i];
        Add(newpivots, piv);
        done[i] := true;
      fi;
    od;
  fi;
  for i in inds do
    if not IsBound(done[i]) then
      v := mat[i];
      piv := pivots[i];
      if piv = 0 then
        # case of a not seen vector
        piv := 1;
        while piv <= ncols and v[piv] = zero do
          piv := piv+1;
        od;
      fi;
      for pos in [1..Length(res)] do
        if newpivots[pos] = piv and piv <= ncols then
          # can be reduced by a row in res
          c := -v[piv]/res[pos][piv];
          AddRowVector(v, res[pos], c);
          piv := piv+1;
          while piv <= ncols and v[piv] = zero do
            piv := piv+1;
          od;
        elif newpivots[pos] >= piv then
          Add(res, v, pos);
          Add(newpivots, piv, pos);
          break;
        fi;
      od;
      if Length(res) = 0 or newpivots[pos] < piv then
        Add(res, v);
        Add(newpivots, piv);
      fi;
    fi;
  od;
##  We return res and newpivots and let the handler receiving the result 
##  write them into mat and pivots. Alternatively, we could do this here,
##  return a dummy result and use a noop result handler.
##    # write result into mat and pivots
##    mat{inds} := res;
##    pivots{inds} := newpivots;
  Info(InfoDebug, 2, Runtime()-t, " ", Length(inds));
##    return true;
  return [res, newpivots, inds];
end;

#############################################################################
##  
##  This is an experimental function. Instead of trigonalizing in one step,
##  we trigonalize num intervals of rows, then sort all rows such that the 
##  list of pivots in non-decreasing, and start over. This is done rounds
##  times and afterwards the rest is done in a single interval.
##  The nice point is here that the total running time is almost the same for 
##  a large range of values for num and rounds. This means we have split the
##  whole work into many small tasks with neglectible overhead.
##  
##  I have played with various possibilities to vary the lengths of the
##  intervals of rows given to TrigonalizeSubset during the algorithm.
##  The best seems to be to keep these intervals the same all the time
##  and do the cleaning interval-wise for about 2 * #intervals rounds.
##  Then very little is left to do for the final cleanup.
##  
TrigonalizeBySubsets := function(mat, num, rounds)
  local len, pivots, round, ilen, intv, res, i;
  len := Length(mat);
  # initialize pivots as unknown
  pivots := 0*[1..len];
  round := 0;
  repeat 
    # the last round must be with num = 1 to ensure a trigonal form
    # in the result
    if round = rounds then num := 1; fi;

    # split rows of mat into num intervals and call TrigonalizeSubset
    # for these
    ilen := QuoInt(len, num);
    for i in [1..num] do
      if i < num then
        intv := (i-1)*ilen+[1..ilen];
      else
        intv := [(num-1)*ilen+1..len];
      fi;
      res := TrigonalizeSubset(mat, pivots, intv);
      mat{res[3]} := res[1];
      pivots{res[3]} := res[2];
    od;
    
    # sort rows by pivot and start over
    SortParallel(pivots,mat);
    round := round+1;
  until ilen=len;
  return [mat, pivots];
end;



#############################################################################
##  
##  So, now lets do the same with several threads.   
##  
##  We first give a straight forward variant TrigonalizeByThreads1.
##  
##  Looking at the code of TrigonalizeByThreads1  we see that in fact the whole
##  mechanism has very little to do with the specific application. 
##  
##  Therefore we provide some completely generic utility functions to start and 
##  destroy a number of threads and channels. And also a generic function which 
##  distributes tasks among such a collection of threads.
##  
##  Using this we can write an elegant and short function
##  TrigonalizeByThreads.
##  
TrigonalizeByThreads1 := function(mat, nthreads, mult, rounds)
  local len, pivots, num, inchs, outchs, handler, threads, ilen, j, nres, 
        intv, res, i, round, k;
  len := Length(mat);
  pivots := 0*[1..len];
  num := mult * nthreads;
  inchs := List([1..nthreads], i-> CreateChannel());
  outchs := List([1..nthreads], i-> CreateChannel());
  # the loop for each thread
  handler := function(i)
    local inch, outch, task, res;
    inch := inchs[i];
    outch := outchs[i];
    while true do
      task := ReceiveChannel(inch);
      # this means we are done
      if task = 0 then 
        return;
      fi;
 IsRange(task[3]);
 Print("Th ", i,": ",task[3],"\n"); 
      res := CallFuncList(TrigonalizeSubset, task);
      # we add i to indicate which thread is free
      Add(res, i);
      SendChannel(outch, res);
    od;
  end;
  threads := [];
  for i in [1..nthreads] do
    threads[i] := CreateThread(handler, i);
  od;
  for round in [1..rounds] do
    ilen := QuoInt(len, num);
    # we start with the last interval since this seems to take longer sometimes
    j := num;
    nres := 0;
    intv := [(num-1)*ilen+1..len];
    # first feed all threads
    for k in [1..nthreads] do
      SendChannel(inchs[k], [mat, pivots, intv]);
      j := j-1;
      intv := (j-1)*ilen+[1..ilen];
    od;
    while j > 0 do
      res := MyReceiveAnyChannel(outchs);
      nres := nres+1;
      mat{res[3]} := res[1];
      pivots{res[3]} := res[2];
      SendChannel(inchs[res[4]], [mat,pivots,intv]);
      j := j-1;
      intv := (j-1)*ilen+[1..ilen];
    od;
    while nres < num do
      res := MyReceiveAnyChannel(outchs);
      nres := nres+1;
      mat{res[3]} := res[1];
      pivots{res[3]} := res[2];
    od;
    # now this round is done and we sort
    SortParallel(pivots,mat);
  od;
  # the final cleanup is single threaded
  for i  in [1..nthreads] do
    # close threads and channels
    SendChannel(inchs[i], 0);
    WaitThread(threads[i]);
    DestroyChannel(inchs[i]);
    DestroyChannel(outchs[i]);
  od;
  intv := [1..len];
  res := TrigonalizeSubset(mat, pivots, intv);
  mat{intv} := res[1];
  pivots{intv} := res[2];
  return [mat, pivots];
end;


#############################################################################
##  
##  This is a generic function to start a thread. It receives tasks to do from
##  an input channel. 
##  A task is a pair [workfunc, args] of a function and the list of its 
##  arguments, the function must return something.
##  The result res = CallFuncList(workfunc, args) is sent into the output
##  channel in the form [res, id], such that id allows to identify this thread.
## 
##  The task can also be 0 and this tells the thread to terminate.
##  
ThreadFunction := function(id, inch, outch)
  local task, res;
  while true do 
    # the tasks we get are inputs to TrigonalizeSubset or 0 to finish
    task := ReceiveChannel(inch);
    # a task 0  means we are done
    if task = 0 then 
      return;
    fi;
    res := CallFuncList(task[1], task[2]);
    # we return res and id such that the master knows which thread is free
    SendChannel(outch, [res,id]);
  od;
end;

# create n threads with n input and n output channels
CreateChannelsAndThreads := function(n)
  local inchs, outchs, threads, i;
  inchs := List([1..n], i-> CreateChannel());
  outchs := List([1..n], i-> CreateChannel());
  # now start threads
  threads := [];
  for i in [1..n] do
    threads[i] := CreateThread(ThreadFunction, i, inchs[i], outchs[i]);
  od;
  return [threads, inchs, outchs];
end;
# and destroy them, arg is output of last function
DestroyChannelsAndThreads := function(chths)
  local n, i;
  n := Length(chths[1]);
  for i  in [1..n] do
    # send stop tasks
    SendChannel(chths[2][i], 0);
  od;
  for i in [1..n] do
    WaitThread(chths[1][i]);
    DestroyChannel(chths[2][i]);
    DestroyChannel(chths[3][i]);
  od;
end;

#############################################################################
##  
##  With this function we distribute a list of tasks among a list of threads,
##  created with the functions above.
##  
##  Arguments:
##       threads is list of threads, 
##       inchs and outchs the same number of channels,
##       tasks can be a list or an enumerator, 
##       ntasks the number of tasks, and
##       handler a function that is applied to the results of each task.
##  
DistributeTasks := function(threads, inchs, outchs, tasks, ntasks, handler)
  local nthreads, nres, res, i;
  nthreads := Length(threads);
  nres := 0;
  for i in [1..nthreads] do
    # first feed all threads
    SendChannel(inchs[i], tasks[i]);
  od;
  for i in [nthreads+1..ntasks] do
    # wait for a thread sending the result and feed it with the next task
    res := MyReceiveAnyChannel(outchs);
    nres := nres+1;
    # send the next task to this thread number res[2]
    SendChannel(inchs[res[2]], tasks[i]);
    # call the handler function
    handler(res[1]);
  od;
  # all tasks are sent away, now collect the remaining results
  while nres < ntasks do
    res := MyReceiveAnyChannel(outchs);
    nres := nres+1;
    handler(res[1]);
  od;
end;

#############################################################################
##  
##  With these utilities it is easy to write a threaded version
##  of TrigonalizeBySubsets.
##  
TrigonalizeByThreads := function(mat, nthreads, mult, rounds)
  local len, pivots, num, qr, intervals, e, b, thchs, res, round, i;
  len := Length(mat);
  pivots := 0*[1..len];
  num := mult * nthreads;
  # find len/num intervals of [1..len] (is there an elegant one-liner?)
  qr := QuotientRemainder(len, num);
  intervals := [];
  e := len; b := len-qr[1]+1;
  while b >= 0 do
    Add(intervals, [b..e]);
    e := b-1;
    if qr[2] > 0 then
      b := e-qr[1];
      qr[2] := qr[2]-1;
    else
      b := e-qr[1]+1;
    fi;
  od;
  # create the threads
  thchs := CreateChannelsAndThreads(nthreads);
  for round in [1..rounds] do
    DistributeTasks(thchs[1], thchs[2], thchs[3], List(intervals, intv -> 
                 [TrigonalizeSubset, [mat, pivots, intv]]), num,
                  function(res) mat{res[3]} := res[1]; pivots{res[3]} := res[2]; end);
    # do we need an explicit memory barrier here?
    SortParallel(pivots,mat);
  od;
  # clean out the rest
  res := TrigonalizeSubset(mat, pivots, [1..len]);
  
  # That is it for now. But we can easily add some code here to also cover
  # the cases of semi-echelon form and full-echelon form computations.

  # ...

  # destroys channels and threads
  DestroyChannelsAndThreads(thchs);
  return [mat, pivots];
end;


