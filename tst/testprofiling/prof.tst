# This test would badly break if we run it while profiling is active
# So in that case we just make sure we don't break anything
gap> START_TEST("prof.tst");
gap> tempdir := DirectoryTemporary();;
gap> prof := IsLineByLineProfileActive();;
gap> if prof then Print("prof.tst will produce failures if run with profiling"); fi;
gap> longFile := function(l)
>      return Concatenation( [ ListWithIdenticalEntries(l - 1, '\n'),
>                              "f := function(x) return x + ", String(l), "; end;\n" ] );
>    end;;
gap> FileString(Filename(tempdir, "line-65535.g"), longFile(65535));;
gap> FileString(Filename(tempdir, "line-65536.g"), longFile(65536));;
gap> FileString(Filename(tempdir, "line-65537.g"), longFile(65537));;
gap> Read(Filename(tempdir, "line-65535.g"));;
gap> f(0);
65535
gap> Read(Filename(tempdir, "line-65536.g"));;
gap> f(0);
65536
gap> Read(Filename(tempdir, "line-65537.g"));;
gap> f(0);
65537
gap> IsLineByLineProfileActive();
false
gap> if not prof then ProfileLineByLine(Filename(tempdir, "profout")); fi;
#I  Profile filenames must end in .gz to enable compression
gap> IsLineByLineProfileActive();
true
gap> Read(Filename(tempdir, "line-65535.g"));;
gap> f(0);
65535
gap> Read(Filename(tempdir, "line-65536.g"));;
gap> f(0);
65536
gap> Read(Filename(tempdir, "line-65536.g"));;
gap> f(0);
65536
gap> Read(Filename(tempdir, "line-65537.g"));;
gap> f(0);
65537
gap> for i in [1..10] do
> f := fail;
> Read(Filename(tempdir, "line-65536.g"));
> if f(0) <> 65536 then Print("bad"); fi;
> od;
gap> f(0);
65536
gap> for i in [1..10] do
> f := fail;
> Read(Filename(tempdir, "line-65536.g"));
> if f(0) <> 65536 then Print("bad"); fi;
> od;
gap> if not prof then UnprofileLineByLine(); fi;
gap> IsLineByLineProfileActive();
false
gap> STOP_TEST("prof.tst", 1);
