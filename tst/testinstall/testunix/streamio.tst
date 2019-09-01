#@local scriptdir, write, checkPartialRead, process, c
#
gap> START_TEST("streamio.tst");
gap> scriptdir := DirectoriesLibrary( "tst/teststandard/processes/" );;
gap> write := Filename(scriptdir, "slowwrite.sh");;

# Read the output of 'prog', using 'readfunc'. The output should
# come in two parts, 'firstread' and 'secondread'.
# If GAP is too slow, allow 'firstread' and 'secondread' to be read
# in one step, but then return 'false'.
# We run this function multiple times to avoid very occasional failures
# due to OS scheduling.
gap> checkPartialRead := function(prog, readfunc, firstread, secondread)
> local process, l;
> process := InputOutputLocalProcess(DirectoryCurrent(), prog, ["prog", firstread, secondread]);
> l := ReadLine(process);
> if l = Concatenation(firstread, secondread) then
>   if ReadLine(process) <> fail then Error("Invalid end - type 1"); fi;
>   CloseStream(process);
>   return false;
> else
>   if ReadLine(process) <> secondread then Error("Missing second"); fi;
>   if ReadLine(process) <> fail then Error("Invalid end - type 2"); fi;
>   CloseStream(process);
>   return true;
> fi;
> end;;

#@if ARCH_IS_UNIX()
gap> ForAny([1..10], x -> checkPartialRead(write, ReadLine, "aaa", "aaa\n"));
true
gap> ForAny([1..10], x -> checkPartialRead(write, ReadLine, "aaa", "aaa"));
true
gap> ForAny([1..10], x -> checkPartialRead(write, ReadAll, "aaa", "aaa\n"));
true

# Read as bytes, which is always identical
gap> process := InputOutputLocalProcess(DirectoryCurrent(), write, ["prog", "abc", "def"]);
< input/output stream to slowwrite.sh >
gap> c := ReadByte(process);
97
gap> c := ReadByte(process);
98
gap> c := ReadByte(process);
99
gap> c := ReadByte(process);
100
gap> c := ReadByte(process);
101
gap> c := ReadByte(process);
102
gap> c := ReadByte(process);
fail
gap> CloseStream(process);
#@fi
gap> STOP_TEST("streamio.tst", 1);
