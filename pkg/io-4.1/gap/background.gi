#############################################################################
##
##  background.gi               GAP 4 package IO
##                                                           Max Neunhoeffer
##
##  Copyright (C) 2006-2011 by Max Neunhoeffer
##
##  This file is free software, see license information at the end.
##
##  This file contains the implementations for background jobs using fork.
##

InstallGlobalFunction(DifferenceTimes,
  function(t1, t2)
    local x;
    x := (t1.tv_sec*1000000+t1.tv_usec) - (t2.tv_sec*1000000+t2.tv_usec);
    return rec(tv_usec := x mod 1000000,
               tv_sec := (x - x mod 1000000) / 1000000);
  end);

InstallGlobalFunction(CompareTimes,
  function(t1, t2)
    local a,b;
    a := t1.tv_sec * 1000000 + t1.tv_usec;
    b := t2.tv_sec * 1000000 + t2.tv_usec;
    if a < b then return -1;
    elif a > b then return 1;
    else return 0;
    fi;
  end);

InstallMethod(BackgroundJobByFork, "for a function and a list",
  [IsFunction, IsObject],
  function(fun, args)
    return BackgroundJobByFork(fun, args, rec());
  end );

InstallValue(BackgroundJobByForkOptions,
  rec(
    TerminateImmediately := false,
    BufferSize := 8192,
  ));

InstallMethod(BackgroundJobByFork, "for a function, a list and a record",
  [IsFunction, IsObject, IsRecord],
  function(fun, args, opt)
    local j, n;
    IO_InstallSIGCHLDHandler();
    for n in RecNames(BackgroundJobByForkOptions) do
        if not(IsBound(opt.(n))) then 
            opt.(n) := BackgroundJobByForkOptions.(n);
        fi;
    od;
    j := rec( );
    j.childtoparent := IO_pipe();
    if j.childtoparent = fail then
        Info(InfoIO, 1, "Could not create pipe.");
        return fail;
    fi;
    if opt.TerminateImmediately then
        j.parenttochild := false;
    else
        j.parenttochild := IO_pipe();
        if j.parenttochild = fail then
            IO_close(j.childtoparent.toread);
            IO_close(j.childtoparent.towrite);
            Info(InfoIO, 1, "Could not create pipe.");
            return fail;
        fi;
    fi;
    j.pid := IO_fork();
    if j.pid = fail then
        Info(InfoIO, 1, "Could not fork.");
        return fail;
    fi;
    if j.pid = 0 then
        # we are in the child:
        IO_close(j.childtoparent.toread);
        j.childtoparent := IO_WrapFD(j.childtoparent.towrite,
                                     false, opt.BufferSize);
        if j.parenttochild <> false then
            IO_close(j.parenttochild.towrite);
            j.parenttochild := IO_WrapFD(j.parenttochild.toread,
                                         opt.BufferSize, false);
        fi;
        BackgroundJobByForkChild(j, fun, args);
        IO_exit(0);  # just in case
    fi;
    # Here we are in the parent:
    IO_close(j.childtoparent.towrite);
    j.childtoparent := IO_WrapFD(j.childtoparent.toread,
                                 opt.BufferSize, false);
    if j.parenttochild <> false then
        IO_close(j.parenttochild.toread);
        j.parenttochild := IO_WrapFD(j.parenttochild.towrite,
                                     false, opt.BufferSize);
    fi;
    j.terminated := false;
    j.result := false;
    j.idle := args = fail;
    Objectify(BGJobByForkType, j);
    return j;
  end );

InstallGlobalFunction(BackgroundJobByForkChild,
  function(j, fun, args)
    local ret;
    while true do   # will be left by break
        if args <> fail then   # the case to make an as yet idle worker
            ret := CallFuncList(fun, args);
            IO_Pickle(j.childtoparent, ret);
            IO_Flush(j.childtoparent);
        fi;
        if j.parenttochild = false then break; fi;
        args := IO_Unpickle(j.parenttochild);
        if not(IsList(args)) then break; fi;
    od;
    IO_Close(j.childtoparent);
    if j.parenttochild <> false then
        IO_Close(j.parenttochild);
    fi;
    IO_exit(0);
  end);

