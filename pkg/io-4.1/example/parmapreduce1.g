LoadPackage("io");
l := List([1..1000000],i->Random(1,100));;

GASMAN("collect");
start := IO_gettimeofday();;
a := Sum(l,Factorial);
Print("Non-parallel: ",DifferenceTimes(IO_gettimeofday(),start),"\n");

for i in [2..8] do
    GASMAN("collect");
    start := IO_gettimeofday();;
    b := ParMapReduceByFork(l,Factorial,\+,rec(NumberJobs := i));
    Print("With ",i," jobs: ",DifferenceTimes(IO_gettimeofday(),start),"\n");
od;
