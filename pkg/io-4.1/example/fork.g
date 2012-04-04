# An example using fork:

LoadPackage("io");
IO_InstallSIGCHLDHandler();    # install correct signal handler

pid := IO_fork();
if pid < 0 then
    Error("Cannot fork!");
fi;
if pid > 0 then   # the parent
    Print("Did fork, now waiting for child...\n");
    
    a := IO_WaitPid(pid,true);
    Print("Got ",a," as result of WaitPid.\n");
else
    # the child:
    res := IO_execv("/bin/ls",["/tmp"]);
    Print("execv did not work: ",res);
fi;

pid := IO_fork();
if pid < 0 then
    Error("Cannot fork!");
fi;
if pid > 0 then   # the parent
    repeat
        a := IO_WaitPid(pid,false);
        Print(".\c");
    until a <> false;
    Print("Got ",a," as result of WaitPid.\n");
else
    # the child:
    e := IO_Environment();
    e.myvariable := "xyz";
    res := IO_execve("/usr/bin/env",[],IO_MakeEnvList(e));
    Print("execve did not work: ",res);
fi;

pid := IO_fork();
if pid < 0 then
    Error("Cannot fork!");
fi;
if pid > 0 then   # the parent
    repeat
        a := IO_WaitPid(pid,false);
        Print(".\c");
        Sleep(1);
    until a <> false;
    Print("Got ",a," as result of WaitPid.\n");
else
    # the child:
    res := IO_execvp("sleep",["5"]);
    Print("execvp did not work: ",res);
fi;

