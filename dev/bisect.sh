#!/bin/sh
#
#  This script can be used together with `git bisect run` to track down
#  regressions. In a nutshell, `git bisect` performs a binary search on a
#  range of commits to find the one which introduced a change in behavior
#  (when branches and merge commits are involved, things are considerably more
#  complicated; for further information, please read `git help bisect`).
#
#  To use this script, you need a .tst file that tests the regression.
#  Moreover, you need to know at least one commit in which the bug is not
#  (yet) present, and one where it is present. Finally, you must make
#  a copy of this script, preferably outside the GAP directory. For example,
#  copy it to /tmp/gap-bisect.sh.
#
#  Then, execute the following commands from the GAP root directory; note that
#  the last command will usually checkout a different commit, so make sure
#  you have a clean working tree.
#       git bisect start
#       git bisect bad KNOWN-BAD-COMMIT
#       git bisect good KNOWN-GOOD-COMMIT
#
#  Now you normally need to test the commit selected by `git bisect` and then
#  report whether it is "good" or "bad". This is where this script comes in:
#  it can automate this for you using a .tst file, which means that you can
#  drink a coffee while it does the bisecting work for you. To use it, issue
#  the following command next:
#
#       git bisect run /PATH/TO/COPY/OF/bisect.sh YOUR_TEST_FILE.tst
#
#  Then git will start to check out revisions, and run this script, which in
#  turn compiles GAP, and then runs the test file given to it; depending on
#  the outcome of the test, the current commit is marked as bad or good, and
#  so on, until the commit introducing the change is found.
#
#  Some usage hints and caveats:
#
#  For a known bad commit, typically you will use `master`, but sometimes also
#  `stable-4.XYZ` may be useful.
#
#  For a known good commit, you can typically try to use `stable-4.X` for the
#  last major GAP release in which the regression was not yet present.
#
#  This script has to rebuild GAP in each iteration. This may involve
#  re-running the `configure` script. Beware: if you used `configure` options
#  that are not supported by older versions of the script, or changed
#  semantics, this can cause the build to fail. It is thus safest to use this
#  script after running `configure` with no options given.
#
#  When tracking down very old issues, it may be necessary to test versions of
#  GAP before 4.9. But between 4.8 and 4.9, we changed our build system, and
#  merged HPC-GAP. These changes complicate the bisecting process. Therefore
#  it is usually best to first determine if the issue was introduced before or
#  after these changes. Two tags were made on suitable commits before and
#  after these changes. So typically, you will first check if
#  bisect-before-hpcgap-merge is good (by checking it out, and running this
#  script). Depending on the outcome, mark it either as good via `git bisect
#  good`, and then proceed as above; or else mark it as bad, then proceed to
#  test bisect-before-hpcgap-merge.
#
#  For reference, here are the commit hashes to which the tags refer:
#
#  a5cb6b00726281d5310b89e5c4088fb62aa8d9d0  bisect-before-hpcgap-merge
#  c30acd6be350871560bd2efbff3af01f642a9fb6  bisect-after-new-buildsys
#
set -e

TESTFILE=$1

# rebuild GAP; if that fails, signal to `git bisect` that we cannot decide whether
# this commit is bad or good.
echo "Recompiling GAP..."
autoconf || exit 125
make -j8 || exit 125

echo "HEAD: "$(git rev-parse HEAD)
echo "Running tests..."

echo '
# if ErrorLevel is not defined, something is very wrong, so skip the commit
if not IsBound(ErrorLevel) then
  Print("Panic, ErrorLevel not defined, skipping this commit\\n");
  FORCE_QUIT_GAP(125);
fi;

# intercept any further break loops and again, bail out
OnBreak:=function()
  Print("Panic, break loop was triggered, skipping this commit\\n");
  FORCE_QUIT_GAP(125);
end;

# check if we are in an error handler...
if ErrorLevel > 0 then
  if IsBoundGlobal("TRANSREGION") then
    # workaround for bug in commit range f3da6b3812a293ca..d2ea52ef86a1c68b
    # where GAP may not start if the current version of transpkg is present, due
    # to a conflict in the definition of TRANSREGION
    MakeReadWriteGlobal("TRANSREGION");
    return;
  else
    # ... for any other error: tell git to skip this commit
    Print("Panic, GAP run into an error during startup, skipping this commit\\n");
    FORCE_QUIT_GAP(125);
  fi;
fi;

# run the actual test
if Test("'${TESTFILE}'") then
  Print("Commit is good\\n");
  QUIT_GAP(0);
else
  Print("Commit is bad\\n");
  QUIT_GAP(1);
fi;
' | ./gap -A -b -q