InstallMethod(IsIdle, "for a background job by fork",
  [IsBackgroundJobByFork],
  function(j)
    if j!.terminated then return fail; fi;
    # Note that we have to check every time, since the job might have
    # terminated in the meantime!
    if IO_HasData(j!.childtoparent) then
        j!.result := IO_Unpickle(j!.childtoparent);
        if j!.result = IO_Nothing or j!.result = IO_Error then
            j!.result := fail;
            j!.terminated := true;
            j!.idle := fail;
            IO_Close(j!.childtoparent);
            if j!.parenttochild <> false then
                IO_Close(j!.parenttochild);
            fi;
            IO_WaitPid(j!.pid,true);
            return fail;
        fi;
        j!.idle := true;
        return true;
    fi;
    return j!.idle;
  end);

InstallMethod(HasTerminated, "for a background job by fork",
  [IsBackgroundJobByFork],
  function(j)
    if j!.terminated then return true; fi;
    return IsIdle(j) = fail;
  end);

InstallMethod(WaitUntilIdle, "for a background job by fork",
  [IsBackgroundJobByFork],
  function(j)
    local fd,idle,l;
    idle := IsIdle(j);
    if idle = true then return j!.result; fi;
    if idle = fail then return fail; fi;
    fd := IO_GetFD(j!.childtoparent);
    l := [fd];
    IO_select(l,[],[],false,false);
    j!.result := IO_Unpickle(j!.childtoparent);
    if j!.result = IO_Nothing or j!.result = IO_Error then
        j!.result := fail;
        j!.terminated := true;
        j!.idle := fail;
        IO_Close(j!.childtoparent);
        if j!.parenttochild <> false then
            IO_Close(j!.parenttochild);
        fi;
        IO_WaitPid(j!.pid,true);
        return fail;
    fi;
    j!.idle := true;
    if j!.parenttochild = false then
        IO_Close(j!.childtoparent);
        IO_WaitPid(j!.pid,true);
        j!.terminated := true;
    fi;
    return j!.result;
  end);
 
InstallMethod(Kill, "for a background job by fork",
  [IsBackgroundJobByFork],
  function(j)
    if j!.terminated then return; fi;
    IO_kill(j!.pid,IO.SIGTERM);
    IO_Close(j!.childtoparent);
    if j!.parenttochild <> false then
        IO_Close(j!.parenttochild);
    fi;
    IO_WaitPid(j!.pid,true);
    j!.idle := fail;
    j!.terminated := true;
    j!.result := fail;
  end);

InstallMethod(ViewObj, "for a background job by fork",
  [IsBackgroundJobByFork],
  function(j)
    local idle;
    Print("<background job by fork pid=",j!.pid);
    idle := IsIdle(j);
    if idle = true then 
        Print(" currently idle>"); 
    elif idle = fail then
        Print(" already terminated>");
    else
        Print(" busy>");
    fi;
  end);

InstallMethod(Pickup, "for a background job by fork",
  [IsBackgroundJobByFork],
  function(j)
    return WaitUntilIdle(j);
  end);

InstallMethod(Submit, "for a background job by fork and an object",
  [IsBackgroundJobByFork, IsObject],
  function(j,o)
    local idle,res;
    if j!.parenttochild = false then
        Error("job terminated immediately after finishing computation");
        return fail;
    fi;
    idle := IsIdle(j);
    if idle = false then
        Error("job must be idle to send the next argument list");
        return fail;
    elif idle = fail then
        Error("job has already terminated");
        return fail;
    fi;
    res := IO_Pickle(j!.parenttochild,o);
    if res <> IO_OK then
        Info(InfoIO, 1, "problems sending argument list", res);
        return fail;
    fi;
    IO_Flush(j!.parenttochild);
    j!.idle := false;
    return true;
  end);

InstallMethod(ParTakeFirstResultByFork, "for two lists",
  [IsList, IsList],
  function(jobs, args)
    return ParTakeFirstResultByFork(jobs, args, rec());
  end);

InstallValue( ParTakeFirstResultByForkOptions,
  rec( TimeOut := rec(tv_sec := false, tv_usec := false),
  ));

# Hack for old windows binary:
if not(IsBound(IO_gettimeofday)) then
    IO_gettimeofday := function() return rec( tv_sec := 0, tv_usec := 0 ); end;
fi;

