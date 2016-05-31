gap> START_TEST("random.tst");
gap> Read( Filename( DirectoriesLibrary( "tst" ), "testrandom.g" ) );
gap> randomTest(Integers, Random);
gap> randomTest([1..10], Random);
gap> randomTest([1,-6,"cheese", Group(())], Random);
gap> STOP_TEST("random.tst", 1);
