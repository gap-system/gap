gap> START_TEST("streams.tst");

#
gap> tmpdir := DirectoryTemporary();;
gap> fname := Filename(tmpdir, "data");;

# write initial data
gap> stream := OutputTextFile( fname, false );;
gap> PrintTo( stream, "1");
gap> AppendTo( stream, "2");
gap> PrintTo( stream, "3");
gap> CloseStream(stream);

# verify it
gap> StringFile(fname);
"123"

# append to initial data
gap> stream := OutputTextFile( fname, true );;
gap> PrintTo( stream, "4");
gap> CloseStream(stream);

# verify it
gap> StringFile(fname);
"1234"

# overwrite initial data
gap> stream := OutputTextFile( fname, false );;
gap> PrintTo( stream, "new content");
gap> CloseStream(stream);

# verify it
gap> StringFile(fname);
"new content"

#
gap> STOP_TEST( "streams.tst", 1);