InstallMethod(ParTakeFirstResultByFork, "for two lists and a record",
  [IsList, IsList, IsRecord],
  function(jobs, args, opt)
    local answered,answers,i,j,jo,n,pipes,r;
    if not(ForAll(jobs,IsFunction) and ForAll(args,IsList) and
           Length(jobs) = Length(args)) then
        Error("jobs must be a list of functions and args a list of lists, ",
              "both of the same length");
        return fail;
    fi;
    for n in RecNames(ParTakeFirstResultByForkOptions) do
        if not(IsBound(opt.(n))) then 
            opt.(n) := ParTakeFirstResultByForkOptions.(n); 
        fi;
    od;
    n := Length(jobs);
    jo := EmptyPlist(n);
    for i in [1..n] do
        jo[i] := BackgroundJobByFork(jobs[i],args[i],
                                     rec(ImmediatelyTerminate := true));
        if jo[i] = fail then
            for j in [1..i-1] do
                Kill(jo[i]);
            od;
            Info(InfoIO, 1, "Could not start all background jobs.");
            return fail;
        fi;
    od;
    pipes := List(jo,j->IO_GetFD(j!.childtoparent));
    r := IO_select(pipes,[],[],opt.TimeOut.tv_sec,opt.TimeOut.tv_usec);
    answered := [];
    answers := EmptyPlist(n);
    for i in [1..n] do
        if pipes[i] = fail then
            Kill(jo[i]);
            Info(InfoIO,2,"Child ",jo[i]!.pid," has been terminated.");
        else
            Add(answered,i);
        fi;
    od;
    Info(InfoIO,2,"Getting answers...");
    for i in answered do
        answers[i] := WaitUntilIdle(jo[i]);
        Info(InfoIO,2,"Child ",jo[i]!.pid," has terminated with answer.");
        Kill(jo[i]);  # this is to cleanup data structures
    od;
    return answers;
  end);

InstallMethod(ParDoByFork, "for two lists",
  [IsList, IsList],
  function(jobs, args)
    return ParDoByFork(jobs, args, rec());
  end);

InstallValue( ParDoByForkOptions,
  rec( TimeOut := rec(tv_sec := false, tv_usec := false),
  ));

InstallMethod(ParDoByFork, "for two lists and a record",
  [IsList, IsList, IsRecord],
  function(jobs, args, opt)
    local cmp,diff,fds,i,j,jo,jobnr,n,now,pipes,r,results,start;
    if not(ForAll(jobs,IsFunction) and ForAll(args,IsList) and
           Length(jobs) = Length(args)) then
        Error("jobs must be a list of functions and args a list of lists, ",
              "both of the same length");
        return fail;
    fi;
    for n in RecNames(ParDoByForkOptions) do
        if not(IsBound(opt.(n))) then 
            opt.(n) := ParDoByForkOptions.(n); 
        fi;
    od;
    n := Length(jobs);
    jo := EmptyPlist(n);
    for i in [1..n] do
        jo[i] := BackgroundJobByFork(jobs[i],args[i],
                                     rec(ImmediatelyTerminate := true));
        if jo[i] = fail then
            for j in [1..i-1] do
                Kill(jo[i]);
            od;
            Info(InfoIO, 1, "Could not start all background jobs.");
            return fail;
        fi;
    od;
    pipes := List(jo,j->IO_GetFD(j!.childtoparent));
    results := EmptyPlist(n);
    start := IO_gettimeofday();
    Info(InfoIO, 2, "Started ", n, " jobs..."); 
    while true do
        fds := EmptyPlist(n);
        jobnr := EmptyPlist(n);
        for i in [1..n] do
            if not(IsBound(results[i])) then
                Add(fds,pipes[i]);
                Add(jobnr,i);
            fi;
        od;
        if Length(fds) = 0 then break; fi;
        if opt.TimeOut.tv_sec = false then
            r := IO_select(fds,[],[],false,false);
        else
            now := IO_gettimeofday();
            diff := DifferenceTimes(now,start);
            cmp := CompareTimes(opt.TimeOut, diff);
            if cmp <= 0 then
                for i in [1..n] do
                    Kill(jo[i]);
                od;
                Info(InfoIO, 2, "Timeout occurred, all jobs killed.");
                return results;
            fi;
            diff := DifferenceTimes(opt.TimeOut, diff);
            r := IO_select(fds, [], [], diff.tv_sec, diff.tv_usec);
        fi;
        for i in [1..Length(fds)] do
            if fds[i] <> fail then
                j := jobnr[i];
                results[j] := WaitUntilIdle(jo[j]);
                Info(InfoIO,2,"Child ",jo[j]!.pid,
                     " has terminated with answer.");
                Kill(jo[j]);  # this is to cleanup data structures
            fi;
        od;
    od;
    return results;
  end);

