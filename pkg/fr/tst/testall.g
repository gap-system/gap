LoadPackage("fr");
SetInfoLevel(InfoFR,1);
dirs := DirectoriesPackageLibrary("fr","tst");
ReadTest(Filename(dirs,"chapter-3.tst"));
ReadTest(Filename(dirs,"chapter-4.tst"));
ReadTest(Filename(dirs,"chapter-5-a.tst"));
ReadTest(Filename(dirs,"chapter-5-b.tst"));
ReadTest(Filename(dirs,"chapter-i.tst"));
ReadTest(Filename(dirs,"chapter-9.tst"));