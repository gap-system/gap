# This test would badly break if we run it while profiling is active
# So in that case we just make sure we don't break anything
gap> START_TEST("prof.tst");
gap> base := Filename( DirectoriesLibrary( "tst" ), "example-dir/long-files/");;
gap> tempdir := DirectoryTemporary();;
gap> prof := IsLineByLineProfileActive();;
gap> if prof then Print("prof.tst will produce failures if run with profiling"); fi;
gap> CLEAR_PROFILE_OVERFLOW_CHECKS();
gap> Read(Concatenation(base, "line-65535.g"));;
gap> f(100);
102
gap> Read(Concatenation(base, "line-65536.g"));;
gap> f(100);
110
gap> Read(Concatenation(base, "line-65537.g"));;
gap> f(100);
200
gap> CLEAR_PROFILE_OVERFLOW_CHECKS();
gap> if not prof then ProfileLineByLine(Filename(tempdir, "profout.gz")); fi;
gap> Read(Concatenation(base, "line-65535.g"));;
gap> f(100);
102
gap> Read(Concatenation(base, "line-65536.g"));;
Error, Profiling only works on the first 65,535 lines of each file
(this warning will only appear once).
gap> f(100);
102
gap> Read(Concatenation(base, "line-65536.g"));;
gap> f(100);
110
gap> Read(Concatenation(base, "line-65537.g"));;
gap> f(100);
200
gap> if prof then lim := 10; else lim := 66000; fi;
gap> for i in [1..lim] do
> f := fail;
> Read(Concatenation(base, "line-65536.g"));
> if f(100) <> 110 then Print("bad"); fi;
> od;
Error, Profiling only works for the first 65,535 read files
(this warning will only appear once).
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `CallFuncList' on 2 arguments
gap> for i in [1..10] do
> f := fail;
> Read(Concatenation(base, "line-65536.g"));
> if f(100) <> 110 then Print("bad"); fi;
> od;
gap> if not prof then UnprofileLineByLine(); fi;
gap> STOP_TEST("prof.tst", 1);
