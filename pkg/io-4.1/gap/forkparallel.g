DeclareInfoClass("InfoIO");

DoChild := function( pipefd, func, arglist )
    local file,ppid,ret;
    ppid := IO_getppid();
    ret := CallFuncList(func,arglist);
    file := IO_WrapFD(pipefd,false,1024);
    IO_Pickle(file,ret);
    IO_Close(file);
    IO_exit(0);
end;

DoParallelOptions := rec(
  TimeOutSecs := false, 
  TimeOutuSecs := false,
);

DoParallelByFork := function(jobs,opt)
  local answered,answers,file,i,j,n,pid,pids,pipes,pipescopy,r;
  if not(IsEvenInt(Length(jobs))) or Length(jobs) < 4 or
     not(IsRecord(opt)) then
      Error(Concatenation("Usage: DoParallelByFork(jobs,opt); where ",
                          "jobs is [func,arglist{,func,arglist})"));
      return fail;
  fi;
  IO_InstallSIGCHLDHandler();
  for n in RecNames(DoParallelOptions) do
      if not(IsBound(opt.(n))) then opt.(n) := DoParallelOptions.(n); fi;
  od;
  n := Length(jobs)/2;
  pipes := EmptyPlist(n);
  for i in [1..n] do
      pipes[i] := IO_pipe();
      if pipes[i] = fail then
          for j in [1..i-1] do
              IO_close(pipes[j].towrite);
              IO_close(pipes[j].toread);
          od;
          Error("Cannot make pipes");
      fi;
  od;
  pids := EmptyPlist(n);
  for i in [1..n] do
      pid := IO_fork();
      if pid = 0 then
          # we are in the child:
          for j in [1..n] do
              if j <> i then
                  IO_close(pipes[j].towrite);
                  IO_close(pipes[j].toread);
              else
                  IO_close(pipes[j].toread);
              fi;
          od;
          DoChild( pipes[i].towrite, jobs[2*i-1], jobs[2*i] );
          IO_exit(0);
      fi;
      pids[i] := pid;
      Info(InfoIO,2,"Started child, pid=",pid);
      IO_close(pipes[i].towrite);
  od;
  pipes := List(pipes,x->x.toread);
  pipescopy := ShallowCopy(pipes);
  r := IO_select(pipescopy,[],[],opt.TimeOutSecs,opt.TimeOutuSecs);
  answered := [];
  answers := EmptyPlist(n);
  for i in [1..n] do
      if pipescopy[i] = fail then
          IO_close(pipes[i]);
          IO_kill(pids[i],IO.SIGTERM);
          IO_WaitPid(pids[i],true);
          Info(InfoIO,2,"Child ",pids[i]," terminated.");
      else
          Add(answered,i);
      fi;
  od;
  Info(InfoIO,2,"Getting answers...");
  for i in answered do
      file := IO_WrapFD(pipes[i],1024,false);
      answers[i] := IO_Unpickle(file);
      IO_Close(file);
      IO_WaitPid(pids[i],true);
      Info(InfoIO,2,"Child ",pids[i]," terminated with answer.");
  od;
  return answers;
end;

