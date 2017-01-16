#############################################################################
##
#W  testmanuals.g
##
##  <#GAPDoc Label="[1]{testmanuals.g}">
##  <#/GAPDoc>
##

# This code extracts the examples from manuals chapter-wise and
# stores them in a file that can be passed to the Test function

pathtodoc := DirectoriesLibrary("doc/ref");
Read(Filename(pathtodoc, "makedocreldata.g"));
GAPInfo.ManualDataRef.pathtodoc := DirectoriesLibrary("doc/ref");
GAPInfo.ManualDataRef.pathtoroot := DirectoriesLibrary("");

exsref := ExtractExamples(
    GAPInfo.ManualDataRef.pathtodoc,
    GAPInfo.ManualDataRef.main,
    GAPInfo.ManualDataRef.files,
    "Chapter" );

WriteExamplesTst := function(directory)
    local ch, chname, chapterfiles, i, a, output;
    chapterfiles := [];
    directory := Directory(directory);
    for i in [1..Length(exsref)] do
        ch := exsref[i];
        if Length(ch) > 0 then
            chname := STRINGIFY("chapter", i, ".tst");
            Add(chapterfiles, chname);

            # Note that the following truncates the testfile.
            output := OutputTextFile( Filename(directory, chname), false );
            SetPrintFormattingStatus( output, false );

            AppendTo(output, "####  Reference manual, Chapter ",i,"  ####\n",
                     "gap> START_TEST(\"", chname, "\");\n");
            for a in ch do
                AppendTo(output, "\n#LOC# ", a[2], a[1]);
                if a[1][Length(a[1])] <> '\n' then
                   AppendTo(output, "\n");
                fi;
            od;
            AppendTo(output, "\n\n\ngap> STOP_TEST(\"", chname, "\", 0);");
        fi;
    od;
    return chapterfiles;
end;

testdir := Filename(DirectoriesLibrary("tst")[1], "testmanuals");
CreateDir(testdir);
Print("Extracting manual examples to ", testdir, "...\n");
WriteExamplesTst( testdir );
QUIT_GAP(0);

#############################################################################
##
#E

