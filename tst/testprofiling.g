#############################################################################
##
##  This file runs all tests from the 'tst/testprofiling' directory of the
##  GAP distribution. This contains tests for the profiling functionality
##  GAP provides. They are kept separate from the regular tests, as those are
##  also run with the profiler enabled -- but testing the profiling code
##  while the profiler runs does not work.
##

Print( "You should start GAP4 using `gap -A -x 80 -r -m 100m -o 1g -K 2g'.\n\n" );

TestDirectory( [ DirectoriesLibrary( "tst/testprofiling" ) ],
  rec(exitGAP := true) );
  
# Should never get here
FORCE_QUIT_GAP(1);

#############################################################################
##
#E
