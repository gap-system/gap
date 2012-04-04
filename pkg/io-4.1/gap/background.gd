#############################################################################
##
##  background.gd               GAP 4 package IO                    
##                                                           Max Neunhoeffer
##
##  Copyright (C) 2006-2011 by Max Neunhoeffer
##  This file is free software, see license information at the end.
##
##  This file contains declarations for background processes using fork.
##

# The types for background jobs by fork:

BindGlobal("BackgroundJobsFamily", NewFamily("BackgroundJobsFamily"));

DeclareCategory("IsBackgroundJob", 
                IsComponentObjectRep and IsAttributeStoringRep);
DeclareRepresentation("IsBackgroundJobByFork", IsBackgroundJob,
  ["pid", "childtoparent", "parenttochild", "result",
   "terminated"]);

BindGlobal("BGJobByForkType", 
           NewType(BackgroundJobsFamily, IsBackgroundJobByFork));


# Some helpers for times:

DeclareGlobalFunction("DifferenceTimes");
DeclareGlobalFunction("CompareTimes");

# The constructor:

DeclareOperation("BackgroundJobByFork", [IsFunction, IsObject]);
DeclareOperation("BackgroundJobByFork", [IsFunction, IsObject, IsRecord]);
DeclareGlobalVariable("BackgroundJobByForkOptions");
DeclareGlobalFunction("BackgroundJobByForkChild");


# The operations/attributes/properties:

DeclareOperation("IsIdle", [IsBackgroundJob]);
DeclareOperation("HasTerminated", [IsBackgroundJob]);
DeclareOperation("WaitUntilIdle", [IsBackgroundJob]);
DeclareOperation("Kill", [IsBackgroundJob]);
DeclareOperation("Pickup", [IsBackgroundJob]);
DeclareOperation("Submit", [IsBackgroundJob, IsObject]);


# Parallel skeletons:

DeclareGlobalVariable("ParTakeFirstResultByForkOptions");

DeclareOperation("ParTakeFirstResultByFork", [IsList, IsList]);
DeclareOperation("ParTakeFirstResultByFork", [IsList, IsList, IsRecord]);
# Arguments are:
#   list of job functions
#   list of argument lists
#   options record

DeclareGlobalVariable("ParDoByForkOptions");

DeclareOperation( "ParDoByFork", [IsList, IsList]);
DeclareOperation( "ParDoByFork", [IsList, IsList, IsRecord]);
# Arguments are:
#   list of job functions
#   list of argument lists
#   options record

DeclareGlobalFunction("ParMapReduceWorker");
DeclareGlobalVariable("ParMapReduceByForkOptions");

DeclareOperation("ParMapReduceByFork",
  [IsList, IsFunction, IsFunction, IsRecord]);
# Arguments are:
#   list to work on
#   map function
#   reduce function (taking two arguments)
#   options record

DeclareGlobalFunction("ParListWorker");
DeclareGlobalVariable("ParListByForkOptions");

DeclareOperation("ParListByFork",
  [IsList, IsFunction, IsRecord]);
# Arguments are:
#   list to work on
#   map function
#   options record


# The types for worker farms by fork:

BindGlobal("WorkerFarmsFamily", NewFamily("WorkerFarmsFamily"));

DeclareCategory("IsWorkerFarm", 
                IsComponentObjectRep and IsAttributeStoringRep);
DeclareRepresentation("IsWorkerFarmByFork", IsWorkerFarm,
  ["jobs", "inqueue", "outqueue", "whodoeswhat"]);
   

BindGlobal("WorkerFarmByForkType", 
           NewType(WorkerFarmsFamily, IsWorkerFarmByFork));

DeclareGlobalVariable("ParWorkerFarmByForkOptions");

DeclareOperation("ParWorkerFarmByFork", [IsFunction, IsRecord]);
# Arguments are:
#   worker function
#   options record
#
# This creates a new object of type "IsWorkerFarmByFork".

DeclareOperation("DoQueues", [IsWorkerFarmByFork, IsBool]);
DeclareOperation("Kill", [IsWorkerFarmByFork]);
DeclareOperation("Submit", [IsWorkerFarmByFork, IsList]);
DeclareOperation("IsIdle", [IsWorkerFarmByFork]);
DeclareOperation("Pickup", [IsWorkerFarmByFork]);

# Semantics:
#   Starts some background jobs, maintains an "in" and an "out" queue.
#   DoQueues feeds idle jobs from the input queue and gets results 
#   from them for the output queue.
#   Kill and IsIdle work on all workers at the same time. Submit queues
#   new jobs to the input queue and Pickup fetches all from the current
#   output queue (pairs of the form [arglist,result]).

##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
