LoadPackage( "FGA" );
dirs := DirectoriesPackageLibrary( "FGA", "tst" );
ReadTest( Filename( dirs, "FGA.tst" ) );
