# This code extracts the examples from the ref manual chapter-wise

Read("makedocreldata.g");
exsref := ExtractExamples(GAPInfo.ManualDataRef.pathtodoc,
       GAPInfo.ManualDataRef.main, GAPInfo.ManualDataRef.files, "Chapter");
       
PrintTo("exsref.g", "exsref:=", exsref, ";"); 

RS := rec(changeSources := true);
WS := rec(compareFunction := "uptowhitespace");
WSRS := rec(changeSources := true, compareFunction := "uptowhitespace");

WriteRefExamplesTst := function(prefixfnam)
  local ch, i, a, fnam;
  for i in [1..Length(exsref)] do
    fnam := Concatenation( prefixfnam, String(i), ".tst" );
    PrintTo(fnam,"gap> save:=SizeScreen();; SizeScreen([72,save[2]]);;\n");
    ch := exsref[i];
    AppendTo(fnam, "\n####  Reference Manual, Chapter ",i,"  ####\n",
                   "gap> START_TEST(\"", i, "\");\n");
    for a in ch do
      AppendTo(fnam, "\n# ",a[2], a[1]);
    od;
    AppendTo(fnam, "gap> SizeScreen(save);;\n");
  od;
end;

WriteRefExamplesTst("ref");
