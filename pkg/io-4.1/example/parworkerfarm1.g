LoadPackage("io");
l := List([1..100],x->Random(1,1000));;                
wf := ParWorkerFarmByFork(x->x^2,rec(NumberJobs := 4));
for i in [1..Length(l)] do Submit(wf,[l[i]]); od;
while not(IsIdle(wf)) do DoQueues(wf,true); Print(".\c"); od;
Print("\n");
result := Pickup(wf);
Kill(wf);
Print(l,"\n",result,"\n");

