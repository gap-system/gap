gap> d := DirectoryCurrent();;
gap> scriptdir := DirectoriesLibrary( "tst/teststandard/processes/" );;
gap> checkpl := Filename(scriptdir, "check.pl");;

# If IO is loaded, disable its signal handler
gap> if IsBoundGlobal("IO_RestoreSIGCHLDHandler") then
> ValueGlobal("IO_RestoreSIGCHLDHandler")();
> fi;
gap> runChild := function(ms, ignoresignals)
>    local signal;
>    if ignoresignals then signal := "1"; else signal := "0"; fi;
>    return InputOutputLocalProcess(d, checkpl, [ String(time), signal]);
>  end;;
gap> for i in [1..200] do
> children := List([1..20], x -> runChild(Random([1..2000]), Random([false,true])));;
> if ForAny(children, x -> x=fail) then Print("Failed producing child\n"); fi;
> Perform(children, CloseStream);
> od;
