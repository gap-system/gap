LoadPackage("openmath");

dir := DirectoriesPackageLibrary("openmath","tst");

testsfiles := [ 
"openmath02.tst",
"openmath03.tst",
"test_new"
];

Print("=================================================================\n");
for ff in testsfiles do
  fn := Filename(dir, ff );
  Print("*** TESTING ", fn, "\n");
  ReadTest( fn );
  Print("=================================================================\n");
od;  
Print("*** FINISHED OPENMATH PACKAGE TESTS\n");
Print("=================================================================\n");