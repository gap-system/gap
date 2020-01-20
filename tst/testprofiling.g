#############################################################################
##
##  This file runs all tests from the 'tst/testprofiling' directory of the
##  GAP distribution. This contains tests for the profiling functionality
##  GAP provides. They are kept separate from the regular tests, as those are
##  also run with the profiler enabled -- but testing the profiling code
##  while the profiler runs does not work.
##

TestDirectory( [ DirectoriesLibrary( "tst/testprofiling" ) ],
  rec(exitGAP := true) );
  
# Should never get here
ForceQuitGap(1);
