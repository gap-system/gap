d := DirectoryCurrent();;
f := Filename(DirectoriesSystemPrograms(), "rev");;
s := InputOutputLocalProcess(d,f,[]);;
Sleep(1);
CloseStream(s); Print("\n");
