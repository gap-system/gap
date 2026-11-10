#############################################################################
##
##  Tests that Process tells apart an exit code, death by a signal, and a
##  program which never started.
##
gap> START_TEST("processstatus.tst");

#@if ARCH_IS_UNIX()
gap> procDir := DirectoryTemporary();;
gap> chmod := PathSystemProgram("chmod");;
gap> WriteProcTestScript := function(name, contents)
>      local file;
>      file := Filename(procDir, name);
>      PrintTo(file, contents);
>      Process(DirectoryCurrent(), chmod, InputTextNone(), OutputTextNone(),
>              ["+x", file]);
>      return file;
>    end;;
gap> RunProcTest := file -> Process(DirectoryCurrent(), file, InputTextNone(),
>                           OutputTextNone(), []);;

# an ordinary exit code is reported as is
gap> RunProcTest(WriteProcTestScript("exit42", "#!/bin/sh\nexit 42\n"));
42

# 255 is an exit code like any other, and must not be confused with a failure
# to start the program
gap> RunProcTest(WriteProcTestScript("exit255", "#!/bin/sh\nexit 255\n"));
255

# a program which cannot be started at all: the file is executable, so it gets
# as far as execve, which then fails
gap> RunProcTest(WriteProcTestScript("badinterp", "#!/nonexistent/interpreter\n"));
fail

# Death by a signal is reported as the negated signal number. Only SIGKILL is
# tested: any other signal may be caught by the shell, which then exits with
# 128+s (OpenBSD), or be blocked by a signal mask inherited from GAP (as when
# running inside Julia).
gap> RunProcTest(WriteProcTestScript("sigkill", "#!/bin/sh\nkill -KILL $$\n"));
-9
#@fi

#
gap> STOP_TEST("processstatus.tst");
