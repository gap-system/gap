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
  local files,i, outFile, lastIndex;
  outFile := IO_File("tmp/gap.gaplog","w");
  i := 0;
  while true do
    files[i] := IO_File(Concatenation("tmp/w",String(i)),"r");
    if IsIdenticalObj(files[i],fail) then
      lastIndex := i;
      break;
    else
      line[i] := IO_ReadLine(files[i]);
      i := i+1;
    fi;
  od;
  
end;

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
