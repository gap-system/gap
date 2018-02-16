#############################################################################
##
#W  testmanuals.g
##
##  <#GAPDoc Label="[1]{testmanuals.g}">
##  <#/GAPDoc>
##

# This code extracts the examples from manuals chapter-wise and
# stores them in a file that can be passed to the Test function

WriteExamplesTst := function(directory, meta)
    local examples, ch, chname, chapterfiles, i, a, output;
    examples := ExtractExamples(meta.pathtodoc, meta.main,
                                meta.files, "Chapter" );
    chapterfiles := [];
    directory := Directory(directory);
    for i in [1..Length(examples)] do
        ch := examples[i];
        if Length(ch) > 0 then
            chname := STRINGIFY(meta.bookname, "-chapter", String(1000+i){[2..4]}, ".tst");
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

#
# reference manual
#
Print("Extracting reference manual examples to ", testdir, "...\n");
pathtodoc := DirectoriesLibrary("doc/ref");
Read(Filename(pathtodoc, "makedocreldata.g"));
GAPInfo.ManualDataRef.pathtodoc := pathtodoc;
GAPInfo.ManualDataRef.pathtoroot := DirectoriesLibrary("");
WriteExamplesTst( testdir, GAPInfo.ManualDataRef );

#
# tutorial
#
Print("Extracting tutorial examples to ", testdir, "...\n");
pathtodoc := DirectoriesLibrary("doc/tut");
Read(Filename(pathtodoc, "makedocreldata.g"));
GAPInfo.ManualDataTut.pathtodoc := pathtodoc;
GAPInfo.ManualDataTut.pathtoroot := DirectoriesLibrary("");
WriteExamplesTst( testdir, GAPInfo.ManualDataTut );

#
QUIT_GAP(0);

#############################################################################
##
#E