InstallValue(ParMapReduceByForkOptions,
  rec( TimeOut := rec(tv_sec := false, tv_usec := false),
  ));

InstallGlobalFunction(ParMapReduceWorker,
  function(l, what, map, reduce)
    local res,i;
    res := map(l[what[1]]);
    for i in what{[2..Length(what)]} do
        res := reduce(res,map(l[i]));
    od;
    return res;
  end);

InstallMethod(ParMapReduceByFork, "for a list, two functions and a record",
  [IsList, IsFunction, IsFunction, IsRecord],
  function(l, map, reduce, opt)
    local args,i,jobs,m,n,res,res2,where;
    for n in RecNames(ParMapReduceByForkOptions) do
        if not(IsBound(opt.(n))) then 
            opt.(n) := ParMapReduceByForkOptions.(n); 
        fi;
    od;
    if not(IsBound(opt.NumberJobs)) then
        Error("Need component NumberJobs in options record");
        return fail;
    fi;
    if Length(l) = 0 then
        Error("List to work on must have length at least 1");
        return fail;
    fi;
    n := opt.NumberJobs;
    if Length(l) < n or n = 1 then
        return ParMapReduceWorker(l,[1..Length(l)],map,reduce);
    fi;
    m := QuoInt(Length(l),n);  # is at least 1 by now
    jobs := ListWithIdenticalEntries(n, ParMapReduceWorker);
    args := EmptyPlist(n);
    where := 0;
    for i in [1..n-1] do
        args[i] := [l,[where+1..where+m],map,reduce];
        where := where+m;
    od;
    args[n] := [l,[where+1..Length(l)],map,reduce];
    res := ParDoByFork(jobs,args,opt);  # hand down timeout
    if not(Length(res) = n and ForAll([1..n],x->IsBound(res[x]))) then
        Info(InfoIO, 1, "Timeout in ParMapReduceByFork");
        return fail;
    fi;
    res2 := reduce(res[1],res[2]);  # at least 2 jobs!
    for i in [3..n] do
        res2 := reduce(res2,res[i]);
    od;
    return res2;
  end);

InstallValue(ParListByForkOptions,
  rec( TimeOut := rec(tv_sec := false, tv_usec := false),
  ));

InstallGlobalFunction(ParListWorker,
  function(l, what, map)
    local res,i;
    res := EmptyPlist(Length(what));
    for i in what do res[Length(res)+1] := map(l[i]); od;
    return res;
  end);

InstallMethod(ParListByFork, "for a list, two functions and a record",
  [IsList, IsFunction, IsRecord],
  function(l, map, opt)
    local args,i,jobs,m,n,res,where;
    for n in RecNames(ParListByForkOptions) do
        if not(IsBound(opt.(n))) then 
            opt.(n) := ParListByForkOptions.(n); 
        fi;
    od;
    if not(IsBound(opt.NumberJobs)) then
        Error("Need component NumberJobs in options record");
        return fail;
    fi;
    if Length(l) = 0 then
        return [];
    fi;
    n := opt.NumberJobs;
    if n = 1 then return List(l,map); fi;
    if Length(l) < n then n := Length(l); fi;
    m := QuoInt(Length(l),n);  # is at least 1 by now
    jobs := ListWithIdenticalEntries(n, ParListWorker);
    args := EmptyPlist(n);
    where := 0;
    for i in [1..n-1] do
        args[i] := [l,[where+1..where+m],map];
        where := where+m;
    od;
    args[n] := [l,[where+1..Length(l)],map];
    res := ParDoByFork(jobs,args,opt);  # hand down timeout
    if not(Length(res) = n and ForAll([1..n],x->IsBound(res[x]))) then
        Info(InfoIO, 1, "Timeout in ParListByFork");
        return fail;
    fi;
    return Concatenation(res);
  end);


InstallValue(ParWorkerFarmByForkOptions,
  rec( 
  ));

