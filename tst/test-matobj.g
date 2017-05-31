TestDirectory( [ DirectoriesLibrary( "tst/test-matobj" ) ],
               rec(exitGAP := true, testOptions := rec( compareFunction := "uptowhitespace" ) ) );

