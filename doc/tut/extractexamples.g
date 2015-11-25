# This code extracts the examples from the ref manual chapter-wise

Read("makedocreldata.g");
exstut := ExtractExamples(GAPInfo.ManualDataTut.pathtodoc,
       GAPInfo.ManualDataTut.main, GAPInfo.ManualDataTut.files, "Chapter");
       
PrintTo("exstut.g", "exstut:=", exstut, ";"); 

RS := rec(changeSources := true);
WS := rec(compareFunction := "uptowhitespace");
WSRS := rec(changeSources := true, compareFunction := "uptowhitespace");

WriteTutExamplesTst := function(prefixfnam)
  local ch, i, a, fnam;
  for i in [1..Length(exstut)] do
    fnam := Concatenation( prefixfnam, String(i), ".tst" );
    PrintTo(fnam,"gap> save:=SizeScreen();; SizeScreen([72,save[2]]);;\n");
    ch := exstut[i];
    AppendTo(fnam, "\n####  Tutorial, Chapter ",i,"  ####\n",
                   "gap> START_TEST(\"", i, "\");\n");
    for a in ch do
      AppendTo(fnam, "\n# ",a[2], a[1]);
    od;
    AppendTo(fnam, "gap> SizeScreen(save);;\n");
  od;
end;

WriteTutExamplesTst("tut");
