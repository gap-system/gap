#
# This file can be read in HPC-GAP and legacy GAP
#
# All runtimes are in seconds, time taken by gettimeofday syscall
#

ReadGapRoot("demo/bench.g");

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
