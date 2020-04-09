Print("--------------------\n");
Print("Building GAP manuals\n");
Print("--------------------\n");

if not IsBound(createPDF) then
    createPDF := true;
fi;

if books = "all" then
    books := ["ref", "tut", "hpc", "dev"];;
else
    books := [books];
fi;

for run in [1 .. runs] do
  for book in books do
    path := Concatenation(base, "/doc/", book);
    # skip over missing manuals
    if not IsDirectoryPath(path) then
        continue;
    fi;
    Print("----------------------------\n");
    Print("Building GAP manual '",book,"' at ",path,"\n");
    Print("Run ",run," of ", runs, "\n");
    Print("----------------------------\n");
    if run = 1 then
        createBlackAndWhite := false;
    else
        createBlackAndWhite := true;
    fi;
    dir := Directory(path);
    f := Filename(dir, "makedocrel.g");
    Read(f);
  od;
od;
