
SpinsPerSecond := rec();

SpinInners := rec(
                  smallint := function(loops)
    local   i,  x;
    x := 0;
    for i in [1..loops] do
        x := (x + i) mod 2^26;
    od;
end,
  largeint := function(loops)
    local   x,  i;
    x := 2^100;
    for i in [1..loops] do
        x := x + i;
    od;
end,
  listNoAlloc := function(loops)
    local   x,  i;
    x := [1,3,2];
    for i in [1..loops] do
        x[i mod 3 + 1] := (x[ (i +2) mod 3 + 1] + i) mod 2^26;
    od;
end,
  listAllocating := function(loops)
    local   x,  i;
    x := [1,3,2];
    for i in [1..loops] do
        x := ShallowCopy(x) * i mod 2^26;
    od;
end);
    
    
Spin := function(which, microseconds)
    SpinInners.(which)(QuoInt(microseconds*SpinsPerSecond.(which),1000000));
    return true;
end;

for n in NamesOfComponents(SpinInners) do
    ct := 1;
    repeat
        t := Runtime();
        SpinInners.(n)(ct);
        ct := ct*5;
        t := Runtime()-t;
    until t > 1000;
    SpinsPerSecond.(n) := QuoInt(200*ct,t);
od;

Realtime := function() 
    local   s,  str;
    s := "";
    str := OutputTextString(s,true);
    Process(DirectoryCurrent(),
            Filename(DirectoriesSystemPrograms(),"date"),
            InputTextNone(),
            str,
            ["+%s"]);
    CloseStream(str);
    RemoveCharacters(s," \n");
    return Int(s);
end;

TestParList := function(parListFun,ntasks, nworkers, spintype, taskLenFun)
    local   lens,  t,  tr;
    lens := List([1..ntasks],taskLenFun);
    t := Runtime();
    tr := Realtime();
    parListFun(lens, t->Spin(spintype,t), nworkers);
    return [Runtime()-t,1000*(Realtime()-tr)];
end;
