#description Decide finiteness of 153 cyclotomic matrix groups at two seeds
#author Max Horn
#timelimit 1
#cmdlineops
#packages:

starttime := Runtime();

Read( "matgrp.g" );
res := RunMatGrpBenchmark( [ 0, 1 ] );

Print( "*** RUNTIME ", Runtime()-starttime, "\n" );

if res then
  QuitGap(0);
else
  QuitGap(1);
fi;
