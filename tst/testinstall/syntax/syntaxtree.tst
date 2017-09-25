# This test prints the names of the test functions that fail to produce the desired output
gap> Read( Filename(DirectoriesLibrary( "tst/testinstall/syntax" ), "testsyntax.g" ) );
gap> i := PositionsProperty([1..Length(trees)], i -> trees[i] <> expect_trees[i]);;
gap> List(trees{ i }, x -> x.name);
[  ]

#
