LoadPackage("io");

SetInfoLevel(InfoIO,2);

f := function(g)
  return Size(Centre(g));
end;

l := AllSmallGroups(128);
Print("Have ",Length(l)," small groups.\n");
t := IO_gettimeofday();
ll := ParListByFork(l,f,rec(NumberJobs := 4));
Print("Parallel time (4 jobs): ",DifferenceTimes(IO_gettimeofday(),t),"\n");
t := IO_gettimeofday();
lll := List(l,f);
Print("Sequential time (1 job): ",DifferenceTimes(IO_gettimeofday(),t),"\n");
if ll <> lll then
    Error("did not work");
fi;
