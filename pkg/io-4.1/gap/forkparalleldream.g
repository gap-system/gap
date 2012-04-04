j := BackgroundJobByFork( func, args )
IsIdle(j)               -> true or false
HasTerminated(j)        -> true or false
WaitUntilIdle(j)        -> returns value
WaitUntilTerminated(j) 
Kill(j)
GetResult(j)
SendArguments(j,args)

ParMapReduceByFork(l,mapfunc,redfunc,opt)
  options:  
    NumberJobs

ParTakeFirstResultByFork(jobs,args,opt)
  options:  
    TimeOutSecs
    TimeOutuSecs

ParDo(jobs,args,opt)
  options:
    TimeOutSecs
    TimeOutuSecs

w := ParMakeWorkersByFork(jobs,args,opt)
  options:
    NumberJobs
Kill(w)
SendWork(w,args)
IsIdle(w)
AreAllIdle(w)
