#@if IsHPCGAP
#
# some tests to specifically trigger code which causes the coverage reports on
# codecov to fluctuate (due to indeterminism in the multi threaded execution).
#
# ideally, these should be moved to better fitting test files in the future.
#

# hit early return in TraverseRegionFrom(), from src/hpc/traverse.c
# by doing a StructuralCopy on an object we don't have access on
gap> x:=0;;
gap> WaitThread( CreateThread( function() x:=[1,2,3]; end ) );
gap> StructuralCopy(x);
Error, Object not in a readable region


# threadapi.c:
#  - fluctuation in SignalMonitor: need to get to queue = queue->next;
#  - fluctuation in SyncRead

# stdtasks.g:
#   FireTrigger:    if trigger.done then return; fi   at start

#@fi
