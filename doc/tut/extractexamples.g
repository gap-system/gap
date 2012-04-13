# This code extracts the examples from the ref manual chapter-wise and
# stores this in a workspace.

Read("makedocreldata.g");
exstut := ExtractExamples(GAPInfo.ManualDataTut.pathtodoc,
       GAPInfo.ManualDataTut.main, GAPInfo.ManualDataTut.files, "Chapter");

RS := rec(changeSources := true);
WS := rec(compareFunction := "uptowhitespace");
WSRS := rec(changeSources := true, compareFunction := "uptowhitespace");

WriteTutExamplesTst := function(fnam)
  local ch, i, a;
  PrintTo(fnam,"gap> save:=SizeScreen();; SizeScreen([72,save[2]]);;\n");
  for i in [1..Length(exstut)] do
    ch := exstut[i];
    AppendTo(fnam, "\n####  Tutorial, Chapter ",i,"  ####\n",
                   "gap> START_TEST(\"", i, "\");\n");
    for a in ch do
      AppendTo(fnam, "\n# ",a[2], a[1]);
    od;
  od;
  AppendTo(fnam, "gap> SizeScreen(save);;\n");
end;
