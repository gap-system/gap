#description Normalizers, conjugacy and set stabilizers by partition backtrack
#author Max Horn
#timelimit 3
#cmdlineops
#packages

# Runs all cases of the suite but the sweeps in this one process; run.py
# runs them in separate processes with time limits instead. A global
# BENCH_FILTER, if bound, restricts the cases to those whose name contains
# it.

Read( "../runner.g" );
BENCH := rec( dir := "..", suite := "pbt" );
Read( "pbt.g" );

starttime := Runtime();
bad := false;
for case in BENCH_CASES do
  if case.category = "sweep" then
    continue;
  elif IsBound( BENCH_FILTER )
       and PositionSublist( case.name, BENCH_FILTER ) = fail then
    continue;
  fi;
  r := BENCH_RunCase( case, [ 1 ] );
  if r.status = "ok" then
    Print( case.name, ": ", r.result, " ", r.ms[1], " ms\n" );
    if r.result = "false" then
      bad := true;
      Print( "*** FAIL ", case.name, "\n" );
    fi;
  elif r.status = "skipped" then
    Print( case.name, ": skipped, ", r.error, "\n" );
  else
    bad := true;
    Print( "*** FAIL ", case.name, ": ", r.error, "\n" );
  fi;
od;

Print( "*** RUNTIME ", Runtime() - starttime, "\n" );

if bad then
  QuitGap(1);
else
  QuitGap(0);
fi;
