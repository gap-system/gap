Tracing := AtomicRecord ( rec ( Trace := false,
                   StartTime := 0,
                   FileNameNo := ShareObj([1]),
                   Files := AtomicList ([])));

MicroSeconds := function()
  local t;
  t := CurrentTime();
  return t.tv_sec * 1000000 + t.tv_usec;
end;

MSTime := function()
  return MicroSeconds() - Tracing.StartTime;
end;

PostProcessLogging := function()
  local fp;
  fp := IO_File("tmp/eventlog","w");
  IO_Write(fp,

StopLogging := function()
  Tracing.trace := false;
  PostProcessLogging();
end;

StartLogging := function()
  local loadIO;
  Tracing.Trace := true;
  loadIO := LoadPackage("io");
  if IsIdenticalObj(loadIO,fail) then
    Print ("IO package failed to load. Logging disabled\n");
    StopLogging();
  else
    Tracing.StartTime := MicroSeconds();
  fi;
end;

InitWorkerLog := function()
  local fname;
  atomic Tracing.FileNameNo do
    fname := Concatenation ("tmp/w", String(Tracing.FileNameNo[1]));
    Tracing.FileNameNo[1] := Tracing.FileNameNo[1]+1;
  od;
  Tracing.Files[ThreadID(CurrentThread())] := IO_File(fname,"w");
  IO_Write(Tracing.Files[ThreadID(CurrentThread())], 
          MSTime(), " ", ThreadID(CurrentThread()), " WORKER_CREATED\n");
end;
