LoadPackage( "polenta" );
dirs := DirectoriesPackageLibrary( "polenta", "tst" );

ReadTest( Filename( dirs, "polenta_finite.tst" ) );
ReadTest( Filename( dirs, "POLENTA.tst" ) );
ReadTest( Filename( dirs, "POLENTA2.tst" ) ); # slow
#ReadTest( Filename( dirs, "POLENTA3.tst" ) ); # VERY slow

