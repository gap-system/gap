LoadPackage("float");
SetInfoLevel(InfoFloat,1);
dirs := DirectoriesPackageLibrary("float","tst");

SetFloats(IEEE754FLOAT);
ReadTest(Filename(dirs,"arithmetic.tst"));
SetFloats(MPFR);
ReadTest(Filename(dirs,"arithmetic.tst"));
SetFloats(MPFI);
ReadTest(Filename(dirs,"arithmetic.tst"));
SetFloats(MPC);
ReadTest(Filename(dirs,"arithmetic.tst"));
SetFloats(CXSC);
ReadTest(Filename(dirs,"arithmetic.tst"));