InstallMethod(ParWorkerFarmByFork, "for a function and a record",
  [IsFunction, IsRecord],
  function(worker, opt)
    local f,i,j,n;
    for n in RecNames(ParWorkerFarmByForkOptions) do
        if not(IsBound(opt.(n))) then 
            opt.(n) := ParWorkerFarmByForkOptions.(n); 
        fi;
    od;
    if not(IsBound(opt.NumberJobs)) then
        Error("Need component NumberJobs in options record");
        return fail;
    fi;
    n := opt.NumberJobs;
    f := rec( jobs := EmptyPlist(n), inqueue := [], outqueue := [],
              whodoeswhat := EmptyPlist(n) );
    # Now create the background jobs:
    for i in [1..n] do
        f.jobs[i] := BackgroundJobByFork(worker,fail,rec());
        if f.jobs[i] = fail then
            for j in [1..i-1] do
                Kill(f.jobs[i]);
            od;
            Info(InfoIO, 1, "Could not start all background jobs.");
            return fail;
        fi;
    od;
    return Objectify(WorkerFarmByForkType, f);
  end);

InstallMethod(Kill, "for a worker farm by fork",
  [IsWorkerFarmByFork],
  function(f)
    local i;
    for i in [1..Length(f!.jobs)] do
        Kill(f!.jobs[i]);
    od;
    f!.jobs := [];
  end);

InstallMethod(ViewObj, "for a worker farm by fork",
  [IsWorkerFarmByFork],
  function(f)
    Print("<worker farm by fork with ",Length(f!.jobs)," workers");
    if Length(f!.jobs) = 0 then
        Print(" already terminated>");
    else
        if IsIdle(f) then
            Print(" currently idle>");
        else
            Print(" busy>");
        fi;
    fi;
  end);

InstallMethod(Submit, "for a worker farm by fork",
  [IsWorkerFarmByFork, IsList],
  function(f,args)
    Add(f!.inqueue,args);
    DoQueues(f,false);
  end);

InstallMethod(Pickup, "for a worker farm by fork",
  [IsWorkerFarmByFork],
  function(f)
    local res;
    DoQueues(f,false);
    res := f!.outqueue;
    f!.outqueue := [];
    return res;
  end);

InstallMethod(IsIdle, "for a worker farm by fork",
  [IsWorkerFarmByFork],
  function(f)
    DoQueues(f,false);
    return Length(f!.whodoeswhat) = 0;
  end);

InstallMethod(DoQueues, "for a worker farm by fork",
  [IsWorkerFarmByFork, IsBool],
  function(f, block)
    local args,i,k,n,pipes,res;
    if Length(f!.jobs) = 0 then
        Error("worker farm is already terminated");
        return;
    fi;
    n := Length(f!.jobs);
    # First send arguments to jobs which are known to be idle:
    if Length(f!.inqueue) > 0 then
        for i in [1..n] do
            if not(IsBound(f!.whodoeswhat[i])) then
                Info(InfoIO, 3, "Submitting arglist to worker #", i);
                args := Remove(f!.inqueue,1);
                Submit(f!.jobs[i],args);
                f!.whodoeswhat[i] := args;
            fi;
            if Length(f!.inqueue) = 0 then break; fi;
        od;
    fi;
    # Now check all jobs, see whether they have become idle, get the
    # results and possibly submit another task. We limit the selection
    # by a non-blocking select call (note that jobs known to be idle
    # do not show up here!):
    repeat
        pipes := List(f!.jobs,x->IO_GetFD(x!.childtoparent));
        if not(block) then
            k := IO_select(pipes,[],[],0,0);
        else
            k := IO_select(pipes,[],[],false,false);
        fi;
        for i in [1..Length(f!.jobs)] do
            if pipes[i] <> fail then
                # Must have finished since we last looked:
                Info(InfoIO, 3, "Getting result from worker #", i);
                res := Pickup(f!.jobs[i]);
                Add(f!.outqueue,[f!.whodoeswhat[i],res]);
                Unbind(f!.whodoeswhat[i]);
                if Length(f!.inqueue) > 0 then
                    Info(InfoIO, 3, "Submitting arglist to worker #", i);
                    args := Remove(f!.inqueue,1);
                    Submit(f!.jobs[i],args);
                    f!.whodoeswhat[i] := args;
                fi; 
            fi;
        od;
    until k = 0 or block;
  end);

##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
