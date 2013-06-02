Dear All,

After some experiments with Hudson build system ( http://hudson-ci.org/ ),
I've setup the following four periodic jobs on our Hudson facility to test 
GAP 4.4.12 and GAP.dev on a regular basis without packages and with all 
currently distributed packages. You can find all jobs listed below using
the Hudson interface: http://cvs.gap-system.org:8080/hudson/

The four jobs are:

1) GAP-dev

This is a so-called "matrix" job which tests all 20 combinations
parametrised by: 32/64 bits mode, GMP yes/no and 5 tests: testinstall,
teststandard, testmanuals, testpackages, testpackagesload. It is running
nightly (full run takes 5-7 hours on 2 CPUs, in the night normally about
5:15 as shows the preceding week).

2) GAP-4.4.12 

This is also a "matrix" job which tests all 10 combinations parametrised 
by 32/64 bits mode and 5 tests: testinstall, teststandard, testmanuals, 
testpackages, testpackagesload. It is running weekly (or may be started 
manually by demand, if faster check is needed).

3) GAP-dev-plots

This job retrieves results from (1) and displays graphs with the runtimes 
of testinstall and teststandard in 8 combinations (32bit/64bit; GMP yes/no; 
with/without packages).

4) GAP-4.4.12-plots 

This is a job similar to (3) which displays graphs with runtimes of tests
from (2), except GMP, of course. It will be running weekly as well as (2).

Some features:
- automatic email notifications about failed tests.
- ability to specify the time limit to terminate long test and report failure.
- keeping archive of console outputs across the specified period of time
  or for the specified number of recent builds.
- having an account on the machine containing Hudson workspace, you may
  have a quick access to all configurations if you need to check something.
- "matrix" jobs displays a table with the status of builds, from which you
  may easier see if there are any problems triggered by GMP or 32/64-bit modes.
- graphs will allow to notice it easier if there will be any changes in the 
  system or in the packages that have an impact on the performance.
- the console output contains tests log files, just search for "===OUT" string 
  to quickly navigate between them.
- clicking on the data point on the performance graph, you may go to the page
  for the corresponding build.

Such configuration can be easily customised for another jobs, for example:
- testing GAP on other architectures, including Mac OS X and Windows (desirable).
- job for the GAP.dev release branch (definitely need it at some prerelease stage).
- job to wrap new packages archive and test it, or, alternatively,
  job to get the newly wrapped packages archive from some place and test it,
  then someone will check the output and make the archive public or not.
- job to check Frank's rsync distribution (will this be useful?).

Limitations you should be aware of:

- Architecture: Currently only one architecture is tested.

- Test granularity: The idea is that each single job performs exactly one of 
  standard five tests in a specified configuration. Combining two or more tests
  in a single job would make failure reports less informative. On the other side,
  for the maintenance purposes, it would be too much overhead to create separate
  jobs for e.g. testinstall with and without packages, or for each individual file
  from the tst directory - while now I can just use standard targets from the
  Makefile. 

- Failure detection: if there is a failure, there is definitely a problem. However,
  if there is no failure reported, it does not mean that there are no problems. 
  More specifically:
  - for testinstall and teststandard I rely on the fact that the last line of the 
    test log has format "total <GAP4Stones> <runtime,msec>" to extract runtime 
    information for the plots. If there is no such line, this will mean that at 
    least one (with/without packages) of the tests failed, and a failure will be 
    reported. Otherwise, both tests must be completed, and then discrepancies could 
    be seen from the test output. 
  - testmanuals, testpackages and testpackagesload will normally fail only if a
    critical error happened during the pre-test phase. Otherwise, I would expect 
    that they will never report a failure after the "make test..." command. To see 
    the actual picture, one need to have a look at the test output.
  We may think how to design standard tests to improve failure detection, but, for 
  now, it would be convenient to keep the setup for GAP.dev and GAP 4.4.12 jobs as 
  similar as possible, and, for the future, any such modifications should be useful 
  also when tests will be performed by the user from the system prompt. We might 
  introduce some success metrics, like the number of lines where output differs, but 
  this will have a very limited practical meaning: we may put them on a graph to be 
  able to spot earlier any dramatic changes, but then change of 1-2 lines may be
  not easily seen, or same number may be a result of combination of fixes and new 
  bugs, so the most reliable way would be to see the test log anyway. 

Policy for packages:

- GAP 4.4.12 is not changing, so the main usage of this job is to test currently
  redistributed packages. Therefore, if there are any incompatibilities between
  packages such that LoadAllPackages() doesn't work, this will break 2nd parts of
  testinstall and teststandard tests so they will be reported as failed. This will
  stay as such until the problem with the packages will be resolved. 

- GAP.dev is used for development, so (a) we can not wait until this problems with
  packages will be resolved and (b) some packages may be incompatible with GAP.dev
  and we can not wait even longer. So if some packages will break the GAP.dev
  tests, they will be excluded from the test until the problem will be fixed. There
  are some of packages in this list now.

I've created a directory dev/hudson in GAP.dev and put there scripts and notes from
this email. I will write a separate message with an overview of the current status 
of the tests shortly. 

Best wishes,
Alexander,
November 2009







