#############################################################################
##
##  Tests for RunProcess
##
gap> START_TEST("process.tst");

#@if ARCH_IS_UNIX()

# the exit code is reported rather than raised as an error
gap> RunProcess("true").status;
0
gap> RunProcess("false").status = 0;
false

# output is captured by default
gap> RunProcess("echo", "GAP is great!");
rec( output := "GAP is great!\n", status := 0 )

# arguments are passed verbatim; no shell sees them, so spaces and quotes
# need no escaping
gap> RunProcess("printf", "[%s]", "a b", "c'd", "e*f").output;
"[a b][c'd][e*f]"

# integers are accepted and converted
gap> RunProcess("printf", "[%s]", 42, -7).output;
"[42][-7]"

# an absolute path is used as-is
gap> RunProcess("/bin/echo", "hi").output;
"hi\n"

# input defaults to nothing at all
gap> RunProcess("cat").output;
""
gap> RunProcess("cat", rec(input := InputTextString("meow\n"))).output;
"meow\n"

# with an explicit output stream, the result has no output component
gap> out := "";; RunProcess("echo", "hi", rec(output := OutputTextString(out, false)));
rec( status := 0 )
gap> out;
"hi\n"

# the working directory can be chosen
gap> dir := DirectoryTemporary();;
gap> PrintTo(Filename(dir, "marker"), "");
gap> RunProcess("ls", rec(directory := dir)).output;
"marker\n"

# error cases
gap> RunProcess();
Error, must specify a command to execute
gap> RunProcess(rec(directory := DirectoryCurrent()));
Error, must specify a command to execute
gap> RunProcess("echo", rec(colour := "blue"));
Error, unsupported option 'colour'
gap> RunProcess("this-program-does-not-exist");
Error, could not locate executable for 'this-program-does-not-exist'
gap> RunProcess("echo", [1, 2]);
Error, arguments must be strings or integers
gap> RunProcess("echo", rec(input := 1));
Error, <options>.input must be an input stream
gap> RunProcess("echo", rec(output := 1));
Error, <options>.output must be an output stream
gap> RunProcess("echo", rec(directory := "/tmp"));
Error, <options>.directory must be a directory object

# a record in a non-final position is treated as an argument, and rejected
gap> RunProcess("echo", rec(), "x");
Error, arguments must be strings or integers
#@fi

#
gap> STOP_TEST("process.tst");
