gap> START_TEST("random.tst");
gap> Read( Filename( DirectoriesLibrary( "tst" ), "testrandom.g" ) );
gap> randomTest(Integers, Random);
gap> randomTest(Rationals, Random);
gap> randomTest([1..10], Random);
gap> randomTest([1,-6,"cheese", Group(())], Random);
gap> randomTest(PadicExtensionNumberFamily(3, 5, [1,1,1], [1,1]), Random, function(x,y) return IsPadicExtensionNumber(x); end);
gap> randomTest(PurePadicNumberFamily(2,20), Random, function(x,y) return IsPurePadicNumber(x); end);
gap> STOP_TEST("random.tst", 1);
