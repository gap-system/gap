#
# This file can be read in HPC-GAP and legacy GAP
#
# All runtimes are in seconds, time taken by gettimeofday syscall
#

if not IsBound(CurrentTime) then
    if IsBound(IO_gettimeofday) then
        BindGlobal("CurrentTime", IO_gettimeofday);
    else
        Error("Don't know a way to get time of day\n");
    fi;
fi;
MicroSeconds := function()
    local t;
    t := CurrentTime();
    return t.tv_sec * 1000000 + t.tv_usec;
end;
Bench := function(f)
    local start,stop;
    start := MicroSeconds();
    f();
    stop := MicroSeconds();

    return (stop - start) * 1.0 / 1000000;
end;


# This is bad for non-generational GCs
gc := function()
  local i, t;
  for i in [1..100000000] do
    t := [i];               
  od;
end;

# This is bad for generational GCs
gc2 := function()
  local i, j, t;
  for j in [1..100] do
    t := fail;
    for i in [1..1000000] do
      t := [t, t];
    od;
  od;
end;    

res := [];
res2 := [];


for i in [1..10] do
    Print("run ", i, "...");
    Add(res, Bench(gc));
    Print(" completed.\n");
od;

for i in [1..10] do
    Print("run ", i, "...");
    Add(res2, Bench(gc2));
    Print(" completed.\n");
od;

Print(res, "\n");
Print(res2, "\n");
