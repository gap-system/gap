gap> START_TEST("streams.tst");

#
# input/output streams
#
gap> d := DirectoryCurrent();;
#@if ARCH_IS_UNIX()
gap> f := Filename(DirectoriesSystemPrograms(), "cat");;
gap> s := InputOutputLocalProcess(d,f,[]);
< input/output stream to cat >
gap> WriteLine(s,"The cat sat on the mat");
true
gap> repeat str := ReadLine(s); until str <> fail; str;
"The cat sat on the mat\n"
gap> WriteLine(s,"abc");
true
gap> WriteLine(s,"xyz");
true
gap> repeat str := ReadAllLine(s); until str <> fail; str;
"abc\n"
gap> CloseStream(s);
gap> s;
< closed input/output stream to cat >
#@fi

#
gap> STOP_TEST( "streams.tst", 1);
